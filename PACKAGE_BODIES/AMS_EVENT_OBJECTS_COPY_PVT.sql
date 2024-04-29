--------------------------------------------------------
--  DDL for Package Body AMS_EVENT_OBJECTS_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_EVENT_OBJECTS_COPY_PVT" AS
/* $Header: amsveocb.pls 120.3 2006/07/14 03:53:04 batoleti noship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='AMS_Event_Objects_Copy_PVT';
g_file_name  CONSTANT VARCHAR2(12):='amsveocb.pls';
G_OBJECT_TYPE_MODEL       CONSTANT VARCHAR2(30) := 'EVEH';
G_ATTRIBUTE_GEOS          CONSTANT VARCHAR2(30) := 'GEOS';
G_ATTRIBUTE_CELL          CONSTANT VARCHAR2(30) := 'CELL';
-- Debug mode
-- g_debug boolean := FALSE;
-- g_debug boolean := TRUE;
--Added for the bug fix : 5213670
g_commit VARCHAR2(30) := 'T';
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Copy_event_header
--
--   Description
--           To support the "Copy Event Headers" functionality from the events overview
--           and detail pages.
--
--   History
--      12-MAY-2001   PMOTHUKU  Created this available procedures below
--                    Implemented the procedures separetly so that they
--
--   ==============================================================================
AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION get_agenda_name (p_agenda_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (256);
        CURSOR c_agenda_name(p_agenda_id IN NUMBER)    IS
        SELECT   event_header_name
          FROM     ams_event_headers_vl
          WHERE  parent_event_header_id = p_agenda_id;

BEGIN

      OPEN c_agenda_name(p_agenda_id);
      FETCH c_agenda_name INTO l_name;
      CLOSE c_agenda_name;

      RETURN '"' || l_name || '" ';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' || p_agenda_id || '"';
END get_agenda_name;


FUNCTION get_offer_name (p_offer_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (256);
        CURSOR c_offer_name(p_offer_id IN NUMBER)    IS
        SELECT   event_offer_name
          FROM     ams_event_offers_vl
          WHERE  parent_event_offer_id = p_offer_id;

BEGIN

      OPEN c_offer_name(p_offer_id);
      FETCH c_offer_name INTO l_name;
      CLOSE c_offer_name;

      RETURN '"' || l_name || '" ';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' || p_offer_id || '"';
END get_offer_name;

PROCEDURE copy_act_offers (
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num          NUMBER;
      l_name              VARCHAR2 (80);
      l_mesg_text         VARCHAR2 (2000);
      l_api_version       NUMBER;
      l_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      l_msg_data          VARCHAR2 (512);
      l_act_offer_id   NUMBER;
      l_evo_rec      AMS_EventOffer_PVT.evo_rec_type;
      l_offers_rec    AMS_EventOffer_PVT.evo_rec_type;
      temp_offers_rec   AMS_EventOffer_PVT.evo_rec_type;
      l_lookup_meaning    VARCHAR2 (80);
      l_event_header_id  NUMBER;
      l_new_object_id    NUMBER;
      x_custom_setup_id   NUMBER;



      CURSOR offers_cur(l_event_offer_id NUMBER) IS
      SELECT event_header_id
      FROM ams_event_offers_vl
      WHERE  event_offer_id=l_event_offer_id;

      l_attributes_table      AMS_CpyUtility_PVT.copy_attributes_table_type;
      l_copy_columns_table    AMS_CpyUtility_PVT.copy_columns_table_type;

      CURSOR new_event_dates (l_new_event_header_id NUMBER) IS
      SELECT ACTIVE_FROM_DATE, ACTIVE_TO_DATE
      FROM ams_event_headers_vl
      WHERE  EVENT_HEADER_ID = l_new_event_header_id;

      l_event_new_start_date DATE;
      l_event_new_end_date DATE;

   BEGIN
        OPEN offers_cur(p_src_act_id);
        fetch offers_cur into l_event_header_id;
        close offers_cur;

         --l_attributes_table(1) := 'DETL';
        l_attributes_table(1) := 'CATG';
        l_attributes_table(2) := 'MESG';
        l_attributes_table(3) := 'GEOS';
        l_attributes_table(4) := 'AGEN';
        l_attributes_table(5) := 'DELV';
        l_attributes_table(6) := 'PROD';


        OPEN new_event_dates(p_new_act_id);
        FETCH new_event_dates INTO l_event_new_start_date, l_event_new_end_date;
        CLOSE new_event_dates;

        IF (AMS_DEBUG_HIGH_ON) THEN
        AMS_UTILITY_PVT.debug_message('CG: the  new_event_dates = ' || l_event_new_start_date || ' ' || l_event_new_end_date);
        END IF;


        l_copy_columns_table(1).column_name := 'EVENT_HEADER_ID';
	l_copy_columns_table(1).column_value := p_new_act_id;
        l_copy_columns_table(2).column_name := 'EVENT_NEW_START_DATE';
	l_copy_columns_table(2).column_value := l_event_new_start_date;
        l_copy_columns_table(3).column_name := 'EVENT_NEW_END_DATE';
	l_copy_columns_table(3).column_value := l_event_new_end_date;

        p_errcode := NULL;
        p_errnum := 0;
        p_errmsg := NULL;
        ams_utility_pvt.get_lookup_meaning ('AMS_SYS_ARC_QUALIFIER',
                                           'EVEO',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
        fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
        fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
        l_mesg_text := fnd_message.get;
        ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          l_event_header_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );
        l_stmt_num := 1;

        AMS_EventSchedule_Copy_PVT.copy_event_schedule(
             p_api_version                => 1.0,
             p_init_msg_list              => FND_API.G_FALSE,
             p_commit                     => FND_API.G_FALSE,
             p_validation_level           => FND_API.G_VALID_LEVEL_FULL,

             x_return_status              =>  l_return_status,
             x_msg_count                  =>  x_msg_count,
             x_msg_data                   =>  l_msg_data,

             p_source_object_id           =>   p_src_act_id,
             p_attributes_table           =>  l_attributes_table,
             p_copy_columns_table         =>  l_copy_columns_table,

             x_new_object_id              =>  l_new_object_id,
             x_custom_setup_id            =>  x_custom_setup_id
          );

          /* Adding the event_header_id to the event_offer_created.
             This way we are attaching the offers to a particular
             event header .
          */

           IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
		       RAISE Fnd_Api.G_EXC_ERROR;
		     END IF;

         -- IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             UPDATE ams_event_offers_all_b
             SET event_header_id = p_new_act_id
             WHERE event_offer_id = l_new_object_id;
        --  END IF;

        -- dbms_output.put_line('the new  rec with new  header/offer ids are '|| p_src_act_id ||'/'|| l_new_object_id);


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   l_event_header_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;
           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                AMS_Event_Objects_Copy_PVT.get_offer_name (
                                  p_src_act_id
                                ), 1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               l_event_header_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
           END IF;


   END copy_act_offers;
