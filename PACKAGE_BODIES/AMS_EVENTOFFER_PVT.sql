--------------------------------------------------------
--  DDL for Package Body AMS_EVENTOFFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENTOFFER_PVT" AS
/*$Header: amsvevob.pls 120.13 2006/10/26 01:06:17 batoleti ship $*/
g_pkg_name   CONSTANT VARCHAR2(30):='AMS_EventOffer_PVT';

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Check_Dates_Range (
   p_evo_rec          IN  evo_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
);

PROCEDURE Check_Parent_Active (
   p_evo_rec          IN  evo_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
);


PROCEDURE Update_Metrics (
   p_evo_rec          IN  evo_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2,
   x_msg_count OUT NOCOPY VARCHAR2,
   x_msg_data OUT NOCOPY VARCHAR2
);

FUNCTION check_association_exists(
   p_obj_type               IN VARCHAR2,
   p_obj_id                  IN NUMBER,
   p_association_with         IN VARCHAR2,
   p_additional_where_clause   IN VARCHAR2 := NULL
)
Return VARCHAR2
IS

   l_sql   VARCHAR2(4000);
   l_count NUMBER;
   l_type_col  VARCHAR2(100);
   l_id_col    VARCHAR2(100);
   l_table_name VARCHAR2(200);
   l_additional_where_clause  VARCHAR2(1000) := p_additional_where_clause;

BEGIN

   if (p_association_with IN ('DELV', 'CAMP')) then
      l_table_name := 'AMS_OBJECT_ASSOCIATIONS';
      l_type_col := 'MASTER_OBJECT_TYPE';
      l_id_col := 'MASTER_OBJECT_ID';
      if l_additional_where_clause is null then
      /*
         l_additional_where_clause := ' USING_OBJECT_TYPE = ''' || p_association_with || '''';
      */
      -- SQL Bind Project
      -- Use Bind Variables
         l_additional_where_clause := 'USING_OBJECT_TYPE = :b1 ';
      else
      /*
         l_additional_where_clause := l_additional_where_clause ||
                        ' AND USING_OBJECT_TYPE = ''' || p_association_with || '''';
      */
      -- Use Bind Variables
         l_additional_where_clause := l_additional_where_clause || ' AND USING_OBJECT_TYPE = :b1 ';
      end if;
   end if;
/*
   if (p_association_with = 'CAMP') then
      l_table_name := 'AMS_OBJECT_ASSOCIATIONS';
      l_type_col := 'MASTER_OBJECT_TYPE';
      l_id_col := 'MASTER_OBJECT_ID';
      if l_additional_where_clause is null then
         l_additional_where_clause := ' USING_OBJECT_TYPE = ''' || p_association_with || '''';
      else
         l_additional_where_clause := l_additional_where_clause ||
                        ' AND USING_OBJECT_TYPE = ''' || p_association_with || '''';
      end if;
   end if;
*/
   if (p_association_with = 'MESG') then
      l_table_name := 'AMS_ACT_MESSAGES';
      l_type_col := 'MESSAGE_USED_BY';
      l_id_col := 'MESSAGE_USED_BY_ID';
   end if;

   if (p_association_with = 'PROD') then
      l_table_name := 'AMS_ACT_PRODUCTS';
      l_type_col := 'ARC_ACT_PRODUCT_USED_BY';
      l_id_col := 'ACT_PRODUCT_USED_BY_ID';
   end if;

   if (p_association_with = 'RESC') then
      l_table_name := 'AMS_ACT_RESOURCES';
      l_type_col := 'ARC_ACT_RESOURCE_USED_BY';
      l_id_col := 'ACT_RESOURCE_USED_BY_ID';
   end if;

   if (p_association_with = 'CELL') then
      l_table_name := 'AMS_ACT_MARKET_SEGMENTS';
      l_type_col := 'ARC_ACT_MARKET_SEGMENT_USED_BY';
      l_id_col := 'ACT_MARKET_SEGMENT_USED_BY_ID';
   end if;

   if (p_association_with = 'ATCH') then
      l_table_name := 'JTF_AMV_ATTACHMENTS';
      l_type_col := 'ATTACHMENT_USED_BY';
      l_id_col := 'ATTACHMENT_USED_BY_ID';
   end if;

   if (p_association_with = 'TEAM') then
      l_table_name := 'AMS_ACT_ACCESS';
      l_type_col := 'ARC_ACT_ACCESS_TO_OBJECT';
      l_id_col := 'ACT_ACCESS_TO_OBJECT_ID';
   end if;

   if (p_association_with = 'NOTE') then
      l_table_name := 'JTF_NOTES_VL';
      l_type_col := 'SOURCE_OBJECT_CODE';
      l_id_col := 'SOURCE_OBJECT_ID';
   end if;

   if (p_association_with = 'TASK') then
      l_table_name := 'JTF_TASKS_VL';
      l_type_col := 'SOURCE_OBJECT_TYPE_CODE';
      l_id_col := 'SOURCE_OBJECT_ID';
   end if;

   -- Commented and replaced for SQL Bind Project
   /*
   l_sql := 'SELECT count(*) FROM ' || l_table_name;
   l_sql := l_sql || ' WHERE ' || l_type_col || ' = ''' || p_obj_type ||'''';
   l_sql := l_sql || ' AND ' || l_id_col || ' = ' || p_obj_id;
   */

   l_sql := 'SELECT count(*) FROM ' || l_table_name || ' WHERE ' || l_type_col || ' = :b2 AND ';
   l_sql := l_sql || l_id_col || ' = :b3 ';



   IF l_additional_where_clause IS NOT NULL THEN
      l_sql := l_sql || ' AND ' || l_additional_where_clause;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('SQL statement: '||l_sql);

   END IF;

   IF l_additional_where_clause IS NOT NULL THEN
     -- We need to bind 3 vars for DELV and CAMP
     EXECUTE IMMEDIATE l_sql INTO l_count
     USING p_obj_type, p_obj_id, p_association_with;
   ELSE
     -- We need to bind 2 vars for all others
     EXECUTE IMMEDIATE l_sql INTO l_count
     USING p_obj_type, p_obj_id;
   END IF;

   IF l_count = 0 THEN
      RETURN FND_API.g_false;
   ELSE
      RETURN FND_API.g_true;
   END IF;

END check_association_exists;

---------------------------------------------------------------------
-- PROCEDURE
--    create_inv_item
--
-- HISTORY
--    03/05/2000  sugupta   Create.
---------------------------------------------------------------------
PROCEDURE create_inv_item
(
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_inv_item_number     IN  VARCHAR2,
  p_inv_item_desc       IN  VARCHAR2,
  p_inv_long_desc      IN  VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_item_id            OUT NOCOPY NUMBER,
  x_org_id          OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_header
--
-- HISTORY
--    03/05/2000  sugupta     Create.
---------------------------------------------------------------------

PROCEDURE create_pricelist_header
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_evo_rec               IN  evo_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_header_id     OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_line
--
-- HISTORY
--    03/05/2000  sugupta     Create.
---------------------------------------------------------------------

PROCEDURE create_pricelist_line
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_price_hdr_id            IN  NUMBER,
  p_evo_rec                 IN   evo_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_line_id       OUT NOCOPY NUMBER
);

PROCEDURE copy_ev_header_to_offer(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_evo_rec             OUT NOCOPY      evo_rec_type,
      p_src_evh_id         IN       NUMBER,
      p_evo_rec            IN       evo_rec_type
);

PROCEDURE copy_ev_header_associations(
      p_api_version         IN        NUMBER,
      p_init_msg_list       IN        VARCHAR2 := fnd_api.g_false,
       p_commit             IN        VARCHAR2 := fnd_api.g_false,
      p_validation_level    IN        NUMBER   := FND_API.g_valid_level_full,
      x_return_status       OUT NOCOPY       VARCHAR2,
      x_msg_count           OUT NOCOPY       NUMBER,
      x_msg_data            OUT NOCOPY       VARCHAR2,
     x_transaction_id       OUT NOCOPY       NUMBER,
      p_src_evh_id          IN        NUMBER,
      p_evo_id              IN        NUMBER,
     p_setup_id             IN        NUMBER
);

PROCEDURE check_evo_update(
   p_evo_rec       IN OUT NOCOPY  AMS_EVENTOFFER_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);
PROCEDURE check_evo_inter_entity(
   p_evo_rec        IN  evo_rec_type,
   p_complete_rec    IN  evo_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE create_global_pricing(
   p_evo_rec        IN OUT NOCOPY evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    create_event_offer
--
-- HISTORY
--    11/23/1999  sugupta  Created.
--     01/20/2000  gdeodhar Added the reg_required_flag column to create stmt.
--                     Also added the user_status_id = 1 and system_status_code = 'NEW'
--                     in the create statement.
--    07/20/2000  sugupta  user_status_id equal to 1 only for event_level=MAIN
---------------------------------------------------------------------
PROCEDURE create_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_evo_rec            IN  evo_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   x_evo_id            OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'create_event_offer';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status VARCHAR2(1);
   l_evo_rec       evo_rec_type;
   l_dlv_rec      AMS_ActDelvMethod_PVT.act_DelvMethod_rec_type;
 --  location_rec      hz_location_pub.location_rec_type;
   location_rec      hz_location_v2pub.location_rec_type;
   l_dlv_id       NUMBER := null;
   l_evo_count     NUMBER;
   l_start_time   DATE;
   l_end_time       DATE;
   l_reg_start_time DATE;
   l_reg_end_time   DATE;
   l_copy_flag  VARCHAR2(1);
   l_setup_id   NUMBER := nvl(p_evo_rec.custom_setup_id,1006);
   l_org_id  NUMBER := null;
   l_source_code_id  NUMBER;
   l_user_id  NUMBER;
   l_res_id   NUMBER;
   l_cs_count  NUMBER;
 -- will need to pass this transaction id back to screen.. todo later
   x_transaction_id   NUMBER;
   l_ou_id     NUMBER;
   l_ovn       NUMBER(9) := 1;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR c_evo_seq IS
   SELECT ams_event_offers_all_b_s.NEXTVAL
     FROM DUAL;

   CURSOR c_evo_count(evo_id IN NUMBER) IS
   SELECT count(*)
     FROM ams_event_offers_all_b
    WHERE event_offer_id = evo_id;

   CURSOR c_evo_status_evagd(ust_id IN NUMBER) IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = ust_id
     AND system_status_type = 'AMS_EVENT_AGENDA_STATUS';

   CURSOR c_list_YN(id_in IN NUMBER) IS
   SELECT count(*) FROM ams_custom_setup_attr
   WHERE custom_setup_id = id_in
   AND object_attribute = 'ILST'
   AND ATTR_AVAILABLE_FLAG = 'Y';

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT create_event_offer;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --------------------API CODE--------------------------

   ----------------- copy stuff from headers before validation--------
-- sugupta 03/20/2000 get the profile option..todo
-- if profile option indicates Copying from header to  offer, make a call to
-- copy_ev_header_to_offer procedure to copy appropriate fields from header to offer.
-- associations of header will be copied

   l_copy_flag := FND_PROFILE.Value('AMS_COPY_EVH_TO_EVO');--'Y';

   IF (p_evo_rec.event_level = 'MAIN' and l_copy_flag = 'Y' and p_evo_rec.event_object_type = 'EVEO') then
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message(l_full_name ||': copy header to offer');
      END IF;
      copy_ev_header_to_offer(
         p_api_version       => l_api_version,
         p_init_msg_list     => FND_API.g_false,
         x_return_status     => l_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         x_evo_rec           => l_evo_rec,
         p_src_evh_id        => p_evo_rec.event_header_id,
         p_evo_rec           => p_evo_rec
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      l_evo_rec := p_evo_rec;
      IF l_evo_rec.event_object_type = 'EONE' THEN
         l_evo_rec.event_standalone_flag := 'Y';
      ELSIF l_evo_rec.event_object_type = 'EVEO' THEN
         l_evo_rec.event_standalone_flag := 'N';
      ELSE
         FND_MESSAGE.set_name('AMS', 'AMS_DM_SRC_NO_ARC_USED_FOR_OBJ');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

-----------ADDED CODE to populate task id----------------------
   IF (p_evo_rec.event_level = 'MAIN') THEN
      null;
      /* Hornet :call task creation API */
   END IF;

-- associations for the event header will be copied after creating the event_offer
-- FROM HERE ON ITS L_EVO_REC, NOT P_EVO_REC

--------------- calendar----------------------------
-- added sugupta 08/28/20000--------------
-- default event calendar, present;y defailting it to be same as campaigns calendar.. SHOULD CHANGE
-- not sure about the logic, should it be defaulted only for MAIN events, not the agenda..

-- IF l_evo_rec.event_calendar IS NULL THEN
      l_evo_rec.event_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
-- END IF;
----------------------------user status and system status---------------------

-- added sugupta 07/20/2000 for event agenda, stastuses shouldnt be defaulted to 1/NEW
-- for main event, while creation.. user status shud always be 1, system status always NEW

   IF l_evo_rec.event_level = 'MAIN' then
      l_evo_rec.user_status_id := ams_utility_pvt.get_default_user_status('AMS_EVENT_STATUS','NEW');
      l_evo_rec.system_status_code := 'NEW';
   ELSE
      -- pick up the correct system_status_code
      IF l_evo_rec.user_status_id IS NOT NULL THEN
         OPEN c_evo_status_evagd(l_evo_rec.user_status_id);
         FETCH c_evo_status_evagd INTO l_evo_rec.system_status_code;
         CLOSE c_evo_status_evagd;
      END IF;
   END IF;

   ----------------------- validate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': validate');
   END IF;


   validate_event_offer(
      p_api_version        => l_api_version,
      p_init_msg_list      => p_init_msg_list,
      p_validation_level   => p_validation_level,
      p_evo_rec           => l_evo_rec,
      x_return_status      => l_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   --------------- CHECK ACCESS FOR THE USER ONLY FOR EVENT AGENDA-------------------
   ----------added sugupta 07/25/2000
   IF l_evo_rec.event_level = 'SUB' THEN
      l_user_id := FND_GLOBAL.User_Id;
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
      END IF;
      IF l_user_id IS NOT NULL then
         open get_res_id(l_user_id);
         fetch get_res_id into l_res_id;
         close get_res_id;
      END IF;
      IF AMS_ACCESS_PVT.check_update_access(l_evo_rec.parent_event_offer_id, l_evo_rec.event_object_type, l_res_id, 'USER') = 'N' then
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS');-- reusing the message
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -------------------------- insert --------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': insert');
   END IF;
   -- ==========================================================
   -- Following code is added by mukumar on 10/30/2000
   -- the code will convert the transaction currency in to
   -- functional currency.
   -- ==========================================================
   IF l_evo_rec.fund_amount_tc IS NOT NULL THEN
      AMS_EvhRules_PVT.Convert_Evnt_Currency(
         p_tc_curr     => l_evo_rec.currency_code_tc,
         p_tc_amt      => l_evo_rec.fund_amount_tc,
         x_fc_curr     => l_evo_rec.currency_code_fc,
         x_fc_amt      => l_evo_rec.fund_amount_fc
      ) ;
   END IF ;

   -------------------------event offer id----------------------
   IF l_evo_rec.event_offer_id IS NULL THEN
      LOOP
         OPEN c_evo_seq;
         FETCH c_evo_seq INTO l_evo_rec.event_offer_id;
         CLOSE c_evo_seq;

         OPEN c_evo_count(l_evo_rec.event_offer_id);
         FETCH c_evo_count INTO l_evo_count;
         CLOSE c_evo_count;

         EXIT WHEN l_evo_count = 0;
       END LOOP;
    END IF;


----------------------------source code---------------------
-- if event level is SUB, source_code should be null
-- if incoming source_code is NULL, it is defaulted.

-- Global flag if not passed from the screen, default it as N
   IF l_evo_rec.global_flag IS NULL THEN
      l_evo_rec.global_flag := 'N';
   END IF;

   IF l_evo_rec.event_level = 'SUB' THEN
      l_evo_rec.source_code := null;
   ELSE
      IF l_evo_rec.source_code IS NULL THEN
          l_evo_rec.source_code := AMS_SourceCode_PVT.get_new_source_code (
                            -- replace object type  with table's value once implemented
                           p_object_type => l_evo_rec.event_object_type,
                           p_custsetup_id => l_evo_rec.custom_setup_id,
                           -- replace global_flag with table's value once implemented
                           p_global_flag => l_evo_rec.global_flag
                           );
      END IF;
   END IF;


   /* Code Added By GMadana for date/time validation */
   IF l_evo_rec.event_start_date_time > l_evo_rec.event_end_date_time THEN
      IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error)
      THEN
          Fnd_Message.set_name('AMS', 'AMS_EVO_START_TM_GT_END_TM');
          Fnd_Msg_Pub.ADD;
        END IF;
      x_return_status := Fnd_Api.g_ret_sts_error;
      RAISE Fnd_Api.g_exc_error;
   END IF; -- st tm > end tm

/****************EVENT_DELIVERY_METHOD_ID**********************/
-- l_evo_rec will bring in delivery_method_code.. a l_dlv_rec record type is
-- constructed and passed to Create_Act_DelvMethod which creates a row in
-- AMS_ACT_DELIVERY_METHODS table and returns delivery_method_id which is then
-- inserted into ams_event_offers table.
-- Caution is advised that while retrieving records from event offers table,
-- delivery_method_id is retrieved and not delivery_method_code..
-- ams_event_offers_v takes care of that and returns delivery_method_code though
-- sugupta 3/27/00 change of plans... delivery method will always be passed to update procedure, not create..
-- adding call to Create_Act_DelvMethod in update_event_offer procedure now
-- dlv method code will neevr be passed for event agenda... so no need to put an if loop for event level

   IF (l_evo_rec.EVENT_DELIVERY_METHOD_CODE IS NOT NULL OR
      l_evo_rec.EVENT_DELIVERY_METHOD_CODE <> FND_API.g_miss_char) THEN
      -- This new if statment added to support one of event
      IF l_evo_rec.EVENT_STANDALONE_FLAG = 'Y' THEN
         l_dlv_rec.ARC_ACT_DELIVERY_USED_BY := 'EONE';
         l_dlv_rec.ACT_DELIVERY_METHOD_USED_BY_ID :=  l_evo_rec.event_offer_id;
         l_dlv_rec.DELIVERY_MEDIA_TYPE_CODE := l_evo_rec.EVENT_DELIVERY_METHOD_CODE;
      ELSE
         l_dlv_rec.ARC_ACT_DELIVERY_USED_BY := 'EVEO';
         l_dlv_rec.ACT_DELIVERY_METHOD_USED_BY_ID :=  l_evo_rec.event_offer_id;
         l_dlv_rec.DELIVERY_MEDIA_TYPE_CODE := l_evo_rec.EVENT_DELIVERY_METHOD_CODE;
      END IF;
      AMS_ActDelvMethod_PVT.Create_Act_DelvMethod(
            p_api_version => l_api_version,
            p_init_msg_list => FND_API.g_false,
            p_commit => FND_API.g_false,
            p_validation_level =>  FND_API.g_valid_level_full,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_act_DelvMethod_rec => l_dlv_rec,
            x_act_DelvMethod_id => l_dlv_id);

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


   /* Code Added by GMADANA for Date validation for attaching Program as Parent */
   /* Check_Dates_Range has date validation for MAIN level and SUB level events
      as agenda for Event Schedule has Start date on the GUI.
   */


   -- soagrawa added if clause on 24-feb-2003 for INTERNAL bug# 2816673
   IF(l_evo_rec.event_object_type = 'EONE' AND l_evo_rec.parent_type = 'CAMP')
   THEN
      -- dont check for date range
      NULL;
   ELSE
     Check_Dates_Range(
         p_evo_rec    => p_evo_rec,
         x_return_status      => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;


-- integration with inventory and pricing api's happens at update level..
--the user enters inventory number from reg set up screen..
-- 05/09/2000 however setting up the organization id here from profile option...
   l_org_id := FND_PROFILE.Value('AMS_ITEM_ORGANIZATION_ID');
-- 05/10/2000  based on values of city, state, country passed, call hz_loc API
-- to create a new loc_id to be inserted into offers table
-- city/state/country will never be passed for event agenda... so no need to put an if loop for event level

   IF  (l_evo_rec.CITY IS NULL AND l_evo_rec.STATE IS NULL AND l_evo_rec.COUNTRY IS NULL)
   THEN
      l_evo_rec.event_location_id := null;
   ELSE
      location_rec.country := l_evo_rec.COUNTRY;
      location_rec.state := l_evo_rec.STATE;
      location_rec.city := l_evo_rec.CITY;
      location_rec.address1 := ' ';
      location_rec.ORIG_SYSTEM_REFERENCE := -1;
      location_rec.content_source_type := 'USER_ENTERED';
      location_rec.created_by_module := 'AMS_EVENT';
      hz_location_v2pub.create_location(
            p_init_msg_list     => p_init_msg_list,
            p_location_rec => location_rec,
            x_return_status => l_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_location_id => l_evo_rec.event_location_id
            );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Added by rmajumda (09/15/05). MOAC changes
   l_ou_id := fnd_profile.value('DEFAULT_ORG_ID');


         IF l_evo_rec.object_version_number = 2 THEN -- copy
            l_ovn := 2;
         END IF;

   insert into ams_event_offers_all_b(
      event_offer_id
      ,setup_type_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,object_version_number
      ,application_id
      ,event_header_id
      ,private_flag
      ,active_flag
      ,source_code
      ,event_level
      ,user_status_id
      ,last_status_date
      ,system_status_code
      ,event_type_code
      ,event_delivery_method_id
      ,event_required_flag
      ,event_language_code
      ,event_location_id
      ,overflow_flag
      ,partner_flag
      ,event_standalone_flag
      ,reg_frozen_flag
      ,reg_required_flag
      ,reg_charge_flag
      ,reg_invited_only_flag
      ,reg_waitlist_allowed_flag
      ,reg_overbook_allowed_flag
      ,parent_event_offer_id
      ,event_duration
      ,event_duration_uom_code
      ,event_start_date
      ,event_start_date_time
      ,event_end_date
      ,event_end_date_time
      ,reg_start_date
      ,reg_start_time
      ,reg_end_date
      ,reg_end_time
      ,reg_maximum_capacity
      ,reg_overbook_pct
      ,reg_effective_capacity
      ,reg_waitlist_pct
      ,reg_minimum_capacity
      ,reg_minimum_req_by_date
      ,inventory_item_id
      ,organization_id
      ,pricelist_header_id
      ,pricelist_line_id
      ,org_id
      ,waitlist_action_type_code
      ,stream_type_code
      ,owner_user_id
      ,event_full_flag
      ,forecasted_revenue
      ,actual_revenue
      ,forecasted_cost
      ,actual_cost
      ,fund_source_type_code
      ,fund_source_id
      ,cert_credit_type_code
      ,certification_credits
      ,coordinator_id
      ,priority_type_code
      ,cancellation_reason_code
      ,auto_register_flag
      ,email
      ,phone
      ,fund_amount_tc
      ,fund_amount_fc
      ,currency_code_tc
      ,currency_code_fc
      ,url
      ,timezone_id
      ,event_venue_id
      ,inbound_script_name
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
      ,country_code
      ,business_unit_id
      ,event_calendar
      ,start_period_name
      ,end_period_name
      ,global_flag
      ,task_id  -- Hornet
      --,program_id  -- Hornet
      ,parent_type  -- Hornet
      ,parent_id  -- Hornet
      ,CREATE_ATTENDANT_LEAD_FLAG  --hornet
      ,CREATE_REGISTRANT_LEAD_FLAG  --hornet
      ,event_object_type   --hornet
      ,reg_timezone_id   -- hornet
      ,event_password /* Hornet : added for imeeting integration*/
      ,record_event_flag   /* Hornet : added for imeeting integration*/
      ,allow_register_in_middle_flag  /* Hornet : added for imeeting integration*/
      ,publish_attendees_flag  /* Hornet : added for imeeting integration*/
      ,direct_join_flag   /* Hornet : added for imeeting integration*/
      ,event_notification_method  /* Hornet : added for imeeting integration*/
      ,actual_start_time  /* Hornet : added for imeeting integration*/
      ,actual_end_time  /* Hornet : added for imeeting integration*/
      ,server_id   /* Hornet : added for imeeting integration*/
      ,OWNER_FND_USER_ID
      ,MEETING_DIAL_IN_INFO
      ,MEETING_EMAIL_SUBJECT
      ,MEETING_SCHEDULE_TYPE
      , MEETING_STATUS
      ,PUBLISH_FLAG
      ,MEETING_ENCRYPTION_KEY_CODE
      ,MEETING_MISC_INFO
      ,NUMBER_OF_ATTENDEES
      ,EVENT_PURPOSE_CODE
      )
   VALUES(
      l_evo_rec.event_offer_id,
      l_evo_rec.custom_setup_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      l_ovn,  -- object_version_number Bug 5171873 can be 2 for copy
      l_evo_rec.application_id,
      l_evo_rec.event_header_id,         -- will come from Interface
      NVL(l_evo_rec.private_flag,'N'),      -- Value will come from the User Interface.
      NVL(l_evo_rec.active_flag, 'Y'),      -- 'N' when active_flag is NULL
      l_evo_rec.source_code,            -- If the incoming value is NULL, it must be generated.
      l_evo_rec.event_level,            -- MAIN (event offer), SUB (agenda item)
      l_evo_rec.user_status_id,
      NVL(l_evo_rec.last_status_date,SYSDATE),
      l_evo_rec.system_status_code,
      l_evo_rec.event_type_code,
      l_dlv_id,
      NVL(l_evo_rec.event_required_flag,'N'),
      l_evo_rec.event_language_code,
      l_evo_rec.event_location_id,
      NVL(l_evo_rec.overflow_flag,'N'),
      NVL(l_evo_rec.partner_flag,'N'),
      NVL(l_evo_rec.event_standalone_flag,'N'),      -- Value will come from the User Interface.
      NVL(l_evo_rec.reg_frozen_flag,'N'),
      NVL(l_evo_rec.reg_required_flag,'Y'),         -- Value will come from the User Interface.
      NVL(l_evo_rec.reg_charge_flag,'Y'),         -- Value will come from the UserInterface.
      NVL(l_evo_rec.reg_invited_only_flag,'N'),      -- Value will come from the User Interface.
      NVL(l_evo_rec.reg_waitlist_allowed_flag,'N'),
      NVL(l_evo_rec.reg_overbook_allowed_flag,'N'),
      l_evo_rec.parent_event_offer_id,
      l_evo_rec.event_duration,
      l_evo_rec.event_duration_uom_code,
      l_evo_rec.event_start_date,
      NVL(l_evo_rec.event_start_date_time,l_evo_rec.event_start_date),
      l_evo_rec.event_end_date,
      NVL(l_evo_rec.event_end_date_time,l_evo_rec.event_end_date),
      l_evo_rec.reg_start_date,
      l_reg_start_time,
      l_evo_rec.reg_end_date,
      l_reg_end_time,
      l_evo_rec.reg_maximum_capacity,
      l_evo_rec.reg_overbook_pct,
      l_evo_rec.reg_effective_capacity,
      l_evo_rec.reg_waitlist_pct,
      l_evo_rec.reg_minimum_capacity,
      l_evo_rec.reg_minimum_req_by_date,
      null, -- l_evo_rec.inventory_item_id, in fact, I should be getting inv item id here as well if evo_rec.inv_num is not null... todo
      l_org_id,
      l_evo_rec.pricelist_header_id,
      l_evo_rec.pricelist_line_id,
      --TO_NUMBER(SUBSTRB(userenv('CLIENT_INFO'),1,10)),    -- org_id
      l_ou_id,
      l_evo_rec.waitlist_action_type_code,
      l_evo_rec.stream_type_code,
      l_evo_rec.owner_user_id,
      NVL(l_evo_rec.event_full_flag,'N'),
      l_evo_rec.forecasted_revenue,
      l_evo_rec.actual_revenue,
      l_evo_rec.forecasted_cost,
      l_evo_rec.actual_cost,
      l_evo_rec.fund_source_type_code,
      l_evo_rec.fund_source_id,
      l_evo_rec.cert_credit_type_code,
      l_evo_rec.certification_credits,
      l_evo_rec.coordinator_id,
      l_evo_rec.priority_type_code,
      l_evo_rec.cancellation_reason_code,
      NVL(l_evo_rec.auto_register_flag, nvl(FND_PROFILE.value('AMS_AUTO_REGISTER_FLAG'), 'Y')),
      l_evo_rec.email,
      l_evo_rec.phone,
      l_evo_rec.fund_amount_tc,
      l_evo_rec.fund_amount_fc,
      l_evo_rec.currency_code_tc,
      l_evo_rec.currency_code_fc,
      l_evo_rec.url,
      l_evo_rec.timezone_id,
      l_evo_rec.event_venue_id,
      l_evo_rec.inbound_script_name,
      l_evo_rec.attribute_category,
      l_evo_rec.attribute1,
      l_evo_rec.attribute2,
      l_evo_rec.attribute3,
      l_evo_rec.attribute4,
      l_evo_rec.attribute5,
      l_evo_rec.attribute6,
      l_evo_rec.attribute7,
      l_evo_rec.attribute8,
      l_evo_rec.attribute9,
      l_evo_rec.attribute10,
      l_evo_rec.attribute11,
      l_evo_rec.attribute12,
      l_evo_rec.attribute13,
      l_evo_rec.attribute14,
      l_evo_rec.attribute15,
--      l_evo_rec.country_code,
--      The above will require the JSP to send the country_code as part of the rec.
--      This is not needed the API can pick it up as follows:
      NVL(l_evo_rec.country_code, TO_NUMBER(FND_PROFILE.value('AMS_SRCGEN_USER_CITY'))),
--      The above picks up the country code from the Profile option if the one sent in
--      by the JSP page is null.
      l_evo_rec.business_unit_id,
--      The JSPs are expected to send the value of the business_unit_id. It is nullable.
      l_evo_rec.event_calendar,
      l_evo_rec.start_period_name,
      l_evo_rec.end_period_name,
      nvl(l_evo_rec.global_flag, 'N'),
--      above 4 fields added to be in synch with campaigns
      l_evo_rec.task_id,  -- Hornet
      --l_evo_rec.program_id, -- Hornet
      l_evo_rec.parent_type,  -- Hornet
      l_evo_rec.parent_id  -- Hornet
      ,l_evo_rec.CREATE_ATTENDANT_LEAD_FLAG  --hornet
      ,l_evo_rec.CREATE_REGISTRANT_LEAD_FLAG --hornet
      ,l_evo_rec.event_object_type
      ,l_evo_rec.reg_timezone_id
      ,l_evo_rec.event_password /* Hornet : added for imeeting integration*/
      ,l_evo_rec.record_event_flag   /* Hornet : added for imeeting integration*/
      ,l_evo_rec.allow_register_in_middle_flag  /* Hornet : added for imeeting integration*/
      ,l_evo_rec.publish_attendees_flag  /* Hornet : added for imeeting integration*/
      ,l_evo_rec.direct_join_flag   /* Hornet : added for imeeting integration*/
      ,l_evo_rec.event_notification_method  /* Hornet : added for imeeting integration*/
      ,l_evo_rec.actual_start_time  /* Hornet : added for imeeting integration*/
      ,l_evo_rec.actual_end_time  /* Hornet : added for imeeting integration*/
      ,l_evo_rec.server_id  /* Hornet : added for imeeting integration*/
      ,l_evo_rec.OWNER_FND_USER_ID /* Hornet : added for imeeting integration*/
      ,l_evo_rec.MEETING_DIAL_IN_INFO /* Hornet : added for imeeting integration*/
      ,l_evo_rec.MEETING_EMAIL_SUBJECT /* Hornet : added for imeeting integration*/
      ,l_evo_rec.MEETING_SCHEDULE_TYPE /* Hornet : added for imeeting integration*/
      ,l_evo_rec.MEETING_STATUS /* Hornet : added for imeeting integration*/
      ,l_evo_rec.PUBLISH_FLAG /* Hornet : added for imeeting integration*/
      ,l_evo_rec.MEETING_ENCRYPTION_KEY_CODE /* Hornet : added for imeeting integration*/
      ,l_evo_rec.MEETING_MISC_INFO /* Hornet : added for imeeting integration*/
      ,l_evo_rec.NUMBER_OF_ATTENDEES /* Hornet : added for imeeting integration*/
      ,l_evo_rec.EVENT_PURPOSE_CODE /* Hornet */
   );

   INSERT INTO ams_event_offers_all_tl(
      event_offer_id,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      source_lang,
      event_offer_name,
      event_mktg_message,
      description
   )
   SELECT
      l_evo_rec.event_offer_id,
      l.language_code,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.conc_login_id,
      USERENV('LANG'),
      l_evo_rec.event_offer_name,
      l_evo_rec.event_mktg_message,
      l_evo_rec.description
   FROM fnd_languages l
   WHERE l.installed_flag in ('I', 'B')
   AND NOT EXISTS(
         SELECT NULL
         FROM ams_event_offers_all_tl t
         WHERE t.event_offer_id = l_evo_rec.event_offer_id
         AND t.language = l.language_code );

   x_evo_id := l_evo_rec.event_offer_id;

   --modified sugupta Should do it only for 'MAIN' event level
   IF l_evo_rec.event_level = 'MAIN'  THEN
      --IF p_evo_rec.source_code is NOT NULL THEN
         AMS_EvhRules_PVT.push_source_code(
         l_evo_rec.source_code,
         l_evo_rec.event_object_type,
         l_evo_rec.event_offer_id
         );
      --END IF;
      OPEN c_list_YN(l_evo_rec.custom_setup_id);
      FETCH c_list_YN INTO l_cs_count;
      IF c_list_YN%NOTFOUND THEN
         CLOSE c_list_YN;
      else
         CLOSE c_list_YN;
         AMS_EvhRules_PVT.Create_list(
                           p_evo_id     => x_evo_id,
                           p_evo_name   => l_evo_rec.event_offer_name,
                           p_obj_type  => l_evo_rec.event_object_type,
                           p_owner_id    => l_evo_rec.owner_user_id
                        );
      END IF;
      AMS_EvhRules_PVT.Add_Update_Access_record(p_object_type => l_evo_rec.event_object_type, -- 'EVEO'
                    p_object_id => l_evo_rec.event_offer_id,
                    p_Owner_user_id => l_evo_rec.owner_user_id,
                    x_return_status => l_return_status,
                    x_msg_count          => x_msg_count,
                   x_msg_data           => x_msg_data);
   END IF;

--
-- call to copy_ev_header_associations to copy associations from header to offer
-- presently hardcoding setup_id to 1006 and not using it in the procedure..
-- but will use the setup_id passed from evo_rec to get what object_attributes
-- needs to be copied from header to offer based on setup_id associated with new offer_id..

   IF (l_evo_rec.event_level = 'MAIN' and l_copy_flag = 'Y' and l_evo_rec.event_object_type = 'EVEO') then
      copy_ev_header_associations(
        p_api_version       => l_api_version,
        p_init_msg_list     => FND_API.g_false,
         p_commit            => FND_API.g_false,
        p_validation_level  => FND_API.g_valid_level_full,
        x_return_status     => l_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
          x_transaction_id     => x_transaction_id,
        p_src_evh_id        => p_evo_rec.event_header_id,
        p_evo_id           =>  x_evo_id,
        p_setup_id        =>  l_setup_id
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         --RAISE FND_API.g_exc_error;
         null;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         --RAISE FND_API.g_exc_unexpected_error;
         null;
      ELSE
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_PVT.debug_message(l_full_name ||': transaction id for copy :'|| x_transaction_id );
         END IF;
      END IF;
   END IF;

--
-- The AMS_SourceCode_PVT takes care of inserting the newly generated
-- Source Code in ams_source_codes table.
--
--
--
-- sugupta 22-May-2000
-- Added call to AMS_SourceCode_PVT.create_sourcecode.
-- modified sugupta Should do it only for 'MAIN' event level
-- I don't know why he is generating another source code at the end
   IF l_evo_rec.event_level = 'MAIN'  THEN
      -- attach seeded metrics
      AMS_RefreshMetric_PVT.copy_seeded_metric(
        p_api_version => l_api_version,
        x_return_status => l_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_arc_act_metric_used_by => l_evo_rec.event_object_type, --'EVEO'
        p_act_metric_used_by_id => x_evo_id,
        p_act_metric_used_by_type => NULL
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF; -- check for event level MAIN

   ------------------------- finish -------------------------------

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_event_offer;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_event_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );


   WHEN OTHERS THEN

     IF (c_evo_seq%ISOPEN) THEN
      CLOSE c_evo_seq;
     END IF;
     IF (c_evo_count%ISOPEN) THEN
      CLOSE c_evo_count;
     END IF;

      ROLLBACK TO create_event_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_event_offer;


---------------------------------------------------------------
-- PROCEDURE
--    delete_event_offer
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------
PROCEDURE delete_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   p_evo_id            IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'delete_event_offer';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_offer_id NUMBER;
   l_level  VARCHAR2(30);
   l_user_id  NUMBER;
   l_res_id   NUMBER;
   l_object_type VARCHAR2(30);

   CURSOR get_event_object_type(id_in in NUMBER) is
   SELECT event_object_type
   FROM AMS_EVENT_OFFERS_ALL_B
   WHERE EVENT_OFFER_ID = id_in;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR get_parent_offer_info(l_evo_id IN NUMBER) IS
   SELECT event_level,parent_event_offer_id
   FROM ams_event_offers_all_b
   WHERE event_offer_id = l_evo_id
   and   event_level = 'SUB';

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT delete_event_offer;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   l_user_id := FND_GLOBAL.User_Id;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
   END IF;
   IF l_user_id IS NOT NULL then
      open get_res_id(l_user_id);
      fetch get_res_id into l_res_id;
      close get_res_id;
   END IF;

   open get_parent_offer_info(p_evo_id);
   fetch get_parent_offer_info into l_level, l_offer_id;
   close get_parent_offer_info;

   open get_event_object_type(p_evo_id);
   fetch get_event_object_type into l_object_type;
   close get_event_object_type;

   IF (l_level <> 'SUB' OR l_level IS NULL ) THEN
      l_offer_id := p_evo_id;
   END IF;
   if AMS_ACCESS_PVT.check_update_access(l_offer_id, l_object_type, l_res_id, 'USER') = 'N' then
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS'); --reusing the message
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   end if;

   ------------------------ delete ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': delete');
   END IF;

   UPDATE ams_event_offers_all_b
   SET active_flag = 'N'
   WHERE event_offer_id = p_evo_id
   AND object_version_number = p_object_version;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO delete_event_offer;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO delete_event_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO delete_event_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END delete_event_offer;


-------------------------------------------------------------------
-- PROCEDURE
--    lock_event_offer
--
-- HISTORY
--    11/23/1999  sugupta  Created
--------------------------------------------------------------------
PROCEDURE lock_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   p_evo_id           IN  NUMBER,
   p_object_version    IN  NUMBER,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS

   l_api_version  CONSTANT NUMBER       := 1.0;
   l_api_name     CONSTANT VARCHAR2(30) := 'lock_event_offer';
   l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_evo_id      NUMBER;

   CURSOR c_evo_b IS
   SELECT event_offer_id
     FROM ams_event_offers_all_b
    WHERE event_offer_id = p_evo_id
      AND object_version_number = p_object_version
   FOR UPDATE OF event_offer_id NOWAIT;

   CURSOR c_evo_tl IS
   SELECT event_offer_id
     FROM ams_event_offers_all_tl
    WHERE event_offer_id = p_evo_id
      AND USERENV('LANG') IN (language, source_lang)
   FOR UPDATE OF event_offer_id NOWAIT;

BEGIN

   -------------------- initialize ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ lock -------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': lock');
   END IF;

   OPEN c_evo_b;
   FETCH c_evo_b INTO l_evo_id;
   IF (c_evo_b%NOTFOUND) THEN
      CLOSE c_evo_b;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_evo_b;

   OPEN c_evo_tl;
   CLOSE c_evo_tl;

   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
         FND_MSG_PUB.add;
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END lock_event_offer;


---------------------------------------------------------------------
-- PROCEDURE
--    update_event_offer
--
-- HISTORY
--    11/23/1999  sugupta  Created
--    01/25/2000  gdeodhar  Added code to pick up the system_status_code
--                     from ams_user_statuses_b table. The UI will
--                     never pass this code.
--   07/07/2000   sugupta  modified call inv and pricing api's based on profile option
--   08/01/2000   sugupta   added access code
--   11-feb-2003  soagrawa  fixed access related bug for INTERNAL bug# 2795823
--   02-jun-2003  dbiswas   modified a cursor for bug# 2983031
--   19-aug-2003  soagrawa  fixed bug# 3100382
----------------------------------------------------------------------
PROCEDURE update_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   p_evo_rec          IN  evo_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'update_event_offer';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_evo_rec        evo_rec_type;
   l_global_flag    VARCHAR2(25);
   l_source_code    VARCHAR2(30);
   l_dlv_rec       AMS_ActDelvMethod_PVT.act_DelvMethod_rec_type;
--   location_rec      hz_location_pub.location_rec_type;
   location_rec      hz_location_v2pub.location_rec_type;
   l_dlv_code      VARCHAR2(30);
   l_dlv_id      NUMBER := null;
   l_dlv_ver    NUMBER;
   l_return_status  VARCHAR2(1);
   l_traget_list_exists VARCHAR2(1);

   l_inventory_item_id        NUMBER;
   l_org_id         NUMBER;
   l_inv_item_number    VARCHAR2(40);
   l_inv_item_desc      VARCHAR2(240);
   l_inv_long_desc      VARCHAR2(4000);
   l_pricelist_header_id  NUMBER;
   l_inv_profile   VARCHAR2(1);
   l_qp_profile    VARCHAR2(1);
   ------------------- REMOVE THESE 3 VAR
   l_count       NUMBER;
   l_msg         VARCHAR2(2000);
   l_msg_count   NUMBER;
   ------
   l_user_id  NUMBER;
   l_res_id   NUMBER;
   l_evo_id   NUMBER;
   l_dummy    NUMBER;
   l_resource_id NUMBER;
   l_obj_num  NUMBER;

 -- l_location_rec   HZ_LOCATION_PUB.Location_Rec_Type;
  l_location_rec   HZ_LOCATION_V2PUB.Location_Rec_Type;
   l_location_id  NUMBER;
   l_address1     VARCHAR2(240);
   l_address2     VARCHAR2(240);
   l_city         VARCHAR2(60);
   l_state        VARCHAR2(60);
   l_country      VARCHAR2(60);


   l_sys_st_code    VARCHAR2(30);

   l_oldStDate      DATE;
   l_oldEdDate      DATE;
   l_actres_id      NUMBER;
   l_obj_ver        NUMBER;
   l_system_status_code  VARCHAR2(30);
   l_min_session_time       DATE;
   l_max_session_time       DATE;

/* Following code is modified by ptendulk to move to 1:1 ffm
   l_bind_values      AMF_REQUEST.string_tbl_type;
*/
   --l_bind_names       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   --l_bind_values      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

   -- added by soagrawa for bug# 2761612 21-jan-2003
   l_dummy_source_code   VARCHAR2(30);

-- Somewhere it must be checked however if certain fields can be or
--cannot be updated by the user based on the status of the event.
-- For example, if the event is in active stage, the user will not
--be able to update the Marketing Message or budget related columns.
-- appid, ev_header_id, source_code cannot not be updated by the user.

   CURSOR c_evo_status_evo IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = p_evo_rec.user_status_id
     AND system_status_type = 'AMS_EVENT_STATUS';

   CURSOR c_evo_status_evagd IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = p_evo_rec.user_status_id
   AND system_status_type = 'AMS_EVENT_AGENDA_STATUS';

-- dbiswas modified cursor for bug# 2983031 on 02-jun-2003
   CURSOR c_evo_status IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = l_evo_rec.user_status_id --p_evo_rec.user_status_id
   AND system_status_type = 'AMS_EVENT_STATUS';

   CURSOR c_evo_dlv_mthd IS
   SELECT dlv.delivery_media_type_code, dlv.activity_delivery_method_id, dlv.object_version_number
   FROM Ams_act_delivery_methods dlv, ams_event_offers_all_b off
   WHERE dlv.activity_delivery_method_id = off.event_delivery_method_id
   and off.event_offer_id = p_evo_rec.event_offer_id;

   CURSOR c_pricelist_header_id(curr_code IN VARCHAR2) IS
   SELECT distinct(pricelist_header_id)
   FROM ams_event_offers_all_b evo, qp_price_lists_v qph
   WHERE evo.pricelist_header_id = qph.price_list_id
   AND   qph.currency_code = curr_code;

   CURSOR get_res_id(l_user_id IN NUMBER) IS
   SELECT resource_id
   FROM ams_jtf_rs_emp_v
   WHERE user_id = l_user_id;

   CURSOR c_location(id_in IN NUMBER) IS
   SELECT loc.address1, loc.address2, loc.city, loc.state, loc.country
   FROM   hz_locations loc, ams_event_offers_all_b evo
   WHERE  loc.location_id = evo.event_location_id
   and    evo.event_offer_id = id_in;


   CURSOR c_bdgt_line_yn(id_in IN NUMBER, objtype_in IN VARCHAR2) IS
   SELECT count(*)
   FROM OZF_ACT_BUDGETS --anchaudh: changed call from ams_act_budgets to ozf_act_budgets : bug#3453430
   WHERE arc_act_budget_used_by = objtype_in
   AND act_budget_used_by_id =id_in;

   CURSOR c_evo IS
   SELECT global_flag,source_code
   FROM ams_event_offers_all_b
   WHERE event_offer_id = p_evo_rec.event_offer_id;

   CURSOR c_resources IS
   SELECT activity_resource_id, object_version_number
   FROM ams_act_resources
   WHERE act_resource_used_by_id = p_evo_rec.event_offer_id;

/*
   CURSOR c_venue_id IS
   SELECT event_venue_id, event_start_date, event_end_date, system_status_code
   FROM ams_event_offers_all_b
   WHERE event_offer_id = p_evo_rec.event_offer_id;
*/

   CURSOR c_old_dates IS
   SELECT event_start_date_time, event_end_date_time
   FROM ams_event_offers_all_b
   WHERE event_offer_id = p_evo_rec.event_offer_id;

   CURSOR C_get_event_resources(id_in IN NUMBER) IS
   SELECT activity_resource_id, object_version_number
   FROM   ams_act_resources
   WHERE  act_resource_used_by_id = id_in;

   CURSOR C_get_session_resources(id_in IN NUMBER) IS
   SELECT activity_resource_id, object_version_number
   FROM ams_act_resources
   WHERE  arc_act_resource_used_by = 'SESSION'
   AND    act_resource_used_by_id IN ( SELECT agenda_id
                                       FROM ams_agendas_b
                                       WHERE agenda_type = 'SESSION'
                                       AND   active_flag = 'Y'
                                       AND   parent_id IN ( SELECT agenda_id
                                                            FROM ams_agendas_b
                                                            WHERE parent_id =  id_in ) );

-- VMODUR Added 4371624
   CURSOR c_get_min_max_session_time(id_in IN NUMBER, type_in in VARCHAR2) IS
   select min(s.start_date_time), max(s.end_date_time)
     from ams_agendas_b s, ams_agendas_b h
    where s.agenda_type = 'SESSION'
     and s.active_flag = 'Y'
     and s.parent_id = h.agenda_id
     and h.parent_id = id_in
     and h.parent_type = type_in;

BEGIN

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': entered update');

   END IF;

  -------------------- initialize -------------------------
   SAVEPOINT update_event_offer;

   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ----------------------- validate ----------------------

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': validate');

   END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message(p_evo_rec.event_offer_id ||': validate1');
     END IF;
  -- replace g_miss_char/num/date with current column values
   complete_evo_rec(p_evo_rec, l_evo_rec);

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': check items');

   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_evo_items(
         p_evo_rec        => l_evo_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': check records');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_evo_record(
         p_evo_rec        => p_evo_rec,
         p_complete_rec   => l_evo_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
     -- inter-entity level
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': check inter-entity');
   END IF;
   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_inter_entity THEN
      check_evo_inter_entity(
         p_evo_rec        => p_evo_rec,
         p_complete_rec    => l_evo_rec,
         p_validation_mode => JTF_PLSQL_API.g_update,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- Check if (budget lines are available added 06/04/2001 murali)

   IF (p_evo_rec.currency_code_tc <> FND_API.g_miss_char) THEN
      IF (p_evo_rec.currency_code_tc <> nvl(l_evo_rec.currency_code_tc, '1') ) THEN
         OPEN c_bdgt_line_yn(l_evo_rec.event_offer_id, l_evo_rec.event_object_type);
         FETCH c_bdgt_line_yn INTO l_dummy;
         IF c_bdgt_line_yn%NOTFOUND THEN
            CLOSE c_bdgt_line_yn;
         ELSE
            CLOSE c_bdgt_line_yn;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVENT_BUD_PRESENT');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END IF;

-- check rules specific to update evo.. eg. status id should trigger approval workflow
-- other checks regarding dates and numbers are included in check_evo_record
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': check update level');
   END IF;

     check_evo_update(
       p_evo_rec       => l_evo_rec,
         x_return_status  => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

   -- handle source code update
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': update source code');
   END IF;
   -- only for main and non active events


   /* Changed the p_evo_rec.source_code to l_evo_rec.source_code in the following line
      p_evo_rec.source_code will be g_miss_char which will give OSO Exception
      Bug # 2233024
    */

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message('The value of p_source_code is ' || l_evo_rec.source_code);

   END IF;

