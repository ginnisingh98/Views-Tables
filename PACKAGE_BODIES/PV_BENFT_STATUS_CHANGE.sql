--------------------------------------------------------
--  DDL for Package Body PV_BENFT_STATUS_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BENFT_STATUS_CHANGE" AS
/* $Header: pvstchgb.pls 120.7 2006/05/09 16:19:04 saarumug ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_BENFT_STATUS_CHANGE';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvstchgb.pls';

/**
* Procedure to convert comma separated user list to a
* wf_directory.UserTable type.
**/
PROCEDURE CONVERT_LIST_TO_TABLE(p_role_list      IN VARCHAR2
                                ,x_role_list_tbl OUT NOCOPY wf_directory.UserTable);


PROCEDURE STATUS_CHANGE_notification(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   P_BENEFIT_ID          IN  NUMBER,
   P_STATUS              IN  VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_PARTNER_ID          IN  NUMBER,
   p_msg_callback_api    IN  VARCHAR2,
   p_user_callback_api   IN  VARCHAR2,
   p_user_role           IN  VARCHAR2 DEFAULT NULL,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

  l_api_name            CONSTANT VARCHAR2(30) := 'STATUS_CHANGE_NOTIFICATION';
  l_api_version_number  CONSTANT NUMBER       := 1.0;

  CURSOR lc_get_benefit_type (pc_benefit_id number) is
  select benefit_type_code from pv_ge_benefits_b
  where benefit_id = pc_benefit_id;

  CURSOR lc_get_message (pc_benefit_id number, pc_status varchar2, pc_userrole varchar2) is
  select user_role, wf_message_type, wf_message_name
  from pv_notification_setups
  where benefit_id = pc_benefit_id
  and entity_status = pc_status
  AND user_role like pc_userrole;

  cursor lc_get_cm (pc_partner_id number) is
  select fnd_user.user_name
  from pv_partner_accesses acc, jtf_rs_resource_extns res, fnd_user
  where acc.partner_id = pc_partner_id
  and acc.resource_id = res.resource_id
  and res.user_id = fnd_user.user_id;

  cursor lc_get_approvers (pc_benefit_type varchar2, pc_entity_id number) is
  select fnd_user.user_name
  from pv_ge_temp_approvers apr, fnd_user
  where apr.arc_appr_for_entity_code = pc_benefit_type
  and apr.appr_for_entity_id = pc_entity_id
  and apr.approver_id = fnd_user.user_id
  AND APR.approval_status_code IN ('PENDING_APPROVAL','PENDING_DEFAULT')
  and apr.approver_type_code = 'USER';

  l_benefit_type    varchar2(8);
  l_adhoc_role      varchar2(200);
  l_role_list       varchar2(3000);
  l_user_type       varchar2(30);
  l_msg_type        varchar2(30);
  l_msg_name        varchar2(30);
  l_itemkey         varchar2(200);
  l_group_notify_id number;
  l_context         varchar2(1000);
  l_has_notification boolean := false;

  l_role_list_tbl   WF_DIRECTORY.UserTable; --Bug 5124079

BEGIN
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.start',
       'Benefit id:' || p_benefit_id || '. Entity id: ' || p_entity_id ||
       '. Status:' || p_status || '. Partner id:' || p_partner_id ||
      '. Message callback API: ' || p_msg_callback_api || 'User type: ' || nvl(p_user_role,'NULL') ||
      '. User Callback API: ' || p_user_callback_api);
    end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open lc_get_benefit_type(pc_benefit_id => p_benefit_id);
   fetch lc_get_benefit_type into l_benefit_type;
   close lc_get_benefit_type;

   IF l_benefit_type is null then
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Benefit does not exist. Benefit id: ' || p_benefit_id);
      fnd_msg_pub.Add;
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   if p_user_role is null then
      open lc_get_message(pc_benefit_id => p_benefit_id, pc_status => p_status, pc_userrole => '%');
   else
      open lc_get_message(pc_benefit_id => p_benefit_id, pc_status => p_status, pc_userrole => p_user_role);
   end if;

   loop
      fetch lc_get_message into l_user_type, l_msg_type, l_msg_name;
      exit when lc_get_message%notfound;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
          'Notification Setup: User type:' || l_user_type || '. Message type:' || l_msg_type
          || '. Message Name:' || l_msg_name);
      END IF;

      l_has_notification := true;

      l_role_list := '';

      execute immediate 'select ' || p_user_callback_api ||
                        '(:itemtype, :entity_id, :usertype, :status) from dual'
      into l_role_list using l_benefit_type, p_entity_id, l_user_type, p_status ;

      if l_role_list is null then

          if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
              'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
              'None found from user callback api.  executing system sql');
           END IF;

          if l_user_type = 'CHANNEL_MANAGER' then

              for l_row in lc_get_cm(pc_partner_id => p_partner_id) loop
                 l_role_list := l_role_list || ',' || l_row.user_name;
              end loop;
              l_role_list := substr(l_role_list,2);

          elsif l_user_type = 'BENEFIT_APPROVER' then

              for l_row in lc_get_approvers(pc_benefit_type => l_benefit_type, pc_entity_id => p_entity_id) loop
                 l_role_list := l_role_list || ',' || l_row.user_name;
              end loop;
              l_role_list := substr(l_role_list,2);

          elsif l_user_type = 'DQM_APPROVER' then

              for l_row in lc_get_approvers(pc_benefit_type => 'PVDQMAPR', pc_entity_id => p_entity_id) loop
                 l_role_list := l_role_list || ',' || l_row.user_name;
              end loop;
              l_role_list := substr(l_role_list,2);

          else
             if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                 'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
                 'Possible error.  Unrecognized user role:' || l_user_type);
              END IF;
          end if;
      end if;

      CONVERT_LIST_TO_TABLE(p_role_list     => l_role_list,
                            x_role_list_tbl => l_role_list_tbl);

      if l_role_list_tbl.COUNT > 0 then
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
             'user list for ' || l_user_type || ' is:' || l_role_list);
         END IF;

         l_itemkey := l_msg_type||'|'||l_user_type||'|'||l_msg_name||'|'||p_entity_id||
                      '|'||to_char(sysdate,'YYYYMMDDHH24MISS');

         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
             'Creating process for itemtype:' || l_benefit_type || '. itemkey: ' || l_itemkey);
         END IF;

         wf_engine.CreateProcess ( ItemType => l_BENEFIT_TYPE,
                                   ItemKey  => l_itemkey,
                                   process  => 'NOOP_PROCESS',
                                   user_key  => l_itemkey);

         execute immediate 'BEGIN ' ||
                           p_msg_callback_api || '(:itemtype, :itemkey, :entity_id, :usertype, :status); ' ||
                          'END;'
         using l_benefit_type, l_itemkey, p_entity_id, l_user_type, p_status;

         l_adhoc_role := l_itemkey;
         wf_directory.CreateAdHocRole2(role_name         => l_adhoc_role,
                                       role_display_name => l_adhoc_role,
                                       role_users        => l_role_list_tbl);

         l_context := l_benefit_type || ':' || l_itemkey || ':';

         l_group_notify_id := wf_notification.sendGroup(
                                role         => l_adhoc_role,
                                msg_type     => l_msg_type,
                                msg_name     => l_msg_name,
                                due_date     => null,
                                callback     => 'wf_engine.cb',
                                context      => l_context,
                                send_comment => NULL,
                                priority     => NULL );

         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
             'Sent notification to role: ' || l_adhoc_role ||
             ' Using message: ' || l_msg_name || '. Notify id: ' || l_group_notify_id );
         END IF;

         wf_engine.StartProcess(itemtype => l_benefit_type,
                                itemkey  => l_itemkey);

     else
        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
            'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
            'No users found for user type: ' || l_user_type);
        END IF;
     end if;

   end loop;
   close lc_get_message;

   if not l_has_notification then
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
          'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.info',
          'No Notifications has been setup for this benefit');
      END IF;
   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.end', 'Exiting' );
   end if;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.error', fnd_msg_pub.get(p_encoded => 'F') );
      end if;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.unexpected', fnd_msg_pub.get(p_encoded => 'F') );
      end if;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_NOTIFICATION.unexpected', fnd_msg_pub.get(p_encoded => 'F') );
      end if;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