PROCEDURE copy_act_delivery_method(
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
      -- PL/SQL Block
      l_stmt_num              NUMBER;
      l_name                  VARCHAR2 (80);
      l_mesg_text             VARCHAR2 (2000);
      l_api_version           NUMBER;
      l_return_status         VARCHAR2 (1);
      x_msg_count             NUMBER;
      l_msg_data              VARCHAR2 (512);
      l_act_deliverable_id   NUMBER;
      l_deliverables_rec     ams_associations_pvt.association_rec_type;
      l_temp_deliverables_rec     ams_associations_pvt.association_rec_type;
      l_lookup_meaning        VARCHAR2 (80);

      CURSOR deliverable_cur
      IS
         SELECT
         DLT.deliverable_name ,
         DLV.custom_setup_id,
         CAT.category_id,
         OBJ.master_object_id,
         OBJ.object_association_id,
         OBJ.using_object_id,
         CAT.category_name ,
         OBJ.object_version_number,
         OBJ.quantity_needed,
         OBJ.fulfill_on_type_code,
         OBJ.master_object_type,
         OBJ.quantity_needed_by_date,
         OBJ.USING_OBJECT_TYPE,
          OBJ.primary_flag,
          OBJ.USAGE_TYPE
        FROM
         AMS_OBJECT_ASSOCIATIONS OBJ,
	 AMS_DELIVERABLES_ALL_B DLV,
	AMS_DELIVERABLES_ALL_TL DLT,
	 AMS_CATEGORIES_TL CAT
	WHERE
	 OBJ.master_object_id = p_src_act_id AND
	 OBJ.USING_OBJECT_TYPE = 'DELV' AND
	 OBJ.USING_OBJECT_ID = DLV.DELIVERABLE_ID AND
	 OBJ.USING_OBJECT_ID = DLT.DELIVERABLE_ID AND
	 DLT.LANGUAGE = USERENV('LANG') AND
	 DLV.CATEGORY_TYPE_ID = CAT.CATEGORY_ID AND
	 CAT.LANGUAGE = USERENV('LANG') AND
	 OBJ.master_object_type =p_src_act_type;
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      l_stmt_num := 1;
IF p_src_act_id IS NOT NULL THEN
IF (AMS_DEBUG_HIGH_ON) THEN

    AMS_UTILITY_PVT.debug_message('the  deliverable copying: ');
END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_src_act_id: ' ||  p_src_act_id||'\n');
 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_new_act_id: ' ||  p_new_act_id||'\n');
 END IF;
 END IF;
      FOR deliverable_rec IN deliverable_cur
      LOOP
         BEGIN
            p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_deliverables_rec := l_temp_deliverables_rec;
            l_deliverables_rec.master_object_id:= p_new_act_id;
            l_deliverables_rec.master_object_type:=  NVL(p_new_act_type,p_src_act_type);

            l_deliverables_rec.using_object_id:= deliverable_rec.using_object_id;
            l_deliverables_rec.object_version_number:= deliverable_rec.object_version_number;
            l_deliverables_rec.quantity_needed := NULL;
            l_deliverables_rec.fulfill_on_type_code := deliverable_rec.fulfill_on_type_code;
            l_deliverables_rec.quantity_needed_by_date := deliverable_rec.quantity_needed_by_date;
			l_deliverables_rec.using_object_type:= deliverable_rec.using_object_type;
            l_deliverables_rec.usage_type:= deliverable_rec.usage_type;
            l_deliverables_rec.primary_flag:= deliverable_rec.primary_flag;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
             --Added for the bug fix : 5213670
	     if g_commit = null OR trim(g_commit) ='' THEN
	        g_commit:='T';
	      END IF;
	      --End Added for the bug fix : 5213670
	       ams_associations_pvt.create_association(
               p_api_version => l_api_version,
               p_init_msg_list => fnd_api.g_true,
               p_commit=>g_commit,
               p_validation_level=> FND_API.g_valid_level_full,
               x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => l_msg_data,
                p_association_rec => l_deliverables_rec,
				x_object_association_id => l_act_deliverable_id
                );
         --Added for the bug fix : 5213670
         g_commit:='T';
         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           END IF;
           EXCEPTION
             WHEN OTHERS THEN p_errcode := SQLCODE;
               p_errnum := 3;
               l_stmt_num := 4;
              END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errcode := SQLCODE;
         p_errnum := 4;
         l_stmt_num := 5;
         fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
         fnd_message.set_token ('ELEMENTS','AMS_COPY_DELIVMETHODS', TRUE);
         l_mesg_text := fnd_message.get;
         p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                              ',' || '): ' || p_errcode || SQLERRM, 1, 4000);
         ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                             p_src_act_id,
                                             p_errmsg,
                                             'ERROR'
                                          );
   END copy_act_delivery_method;

 PROCEDURE copy_event_header_agenda(
      p_src_act_type   IN       VARCHAR2,
      p_new_act_type   IN       VARCHAR2 := NULL,
      p_src_act_id     IN       NUMBER,
      p_new_act_id     IN       NUMBER,
      p_errnum         OUT NOCOPY      NUMBER,
      p_errcode        OUT NOCOPY      VARCHAR2,
      p_errmsg         OUT NOCOPY      VARCHAR2
   )
   IS
 l_stmt_num          NUMBER;
      l_name              VARCHAR2 (80);
      l_mesg_text         VARCHAR2 (2000);
      l_api_version       NUMBER;
      l_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      l_msg_data          VARCHAR2 (512);
      l_act_agenda_id   NUMBER;
      l_agenda_rec    AMS_EventHeader_PVT.evh_rec_type;
      temp_agenda_rec   AMS_EventHeader_PVT.evh_rec_type;
      l_lookup_meaning    VARCHAR2 (80);

      CURSOR agenda_cur IS
      SELECT
         event_header_id
	,last_update_date
	,last_updated_by
	,creation_date
	,created_by
	,last_update_login
	,object_version_number
	,event_level
	,application_id
	,event_type_code
	,active_flag
	,private_flag
	,user_status_id
	,system_status_code
	,last_status_date
	,stream_type_code
	,source_code
	,event_standalone_flag
	,day_of_event
	,agenda_start_time
	,agenda_end_time
	,reg_required_flag
	,reg_charge_flag
	,reg_invited_only_flag
	,partner_flag
	,overflow_flag
	,parent_event_header_id
	,duration
	,duration_uom_code
	,active_from_date
	,active_to_date
	,reg_maximum_capacity
	,reg_minimum_capacity
	,main_language_code
	,cert_credit_type_code
	,certification_credits
	,inventory_item_id
	,organization_id
	,org_id
	,forecasted_revenue
	,actual_revenue
	,forecasted_cost
	,actual_cost
	,coordinator_id
	,fund_source_type_code
	,fund_source_id
	,fund_amount_tc
	,fund_amount_fc
        ,currency_code_tc
        ,currency_code_fc
	,owner_user_id
	,url
	,email
	,phone
	,priority_type_code
	,cancellation_reason_code
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
   	,event_header_name
   	,event_mktg_message
   	,description
        ,setup_type_id
        ,country_code
        ,business_unit_id
	,event_calendar
	,start_period_name
	,end_period_name
	,global_flag
	,task_id
	,program_id
	,CREATE_ATTENDANT_LEAD_FLAG
	,CREATE_REGISTRANT_LEAD_FLAG
          ,EVENT_PURPOSE_CODE
 FROM ams_event_headers_vl
 WHERE parent_event_header_id =  p_src_act_id
      AND event_level='SUB';
   BEGIN
      p_errcode := NULL;
      p_errnum := 0;
      p_errmsg := NULL;
      ams_utility_pvt.get_lookup_meaning ( 'AMS_SYS_ARC_QUALIFIER',
                                           'AGEN',
                                           l_return_status,
                                           l_lookup_meaning
                                        );
      fnd_message.set_name ('AMS', 'AMS_COPY_ELEMENTS');
      fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
      l_mesg_text := fnd_message.get;
      ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                          p_src_act_id,
                                          l_mesg_text,
                                          'GENERAL'
                                       );
      l_stmt_num := 1;
  -- copy agenda
  IF p_src_act_id IS NOT NULL THEN
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_src_act_id: ' ||  p_src_act_id||'\n');
 END IF;
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the  p_new_act_id: ' ||  p_new_act_id||'\n');
 END IF;
 END IF;
      FOR agenda_rec IN agenda_cur
      LOOP
         BEGIN
             p_errcode := NULL;
            p_errnum := 0;
            p_errmsg := NULL;
            l_api_version := 1.0;
            l_return_status := NULL;
            x_msg_count := 0;
            l_msg_data := NULL;
            l_act_agenda_id:=0;
            l_agenda_rec.parent_event_header_id := p_new_act_id;