l_traget_list_exists := FND_API.G_TRUE;
   /* Added by GMADANA */
   OPEN c_evo;
     FETCH c_evo INTO l_global_flag, l_source_code;
   CLOSE c_evo;
     IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_Utility_PVT.debug_message('The value of p_source_code is ' || l_evo_rec.event_offer_id ||l_evo_rec.event_object_type );
     END IF;
   l_traget_list_exists := AMS_ScheduleRules_PVT.Target_Group_Exist( p_schedule_id => l_evo_rec.event_offer_id
                             , p_obj_type => l_evo_rec.event_object_type);
   if (l_traget_list_exists = FND_API.G_FALSE) THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('l_traget_list_exists is false' );
      END IF;
   end if;

   IF p_evo_rec.source_code <> FND_API.g_miss_char
   THEN
      IF p_evo_rec.source_code <> l_source_code
      THEN
         IF l_evo_rec.event_level = 'MAIN' AND l_evo_rec.system_status_code = 'NEW' AND l_traget_list_exists = FND_API.G_FALSE
         THEN
            IF l_evo_rec.event_object_type = 'EVEO' THEN
               -- extracting out source code modified by soagrawa
               -- 21-jan-2003 bug# 2761612
               AMS_EvhRules_PVT.update_evo_source_code(
               l_evo_rec.event_offer_id,
               l_evo_rec.source_code,
               l_evo_rec.global_flag,
               l_dummy_source_code,
               l_return_status
            );
            l_evo_rec.source_code := l_dummy_source_code;
            ELSE
               /* this new procedure needed  for one of event take this comment once the code is ready*/
               -- extracting out source code modified by soagrawa
               -- 21-jan-2003 bug# 2761612
               AMS_EvhRules_PVT.update_eone_source_code(
               l_evo_rec.event_offer_id,
               l_evo_rec.source_code,
               l_evo_rec.global_flag,
               l_dummy_source_code,
               l_return_status
            );
            l_evo_rec.source_code := l_dummy_source_code;
            END IF;
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            if l_traget_list_exists = FND_API.G_TRUE
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVEO_SRCCD_NO_CHNG');
               FND_MSG_PUB.add;
               RAISE FND_API.g_exc_error;
            else
               FND_MESSAGE.set_name('AMS', 'AMS_CAMP_UPDATE_SRC_STAT');
               FND_MSG_PUB.add;
               RAISE FND_API.g_exc_error;
            END IF;
         END IF;
      END IF;
   ELSIF  p_evo_rec.source_code IS NULL  /* added by musman for bug 2618242 fix*/
   THEN
      l_evo_rec.source_code := l_source_code;
   END IF;

   IF  p_evo_rec.global_flag <> FND_API.g_miss_char
    OR p_evo_rec.global_flag is NULL
   THEN
     IF p_evo_rec.global_flag <> l_global_flag
     THEN
         IF l_evo_rec.event_level = 'MAIN' AND l_evo_rec.system_status_code = 'NEW' AND l_traget_list_exists = FND_API.G_FALSE
         THEN
            IF l_evo_rec.event_object_type = 'EVEO' THEN
               IF (AMS_DEBUG_HIGH_ON) THEN

                   AMS_Utility_PVT.debug_message('Entered AMS_EvhRules_PVT.update_evo_source_code');
               END IF;
               -- extracting out source code modified by soagrawa
               -- 21-jan-2003 bug# 2761612
               AMS_EvhRules_PVT.update_evo_source_code(
               l_evo_rec.event_offer_id,
               l_evo_rec.source_code,
               l_evo_rec.global_flag,
               l_dummy_source_code,
               l_return_status
            );
            l_evo_rec.source_code := l_dummy_source_code;
            ELSE
               /* this new procedure needed  for one of event take this comment once the code is ready*/
               -- extracting out source code modified by soagrawa
               -- 21-jan-2003 bug# 2761612
               AMS_EvhRules_PVT.update_eone_source_code(
               l_evo_rec.event_offer_id,
               l_evo_rec.source_code,
               l_evo_rec.global_flag,
               l_dummy_source_code,
               l_return_status
            );
            l_evo_rec.source_code := l_dummy_source_code;
            END IF;
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            if l_traget_list_exists = FND_API.G_TRUE
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVEO_GLFLAG_NO_CHANG');
               FND_MSG_PUB.add;
               RAISE FND_API.g_exc_error;
            else
               FND_MESSAGE.set_name('AMS', 'AMS_EVNT_UPDATE_GFLG_STAT');
               FND_MSG_PUB.add;
               RAISE FND_API.g_exc_error;
            END IF;
         END IF;
      END IF;
   END IF;

   --------------- CHECK ACCESS FOR THE USER-------------------
   ----------added sugupta 07/25/2000
   l_user_id := FND_GLOBAL.User_Id;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(' CHECK ACCESS l_user_id is ' ||l_user_id );
   END IF;
   if l_user_id IS NOT NULL then
      open get_res_id(l_user_id);
      fetch get_res_id into l_res_id;
      close get_res_id;
   end if;
   IF l_evo_rec.event_level = 'SUB' THEN
      l_evo_id := l_evo_rec.parent_event_offer_id;
   ELSE
      l_evo_id := l_evo_rec.event_offer_id;
   END IF;
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message(l_evo_id || l_evo_rec.event_object_type || l_user_id ||': CHECK ACCESS');
      END IF;


   -- soagrawa added if clause on 11-feb-2003 for INTERNAL bug# 2795823
   IF(l_evo_rec.event_object_type = 'EONE' AND l_evo_rec.parent_type = 'CAMP')
   THEN
      -- dont check for access
      NULL;
   ELSE
      -- check for access
      if AMS_ACCESS_PVT.check_update_access(l_evo_id, l_evo_rec.event_object_type, l_res_id, 'USER') = 'N' then
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_UPDATE_ACCESS');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      end if;
   END IF;


-----------------------update---------------------------------------
   IF l_evo_rec.user_status_id <> FND_API.g_miss_num
   THEN

      -- pick up the correct system_status_code first.
      IF l_evo_rec.event_level = 'MAIN'
      THEN
         OPEN c_evo_status_evo;
         FETCH c_evo_status_evo INTO l_evo_rec.system_status_code;
         CLOSE c_evo_status_evo;
      ELSIF l_evo_rec.event_level = 'SUB'
      THEN
         OPEN c_evo_status_evagd;
         FETCH c_evo_status_evagd INTO l_evo_rec.system_status_code;
         CLOSE c_evo_status_evagd;
      END IF;
   END IF;

-- Have to confirm that delivery_method code has not changed for this offer.
-- If it has, call the Update_Act_DelvMethod api to change the delv_method
-- corresponding to the delv_method_id stored in the offers table.
-- open the cursor and retrive values for l_dlv_id.. if l_dlv_id exists before
-- that l_dlv_id is always inserted back
-- Please NOTE THAT EVENT_DELIVERY_METHOD_CODE is not updated
-- in complete_evo_rec procedure.. so iis either NULL or it has a new value
-- No code has been added for the case if l_dlv_id does not exist -- added craete_dlv then
-- update_event_offer proceddure is called.. in that case, have to add a
-- proceudre call to Create_Act_DelvMethod if l_dlv_id is null after cursor call
-- sugupta 3/27/00 change of plans.. delivery method code will alwyas be passed to update_event_offer
-- call and not create procedure.. hence adding the code to call Create_Act_DelvMethod
-- dlv method code will neevr be passed for event agenda... so no need to put an if loop for event level

   OPEN c_evo_dlv_mthd;
    FETCH c_evo_dlv_mthd INTO l_dlv_code, l_dlv_id, l_dlv_ver;
    CLOSE c_evo_dlv_mthd;


    IF (AMS_DEBUG_HIGH_ON) THEN





        AMS_Utility_PVT.debug_message( 'delv meth code from cursor ' || l_dlv_code);


    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_Utility_PVT.debug_message( 'delv meth Code in the Rec ' || l_evo_rec.event_delivery_method_code);
    END IF;

    IF (AMS_DEBUG_HIGH_ON) THEN



        AMS_Utility_PVT.debug_message( 'delv meth id from cursor ' || l_dlv_id);

    END IF;

   IF l_evo_rec.event_delivery_method_code <> FND_API.g_miss_char
      AND l_evo_rec.event_delivery_method_code IS NOT NULL THEN

      IF l_dlv_id is NOT NULL then
         IF l_evo_rec.EVENT_DELIVERY_METHOD_CODE <> l_dlv_code THEN
            AMS_ActDelvMethod_PVT.init_act_DelvMethod_rec (l_dlv_rec);
            l_dlv_rec.ACTIVITY_DELIVERY_METHOD_ID := l_dlv_id;
            l_dlv_rec.DELIVERY_MEDIA_TYPE_CODE := l_evo_rec.EVENT_DELIVERY_METHOD_CODE;
            l_dlv_rec.object_version_number := l_dlv_ver;

            AMS_ActDelvMethod_PVT.Update_Act_DelvMethod(
                         p_api_version => l_api_version,
                         p_init_msg_list => FND_API.g_false,
                         p_commit => FND_API.g_false,
                         p_validation_level => FND_API.g_valid_level_full,
                         x_return_status => l_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_act_DelvMethod_rec => l_dlv_rec);

            IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
            END IF;
        END IF;
      ELSE
         IF l_evo_rec.EVENT_STANDALONE_FLAG = 'Y' THEN
            l_dlv_rec.ARC_ACT_DELIVERY_USED_BY := 'EONE';
            l_dlv_rec.ACT_DELIVERY_METHOD_USED_BY_ID :=  l_evo_rec.event_offer_id;
            l_dlv_rec.DELIVERY_MEDIA_TYPE_CODE := l_evo_rec.EVENT_DELIVERY_METHOD_CODE;
         ELSE
            l_dlv_rec.ARC_ACT_DELIVERY_USED_BY := 'EVEO';
            l_dlv_rec.ACT_DELIVERY_METHOD_USED_BY_ID :=  l_evo_rec.event_offer_id;
            l_dlv_rec.DELIVERY_MEDIA_TYPE_CODE := l_evo_rec.EVENT_DELIVERY_METHOD_CODE;
         END IF;
         AMS_ActDelvMethod_PVT.Create_Act_DelvMethod(
                         p_api_version => l_api_version,
                         p_init_msg_list => FND_API.g_false,
                         p_commit => FND_API.g_false,
                         p_validation_level => FND_API.g_valid_level_full,
                         x_return_status => l_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_act_DelvMethod_rec => l_dlv_rec,
                         x_act_DelvMethod_id => l_dlv_id);
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
  -- ELSE -- meaning delv method code passed as null
   -- The following if condition is added for bug # 2376741

     ELSIF(l_evo_rec.event_delivery_method_code IS NULL)
     THEN
   -- added sugupta 07/26/2000 if delv code passed as null and delv id exists, then we delete act_del_id
   -- from both act_delv table as well as eveo table

      IF l_dlv_id is NOT NULL then
         AMS_ActDelvMethod_PVT.Delete_Act_DelvMethod(
                 p_api_version => l_api_version,
                         p_init_msg_list => FND_API.g_false,
                         p_commit => FND_API.g_false,
                         p_validation_level => FND_API.g_valid_level_full,
                         x_return_status => l_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                   p_act_DelvMethod_id => l_dlv_id,
                   p_object_version => l_dlv_ver);
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         -- now that dlv_id has been deleted from act_delv table, null it from evo table as well
         l_dlv_id := null;
      END IF;
   END IF;