END;


/*********************************************************
* This PROCEDURE is used to convert a comma separated list
* of Users who will be notified using a Workflow notification
* Bug 5124097 requires the CreateAdHocRole2 API to be called
* instead od CreateAdHocRole so that usernames with blank
* spaces can be supported. So this procedure converts a
* comma separated list like JOHN SMITH,TOM JONES,JIM BATES
* to a wf_directory.UserTable with these names.
* - JOHN SMITH
* - TOM JONES
* - JIM BATES
* this is called by the STATUS_CHANGE_notification API just before
* the call to CreateAdHocRole2.
*
* Updates : Made changes for Bug 5189270.
*/
PROCEDURE CONVERT_LIST_TO_TABLE(p_role_list      IN VARCHAR2
                                ,x_role_list_tbl OUT NOCOPY wf_directory.UserTable)
IS
    l_index NUMBER := 1;
    l_to_position NUMBER := 1;
    l_from_position NUMBER := 1;
    l_temp VARCHAR2(100);
BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        'pv.plsql.CONVERT_LIST_TO_TABLE.GET_PRODUCTS.begin',
        'p_role_list '||p_role_list);
    END IF;

    -- This call will give 0 for no occurances of ',' and
    -- the index of ',' in the string if it does occur in
    -- the string. If it is in the first position
    -- it will return 1
    l_to_position := INSTR(p_role_list,',',1,l_index);

    IF ( LENGTH(p_role_list) > 0 AND l_to_position > 0 ) THEN
        WHILE (l_to_position <> 0 )
        LOOP

            IF (l_from_position = 1 and l_to_position <> 0 ) THEN
                l_temp := substr(p_role_list,l_from_position,l_to_position-1);
            ELSIF(l_from_position > 1 and l_to_position <> 0 ) THEN
                l_temp := substr(p_role_list,l_from_position+1,l_to_position-l_from_position-1);
            END IF;

            IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                'pv.plsql.CONVERT_LIST_TO_TABLE.GET_PRODUCTS.begin',
                'Next User===>'||l_temp);
            END IF;

            x_role_list_tbl(l_index) := l_temp;
            IF l_to_position <> 0 THEN
                l_index := l_index + 1;
                l_from_position := l_to_position;
                l_to_position := INSTR(p_role_list,',',1,l_index);
            END IF;
        END LOOP;

        l_temp := substr(p_role_list,l_from_position+1,LENGTH(p_role_list)-l_from_position+1);
        x_role_list_tbl(l_index) := l_temp;

    ELSE

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
            'pv.plsql.CONVERT_LIST_TO_TABLE.GET_PRODUCTS.begin',
            'There were no Commas so only one user...');
        END IF;

        IF(TRIM(p_role_list) IS NOT NULL) THEN
            x_role_list_tbl(l_index) := p_role_list;
        END IF;

    END IF;

    FOR i IN 1..x_role_list_tbl.COUNT
    LOOP
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
            'pv.plsql.CONVERT_LIST_TO_TABLE.GET_PRODUCTS.begin',
            'USER ['||x_role_list_tbl(i)||']');
        END IF;
    END LOOP;