l_agenda_rec.event_header_name:= agenda_rec.event_header_name;
l_agenda_rec.active_from_date:= agenda_rec.active_from_date;
l_agenda_rec.active_to_date:= agenda_rec.active_to_date;
l_agenda_rec.application_id:=530;
l_agenda_rec.agenda_start_time := agenda_rec.agenda_start_time;

l_agenda_rec.agenda_end_time   := agenda_rec.agenda_end_time;
l_agenda_rec.day_of_event  := agenda_rec.day_of_event;
l_agenda_rec.owner_user_id:=agenda_rec.owner_user_id;
l_agenda_rec.event_level:='SUB';
l_agenda_rec.user_status_id:=agenda_rec.user_status_id;
     AMS_EventHeader_PVT.create_event_header (
      p_api_version  => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level   =>  FND_API.g_valid_level_full,
      x_return_status   => l_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => l_msg_data,
      p_evh_rec          => l_agenda_rec,
       x_evh_id          => l_act_agenda_id
   );

     IF (AMS_DEBUG_HIGH_ON) THEN



         AMS_UTILITY_PVT.debug_message('the  p_act_agenda_id: ' || l_act_agenda_id||'\n');

     END IF;


         IF l_return_status = fnd_api.g_ret_sts_error
             OR l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            FOR l_counter IN 1 .. x_msg_count
            LOOP
               l_mesg_text := fnd_msg_pub.get (p_encoded => fnd_api.g_false);
               l_stmt_num := 2;
               p_errnum := 1;
               p_errmsg := substr(l_mesg_text||' , '|| TO_CHAR (l_stmt_num) ||
                                  ' , ' || '): ' || l_counter ||
                                  ' OF ' || x_msg_count, 1, 4000);
                ams_cpyutility_pvt.write_log_mesg( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                  );
           END LOOP;
           fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
           fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
           l_mesg_text := fnd_message.get;

           p_errmsg := SUBSTR ( l_mesg_text || ' - ' ||
                                AMS_Event_Objects_Copy_PVT.get_agenda_name (
                                  agenda_rec.parent_event_header_id
                                ), 1, 4000);
           ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                               p_src_act_id,
                                               p_errmsg,
                                               'ERROR'
                                            );
           END IF;
             EXCEPTION
                WHEN OTHERS THEN
                   p_errcode := SQLCODE;
                   p_errnum := 3;
                   l_stmt_num := 4;
                   fnd_message.set_name ('AMS', 'AMS_COPY_ERROR');
                   fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                   l_mesg_text := fnd_message.get;
                   p_errmsg := SUBSTR ( l_mesg_text ||
                                        ',' || TO_CHAR (l_stmt_num) ||
                                        ',' || '): ' || p_errcode ||
                                        SQLERRM, 1, 4000);
               fnd_message.set_name ('AMS', 'AMS_COPY_ERROR2');
               fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
               l_mesg_text := fnd_message.get;
               p_errmsg := SUBSTR ( l_mesg_text ||
                                   AMS_Event_Objects_Copy_PVT.get_agenda_name (
                                       agenda_rec.parent_event_header_id
                                    ) || p_errmsg, 1, 4000);
               ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                   p_src_act_id,
                                                   p_errmsg,
                                                   'ERROR'
                                                );
               END;
            END LOOP;

           EXCEPTION
              WHEN OTHERS
              THEN
                 p_errcode := SQLCODE;
                 p_errnum := 4;
                 l_stmt_num := 5;
                 fnd_message.set_name ('AMS', 'AMS_COPY_ERROR3');
                 fnd_message.set_token ('ELEMENTS', l_lookup_meaning, TRUE);
                 l_mesg_text := fnd_message.get;
                 p_errmsg := SUBSTR ( l_mesg_text || TO_CHAR (l_stmt_num) ||
                                      ',' || '): ' || p_errcode || SQLERRM,
                                       1, 4000);
                 ams_cpyutility_pvt.write_log_mesg ( p_src_act_type,
                                                     p_src_act_id,
                                                     p_errmsg,
                                                     'ERROR'
                                                  );
   END copy_event_header_agenda;