----------INV AND PRICING INTEGRATION /* Added by GMADANA */--------------------

    IF l_evo_rec.INVENTORY_ITEM_ID IS NULL THEN
       IF l_evo_rec.INVENTORY_ITEM <> FND_API.g_miss_char
          AND l_evo_rec.INVENTORY_ITEM IS NOT NULL THEN
          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.debug_message(l_full_name ||':  calling create inv item');
          END IF;
          l_inv_item_number :=  l_evo_rec.INVENTORY_ITEM;
          l_inv_item_desc   :=  l_evo_rec.EVENT_OFFER_NAME;
          l_inv_long_desc   :=  l_evo_rec.DESCRIPTION;


          AMS_EvhRules_PVT.create_inventory_item(
                  p_item_number => l_inv_item_number,
                  p_item_desc  => l_inv_item_desc,
                  p_item_long_desc => l_inv_long_desc,
                  p_user_id => l_evo_rec.owner_user_id,
                  x_org_id => l_org_id,
                  x_inv_item_id => l_inventory_item_id,
                  x_return_status  => l_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data);

         l_evo_rec.INVENTORY_ITEM_ID := l_inventory_item_id;
         l_evo_rec.ORGANIZATION_ID := l_org_id;

          IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          ELSIF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          END IF;


          create_global_pricing(
                     p_evo_rec   => l_evo_rec,
                     x_return_status => l_return_status
                     );

          IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          ELSIF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          END IF;

       END IF; -- end if for l_evo_rec.INVENTORY_ITEM <> FND_API.g_miss_char
  ELSE
      create_global_pricing(
              p_evo_rec   => l_evo_rec,
              x_return_status => l_return_status
              );

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;

  END IF; -- end if for IF l_evo_rec.INVENTORY_ITEM_ID IS NULL

----------------END OF INV/PRICING INTEGRATION-----------------------
  -- calculate reg_effective_capacity if maximum capacity is not null

   IF l_evo_rec.reg_maximum_capacity IS NOT NULL then
      IF l_evo_rec.reg_overbook_pct IS NOT NULL then
         l_evo_rec.reg_effective_capacity := round((1 + (l_evo_rec.reg_overbook_pct/100)) * l_evo_rec.reg_maximum_capacity);
      ELSE
         l_evo_rec.reg_effective_capacity := l_evo_rec.reg_maximum_capacity;
      END IF;
   ELSE
      l_evo_rec.reg_effective_capacity := 0;
   END IF;

--  check if city, state,country has been passed. If they are passed, create a new loc_id
-- THESE will never be passed for event agenda... so no need to put an if loop for event level
     -- ==========================================================
     -- Following code is added by mukumar on 10/30/2000
     -- the code will convert the transaction currency in to
     -- functional currency.
     -- ==========================================================
     IF p_evo_rec.fund_amount_tc IS NOT NULL THEN
        IF p_evo_rec.fund_amount_tc <> FND_API.g_miss_num THEN
           AMS_EvhRules_PVT.Convert_Evnt_Currency(
              p_tc_curr     => l_evo_rec.currency_code_tc,
              p_tc_amt      => l_evo_rec.fund_amount_tc,
              x_fc_curr     => l_evo_rec.currency_code_fc,
              x_fc_amt      => l_evo_rec.fund_amount_fc
           ) ;
        END IF ;
     ELSE
        l_evo_rec.fund_amount_fc := null ;
     END IF;
   -------------------------- check locations --------------------
-- CHECK FOR WHETHER NEW LOCATION NEEDS TO BE CREATED
   IF (l_evo_rec.event_location_id IS NOT NULL
     AND (nvl(l_evo_rec.CITY, ' ') = ' ' OR l_evo_rec.CITY = FND_API.g_miss_char)
      AND (nvl(l_evo_rec.STATE, ' ') = ' ' OR l_evo_rec.STATE = FND_API.g_miss_char)
     AND (nvl(l_evo_rec.COUNTRY, ' ') = ' ' OR l_evo_rec.COUNTRY = FND_API.g_miss_char ))
   THEN
      l_evo_rec.event_location_id := NULL;
   ELSE
      IF l_evo_rec.event_location_id IS NOT NULL THEN
         OPEN c_location(l_evo_rec.event_offer_id);
         FETCH c_location INTO l_address1, l_address2, l_city, l_state, l_country;
         IF c_location%NOTFOUND THEN
            CLOSE c_location;
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
         CLOSE c_location;
      END IF;
      IF (nvl(l_evo_rec.city, ' ') <> nvl(l_city, ' ') OR
         nvl(l_evo_rec.state, ' ') <> nvl(l_state, ' ') OR
         nvl(l_evo_rec.country, ' ') <> nvl(l_country, ' ')) THEN
            l_location_rec.address1 := ' ';
            l_location_rec.city := l_evo_rec.city;
            l_location_rec.state := l_evo_rec.state;
            l_location_rec.country := l_evo_rec.country;
            l_location_rec.ORIG_SYSTEM_REFERENCE := -1;
            l_location_rec.CONTENT_SOURCE_TYPE := 'USER_ENTERED';
	    l_location_rec.created_by_module := 'AMS_EVENT';
            HZ_LOCATION_V2PUB.Create_Location(
               p_init_msg_list     => FND_API.g_false,
               p_location_rec      => l_location_rec,
               x_return_status     => l_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               x_location_id       => l_evo_rec.event_location_id
               );
            --IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
            --  l_venue_rec.location_id := l_location_id;
            --END IF;
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
      END IF; --check for addr1, city, state, country
    END IF; -- check for NULL


    /* Code Added by GMADANA for checking whether parent is active or not */

   -- soagrawa added if clause on 24-feb-2003 for INTERNAL bug# 2816673
   IF(l_evo_rec.event_object_type = 'EONE' AND l_evo_rec.parent_type = 'CAMP')
   THEN
      -- dont check for parent being active
      NULL;
   ELSE

     Check_Parent_Active(
         p_evo_rec    => l_evo_rec,
         x_return_status      => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;
   END IF;

     /* Code Added by GMADANA for Date validation for attaching Program as Parent */
     /* Check_Dates_Range has date validation for MAIN level and SUB level events
        as agenda for Event Schedule has Start date on the GUI.
     */

   -- soagrawa added if clause on 24-feb-2003 for INTERNAL bug# 2816673
   IF(l_evo_rec.event_object_type = 'EONE' AND l_evo_rec.parent_type = 'CAMP')
   THEN
      -- dont check for date range
      NULL;
   ELSE
     Check_Dates_Range(
         p_evo_rec    => l_evo_rec,
         x_return_status      => x_return_status
      );

      IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
      ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
      END IF;

   END IF;

-- VMODUR Added for Bug 4371624
   IF l_evo_rec.event_level = 'MAIN' THEN
     OPEN c_get_min_max_session_time(l_evo_rec.event_offer_id, l_evo_rec.event_object_type);
     FETCH c_get_min_max_session_time INTO l_min_session_time, l_max_session_time;
     CLOSE c_get_min_max_session_time;

    IF l_min_session_time IS NOT NULL AND l_max_session_time IS NOT NULL THEN
     IF (AMS_DEBUG_HIGH_ON) THEN
       AMS_Utility_PVT.debug_message('l_min_session_time: '||to_char(l_min_session_time,'DD-MON-YYYY HH24:MI:SS'));
       AMS_Utility_PVT.debug_message('l_max_session_time: '||to_char(l_max_session_time,'DD-MON-YYYY HH24:MI:SS'));
     END IF;
    END IF;

     IF l_min_session_time IS NOT NULL AND l_min_session_time < l_evo_rec.event_start_date_time THEN
        IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message('Event Start is after Min Session Start');
        END IF;
         Fnd_Message.set_name('AMS', 'AMS_EVT_SESS_STDT_CONFLICT');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
     END IF;

     IF l_max_session_time IS NOT NULL AND l_max_session_time > l_evo_rec.event_end_date_time THEN
        IF (AMS_DEBUG_HIGH_ON) THEN
          AMS_Utility_PVT.debug_message('Event End is before Max Session End');
        END IF;
         Fnd_Message.set_name('AMS', 'AMS_EVT_SESS_EDDT_CONFLICT');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
     END IF;

   END IF;
-- VMODUR End of Addition

    /* Call to Metrics If Progam name has chnaged. Only EONEs have program as parent, not EVEO */
    IF( l_evo_rec.event_object_type = 'EONE') THEN
       Update_Metrics (
          p_evo_rec => l_evo_rec,
          x_return_status  => x_return_status,
          x_msg_count  => x_msg_count,
          x_msg_data  =>x_msg_data
        );
    END IF;

    IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
         RAISE Fnd_Api.g_exc_unexpected_error;
    ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
         RAISE Fnd_Api.g_exc_error;
    END IF;

   /* If the owner user id cahnges call AMS_EvhRules_PVT.Update_Owner */
     -- Change the owner in Access table if the owner is changed.

   IF  p_evo_rec.owner_user_id <> FND_API.g_miss_num
   THEN
      AMS_EvhRules_PVT.Update_Owner(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           p_commit            => p_commit,
           p_validation_level  => p_validation_level,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_object_type       => l_evo_rec.event_object_type,
           p_event_id          => l_evo_rec.event_offer_id,
           p_owner_id          => p_evo_rec.owner_user_id
           );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF ;

   OPEN  c_old_dates;
   FETCH c_old_dates INTO l_oldStDate, l_oldEdDate;
   CLOSE c_old_dates;

   IF( l_oldStDate <> l_evo_rec.event_start_date_time
       OR l_oldEdDate <> l_evo_rec.event_end_date_time)
   THEN

       -- Get all the resources attached to the event (event level)
       -- and make them unconfirmed.

       OPEN  C_get_event_resources(l_evo_rec.event_offer_id);
       FETCH C_get_event_resources INTO l_actres_id, l_obj_ver;

       WHILE C_get_event_resources%FOUND LOOP

            UPDATE ams_act_resources
            SET  object_version_number = l_obj_ver + 1,
                 system_status_code = 'UNCONFIRMED',
                 user_status_id = ( SELECT user_status_id
                                    FROM AMS_USER_STATUSES_B
                                    WHERE SYSTEM_STATUS_CODE = 'UNCONFIRMED'
                                    AND  SYSTEM_STATUS_TYPE = 'AMS_EVENT_AGENDA_STATUS'
                                    -- added by soagrawa on 25-feb-2003 for bug# 2820297
                                    AND  DEFAULT_FLAG = 'Y')
            WHERE activity_resource_id = l_actres_id;

            FETCH C_get_event_resources INTO l_actres_id, l_obj_ver;

       END LOOP;


       -- Get all the resources attached to the event (Session level)
       -- and make them unconfirmed.
       OPEN  C_get_session_resources(l_evo_rec.event_offer_id);
       FETCH C_get_session_resources INTO l_actres_id, l_obj_ver;

       WHILE C_get_session_resources%FOUND LOOP

            UPDATE ams_act_resources
            SET  object_version_number = l_obj_ver + 1,
                 system_status_code = 'UNCONFIRMED',
                 user_status_id = ( SELECT user_status_id
                                       FROM AMS_USER_STATUSES_B
                                       WHERE SYSTEM_STATUS_CODE = 'UNCONFIRMED'
                                       AND  SYSTEM_STATUS_TYPE = 'AMS_EVENT_AGENDA_STATUS'
                                       -- added by soagrawa on 25-feb-2003 for bug# 2820297
                                       AND  DEFAULT_FLAG = 'Y')
            WHERE activity_resource_id = l_actres_id;

            FETCH C_get_session_resources INTO l_actres_id, l_obj_ver;

       END LOOP;

   END IF;




  /* Get the Old venue id, old start date and old end date
     for event fulfilment which will be called at the end of
     update
  */
  /*
   OPEN  c_venue_id;
   FETCH c_venue_id INTO l_venue_id, l_start_date, l_end_date, l_system_status_code;
   CLOSE c_venue_id;
  */

-------------------------- update --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name ||': update');
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('obj-ver number'||l_evo_rec.object_version_number);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('obj-id'||l_evo_rec.event_offer_id);
   END IF;
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message('obj-flag'||l_evo_rec.overflow_flag);
   END IF;

-- GDEODHAR : Sept. 26, 2000 added two separate update statements.
-- One for the main events where the workflow has to be kicked off for status change
-- and hence the update of the base table should not update the status related fields.
-- The other update statement is needed for the Agenda items for which the status change
-- is straight-forward.

   IF  l_evo_rec.event_level = 'MAIN' THEN
      UPDATE ams_event_offers_all_b SET
         last_update_date = SYSDATE,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.conc_login_id,
         object_version_number = l_evo_rec.object_version_number + 1,
         private_flag = l_evo_rec.private_flag,
         active_flag = l_evo_rec.active_flag,
         source_code = l_evo_rec.source_code,
         event_level = l_evo_rec.event_level,
         event_type_code = l_evo_rec.event_type_code,
         event_delivery_method_id = l_dlv_id,
         event_language_code = l_evo_rec.event_language_code,
         event_location_id = l_evo_rec.event_location_id,
         overflow_flag = l_evo_rec.overflow_flag,
         partner_flag = l_evo_rec.partner_flag,
         event_standalone_flag = l_evo_rec.event_standalone_flag,
         reg_frozen_flag = l_evo_rec.reg_frozen_flag,
         reg_required_flag = l_evo_rec.reg_required_flag,
         reg_charge_flag = l_evo_rec.reg_charge_flag,
         reg_invited_only_flag = l_evo_rec.reg_invited_only_flag,
         reg_waitlist_allowed_flag = l_evo_rec.reg_waitlist_allowed_flag,
         reg_overbook_allowed_flag = l_evo_rec.reg_overbook_allowed_flag,
         parent_event_offer_id = l_evo_rec.parent_event_offer_id,
         event_duration = l_evo_rec.event_duration,
         event_duration_uom_code = l_evo_rec.event_duration_uom_code,
        -- event_start_date = l_evo_rec.event_start_date,
         event_start_date_time = l_evo_rec.event_start_date_time,
        -- event_end_date = l_evo_rec.event_end_date,
         event_end_date_time = l_evo_rec.event_end_date_time,
         reg_start_date = l_evo_rec.reg_start_date,
         reg_start_time = to_date(to_char(l_evo_rec.reg_start_time,'HH24:MI'),'HH24:MI'),
         reg_end_date = l_evo_rec.reg_end_date,
         reg_end_time = to_date(to_char(l_evo_rec.reg_end_time,'HH24:MI'),'HH24:MI'),
         reg_maximum_capacity = l_evo_rec.reg_maximum_capacity,
         reg_overbook_pct = l_evo_rec.reg_overbook_pct,
         reg_effective_capacity = l_evo_rec.reg_effective_capacity,
         reg_waitlist_pct = l_evo_rec.reg_waitlist_pct,
         reg_minimum_capacity = l_evo_rec.reg_minimum_capacity,
         reg_minimum_req_by_date = l_evo_rec.reg_minimum_req_by_date,
         inventory_item_id = l_evo_rec.INVENTORY_ITEM_ID,
         organization_id = l_evo_rec.ORGANIZATION_ID,
         pricelist_header_id = l_evo_rec.pricelist_header_id,
         pricelist_line_id = l_evo_rec.pricelist_line_id,
         waitlist_action_type_code = l_evo_rec.waitlist_action_type_code,
         stream_type_code = l_evo_rec.stream_type_code,
         owner_user_id = l_evo_rec.owner_user_id,
         event_full_flag = l_evo_rec.event_full_flag,
         forecasted_revenue = l_evo_rec.forecasted_revenue,
         actual_revenue = l_evo_rec.actual_revenue,
         forecasted_cost = l_evo_rec.forecasted_cost,
         actual_cost = l_evo_rec.actual_cost,
         fund_source_type_code = l_evo_rec.fund_source_type_code,
         fund_source_id = l_evo_rec.fund_source_id,
         cert_credit_type_code = l_evo_rec.cert_credit_type_code,
         certification_credits = l_evo_rec.certification_credits,
         coordinator_id = l_evo_rec.coordinator_id,
         priority_type_code = l_evo_rec.priority_type_code,
         cancellation_reason_code = l_evo_rec.cancellation_reason_code,
         email = l_evo_rec.email,
         phone = l_evo_rec.phone,
         fund_amount_tc = l_evo_rec.fund_amount_tc,
         fund_amount_fc = l_evo_rec.fund_amount_fc,
         currency_code_tc = l_evo_rec.currency_code_tc,
         currency_code_fc = l_evo_rec.currency_code_fc,
         url = l_evo_rec.url,
         timezone_id = l_evo_rec.timezone_id,
         --event_venue_id = l_evo_rec.event_venue_id,
         inbound_script_name = l_evo_rec.inbound_script_name,
         auto_register_flag = NVL(l_evo_rec.auto_register_flag, nvl(FND_PROFILE.value('AMS_AUTO_REGISTER_FLAG'), 'Y')),
         attribute_category = l_evo_rec.attribute_category,
         attribute1 = l_evo_rec.attribute1,
         attribute2 = l_evo_rec.attribute2,
         attribute3 = l_evo_rec.attribute3,
         attribute4 = l_evo_rec.attribute4,
         attribute5 = l_evo_rec.attribute5,
         attribute6 = l_evo_rec.attribute6,
         attribute7 = l_evo_rec.attribute7,
         attribute8 = l_evo_rec.attribute8,
         attribute9 = l_evo_rec.attribute9,
         attribute10 = l_evo_rec.attribute10,
         attribute11 = l_evo_rec.attribute11,
         attribute12 = l_evo_rec.attribute12,
         attribute13 = l_evo_rec.attribute13,
         attribute14 = l_evo_rec.attribute14,
         attribute15 = l_evo_rec.attribute15,
         country_code = l_evo_rec.country_code,
         business_unit_id = l_evo_rec.business_unit_id,
         event_calendar  = l_evo_rec.event_calendar,
         start_period_name = l_evo_rec.start_period_name,
         end_period_name = l_evo_rec.end_period_name,
         global_flag = nvl(l_evo_rec.global_flag, 'N'),
         task_id = l_evo_rec.task_id,  --Hornet
         --program_id = l_evo_rec.program_id, --Hornet
         parent_type = l_evo_rec.parent_type,  --Hornet
         parent_id = l_evo_rec.parent_id  --Hornet
         ,CREATE_ATTENDANT_LEAD_FLAG = l_evo_rec.CREATE_ATTENDANT_LEAD_FLAG /*hornet*/
         ,CREATE_REGISTRANT_LEAD_FLAG = l_evo_rec.CREATE_REGISTRANT_LEAD_FLAG /*hornet*/
         --,EVENT_OBJECT_TYPE = l_evo_rec.event_object_type /* hornet*/
         ,reg_timezone_id = l_evo_rec.reg_timezone_id
         ,event_password = l_evo_rec.event_password /* Hornet : added for imeeting integration*/
         ,record_event_flag = l_evo_rec.record_event_flag   /* Hornet : added for imeeting integration*/
         ,allow_register_in_middle_flag = l_evo_rec.allow_register_in_middle_flag  /* Hornet : added for imeeting integration*/
         ,publish_attendees_flag = l_evo_rec.publish_attendees_flag  /* Hornet : added for imeeting integration*/
         ,direct_join_flag = l_evo_rec.direct_join_flag   /* Hornet : added for imeeting integration*/
         ,event_notification_method = l_evo_rec.event_notification_method  /* Hornet : added for imeeting integration*/
         ,actual_start_time = l_evo_rec.actual_start_time  /* Hornet : added for imeeting integration*/
         ,actual_end_time = l_evo_rec.actual_end_time  /* Hornet : added for imeeting integration*/
         ,server_id = l_evo_rec.server_id  /* Hornet : added for imeeting integration*/
         ,OWNER_FND_USER_ID = l_evo_rec.OWNER_FND_USER_ID /* Hornet : added for imeeting integration*/
         ,MEETING_DIAL_IN_INFO = l_evo_rec.MEETING_DIAL_IN_INFO /* Hornet : added for imeeting integration*/
         ,MEETING_EMAIL_SUBJECT = l_evo_rec.MEETING_EMAIL_SUBJECT /* Hornet : added for imeeting integration*/
         ,MEETING_SCHEDULE_TYPE = l_evo_rec.MEETING_SCHEDULE_TYPE /* Hornet : added for imeeting integration*/
         ,MEETING_STATUS = l_evo_rec.MEETING_STATUS /* Hornet : added for imeeting integration*/
         ,PUBLISH_FLAG = l_evo_rec.PUBLISH_FLAG /* Hornet : added for imeeting integration*/
         ,MEETING_ENCRYPTION_KEY_CODE = l_evo_rec.MEETING_ENCRYPTION_KEY_CODE /* Hornet : added for imeeting integration*/
         ,MEETING_MISC_INFO = l_evo_rec.MEETING_MISC_INFO /* Hornet : added for imeeting integration*/
         ,NUMBER_OF_ATTENDEES = l_evo_rec.NUMBER_OF_ATTENDEES /* Hornet : added for imeeting integration*/
         ,EVENT_PURPOSE_CODE = l_evo_rec.EVENT_PURPOSE_CODE /* Hornet */
      WHERE event_offer_id = l_evo_rec.event_offer_id
      AND object_version_number = l_evo_rec.object_version_number;
   ELSIF l_evo_rec.event_level = 'SUB' THEN
      UPDATE ams_event_offers_all_b SET
         last_update_date = SYSDATE,
         last_updated_by = FND_GLOBAL.user_id,
         last_update_login = FND_GLOBAL.conc_login_id,
         object_version_number = l_evo_rec.object_version_number + 1,
         private_flag = l_evo_rec.private_flag,
         active_flag = l_evo_rec.active_flag,
         source_code = l_evo_rec.source_code,
         event_level = l_evo_rec.event_level,
         user_status_id = l_evo_rec.user_status_id,
         system_status_code = l_evo_rec.system_status_code,
         last_status_date = l_evo_rec.last_status_date,
         event_type_code = l_evo_rec.event_type_code,
         event_delivery_method_id = l_dlv_id,
         event_language_code = l_evo_rec.event_language_code,
         event_location_id = l_evo_rec.event_location_id,
         overflow_flag = l_evo_rec.overflow_flag,
         partner_flag = l_evo_rec.partner_flag,
         event_standalone_flag = l_evo_rec.event_standalone_flag,
         reg_frozen_flag = l_evo_rec.reg_frozen_flag,
         reg_required_flag = l_evo_rec.reg_required_flag,
         reg_charge_flag = l_evo_rec.reg_charge_flag,
         reg_invited_only_flag = l_evo_rec.reg_invited_only_flag,
         reg_waitlist_allowed_flag = l_evo_rec.reg_waitlist_allowed_flag,
         reg_overbook_allowed_flag = l_evo_rec.reg_overbook_allowed_flag,
         parent_event_offer_id = l_evo_rec.parent_event_offer_id,
         event_duration = l_evo_rec.event_duration,
         event_duration_uom_code = l_evo_rec.event_duration_uom_code,
         --event_start_date = l_evo_rec.event_start_date,
         event_start_date_time = l_evo_rec.event_start_date_time,
         --event_end_date = l_evo_rec.event_end_date,
         event_end_date_time = l_evo_rec.event_end_date_time,
         reg_start_date = l_evo_rec.reg_start_date,
         reg_start_time = to_date(to_char(l_evo_rec.reg_start_time,'HH24:MI'),'HH24:MI'),
         reg_end_date = l_evo_rec.reg_end_date,
         reg_end_time = to_date(to_char(l_evo_rec.reg_end_time,'HH24:MI'),'HH24:MI'),
         reg_maximum_capacity = l_evo_rec.reg_maximum_capacity,
         reg_overbook_pct = l_evo_rec.reg_overbook_pct,
         reg_effective_capacity = l_evo_rec.reg_effective_capacity,
         reg_waitlist_pct = l_evo_rec.reg_waitlist_pct,
         reg_minimum_capacity = l_evo_rec.reg_minimum_capacity,
         reg_minimum_req_by_date = l_evo_rec.reg_minimum_req_by_date,
         inventory_item_id = l_evo_rec.INVENTORY_ITEM_ID,
         organization_id = l_evo_rec.ORGANIZATION_ID,
         pricelist_header_id = l_evo_rec.pricelist_header_id,
         pricelist_line_id = l_evo_rec.pricelist_line_id,
         waitlist_action_type_code = l_evo_rec.waitlist_action_type_code,
         stream_type_code = l_evo_rec.stream_type_code,
         owner_user_id = l_evo_rec.owner_user_id,
         event_full_flag = l_evo_rec.event_full_flag,
         forecasted_revenue = l_evo_rec.forecasted_revenue,
         actual_revenue = l_evo_rec.actual_revenue,
         forecasted_cost = l_evo_rec.forecasted_cost,
         actual_cost = l_evo_rec.actual_cost,
         fund_source_type_code = l_evo_rec.fund_source_type_code,
         fund_source_id = l_evo_rec.fund_source_id,
         cert_credit_type_code = l_evo_rec.cert_credit_type_code,
         certification_credits = l_evo_rec.certification_credits,
         coordinator_id = l_evo_rec.coordinator_id,
         priority_type_code = l_evo_rec.priority_type_code,
         cancellation_reason_code = l_evo_rec.cancellation_reason_code,
         email = l_evo_rec.email,
         phone = l_evo_rec.phone,
         fund_amount_tc = l_evo_rec.fund_amount_tc,
         fund_amount_fc = l_evo_rec.fund_amount_fc,
         currency_code_tc = l_evo_rec.currency_code_tc,
         currency_code_fc = l_evo_rec.currency_code_fc,
         url = l_evo_rec.url,
         timezone_id = l_evo_rec.timezone_id,
        -- event_venue_id = l_evo_rec.event_venue_id,
         inbound_script_name = l_evo_rec.inbound_script_name,
         auto_register_flag = NVL(l_evo_rec.auto_register_flag, nvl(FND_PROFILE.value('AMS_AUTO_REGISTER_FLAG'), 'Y')),
         attribute_category = l_evo_rec.attribute_category,
         attribute1 = l_evo_rec.attribute1,
         attribute2 = l_evo_rec.attribute2,
         attribute3 = l_evo_rec.attribute3,
         attribute4 = l_evo_rec.attribute4,
         attribute5 = l_evo_rec.attribute5,
         attribute6 = l_evo_rec.attribute6,
         attribute7 = l_evo_rec.attribute7,
         attribute8 = l_evo_rec.attribute8,
         attribute9 = l_evo_rec.attribute9,
         attribute10 = l_evo_rec.attribute10,
         attribute11 = l_evo_rec.attribute11,
         attribute12 = l_evo_rec.attribute12,
         attribute13 = l_evo_rec.attribute13,
         attribute14 = l_evo_rec.attribute14,
         attribute15 = l_evo_rec.attribute15,
         country_code = l_evo_rec.country_code,
         business_unit_id = l_evo_rec.business_unit_id,
         event_calendar  = l_evo_rec.event_calendar,
         start_period_name = l_evo_rec.start_period_name,
         end_period_name = l_evo_rec.end_period_name,
         global_flag = nvl(l_evo_rec.global_flag, 'N')
         ,reg_timezone_id = l_evo_rec.reg_timezone_id
         ,event_password = l_evo_rec.event_password /* Hornet : added for imeeting integration*/
         ,record_event_flag = l_evo_rec.record_event_flag   /* Hornet : added for imeeting integration*/
         ,allow_register_in_middle_flag = l_evo_rec.allow_register_in_middle_flag  /* Hornet : added for imeeting integration*/
         ,publish_attendees_flag = l_evo_rec.publish_attendees_flag  /* Hornet : added for imeeting integration*/
         ,direct_join_flag = l_evo_rec.direct_join_flag   /* Hornet : added for imeeting integration*/
         ,event_notification_method = l_evo_rec.event_notification_method  /* Hornet : added for imeeting integration*/
         ,actual_start_time = l_evo_rec.actual_start_time  /* Hornet : added for imeeting integration*/
         ,actual_end_time = l_evo_rec.actual_end_time  /* Hornet : added for imeeting integration*/
         ,server_id = l_evo_rec.server_id  /* Hornet : added for imeeting integration*/
         ,OWNER_FND_USER_ID = l_evo_rec.OWNER_FND_USER_ID /* Hornet : added for imeeting integration*/
         ,MEETING_DIAL_IN_INFO = l_evo_rec.MEETING_DIAL_IN_INFO /* Hornet : added for imeeting integration*/
         ,MEETING_EMAIL_SUBJECT = l_evo_rec.MEETING_EMAIL_SUBJECT /* Hornet : added for imeeting integration*/
         ,MEETING_SCHEDULE_TYPE = l_evo_rec.MEETING_SCHEDULE_TYPE /* Hornet : added for imeeting integration*/
         ,MEETING_STATUS = l_evo_rec.MEETING_STATUS /* Hornet : added for imeeting integration*/
         ,PUBLISH_FLAG = l_evo_rec.PUBLISH_FLAG /* Hornet : added for imeeting integration*/
         ,MEETING_ENCRYPTION_KEY_CODE = l_evo_rec.MEETING_ENCRYPTION_KEY_CODE /* Hornet : added for imeeting integration*/
         ,MEETING_MISC_INFO = l_evo_rec.MEETING_MISC_INFO /* Hornet : added for imeeting integration*/
         ,NUMBER_OF_ATTENDEES = l_evo_rec.NUMBER_OF_ATTENDEES /* Hornet : added for imeeting integration*/
         ,EVENT_PURPOSE_CODE = l_evo_rec.EVENT_PURPOSE_CODE /* Hornet */

      WHERE event_offer_id = l_evo_rec.event_offer_id
      AND object_version_number = l_evo_rec.object_version_number;
   END IF;