EXCEPTION
WHEN OTHERS THEN

    IF( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.CONVERT_LIST_TO_TABLE.unexpected', FALSE );
    END IF;

END CONVERT_LIST_TO_TABLE;


--=============================================================================+
--| Public Procedure                                                           |
--|    STATUS_CHANGE_LOGGING                                                   |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE STATUS_CHANGE_LOGGING(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   P_BENEFIT_ID          IN  NUMBER,
   P_STATUS              IN  VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_PARTNER_ID          IN  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2)
is
   l_api_name            CONSTANT VARCHAR2(30) := 'STATUS_CHANGE_LOGGING';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_access_level      varchar2(1) := 'V';

   l_message_name      varchar2(30);
   l_decline_code      varchar2(30);
   l_entity_type       varchar2(20);
   l_referral_code     varchar2(50);
   l_benefit_type      varchar2(10);
   l_linked_to         number;
   l_order_id          number;
   l_log_params_tbl    pvx_utility_pvt.log_params_tbl_type;
   l_entity_number     varchar2(100);
   l_referral_code_ref varchar2(50);
   l_approved_count    NUMBER;
   l_decline_reason_code varchar2(30);

   cursor lc_access_level (pc_status varchar2, pc_benefit_type varchar2) is
   select 'P' from pv_benft_status_maps
   WHERE partner_status_code = pc_status
   and benefit_type = pc_benefit_type;

   cursor lc_get_entity_detail (pc_entity_id number) is
   select ref.referral_code, ben.benefit_type_code, ref.entity_type, ref.entity_id_linked_to,
   ref.decline_reason_code, ref.order_id
   from pv_referrals_b ref, pv_ge_benefits_b ben
   where ref.referral_id = pc_entity_id and ref.benefit_id = ben.benefit_id;

   cursor lc_oppty_linked_flag (pc_lead_id number) is
   select lead_number, prm_referral_code from as_leads_all where lead_id = pc_lead_id;

   cursor lc_lead_linked_flag (pc_lead_id number) is
   select lead_number, decode(source_system,'REFERRAL',source_primary_reference,NULL)
   from as_sales_leads where sales_lead_id = pc_lead_id;

   cursor lc_ref_linked_flag (pc_referral_id number) is
   select referral_code from pv_referrals_b where referral_id = pc_referral_id;

    cursor lc_event_reason IS
    select decline_reason_code from pv_referrals_b
    where  referral_id = P_ENTITY_ID;

    cursor lc_current_approvers(pc_benefit_type varchar2, pc_referral_id number) is
    select apr.approver_id, jrre.source_name
    from pv_ge_temp_approvers apr, jtf_rs_resource_extns jrre
    where apr.arc_appr_for_entity_code = pc_benefit_type
    and apr.appr_for_entity_id = pc_referral_id
    and apr.approver_id = jrre.user_id
    and APR.approval_status_code IN ('PENDING_APPROVAL','PENDING_DEFAULT')
    and apr.approver_type_code = 'USER';

BEGIN
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_LOGGING.start',
       'Benefit id:' || p_benefit_id || '. Entity id: ' || p_entity_id ||
       '. Status:' || p_status || '. Partner id:' || p_partner_id);
    end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open lc_get_entity_detail (pc_entity_id => p_entity_id);
   fetch lc_get_entity_detail into l_referral_code, l_benefit_type, l_entity_type,
         l_linked_to, l_decline_code, l_order_id;
   close lc_get_entity_detail;

    open lc_access_level(pc_status => p_status, pc_benefit_type => l_benefit_type);
    fetch lc_access_level into l_access_level;
    close lc_access_level;

    l_log_params_tbl(1).param_name := 'REFERRAL_CODE';
    l_log_params_tbl(1).param_value := l_referral_code;

    if l_benefit_type = 'PVREFFRL' then

        if p_status = 'DRAFT' then
            l_message_name := 'PV_LG_REF_DRAFT';

        elsif p_status = 'SUBMITTED_FOR_APPROVAL' then
            l_message_name := 'PV_LG_REF_SUBMITTED';

        elsif p_status = 'APPRVD_PENDNG_CSTMR_DQM' then
            l_message_name := 'PV_LG_REF_APPRVD_PEND_DQM';

        elsif p_status = 'DECLINED' then
            -- --------------------------------------------------------------------
            -- Before check for anything, check if the referral had been approved
            -- at some point in time.
            -- --------------------------------------------------------------------
            FOR x IN (SELECT COUNT(*) approved_count
                      FROM   pv_ge_history_log_vl
                      WHERE  ARC_HISTORY_FOR_ENTITY_CODE = 'PVREFFRL' AND
                             history_for_entity_id       = p_entity_id AND
                             message_code IN ('PV_LG_REF_APPROVED',
                                              'PV_LG_REF_APPROVED_DUP_OPPTY',
                                              'PV_LG_REF_APPROVED_DUP_LEAD',
                                              'PV_LG_REF_APPROVED_DUP_REF'))
            LOOP
               l_approved_count := x.approved_count;
            END LOOP;

            -- --------------------------------------------------------------------
            -- If l_approved_count > 0, this means this referral had been approved
            -- at some point in time.
            -- --------------------------------------------------------------------
            IF (l_approved_count > 0) THEN
               l_message_name := 'PV_LG_REF_REVALUATED_DECLINED';

            -- --------------------------------------------------------------------
            -- All other cases.
            -- --------------------------------------------------------------------
            ELSE
               if l_linked_to is not null and l_entity_type = 'LEAD' then
                   l_message_name := 'PV_LG_REF_DECLINED_DUP_OPPTY';
                   l_log_params_tbl(2).param_name := 'OPP_NUMBER';
                   l_log_params_tbl(2).param_value := l_linked_to;

               elsif l_linked_to is not null and l_entity_type = 'SALES_LEAD' then
                   l_message_name := 'PV_LG_REF_DECLINED_DUP_LEAD';
                   l_log_params_tbl(2).param_name := 'LEAD_NUMBER';
                   l_log_params_tbl(2).param_value := l_linked_to;

               elsif l_linked_to is not null and l_entity_type = 'PVREFFRL' then
                   l_message_name := 'PV_LG_REF_DECLINED_DUP_REF';
                   l_log_params_tbl(2).param_name := 'REF_NUMBER';
                   l_log_params_tbl(2).param_value := l_LINKED_TO;

               else
                   l_message_name := 'PV_LG_REF_DECLINED_REASON';

                   OPEN lc_event_reason;
                   FETCH lc_event_reason INTO l_decline_reason_code;
                   CLOSE lc_event_reason;

                   l_log_params_tbl(2).param_name := 'DECLINE_REASON';
                   l_log_params_tbl(2).param_value := l_decline_reason_code;
                   l_log_params_tbl(2).param_type := 'LOOKUP';
                   l_log_params_tbl(2).param_lookup_type := 'PV_REFERRAL_DECLINE_REASON';

               end if;
            END IF;

        elsif p_status = 'APPROVED' then

            -- since we are only setting prm_referral_code on new oppty/lead, if l_referral_code_ref
            -- is null, it means that a link has happened

            if l_entity_type = 'LEAD' then
               open lc_oppty_linked_flag(pc_lead_id => l_linked_to);
               fetch lc_oppty_linked_flag into l_entity_number, l_referral_code_ref;
               close lc_oppty_linked_flag;

            elsif l_entity_type = 'SALES_LEAD' then
               open lc_lead_linked_flag(pc_lead_id => l_linked_to);
               fetch lc_lead_linked_flag into l_entity_number, l_referral_code_ref;
               close lc_lead_linked_flag;

            elsif l_entity_type = 'PVREFFRL' then
               open lc_ref_linked_flag(pc_referral_id => l_linked_to);
               fetch lc_ref_linked_flag into l_entity_number;
               close lc_ref_linked_flag;
               l_referral_code_ref := null;
            end if;

            if l_referral_code_ref is null and l_entity_type = 'LEAD' then
                l_message_name := 'PV_LG_REF_APPROVED_DUP_OPPTY';
                l_log_params_tbl(2).param_name := 'OPP_NUMBER';
                l_log_params_tbl(2).param_value := l_entity_number;

            elsif l_referral_code_ref is null and l_entity_type = 'SALES_LEAD' then
                l_message_name := 'PV_LG_REF_APPROVED_DUP_LEAD';
                l_log_params_tbl(2).param_name := 'LEAD_NUMBER';
                l_log_params_tbl(2).param_value := l_entity_number;

            elsif l_referral_code_ref is null and l_entity_type = 'PVREFFRL' then
                l_message_name := 'PV_LG_REF_APPROVED_DUP_REF';
                l_log_params_tbl(2).param_name := 'REF_NUMBER';
                l_log_params_tbl(2).param_value := l_entity_number;

            else
                l_message_name := 'PV_LG_REF_APPROVED';
            end if;

        elsif p_status = 'COMP_INITIATED' then
            l_message_name := 'PV_LG_REF_COMP_INITIATED';

        elsif p_status = 'COMP_ACCEPTED' then
            l_message_name := 'PV_LG_REF_COMP_ACCEPTED';

        elsif p_status = 'COMP_CANCELLED' then
            l_message_name := 'PV_LG_REF_COMP_CANCELLED';

        elsif p_status = 'COMP_AWAIT_PRT_ACCEPT' then
            l_message_name := 'PV_LG_REF_COMP_AWAIT_PT_ACCEPT';

        elsif p_status = 'COMP_BEING_NEGOTIATED' then
            l_message_name := 'PV_LG_REF_COMP_NEGOTIATION';

        elsif p_status = 'PAYMENT_BEING_PROCESSED' then
            l_message_name := 'PV_LG_REF_PYMT_BEING_PROCESSED';

        elsif p_status = 'CLOSED_FEE_PAID' then
            l_message_name := 'PV_LG_REF_CLOSED_FEE_PAID';

        elsif p_status = 'CLOSED_DEAD_LEAD' then
            l_message_name := 'PV_LG_REF_CLOSED_DEAD_LEAD';

        elsif p_status = 'CLOSED_LOST_OPPTY' then
            l_message_name := 'PV_LG_REF_CLOSED_LOST_OPPTY';

        elsif p_status = 'EXPIRED' then
            l_message_name := 'PV_LG_REF_EXPIRED';

        elsif p_status = 'MANUAL_CLOSE' then
            l_message_name := 'PV_LG_REF_CLOSED';

        elsif p_status = 'MANUAL_EXTEND' then
            l_message_name := 'PV_LG_REF_EXTENDED';

        end if;

    elsif l_benefit_type = 'PVDEALRN' then

        if p_status = 'DRAFT' then
            l_message_name := 'PV_LG_DEAL_DRAFT';

        elsif p_status = 'SUBMITTED_FOR_APPROVAL' then
            l_message_name := 'PV_LG_DEAL_SUBMITTED';

        elsif p_status = 'APPRVD_PENDNG_CSTMR_DQM' then
            l_message_name := 'PV_LG_DEAL_APPRVD_PEND_DQM';

        elsif p_status = 'DECLINED' then
            -- --------------------------------------------------------------------
            -- Before check for anything, check if the referral had been approved
            -- at some point in time.
            -- --------------------------------------------------------------------
            FOR x IN (SELECT COUNT(*) approved_count
                      FROM   pv_ge_history_log_vl
                      WHERE  ARC_HISTORY_FOR_ENTITY_CODE = 'PVDEALRN' AND
                             history_for_entity_id       = p_entity_id AND
                             message_code IN ('PV_LG_DEAL_APPROVED',
                                              'PV_LG_DEAL_APPROVED_DUP_DEAL',
                                              'PV_LG_DEAL_APPROVED_DUP_LEAD',
                                              'PV_LG_DEAL_APPROVED_DUP_OPPTY'))
            LOOP
               l_approved_count := x.approved_count;
            END LOOP;

            -- --------------------------------------------------------------------
            -- If l_approved_count > 0, this means this referral had been approved
            -- at some point in time.
            -- --------------------------------------------------------------------
            IF (l_approved_count > 0) THEN
               l_message_name := 'PV_LG_DEAL_REVALUATED_DECLINED';

            -- --------------------------------------------------------------------
            -- All other cases.
            -- --------------------------------------------------------------------
            ELSE
               if l_linked_to is not null and l_entity_type = 'LEAD' then
                   l_message_name := 'PV_LG_DEAL_DECLINED_DUP_OPPTY';
                   l_log_params_tbl(2).param_name := 'OPP_NUMBER';
                   l_log_params_tbl(2).param_value := l_linked_to;

               elsif l_linked_to is not null and l_entity_type = 'SALES_LEAD' then
                   l_message_name := 'PV_LG_DEAL_DECLINED_DUP_LEAD';
                   l_log_params_tbl(2).param_name := 'LEAD_NUMBER';
                   l_log_params_tbl(2).param_value := l_linked_to;

               elsif l_linked_to is not null and l_entity_type = 'PVDEALRN' then
                   l_message_name := 'PV_LG_DEAL_DECLINED_DUP_DEAL';
                   l_log_params_tbl(2).param_name := 'DEAL_NUMBER';
                   l_log_params_tbl(2).param_value := l_LINKED_TO;

               else
                   l_message_name := 'PV_LG_DEAL_DECLINED_REASON';

                   OPEN lc_event_reason;
                   FETCH lc_event_reason INTO l_decline_reason_code;
                   CLOSE lc_event_reason;

                   l_log_params_tbl(2).param_name := 'DECLINE_REASON';
                   l_log_params_tbl(2).param_value := l_decline_reason_code;
                   l_log_params_tbl(2).param_type := 'LOOKUP';
                   l_log_params_tbl(2).param_lookup_type := 'PV_REFERRAL_DECLINE_REASON';

               end if;
            END IF;

        elsif p_status = 'APPROVED' then

            if l_entity_type = 'LEAD' then
               open lc_oppty_linked_flag(pc_lead_id => l_linked_to);
               fetch lc_oppty_linked_flag into l_entity_number, l_referral_code_ref;
               close lc_oppty_linked_flag;

            elsif l_entity_type = 'SALES_LEAD' then
               open lc_lead_linked_flag(pc_lead_id => l_linked_to);
               fetch lc_lead_linked_flag into l_entity_number, l_referral_code_ref;
               close lc_lead_linked_flag;

            elsif l_entity_type = 'PVDEALRN' then
               open lc_ref_linked_flag(pc_referral_id => l_linked_to);
               fetch lc_ref_linked_flag into l_entity_number;
               close lc_ref_linked_flag;
               l_referral_code_ref := null;
            end if;

            if l_referral_code_ref is null and l_entity_type = 'LEAD' then
                l_message_name := 'PV_LG_DEAL_APPROVED_DUP_OPPTY';
                l_log_params_tbl(2).param_name := 'OPP_NUMBER';
                l_log_params_tbl(2).param_value := l_entity_number;

            elsif l_referral_code_ref is null and l_entity_type = 'SALES_LEAD' then
                l_message_name := 'PV_LG_DEAL_APPROVED_DUP_LEAD';
                l_log_params_tbl(2).param_name := 'LEAD_NUMBER';
                l_log_params_tbl(2).param_value := l_entity_number;

            elsif l_referral_code_ref is null and l_entity_type = 'PVDEALRN' then
                l_message_name := 'PV_LG_DEAL_APPROVED_DUP_DEAL';
                l_log_params_tbl(2).param_name := 'DEAL_NUMBER';
                l_log_params_tbl(2).param_value := l_entity_number;

            else
                l_message_name := 'PV_LG_DEAL_APPROVED';
            end if;


        elsif p_status = 'CLOSED_LOST_OPPTY' then
            l_message_name := 'PV_LG_DEAL_CLOSED_LOST_OPPTY';

        elsif p_status = 'CLOSED_OPPTY_WON' then
            l_message_name := 'PV_LG_DEAL_CLOSED_WON_OPPTY';

        elsif p_status = 'EXPIRED' then
            l_message_name := 'PV_LG_DEAL_EXPIRED';

        elsif p_status = 'MANUAL_CLOSE' then
            l_message_name := 'PV_LG_DEAL_CLOSED';

        elsif p_status = 'MANUAL_EXTEND' then
            l_message_name := 'PV_LG_DEAL_EXTENDED';
        end if;

    end if;

    if l_message_name is not null then

        PVX_Utility_PVT.create_history_log(
            p_arc_history_for_entity_code => l_benefit_type,
            p_history_for_entity_id       => p_entity_id,
            p_history_category_code       => 'GENERAL',
            p_message_code                => l_message_name,
            p_partner_id                  => p_partner_id,
            p_access_level_flag           => l_access_level,
            p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
            p_comments                    => NULL,
            p_log_params_tbl              => l_log_params_tbl,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data);

        if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
        end if;

    end if;


    if p_status = 'SUBMITTED_FOR_APPROVAL' then

        l_message_name := null;

        IF l_benefit_type = 'PVREFFRL' then
            l_message_name :=   'PV_LG_REF_REQR_APPRVD_BY_USER';
        ELSIF l_benefit_type = 'PVDEALRN' then
            l_message_name :=   'PV_LG_DEAL_REQR_APPRVD_BY_USER';
        ELSIF l_benefit_type = 'PVDQMAPR' then
            l_message_name :=   'PV_LG_DQM_REQR_DEDUP_BY_USER';
        END IF;

        if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                           ,'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_LOGGING.start'
                           ,'Approvers notification Message:'||l_message_name);
        end if;


        FOR  l_approvers IN lc_current_approvers(pc_benefit_type => l_benefit_type
                                                , pc_referral_id => p_entity_id)
        LOOP

            IF l_message_name IS NOT NULL THEN

                l_log_params_tbl.DELETE;
                l_log_params_tbl(1).param_name := 'APPROVER';
                l_log_params_tbl(1).param_value := l_approvers.source_name;

                if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE
                                   ,'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_LOGGING.start'
                                   ,'Logging notification for:'||l_approvers.source_name);
                end if;

                PVX_Utility_PVT.create_history_log(
                          p_arc_history_for_entity_code => l_benefit_type,
                          p_history_for_entity_id       => p_entity_id,
                          p_history_category_code       => 'GENERAL',
                          p_message_code                => l_message_name,
                          p_partner_id                  => p_partner_id,
                          p_access_level_flag           => 'V',
                          p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_10,
                          p_comments                    => NULL,
                          p_log_params_tbl              => l_log_params_tbl,
                          x_return_status               => x_return_status,
                          x_msg_count                   => x_msg_count,
                          x_msg_data                    => x_msg_data);

            END IF;

        END LOOP;

        --if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
        --    raise FND_API.G_EXC_ERROR;
        --end if;

    end if;

    IF FND_API.To_Boolean ( p_commit )   THEN
        COMMIT WORK;
    END IF;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_LOGGING.end', 'Exiting');
    end if;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END;