PROCEDURE copy_event_header(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_source_object_id           IN   NUMBER,
    p_attributes_table           IN   AMS_CpyUtility_PVT.copy_attributes_table_type,
    p_copy_columns_table         IN   AMS_CpyUtility_PVT.copy_columns_table_type,

    x_new_object_id              OUT NOCOPY  NUMBER,
    x_custom_setup_id            OUT NOCOPY  NUMBER
   )
IS

   L_API_NAME                  CONSTANT VARCHAR2(30) := 'create_event_header';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER(9) := 2;-- Copy 5171873
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_event_header_id               NUMBER:=p_source_object_id;
   l_new_event_header_id           NUMBER;
   l_dummy                     NUMBER;
    p_event_header_rec        AMS_EventHeader_PVT.evh_rec_type;
   l_evh_rec                  AMS_EventHeader_PVT.evh_rec_type;
   l_reference_rec             AMS_EventHeader_PVT.evh_rec_type;
   l_event_header_rec              AMS_EventHeader_PVT.evh_rec_type;
   l_new_reference_rec         AMS_EventHeader_PVT.evh_rec_type;
   l_return_status             VARCHAR2(1);
   l_errnum          NUMBER;
   l_errcode         VARCHAR2(30);
   l_errmsg          VARCHAR2(4000);
   --l_msg_count                 NUMBER;
   --l_msg_data                  VARCHAR2;
   l_custom_setup_id           NUMBER := 1;
     -- these variables are for selective copying of event schedules with a particular parent event name
   l_new_event_schedule_id           NUMBER;
   l_tmp_event_schedule_id           NUMBER;
   x_event_schedule_ids              VARCHAR2(3000);
   l_event_schedule_ids              VARCHAR2(3000);
   l_index                     NUMBER ;
   l_length                    NUMBER;
   l_counter                   NUMBER;
   l_str_event_schedule_id           VARCHAR2(20);
   l_copy_sched_cont_flag      VARCHAR2(1) := 'Y';

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT copy_event_header;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('the source object id: ' ||  p_source_object_id||'\n');
    END IF;
    IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('the new source object id: ' ||  x_new_object_id||'\n');
    END IF;
     IF (AMS_DEBUG_HIGH_ON) THEN

         AMS_UTILITY_PVT.debug_message('the source custom setup id: ' ||   x_custom_setup_id||'\n');
     END IF;
     FOR i IN 1..p_copy_columns_table.COUNT LOOP
           IF (AMS_DEBUG_HIGH_ON) THEN

               AMS_UTILITY_PVT.debug_message('the'||i||'copy column name: '|| p_copy_columns_table(i).column_name||'\n');
           END IF;
	   IF (AMS_DEBUG_HIGH_ON) THEN

	       AMS_UTILITY_PVT.debug_message('the'||i||'copy column value: '|| p_copy_columns_table(i).column_value||'\n');
	   END IF;

	   END LOOP;

    FOR i IN 1..p_attributes_table.COUNT LOOP
        IF (AMS_DEBUG_HIGH_ON) THEN

            AMS_UTILITY_PVT.debug_message('the'||i||'attibute: '||p_attributes_table(i));
        END IF;
      END LOOP;
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   --
   -- Start of API body
   --

   -- ----------------------------
   -- fetch source object details
   -- ----------------------------

   AMS_EventHeader_PVT.init_evh_rec(p_event_header_rec);
   p_event_header_rec.event_header_id:=p_source_object_id;
    AMS_EventHeader_PVT.complete_evh_rec(p_event_header_rec,l_evh_rec);

   l_reference_rec:=l_evh_rec;
   l_event_header_rec:=l_evh_rec;
   l_event_header_rec.event_header_id := null;
   l_event_header_rec.object_version_number := 2; -- Copy 5171873
  -- l_event_header_rec.source_code := null;


   -- ------------------------------
   -- copy all required fields
   -- i.e. copy values of all mandatory columns from the copy UI
   -- Mandatory fields for EVEH are EventName,EventHeaderId,Start Date and End Date
   -- for ams_event_headers_all_b table :
   -- ------------------------------