-- GDEODHAR : End of changes. Sept. 26th 2000.
   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

-- GDEODHAR : Sept. 26th, 2000 : Note that for MAIN Events and Agenda (SUB) items, the
-- update of the TL table is the same.

   update ams_event_offers_all_tl set
      event_offer_name = l_evo_rec.event_offer_name,
      event_mktg_message = l_evo_rec.event_mktg_message,
      description = l_evo_rec.description,
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.user_id,
      last_update_login = FND_GLOBAL.conc_login_id,
      source_lang = USERENV('LANG')
   WHERE event_offer_id = l_evo_rec.event_offer_id
   AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

---murali call "update_event_status 09/26/00 S
-- GDEODHAR : Added a condition. (Sept. 26th 2000)

--Added by ANSKUMAR FOR FULFILMENT FIX : 4676049
 fulfill_event_offer(l_evo_rec, l_return_status);

      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
      END IF;

   UPDATE ams_event_offers_all_b SET
         event_start_date = l_evo_rec.event_start_date,
         event_end_date = l_evo_rec.event_end_date,
         event_venue_id = l_evo_rec.event_venue_id
   WHERE event_offer_id = l_evo_rec.event_offer_id;

   IF (SQL%NOTFOUND) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

--End Adding

   IF l_evo_rec.event_level = 'MAIN' THEN
      AMS_EvhRules_PVT.update_event_status(
            p_event_id            => l_evo_rec.event_offer_id,
            p_event_activity_type => l_evo_rec.event_object_type, --'EVEO',
            p_user_status_id      => l_evo_rec.user_status_id,
            p_fund_amount_tc      => l_evo_rec.fund_amount_tc,
            p_currency_code_tc    => l_evo_rec.currency_code_tc
           );

      AMS_EvhRules_PVT.Add_Update_Access_record(p_object_type => l_evo_rec.event_object_type, --'EVEO',
         p_object_id          => l_evo_rec.event_offer_id,
         p_Owner_user_id      => l_evo_rec.owner_user_id,
         x_return_status      => l_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data);

         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

 END IF;



/* If the Event Schedule is canclled, make all the resources attached to it
   and aswell to its sessions  cancelled.
*/

OPEN c_evo_status_evo;
FETCH c_evo_status_evo INTO l_sys_st_code;
CLOSE c_evo_status_evo;

IF(l_sys_st_code = 'CANCELLED'
   OR
   l_sys_st_code = 'COMPLETED'
   OR
   l_sys_st_code = 'ARCHIVED')
THEN
     OPEN c_resources;
     FETCH c_resources INTO l_resource_id, l_obj_num;

     WHILE c_resources%FOUND LOOP

        UPDATE ams_act_resources
        SET system_status_code = 'CANCELLED',
        object_version_number = l_obj_num+1,
        user_status_id = (SELECT user_status_id
                          FROM ams_user_statuses_b
                          WHERE system_status_type = 'AMS_EVENT_AGENDA_STATUS'
                          AND system_status_code = 'CANCELLED'
                          -- added by soagrawa on 25-feb-2003 for bug# 2820297
                          AND  DEFAULT_FLAG = 'Y')
        WHERE activity_resource_id = l_resource_id;

     FETCH c_resources INTO l_resource_id, l_obj_num;

     END LOOP; -- WHILE(c_resources%FOUND)
     CLOSE c_resources;

     UPDATE ams_act_resources
     SET system_status_code = 'CANCELLED',
     object_version_number = l_obj_num+1,
     user_status_id = (SELECT user_status_id
                       FROM ams_user_statuses_b
                       WHERE system_status_type = 'AMS_EVENT_AGENDA_STATUS'
                       AND system_status_code = 'CANCELLED'
                       -- added by soagrawa on 25-feb-2003 for bug# 2820297
                       AND  DEFAULT_FLAG = 'Y')
     WHERE activity_resource_id IN (SELECT activity_resource_id
                                    FROM ams_act_resources
                                    WHERE act_resource_used_by_id IN ( SELECT agenda_id
                                                                       FROM ams_agendas_b
                                                                       WHERE parent_id IN (SELECT agenda_id
                                                                                           FROM ams_agendas_b
                                                                                           WHERE parent_id = l_evo_rec.event_offer_id)));


END IF;

-------------------- finish --------------------------
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_event_offer;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_event_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
   IF (c_evo_status_evo%ISOPEN) THEN
      CLOSE c_evo_status_evo;
   END IF;
   IF (c_evo_status_evagd%ISOPEN) THEN
      CLOSE c_evo_status_evagd;
   END IF;
   IF (c_evo_dlv_mthd%ISOPEN) THEN
      CLOSE c_evo_dlv_mthd;
   END IF;
   IF (c_pricelist_header_id%ISOPEN) THEN
      CLOSE c_pricelist_header_id;
   END IF;

      ROLLBACK TO update_event_offer;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END update_event_offer;


--------------------------------------------------------------------
-- PROCEDURE
--    validate_event_offer
--
-- HISTORY
--    11/23/1999  sugupta  Created.
--------------------------------------------------------------------
PROCEDURE validate_event_offer(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   p_evo_rec          IN  evo_rec_type,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
)IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'validate_event_offer';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status VARCHAR2(1);

