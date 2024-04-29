--------------------------------------------------------
--  DDL for Package Body CSZ_INTERACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSZ_INTERACTION_PVT" 
/* $Header: cszvintb.pls 120.0 2005/06/01 11:18:19 appldev noship $ */
AS
   -- event types used in end_interaction
   APPLY CONSTANT VARCHAR2(10)  := 'Apply';
   STOP CONSTANT VARCHAR2(10)   := 'Stop';
   CANCEL CONSTANT VARCHAR2(10) := 'Cancel';

   -- Values seeded in jtf_ih_actions  table for Service
   SR_UPDATE CONSTANT VARCHAR(30) := 'Cs Sr Upd';
   SR_CANCEL CONSTANT VARCHAR(30) := 'Cancel SR';
   SR_MEDIA_TYPE CONSTANT VARCHAR(30) := 'TELEPHONE';
   SR_MODULE CONSTANT VARCHAR(30) := 'Service Request';

   /*------------------------------------------------------*/
   /* procedure name: begin_interaction                    */
   /* description :  Creates a new interaction interaction */
   /*                record                                */
   /* logic       :  Open MediaItem, then create interaction */
   /*                and add activity.                      */
   /*------------------------------------------------------*/

   PROCEDURE begin_interaction ( p_incident_id      IN  NUMBER,
       p_cust_party_id    IN  NUMBER,
       p_resp_appl_id     IN  NUMBER,
       p_resp_id          IN  NUMBER,
       p_user_id          IN  NUMBER,
       p_login_id         IN  NUMBER,
       p_direction        IN  VARCHAR2,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2,
       x_interaction_id   OUT NOCOPY NUMBER,
       x_creation_time    OUT NOCOPY DATE )
   AS
       -- Media Item handling variables
       l_media_rec         JTF_IH_PUB.media_rec_type;
       l_media_id          NUMBER;

       -- Interaction Handling Variables
       l_interaction_rec    JTF_IH_PUB.interaction_rec_type;
       l_interaction_id     NUMBER;
       l_wrap_id            NUMBER;
       l_outcome_id         NUMBER;
       l_outcome_short_desc VARCHAR2(100);
       l_result_id          NUMBER;
       l_result_required    VARCHAR2(100);
       l_result_short_desc  VARCHAR2(100);
       l_reason_required    VARCHAR2(100);
       l_reason_id          VARCHAR2(100);
       l_reason_short_desc  VARCHAR2(100);
       l_action_value       VARCHAR2(30);
       l_action_id          NUMBER;

       -- Activity Handling Variables
       l_activity_rec     JTF_IH_PUB.activity_rec_type;
       l_activity_id      NUMBER;

      -- local variables
       l_api_version      CONSTANT NUMBER := 1.0;
       l_init_msg_list    VARCHAR2(10) := Fnd_Api.G_TRUE;
       l_commit           VARCHAR2(10) := Fnd_Api.G_FALSE;
       l_msg_count        NUMBER;
       l_msg_data         VARCHAR2(2000);
       l_return_status    VARCHAR2(4);
   begin
     -- establish save point
     SAVEPOINT begin_interaction_sp;

     -- standard call to check for call compatibility.
     IF Fnd_Api.to_boolean(l_init_msg_list)
     THEN
       Fnd_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

     --open new media item and return media id.
     begin
         -- setup Media record.
         l_media_rec.media_item_type := SR_MEDIA_TYPE;
         --verify direction flag, set in media rec
         if (p_direction <> 'INBOUND' AND p_direction <> 'OUTBOUND') then
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
           Fnd_Message.set_name('CS','Error:Invalid Direction specified for Interaction.');
           Fnd_Msg_Pub.ADD;
           RAISE Fnd_Api.G_EXC_ERROR;
         else
           l_media_rec.direction := p_direction;
         end if;

         --verify p_resp_appl_id, p_resp_id, p_user_id, p_login_id are valid
         if (p_resp_appl_id = null OR p_resp_appl_id = Fnd_Api.G_MISS_NUM) then
            Fnd_Message.SET_NAME('CS','Invalid Application id found');
            Fnd_Msg_Pub.ADD;
         end if;

         if (p_resp_id = null OR p_resp_id = Fnd_Api.G_MISS_NUM) then
            Fnd_Message.SET_NAME('CS','Invalid Responsibility id found');
            Fnd_Msg_Pub.ADD;
         end if;

         if (p_user_id = null OR p_user_id = Fnd_Api.G_MISS_NUM) then
            Fnd_Message.SET_NAME('CS','Invalid User Id');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         end if;

         if (p_login_id = null OR p_login_id = Fnd_Api.G_MISS_NUM) then
            Fnd_Message.SET_NAME('CS','Invalid User Login Id');
            Fnd_Msg_Pub.ADD;
         end if;

         begin
          -- open media item
           JTF_IH_PUB.open_mediaitem ( l_api_version,
                                      l_init_msg_list,
                                      l_commit,                 -- commit flag
                                      p_resp_appl_id,
                                      p_resp_id,
                                      p_user_id,
                                      p_login_id,
                                      l_return_status,
                                      l_msg_count,
                                      l_msg_data,
                                      l_media_rec,
                                      l_media_id );              -- returns media id
         exception
          when others then
             -- throw error
            Fnd_Message.SET_NAME('CS','Error while trying to Open MediaItem');
            Fnd_Msg_Pub.ADD;
            rollback to begin_interaction_sp;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
         end;
      exception
        when others then
            rollback to begin_interaction_sp;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
      end;

      -- Open interaction and return interaction id if successful
      begin
        -- setup Interaction record
        l_interaction_rec.handler_id := p_resp_appl_id; --(application ID here!!!)
        l_interaction_rec.party_id := p_cust_party_id; -- Customer Party ID

        -- Agent resource id
        begin
          SELECT resource_id INTO l_interaction_rec.resource_id FROM jtf_rs_resource_extns  WHERE user_id = p_user_id;
        exception
           when NO_DATA_FOUND then
             x_return_status := Fnd_Api.G_RET_STS_ERROR;
             Fnd_Message.SET_NAME('CS','No resource Id found for User:' || p_user_id);
             Fnd_Msg_Pub.ADD;
             raise NO_DATA_FOUND;
        end;
        -- Profile Values from wrap up
        begin
          select FND_PROFILE.Value('CSC_CC_WRAPUP_INTERACTION_DEFAULTS') into l_wrap_id from dual;
        exception
          when NO_DATA_FOUND then
             x_return_status := Fnd_Api.G_RET_STS_ERROR;
             Fnd_Message.SET_NAME('CS','Profile "CSC_CC_WRAPUP_INTERACTION_DEFAULTS" could not be found');
             Fnd_Msg_Pub.ADD;
             raise NO_DATA_FOUND;
        end;

        -- Retreive default values for populating the result, reason, outcome fields in JTF_IH_ACTIVITIES table
        begin
           select outcome_id, result_id, reason_id into l_outcome_id, l_result_id, l_reason_id from jtf_ih_wrap_ups_vl where wrap_id = l_wrap_id;
        exception
           when NO_DATA_FOUND then
              x_return_status := Fnd_Api.G_RET_STS_ERROR;
              Fnd_Message.SET_NAME('CS','Outcome, result, reason codes could not be found');
              Fnd_Msg_Pub.ADD;
              raise NO_DATA_FOUND;
        end;
        l_action_value := SR_UPDATE;
        --  Retreives the valid actionID for SR update actions.
        begin
           SELECT nvl(action_id,0) into l_action_id
           FROM jtf_ih_actions_tl
           WHERE action = l_action_value
           AND rownum < 2;
        exception
           when NO_DATA_FOUND then
              x_return_status := Fnd_Api.G_RET_STS_ERROR;
              Fnd_Message.SET_NAME('CS','Action Id could not be found for SR Update action');
              Fnd_Msg_Pub.ADD;
              raise NO_DATA_FOUND;
        end;

        l_interaction_rec.outcome_id := l_outcome_id;
        l_interaction_rec.reason_id := l_reason_id;
        l_interaction_rec.result_id := l_result_id;

        begin
           JTF_IH_PUB.open_Interaction( l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        p_resp_appl_id,
                                        p_resp_id,
                                        p_user_id,
                                        p_login_id,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_interaction_rec,
                                        l_interaction_id  );
        exception
          when others then
            rollback to begin_interaction_sp;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
        end;
     exception
          when others then
            rollback to begin_interaction_sp;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
     end;
     -- Add activity for this interaction and return activity id if successful
     begin
       -- Add activity :
       l_activity_rec.action_id := l_action_id;  -- Created
       l_activity_rec.interaction_id := l_interaction_id; -- ID of the interaction for this activity
       l_activity_rec.doc_id := p_incident_id;   -- ID of the interaction for this activity
       l_activity_rec.media_id := l_media_id;    -- ID of  Phone call, e-mail (Media)  - returned from the open_mediaitem call
       l_activity_rec.outcome_id := l_outcome_id;
       l_activity_rec.reason_id := l_reason_id;
       l_activity_rec.result_id := l_result_id;
       begin
         select action_item_id into l_activity_rec.action_item_id from jtf_ih_action_items_tl where short_description = SR_MODULE;
       exception
         when NO_DATA_FOUND then
              x_return_status := Fnd_Api.G_RET_STS_ERROR;
              Fnd_Message.SET_NAME('CS','ActionItemId not found for "Service Request" module');
              Fnd_Msg_Pub.ADD;
              raise NO_DATA_FOUND;
       end;
       begin
         JTF_IH_PUB.add_activity( l_api_version,
                                l_init_msg_list,
                                l_commit,
                                p_resp_appl_id,
                                p_resp_id,
                                p_user_id,
                                p_login_id,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_activity_rec,
                                l_activity_id );
       exception
         when others then
              x_return_status := Fnd_Api.G_RET_STS_ERROR;
              Fnd_Message.SET_NAME('CS','Error while creating Activity record');
              Fnd_Msg_Pub.ADD;
              raise Fnd_Api.G_EXC_ERROR;
       end;
     exception
       when others then
           rollback to begin_interaction_sp;
           x_return_status := Fnd_Api.G_RET_STS_ERROR;
           Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
     end;
      -- set up return values when successful.
      x_interaction_id := l_interaction_id;
      x_creation_time := sysdate;

  exception
    when others then
       rollback to begin_interaction_sp;
       x_return_status := Fnd_Api.G_RET_STS_ERROR;
       Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
  end;

   /*------------------------------------------------------*/
   /* procedure name: end_interaction                      */
   /* description :  Ends given interaction record         */
   /* logic       :  Update activity to closed, then update*/
   /*                interaction and close media item.     */
   /*------------------------------------------------------*/

   PROCEDURE end_interaction
     ( p_interaction_id           IN   NUMBER,
       p_event                    IN   VARCHAR2,
       p_cust_party_id            IN   NUMBER,
       p_resp_appl_id             IN   NUMBER,
       p_resp_id                  IN   NUMBER,
       p_user_id                  IN   NUMBER,
       p_login_Id                 IN   NUMBER,
       x_return_status            OUT NOCOPY  VARCHAR2,
       x_msg_count                OUT NOCOPY  NUMBER,
       x_msg_data                 OUT NOCOPY  VARCHAR2) as

       l_media_rec       JTF_IH_PUB.media_rec_type;
       l_activity_rec    JTF_IH_PUB.activity_rec_type;
       l_activity_id     NUMBER;
       l_media_id        NUMBER;

        -- Interaction Handling Variables
       l_interaction_rec JTF_IH_PUB.interaction_rec_type;
       l_interaction_id  NUMBER;
       l_wrap_id NUMBER;
       l_outcome_id NUMBER;
       l_outcome_short_desc VARCHAR2(100);
       l_result_id NUMBER;
       l_result_required VARCHAR2(100);
       l_result_short_desc VARCHAR2(100);
       l_reason_required VARCHAR2(100);
       l_reason_id VARCHAR2(100);
       l_reason_short_desc VARCHAR2(100);
       l_action_value VARCHAR2(30);
       l_action_id NUMBER;

       -- local variables
       l_api_version      CONSTANT NUMBER := 1.0;
       l_init_msg_list    VARCHAR2(10) := Fnd_Api.G_TRUE;
       l_commit           VARCHAR2(10) := Fnd_Api.G_FALSE;
       l_msg_count        NUMBER;
       l_msg_data         VARCHAR2(2000);
       l_return_status    VARCHAR2(4);

   begin
     -- establish save point
     SAVEPOINT end_interaction_sp;

     -- standard call to check for call compatibility.
     IF Fnd_Api.to_boolean(l_init_msg_list)
     THEN
       Fnd_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

     -- retrieve media id for given interaction
     begin
       select media_id into l_media_id from jtf_ih_activities_vl
       where interaction_id = p_interaction_id;
     exception
       when NO_DATA_FOUND then
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            -- dbms_output.put_line ('No Media Id found for corresponding Interaction Id:' || p_interaction_id);
            Fnd_Message.SET_NAME('CS','No Media Id found for corresponding Interaction Id:' || p_interaction_id);
            Fnd_Msg_Pub.ADD;
            RAISE NO_DATA_FOUND;
       when others then
            -- dbms_output.put_line ('EndInteraction :: Error while retrieving media Id for Interaction Id:' || p_interaction_id);
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Message.SET_NAME('CS','EndInteraction :: Error while retrieving media Id for Interaction Id:' || p_interaction_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
     end;

     if (p_event = APPLY OR p_event = STOP) then
        l_action_value := SR_UPDATE;
     else
        l_action_value := SR_CANCEL;
     end if;
     -- dbms_output.put_line ('Action=' || l_action_value);
     --  Retreives the valid actionID for \223SR update\224 actions.
     begin
       SELECT nvl(action_id,0) into l_action_id
       FROM jtf_ih_actions_tl
       WHERE action = l_action_value
       AND rownum < 2;
     exception
       when NO_DATA_FOUND then
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            -- dbms_output.put_line ('No Action Id found for corresponding Action:' || l_action_value);
            Fnd_Message.SET_NAME('CS','No Action Id found for corresponding Action:' || l_action_value);
            Fnd_Msg_Pub.ADD;
            Raise NO_DATA_FOUND;
       when others then
            -- dbms_output.put_line ('EndInteraction :: Error while retrieving action Id for Action:' || l_action_value);
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Message.SET_NAME('CS','EndInteraction :: Error while retrieving action Id for Action:' || l_action_value);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
     end;
     -- dbms_output.put_line ('ActionID=' || l_action_id || ' Status=' || x_return_status);
     l_activity_rec.action_id := l_action_id;  -- Created
     begin
       select action_item_id into l_activity_rec.action_item_id from jtf_ih_action_items_tl where short_description = SR_MODULE;
     exception
       when NO_DATA_FOUND then
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Message.SET_NAME('CS','ActionItemId not found for "Service Request" module');
          Fnd_Msg_Pub.ADD;
          raise NO_DATA_FOUND;
     end;
     l_activity_rec.interaction_id := p_interaction_id;
     l_activity_rec.end_date_time := sysdate;

     -- ID of the interaction for this activity
     begin
       JTF_IH_PUB.update_activity(
           l_api_version,
           l_init_msg_list,
           l_commit,
           p_resp_appl_id,
           p_resp_id,
           p_user_id,
           p_login_id,
           l_return_status,
           l_msg_count,
           l_msg_data,
           l_activity_rec,
           l_activity_id );
      exception
        when others then
          -- dbms_output.put_line ('Error after updateActivity-' || l_msg_data);
          rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
      end;

      -- dbms_output.put_line ('Updated Activity=' || l_activity_id || ' Status=' || x_return_status);
      l_interaction_rec.handler_id := p_resp_appl_id; --(application ID here!!!)
      l_interaction_rec.party_id := p_cust_party_id; -- Customer Party ID
      l_interaction_rec.end_date_time := sysdate;
      l_interaction_rec.interaction_id := p_interaction_id;
      -- Agent resource id
      begin
       SELECT resource_id INTO l_interaction_rec.resource_id FROM jtf_rs_resource_extns  WHERE user_id = p_user_id;
     exception
       when NO_DATA_FOUND then
          rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Message.SET_NAME('CS','No resource Id found for User:' || p_user_id);
          Fnd_Msg_Pub.ADD;
          raise NO_DATA_FOUND;
     end;
      -- dbms_output.put_line ('Got Resource Id=' || l_interaction_rec.resource_id|| ' Status=' || x_return_status);

     -- Profile Values from wrap up
     begin
       select FND_PROFILE.Value('CSC_CC_WRAPUP_INTERACTION_DEFAULTS') into l_wrap_id from dual;
     exception
       when NO_DATA_FOUND then
          rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Message.SET_NAME('CS','Profile "CSC_CC_WRAPUP_INTERACTION_DEFAULTS" could not be found');
          Fnd_Msg_Pub.ADD;
          raise NO_DATA_FOUND;
     end;

      -- dbms_output.put_line ('Got Profile Id=CSC_CC_WRAPUP_INTERACTION_DEFAULTS'|| ' Status=' || x_return_status);
     -- Retreive default values for populating the result, reason, outcome fields in JTF_IH_ACTIVITIES table
     begin
       select outcome_id, result_id, reason_id into l_outcome_id, l_result_id, l_reason_id from jtf_ih_wrap_ups_vl where wrap_id = l_wrap_id;
     exception
       when NO_DATA_FOUND then
          rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Message.SET_NAME('CS','Outcome, result, reason codes could not be found');
          Fnd_Msg_Pub.ADD;
          raise NO_DATA_FOUND;
     end;
      -- dbms_output.put_line ('Got Outcome,reason,result Id=' || l_outcome_id || ' Status=' || x_return_status);

     -- Close the Interaction
     begin
       JTF_IH_PUB.close_interaction( l_api_version,
                                     l_init_msg_list,
                                     l_commit,
                                     p_resp_appl_id,
                                     p_resp_id,
                                     p_user_id,
                                     p_login_id,
                                     l_return_status,
                                     l_msg_count,
                                     l_msg_data,
                                     l_interaction_rec );
     exception
       when others then
        rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
     end;
     l_media_rec.media_id := l_media_id;

      -- dbms_output.put_line ('Glosed Interaction'|| ' Status=' || x_return_status );
     -- Close instance of media item
     begin
       Jtf_Ih_Pub.close_MediaItem(
                          l_api_version,
                          l_init_msg_list,
                          l_commit,
                          p_resp_appl_id,
                          p_resp_id,
                          p_user_id,
                          p_login_id,
                          l_return_status,
                          l_msg_count,
                          l_msg_data,
                          l_media_rec );
     exception
       when others then
          rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
     end;
   -- dbms_output.put_line ('Closed Media Item'|| ' Status=' || x_return_status );
  exception
       when others then
          rollback to end_interaction_sp;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          Fnd_Msg_Pub.count_and_get( p_encoded => Fnd_Api.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
  end;


END;

/