--=============================================================================+
--| Public Procedure                                                           |
--|    Claim_Ref_Status_Change_Sub                                             |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION CLAIM_REF_STATUS_CHANGE_SUB(
   p_subscription_guid in     raw,
   p_event             in out nocopy wf_event_t)
RETURN VARCHAR2
IS

   l_api_name          CONSTANT VARCHAR2(30) := 'CLAIM_REF_STATUS_CHANGE_SUB';

   l_rule                   varchar2(20);
   l_parameter_list         wf_parameter_list_t := wf_parameter_list_t();
   l_parameter_t            wf_parameter_t := wf_parameter_t(null, null);
   l_parameter_name         l_parameter_t.name%type;
   i                        pls_integer;

   l_msg_callback_api       varchar2(60);
   l_user_callback_api      varchar2(60);
   l_benefit_id             number;
   l_claim_id               number;
   l_status                 varchar2(30);
   l_event_name             varchar2(50);
   l_entity_id              varchar2(100);
   l_partner_id             number;
   l_user_list              varchar2(2000);
   l_msg_count              number;
   l_msg_data               varchar2(2000);
   l_return_status          varchar2(10);
   l_claim_status_code      varchar2(30);
   l_org_id                 number;
   l_referral_id            number;
   l_referral_status_code   varchar2(25);

   CURSOR c_ref_details IS
      SELECT REF.benefit_id, REF.referral_id, REF.partner_id
      FROM   pv_referrals_b REF
      WHERE  REF.claim_id   = l_claim_id;