BEGIN

   ----------------------- initialize --------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ---------------------- validate ------------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_Utility_PVT.debug_message(l_full_name||': check items');
   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
      check_evo_items(
         p_evo_rec        => p_evo_rec,
         p_validation_mode => JTF_PLSQL_API.g_create,
         x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': check record');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
      check_evo_record(
         p_evo_rec       => p_evo_rec,
         p_complete_rec   => NULL,
         x_return_status  => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name||': check inter-entity');

   END IF;

   IF p_validation_level >= JTF_PLSQL_API.g_valid_level_inter_entity THEN
      IF p_evo_rec.event_level = 'MAIN' THEN
         check_evo_inter_entity(
            p_evo_rec        => p_evo_rec,
            p_complete_rec    => p_evo_rec,
            p_validation_mode => JTF_PLSQL_API.g_create,
            x_return_status   => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
   END IF;
   -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': end');

   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END validate_event_offer;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_update_ok_items
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_update_ok_items(
   p_evo_rec        IN  evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

-- add code
-- For example, if the event is in active stage, the user will not
--be able to update the Marketing Message or budget related columns.
-- appid, ev_header_id, source_code cannot not be updated by the user.

-- ALL THIS IS TAKEN CARE OF IN CHEKC_EVO_UPDATE PROC.. THINK THIS PROCEDURE IS NOT NEEDED..

END check_evo_update_ok_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_req_items
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_req_items(
   p_evo_rec       IN  evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   ------------------------ owner_user_id --------------------------
   IF (p_evo_rec.owner_user_id IS NULL OR p_evo_rec.owner_user_id = FND_API.g_miss_num) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_OWNER_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   ------------------------ user_status_id --------------------------
   IF (p_evo_rec.user_status_id IS NULL OR p_evo_rec.user_status_id = FND_API.g_miss_num) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_USER_STATUS_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

    ------------------------ application_id --------------------------
   IF (p_evo_rec.application_id IS NULL OR p_evo_rec.application_id = FND_API.g_miss_num) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_NO_APPLICATION_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
    ------------------------ parent_event_offer_id--------------------------
   IF p_evo_rec.EVENT_LEVEL = 'SUB' THEN
      IF (p_evo_rec.parent_event_offer_id IS NULL OR p_evo_rec.parent_event_offer_id = FND_API.g_miss_num) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_PARENT_OFFER_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
  -- commenting NEEDS TO BE UNCOMMENTED
    ------------------------ custom_setup_id --------------------------
   IF (p_evo_rec.event_level = 'MAIN' AND p_evo_rec.parent_type <> 'CSCH' AND
      (p_evo_rec.custom_setup_id IS NULL OR p_evo_rec.custom_setup_id = FND_API.g_miss_num)) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_NO_SETUP_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   -- check other required items.
END check_evo_req_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_uk_items
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_uk_items(
   p_evo_rec        IN  evo_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   l_valid_flag  VARCHAR2(1);
   l_dummy NUMBER;
   cursor c_src_code(src_code_in IN VARCHAR2) IS
   SELECT 1 FROM DUAL WHERE EXISTS (select 1 from ams_source_codes
          where SOURCE_CODE = src_code_in);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- For create_event_offer, when event_offer_id is passed in, we need to
   -- check if this event_offer_id is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
     AND p_evo_rec.event_offer_id IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_uniqueness(
            'ams_event_offers_all_b',
            'event_offer_id = ' || p_evo_rec.event_offer_id
            ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_DUPLICATE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
-- todo- add a check for uniqueness for name... actually as long as user has at least one
-- of name, venue and dates/time different.. it should be fine

   -- For create_event_offer, when source_code is passed in, we need to
   -- check if this source_code is unique.
   IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_evo_rec.source_code IS NOT NULL
   THEN
   /*
      IF AMS_Utility_PVT.check_uniqueness(
            'ams_event_offers_vl',
            'source_code = ''' || p_evo_rec.source_code || ''''
         ) = FND_API.g_false
     */
      open c_src_code(p_evo_rec.source_code);
      fetch c_src_code into l_dummy;
      close c_src_code;
      IF l_dummy <> 1 THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_DUPE_SOURCE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -- check other unique items

END check_evo_uk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_fk_items
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_fk_items(
   p_evo_rec        IN  evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
  l_table_name                  VARCHAR2(30);
   l_pk_name                     VARCHAR2(30);
   l_pk_value                    VARCHAR2(30);
   l_pk_data_type                NUMBER;
   l_additional_where_clause     VARCHAR2(4000);
   l_where_clause VARCHAR2(80) := null;
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- owner_user_id ------------------------
   -- modified sugupta use ams_jtf_rs_emp_v instead of ams_jtf_rs_emp_v
   IF p_evo_rec.owner_user_id <> FND_API.g_miss_num AND
     p_evo_rec.owner_user_id is NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
         'ams_jtf_rs_emp_v',
         'resource_id',
         p_evo_rec.owner_user_id
      ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_OWNER_USER');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   --------------------- application_id ------------------------
   IF p_evo_rec.application_id <> FND_API.g_miss_num AND
      p_evo_rec.application_id is NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_application',
            'application_id',
            p_evo_rec.application_id
      ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_APP_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   --------------------- inbound_script_name ------------------------
   IF p_evo_rec.inbound_script_name <> FND_API.g_miss_char
      AND p_evo_rec.inbound_script_name IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ies_deployed_scripts',
            'dscript_name',
            p_evo_rec.inbound_script_name,
         AMS_Utility_PVT.g_varchar2
      ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_INBOUND_SCRIPT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
 ----------------------- event_header_id ------------------------
   IF p_evo_rec.event_header_id <> FND_API.g_miss_num AND
     p_evo_rec.event_header_id is NOT NULL THEN
      IF p_evo_rec.EVENT_STANDALONE_FLAG = 'N'THEN
         IF AMS_Utility_PVT.check_fk_exists(
            'ams_event_headers_all_b',
            'event_header_id',
            p_evo_rec.event_header_id
         ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PARENT_HEADER');
               FND_MSG_PUB.add;
             END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;
   ----------------------- parent_event_offer_id ------------------------
   IF p_evo_rec.parent_event_offer_id <> FND_API.g_miss_num
     AND p_evo_rec.parent_event_offer_id IS NOT NULL  THEN
      IF p_evo_rec.EVENT_STANDALONE_FLAG = 'Y'THEN
         IF AMS_Utility_PVT.check_fk_exists(
            'ams_event_offers_all_b',
            'event_offer_id',
            p_evo_rec.parent_event_offer_id
         ) = FND_API.g_false
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PARENT_OFFER');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;
   END IF;
         ----------------------- parent_id ------------------------
   IF p_evo_rec.parent_id <> FND_API.g_miss_num THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'AMS_CAMPAIGNS_ALL_B',
            'CAMPAIGN_ID',
            p_evo_rec.parent_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVH_BAD_PARENT_EVEH');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- duration_uom_code ------------------------
   IF p_evo_rec.event_duration_uom_code <> FND_API.g_miss_char
      AND p_evo_rec.event_duration_uom_code IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'mtl_units_of_measure_tl',
            'uom_code',
            p_evo_rec.event_duration_uom_code,
         AMS_Utility_PVT.g_varchar2
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_DUR_UOM_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- PRICELIST_HEADER_ID ------------------------
   IF p_evo_rec.pricelist_header_id <> FND_API.g_miss_num
     AND p_evo_rec.pricelist_header_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'qp_list_headers_v',
            'list_header_id',
            p_evo_rec.pricelist_header_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PRICE_HEADER_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- PRICELIST_LINE_ID ------------------------
   IF p_evo_rec.pricelist_line_id <> FND_API.g_miss_num
       AND p_evo_rec.pricelist_line_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'qp_list_lines_v',
            'list_line_id',
            p_evo_rec.pricelist_line_id
      ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PRICE_LINE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- TIMEZONE_ID ------------------------
   IF p_evo_rec.timezone_id <> FND_API.g_miss_num
     AND p_evo_rec.timezone_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_timezones_b',
         'upgrade_tz_id',
            p_evo_rec.timezone_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_TIMEZONE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- REG_TIMEZONE_ID ------------------------
   IF p_evo_rec.reg_timezone_id <> FND_API.g_miss_num
     AND p_evo_rec.reg_timezone_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_timezones_b',
         'upgrade_tz_id',
            p_evo_rec.reg_timezone_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_TIMEZONE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- event_venue_id ------------------------
   IF p_evo_rec.event_venue_id <> FND_API.g_miss_num
     AND p_evo_rec.event_venue_id IS NOT NULL  THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_venues_vl',
         'venue_id',
            p_evo_rec.event_venue_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_VENUE_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- event_language_code ------------------------
   IF p_evo_rec.event_language_code <> FND_API.g_miss_char
     AND p_evo_rec.event_language_code IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'fnd_languages',
         'language_code',
            p_evo_rec.event_language_code,
         AMS_Utility_PVT.g_varchar2
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_LANG_CODE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- event_location_id ------------------------
   IF p_evo_rec.event_location_id <> FND_API.g_miss_num
     AND p_evo_rec.event_location_id IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'hz_locations',
         'location_id',
            p_evo_rec.event_location_id
        ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_LOCATION_ID');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
-----------------------Country Code ---------------------------------
   /*   Since from hornet country code contains country id  we need to have
    followinfg validation
*/
   IF p_evo_rec.country_code <> FND_API.g_miss_num AND
      p_evo_rec.country_code IS NOT NULL THEN

      l_table_name              := 'jtf_loc_hierarchies_b';
      l_pk_name                 := 'location_hierarchy_id' ;
      l_pk_data_type            := AMS_Utility_PVT.G_NUMBER ;
      l_pk_value                := to_number(p_evo_rec.country_code);
      l_additional_where_clause := null ;

      IF AMS_Utility_PVT.check_fk_exists(
                   p_table_name              => l_table_name,
                   p_pk_name                 => l_pk_name,
                   p_pk_value                => l_pk_value,
                   p_pk_data_type            => l_pk_data_type,
                   p_additional_where_clause => l_additional_where_clause
         ) = FND_API.g_false
      THEN
         AMS_Utility_Pvt.Error_Message(p_message_name => 'AMS_CSCH_BAD_COUNTRY') ;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- user_status_id ------------------------
   IF p_evo_rec.user_status_id <> FND_API.g_miss_num
    AND p_evo_rec.user_status_id IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'ams_user_statuses_b',
         'user_status_id',
            p_evo_rec.user_status_id
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_USER_ST_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
/* we dont need this validation for inv_id here now as we dont use inv_id
in evo_rec to update/create any more.. we have inv_num, which is always validated for
uniqueness in call to create_inv_item procedure call
   ----------------------- inventory_item_id ------------------------
   -- gdeodhar: There was a WHERE in the following clause. Took it out
   -- This was Ravi's instruction.
   -- looks like AMS_Utility_PVT takes care of adding WHERE and AND accordingly.
   l_where_clause := ' organization_id = ' || p_evo_rec.organization_id;

   IF p_evo_rec.inventory_item_id <> FND_API.g_miss_num
     AND p_evo_rec.inventory_item_id IS NOT NULL AND p_evo_rec.organization_id IS NOT NULL THEN
      IF AMS_Utility_PVT.check_fk_exists(
            'mtl_system_items_b',
         'inventory_item_id',
            p_evo_rec.inventory_item_id,
         AMS_UTILITY_PVT.g_number,
         l_where_clause
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_INV_ITEM_ID');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
*/
 -- no need to check system_status_code as we are
-- storing it in the offer table just to ease the reporting.

END check_evo_fk_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_lookup_items
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_lookup_items(
   p_evo_rec        IN  evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

  --  system_status_code derived from user_status_id always....

   -- event_level must be checked here. (MAIN or SUB)

   ----------------------- event_type_code ------------------------
   IF p_evo_rec.event_type_code <> FND_API.g_miss_char
      AND p_evo_rec.event_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_TYPE',
            p_lookup_code => p_evo_rec.event_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
    ----------------------- event_level ------------------------
   IF p_evo_rec.event_level <> FND_API.g_miss_char
      AND p_evo_rec.event_level IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_LEVEL',
            p_lookup_code => p_evo_rec.event_level
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_LEVEL');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
  ----------------------- waitlist_action_type_code ------------------------
   IF p_evo_rec.waitlist_action_type_code <> FND_API.g_miss_char
      AND p_evo_rec.waitlist_action_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_WAITLIST_ACTION',
            p_lookup_code => p_evo_rec.waitlist_action_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_WAILIST_ACTION');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
    ----------------------- stream_type_code ------------------------
   IF p_evo_rec.stream_type_code <> FND_API.g_miss_char
      AND p_evo_rec.stream_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_STREAM_TYPE',
            p_lookup_code => p_evo_rec.stream_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_STREAM_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
    ----------------------- fund_source_type_code ------------------------
   IF p_evo_rec.fund_source_type_code <> FND_API.g_miss_char
      AND p_evo_rec.fund_source_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_FUND_SOURCE',
            p_lookup_code => p_evo_rec.fund_source_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_FUND_SOURCE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   ----------------------- priority ------------------------
   IF p_evo_rec.priority_type_code <> FND_API.g_miss_char
      AND p_evo_rec.priority_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_PRIORITY',
            p_lookup_code => p_evo_rec.priority_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PRIORITY');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- certification_credit_type ------------------------
   IF p_evo_rec.cert_credit_type_code <> FND_API.g_miss_char
      AND p_evo_rec.cert_credit_type_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_CERT_CREDIT_TYPE',
            p_lookup_code => p_evo_rec.cert_credit_type_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_CREDIT_TYPE');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- cancellation_reason_code ------------------------
   IF p_evo_rec.cancellation_reason_code <> FND_API.g_miss_char
      AND p_evo_rec.cancellation_reason_code IS NOT NULL
   THEN
      IF AMS_Utility_PVT.check_lookup_exists(
            p_lookup_type => 'AMS_EVENT_CANCEL_REASON',
            p_lookup_code => p_evo_rec.cancellation_reason_code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_CANCEL_REASON');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_evo_lookup_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_flag_items
--
-- HISTORY
--    11/23/1999  sugupta  Created
--    11/19/1999  rvaka     updated
---------------------------------------------------------------------
PROCEDURE check_evo_flag_items(
   p_evo_rec        IN  evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;


   ----------------------- active_flag ------------------------
   IF p_evo_rec.active_flag <> FND_API.g_miss_char
      AND p_evo_rec.active_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.active_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_ACTIVE_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;


   ----------------------- private_flag ------------------------
   IF p_evo_rec.private_flag <> FND_API.g_miss_char
      AND p_evo_rec.private_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.private_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_evo_BAD_PRIVATE_FLAG');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
     ----------------------- event_full_flag ------------------------
   IF p_evo_rec.event_full_flag <> FND_API.g_miss_char
      AND p_evo_rec.event_full_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.event_full_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_FULL_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
      ----------------------- auto_register_flag ------------------------
   IF p_evo_rec.auto_register_flag <> FND_API.g_miss_char
      AND p_evo_rec.auto_register_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.auto_register_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_AUTOREG_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
    ----------------------- event_standalone_flag ------------------------
   IF p_evo_rec.event_standalone_flag <> FND_API.g_miss_char
      AND p_evo_rec.event_standalone_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.event_standalone_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_STANDALONE_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
 ----------------------- reg_required_flag ------------------------
   IF p_evo_rec.reg_required_flag <> FND_API.g_miss_char
      AND p_evo_rec.reg_required_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.reg_required_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_REG_REQUIRED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- reg_invited_only_flag ------------------------
   IF p_evo_rec.reg_invited_only_flag <> FND_API.g_miss_char
      AND p_evo_rec.reg_invited_only_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.reg_invited_only_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_REG_INVITED_ONLY_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
      ----------------------- reg_waitlist_allowed_flag ------------------------
   IF p_evo_rec.reg_waitlist_allowed_flag <> FND_API.g_miss_char
      AND p_evo_rec.reg_waitlist_allowed_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.reg_waitlist_allowed_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_REG_WAITLIST_ALLOWED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
      ----------------------- reg_overbook_allowed_flag ------------------------
   IF p_evo_rec.reg_overbook_allowed_flag <> FND_API.g_miss_char
      AND p_evo_rec.reg_overbook_allowed_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.reg_overbook_allowed_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_REG_OVERBOOK_ALLOWED_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   ----------------------- reg_charge_flag ------------------------
   IF p_evo_rec.reg_charge_flag <> FND_API.g_miss_char
      AND p_evo_rec.reg_charge_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.reg_charge_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_REG_CHARGE_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
----------------------- reg_frozen_flag ------------------------
   IF p_evo_rec.reg_frozen_flag <> FND_API.g_miss_char
      AND p_evo_rec.reg_frozen_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.reg_frozen_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_REG_FROZEN_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   ----------------------- overflow_flag ------------------------
   IF p_evo_rec.overflow_flag <> FND_API.g_miss_char
      AND p_evo_rec.overflow_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.overflow_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_OVERFLOW_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
 ----------------------- partner_flag ------------------------
   IF p_evo_rec.partner_flag <> FND_API.g_miss_char
      AND p_evo_rec.partner_flag IS NOT NULL
   THEN
      IF AMS_Utility_PVT.is_Y_or_N(p_evo_rec.partner_flag) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_BAD_PARTNER_FLAG');
            FND_MSG_PUB.add;
         END IF;

         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   -- check other flags

END check_evo_flag_items;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_items
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_items(
   p_evo_rec         IN  evo_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN

   -------------------------- Update Mode ----------------------------
   -- check if the p_evo_rec has any columns that should not be updated at this stage as per the business logic.
   -- for example, changes to source_code should not be allowed at any update.
   -- Also when the event is in active stage, changes to marketing message and budget related columns should not be allowed.
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('before ok_items');
END IF;
   IF p_validation_mode = JTF_PLSQL_API.g_update THEN
        check_evo_update_ok_items(
            p_evo_rec        => p_evo_rec,
            x_return_status  => x_return_status
        );

        IF x_return_status <> FND_API.g_ret_sts_success THEN
             RETURN;
        END IF;

    END IF;
--------------------------------------Create mode--------------------------
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('before uk_items');
END IF;

   check_evo_uk_items(
      p_evo_rec         => p_evo_rec,
      p_validation_mode => p_validation_mode,
      x_return_status   => x_return_status
   );

   -------------------------- Create or Update Mode ----------------------------
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('before req_items');
END IF;

   check_evo_req_items(
      p_evo_rec        => p_evo_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('before fk_items');
END IF;

   check_evo_fk_items(
      p_evo_rec        => p_evo_rec,
      x_return_status  => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('before lookup_items');
END IF;

   check_evo_lookup_items(
      p_evo_rec         => p_evo_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('before flag_items');
END IF;

   check_evo_flag_items(
      p_evo_rec         => p_evo_rec,
      x_return_status   => x_return_status
   );

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END check_evo_items;


---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_record
--
-- HISTORY
--    11/23/1999  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_record(
   p_evo_rec        IN  evo_rec_type,
   p_complete_rec   IN  evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   -- The following needs to be checked:
   -- 1. Event end date follows start date
   --    if start dtae and end date are same(added 07/20/2000 OR event level = SUB), then check for
   --    end time follows start time
   -- 2. evo start date follows reg start date
   -- 3. evo end date follows reg end date
   -- 4. reg. for agenda (SUB) events not supported yet...

   -- 5. reg_maximum_cap shud be greater than reg_min_cap
   -- 6. Duration and its UOM should be together

   l_evo_start_date  DATE := p_evo_rec.event_start_date;
   l_reg_start_date  DATE := p_evo_rec.reg_start_date;
   l_evo_start_date_time  DATE := p_evo_rec.event_start_date_time;
   l_reg_start_time  DATE := p_evo_rec.reg_start_time;


   l_evo_end_date    DATE := p_evo_rec.event_end_date;
   l_reg_end_date    DATE := p_evo_rec.reg_end_date;
   l_evo_end_date_time  DATE := p_evo_rec.event_end_date_time;
   l_reg_end_time  DATE := p_evo_rec.reg_end_time;
   l_max_cap NUMBER  := p_evo_rec.REG_MAXIMUM_CAPACITY;
   l_min_cap NUMBER  := p_evo_rec.REG_MINIMUM_CAPACITY;
   l_parent_start_date DATE;
   l_parent_end_date DATE;

   cursor get_parent_date (id_in in NUMBER)is
   select ACTUAL_EXEC_START_DATE, ACTUAL_EXEC_END_DATE
   from AMS_CAMPAIGNS_ALL_B
   where CAMPAIGN_ID = id_in
   and  ROLLUP_TYPE = 'RCAM';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_evo_rec.event_start_date <> FND_API.g_miss_date
      OR p_evo_rec.event_end_date <> FND_API.g_miss_date
   THEN
      IF p_evo_rec.event_start_date = FND_API.g_miss_date THEN
         l_evo_start_date := p_complete_rec.event_start_date;
      END IF;

      IF p_evo_rec.event_end_date = FND_API.g_miss_date THEN
         l_evo_end_date := p_complete_rec.event_end_date;
      END IF;

      IF l_evo_start_date > l_evo_end_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_START_DT_GT_END_DT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         return;
      END IF;

      IF p_evo_rec.parent_type = 'RCAM' THEN
         open get_parent_date(p_evo_rec.parent_id);
         fetch get_parent_date into l_parent_start_date, l_parent_end_date;
         close get_parent_date;
         IF l_evo_start_date < l_parent_start_date THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_SD_GT_PRNT_SD');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            return;
         END IF;
         IF l_evo_start_date > l_parent_end_date THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_SD_LT_PRNT_ED');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            return;
         END IF;
         IF l_evo_end_date < l_parent_start_date THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_ED_GT_PRNT_SD');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            return;
         END IF;
         IF l_evo_end_date > l_parent_end_date THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_ED_LT_PRNT_ED');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
            return;
         END IF;
      END IF;


      --  useful for agendas as well(for agenda, st dt = end dt)
      IF l_evo_start_date = l_evo_end_date OR p_complete_rec.event_level = 'SUB' THEN
         IF p_evo_rec.event_start_date_time <> FND_API.g_miss_date
            OR p_evo_rec.event_end_date_time <> FND_API.g_miss_date
         THEN
            IF p_evo_rec.event_start_date_time = FND_API.g_miss_date THEN
               l_evo_start_date_time := p_complete_rec.event_start_date_time;
            END IF;

            IF p_evo_rec.event_end_date_time = FND_API.g_miss_date THEN
               l_evo_end_date_time := p_complete_rec.event_end_date_time;
            END IF;

            IF(to_char(l_evo_end_date_time,'HH24:MI') = '00:00')
            THEN
                l_evo_end_date_time := to_date(to_char(l_evo_end_date_time, 'DD-MM-YYYY') || '23:59','DD-MM-YYYY HH24:MI');
            END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('End Date Time is ' ||to_char(l_evo_end_date_time, 'DD-MM-YYYY HH24:MI'));
            END IF;
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_UTILITY_PVT.debug_message('Start Date Time is ' ||to_char(l_evo_start_date_time,'DD-MM-YYYY HH24:MI') );
            END IF;

           IF l_evo_start_date_time > l_evo_end_date_time THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

                  AMS_UTILITY_PVT.debug_message('Entered the loop');
              END IF;

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_EVO_START_TM_GT_END_TM');
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
               return;
            END IF; -- st tm > end tm
         END IF; -- check time for miss_dates
      END IF; -- st dt = end dt
   END IF; -- check dt for miss_date

   IF p_evo_rec.EVENT_DURATION <> FND_API.g_miss_num
      OR p_complete_rec.EVENT_DURATION IS NOT NULL
   THEN
      IF (AMS_DEBUG_HIGH_ON) THEN

          AMS_Utility_PVT.debug_message('Entered Here1');
      END IF;

      IF ( p_evo_rec.EVENT_DURATION_UOM_CODE IS NULL
          OR
         (p_evo_rec.EVENT_DURATION_UOM_CODE = FND_API.g_miss_char  AND
          p_complete_rec.EVENT_DURATION_UOM_CODE IS NULL) )

      THEN
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_PVT.debug_message('Entered Here2');
         END IF;
         AMS_Utility_PVT.error_message('AMS_EVO_NO_DUR_UOM_CODE');
         x_return_status := FND_API.g_ret_sts_error;
         return;
      END IF;
   END IF;

   IF p_evo_rec.EVENT_DURATION_UOM_CODE <> FND_API.g_miss_char
      OR p_complete_rec.EVENT_DURATION_UOM_CODE IS NOT NULL
   THEN
      IF p_evo_rec.EVENT_DURATION = FND_API.g_miss_num
         AND p_complete_rec.EVENT_DURATION IS NULL
      THEN
         AMS_Utility_PVT.error_message('AMS_EVO_NO_DUR_WITH_CODE');
           x_return_status := FND_API.g_ret_sts_error;
         return;
      END IF;
   END IF;
-- added sugupta 07/20/2000 if budget amount's there, there has to be currency code

   IF p_evo_rec.FUND_AMOUNT_TC <> FND_API.g_miss_num
      OR p_complete_rec.FUND_AMOUNT_TC IS NOT NULL
   THEN
      IF p_evo_rec.CURRENCY_CODE_TC = FND_API.g_miss_char
         AND p_complete_rec.CURRENCY_CODE_TC IS NULL
      THEN
         AMS_Utility_PVT.error_message('AMS_CAMP_BUDGET_NO_CURRENCY'); -- reusing campaign message
           x_return_status := FND_API.g_ret_sts_error;
         return;
      END IF;
   END IF;

   -- Code Added by GMADANA
   IF p_complete_rec.event_start_date_time IS  NULL   -- coming from create
   THEN
       l_evo_start_date_time := p_evo_rec.event_start_date_time;
       l_evo_end_date_time := p_evo_rec.event_end_date_time;
   ELSE  -- coming from update
       l_evo_start_date_time := p_complete_rec.event_start_date_time;
       l_evo_end_date_time := p_complete_rec.event_end_date_time;
   END IF;

   -- Donot make the end time as 23:59, if the end time is 12:00 AM.
/* IF(to_char(l_evo_end_date_time,'HH24:MI') = '00:00')
   THEN
      l_evo_end_date_time := to_date(to_char(l_evo_end_date_time, 'DD-MM-YYYY') || '23:59','DD-MM-YYYY HH24:MI');
   END IF;
*/

 IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_UTILITY_PVT.debug_message('End Date Time is ' ||to_char(l_evo_end_date_time, 'DD-MM-YYYY HH24:MI'));

 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('Start Date Time is ' ||to_char(l_evo_start_date_time,'DD-MM-YYYY HH24:MI') );
 END IF;


   IF l_evo_start_date_time > l_evo_end_date_time
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('AMS', 'AMS_EVO_START_TM_GT_END_TM');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      return;
   END IF;


END check_evo_record;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_update
--
-- HISTORY
--    03/31/00 sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_update(
   p_evo_rec       IN OUT NOCOPY  AMS_EVENTOFFER_PVT.evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_evo IS
   SELECT *
     FROM ams_event_offers_vl
    WHERE event_offer_id = p_evo_rec.event_offer_id;

   CURSOR c_source_code IS
   SELECT 1
     FROM ams_source_codes
    WHERE source_code = p_evo_rec.source_code
    AND active_flag = 'Y';

   l_track_id   NUMBER;
   l_session_id   NUMBER;


   CURSOR c_get_track_id(id_in in NUMBER) IS
   SELECT agenda_id
   FROM ams_agendas_b
   WHERE parent_id = id_in;

   CURSOR c_get_session_id(id_in in NUMBER) IS
   SELECT agenda_id
   FROM ams_agendas_b
   WHERE parent_id = id_in;


   l_msg_data  VARCHAR2(2000);
   l_msg_count NUMBER;
   l_dummy     NUMBER;
   l_evo_rec  c_evo%ROWTYPE;
   l_evo_start_date DATE := p_evo_rec.event_start_date;
   l_evo_end_date DATE := p_evo_rec.event_end_date;
   l_max_cap NUMBER := p_evo_rec.REG_MAXIMUM_CAPACITY;
   l_source_code VARCHAR2(30);
   l_event_availability NUMBER;
   l_event_waitlisted NUMBER;
   l_reg_overbook_allowed_flag VARCHAR2(1) := p_evo_rec.reg_overbook_allowed_flag;
   l_reg_overbook_pct NUMBER := p_evo_rec.reg_overbook_pct;
   l_effective_capacity NUMBER;
   l_num_registered NUMBER;
   l_auto_register_flag VARCHAR2(1) := p_evo_rec.auto_register_flag;
   l_invited_only_flag VARCHAR2(1) := p_evo_rec.reg_invited_only_flag;
BEGIN

    IF (AMS_DEBUG_HIGH_ON) THEN



        AMS_Utility_PVT.debug_message(p_evo_rec.event_offer_id ||': check evo_update');

    END IF;
   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_evo;
   FETCH c_evo INTO l_evo_rec;
   IF c_evo%NOTFOUND THEN
      CLOSE c_evo;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_evo;

------ check some validation stuff for updates-----------------
   -- Check if the above logic will work if either of the dates are NULL.
   IF p_evo_rec.reg_start_date <> FND_API.g_miss_date
      AND p_evo_rec.reg_end_date <> FND_API.g_miss_date
   THEN
      IF p_evo_rec.event_start_date = FND_API.g_miss_date THEN
         l_evo_start_date := l_evo_rec.event_start_date;
      END IF;

      IF p_evo_rec.event_end_date = FND_API.g_miss_date THEN
         l_evo_end_date := l_evo_rec.event_end_date;
      END IF;
      /* *** BATOLETI   Ref bug# 4404567
             Bypassing the registration date valication in case of conc job
             updation process...
      *** */
      IF p_evo_rec.system_status_code <> 'COMPLETED' THEN   ----batoleti Ref Bug# 4404567
         IF p_evo_rec.reg_start_date > l_evo_end_date  THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
              FND_MESSAGE.set_name('AMS', 'AMS_EVO_REGST_DT_GT_START_DT');
              FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
          END IF;


         IF p_evo_rec.reg_end_date > l_evo_end_date THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
               FND_MESSAGE.set_name('AMS', 'AMS_EVO_REGED_DT_GT_END_DT');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_error;
         END IF;
      END IF;  --batoleti  Ref Bug# 4404567
      END IF;
-- 03/31/00 sugupta added
   IF p_evo_rec.REG_MINIMUM_REQ_BY_DATE <> FND_API.g_miss_date
      AND p_evo_rec.reg_end_date <> FND_API.g_miss_date
   THEN
      IF (p_evo_rec.REG_MINIMUM_REQ_BY_DATE > p_evo_rec.reg_end_date or
            p_evo_rec.REG_MINIMUM_REQ_BY_DATE < p_evo_rec.reg_start_date)THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_REQ_DT_GT_RGEND_DT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
-- 07/13/00 sugupta added Bug 1333032
   IF p_evo_rec.reg_start_date <> FND_API.g_miss_date
      AND p_evo_rec.reg_end_date <> FND_API.g_miss_date
   THEN
      IF p_evo_rec.reg_start_date > p_evo_rec.reg_end_date THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_EVO_RGSTDT_GT_RGEND_DT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      ELSIF p_evo_rec.reg_start_date = p_evo_rec.reg_end_date THEN
--  test for reg times
         IF p_evo_rec.reg_start_time <> FND_API.g_miss_date
               OR p_evo_rec.reg_end_time <> FND_API.g_miss_date
            THEN
            IF p_evo_rec.reg_start_time > p_evo_rec.reg_end_time THEN
                  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
                  THEN
                     FND_MESSAGE.set_name('AMS', 'AMS_EVO_RGSTTM_GT_RGEND_TM');
                     FND_MSG_PUB.add;
                  END IF;
                  x_return_status := FND_API.g_ret_sts_error;
            END IF; -- st tm > end tm
         END IF; -- check time for miss_dates
      END IF; -- reg st dt > reg end dt
   END IF;

-- 03/31/00 sugupta added to make sure reg_min_capacity is not less than reg_max_capacity
-- IF p_evo_rec.REG_MINIMUM_CAPACITY <> FND_API.g_miss_num THEN

      IF (p_evo_rec.reg_invited_only_flag = FND_API.g_miss_char)
      THEN
         l_invited_only_flag := l_evo_rec.reg_invited_only_flag;
      END IF;
      IF (nvl(l_invited_only_flag, 'Y') <> 'Y')
      THEN
         IF p_evo_rec.REG_MAXIMUM_CAPACITY = FND_API.g_miss_num
         THEN
            l_max_cap := l_evo_rec.REG_MAXIMUM_CAPACITY;
         END IF;

         IF l_max_cap IS NOT NULL
         THEN
            IF (    (p_evo_rec.REG_MINIMUM_CAPACITY <> FND_API.g_miss_num)
                AND (p_evo_rec.REG_MINIMUM_CAPACITY > l_max_cap)
               )
            THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
               THEN
                  FND_MESSAGE.set_name('AMS', 'AMS_EVO_MINCAP_GT_MAXCAP');
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
            END IF;
         END IF;

         IF p_evo_rec.reg_overbook_allowed_flag = FND_API.g_miss_char
         THEN
            l_reg_overbook_allowed_flag := l_evo_rec.reg_overbook_allowed_flag;
         END IF;
         IF p_evo_rec.reg_overbook_pct = FND_API.g_miss_num
         THEN
            l_reg_overbook_pct := l_evo_rec.reg_overbook_pct;
         END IF;

         IF (AMS_DEBUG_HIGH_ON) THEN



             AMS_Utility_Pvt.Debug_Message('l_reg_overbook_allowed_flag ' || l_reg_overbook_allowed_flag);

         END IF;
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_Pvt.Debug_Message('l_max_cap: ' || l_max_cap);
         END IF;
         IF l_reg_overbook_allowed_flag <> 'Y'
         THEN
            l_effective_capacity := l_max_cap;
         ELSE
            IF (AMS_DEBUG_HIGH_ON) THEN

                AMS_Utility_Pvt.Debug_Message('l_reg_overbook_pct ' || l_reg_overbook_pct);
            END IF;
            l_effective_capacity := round((1 + (l_reg_overbook_pct/100)) * l_max_cap);
         END IF;
         l_num_registered := AMS_EvtRegs_PVT.check_number_registered(p_event_offer_id => l_evo_rec.event_offer_id);
         l_event_availability := l_effective_capacity - l_num_registered;
         IF (AMS_DEBUG_HIGH_ON) THEN

             AMS_Utility_Pvt.Debug_Message('Slots available: ' || l_event_availability);
         END IF;
         IF nvl(l_event_availability, 1) < 0
         THEN
            -- Capacity is too small - error
            AMS_Utility_PVT.Error_Message(  p_message_name => 'AMS_EVO_REG_CAP_LT_ROSTER'
                                          , p_token_name   => 'REGCNT'
                                          , p_token_value  => to_char(l_num_registered)
                                         );
            x_return_status := FND_API.g_ret_sts_error;
         ELSE
            -- There may be room in the event now for people on the waitlist
            IF (p_evo_rec.auto_register_flag = FND_API.g_miss_char)
            THEN
               l_auto_register_flag := l_evo_rec.auto_register_flag;
            END IF;

            IF (nvl(l_auto_register_flag, 'Y') = 'Y')
            THEN
               l_event_waitlisted := AMS_EvtRegs_PVT.check_number_waitlisted(p_event_offer_id => l_evo_rec.event_offer_id);
               IF (  (l_event_availability IS NULL)
                   OR
                     (l_event_availability > l_event_waitlisted)
                  )
               THEN
                  -- Take everyone off the waitlist.
                  l_event_availability := l_event_waitlisted;
               END IF;
               --RAISE FND_API.g_exc_error;
               FOR l_i IN 1..l_event_availability LOOP
                  AMS_EvtRegs_PVT.prioritize_waitlist(  p_api_version_number => 1.0
                                                      , p_Init_Msg_List => FND_API.G_FALSE
                                                      , p_Commit => FND_API.G_FALSE
                                                      , p_override_availability => FND_API.G_TRUE
                                                      , p_event_offer_id => p_evo_rec.event_offer_id
                                                      , x_return_status => x_return_status
                                                      , x_msg_count => l_msg_count
                                                      , x_msg_data => l_msg_data
                                                     );
                  IF (x_return_status = FND_API.g_ret_sts_error)
                  THEN
                     AMS_Utility_PVT.Error_Message(  p_message_name => 'AMS_EVO_REG_WAITLIST_CAP');
                  END IF;
               END LOOP;
            END IF; -- auto_register_flag
         END IF;
         --RAISE FND_API.g_exc_error;
      END IF; -- invite only flag

      IF p_evo_rec.event_venue_id is NULL
      THEN
          OPEN c_get_track_id(p_evo_rec.event_offer_id);
          fetch c_get_track_id into l_track_id;
          WHILE c_get_track_id%FOUND LOOP
              OPEN c_get_session_id(l_track_id);
              fetch c_get_session_id into l_session_id;
                   WHILE c_get_session_id%FOUND LOOP
             update ams_agendas_b
             set room_id = null
                 ,object_version_number = object_version_number + 1
             where agenda_id = l_session_id;
                       fetch c_get_session_id into l_session_id;
         END LOOP;
         close c_get_session_id;
         fetch c_get_track_id into l_track_id;
          END LOOP;
          close c_get_track_id;
      END IF;
-- END IF;

 ---------------------------- status codes-----------------------
   -- change status through workflow
   -- modified sugupta 07/20/2000
   --NOT NEEDED FOR EVENT AGENDAS

   -- Commented the old style of approval process call.
   -- gdeodhar : Oct 06, 2000.
/*
 if l_evo_rec.event_level = 'MAIN' then
   IF p_evo_rec.user_status_id <> FND_API.g_miss_num
      AND p_evo_rec.user_status_id <> l_evo_rec.user_status_id
   THEN
      AMS_WFCmpApr_PVT.StartProcess(
         p_approval_for => 'EVEO',
         p_approval_for_id => p_evo_rec.event_offer_id,
         p_object_version_number => p_evo_rec.object_version_number,
         p_orig_stat_id => l_evo_rec.user_status_id,
         p_new_stat_id => p_evo_rec.user_status_id,
         p_requester_userid => FND_GLOBAL.user_id
      );
   END IF;

  -- need more specific rules on locking columns at different statuses

   -- the following will be locked after theme approval
   IF l_evo_rec.system_status_code <> 'NEW' THEN
      IF p_evo_rec.event_offer_name <> FND_API.g_miss_char
         AND p_evo_rec.event_offer_name <> l_evo_rec.event_offer_name
      THEN
         AMS_Utility_PVT.error_message('AMS_EVO_UPDATE_OFFER_NAME');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_evo_rec.event_type_code <> fnd_api.g_miss_char
         and p_evo_rec.event_type_code <> l_evo_rec.event_type_code
         and (p_evo_rec.event_type_code IS NOT NULL
            OR l_evo_rec.event_type_code IS NOT NULL)
      THEN
         AMS_Utility_PVT.error_message('AMS_EVO_UPDATE_EVENT_TYPE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_evo_rec.event_start_date <> fnd_api.g_miss_date
         and p_evo_rec.event_start_date <> l_evo_rec.event_start_date
         and (p_evo_rec.event_start_date IS NOT NULL
            OR l_evo_rec.event_start_date IS NOT NULL)
      THEN
         AMS_Utility_PVT.error_message('AMS_EVO_UPDATE_START_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_evo_rec.event_end_date <> fnd_api.g_miss_date
         and p_evo_rec.event_end_date <> l_evo_rec.event_end_date
         and (p_evo_rec.event_end_date IS NOT NULL
            OR l_evo_rec.event_end_date IS NOT NULL)
      THEN
         AMS_Utility_PVT.error_message('AMS_EVO_UPDATE_END_DATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF; -- status code <> new
 end if; -- event_level MAIN
*/
   -- Commented part for the old style of approval process call ends.
   -- Locking of fields will be added later.
   -- gdeodhar : Oct 06, 2000.

END check_evo_update;

---------------------------------------------------------------------
-- PROCEDURE
--    check_evo_inter_entity
--
-- HISTORY
--    03/31/00  sugupta  Created.
---------------------------------------------------------------------
PROCEDURE check_evo_inter_entity(
   p_evo_rec        IN  evo_rec_type,
   p_complete_rec    IN  evo_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_return_status  VARCHAR2(1);
   l_dummy   number;
   l_src_code varchar2(30);

/*    cursor c_src_code(id_in) IS
      select source_code from ams_event_offers_all_b
      where event_offer_id = id_in;
*/
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------- check fund source ----------------------
   -- no need to check for event_level = MAIN
   IF p_evo_rec.fund_source_type_code <> FND_API.g_miss_char
      OR p_evo_rec.fund_source_id <> FND_API.g_miss_num
   THEN
      AMS_EvhRules_PVT.check_evh_fund_source(
         p_complete_rec.fund_source_type_code,
         p_complete_rec.fund_source_id,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;
   END IF;
/* 04/01/2000 we will not be enforcing that event offering dates lie between
 event header dates
   ------------------- check dates ------------------------------
   IF p_evo_rec.event_start_date <> FND_API.g_miss_date
      OR p_evo_rec.event_end_date <> FND_API.g_miss_date
   THEN
      check_evo_header_dates(
         p_complete_rec.event_header_id,
         p_complete_rec.event_start_date,
         p_complete_rec.event_end_date,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;
   END IF;
*/
-- added sugupta 31/8/2000
   ------------------- check calendar ----------------------
   IF p_evo_rec.event_calendar <> FND_API.g_miss_char
      OR p_evo_rec.start_period_name <> FND_API.g_miss_char
      OR p_evo_rec.end_period_name <> FND_API.g_miss_char
      OR p_evo_rec.event_start_date <> FND_API.g_miss_date
      OR p_evo_rec.event_end_date <> FND_API.g_miss_date
   THEN
      AMS_EvhRules_PVT.check_evh_calendar(
         p_complete_rec.event_calendar,
         p_complete_rec.start_period_name,
         p_complete_rec.end_period_name,
         p_complete_rec.event_start_date,
         p_complete_rec.event_end_date,
         l_return_status
      );
      IF l_return_status <> FND_API.g_ret_sts_success THEN
         x_return_status := l_return_status;
      END IF;
   END IF;

/*   IF p_validation_mode = JTF_PLSQL_API.g_update
   THEN
        IF p_evo_rec.event_venue_id <> p_complete_rec.event_venue_id
        IF p_complete_rec.event_venue_id is NULL
   THEN
          OPEN c_get_track_id(p_evo_rec.event_offer_id);
          fetch c_get_track_id into l_track_id;
          WHILE c_get_track_id%FOUND LOOP
              OPEN c_get_session_id(l_track_id);
              fetch c_get_session_id into l_session_id;
                   WHILE c_get_session_id%FOUND LOOP
             update ams_agendas_b
             set room_id = null
                 ,object_version_number = object_version_number + 1
             where agenda_id = l_session_id;
                       fetch c_get_session_id into l_session_id;
         END LOOP;
         close c_get_session_id
         fetch c_get_track_id into l_track_id;
          END LOOP;
          close c_get_track_id;
        END IF;
   END IF;
   */
END check_evo_inter_entity;

---------------------------------------------------------------------
-- PROCEDURE
--    init_evo_rec
--
-- HISTORY
--    11/23/1999  sugupta  Create.
---------------------------------------------------------------------
PROCEDURE init_evo_rec(
   x_evo_rec  OUT NOCOPY  evo_rec_type
)
IS
BEGIN
/* commented by murali looks like not matching with the record type
   x_evo_rec.event_offer_id := FND_API.g_miss_num;
   x_evo_rec.last_update_date := FND_API.g_miss_date;
   x_evo_rec.last_updated_by := FND_API.g_miss_num;
   x_evo_rec.creation_date := FND_API.g_miss_date;
   x_evo_rec.created_by := FND_API.g_miss_num;
   x_evo_rec.last_update_login := FND_API.g_miss_num;
   x_evo_rec.object_version_number := FND_API.g_miss_num;
   x_evo_rec.event_level := FND_API.g_miss_char;
   x_evo_rec.application_id := FND_API.g_miss_num;
   x_evo_rec.event_type_code := FND_API.g_miss_char;
   x_evo_rec.EVENT_DELIVERY_METHOD_ID :=  FND_API.g_miss_num;
   x_evo_rec.EVENT_DELIVERY_METHOD_CODE :=  FND_API.g_miss_char;
   x_evo_rec.event_header_id :=  FND_API.g_miss_num;
   x_evo_rec.active_flag := FND_API.g_miss_char;
   x_evo_rec.private_flag := FND_API.g_miss_char;
   x_evo_rec.user_status_id := FND_API.g_miss_num;
   x_evo_rec.system_status_code := FND_API.g_miss_char;
   x_evo_rec.last_status_date := FND_API.g_miss_date;
   x_evo_rec.stream_type_code := FND_API.g_miss_char;
   x_evo_rec.source_code := FND_API.g_miss_char;
   x_evo_rec.event_standalone_flag := FND_API.g_miss_char;
   x_evo_rec.reg_required_flag := FND_API.g_miss_char;
   x_evo_rec.reg_charge_flag := FND_API.g_miss_char;
   x_evo_rec.reg_invited_only_flag := FND_API.g_miss_char;
   x_evo_rec.partner_flag := FND_API.g_miss_char;
   x_evo_rec.overflow_flag := FND_API.g_miss_char;
   x_evo_rec.parent_event_offer_id := FND_API.g_miss_num;
   x_evo_rec.reg_frozen_flag := FND_API.g_miss_char;
   x_evo_rec.auto_register_flag := FND_API.g_miss_char;
   x_evo_rec.event_full_flag := FND_API.g_miss_char;
   x_evo_rec.REG_OVERBOOK_ALLOWED_FLAG := FND_API.g_miss_char;
   x_evo_rec.REG_CHARGE_FLAG := FND_API.g_miss_char;
   x_evo_rec.REG_INVITED_ONLY_FLAG := FND_API.g_miss_char;
   x_evo_rec.REG_WAITLIST_ALLOWED_FLAG := FND_API.g_miss_char;
   x_evo_rec.EVENT_VENUE_ID := FND_API.g_miss_num;
   x_evo_rec.FUND_AMOUNT_TC := FND_API.g_miss_num;
   x_evo_rec.FUND_AMOUNT_FC := FND_API.g_miss_num;
   x_evo_rec.CURRENCY_CODE_TC := FND_API.g_miss_char;
   x_evo_rec.CURRENCY_CODE_FC := FND_API.g_miss_char;
   x_evo_rec.event_duration := FND_API.g_miss_num;
   x_evo_rec.event_duration_uom_code := FND_API.g_miss_char;
   x_evo_rec.reg_maximum_capacity := FND_API.g_miss_num;
   x_evo_rec.reg_minimum_capacity := FND_API.g_miss_num;
   x_evo_rec.cert_credit_type_code := FND_API.g_miss_char;
   x_evo_rec.certification_credits := FND_API.g_miss_num;
   x_evo_rec.inventory_item_id := FND_API.g_miss_num;
   x_evo_rec.inventory_item := FND_API.g_miss_char;
   x_evo_rec.organization_id := FND_API.g_miss_num;
   x_evo_rec.actual_revenue := FND_API.g_miss_num;
   x_evo_rec.forecasted_cost := FND_API.g_miss_num;
   x_evo_rec.actual_cost := FND_API.g_miss_num;
   x_evo_rec.coordinator_id := FND_API.g_miss_num;
   x_evo_rec.fund_source_type_code := FND_API.g_miss_char;
   x_evo_rec.fund_source_id := FND_API.g_miss_num;
   x_evo_rec.owner_user_id := FND_API.g_miss_num;
   x_evo_rec.timezone_id := FND_API.g_miss_num;
   x_evo_rec.url := FND_API.g_miss_char;
   x_evo_rec.priority_type_code := FND_API.g_miss_char;
   x_evo_rec.cancellation_reason_code := FND_API.g_miss_char;
   x_evo_rec.inbound_script_name := FND_API.g_miss_char;
   x_evo_rec.PRICELIST_HEADER_CURRENCY_CODE := FND_API.g_miss_char;
   x_evo_rec.PRICELIST_LIST_PRICE := FND_API.g_miss_num;
   x_evo_rec.attribute_category := FND_API.g_miss_char;
   x_evo_rec.attribute1 := FND_API.g_miss_char;
   x_evo_rec.attribute2 := FND_API.g_miss_char;
   x_evo_rec.attribute3 := FND_API.g_miss_char;
   x_evo_rec.attribute4 := FND_API.g_miss_char;
   x_evo_rec.attribute5 := FND_API.g_miss_char;
   x_evo_rec.attribute6 := FND_API.g_miss_char;
   x_evo_rec.attribute7 := FND_API.g_miss_char;
   x_evo_rec.attribute8 := FND_API.g_miss_char;
   x_evo_rec.attribute9 := FND_API.g_miss_char;
   x_evo_rec.attribute10 := FND_API.g_miss_char;
   x_evo_rec.attribute11 := FND_API.g_miss_char;
   x_evo_rec.attribute12 := FND_API.g_miss_char;
   x_evo_rec.attribute13 := FND_API.g_miss_char;
   x_evo_rec.attribute14 := FND_API.g_miss_char;
   x_evo_rec.attribute15 := FND_API.g_miss_char;
      x_evo_rec.EVENT_OFFER_NAME := FND_API.g_miss_char;
      x_evo_rec.EVENT_MKTG_MESSAGE := FND_API.g_miss_char;
      x_evo_rec.description := FND_API.g_miss_char;
   x_evo_rec.custom_setup_id := FND_API.g_miss_num;
      x_evo_rec.country_code := FND_API.g_miss_char;
      x_evo_rec.business_unit_id := FND_API.g_miss_num;
   x_evo_rec.event_calendar := FND_API.g_miss_char;
   x_evo_rec.start_period_name := FND_API.g_miss_char;
   x_evo_rec.end_period_name := FND_API.g_miss_char;
   x_evo_rec.global_flag := FND_API.g_miss_char;
*/

x_evo_rec.EVENT_OFFER_ID            := FND_API.g_miss_num;
x_evo_rec.LAST_UPDATE_DATE          := FND_API.g_miss_date;
x_evo_rec.LAST_UPDATED_BY           := FND_API.g_miss_num;
x_evo_rec.CREATION_DATE             := FND_API.g_miss_date;
x_evo_rec.CREATED_BY                := FND_API.g_miss_num;
x_evo_rec.LAST_UPDATE_LOGIN         := FND_API.g_miss_num;
x_evo_rec.OBJECT_VERSION_NUMBER     := FND_API.g_miss_num;
x_evo_rec.APPLICATION_ID            := FND_API.g_miss_num;
x_evo_rec.EVENT_HEADER_ID           := FND_API.g_miss_num;
x_evo_rec.PRIVATE_FLAG              := FND_API.g_miss_char;
x_evo_rec.ACTIVE_FLAG               := FND_API.g_miss_char;
x_evo_rec.SOURCE_CODE               := FND_API.g_miss_char;
x_evo_rec.EVENT_LEVEL               := FND_API.g_miss_char;
x_evo_rec.USER_STATUS_ID            := FND_API.g_miss_num;
x_evo_rec.LAST_STATUS_DATE          := FND_API.g_miss_date;
x_evo_rec.SYSTEM_STATUS_CODE        := FND_API.g_miss_char;
x_evo_rec.EVENT_TYPE_CODE           := FND_API.g_miss_char;
x_evo_rec.EVENT_DELIVERY_METHOD_ID  := FND_API.g_miss_num;
x_evo_rec.EVENT_DELIVERY_METHOD_CODE := FND_API.g_miss_char;
x_evo_rec.EVENT_REQUIRED_FLAG      := FND_API.g_miss_char;
x_evo_rec.EVENT_LANGUAGE_CODE       := FND_API.g_miss_char;
x_evo_rec.EVENT_LOCATION_ID         := FND_API.g_miss_num;
x_evo_rec.CITY                  := FND_API.g_miss_char;
x_evo_rec.STATE                  := FND_API.g_miss_char;
x_evo_rec.PROVINCE               := FND_API.g_miss_char;
x_evo_rec.COUNTRY               := FND_API.g_miss_char;
x_evo_rec.OVERFLOW_FLAG             := FND_API.g_miss_char;
x_evo_rec.PARTNER_FLAG              := FND_API.g_miss_char;
x_evo_rec.EVENT_STANDALONE_FLAG     := FND_API.g_miss_char;
x_evo_rec.REG_FROZEN_FLAG           := FND_API.g_miss_char;
x_evo_rec.REG_REQUIRED_FLAG         := FND_API.g_miss_char;
x_evo_rec.REG_CHARGE_FLAG           := FND_API.g_miss_char;
x_evo_rec.REG_INVITED_ONLY_FLAG     := FND_API.g_miss_char;
x_evo_rec.REG_WAITLIST_ALLOWED_FLAG := FND_API.g_miss_char;
x_evo_rec.REG_OVERBOOK_ALLOWED_FLAG := FND_API.g_miss_char;
x_evo_rec.PARENT_EVENT_OFFER_ID     := FND_API.g_miss_num;
x_evo_rec.EVENT_DURATION            := FND_API.g_miss_num;
x_evo_rec.EVENT_DURATION_UOM_CODE   := FND_API.g_miss_char;
x_evo_rec.EVENT_START_DATE          := FND_API.g_miss_date;
x_evo_rec.EVENT_START_DATE_TIME     := FND_API.g_miss_date;
x_evo_rec.EVENT_END_DATE            := FND_API.g_miss_date;
x_evo_rec.EVENT_END_DATE_TIME       := FND_API.g_miss_date;
x_evo_rec.REG_START_DATE            := FND_API.g_miss_date;
x_evo_rec.REG_START_TIME            := FND_API.g_miss_date;
x_evo_rec.REG_END_DATE              := FND_API.g_miss_date;
x_evo_rec.REG_END_TIME              := FND_API.g_miss_date;
x_evo_rec.REG_MAXIMUM_CAPACITY      := FND_API.g_miss_num;
 x_evo_rec.REG_OVERBOOK_PCT          := FND_API.g_miss_num;
x_evo_rec.REG_EFFECTIVE_CAPACITY    := FND_API.g_miss_num;
x_evo_rec.REG_WAITLIST_PCT          := FND_API.g_miss_num;
x_evo_rec.REG_MINIMUM_CAPACITY      := FND_API.g_miss_num;
x_evo_rec.REG_MINIMUM_REQ_BY_DATE   := FND_API.g_miss_date;
x_evo_rec.INVENTORY_ITEM_ID        := FND_API.g_miss_num;
x_evo_rec.INVENTORY_ITEM            := FND_API.g_miss_char;
x_evo_rec.ORGANIZATION_ID         := FND_API.g_miss_num;
x_evo_rec.PRICELIST_HEADER_ID       := FND_API.g_miss_num;
x_evo_rec.PRICELIST_LINE_ID         := FND_API.g_miss_num;
x_evo_rec.ORG_ID                    := FND_API.g_miss_num;
x_evo_rec.WAITLIST_ACTION_TYPE_CODE := FND_API.g_miss_char;
x_evo_rec.STREAM_TYPE_CODE          := FND_API.g_miss_char;
x_evo_rec.OWNER_USER_ID             := FND_API.g_miss_num;
x_evo_rec.EVENT_FULL_FLAG           := FND_API.g_miss_char;
x_evo_rec.FORECASTED_REVENUE        := FND_API.g_miss_num;
x_evo_rec.ACTUAL_REVENUE            := FND_API.g_miss_num;
x_evo_rec.FORECASTED_COST           := FND_API.g_miss_num;
x_evo_rec.ACTUAL_COST               := FND_API.g_miss_num;
x_evo_rec.FUND_SOURCE_TYPE_CODE     := FND_API.g_miss_char;
x_evo_rec.FUND_SOURCE_ID            := FND_API.g_miss_num;
x_evo_rec.CERT_CREDIT_TYPE_CODE     := FND_API.g_miss_char;
x_evo_rec.CERTIFICATION_CREDITS     := FND_API.g_miss_num;
x_evo_rec.COORDINATOR_ID            := FND_API.g_miss_num;
x_evo_rec.PRIORITY_TYPE_CODE        := FND_API.g_miss_char;
x_evo_rec.CANCELLATION_REASON_CODE  := FND_API.g_miss_char;
x_evo_rec.AUTO_REGISTER_FLAG        := FND_API.g_miss_char;
x_evo_rec.EMAIL                  := FND_API.g_miss_char;
x_evo_rec.PHONE                     := FND_API.g_miss_char;
x_evo_rec.FUND_AMOUNT_TC            := FND_API.g_miss_num;
x_evo_rec.FUND_AMOUNT_FC            := FND_API.g_miss_num;
x_evo_rec.CURRENCY_CODE_TC          := FND_API.g_miss_char;
x_evo_rec.CURRENCY_CODE_FC          := FND_API.g_miss_char;
x_evo_rec.URL                       := FND_API.g_miss_char;
x_evo_rec.TIMEZONE_ID               := FND_API.g_miss_num;
x_evo_rec.EVENT_VENUE_ID           :=  FND_API.g_miss_num;
x_evo_rec.PRICELIST_HEADER_CURRENCY_CODE := FND_API.g_miss_char;
x_evo_rec.PRICELIST_LIST_PRICE      := FND_API.g_miss_num;
x_evo_rec.INBOUND_SCRIPT_NAME       := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE_CATEGORY        := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE1                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE2                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE3                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE4                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE5                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE6                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE7                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE8                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE9                := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE10               := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE11               := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE12               := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE13               := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE14               := FND_API.g_miss_char;
x_evo_rec.ATTRIBUTE15               := FND_API.g_miss_char;
x_evo_rec.EVENT_OFFER_NAME         := FND_API.g_miss_char;
x_evo_rec.EVENT_MKTG_MESSAGE         := FND_API.g_miss_char;
x_evo_rec.DESCRIPTION            := FND_API.g_miss_char;
x_evo_rec.CUSTOM_SETUP_ID         := FND_API.g_miss_num;
x_evo_rec.COUNTRY_CODE              := FND_API.g_miss_char;
x_evo_rec.BUSINESS_UNIT_ID          := FND_API.g_miss_num;
x_evo_rec.EVENT_CALENDAR            := FND_API.g_miss_char;
x_evo_rec.START_PERIOD_NAME         := FND_API.g_miss_char;
x_evo_rec.END_PERIOD_NAME           := FND_API.g_miss_char;
x_evo_rec.GLOBAL_FLAG               := FND_API.g_miss_char;
x_evo_rec.task_id := FND_API.g_miss_num;
x_evo_rec.parent_id := FND_API.g_miss_num;
x_evo_rec.parent_type := FND_API.g_miss_char;
x_evo_rec.CREATE_ATTENDANT_LEAD_FLAG := FND_API.g_miss_char; /*hornet*/
x_evo_rec.CREATE_REGISTRANT_LEAD_FLAG := FND_API.g_miss_char;/*hornet*/
x_evo_rec.event_object_type := FND_API.g_miss_char;/*hornet*/
x_evo_rec.REG_TIMEZONE_ID := FND_API.g_miss_num;  /*hornet */
x_evo_rec.event_password := FND_API.g_miss_char;/* Hornet : added for imeeting integration*/
x_evo_rec.record_event_flag := FND_API.g_miss_char; /* Hornet : added for imeeting integration*/
x_evo_rec.allow_register_in_middle_flag := FND_API.g_miss_char; /* Hornet : added for imeeting integration*/
x_evo_rec.publish_attendees_flag := FND_API.g_miss_char;/* Hornet : added for imeeting integration*/
x_evo_rec.direct_join_flag := FND_API.g_miss_char; /* Hornet : added for imeeting integration*/
x_evo_rec.event_notification_method := FND_API.g_miss_char; /* Hornet : added for imeeting integration*/
x_evo_rec.actual_start_time := FND_API.g_miss_date; /* Hornet : added for imeeting integration*/
x_evo_rec.actual_end_time := FND_API.g_miss_date;/* Hornet : added for imeeting integration*/
x_evo_rec.server_id := FND_API.g_miss_NUM;/* Hornet : added for imeeting integration*/
x_evo_rec.owner_fnd_user_id := FND_API.g_miss_NUM;/* Hornet : added for imeeting integration  aug13*/
x_evo_rec.meeting_dial_in_info := FND_API.g_miss_char;  /* Hornet : added for imeeting integration aug13*/
x_evo_rec.meeting_email_subject := FND_API.g_miss_char;  /* Hornet : added for imeeting integration  aug13*/
x_evo_rec.meeting_schedule_type := FND_API.g_miss_char;  /* Hornet : added for imeeting integration  aug13*/
x_evo_rec.meeting_status        := FND_API.g_miss_char;  /* Hornet : added for imeeting integration  aug13*/
x_evo_rec.meeting_misc_info     := FND_API.g_miss_char;  /* Hornet : added for imeeting integration  aug13*/
x_evo_rec.publish_flag          := FND_API.g_miss_char;  /* Hornet : added for imeeting integration  aug13*/
x_evo_rec.meeting_encryption_key_code := FND_API.g_miss_char;  /* Hornet : added for imeeting integration  aug13*/
x_evo_rec.number_of_attendees   := FND_API.g_miss_NUM;/* Hornet : added for imeeting integration  aug13*/
x_evo_rec.event_purpose_code := FND_API.g_miss_char;/* Hornet : added aug13*/
END init_evo_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    complete_evo_rec
--
-- HISTORY
--    11/23/1999  sugupta  Created.
--    01/27/2000  gdeodhar Added event_header_id copy to complete_rec.
--    01/27/2000  gdeodhar Added application_id copy to complete_rec.
---------------------------------------------------------------------
PROCEDURE complete_evo_rec(
   p_evo_rec       IN  evo_rec_type,
   x_complete_rec  OUT NOCOPY evo_rec_type
)
IS

   CURSOR c_evo IS
   SELECT *
     FROM ams_event_offers_vl
     WHERE event_offer_id = p_evo_rec.event_offer_id;

 CURSOR c_location(loc_id IN NUMBER) IS
   SELECT   city, state, country
   FROM     hz_locations
   WHERE    location_id = loc_id;

   l_evo_rec  c_evo%ROWTYPE;
   l_city       VARCHAR2(60);
   l_state       VARCHAR2(60);
   l_country    VARCHAR2(60);

BEGIN
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('complete_evo_rec :'|| p_evo_rec.event_offer_id);
END IF;

   x_complete_rec := p_evo_rec;

   OPEN c_evo;
   FETCH c_evo INTO l_evo_rec;
   IF c_evo%NOTFOUND THEN
      CLOSE c_evo;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c_evo;

   IF l_evo_rec.event_location_id IS NOT NULL THEN
      OPEN c_location(l_evo_rec.event_location_id);
      FETCH c_location INTO l_city, l_state, l_country;
      IF c_location%NOTFOUND THEN
         CLOSE c_location;
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
      CLOSE c_location;
    END IF;

   -- This procedure should complete the record by going through all the items in the incoming record.
  -- adding code to complete setup_type_id ( custom_setup_id in evo_rec)
   IF p_evo_rec.custom_setup_id = FND_API.g_miss_num THEN
      x_complete_rec.custom_setup_id := l_evo_rec.setup_type_id;
   END IF;

   IF p_evo_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_evo_rec.created_by;
   END IF;

   IF p_evo_rec.event_level = FND_API.g_miss_char THEN
      x_complete_rec.event_level := l_evo_rec.event_level;
   END IF;

   IF p_evo_rec.event_type_code = FND_API.g_miss_char THEN
      x_complete_rec.event_type_code := l_evo_rec.event_type_code;
   END IF;

   IF p_evo_rec.active_flag = FND_API.g_miss_char THEN
      x_complete_rec.active_flag := l_evo_rec.active_flag;
   END IF;

   IF p_evo_rec.private_flag = FND_API.g_miss_char THEN
      x_complete_rec.private_flag := l_evo_rec.private_flag;
   END IF;

   IF p_evo_rec.user_status_id = FND_API.g_miss_num THEN
      x_complete_rec.user_status_id := l_evo_rec.user_status_id;
   END IF;
--   IF p_evo_rec.event_delivery_method_code = FND_API.g_miss_char THEN
--      x_complete_rec.event_delivery_method_code := l_evo_rec.event_delivery_method_code;
--   END IF;

   if p_evo_rec.event_required_flag = fnd_api.g_miss_char then
      x_complete_rec.event_required_flag := l_evo_rec.event_required_flag;
   END IF;
   if p_evo_rec.event_language_code = fnd_api.g_miss_char then
      x_complete_rec.event_language_code := l_evo_rec.event_language_code;
   END IF;

   if p_evo_rec.event_location_id = fnd_api.g_miss_num then
      x_complete_rec.event_location_id := l_evo_rec.event_location_id;
   end if;
   IF p_evo_rec.system_status_code = FND_API.g_miss_char THEN
      x_complete_rec.system_status_code := l_evo_rec.system_status_code;
   END IF;

--IF p_evo_rec.last_status_date = FND_API.g_miss_date THEN
--   x_complete_rec.last_status_date := l_evo_rec.last_status_date;
--END IF;

   IF p_evo_rec.last_status_date = FND_API.g_miss_date
      OR p_evo_rec.last_status_date IS NULL
   THEN
      IF p_evo_rec.user_status_id = l_evo_rec.user_status_id THEN
      -- no status change, set it to be the original value
         x_complete_rec.last_status_date := l_evo_rec.last_status_date;
      ELSE
      -- status changed, set it to be SYSDATE
         x_complete_rec.last_status_date := SYSDATE;
      END IF;
   END IF;

   IF p_evo_rec.stream_type_code = FND_API.g_miss_char THEN
      x_complete_rec.stream_type_code := l_evo_rec.stream_type_code;
   END IF;

   IF p_evo_rec.source_code = FND_API.g_miss_char THEN
      x_complete_rec.source_code := l_evo_rec.source_code;
   END IF;

   IF p_evo_rec.event_standalone_flag = FND_API.g_miss_char THEN
      x_complete_rec.event_standalone_flag := l_evo_rec.event_standalone_flag;
   END IF;
   if p_evo_rec.reg_frozen_flag = fnd_api.g_miss_char then
      x_complete_rec.reg_frozen_flag := l_evo_rec.reg_frozen_flag;
   END IF;
   IF p_evo_rec.reg_required_flag = FND_API.g_miss_char THEN
      x_complete_rec.reg_required_flag := l_evo_rec.reg_required_flag;
   END IF;
   if p_evo_rec.reg_waitlist_allowed_flag = fnd_api.g_miss_char then
      x_complete_rec.reg_waitlist_allowed_flag := l_evo_rec.reg_waitlist_allowed_flag;
   END IF;
   if p_evo_rec.reg_overbook_allowed_flag = fnd_api.g_miss_char then
      x_complete_rec.reg_overbook_allowed_flag := l_evo_rec.reg_overbook_allowed_flag;
   END IF;
   IF p_evo_rec.reg_charge_flag = FND_API.g_miss_char THEN
      x_complete_rec.reg_charge_flag := l_evo_rec.reg_charge_flag;
   END IF;

   IF p_evo_rec.reg_invited_only_flag = FND_API.g_miss_char THEN
      x_complete_rec.reg_invited_only_flag := l_evo_rec.reg_invited_only_flag;
   END IF;

   IF p_evo_rec.partner_flag = FND_API.g_miss_char THEN
      x_complete_rec.partner_flag := l_evo_rec.partner_flag;
   END IF;
   IF p_evo_rec.overflow_flag = FND_API.g_miss_char THEN
      x_complete_rec.overflow_flag := l_evo_rec.overflow_flag;
   END IF;
   IF p_evo_rec.parent_event_offer_id = FND_API.g_miss_num THEN
      x_complete_rec.parent_event_offer_id := l_evo_rec.parent_event_offer_id;
   END IF;

   IF p_evo_rec.event_duration = FND_API.g_miss_num THEN
      x_complete_rec.event_duration := l_evo_rec.event_duration;
   END IF;

   IF p_evo_rec.event_duration_uom_code = FND_API.g_miss_char THEN
      x_complete_rec.event_duration_uom_code := l_evo_rec.event_duration_uom_code;
   END IF;

   IF p_evo_rec.event_start_date = FND_API.g_miss_date THEN
      x_complete_rec.event_start_date := l_evo_rec.event_start_date;
   END IF;
   if p_evo_rec.event_start_date_time = fnd_api.g_miss_date then
      x_complete_rec.event_start_date_time := l_evo_rec.event_start_date_time;
   END IF;
   if p_evo_rec.event_end_date = fnd_api.g_miss_date then
      x_complete_rec.event_end_date    := l_evo_rec.event_end_date;
   END IF;
   if p_evo_rec.event_end_date_time = fnd_api.g_miss_date then
      x_complete_rec.event_end_date_time    := l_evo_rec.event_end_date_time;
   end if;
   IF p_evo_rec.REG_START_DATE = FND_API.g_miss_date THEN
      x_complete_rec.REG_START_DATE := l_evo_rec.REG_START_DATE;
   END IF;
   if p_evo_rec.REG_START_TIME = fnd_api.g_miss_date then
      x_complete_rec.REG_START_TIME := l_evo_rec.REG_START_TIME;
   END IF;
   if p_evo_rec.REG_END_DATE = fnd_api.g_miss_date then
      x_complete_rec.REG_END_DATE    := l_evo_rec.REG_END_DATE;
   END IF;
   if p_evo_rec.REG_END_TIME = fnd_api.g_miss_date then
      x_complete_rec.REG_END_TIME    := l_evo_rec.REG_END_TIME;
   end if;
   IF p_evo_rec.reg_maximum_capacity = FND_API.g_miss_num THEN
      x_complete_rec.reg_maximum_capacity := l_evo_rec.reg_maximum_capacity;
   END IF;

   IF p_evo_rec.reg_minimum_capacity = FND_API.g_miss_num THEN
      x_complete_rec.reg_minimum_capacity := l_evo_rec.reg_minimum_capacity;
   END IF;
  IF p_evo_rec.REG_OVERBOOK_PCT = FND_API.g_miss_num THEN
      x_complete_rec.REG_OVERBOOK_PCT := l_evo_rec.REG_OVERBOOK_PCT;
   END IF;
  IF p_evo_rec.REG_EFFECTIVE_CAPACITY = FND_API.g_miss_num THEN
      x_complete_rec.REG_EFFECTIVE_CAPACITY := l_evo_rec.REG_EFFECTIVE_CAPACITY;
   END IF;
    IF p_evo_rec.REG_WAITLIST_PCT = FND_API.g_miss_num THEN
      x_complete_rec.REG_WAITLIST_PCT := l_evo_rec.REG_WAITLIST_PCT;
   END IF;
   IF p_evo_rec.REG_MINIMUM_REQ_BY_DATE = FND_API.g_miss_date THEN
      x_complete_rec.REG_MINIMUM_REQ_BY_DATE := l_evo_rec.REG_MINIMUM_REQ_BY_DATE;
   END IF;
   IF p_evo_rec.event_language_code = FND_API.g_miss_char THEN
      x_complete_rec.event_language_code := l_evo_rec.event_language_code;
   END IF;

   IF p_evo_rec.cert_credit_type_code = FND_API.g_miss_char THEN
      x_complete_rec.cert_credit_type_code := l_evo_rec.cert_credit_type_code;
   END IF;

   IF p_evo_rec.certification_credits = FND_API.g_miss_num THEN
      x_complete_rec.certification_credits := l_evo_rec.certification_credits;
   END IF;

   IF p_evo_rec.inventory_item_id = FND_API.g_miss_num THEN
      x_complete_rec.inventory_item_id := l_evo_rec.inventory_item_id;
   END IF;
   IF p_evo_rec.organization_id = fnd_api.g_miss_num then
      x_complete_rec.organization_id := l_evo_rec.organization_id;
   END IF;
      IF p_evo_rec.PRICELIST_LINE_ID = FND_API.g_miss_num THEN
      x_complete_rec.PRICELIST_LINE_ID := l_evo_rec.PRICELIST_LINE_ID;
   END IF;
      IF p_evo_rec.PRICELIST_HEADER_ID = FND_API.g_miss_num THEN
      x_complete_rec.PRICELIST_HEADER_ID := l_evo_rec.PRICELIST_HEADER_ID;
   END IF;
   IF p_evo_rec.WAITLIST_ACTION_TYPE_CODE = FND_API.g_miss_char THEN
      x_complete_rec.WAITLIST_ACTION_TYPE_CODE := l_evo_rec.WAITLIST_ACTION_TYPE_CODE;
   END IF;
   IF p_evo_rec.EVENT_FULL_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.EVENT_FULL_FLAG := l_evo_rec.EVENT_FULL_FLAG;
   END IF;
   IF p_evo_rec.AUTO_REGISTER_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.AUTO_REGISTER_FLAG := l_evo_rec.AUTO_REGISTER_FLAG;
   END IF;
   IF p_evo_rec.forecasted_revenue = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_revenue := l_evo_rec.forecasted_revenue;
   END IF;

   IF p_evo_rec.actual_revenue = FND_API.g_miss_num THEN
      x_complete_rec.actual_revenue := l_evo_rec.actual_revenue;
   END IF;

   IF p_evo_rec.forecasted_cost = FND_API.g_miss_num THEN
      x_complete_rec.forecasted_cost := l_evo_rec.forecasted_cost;
   END IF;

   IF p_evo_rec.actual_cost = FND_API.g_miss_num THEN
      x_complete_rec.actual_cost := l_evo_rec.actual_cost;
   END IF;

   IF p_evo_rec.coordinator_id = FND_API.g_miss_num THEN
      x_complete_rec.coordinator_id := l_evo_rec.coordinator_id;
   END IF;

   IF p_evo_rec.fund_source_type_code = FND_API.g_miss_char THEN
      x_complete_rec.fund_source_type_code := l_evo_rec.fund_source_type_code;
   END IF;

   IF p_evo_rec.fund_source_id = FND_API.g_miss_num THEN
      x_complete_rec.fund_source_id := l_evo_rec.fund_source_id;
   END IF;

   IF p_evo_rec.owner_user_id = FND_API.g_miss_num THEN
      x_complete_rec.owner_user_id := l_evo_rec.owner_user_id;
   END IF;

   IF p_evo_rec.url = FND_API.g_miss_char THEN
      x_complete_rec.url := l_evo_rec.url;
   END IF;

   IF p_evo_rec.email = FND_API.g_miss_char THEN
      x_complete_rec.email := l_evo_rec.email;
   END IF;

   IF p_evo_rec.phone = FND_API.g_miss_char THEN
      x_complete_rec.phone := l_evo_rec.phone;
   END IF;

   IF p_evo_rec.fund_amount_tc = FND_API.g_miss_num THEN
      x_complete_rec.fund_amount_tc := l_evo_rec.fund_amount_tc;
   END IF;

   IF p_evo_rec.fund_amount_fc = FND_API.g_miss_num THEN
      x_complete_rec.fund_amount_fc := l_evo_rec.fund_amount_fc;
   END IF;

   IF p_evo_rec.currency_code_tc = FND_API.g_miss_char THEN
      x_complete_rec.currency_code_tc := l_evo_rec.currency_code_tc;
   END IF;

   IF p_evo_rec.currency_code_fc = FND_API.g_miss_char THEN
      x_complete_rec.currency_code_fc := l_evo_rec.currency_code_fc;
   END IF;

   IF p_evo_rec.TIMEZONE_ID = FND_API.g_miss_num THEN
      x_complete_rec.TIMEZONE_ID := l_evo_rec.TIMEZONE_ID;
   END IF;
   IF p_evo_rec.event_venue_id = FND_API.g_miss_num THEN
      x_complete_rec.event_venue_id := l_evo_rec.event_venue_id;
   END IF;
   IF p_evo_rec.priority_type_code = FND_API.g_miss_char THEN
      x_complete_rec.priority_type_code := l_evo_rec.priority_type_code;
   END IF;

   IF p_evo_rec.cancellation_reason_code = FND_API.g_miss_char THEN
      x_complete_rec.cancellation_reason_code := l_evo_rec.cancellation_reason_code;
   END IF;

   IF p_evo_rec.inbound_script_name = FND_API.g_miss_char THEN
      x_complete_rec.inbound_script_name := l_evo_rec.inbound_script_name;
   END IF;

   IF p_evo_rec.attribute_category = FND_API.g_miss_char THEN
      x_complete_rec.attribute_category := l_evo_rec.attribute_category;
   END IF;

   IF p_evo_rec.attribute1 = FND_API.g_miss_char THEN
      x_complete_rec.attribute1 := l_evo_rec.attribute1;
   END IF;

   IF p_evo_rec.attribute2 = FND_API.g_miss_char THEN
      x_complete_rec.attribute2 := l_evo_rec.attribute2;
   END IF;

   IF p_evo_rec.attribute3 = FND_API.g_miss_char THEN
      x_complete_rec.attribute3 := l_evo_rec.attribute3;
   END IF;

   IF p_evo_rec.attribute4 = FND_API.g_miss_char THEN
      x_complete_rec.attribute4 := l_evo_rec.attribute4;
   END IF;

   IF p_evo_rec.attribute5 = FND_API.g_miss_char THEN
      x_complete_rec.attribute5 := l_evo_rec.attribute5;
   END IF;

   IF p_evo_rec.attribute6 = FND_API.g_miss_char THEN
      x_complete_rec.attribute6 := l_evo_rec.attribute6;
   END IF;

   IF p_evo_rec.attribute7 = FND_API.g_miss_char THEN
      x_complete_rec.attribute7 := l_evo_rec.attribute7;
   END IF;

   IF p_evo_rec.attribute8 = FND_API.g_miss_char THEN
      x_complete_rec.attribute8 := l_evo_rec.attribute8;
   END IF;

   IF p_evo_rec.attribute9 = FND_API.g_miss_char THEN
      x_complete_rec.attribute9 := l_evo_rec.attribute9;
   END IF;

   IF p_evo_rec.attribute10 = FND_API.g_miss_char THEN
      x_complete_rec.attribute10 := l_evo_rec.attribute10;
   END IF;

   IF p_evo_rec.attribute11 = FND_API.g_miss_char THEN
      x_complete_rec.attribute11 := l_evo_rec.attribute11;
   END IF;

   IF p_evo_rec.attribute12 = FND_API.g_miss_char THEN
      x_complete_rec.attribute12 := l_evo_rec.attribute12;
   END IF;

   IF p_evo_rec.attribute13 = FND_API.g_miss_char THEN
      x_complete_rec.attribute13 := l_evo_rec.attribute13;
   END IF;

   IF p_evo_rec.attribute14 = FND_API.g_miss_char THEN
      x_complete_rec.attribute14 := l_evo_rec.attribute14;
   END IF;

   IF p_evo_rec.attribute15 = FND_API.g_miss_char THEN
      x_complete_rec.attribute15 := l_evo_rec.attribute15;
   END IF;

   IF p_evo_rec.event_offer_name = FND_API.g_miss_char THEN
      x_complete_rec.event_offer_name := l_evo_rec.event_offer_name;
   END IF;

   IF p_evo_rec.event_mktg_message = FND_API.g_miss_char THEN
      x_complete_rec.event_mktg_message := l_evo_rec.event_mktg_message;
   END IF;

   IF p_evo_rec.description = FND_API.g_miss_char THEN
      x_complete_rec.description := l_evo_rec.description;
   END IF;

   -- gdeodhar : Added the following. As when we update the event offer agenda
   -- records, we may not pass the event_header_id.
   IF p_evo_rec.event_header_id = FND_API.g_miss_num THEN
      x_complete_rec.event_header_id := l_evo_rec.event_header_id;
   END IF;
   -- gdeodhar. Added the following.
   IF p_evo_rec.application_id = FND_API.g_miss_num THEN
      x_complete_rec.application_id := l_evo_rec.application_id;
   END IF;

   -- gdeodhar : added the following to support the new fields.
   IF p_evo_rec.country_code = FND_API.g_miss_char THEN
      x_complete_rec.country_code := l_evo_rec.country_code;
   END IF;
   -- added by murali for location
   IF p_evo_rec.country = FND_API.g_miss_char THEN
      x_complete_rec.country := l_country;
   END IF;
   IF p_evo_rec.city = FND_API.g_miss_char THEN
      x_complete_rec.city := l_city;
   END IF;
   IF p_evo_rec.state = FND_API.g_miss_char THEN
      x_complete_rec.state := l_state;
   END IF;

   IF p_evo_rec.business_unit_id = FND_API.g_miss_num THEN
      x_complete_rec.business_unit_id := l_evo_rec.business_unit_id;
   END IF;
 -- sugupta added calendar fields
   IF p_evo_rec.event_calendar = FND_API.g_miss_char THEN
      x_complete_rec.event_calendar := FND_PROFILE.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
   END IF;

   IF p_evo_rec.start_period_name = FND_API.g_miss_char THEN
      x_complete_rec.start_period_name := l_evo_rec.start_period_name;
   END IF;

   IF p_evo_rec.end_period_name = FND_API.g_miss_char THEN
      x_complete_rec.end_period_name := l_evo_rec.end_period_name;
   END IF;

   IF p_evo_rec.global_flag = FND_API.g_miss_char THEN
      x_complete_rec.global_flag := l_evo_rec.global_flag;
   END IF;

   IF p_evo_rec.task_id = FND_API.g_miss_num THEN
      x_complete_rec.task_id := l_evo_rec.task_id;
   END IF;
      IF p_evo_rec.parent_id = FND_API.g_miss_num THEN
      x_complete_rec.parent_id := l_evo_rec.parent_id;
   END IF;
      IF p_evo_rec.parent_type = FND_API.g_miss_char THEN
      x_complete_rec.parent_type := l_evo_rec.parent_type;
   END IF;
      IF p_evo_rec.CREATE_ATTENDANT_LEAD_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.CREATE_ATTENDANT_LEAD_FLAG := l_evo_rec.CREATE_ATTENDANT_LEAD_FLAG;
   END IF;
      IF p_evo_rec.CREATE_REGISTRANT_LEAD_FLAG = FND_API.g_miss_char THEN
      x_complete_rec.CREATE_REGISTRANT_LEAD_FLAG := l_evo_rec.CREATE_REGISTRANT_LEAD_FLAG;
   END IF;
      IF p_evo_rec.event_object_type = FND_API.g_miss_char THEN
      x_complete_rec.event_object_type := l_evo_rec.event_object_type;
   END IF;
   IF p_evo_rec.REG_TIMEZONE_ID = FND_API.g_miss_num THEN
      x_complete_rec.REG_TIMEZONE_ID := l_evo_rec.REG_TIMEZONE_ID;
   END IF;

   IF p_evo_rec.event_password = FND_API.g_miss_char THEN
      x_complete_rec.event_password := l_evo_rec.event_password;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.record_event_flag = FND_API.g_miss_char THEN
      x_complete_rec.record_event_flag := l_evo_rec.record_event_flag;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.allow_register_in_middle_flag = FND_API.g_miss_char THEN
      x_complete_rec.allow_register_in_middle_flag := l_evo_rec.allow_register_in_middle_flag;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.publish_attendees_flag = FND_API.g_miss_char THEN
      x_complete_rec.publish_attendees_flag := l_evo_rec.publish_attendees_flag;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.direct_join_flag = FND_API.g_miss_char THEN
      x_complete_rec.direct_join_flag := l_evo_rec.direct_join_flag;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.event_notification_method = FND_API.g_miss_char THEN
      x_complete_rec.event_notification_method := l_evo_rec.event_notification_method;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.actual_start_time = FND_API.g_miss_date THEN
      x_complete_rec.actual_start_time := l_evo_rec.actual_start_time;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.actual_end_time = FND_API.g_miss_date THEN
      x_complete_rec.actual_end_time := l_evo_rec.actual_end_time;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.server_id = FND_API.g_miss_num THEN
      x_complete_rec.server_id := l_evo_rec.server_id;/* Hornet : added for imeeting integration*/
   END IF;

   IF p_evo_rec.owner_fnd_user_id = FND_API.g_miss_NUM THEN
   x_complete_rec.owner_fnd_user_id := l_evo_rec.owner_fnd_user_id;/* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.meeting_dial_in_info = FND_API.g_miss_char THEN
      x_complete_rec.meeting_dial_in_info := l_evo_rec.meeting_dial_in_info;  /* Hornet : added for imeeting integration aug13*/
   END IF;
   IF p_evo_rec.meeting_email_subject = FND_API.g_miss_char THEN
      x_complete_rec.meeting_email_subject := l_evo_rec.meeting_email_subject;  /* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.meeting_schedule_type = FND_API.g_miss_char  THEN
      x_complete_rec.meeting_schedule_type := l_evo_rec.meeting_schedule_type;  /* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.meeting_status = FND_API.g_miss_char  THEN
      x_complete_rec.meeting_status := l_evo_rec.meeting_status;  /* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.meeting_misc_info = FND_API.g_miss_char  THEN
      x_complete_rec.meeting_misc_info := l_evo_rec.meeting_misc_info;  /* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.publish_flag   = FND_API.g_miss_char  THEN
      x_complete_rec.publish_flag := l_evo_rec.publish_flag;  /* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.meeting_encryption_key_code = FND_API.g_miss_char  THEN
      x_complete_rec.meeting_encryption_key_code := l_evo_rec.meeting_encryption_key_code;  /* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.number_of_attendees   = FND_API.g_miss_NUM  THEN
      x_complete_rec.number_of_attendees := l_evo_rec.number_of_attendees;/* Hornet : added for imeeting integration  aug13*/
   END IF;
   IF p_evo_rec.event_purpose_code = FND_API.g_miss_char  THEN
      x_complete_rec.event_purpose_code := l_evo_rec.event_purpose_code;  /* Hornet : added  aug13*/
   END IF;

END complete_evo_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    create_inv_item
--
-- HISTORY
--    03/04/2000  sugupta  Create.
--    07/07/2000  sugupta  modified Bug 1346165- Added Exception code to print out
--                           an error message if inv api call returns err status
---------------------------------------------------------------------
PROCEDURE create_inv_item
(
  p_commit              IN  VARCHAR2 := FND_API.g_false,
  p_inv_item_number     IN  VARCHAR2,
  p_inv_item_desc       IN  VARCHAR2,
  p_inv_long_desc      IN  VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  x_item_id          OUT NOCOPY NUMBER,
  x_org_id          OUT NOCOPY NUMBER
)
IS
   l_api_name           CONSTANT VARCHAR2(30) := 'create_inv_item';
   l_full_name          CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_commit             VARCHAR2(1);
   l_validation_level   NUMBER;
   l_return_status      VARCHAR2(1);
   l_msg_count          NUMBER;
   l_item_rec           INV_Item_GRP.Item_rec_type;
   x_item_rec           INV_Item_GRP.Item_rec_type;
   x_error_tbl          INV_Item_GRP.Error_tbl_type;
   inv_item_creation_error  EXCEPTION;
   l_err_txt         VARCHAR2(4000);

BEGIN

   null;

/*
--DBMS_OUTPUT.put_line('calling INV_Item_GRP.Create_Item...');
   x_return_status := FND_API.g_ret_sts_success;

   l_commit := p_commit;
   l_validation_level := fnd_api.g_VALID_LEVEL_FULL;
   l_item_rec.SEGMENT1 := p_inv_item_number;
   l_item_rec.ORGANIZATION_ID := FND_PROFILE.Value('AMS_ITEM_ORGANIZATION_ID');
--204;
   l_item_rec.DESCRIPTION := p_inv_item_desc;
   l_item_rec.LONG_DESCRIPTION := p_inv_long_desc;
   l_item_rec.event_flag := 'Y';
   l_item_rec.ORDERABLE_ON_WEB_FLAG := 'Y';
   l_item_rec.CUSTOMER_ORDER_FLAG := 'Y';
   l_item_rec.CUSTOMER_ORDER_ENABLED_FLAG := 'Y';
   l_item_rec.web_status := 'PUBLISHED';

    INV_Item_GRP.Create_Item
    (
         l_commit
        ,l_validation_level
        ,l_item_rec
        ,x_item_rec
        ,l_return_status
        ,x_error_tbl
    );

   x_item_id := x_item_rec.inventory_item_id;
    x_org_id  := x_item_rec.ORGANIZATION_ID;

    x_return_status := l_return_status;

 --  DBMS_OUTPUT.put_line('***********************************');
 --  DBMS_OUTPUT.put_line('Return status = ' || x_return_status);
 --  DBMS_OUTPUT.put_line('***********************************');

   FOR i IN 1 .. x_error_tbl.count LOOP
   --    DBMS_OUTPUT.put_line('i = ' || i);
   --    DBMS_OUTPUT.put_line('Return err name = ' || x_error_tbl(i).message_name);
   --    DBMS_OUTPUT.put_line('Return err msg = ' || x_error_tbl(i).message_text);
   --    DBMS_OUTPUT.put_line('Return err table = ' || x_error_tbl(i).table_name);
   --    DBMS_OUTPUT.put_line('Return err column = ' || x_error_tbl(i).column_name);
    --   DBMS_OUTPUT.put_line('Return err org_id = ' || x_error_tbl(i).organization_id);
   --    DBMS_OUTPUT.put_line('***********************************');
   NULL;
   END LOOP;


    IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE inv_item_creation_error;
    END IF;

EXCEPTION

--   WHEN OTHERS THEN
--    NULL;
 --DBMS_OUTPUT.put_line('-- caught here');

   WHEN inv_item_creation_error THEN
      --x_return_status := FND_API.g_ret_sts_error;
      --l_msg_count := x_error_tbl.count;
      FOR i IN 1 .. x_error_tbl.count LOOP
      l_err_txt := l_err_txt || x_error_tbl(i).message_text;
     END LOOP;
     FND_MSG_PUB.add_exc_msg(p_error_text => l_err_txt);
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => x_msg_count,
                p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      --x_return_status := FND_API.g_ret_sts_unexp_error ;
      l_msg_count := x_error_tbl.count;
      FOR i IN 1 .. x_error_tbl.count LOOP
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => l_msg_count,
                p_data    => x_error_tbl(i).message_text
          );
      END LOOP;

   WHEN OTHERS THEN
     -- x_return_status := FND_API.g_ret_sts_unexp_error;
      l_msg_count := x_error_tbl.count;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FOR i IN 1 .. x_error_tbl.count LOOP
          FND_MSG_PUB.count_and_get(
                p_encoded => FND_API.g_false,
                p_count   => l_msg_count,
                p_data    => x_msg_data
          );
      END LOOP;

   */

END create_inv_item;

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_header
--
-- HISTORY
--    03/04/2000  sugupta  Create.
--    05/17/2000  sugupta  modified
---------------------------------------------------------------------

PROCEDURE create_pricelist_header
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_evo_rec               IN  evo_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_header_id     OUT NOCOPY NUMBER
)

IS
   l_api_version            CONSTANT NUMBER       := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'create_pricelist_header';
   l_full_name              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

   p_price_list_rec         qp_price_list_pub.price_list_rec_type;
   p_price_list_val_rec      qp_price_list_pub.price_list_val_rec_type;
   p_price_list_line_tbl          qp_price_list_pub.price_list_line_tbl_type;
   p_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   p_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   p_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   p_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   p_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

   l_price_list_rec         qp_price_list_pub.price_list_rec_type;
   l_price_list_val_rec      qp_price_list_pub.price_list_val_rec_type;
   l_price_list_line_tbl          qp_price_list_pub.price_list_line_tbl_type;
   l_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   l_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   l_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   l_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

BEGIN

   -- dbms_output.put_line('create List header called');
   x_return_status := FND_API.g_ret_sts_success;
-- todo- get Header name from profile option AMS_PRICELIST_HEADER_NAME
   p_price_list_rec.name := FND_PROFILE.value('AMS_PRICELIST_HEADER_NAME');
   --'Event Registration Pricing';
   p_price_list_rec.created_by := p_evo_rec.owner_user_id;
   p_price_list_rec.creation_date := sysdate;
   p_price_list_rec.currency_code := p_evo_rec.pricelist_header_currency_code;
   p_price_list_rec.list_type_code := 'PRL';
  p_price_list_rec.description := 'Event Registration Pricing';
  p_price_list_rec.start_date_active := p_evo_rec.event_start_date;
  p_price_list_rec.end_date_active := p_evo_rec.event_end_date;
  p_price_list_rec.operation :=QP_GLOBALS.G_OPR_CREATE;

  --p_price_list_rec.active_flag := 'Y';
 -- p_price_list_rec.automatic_flag := 'Y';


   IF (AMS_DEBUG_HIGH_ON) THEN





       AMS_Utility_PVT.debug_message(l_full_name ||': create pricelist header...');


   END IF;

   QP_PRICE_LIST_PUB.Process_Price_List(
           p_api_version_number      => 1.0,
           p_init_msg_list           => FND_API.G_TRUE,
           p_return_values           => FND_API.G_TRUE,
           p_commit                  => FND_API.G_TRUE,
           x_return_status           => l_return_status,
           x_msg_count               => l_msg_count,
           x_msg_data                => l_msg_data,
         p_PRICE_LIST_rec         => p_price_list_rec,
         p_PRICE_LIST_val_rec        => p_PRICE_LIST_val_rec,
         p_PRICE_LIST_LINE_tbl       => p_PRICE_LIST_LINE_tbl ,
         p_PRICE_LIST_LINE_val_tbl   => p_PRICE_LIST_LINE_val_tbl  ,
         p_QUALIFIERS_tbl            => p_QUALIFIERS_tbl,
         p_QUALIFIERS_val_tbl        => p_QUALIFIERS_val_tbl,
         p_PRICING_ATTR_tbl          => p_PRICING_ATTR_tbl,
         p_PRICING_ATTR_val_tbl      => p_PRICING_ATTR_val_tbl,
         x_PRICE_LIST_rec            => l_PRICE_LIST_rec,
         x_PRICE_LIST_val_rec        => l_PRICE_LIST_val_rec,
         x_PRICE_LIST_LINE_tbl       => l_PRICE_LIST_LINE_tbl ,
         x_PRICE_LIST_LINE_val_tbl   => l_PRICE_LIST_LINE_val_tbl  ,
         x_QUALIFIERS_tbl            => l_QUALIFIERS_tbl,
         x_QUALIFIERS_val_tbl        => l_QUALIFIERS_val_tbl,
         x_PRICING_ATTR_tbl          => l_PRICING_ATTR_tbl,
         x_PRICING_ATTR_val_tbl      => l_PRICING_ATTR_val_tbl
   );

   x_pricelist_header_id := l_PRICE_LIST_rec.list_header_id;
    x_return_status := l_return_status;

   -- dbms_output.put_line('The value of x_pricelist_header_id is ' || x_pricelist_header_id);


   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_pricelist_header;

---------------------------------------------------------------------
-- PROCEDURE
--    create_pricelist_line
--
-- HISTORY
--    03/04/2000  sugupta  Create.
--    05/17/2000  sugupta   modifed
---------------------------------------------------------------------

PROCEDURE create_pricelist_line
(
  p_api_version             IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.g_false,
  p_return_values           IN  VARCHAR2 := FND_API.g_false,
  p_commit                  IN  VARCHAR2 := FND_API.g_false,
  p_price_hdr_id            IN  NUMBER,
  p_evo_rec               IN   evo_rec_type,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  x_pricelist_line_id       OUT NOCOPY NUMBER
)
IS
   l_api_version            CONSTANT NUMBER       := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'create_pricelist_line';
   l_full_name              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status          VARCHAR2(1);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

   p_price_list_rec         qp_price_list_pub.price_list_rec_type;
   p_price_list_val_rec      qp_price_list_pub.price_list_val_rec_type;
   p_price_list_line_tbl          qp_price_list_pub.price_list_line_tbl_type;
   p_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   p_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   p_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   p_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   p_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

   l_price_list_rec         qp_price_list_pub.price_list_rec_type;
   l_price_list_val_rec      qp_price_list_pub.price_list_val_rec_type;
   l_price_list_line_tbl          qp_price_list_pub.price_list_line_tbl_type;
   l_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;
   l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
   l_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;
   l_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
   l_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;

BEGIN

   --dbms_output.put_line('create List line called');
   x_return_status := FND_API.g_ret_sts_success;

   p_price_list_line_tbl(1).list_header_id := p_price_hdr_id;
   --dbms_output.put_line('p_price_hdr_id: '||p_price_hdr_id);
   p_price_list_line_tbl(1).list_line_type_code := 'PLL';
   p_price_list_line_tbl(1).base_uom_code := 'EA';
   p_price_list_line_tbl(1).created_by := p_evo_rec.owner_user_id;
   p_price_list_line_tbl(1).inventory_item_id := p_evo_rec.inventory_item_id;
   p_price_list_line_tbl(1).start_date_active := p_evo_rec.event_start_date;
   p_price_list_line_tbl(1).end_date_active := p_evo_rec.event_end_date;
   p_price_list_line_tbl(1).organization_id := p_evo_rec.organization_id;
   p_price_list_line_tbl(1).operation :=QP_GLOBALS.G_OPR_CREATE;
   --p_price_list_line_tbl(1).automatic_flag := 'Y';
   -- modified sugupta 4th of July 2000
   if p_evo_rec.PRICELIST_LIST_PRICE is NULL or p_evo_rec.PRICELIST_LIST_PRICE = FND_API.g_miss_num then
      p_price_list_line_tbl(1).operand := 0;
   else
      p_price_list_line_tbl(1).operand := p_evo_rec.PRICELIST_LIST_PRICE;
   end if;

    p_price_list_line_tbl(1).arithmetic_operator := 'UNIT_PRICE';
   /* as per pricing team, usage of list_price column and percent_price column is obsolete.
   if p_evo_rec.PRICELIST_LIST_PRICE is NULL or p_evo_rec.PRICELIST_LIST_PRICE = FND_API.g_miss_num then
      p_price_list_line_tbl(1).list_price := 0;
   else
      p_price_list_line_tbl(1).list_price := p_evo_rec.PRICELIST_LIST_PRICE;
   end if;
*/
-- modified sugupta 06/21/2000 added code to populate pricing attributes tbl

   p_pricing_attr_tbl(1).product_attribute_context:= 'ITEM';
   p_pricing_attr_tbl(1).product_attribute:= 'PRICING_ATTRIBUTE1';
   p_pricing_attr_tbl(1).product_attr_value:= p_evo_rec.inventory_item_id;
   p_pricing_attr_tbl(1).product_uom_code:= 'Ea';
   p_pricing_attr_tbl(1).excluder_flag:= 'N';
   p_pricing_attr_tbl(1).comparison_operator_code:= '=';
   p_pricing_attr_tbl(1).PRICE_LIST_LINE_index :=1;
   p_pricing_attr_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;

   IF (AMS_DEBUG_HIGH_ON) THEN



       AMS_Utility_PVT.debug_message(l_full_name ||': create pricelist line...');

   END IF;

   QP_PRICE_LIST_PUB.Process_Price_List(
           p_api_version_number      => 1.0,
           p_init_msg_list           => FND_API.G_TRUE,
           p_return_values           => FND_API.G_TRUE,
           p_commit                  => FND_API.G_TRUE,
           x_return_status           => l_return_status,
           x_msg_count               => l_msg_count,
           x_msg_data                => l_msg_data,
         p_PRICE_LIST_rec         => p_price_list_rec,
         p_PRICE_LIST_val_rec        => p_PRICE_LIST_val_rec,
         p_PRICE_LIST_LINE_tbl       => p_PRICE_LIST_LINE_tbl ,
         p_PRICE_LIST_LINE_val_tbl   => p_PRICE_LIST_LINE_val_tbl  ,
         p_QUALIFIERS_tbl            => p_QUALIFIERS_tbl,
         p_QUALIFIERS_val_tbl        => p_QUALIFIERS_val_tbl,
         p_PRICING_ATTR_tbl          => p_PRICING_ATTR_tbl,
         p_PRICING_ATTR_val_tbl      => p_PRICING_ATTR_val_tbl,
         x_PRICE_LIST_rec            => l_PRICE_LIST_rec,
         x_PRICE_LIST_val_rec        => l_PRICE_LIST_val_rec,
         x_PRICE_LIST_LINE_tbl       => l_PRICE_LIST_LINE_tbl ,
         x_PRICE_LIST_LINE_val_tbl   => l_PRICE_LIST_LINE_val_tbl  ,
         x_QUALIFIERS_tbl            => l_QUALIFIERS_tbl,
         x_QUALIFIERS_val_tbl        => l_QUALIFIERS_val_tbl,
         x_PRICING_ATTR_tbl          => l_PRICING_ATTR_tbl,
         x_PRICING_ATTR_val_tbl      => l_PRICING_ATTR_val_tbl
   );

   x_pricelist_line_id := l_PRICE_LIST_LINE_tbl(1).list_line_id;
   x_return_status := l_return_status;

   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   END IF;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
      THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END create_pricelist_line;

/*=================================================*/

PROCEDURE copy_ev_header_to_offer(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_evo_rec             OUT NOCOPY      evo_rec_type,
      p_src_evh_id         IN       NUMBER,
      p_evo_rec            IN       evo_rec_type
) IS
     -- p_eveo_elements_rec   IN       eveo_elements_rec_type,
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'copy_ev_header_to_offer';
      l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_return_status          VARCHAR2(1);
      -- variables for the OUT parameters of the called create procedures
      --l_eveo_ele_rec           eveo_elements_rec_type;
      l_name                   VARCHAR2(80);
      l_msg_count              NUMBER;   -- variables for the OUT parameters of the called create procedures
      l_msg_data               VARCHAR2(512);   -- variables for the OUT parameters of the called create procedures

      l_evo_rec               ams_eventoffer_pvt.evo_rec_type := p_evo_rec;

      l_mesg_text              VARCHAR2(2000);
      p_errmsg                 VARCHAR2(3000);
      l_eventheader_rec         ams_event_headers_vl%ROWTYPE;

      l_lookup_meaning         VARCHAR2(80);
     l_dummy   VARCHAR2(1);

     CURSOR c_get_header_info IS
        SELECT *
         FROM ams_event_headers_vl
         WHERE event_header_id = p_src_evh_id;

      CURSOR c_setup_resp(id_in IN NUMBER) IS
         SELECT 'x'
         FROM ams_custom_setup_attr
         WHERE custom_setup_id = nvl(id_in, 1006)
       and OBJECT_ATTRIBUTE = 'RESP';
   BEGIN
      SAVEPOINT copy_ev_header_to_offer;
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

         ams_utility_pvt.get_lookup_meaning(
            'AMS_SYS_ARC_QUALIFIER',
            'EVEH',
            l_return_status,
            l_lookup_meaning);
--  General Message saying copying has started
         fnd_message.set_name('AMS', 'AMS_COPY_ELEMENTS');
         fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
-- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg('EVEH', p_src_evh_id, l_mesg_text, 'GENERAL');
         l_return_status := NULL;
         l_msg_count := 0;
         l_msg_data := NULL;
-- selects the event offers to copy

      OPEN c_get_header_info;
      FETCH c_get_header_info into l_eventheader_rec;
      IF (c_get_header_info%NOTFOUND) THEN
           CLOSE c_get_header_info;
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
             FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.g_exc_error;
       END IF;

      CLOSE c_get_header_info;

         --l_evo_rec.object_version_number := 1;
         --l_evo_rec.application_id := l_eventheader_rec.application_id;
         --l_evo_rec.event_header_id := p_src_evh_id;
           l_evo_rec.private_flag := l_eventheader_rec.private_flag;

         --l_evo_rec.event_level := l_eventheader_rec.event_level;
         --l_evo_rec.user_status_id := l_eventheader_rec.user_status_id;
         --l_evo_rec.system_status_code := 'NEW';
         --l_evo_rec.event_type_code := l_eventheader_rec.event_type_code;

         if l_evo_rec.event_language_code is NULL then
            l_evo_rec.event_language_code := l_eventheader_rec.main_language_code;
         end if;

         l_evo_rec.overflow_flag := l_eventheader_rec.overflow_flag;
         l_evo_rec.partner_flag := l_eventheader_rec.partner_flag;
         l_evo_rec.event_standalone_flag := l_eventheader_rec.event_standalone_flag;
         l_evo_rec.event_object_type := 'EVEO';
         l_evo_rec.reg_required_flag := 'Y';


         -- Bug # 2452649 as the following flags were removed from Event Header
        --  l_evo_rec.reg_charge_flag := l_eventheader_rec.reg_charge_flag;
        --  l_evo_rec.reg_invited_only_flag := l_eventheader_rec.reg_invited_only_flag;

         if l_evo_rec.event_duration is NULL then
            l_evo_rec.event_duration := l_eventheader_rec.duration;
         end if;

         if l_evo_rec.event_duration_uom_code is NULL then
            l_evo_rec.event_duration_uom_code := l_eventheader_rec.duration_uom_code;
         end if;

         l_evo_rec.reg_maximum_capacity := l_eventheader_rec.reg_maximum_capacity;
         l_evo_rec.reg_minimum_capacity := l_eventheader_rec.reg_minimum_capacity;
         l_evo_rec.organization_id := l_eventheader_rec.organization_id;
         l_evo_rec.org_id := l_eventheader_rec.org_id;
         l_evo_rec.stream_type_code := l_eventheader_rec.stream_type_code;

         l_evo_rec.event_full_flag := 'N';
         -- source code will be uniquely generated if its passed a snull from the screen
         --l_evo_rec.source_code := p_source_code;

         l_evo_rec.cert_credit_type_code := l_eventheader_rec.cert_credit_type_code;
         l_evo_rec.certification_credits := l_eventheader_rec.certification_credits;
         l_evo_rec.coordinator_id := l_eventheader_rec.coordinator_id;

         if l_evo_rec.priority_type_code is NULL then
            l_evo_rec.priority_type_code := l_eventheader_rec.priority_type_code;
        end if;

    open c_setup_resp(p_evo_rec.custom_setup_id);
    fetch c_setup_resp into l_dummy;
    if (l_dummy = 'x') then
       l_evo_rec.email := l_eventheader_rec.email;
       l_evo_rec.phone := l_eventheader_rec.phone;
       l_evo_rec.url := l_eventheader_rec.url;
       l_evo_rec.inbound_script_name := l_eventheader_rec.inbound_script_name;
   end if;

   close c_setup_resp;

   if l_evo_rec.DESCRIPTION is NULL then
      l_evo_rec.DESCRIPTION := l_eventheader_rec.DESCRIPTION;
   end if;

         l_evo_rec.attribute_category := l_eventheader_rec.attribute_category;
         l_evo_rec.attribute1 := l_eventheader_rec.attribute1;
         l_evo_rec.attribute2 := l_eventheader_rec.attribute2;
         l_evo_rec.attribute3 := l_eventheader_rec.attribute3;
         l_evo_rec.attribute4 := l_eventheader_rec.attribute4;
         l_evo_rec.attribute5 := l_eventheader_rec.attribute5;
         l_evo_rec.attribute6 := l_eventheader_rec.attribute6;
         l_evo_rec.attribute7 := l_eventheader_rec.attribute7;
         l_evo_rec.attribute8 := l_eventheader_rec.attribute8;
         l_evo_rec.attribute9 := l_eventheader_rec.attribute9;
         l_evo_rec.attribute10 := l_eventheader_rec.attribute10;
         l_evo_rec.attribute11 := l_eventheader_rec.attribute11;
         l_evo_rec.attribute12 := l_eventheader_rec.attribute12;
         l_evo_rec.attribute13 := l_eventheader_rec.attribute13;
         l_evo_rec.attribute14 := l_eventheader_rec.attribute14;
         l_evo_rec.attribute15 := l_eventheader_rec.attribute15;

   x_evo_rec := l_evo_rec;

      EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_ev_header_to_offer;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_ev_header_to_offer;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF (AMS_DEBUG_HIGH_ON) THEN

             ams_utility_pvt.debug_message(l_full_name || ': debug');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN OTHERS THEN
      IF (c_get_header_info%ISOPEN) THEN
            CLOSE c_get_header_info;
      END IF;
      IF (c_setup_resp%ISOPEN) THEN
            CLOSE c_setup_resp;
      END IF;

         ROLLBACK TO copy_ev_header_to_offer;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
   END copy_ev_header_to_offer;

/*======================================================================*/
     PROCEDURE copy_ev_header_associations(
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 := fnd_api.g_false,
     p_commit            IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level    IN       NUMBER   := FND_API.g_valid_level_full,
     x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
     x_transaction_id      OUT NOCOPY       NUMBER,
      p_src_evh_id         IN       NUMBER,
      p_evo_id            IN       NUMBER,
     p_setup_id         IN       NUMBER)
     -- p_eveo_elements_rec   IN       eveo_elements_rec_type,
   IS
      l_api_version   CONSTANT NUMBER       := 1.0;
      l_api_name      CONSTANT VARCHAR2(30) := 'copy_ev_header_associations';
      l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_return_status          VARCHAR2(1);
      -- variables for the OUT parameters of the called create procedures
      l_eveo_ele_rec           ams_copyactivities_pvt.eveo_elements_rec_type;
      l_msg_count              NUMBER;   -- variables for the OUT parameters of the called create procedures
      l_msg_data               VARCHAR2(512);   -- variables for the OUT parameters of the called create procedures

      l_mesg_text              VARCHAR2(2000);
      p_errmsg                 VARCHAR2(3000);

      l_errcode                VARCHAR2(80);
      l_errnum                 NUMBER;
      l_errmsg                 VARCHAR2(3000);
      l_eveo_ele_rec2         ams_copyactivities_pvt.eveo_elements_rec_type;
      x_sub_evo_id            NUMBER;   -- variables for the OUT parameters of the called copy campaign procedures while copying sub_campaign
      l_evo_count             NUMBER;
      l_lookup_meaning         VARCHAR2(80);

     CURSOR sub_eveh_cur
      IS
         SELECT event_header_id
         FROM ams_event_headers_vl
         WHERE parent_event_header_id = p_src_evh_id;

   CURSOR c_header_resp IS
      SELECT attribute_defined_flag
      FROM ams_object_attributes
      WHERE object_type = 'EVEH'
      AND   object_id  = p_src_evh_id
      AND     object_attribute = 'RESP';


   CURSOR c_get_attr(l_setup_id IN NUMBER) IS
   SELECT object_attribute
   FROM  ams_custom_setup_attr
   WHERE  custom_setup_id = l_setup_id;

   TYPE t_obj_attr IS TABLE OF c_get_attr%ROWTYPE
   INDEX BY BINARY_INTEGER;

   l_obj_attr t_obj_attr;
   l_attr   c_get_attr%ROWTYPE;
   l_total   NUMBER;
   l_association_copied NUMBER := 0;
   l_header_resp  VARCHAR2(1);
   l_object_type VARCHAR2(4) := 'EVEO';
   l_object_id NUMBER := p_evo_id;

   BEGIN
      SAVEPOINT copy_ev_header_associations;
      IF (AMS_DEBUG_HIGH_ON) THEN

          ams_utility_pvt.debug_message(l_full_name || ': start');
      END IF;

      IF fnd_api.to_boolean(p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call(
            l_api_version,
            p_api_version,
            l_api_name,
            g_pkg_name)
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;
      ----------------------- insert -----------------------

      IF (AMS_DEBUG_HIGH_ON) THEN



          ams_utility_pvt.debug_message(l_full_name || ': start');

      END IF;
     -- refresh the log

     AMS_CPYutility_pvt.refresh_log_mesg;

         ams_utility_pvt.get_lookup_meaning(
            'AMS_SYS_ARC_QUALIFIER',
            'EVEH',
            l_return_status,
            l_lookup_meaning);
--  General Message saying copying has started
         fnd_message.set_name('AMS', 'AMS_COPY_ELEMENTS');
         fnd_message.set_token('ELEMENTS', l_lookup_meaning, TRUE);
         l_mesg_text := fnd_message.get;
-- Writing to the Pl/SQLtable
         ams_cpyutility_pvt.write_log_mesg('EVEH', p_src_evh_id, l_mesg_text, 'GENERAL');
         l_return_status := NULL;
         l_msg_count := 0;
         l_msg_data := NULL;

   l_total := 0;

   OPEN c_get_attr(p_setup_id);
   LOOP
       FETCH c_get_attr INTO l_attr ;
       EXIT WHEN c_get_attr%NOTFOUND ;
       l_obj_attr(l_total) := l_attr ;
       l_total := l_total + 1 ;
   END LOOP;
   CLOSE c_get_attr;

   if l_total = 0 then
      return;
   end if;

   FOR i in 1..l_total LOOP
     if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'MESG' then
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_messages(
                           'EVEH',
                           'EVEO',
                           p_src_evh_id,
                           p_evo_id,
                           l_errnum,
                           l_errcode,
                           l_errmsg);

         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'MESG',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'MESG',
                       p_attr_defined_flag  => 'Y'
                     );
       end if;
      end if;
     if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'PROD' then
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_prod(
                           'EVEH',
                           'EVEO',
                           p_src_evh_id,
                           p_evo_id,
                           l_errnum,
                           l_errcode,
                           l_errmsg);

         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'PROD',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'PROD',
                       p_attr_defined_flag  => 'Y'
                     );
       end if;
      end if;
     if ((l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'CAMP') OR (l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'DELV')) then
      if (l_association_copied = 0) then
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_object_associations(
                           'EVEH',
                           'EVEO',
                           p_src_evh_id,
                           p_evo_id,
                           l_errnum,
                           l_errcode,
                           l_errmsg);
         l_association_copied := l_association_copied + 1;
      end if;
      if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'CAMP' then
         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'CAMP',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'CAMP',
                       p_attr_defined_flag  => 'Y'
                     );
         end if;
      elsif l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'DELV' then
         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'DELV',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'DELV',
                       p_attr_defined_flag  => 'Y'
                     );
         end if;
      end if;
      end if;
     if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'ATCH' then
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_attachments(
                           'EVEH',
                           'EVEO',
                           p_src_evh_id,
                           p_evo_id,
                           l_errnum,
                           l_errcode,
                           l_errmsg);

         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'ATCH',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'ATCH',
                       p_attr_defined_flag  => 'Y'
                     );
       end if;
      end if;
      /*Commented by mukemar on may14 2002 we are not supporting the resource copy
     if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'RESC' then
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_resources(
                           'EVEH',
                           'EVEO',
                           p_src_evh_id,
                           p_evo_id,
                           l_errnum,
                           l_errcode,
                           l_errmsg);

         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'RESC',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'RESC',
                       p_attr_defined_flag  => 'Y'
                     );
       end if;
      end if;
      */
     if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'CELL' then
            l_errcode := NULL;
            l_errnum := 0;
            l_errmsg := NULL;
            ams_copyelements_pvt.copy_act_market_segments(
                           'EVEH',
                           'EVEO',
                           p_src_evh_id,
                           p_evo_id,
                           l_errnum,
                           l_errcode,
                           l_errmsg);

         if (AMS_EventOffer_PVT.check_association_exists(l_object_type,l_object_id,'CELL',NULL)
               = FND_API.g_true) then

                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'CELL',
                       p_attr_defined_flag  => 'Y'
                     );
       end if;
      end if;
     if l_obj_attr(i-1).OBJECT_ATTRIBUTE = 'RESP' then
   -- resources would already have been copied in copy_ev_header_to_offer procedure..
   -- update object attribute if  ATTRIBUTE_DEFINED_FLAG  is Y for p_src_evh_id in ams_object_attributes
            open c_header_resp;
         fetch c_header_resp into l_header_resp;
         close c_header_resp;

         if l_header_resp = 'Y' then
                    AMS_ObjectAttribute_PVT.modify_object_attribute(
                       p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       p_commit             => p_commit,
                       p_validation_level   => p_validation_level,

                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,

                       p_object_type        => l_object_type,
                       p_object_id          => l_object_id,
                       p_attr               => 'RESP',
                       p_attr_defined_flag  => 'Y'
                     );
         end if;
      end if;
   END LOOP;

/*
         IF l_eveo_ele_rec.p_sub_eveh = 'Y'
         THEN
            FOR sub_eveh_rec IN sub_eveh_cur
            LOOP
               BEGIN
                  l_return_status := NULL;
                  l_msg_count := 0;
                  l_msg_data := NULL;
                  copy_event_header(
                     p_api_version => 1,
                     p_init_msg_list => fnd_api.g_true,
                     x_return_status => l_return_status,
                     x_msg_data => l_msg_data,
                     x_msg_count => l_msg_count,
                     p_src_evh_id => sub_eveh_rec.event_header_id,
                     p_new_eveh_name => NULL,
                     p_par_eveh_id => x_eveh_id,
                     x_eveh_id => x_sub_eveh_id,
                    --??? p_eveh_elements_rec => l_eveh_elements_rec,
                     p_start_date => p_start_date);
               END;
            END LOOP;
         END IF;

*/
       AMS_CPYutility_pvt.insert_log_mesg(x_transaction_id);

       EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         ROLLBACK TO copy_ev_header_associations;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         ROLLBACK TO copy_ev_header_associations;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         IF (AMS_DEBUG_HIGH_ON) THEN

             ams_utility_pvt.debug_message(l_full_name || ': debug');
         END IF;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
      WHEN OTHERS
      THEN
      IF (c_header_resp%ISOPEN) THEN
            CLOSE c_header_resp;
      END IF;

         ROLLBACK TO copy_ev_header_associations;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false,
            p_count => x_msg_count,
            p_data => x_msg_data);
   END copy_ev_header_associations;

/*********************** server side TEST CASE *****************************************/

-- Start of Comments
--
-- NAME
--   Unit_Test_Insert
--   Unit_Test_Delete
--   Unit_Test_Update
--   Unit_Test_Lock
--
-- PURPOSE
--   These procedures are to test each procedure that satisfy caller needs
--
-- NOTES
-- End of Comments

--********************************************************
PROCEDURE Unit_Test_Insert
IS

   -- local variables
      l_evo_rec         AMS_EVENTOFFER_PVT.evo_rec_type;
        l_return_status         VARCHAR2(1);
        l_msg_count         NUMBER;
        l_msg_data         VARCHAR2(200);
        l_evo_id      AMS_event_offers_all_b.event_offer_id%type;

  BEGIN
--AMS_EVENTOFFER_PVT.init_evo_rec(l_evo_rec);
--   l_evo_rec.source_code:= 'CAMP101';
   L_EVO_REC.EVENT_OFFER_NAME := 'HIJACK CRISIS OVER NO PARTY';
   l_evo_rec.event_level := 'MAIN';
   l_evo_rec.user_status_id := 100;
     l_evo_rec.event_start_date_time := to_date('15:30', 'HH24:MI');
     l_evo_rec.event_end_date_time := to_date('18:55', 'HH24:MI');
   l_evo_rec.reg_maximum_capacity := 100;
   l_evo_rec.reg_minimum_capacity := 10;
   l_evo_rec.reg_overbook_pct := 10;
   l_evo_rec.reg_waitlist_pct := 10;
   l_evo_rec.stream_type_code := 'A';
   l_evo_rec.owner_user_id := 101;
   l_evo_rec.system_status_code := 'PLANNING';
 l_evo_rec.application_id := 530;
   l_evo_rec.event_type_code := 'SEMINAR';
   l_evo_rec.priority_type_code := 'HIGH';
--  l_evo_rec.object_version_number := 5;
  l_evo_rec.event_header_id := 1001;

   --dbms_output.put_line('Call AMS_EVENTOFFER_PVT.UPDATE_offer');

        AMS_EVENTOFFER_PVT.create_event_offer(
         p_api_version         => 1.0 -- p_api_version
        ,p_init_msg_list      => FND_API.G_FALSE
        ,p_commit         => FND_API.G_FALSE
        ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
      ,p_evo_rec         => l_evo_rec
        ,x_return_status      => l_return_status
        ,x_msg_count         => l_msg_count
        ,x_msg_data         => l_msg_data
        ,x_evo_id         => l_evo_id
        );

       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      --dbms_output.put_line(l_return_status);
      --dbms_output.put_line(l_msg_count);
      AMS_UTILITY_PVT.display_messages;
      --dbms_output.put_line('AMS_EVENTOFFER_PVT.update ERROR');
       ELSE
      commit work;
      --dbms_output.put_line(l_return_status);
      AMS_UTILITY_PVT.display_messages;
      END IF;

END Unit_Test_Insert;

--********************************************************

PROCEDURE create_global_pricing(
   p_evo_rec        IN OUT NOCOPY evo_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
)
IS
   l_api_version CONSTANT NUMBER := 1.0;
   l_qp_profile    VARCHAR2(1);
   l_evo_rec        evo_rec_type;
   l_return_status VARCHAR2(1);
   l_pricelist_header_id  NUMBER;
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(512);


   CURSOR c_pricelist_header_id(curr_code IN VARCHAR2) IS
   SELECT distinct(pricelist_header_id)
   FROM ams_event_offers_all_b evo, qp_price_lists_v qph
   WHERE evo.pricelist_header_id = qph.price_list_id
   AND   qph.currency_code = curr_code;

BEGIN
   l_qp_profile := FND_PROFILE.Value('AMS_USE_GLOBAL_PRICING');
   l_evo_rec := p_evo_rec;

   -- Remove the following line once the testing is done.
   l_qp_profile := 'N';

   IF l_qp_profile = 'N' AND
      l_evo_rec.PRICELIST_HEADER_CURRENCY_CODE <> FND_API.g_miss_char AND
      l_evo_rec.PRICELIST_HEADER_CURRENCY_CODE IS NOT NULL THEN

     -- DBMS_OUTPUT.put_line('calling Cursor for pricelist_header');


      OPEN c_pricelist_header_id(l_evo_rec.PRICELIST_HEADER_CURRENCY_CODE);
      FETCH c_pricelist_header_id INTO l_pricelist_header_id;
      CLOSE c_pricelist_header_id;

      -- DBMS_OUTPUT.put_line('The value of  pricelist_header is ' || l_pricelist_header_id);


      -- if pricelist header has been created for any event already
      -- 1.populate this header id to pricelist_header_id,
      -- 2.create pricelist line and store the line id

      IF (l_pricelist_header_id IS NOT NULL) THEN
         l_evo_rec.pricelist_header_id := l_pricelist_header_id;
         -- DBMS_OUTPUT.put_line('Calling create_pricelist_line');
         create_pricelist_line(
            p_api_version             => l_api_version,
            p_init_msg_list           => FND_API.g_false,
            p_return_values           => FND_API.g_false,
            p_commit                  => FND_API.g_false,
            p_price_hdr_id         => l_evo_rec.pricelist_header_id,
            p_evo_rec               => l_evo_rec,
            x_return_status         => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data            => l_msg_data,
            x_pricelist_line_id     => l_evo_rec.pricelist_line_id
         );

         -- DBMS_OUTPUT.put_line('The value of  pricelist_header is ' || l_evo_rec.pricelist_header_id);
        --  DBMS_OUTPUT.put_line('The value of  pricelist_line_id  is ' || l_evo_rec.pricelist_line_id);


         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
         -- if pricelist header has never been created for collateral
         -- 1.create pricelist header
         -- 2.populate this header id to pricelist_header_id,
         -- 3.create pricelist line and store the line id
         -- IF (l_pricelist_header_id IS NULL) THEN
       ELSE
         -- DBMS_OUTPUT.put_line('Calling create_pricelist_header');
         create_pricelist_header(
            p_api_version             => l_api_version,
            p_init_msg_list           => FND_API.g_false,
            p_return_values           => FND_API.g_false,
            p_commit                  => FND_API.g_false,
            p_evo_rec               => l_evo_rec,
            x_return_status         => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data            => l_msg_data,
            x_pricelist_header_id     => l_evo_rec.pricelist_header_id
         );


         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
         -- DBMS_OUTPUT.put_line('Calling create_pricelist_line');

         create_pricelist_line(
            p_api_version             => l_api_version,
            p_init_msg_list           => FND_API.g_false,
            p_return_values           => FND_API.g_false,
            p_commit                  => FND_API.g_false,
            p_price_hdr_id         => l_evo_rec.pricelist_header_id,
            p_evo_rec               => l_evo_rec,
            x_return_status         => l_return_status,
            x_msg_count            => l_msg_count,
            x_msg_data            => l_msg_data,
            x_pricelist_line_id     => l_evo_rec.pricelist_line_id
         );


         IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         END IF;

      END IF; -- end if for l_pricelist_header_id

   END IF; -- end if for l_qp_profile

      p_evo_rec := l_evo_rec;


END create_global_pricing;

--********************************************************


-------------------------------------------------------------
--       Check_Dates_Range
-------------------------------------------------------------
PROCEDURE Check_Dates_Range (
   p_evo_rec          IN  evo_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
)IS
l_evo_rec   evo_rec_type;
l_start_date DATE;
l_end_date DATE;

-- soagrawa modified table names for following 3 cursors on 24-feb-2003 while fixing INTERNAL bug# 2816673

   CURSOR c_program IS
--       SELECT actual_exec_start_date , actual_exec_end_date FROM ams_campaigns_v
         SELECT actual_exec_start_date , actual_exec_end_date
         FROM ams_campaigns_all_b
         WHERE campaign_id = p_evo_rec.parent_id;

   CURSOR c_event IS
--       SELECT active_from_date, active_to_date FROM ams_event_headers_v
         SELECT active_from_date, active_to_date
         FROM ams_event_headers_all_b
         WHERE event_header_id = p_evo_rec.event_header_id;

   CURSOR c_event_schedule IS
--       SELECT event_start_date, event_end_date FROM ams_event_offers_v
         SELECT event_start_date, event_end_date
         FROM ams_event_offers_all_b
         WHERE event_offer_id = p_evo_rec.parent_event_offer_id and system_status_code<> 'CANCELLED';--implemented ER2381975 by anchaudh.


 BEGIN
     x_return_status := FND_API.g_ret_sts_success;

     IF (p_evo_rec.event_level = 'MAIN') THEN
        IF (p_evo_rec.event_object_type = 'EONE') THEN
           OPEN c_program;
           FETCH c_program INTO l_start_date,l_end_date;
           CLOSE c_program;
        ELSIF (p_evo_rec.event_object_type = 'EVEO') THEN
           OPEN c_event;
           FETCH c_event INTO l_start_date,l_end_date;
           CLOSE c_event;
        END IF;
     ELSIF (p_evo_rec.event_level = 'SUB') THEN
        OPEN c_event_schedule;
        FETCH c_event_schedule INTO l_start_date,l_end_date;
        CLOSE c_event_schedule;
     END IF;

     IF (p_evo_rec.event_start_date IS NOT NULL AND l_start_date IS NOT NULL ) THEN
         IF (p_evo_rec.event_start_date < l_start_date) THEN
                  IF (AMS_DEBUG_HIGH_ON) THEN

                      Ams_Utility_Pvt.debug_message('The start date of Event can not be lesser than that of Program');
                  END IF;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN

                   IF (p_evo_rec.event_level = 'MAIN') THEN
                      IF (p_evo_rec.event_object_type = 'EVEO') THEN
                        Fnd_Message.set_name('AMS', 'AMS_EVT_STDT_LS_EVNT_STDT');
                      ELSE
                        Fnd_Message.set_name('AMS', 'AMS_EVT_STDT_LS_PRG_STDT');
                      END IF;
                   ELSIF (p_evo_rec.event_level = 'SUB') THEN
                     Fnd_Message.set_name('AMS', 'AMS_AGEN_STDT_LS_EVNT_STDT');
                   END IF;

                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
         END IF;
     END IF;

  IF (p_evo_rec.event_level = 'MAIN') THEN
     IF (p_evo_rec.event_end_date IS NOT NULL AND l_end_date IS NOT NULL ) THEN
         IF (p_evo_rec.event_end_date > l_end_date) THEN
                  IF (AMS_DEBUG_HIGH_ON) THEN

                      Ams_Utility_Pvt.debug_message('The end date of Event can not be greater than that of Program');
                  END IF;
                IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN

                   IF (p_evo_rec.event_object_type = 'EVEO') THEN
                     Fnd_Message.set_name('AMS', 'AMS_EVT_EDDT_GT_EVNT_EDDT');
                   ELSE
                     Fnd_Message.set_name('AMS', 'AMS_EVT_EDDT_GT_PRG_EDDT');
                   END IF;

                   Fnd_Msg_Pub.ADD;
                   x_return_status := Fnd_Api.g_ret_sts_error;
                   RETURN;
                END IF;
          END IF;
     ELSE
        IF ( p_evo_rec.event_end_date IS NULL AND l_end_date IS NOT NULL ) THEN
            IF (AMS_DEBUG_HIGH_ON) THEN

                Ams_Utility_Pvt.debug_message('The end date of Event can not be greater than that of Program');
            END IF;
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN

                IF (p_evo_rec.event_object_type = 'EVEO') THEN
                  Fnd_Message.set_name('AMS', 'AMS_EVT_EDDT_GT_EVNT_EDDT');
                ELSE
                  Fnd_Message.set_name('AMS', 'AMS_EVT_EDDT_GT_PRG_EDDT');
                END IF;

                Fnd_Msg_Pub.ADD;
                x_return_status := Fnd_Api.g_ret_sts_error;
               RETURN;
             END IF;
        END IF;
     END IF;
   END IF;

  IF (p_evo_rec.event_level = 'SUB') THEN
      IF (p_evo_rec.event_start_date > l_end_date) THEN
         Fnd_Message.set_name('AMS', 'AMS_AGEN_STDT_GT_EVNT_EDDT');
         Fnd_Msg_Pub.ADD;
         x_return_status := Fnd_Api.g_ret_sts_error;
         RETURN;
       END IF;
  END IF;

END Check_Dates_Range;
--------------------------------------------------------------------

-------------------------------------------------------------
--       Check_Parent_Active
-------------------------------------------------------------
PROCEDURE Check_Parent_Active (
   p_evo_rec          IN  evo_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2
)IS
l_evo_rec   evo_rec_type;
l_system_status_code p_evo_rec.system_status_code%TYPE ;

-- soagrawa modified table names for following 2 cursors on 24-feb-2003 while fixing INTERNAL bug# 2816673

   CURSOR c_program IS
--       SELECT status_code FROM ams_campaigns_v
         SELECT status_code
         FROM ams_campaigns_all_b
         WHERE campaign_id = p_evo_rec.parent_id;

   CURSOR c_event IS
--       SELECT system_status_code FROM ams_event_headers_v
         SELECT system_status_code
         FROM ams_event_headers_all_b
         WHERE event_header_id = p_evo_rec.event_header_id;


 BEGIN
     x_return_status := FND_API.g_ret_sts_success;

     IF (p_evo_rec.event_level = 'MAIN' AND p_evo_rec.active_flag = 'Y' AND p_evo_rec.system_status_code = 'ACTIVE' ) THEN

        IF (p_evo_rec.event_object_type = 'EONE') THEN
           OPEN c_program;
           FETCH c_program INTO l_system_status_code;
           CLOSE c_program;
        ELSIF (p_evo_rec.event_object_type = 'EVEO') THEN
           OPEN c_event;
           FETCH c_event INTO l_system_status_code;
           CLOSE c_event;
        END IF;

        IF  l_system_status_code <> 'ACTIVE'  THEN

           IF p_evo_rec.event_object_type = 'EONE' THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

                  Ams_Utility_Pvt.debug_message('The Parent is not Active');
              END IF;
              Fnd_Message.set_name('AMS', 'AMS_PROGRAM_NOT_ACTIVE');
           ELSIF p_evo_rec.event_object_type = 'EVEO' THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

                  Ams_Utility_Pvt.debug_message('The Parent is not Active');
              END IF;
              Fnd_Message.set_name('AMS', 'AMS_EVENT_NOT_ACTIVE');
           END IF;

           Fnd_Msg_Pub.ADD;
           x_return_status := Fnd_Api.g_ret_sts_error;
           RETURN;

       END IF;

    END IF;

END Check_Parent_Active;

-------------------------------------------------------------
--       Update_Metrics
-------------------------------------------------------------
PROCEDURE Update_Metrics (
   p_evo_rec          IN  evo_rec_type,
   x_return_status  OUT NOCOPY   VARCHAR2,
   x_msg_count OUT NOCOPY VARCHAR2,
   x_msg_data OUT NOCOPY VARCHAR2
 ) IS
l_program_id NUMBER;
l_api_version CONSTANT NUMBER  := 1.0;


CURSOR c_program IS
        SELECT parent_id from ams_event_offers_v
        WHERE event_offer_id = p_evo_rec.event_offer_id;
 BEGIN

     OPEN c_program;
     FETCH c_program INTO l_program_id;
     CLOSE c_program;

     x_return_status := FND_API.g_ret_sts_success;

     /* The AMS_ACTMETRIC_PVT.INVALIDATE_ROLLUP should be called
        1) When Program is removed or updated (changed)
        2) No need of calling when program is attached first time
     */

     IF( l_program_id IS NOT NULL )THEN
        IF( l_program_id <> nvl(p_evo_rec.parent_id,0))THEN
            AMS_ACTMETRIC_PVT.INVALIDATE_ROLLUP(
               p_api_version => l_api_version,
               p_init_msg_list   => Fnd_Api.g_false,
               p_commit  => Fnd_Api.G_FALSE,

               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,

               p_used_by_type => 'EONE',
               p_used_by_id => p_evo_rec.event_offer_id
            );

           IF x_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
               RAISE Fnd_Api.g_exc_unexpected_error;
            ELSIF x_return_status = Fnd_Api.g_ret_sts_error THEN
               RAISE Fnd_Api.g_exc_error;
           END IF;
        END IF;
    END IF;

 END Update_Metrics;

-------------------------------------------------------------
--       fulfill_event_offer
-------------------------------------------------------------

PROCEDURE fulfill_event_offer(
   p_evo_rec           IN  evo_rec_type,
   x_return_status     OUT NOCOPY VARCHAR2
)
IS
   CURSOR c_status IS
   SELECT system_status_code
   FROM ams_user_statuses_b
   WHERE user_status_id = p_evo_rec.user_status_id
   AND system_status_type = 'AMS_EVENT_STATUS';

   CURSOR c_details IS
   SELECT event_venue_id, event_start_date, event_end_date, system_status_code
   FROM ams_event_offers_all_b
   WHERE event_offer_id = p_evo_rec.event_offer_id;

   l_return_status  VARCHAR2(1);
   l_fulfilment     VARCHAR2(30);
   l_sys_status_code    VARCHAR2(30);
   l_system_status_code  VARCHAR2(30);
   l_start_date     DATE;
   l_end_date       DATE;
   l_venue_id       NUMBER;

   l_bind_names       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
   l_bind_values      JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Start of Fulfillment VMODUR

l_fulfilment := FND_PROFILE.Value('AMS_FULFILL_ENABLE_FLAG');

IF (AMS_DEBUG_HIGH_ON) THEN
    AMS_Utility_PVT.debug_message(' Fulfilment Profile :' || l_fulfilment);
END IF;

IF( l_fulfilment <> 'N' )
THEN

  /* Get the system_status_code for incoming user_status_id, as we donot send
     system_status_code through Rosetta Rec
  */
  OPEN c_status;
  FETCH c_status INTO l_sys_status_code;
  CLOSE c_status;

  OPEN c_details;
  FETCH c_details INTO l_venue_id, l_start_date, l_end_date, l_system_status_code;
  CLOSE c_details;



  IF (AMS_DEBUG_HIGH_ON) THEN



      AMS_Utility_PVT.debug_message('The p_evo_rec.user_status_id is :' || p_evo_rec.user_status_id);

  END IF;
  IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('The l_sys_status_code is :' || l_sys_status_code);
  END IF;
  IF (AMS_DEBUG_HIGH_ON) THEN

      AMS_Utility_PVT.debug_message('The l_system_status_code is :' || l_system_status_code);
  END IF;


   IF(l_sys_status_code = 'CANCELLED' AND l_sys_status_code <> l_system_status_code)
    THEN

       IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_Utility_PVT.debug_message('Entered Here');
       END IF;
       IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_Utility_PVT.debug_message('Calling Fulfilment Procedure for Cancel');
       END IF;

       l_bind_names(1) := 'EVENT_OFFER_ID' ;
       l_bind_values(1):= TO_CHAR(p_evo_rec.event_offer_id);

       AMS_EvhRules_PVT.Send_Out_Information(
         p_object_type       => p_evo_rec.event_object_type,
         p_object_id         => p_evo_rec.event_offer_id,
         p_trigger_type      => 'CANCELLED',
         p_bind_values       => l_bind_values,
         p_bind_names        => l_bind_names,  -- Added by ptendulk on 13-Dec-2002 for 1:1 integration
         x_return_status     => l_return_status
       );

            l_bind_values.DELETE;
            l_bind_names.DELETE;

       IF l_return_status <> FND_API.g_ret_sts_success THEN
          x_return_status := l_return_status;
	  RETURN;
       END IF;
    END IF;

        -- anchaudh added starts for ER3037795
    IF (l_sys_status_code = 'ACTIVE' AND l_sys_status_code <> l_system_status_code AND l_system_status_code <> 'ON_HOLD') THEN

           IF (AMS_DEBUG_HIGH_ON) THEN
              AMS_Utility_PVT.debug_message('Calling Fulfilment Procedure for Invitation');
           END IF;

            l_bind_names(1) := 'EVENT_OFFER_ID' ;
            l_bind_values(1):= TO_CHAR(p_evo_rec.event_offer_id);

           AMS_EvhRules_PVT.Send_Out_Information(
            p_object_type       => p_evo_rec.event_object_type,
            p_object_id         => p_evo_rec.event_offer_id,
            p_trigger_type      => 'INVITATION',
            p_bind_values       => l_bind_values,
            p_bind_names        => l_bind_names,
            x_return_status     => l_return_status
            );

            l_bind_values.DELETE;
            l_bind_names.DELETE;

       IF l_return_status <> FND_API.g_ret_sts_success THEN
          x_return_status := l_return_status;
	  RETURN;
       END IF;

     END IF;
-- anchaudh added ends for ER3037795


    IF (l_sys_status_code = 'ACTIVE'
         OR l_sys_status_code = 'ON_HOLD')
    THEN
       IF (  (l_start_date <> p_evo_rec.event_start_date)
         OR (l_end_date <> p_evo_rec.event_end_date ))
       THEN
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Calling Fulfilment Procedure for Date change');
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Old start date is '||l_start_date);
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('New start date is '||p_evo_rec.event_start_date);
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Old end date is '||l_end_date);
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('New end date  is '||p_evo_rec.event_end_date);
           END IF;

           l_bind_names(1) := 'OLD_START_DATE';
           l_bind_names(2) := 'OLD_END_DATE';
           l_bind_names(3) := 'EVENT_OFFER_ID';

           l_bind_values(1):= TO_CHAR(l_start_date);
           l_bind_values(2):= TO_CHAR(l_end_date);
           l_bind_values(3):= TO_CHAR(p_evo_rec.event_offer_id);



            AMS_EvhRules_PVT.Send_Out_Information(
             p_object_type       => p_evo_rec.event_object_type,
             p_object_id         => p_evo_rec.event_offer_id,
             p_trigger_type      => 'DATE_CHANGE',
             p_bind_values       => l_bind_values,
             p_bind_names        => l_bind_names,
             x_return_status     => l_return_status
           );

	   l_bind_values.DELETE;
           l_bind_names.DELETE;

           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('The Return Status is ' || l_return_status);
           END IF;

          IF l_return_status <> FND_API.g_ret_sts_success THEN
            x_return_status := l_return_status;
	    RETURN;
          END IF;

       END IF;

       IF( l_venue_id IS NOT NULL AND l_venue_id <> p_evo_rec.event_venue_id)
       THEN
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Calling Fulfilment Procedure for Venue change');
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Old Venue Id is '||l_venue_id);
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('New Venue Id is '||p_evo_rec.event_venue_id);
           END IF;

           l_bind_names(1) := 'OLD_VENUE_ID';
           l_bind_names(2) := 'EVENT_OFFER_ID';

           l_bind_values(1):= TO_CHAR(l_venue_id);
           l_bind_values(2):= TO_CHAR(p_evo_rec.event_offer_id);


          AMS_EvhRules_PVT.Send_Out_Information(
             p_object_type       => p_evo_rec.event_object_type,
             p_object_id         => p_evo_rec.event_offer_id,
             p_trigger_type      => 'VENUE_CHANGE',
             p_bind_values       => l_bind_values,
             p_bind_names        => l_bind_names,
             x_return_status     => l_return_status
          );

	   l_bind_values.DELETE;
           l_bind_names.DELETE;

          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.debug_message('The Return Status is ' || l_return_status);

          END IF;

          IF l_return_status <> FND_API.g_ret_sts_success THEN
            x_return_status := l_return_status;
	    RETURN;
          END IF;

       ELSIF( l_venue_id IS NULL
       AND p_evo_rec.event_venue_id IS NOT NULL)
       THEN

           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Calling Fulfilment api Venue has been created');

           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('Old Venue Id is '||l_venue_id);
           END IF;
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_Utility_PVT.debug_message('New Venue Id is '||p_evo_rec.event_venue_id);
           END IF;

            --defaulting to 0 if its is null
           l_venue_id := 0;

           l_bind_names(1) := 'OLD_VENUE_ID';
           l_bind_names(2) := 'EVENT_OFFER_ID';

           l_bind_values(1):= TO_CHAR(l_venue_id);
           l_bind_values(2):= TO_CHAR(p_evo_rec.event_offer_id);


          AMS_EvhRules_PVT.Send_Out_Information(
             p_object_type       => p_evo_rec.event_object_type,
             p_object_id         => p_evo_rec.event_offer_id,
             p_trigger_type      => 'VENUE_CHANGE',
             p_bind_values       => l_bind_values,
             p_bind_names        => l_bind_names,
             x_return_status     => l_return_status
          );

           l_bind_values.DELETE;
           l_bind_names.DELETE;

          IF (AMS_DEBUG_HIGH_ON) THEN

              AMS_Utility_PVT.debug_message('The Return Status is ' || l_return_status);

          END IF;

         IF l_return_status <> FND_API.g_ret_sts_success THEN
            x_return_status := l_return_status;
	    RETURN;
         END IF;

       END IF;
    END IF;

END IF ;

-- End of Fulfillment VMODUR

END fulfill_event_offer;
---------------------------------------------------------------------
END AMS_EventOffer_PVT;

/