AMS_CpyUtility_PVT.get_column_value('startDate', p_copy_columns_table, l_event_header_rec.active_from_date);
l_event_header_rec.active_from_date:= NVL(l_event_header_rec.active_from_date , l_reference_rec.active_from_date);
AMS_CpyUtility_PVT.get_column_value('endDate', p_copy_columns_table, l_event_header_rec.active_to_date);
l_event_header_rec.active_to_date:= NVL( l_event_header_rec.active_to_date, l_reference_rec.active_to_date);
AMS_CpyUtility_PVT.get_column_value('newObjName', p_copy_columns_table, l_event_header_rec.event_header_name);
l_event_header_rec.event_header_name:= NVL( l_event_header_rec.event_header_name, l_reference_rec.event_header_name);
 AMS_CpyUtility_PVT.get_column_value('ownerId', p_copy_columns_table,l_event_header_rec.owner_user_id);
l_event_header_rec.owner_user_id:= NVL(l_event_header_rec.owner_user_id, l_reference_rec.owner_user_id);
AMS_CpyUtility_PVT.get_column_value('newSrcCode', p_copy_columns_table, l_event_header_rec.source_code);
l_event_header_rec.source_code:= NVL(l_event_header_rec.source_code, NULL);
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the l_event_header_rec.source_code: '||l_event_header_rec.source_code);
 END IF;