BEGIN

    l_parameter_list := p_event.getParameterList();
    l_entity_id      := p_event.getEventKey();
    l_event_name     := p_event.getEventName();

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.CLAIM_REF_STATUS_CHANGE_SUB.start',
       'Event name: ' || l_event_name || 'Event key: ' || l_entity_id);
    end if;

    if l_parameter_list is not null then
        -- ---------------------------------------------------------------
        -- Setting referral status based on the event name.
        -- ---------------------------------------------------------------
        IF (LOWER(l_event_name) = 'oracle.apps.ozf.claim.referralapproval') THEN
           l_referral_status_code := 'COMP_AWAIT_PRT_ACCEPT';

        ELSIF (LOWER(l_event_name) = 'oracle.apps.ozf.claim.paymentpaid') THEN
           l_referral_status_code := 'CLOSED_FEE_PAID';

        ELSIF (LOWER(l_event_name) = 'oracle.apps.ozf.claim.updatestatus') THEN
           -- -----------------------------------------------------------------
           -- if status_code is 'CANCELLED'
           -- -----------------------------------------------------------------
           l_referral_status_code := 'COMP_CANCELLED';
        END IF;


        -- ---------------------------------------------------------------
        -- Retrieving parameters.
        -- ---------------------------------------------------------------
        i := l_parameter_list.first;
        while ( i <= l_parameter_list.last) loop

            l_parameter_name := null;
            l_parameter_name  := l_parameter_list(i).getName();

            IF (l_parameter_name = 'CLAIM_ID') then
               l_claim_id := l_parameter_list(i).getValue();

            ELSIF (l_parameter_name = 'ORG_ID') then
               l_org_id   := l_parameter_list(i).getValue();

            ELSIF (l_parameter_name = 'STATUS_CODE') then
               l_claim_status_code := l_parameter_list(i).getValue();
            END IF;

            i := l_parameter_list.next(i);
        end loop;

        -- -----------------------------------------------------------------
        -- If the event is claim update status and
        -- claim status is not 'CANCELLED', exit the code. We don't need
        -- to process this event.
        -- -----------------------------------------------------------------
        IF (LOWER(l_event_name) = 'oracle.apps.ozf.claim.updatestatus' AND
            UPPER(l_claim_status_code) <> 'CANCELLED')
        THEN
           RETURN 'SUCCESS';
        END IF;

        IF (LOWER(l_event_name) = 'oracle.apps.ozf.claim.updatestatus' AND
            l_claim_id IS NULL)
        THEN
           if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
              'pv.plsql.PV_BENFT_STATUS_CHANGE.CLAIM_REF_STATUS_CHANGE_SUB',
              'Event name: ' || l_event_name || '  ' ||
              '--> There is no claim ID for this event.');
           end if;

           RETURN 'SUCCESS';
        END IF;

        -- ----------------------------------------------------------------
        -- Retrieve benefit_id, referral_id, and partner_id from claim_id.
        -- ----------------------------------------------------------------
        FOR x IN c_ref_details LOOP
      l_referral_id := x.referral_id;
      l_benefit_id  := x.benefit_id;
      l_partner_id  := x.partner_id;
   END LOOP;

        IF (l_referral_id IS NULL) THEN
           if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
              'pv.plsql.PV_BENFT_STATUS_CHANGE.CLAIM_REF_STATUS_CHANGE_SUB',
              'Event name: ' || l_event_name || '  ' ||
              'claim_id  : ' || l_claim_id || '  ' ||
              '--> There is no corresponding referral for this claim.');
           end if;

           RETURN 'SUCCESS';
        END IF;

        -- ----------------------------------------------------------------
        -- Update Referral Status
        -- ----------------------------------------------------------------
        UPDATE pv_referrals_b
        SET    referral_status = l_referral_status_code
        WHERE  referral_id     = l_referral_id;


        -- -------------------------------------------------
        -- Raise business event
        -- oracle.apps.pv.benefit.referral.statusChange
        -- -------------------------------------------------
        pv_benft_status_change.status_change_raise(
           p_api_version_number  => 1.0,
           p_init_msg_list       => FND_API.G_FALSE,
           p_commit              => FND_API.G_FALSE,
           p_event_name          => 'oracle.apps.pv.benefit.referral.statusChange',
           p_benefit_id          => l_benefit_id,
           p_entity_id           => l_referral_id,
           p_status_code         => l_referral_status_code,
           p_partner_id          => l_partner_id,
           p_msg_callback_api    => 'pv_benft_status_change.REFERRAL_SET_MSG_ATTRS',
           p_user_callback_api   => 'pv_benft_status_change.REFERRAL_RETURN_USERLIST',
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data);

        if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
            raise FND_API.G_EXC_ERROR;
        end if;

        -- -------------------------------------------------
        -- Log the event.
        -- -------------------------------------------------
        STATUS_CHANGE_LOGGING(
           p_api_version_number  => 1.0,
           p_init_msg_list       => FND_API.G_FALSE,
           p_commit              => FND_API.G_FALSE,
           p_benefit_id          => l_benefit_id,
           P_STATUS              => l_referral_status_code,
           p_entity_id           => l_referral_id,
           p_partner_id          => l_partner_id,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data
       );

        if (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
            raise FND_API.G_EXC_ERROR;
        end if;

    end if;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.CLAIM_REF_STATUS_CHANGE_SUB.end', 'Exiting');
    end if;

    RETURN 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN

    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.CLAIM_REF_STATUS_CHANGE_SUB.unexpected', FALSE );
    end if;

    fnd_msg_pub.Count_And_Get(p_encoded  => FND_API.G_TRUE
                             ,p_count   => l_msg_count
                             ,p_data    => l_msg_data);

    WF_CORE.CONTEXT(G_PKG_NAME, L_API_NAME, P_EVENT.GETEVENTNAME(), P_SUBSCRIPTION_GUID);
    WF_EVENT.SETERRORINFO(P_EVENT,'ERROR');
    RETURN 'ERROR';
END CLAIM_REF_STATUS_CHANGE_SUB;
-- ====================End of CLAIM_REF_STATUS_CHANGE_SUB=======================




PROCEDURE REFERRAL_SET_MSG_ATTRS(
   p_itemtype            IN VARCHAR2,
   p_itemkey             IN VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_USER_TYPE           IN  VARCHAR2,
   P_STATUS              IN  VARCHAR2) IS

  l_api_name            CONSTANT VARCHAR2(30) := 'REFERRAL_SET_MSG_ATTRS';

l_referral_id       number;
l_referral_code     varchar2(50);
l_referral_name     varchar2(100);
l_comp_amount       varchar2(20);
l_partner_org_name  varchar2(100);
l_partner_cont_name varchar2(100);
l_creator_name      varchar2(100);
l_customer_address  varchar2(200);
l_customer_name     varchar2(250);
l_customer_cont_name   varchar2(100);
l_entity_status        varchar2(100);
l_entity_creation_date date;
l_notes_clob           CLOB;
l_notes_varchar        varchar2(4000);
l_notes                varchar2(2000);
l_note_size            binary_integer := 4000;
l_partner_url          varchar2(500);
l_url                  varchar2(500);
l_function_id          number;

/* Dynamic sql for backward compatibility
   of CASE WHEN on 8i PL/SQL */
TYPE t_ref_cursor IS REF CURSOR;
l_get_referral_details  t_ref_cursor;
l_get_referral_details_sql VARCHAR2(3000);


cursor lc_get_notes(pc_entity_type varchar2, pc_entity_id number) is
select notes, NOTES_DETAIL
from jtf_notes_vl
where source_object_code = pc_entity_type
AND SOURCE_OBJECT_ID = pc_entity_id
AND NOTE_STATUS = 'E'  -- only publish notes
ORDER BY CREATION_DATE DESC;

cursor lc_get_function (pc_function_name varchar2) is
select function_id from fnd_form_functions
where function_name = pc_function_name;


BEGIN

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.REFERRAL_SET_MSG_ATTRS.start',
       'Item type:' || p_itemtype || 'Item key:' || p_itemkey || '. Entity id: ' ||
       p_entity_id || '. Status:' || p_status || '. User type: ' || p_user_type);
    end if;

    /* Constructing Dynamic sql for backward compatibility
     * of CASE WHEN on 8i PL/SQL
     */
    l_get_referral_details_sql :=
    'select
    a.referral_id,
    a.referral_code,
    a.referral_name,
    c.party_name,
    a.customer_name,
    ARP_ADDR_LABEL_PKG.FORMAT_ADDRESS_LABEL(Null,a.customer_address1,a.customer_address2,
    a.customer_address3,a.customer_address4,a.customer_CITY,a.customer_COUNTY,a.customer_STATE,
    a.customer_PROVINCE,a.customer_POSTAL_CODE,Null,a.customer_country,Null,Null,Null,Null,Null,
    NULL,NULL,NULL,2000,1,1) ADDRESS,
    hzp.party_name pt_contact_name,
    (CASE
     WHEN creator.source_first_name IS NULL AND creator.source_last_name IS NULL
         AND creator.category = ''PARTY'' THEN
         (SELECT hzp.party_name
         FROM  hz_relationships hzr, hz_parties hzp
         WHERE hzr.party_id = creator.source_id
         AND hzr.subject_type=''PERSON''
         AND hzr.subject_id = hzp.party_id
         AND hzr.object_type= ''ORGANIZATION'')
     ELSE
         creator.source_name
     END) creator_name,
    a.customer_contact_first_name || '' '' || a.customer_contact_last_name,
    lkup.meaning,
    A.creation_date,
    a.actual_compensation_amt || '' '' || a.currency_code
    from
    pv_referrals_vl a,
    pv_partner_profiles b,
    hz_parties c,
    jtf_rs_resource_extns pt_cont,
    jtf_rs_resource_extns creator,
    pv_lookups lkup,
    hz_relationships hzr,
    hz_parties hzp
    where a.referral_id = :1
    and a.partner_id = b.partner_id
    and b.partner_party_id = c.party_id
    and a.partner_contact_resource_id = pt_cont.resource_id
    and a.created_by = creator.user_id
    and a.referral_status = lkup.lookup_code
    and lkup.lookup_type = ''PV_BENEFIT_ENTITY_STATUS''
    AND hzr.party_id = pt_cont.source_id
    AND hzr.subject_type=''PERSON''
    AND hzr.subject_id = hzp.party_id
    AND hzr.object_type= ''ORGANIZATION'' ';


    OPEN l_get_referral_details FOR l_get_referral_details_sql
    USING p_entity_id;

    FETCH l_get_referral_details INTO l_referral_id, l_referral_code, l_referral_name,
        l_partner_org_name, l_customer_name, l_customer_address, l_partner_cont_name,
        l_creator_name, l_customer_cont_name, l_entity_status, l_entity_creation_date, l_comp_amount;
    CLOSE l_get_referral_details;

    open lc_get_notes(pc_entity_type => p_itemtype, pc_entity_id => p_entity_id);
    fetch lc_get_notes into l_notes, l_notes_clob;
    close lc_get_notes;

    l_notes_varchar := dbms_lob.substr(lob_loc => l_notes_clob, amount => l_note_size, offset => 1);
    if l_notes_varchar is null or length(l_notes_varchar) = 0 then
       l_notes_varchar := l_notes;
    end if;


   l_partner_url := fnd_profile.value('PV_WORKFLOW_ISTORE_URL');
   l_partner_url := substr(l_partner_url,1,instr(l_partner_url,'/',1,3)-1); -- just get the http://<host>:<port>

   if p_itemtype = 'PVREFFRL' then

      -- we need vendor and partner side functions because they point to different OAHP and OAPB paraneters
      -- we don't want to hardcode the parameters here to allow users to customize the web_html_call
      -- in order to support this, we will have 2 functions

      open lc_get_function (pc_function_name => 'PV_REF_NOTIF_LINK_VENDOR');
      fetch lc_get_function into l_function_id;
      close lc_get_function;

      l_url := fnd_run_function.get_run_function_url(l_function_id,-1,-1,0, 'referralId=' ||
                                                     L_REFERRAL_ID || '&entityType=PVREFFRL');

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'VENDOR_LOGIN_URL',
                                   avalue   => l_url);

      open lc_get_function (pc_function_name => 'PV_REFERRAL_OVERVIEW_PT');
      fetch lc_get_function into l_function_id;
      close lc_get_function;

      l_url := fnd_run_function.get_run_function_url(l_function_id,-1,-1,0, 'referralId=' ||
                                                     L_REFERRAL_ID || '&entityType=PVREFFRL');

      if length(l_partner_url) > 0 then -- if profile is set, use it for partner URL

         l_url := l_partner_url || substr(l_url, instr(l_url,'/',1,3));

      end if;

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'PARTNER_LOGIN_URL',
                                   avalue   => l_url);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'REFERRAL_CODE',
                                   avalue   => l_referral_code);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'REFERRAL_NAME',
                                   avalue   => l_referral_name);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'REFERRAL_CREATOR',
                                   avalue   => l_creator_name);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'REFERRAL_STATUS',
                                   avalue   => l_entity_status);

        wf_engine.SetItemAttrDate( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'REFERRAL_CREATE_DATE',
                                   avalue   => l_entity_creation_date);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'REFERRAL_COMMISSION_AMT',
                                   avalue   => l_comp_amount);

   elsif p_itemtype = 'PVDEALRN' then

      open lc_get_function (pc_function_name => 'PV_REF_NOTIF_LINK_VENDOR');
      fetch lc_get_function into l_function_id;
      close lc_get_function;

      l_url := fnd_run_function.get_run_function_url(l_function_id,-1,-1,0, 'referralId=' ||
                                                     L_REFERRAL_ID || '&entityType=PVDEALRN');

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'VENDOR_LOGIN_URL',
                                   avalue   => l_url);

      open lc_get_function (pc_function_name => 'PV_DEALRN_OVERVIEW_PT');
      fetch lc_get_function into l_function_id;
      close lc_get_function;

      l_url := fnd_run_function.get_run_function_url(l_function_id,-1,-1,0, 'referralId=' ||
                                                     L_REFERRAL_ID || '&entityType=PVDEALRN');

      if length(l_partner_url) > 0 then -- if profile is set, use it for partner URL

         l_url := l_partner_url || substr(l_url, instr(l_url,'/',1,3));

      end if;

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'PARTNER_LOGIN_URL',
                                   avalue   => l_url);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'DEAL_CODE',
                                   avalue   => l_referral_code);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'DEAL_NAME',
                                   avalue   => l_referral_name);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'DEAL_CREATOR',
                                   avalue   => l_creator_name);

        wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'DEAL_STATUS',
                                   avalue   => l_entity_status);

        wf_engine.SetItemAttrDate( itemtype => p_itemtype,
                                   itemkey  => p_itemKey,
                                   aname    => 'DEAL_CREATE_DATE',
                                   avalue   => l_entity_creation_date);
   end if;

   wf_engine.SetItemAttrNumber( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'ENTITY_ID',
                              avalue   => l_referral_id);

   wf_engine.SetItemAttrDate( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'TODAY_DATE',
                              avalue   => sysdate);

   wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'PARTNER_ORG_NAME',
                              avalue   => l_partner_org_name);

   wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'CUSTOMER_ADDRESS',
                              avalue   => l_customer_address);

   wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'CUSTOMER_NAME',
                              avalue   => l_customer_name);

   wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'CUSTOMER_CONTACT',
                              avalue   => l_customer_cont_name);

   wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'PT_CONTACT_NAME',
                              avalue   => l_partner_cont_name);

   wf_engine.SetItemAttrText( itemtype => p_itemtype,
                              itemkey  => p_itemKey,
                              aname    => 'LAST_NOTE',
                              avalue   => l_notes_varchar);

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.REFERRAL_SET_MSG_ATTRS.end', 'Exiting');
    end if;

END;

FUNCTION REFERRAL_RETURN_USERLIST(
   p_benefit_type        IN VARCHAR2,
   P_ENTITY_ID           IN  NUMBER,
   P_USER_ROLE           IN  VARCHAR2,
   P_STATUS              IN  VARCHAR2) RETURN VARCHAR2
is
l_role_list varchar2(1000);
l_partner_id number;

cursor lc_get_ext_super_users(pc_permission varchar2,
                              pc_partner_id number) is
   SELECT
      usr.user_name
   FROM
      pv_partner_profiles   prof,
      hz_relationships      pr2,
      jtf_rs_resource_extns pj,
      fnd_user              usr
   WHERE
             prof.partner_id        = pc_partner_id
      and    prof.partner_party_id  = pr2.object_id
      and    pr2.subject_table_name = 'HZ_PARTIES'
      and    pr2.object_table_name  = 'HZ_PARTIES'
      and    pr2.directional_flag   = 'F'
      and    pr2.relationship_code  = 'EMPLOYEE_OF'
      and    pr2.relationship_type  = 'EMPLOYMENT'
      and    (pr2.end_date is null or pr2.end_date > sysdate)
      and    pr2.status            = 'A'
      and    pr2.party_id           = pj.source_id
      and    pj.category       = 'PARTY'
      and    usr.user_id       = pj.user_id
      and   (usr.end_date > sysdate OR usr.end_date IS NULL)
      and exists(select 1 from jtf_auth_principal_maps jtfpm,
                 jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
                 jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp,
                 jtf_auth_permissions_b jtfperm
                 where PJ.user_name = jtfp1.principal_name
                 and jtfp1.is_user_flag=1
                 and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
                 and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
                 and jtfp2.is_user_flag=0
                 and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
                 and jtfrp.positive_flag = 1
                 and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                 and jtfperm.permission_name = pc_permission
                 and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
                 and jtfd.domain_name='CRM_DOMAIN' );