AMS_CpyUtility_PVT.get_column_value('countryId', p_copy_columns_table, l_event_header_rec.country_code);
l_event_header_rec.country_code:= NVL( l_event_header_rec.country_code, l_reference_rec.country_code);
AMS_CpyUtility_PVT.get_column_value('programId', p_copy_columns_table, l_event_header_rec.program_id);
-- batoleti   commneted the below stmt. Refer bug# 5388748 for more details on this.
--l_event_header_rec.program_id:= NVL(l_event_header_rec.program_id, l_reference_rec.program_id);
   --
   -- mandatory fields for eveh create are
   -- name, lang, coordinator, currency, startDate,endDate
   --

   AMS_CpyUtility_PVT.get_column_value ('langCode', p_copy_columns_table, l_event_header_rec.main_language_code );
   l_event_header_rec.main_language_code := NVL (l_event_header_rec.main_language_code, l_reference_rec.main_language_code );

   AMS_CpyUtility_PVT.get_column_value ('currency', p_copy_columns_table, l_event_header_rec.currency_code_tc);
   l_event_header_rec.currency_code_tc:= NVL (l_event_header_rec.currency_code_tc, l_reference_rec.currency_code_tc);

  -- Fields not to be copied



    l_event_header_rec.business_unit_id:= NULL;
    l_event_header_rec.description:=NULL;
    l_event_header_rec.start_period_name:= NULL;
    l_event_header_rec.end_period_name:= NULL;
    l_event_header_rec.user_status_id:=NULL;
    l_event_header_rec.priority_type_code:=NULL;
    l_event_header_rec.fund_amount_tc:= NULL;

    l_event_header_rec.INVENTORY_ITEM_ID:=NULL;
    l_event_header_rec.FORECASTED_REVENUE:=NULL;
    l_event_header_rec.ACTUAL_REVENUE:=NULL;
    l_event_header_rec.FORECASTED_COST:=NULL;
    l_event_header_rec.ACTUAL_COST:=NULL;
    l_event_header_rec.FUND_SOURCE_TYPE_CODE:=NULL;
    l_event_header_rec.FUND_SOURCE_ID:=NULL;
    l_event_header_rec.FUND_AMOUNT_FC:=NULL;






   -- ----------------------------
   -- call create api
 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('HeaderId: ' || l_event_header_rec.event_header_id || 'start\n');
 END IF;