cursor lc_get_int_super_users(pc_permission varchar2) is
      select usr.user_name
      from jtf_auth_principal_maps jtfpm,
      jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
      jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp,
      jtf_auth_permissions_b jtfperm, jtf_rs_resource_extns pj,
      fnd_user usr
      where PJ.user_name = jtfp1.principal_name
      and pj.category = 'EMPLOYEE'
      and usr.user_id       = pj.user_id
      and (usr.end_date > sysdate OR usr.end_date IS NULL)
      and jtfp1.is_user_flag=1
      and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
      and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
      and jtfp2.is_user_flag=0
      and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and jtfrp.positive_flag = 1
      and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name = pc_permission
      and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
      and jtfd.domain_name='CRM_DOMAIN';

cursor lc_get_partner_id(pc_entity_id number) is
select partner_id from pv_referrals_b where referral_id = pc_entity_id;

cursor lc_get_pt_cont(pc_entity_id number) is
select fnd.user_name
from fnd_user fnd, pv_referrals_b ref, jtf_rs_resource_extns jtf
where ref.partner_contact_resource_id = jtf.resource_id
and jtf.user_id = fnd.user_id
and ref.referral_id = pc_entity_id;

cursor lc_get_lead_owner (pc_entity_id number) is
select c.user_name
from as_sales_leads a, pv_referrals_b b, jtf_rs_resource_extns c
where b.referral_id = pc_entity_id
and b.entity_id_linked_to = a.sales_lead_id
and a.assign_to_salesforce_id = c.resource_id;

cursor lc_get_oppty_slsteam (pc_entity_id number) is
select c.user_name
from as_accesses_all a, pv_referrals_b b, jtf_rs_resource_extns c
where b.referral_id = pc_entity_id
and b.entity_id_linked_to = a.lead_id
and a.salesforce_id = c.resource_id
and c.category = 'EMPLOYEE';

-- bug 3671420
cursor lc_get_all_approvers (pc_benefit_type varchar2, pc_entity_id number) is
  select distinct fnd_user.user_name
  from pv_ge_temp_approvers apr, fnd_user
  where apr.arc_appr_for_entity_code = pc_benefit_type
  and apr.appr_for_entity_id = pc_entity_id
  and apr.approver_id = fnd_user.user_id
  AND APR.approval_status_code IN ('PENDING_APPROVAL','PENDING_DEFAULT','APPROVED')
  and apr.approver_type_code = 'USER';

begin
    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.REFERRAL_RETURN_USERLIST.start',
       'Benefit type:' || p_benefit_type || '. Entity id: ' || p_entity_id ||
       '. Status:' || p_status || '. User type: ' || p_user_role);
    end if;

    open lc_get_partner_id(pc_entity_id => p_entity_id);
    fetch lc_get_partner_id into l_partner_id;
    close lc_get_partner_id;

    if p_user_role = 'DEAL_SUPERUSER_EXT' then

        for l_row in lc_get_ext_super_users(pc_permission => 'PV_DEAL_SUPERUSER',
        pc_partner_id => l_partner_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'REFERRAL_SUPERUSER_EXT' then

        for l_row in lc_get_ext_super_users(pc_permission => 'PV_REFERRAL_SUPERUSER',
        pc_partner_id => l_partner_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'DEAL_SUPERUSER_INT' then

        for l_row in lc_get_int_super_users(pc_permission => 'PV_DEAL_SUPERUSER') loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'REFERRAL_SUPERUSER_INT' then

        for l_row in lc_get_int_super_users(pc_permission => 'PV_REFERRAL_SUPERUSER') loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'PT_CONTACT' then

        for l_row in lc_get_pt_cont(pc_entity_id => p_entity_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    elsif p_user_role = 'LEAD_OWNER' then

      if fnd_profile.value('PV_COPY_OWNER_ON_NOTIFICATION') = 'Y' then

         for l_row in lc_get_lead_owner(pc_entity_id => p_entity_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
         end loop;
         l_role_list := substr(l_role_list,2);

      end if;

    elsif p_user_role = 'OPPTY_SLSTEAM_INT' then

      if fnd_profile.value('PV_COPY_OWNER_ON_NOTIFICATION') = 'Y' then

        for l_row in lc_get_oppty_slsteam(pc_entity_id => p_entity_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

      end if;

    elsif p_user_role = 'BENEFIT_APPROVER' and p_status <> 'SUBMITTED_FOR_APPROVAL' then

        for l_row in lc_get_all_approvers(pc_benefit_type => p_benefit_type, pc_entity_id => p_entity_id) loop
            l_role_list := l_role_list || ',' || l_row.user_name;
        end loop;
        l_role_list := substr(l_role_list,2);

    else
         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
             'pv.plsql.PV_BENFT_STATUS_CHANGE.REFERRAL_RETURN_USERLIST.info',
             'Unrecognized user role:' || p_user_role);
         END IF;
    end if;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.REFERRAL_RETURN_USERLIST.end', 'Exiting');
    end if;

    return l_role_list;
end;

FUNCTION STATUS_CHANGE_SUB(
   p_subscription_guid in     raw,
   p_event             in out nocopy wf_event_t) return varchar2
is

   l_api_name            CONSTANT VARCHAR2(30) := 'STATUS_CHANGE_SUB';

   l_rule                   varchar2(20);
   l_parameter_list         wf_parameter_list_t := wf_parameter_list_t();
   l_parameter_t            wf_parameter_t := wf_parameter_t(null, null);
   l_parameter_name         l_parameter_t.name%type;
   i                        pls_integer;

   l_msg_callback_api varchar2(60);
   l_user_callback_api varchar2(60);
   l_benefit_id   number;
   l_status       varchar2(30);
   l_event_name   varchar2(50);
   l_entity_id    number;
   l_partner_id   number;
   l_user_list    varchar2(2000);
   l_msg_count number;
   l_msg_data varchar2(2000);
   l_return_status varchar2(10);

BEGIN

    l_parameter_list := p_event.getParameterList();
    l_entity_id := p_event.getEventKey();
    l_event_name := p_event.getEventName();

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_SUB.start',
       'Event name: ' || l_event_name || 'Event key: ' || l_entity_id);
    end if;

    if l_parameter_list is not null then
        i := l_parameter_list.first;
        while ( i <= l_parameter_list.last) loop

            l_parameter_name := null;
            l_parameter_name  := l_parameter_list(i).getName();

            IF l_parameter_name = 'MSG_CALLBACK_API' then
               l_msg_callback_api := l_parameter_list(i).getValue();
            elsif l_parameter_name = 'USER_CALLBACK_API' then
               l_user_callback_api := l_parameter_list(i).getValue();
            elsif l_parameter_name = 'BENEFIT_ID' THEN
                l_benefit_id := l_parameter_list(i).getValue();
            elsif l_parameter_name = 'STATUS_CODE' THEN
                l_status := l_parameter_list(i).getValue();
            elsif l_parameter_name = 'PARTNER_ID' THEN
                l_partner_id := l_parameter_list(i).getValue();
            END IF;

            i := l_parameter_list.next(i);
        end loop;

        pv_benft_status_change.STATUS_CHANGE_notification(
            p_api_version_number  => 1.0,
            p_init_msg_list       => fnd_api.G_FALSE,
            P_BENEFIT_ID          => l_benefit_id,
            P_STATUS              => l_status,
            P_ENTITY_ID           => l_entity_id,
            P_PARTNER_ID          => l_partner_id,
            p_msg_callback_api    => l_msg_callback_api,
            p_user_callback_api   => l_user_callback_api,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

        if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
        end if;

    end if;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_SUB.end', 'Exiting');
    end if;

    RETURN 'SUCCESS';

EXCEPTION
WHEN OTHERS THEN

    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_SUB.unexpected', FALSE );
    end if;

    fnd_msg_pub.Count_And_Get(p_encoded  => FND_API.G_TRUE
                             ,p_count   => l_msg_count
                             ,p_data    => l_msg_data);

    WF_CORE.CONTEXT(G_PKG_NAME, L_API_NAME, P_EVENT.GETEVENTNAME(), P_SUBSCRIPTION_GUID);
    WF_EVENT.SETERRORINFO(P_EVENT,'ERROR');
    RETURN 'ERROR';
END;

PROCEDURE STATUS_CHANGE_RAISE(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_event_name       IN VARCHAR2,
    p_benefit_id       IN NUMBER,
    p_entity_id        IN NUMBER,
    p_status_code      IN VARCHAR2,
    p_partner_id       IN NUMBER,
    p_msg_callback_api   IN VARCHAR2,
    p_user_callback_api   IN VARCHAR2,
    x_return_status    OUT NOCOPY  VARCHAR2,
    x_msg_count        OUT NOCOPY  NUMBER,
    x_msg_data         OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'STATUS_CHANGE_RAISE';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_return_status   varchar2(30);
   l_msg_count       number;
   l_msg_data        varchar2(1000);

   l_parameter_list         wf_parameter_list_t := wf_parameter_list_t();
   l_parameter_t            wf_parameter_t := wf_parameter_t(null, null);

BEGIN
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_RAISE.begin',
      'Event:' || p_event_name || '. Benefit id:' || p_benefit_id ||
      '. Status code:' || p_status_code || '. Partner id:' || p_partner_id ||
      '. Message callback API: ' || p_msg_callback_api ||
      '. User Callback API: ' || p_user_callback_api);
   end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_parameter_t.setName('BENEFIT_ID');
    l_parameter_t.setValue(p_benefit_id);
    l_parameter_list.extend;
    l_parameter_list(1) := l_parameter_t;

    l_parameter_t.setName('STATUS_CODE');
    l_parameter_t.setValue(p_status_code);
    l_parameter_list.extend;
    l_parameter_list(2) := l_parameter_t;

    l_parameter_t.setName('PARTNER_ID');
    l_parameter_t.setValue(p_partner_id);
    l_parameter_list.extend;
    l_parameter_list(3) := l_parameter_t;

    l_parameter_t.setName('MSG_CALLBACK_API');
    l_parameter_t.setValue(p_msg_callback_api);
    l_parameter_list.extend;
    l_parameter_list(4) := l_parameter_t;

    l_parameter_t.setName('USER_CALLBACK_API');
    l_parameter_t.setValue(p_user_callback_api);
    l_parameter_list.extend;
    l_parameter_list(5) := l_parameter_t;

    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_RAISE.raiseEvent', 'Calling pvx_event_pkg.raise_event' );
    end if;

    pvx_event_pkg.raise_event(
        p_event_name => p_event_name,
        p_event_key  => p_entity_id,
        p_data       => null,
        p_parameters => l_parameter_list);

    IF FND_API.To_Boolean ( p_commit )   THEN
        COMMIT WORK;
    END IF;

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
       'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_RAISE.end', 'Exiting' );
    end if;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_RAISE.error', FALSE );
      end if;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_RAISE.unexpected', FALSE );
      end if;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);

      if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.STATUS_CHANGE_RAISE.unexpected', FALSE );
      end if;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
END;

procedure GET_DECLINE_REASON (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

cursor lc_get_reason (pc_entity_id number) is
select b.meaning from pv_referrals_b a, FND_LOOKUP_VALUES_VL b
where a.referral_id = pc_entity_id
and a.decline_reason_code = b.lookup_code
and b.lookup_type = 'PV_REFERRAL_DECLINE_REASON';

l_entity_id       number;
l_translated_reason varchar2(100);

BEGIN
   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'pv.plsql.PV_BENFT_STATUS_CHANGE.GET_DECLINE_REASON.begin',
      'Document_id:' || document_id || '. display_type:' || display_type);
   end if;

   if display_type in ('text/plain', 'text/html') then
      l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);
      open lc_get_reason(pc_entity_id => l_entity_id);
      fetch lc_get_reason into l_translated_reason;
      close lc_get_reason;

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.GET_DECLINE_REASON.info', 'Reason: ' || l_translated_reason );
      end if;

      document := l_translated_reason;
   end if;

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'pv.plsql.PV_BENFT_STATUS_CHANGE.GET_DECLINE_REASON.end', 'Exiting');
   end if;