AMS_EventHeader_PVT.create_event_header (
      p_api_version  => 1.0,
      p_init_msg_list   => FND_API.G_FALSE,
      p_commit          => FND_API.G_FALSE,
      p_validation_level   =>  FND_API.g_valid_level_full,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data,
      p_evh_rec         => l_event_header_rec,
      x_evh_id          => l_new_event_header_id
   );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- copy agenda
   IF l_event_header_id IS NOT NULL THEN

 IF (AMS_DEBUG_HIGH_ON) THEN



     AMS_UTILITY_PVT.debug_message('the l_event_header_id: ' || l_event_header_id||'\n');

 END IF;

 IF (AMS_DEBUG_HIGH_ON) THEN

     AMS_UTILITY_PVT.debug_message('the l_new_event_header_id: ' || l_new_event_header_id||'\n');
 END IF;

 END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_AGEN , p_attributes_table) = FND_API.G_TRUE THEN
      copy_event_header_agenda (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- copy resources
/*   Commented by mukemar on may14 2002 we are not supporting the resource copy
   IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_RESC, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_resources (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     =>  l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
   */
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_PROD, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_prod (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_GEOS, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_geo_areas (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_CELL, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_market_segments (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- copy categories
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_CATG, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_categories (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_EventSchedule_Copy_PVT.G_ATTRIBUTE_ATCH, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_attachments (
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_MESG, p_attributes_table) = FND_API.G_TRUE THEN
      AMS_CopyElements_PVT.copy_act_messages(
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_DELV, p_attributes_table) = FND_API.G_TRUE THEN
      --Added for the bug fix : 5213670
      g_commit:='F';
      copy_act_delivery_method(
         p_src_act_type   => G_OBJECT_TYPE_MODEL,
         p_new_act_type   => G_OBJECT_TYPE_MODEL,
         p_src_act_id     => l_event_header_id,
         p_new_act_id     => l_new_event_header_id,
         p_errnum         => l_errnum,
         p_errcode        => l_errcode,
         p_errmsg         => l_errmsg
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;


IF AMS_CpyUtility_PVT.is_copy_attribute (AMS_Event_Objects_Copy_PVT.G_ATTRIBUTE_EVEO, p_attributes_table) = FND_API.G_TRUE THEN

       -- Get the Schedule Ids as comma separated variables.
       IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_UTILITY_PVT.debug_message('Getting scheduleid values');
       END IF;

       AMS_CpyUtility_PVT.get_column_value ('eventScheduleIdRec', p_copy_columns_table, x_event_schedule_ids);
       l_event_schedule_ids := NVL (x_event_schedule_ids, '');

       FOR i IN 1..p_copy_columns_table.COUNT LOOP
         --  IF (AMS_DEBUG_HIGH_ON) THEN    Ams_Utility_Pvt.debug_message('The Initial Vlues:' || p_copy_columns_table(i).column_name);  END IF;
		   --  IF (AMS_DEBUG_HIGH_ON) THEN    Ams_Utility_Pvt.debug_message('The Initial Vlues:' || p_copy_columns_table(i).column_value);  END IF;
		     IF (p_copy_columns_table(i).column_name = 'eventScheduleIdRec'
		         AND  p_copy_columns_table(i).column_value = 'undefined' )THEN
	             l_copy_sched_cont_flag := 'N';
		     END IF;

       END LOOP;

       IF (AMS_DEBUG_HIGH_ON) THEN



           AMS_UTILITY_PVT.debug_message('eventScheduleId Rec:' || l_event_schedule_ids);

       END IF;

       WHILE (l_copy_sched_cont_flag <> 'N') LOOP

           -- Separate comma separated l_schedule_ids to number values and use for copy
           l_index := INSTR(l_event_schedule_ids,',');

           IF l_index > 0 THEN
              l_str_event_schedule_id := SUBSTR(l_event_schedule_ids, 1, l_index-1);
              l_tmp_event_schedule_id := TO_NUMBER(l_str_event_schedule_id);
              l_event_schedule_ids := SUBSTR(l_event_schedule_ids, l_index+1);
           ELSE
              l_copy_sched_cont_flag := 'N';
              l_tmp_event_schedule_id := TO_NUMBER(l_event_schedule_ids);
           END IF;


           IF l_tmp_event_schedule_id IS NOT NULL THEN
              IF (AMS_DEBUG_HIGH_ON) THEN

                  AMS_UTILITY_PVT.debug_message('calling event schedule copy for event_schedule id:' || l_tmp_event_schedule_id);
              END IF;

              copy_act_offers(
                 p_src_act_type   => G_OBJECT_TYPE_MODEL,
                 p_new_act_type   => G_OBJECT_TYPE_MODEL,
                 p_src_act_id     => l_tmp_event_schedule_id,
                 p_new_act_id     => l_new_event_header_id,
	         p_errnum         => l_errnum,
                 p_errcode        => l_errcode,
                 p_errmsg         => l_errmsg
               );


               IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
           END IF;

        END LOOP; -- WHILE (l_copy_sched_cont_flag <> 'N')
  END IF;


   p_event_header_rec.event_header_id:=l_new_event_header_id;
   AMS_EVENTHEADER_PVT.complete_evh_rec(p_event_header_rec,l_new_reference_rec);
   x_new_object_id:= l_new_event_header_id;
   x_custom_setup_id:= l_new_reference_rec.custom_setup_id;



   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO copy_event_header;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO copy_event_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO copy_event_header;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );


END copy_event_header;

END AMS_Event_Objects_Copy_PVT;

/