END;

procedure GET_PRODUCTS (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

cursor lc_get_products (pc_entity_id number) is
   select c.CONCAT_CAT_PARENTAGE, b.amount || ' ' || a.currency_code amount
   from pv_referrals_b a, pv_referred_products b, eni_prod_den_hrchy_parents_v c
   where a.referral_id = pc_entity_id
   and a.referral_id = b.referral_id
   and b.product_category_set_id = c.category_set_id
   and b.product_category_id = c.category_id;

cursor lc_max_products_length (pc_entity_id number) is
   select max(length(c.CONCAT_CAT_PARENTAGE)), max(length(to_char(b.amount) || ' ' || a.currency_code))
   from pv_referrals_b a, pv_referred_products b, eni_prod_den_hrchy_parents_v c
   where a.referral_id = pc_entity_id
   and a.referral_id = b.referral_id
   and b.product_category_set_id = c.category_set_id
   and b.product_category_id = c.category_id;

cursor lc_get_label is
   select attribute_code,attribute_label_long
   from ak_attributes_vl ak
   where attribute_application_id = 522
   AND ATTRIBUTE_code in ('ASF_AMOUNT','ASF_PRODUCT_CATEGORY');

l_entity_id           number;
l_max_length_amount    number;
l_max_length_products number;
l_products_list       varchar2(4000);
l_label_amount        varchar2(30);
l_label_products      varchar2(200);
l_has_products        boolean;

BEGIN
   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'pv.plsql.PV_BENFT_STATUS_CHANGE.GET_PRODUCTS.begin',
      'Document_id:' || document_id || '. display_type:' || display_type);
   end if;

   l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);

   if display_type = 'text/plain' then
      open lc_max_products_length(pc_entity_id => l_entity_id);
      fetch lc_max_products_length into l_max_length_products, l_max_length_amount;
      close lc_max_products_length;
   end if;

   for l_label_rec in lc_get_label loop

      if l_label_rec.attribute_code = 'ASF_AMOUNT' then
         l_label_amount := l_label_rec.attribute_label_long;
         l_max_length_amount := greatest(l_max_length_amount, length(l_label_amount));
      elsif l_label_rec.attribute_code = 'ASF_PRODUCT_CATEGORY' then
         l_label_products := l_label_rec.attribute_label_long;
         l_max_length_products := greatest(l_max_length_products, length(l_label_products));
      end if;

   end loop;


   for l_prod_rec in lc_get_products(pc_entity_id => l_entity_id)
   loop
      l_has_products := true;
      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         'pv.plsql.PV_BENFT_STATUS_CHANGE.GET_PRODUCTS.info', 'Product: ' || l_prod_rec.CONCAT_CAT_PARENTAGE );
      end if;
      if display_type = 'text/html' then

         l_products_list := l_products_list || '<tr><td>' || l_prod_rec.concat_cat_parentage ||
                            '</td><td align="right">' || l_prod_rec.amount || '</td></tr>';

      elsif display_type  = 'text/plain' then

         l_products_list := l_products_list || rpad(l_prod_rec.concat_cat_parentage, l_max_length_products + 5) ||
                            lpad(l_prod_rec.amount, l_max_length_amount) || fnd_global.local_chr(10);
      end if;
   end loop;

   if l_has_products and display_type = 'text/html' then
      l_products_list := '<table><tr><th align="left">' || l_label_products || '</th><th align="right">' ||
                          l_label_amount || '</th></tr>' || l_products_list || '</table>';

   elsif l_has_products and display_type = 'text/plain' then
      l_products_list := rpad(l_label_products, l_max_length_products+2) || lpad(l_label_amount, l_max_length_amount+2) ||
                         fnd_global.local_chr(10) || l_products_list;
   end if;

   document := l_products_list;

   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
      'pv.plsql.PV_BENFT_STATUS_CHANGE.GET_PRODUCTS.end', 'Exiting');
   end if;
END;

END;

/
