--------------------------------------------------------
--  DDL for Package Body PV_WORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_WORKFLOW_PUB" as
/* $Header: pvxwffnb.pls 120.2 2006/05/31 04:16:45 dhii ship $ */

-- Start of Comments

-- Package name     : PV_WORKFLOW_PUB
-- Purpose          :
-- History          :
--
-- NOTE             :
-- End of Comments
--


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_WORKFLOW_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxwffnb.pls';


procedure BYPASS_CM_APPROVAL_CHK (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'BYPASS_CM_APPROVAL_CHK';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(50);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_temp                 varchar2(40);
   l_assignment_id        number;
   l_assignment_id_tbl    pv_assignment_pub.g_number_table_type := pv_assignment_pub.g_number_table_type();

   cursor lc_get_assignment (pc_itemtype varchar2,
                             pc_itemkey  varchar2 ) is
   select la.lead_assignment_id
   from   pv_lead_assignments    la
   where  la.wf_item_type       = pc_itemtype
   and    la.wf_item_key        = pc_itemkey
   and    la.status            <> pv_assignment_pub.g_la_status_pt_created;


BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_temp := wf_engine.GetItemAttrText( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => g_wf_attr_bypass_cm_approval);

      if l_temp not in (g_wf_lkup_yes,
                        g_wf_lkup_no) or l_temp is null then

         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_token('TEXT', 'Invalid bypass CM Approval flag: ' || l_temp);
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;

      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Bypass CM: ' || l_temp);
         fnd_msg_pub.Add;
      END IF;

      if l_temp = g_wf_lkup_yes then  -- bypass CM OK

         open lc_get_assignment (pc_itemtype  => itemtype,
                                 pc_itemkey   => itemkey);
         loop
            fetch lc_get_assignment into l_assignment_id;
            exit when lc_get_assignment%notfound;
            l_assignment_id_tbl.extend;
            l_assignment_id_tbl(l_assignment_id_tbl.last) := l_assignment_id;
         end loop;
         close lc_get_assignment;

         for i in 1 .. l_assignment_id_tbl.count loop

            pv_assignment_pvt.UpdateAssignment (
               p_api_version_number  => 1.0
               ,p_init_msg_list      => FND_API.G_FALSE
               ,p_commit             => FND_API.G_FALSE
               ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
               ,p_action             => pv_assignment_pub.g_asgn_action_status_update
               ,p_lead_assignment_id => l_assignment_id_tbl(i)
               ,p_status_date        => sysdate
               ,p_status             => pv_assignment_pub.g_la_status_cm_bypassed
               ,p_reason_code        => NULL
               ,p_rank               => NULL
               ,x_msg_count          => l_msg_count
               ,x_msg_data           => l_msg_data
               ,x_return_status      => l_return_status);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end loop;
      end if;

      l_resultout := 'COMPLETE:' || l_temp;

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end BYPASS_CM_APPROVAL_CHK;


procedure SET_TIMEOUT (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'SET_TIMEOUT';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_timeout_type         varchar2(30);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_timeout_type := wf_engine.GetActivityAttrText(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      actid    => actid,
                                                      aname    => g_wf_attr_pvt_timeout_type);
      pv_assignment_pvt.setTimeout  (
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_itemtype            => itemType,
         p_itemkey             => itemKey,
         p_partner_id          => NULL,
         p_timeoutType         => l_timeout_type,
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      l_resultout := 'COMPLETE:';

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end SET_TIMEOUT;


procedure WAIT_ON_MATCH (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'WAIT_ON_MATCH';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_routing_outcome      varchar2(30);
   l_routing_stage        varchar2(30);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

   l_assignment_id        number;
   l_assign_status        varchar2(30);

   l_assignment_id_tbl    pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();
   l_assign_status_tbl    pv_assignment_pub.g_varchar_table_type :=pv_assignment_pub.g_varchar_table_type();

   cursor lc_get_match_outcome (pc_itemtype varchar2,
                                pc_itemkey  varchar2) is
      select a.lead_assignment_id, a.status
      from pv_lead_assignments a
      where a.wf_item_type = pc_itemtype
      and   a.wf_item_key  = pc_itemkey;

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      pv_assignment_pvt.send_notification (
       p_api_version_number   => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE
       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       ,p_itemtype            => itemType
       ,p_itemkey             => itemKey
       ,p_activity_id         => actid
       ,P_route_stage         => pv_assignment_pub.g_r_status_matched
       ,p_partner_id          => NULL
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      wf_standard.block(itemtype  => itemtype,
                        itemkey   => itemkey,
                        actid     => actid,
                        funcmode  => 'RUN',
                        resultout => l_resultout);

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then

      open lc_get_match_outcome (pc_itemtype => itemtype, pc_itemkey  => itemkey);

      loop
         fetch lc_get_match_outcome into l_assignment_id, l_assign_status;
         exit when lc_get_match_outcome%notfound;

         l_assignment_id_tbl.extend;
         l_assignment_id_tbl(l_assignment_id_tbl.last) := l_assignment_id;
         l_assign_status_tbl.extend;
         l_assign_status_tbl(l_assign_status_tbl.last) := l_assign_status;
      end loop;

      close lc_get_match_outcome;

      for i in 1 .. l_assignment_id_tbl.count loop

         if l_assign_status_tbl(i) = pv_assignment_pub.g_la_status_assigned then

            -- CM did not act and timeout happened

            pv_assignment_pvt.UpdateAssignment (
               p_api_version_number  => 1.0
               ,p_init_msg_list      => FND_API.G_FALSE
               ,p_commit             => FND_API.G_FALSE
               ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
               ,p_action             => pv_assignment_pub.g_asgn_action_status_update
               ,p_lead_assignment_id => l_assignment_id_tbl(i)
               ,p_status_date        => sysdate
               ,p_status             => pv_assignment_pub.g_la_status_cm_timeout
               ,p_reason_code        => NULL
               ,p_rank               => NULL
               ,x_msg_count          => l_msg_count
               ,x_msg_data           => l_msg_data
               ,x_return_status      => l_return_status);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

            update pv_party_notifications
        set resource_response = pv_assignment_pub.g_la_status_cm_timeout,
          response_date = sysdate,
          object_version_number = object_version_number + 1,
          last_update_date    = sysdate,
          last_updated_by     = FND_GLOBAL.user_id,
          last_update_login   = FND_GLOBAL.login_id
        where lead_assignment_id = l_assignment_id_tbl(i)
        and resource_response is null
        and notification_type = pv_assignment_pub.g_notify_type_matched_to;

         end if;
      end loop;

      wf_engine.SetItemAttrText (itemtype => itemType,
                                 itemkey  => itemKey,
                                 aname    => g_wf_attr_routing_outcome,
                                 avalue   => g_wf_lkup_match_timedout);

      l_resultout := 'COMPLETE:' || g_wf_lkup_match_timedout;

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end WAIT_ON_MATCH;


procedure PROCESS_MATCH_OUTCOME (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'PROCESS_MATCH_OUTCOME';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_match_outcome        varchar2(30);

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_match_outcome := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => g_wf_attr_routing_outcome);

      -- in case salesrep have added access records for partner/partner contact
      -- in direct matching and cm has rejected

      pv_assignment_pvt.removeRejectedFromAccess (
                                 p_api_version_number  => 1.0,
                                 p_init_msg_list       => FND_API.G_FALSE,
                                 p_commit              => FND_API.G_FALSE,
                                 p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                 p_itemtype            => itemType,
                                 p_itemkey             => itemKey,
                                 p_partner_id          => NULL,
                                 x_return_status       => l_return_status,
                                 x_msg_count           => l_msg_count,
                                 x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      l_resultout := 'COMPLETE:' || l_match_outcome;

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end PROCESS_MATCH_OUTCOME;


procedure GET_ASSIGNMENT_TYPE (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'GET_ASSIGNMENT_TYPE';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_partner_id           number;
   l_assign_sequence      pls_integer;
   l_assignment_type      varchar2(30);
   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

   cursor lc_get_pt_id (pc_itemtype varchar2,
                        pc_itemkey  varchar2) is
   select partner_id, assign_sequence
   from   pv_lead_assignments la
   where  la.wf_item_type = pc_itemtype
   and    la.wf_item_key  = pc_itemkey
   and    status in (pv_assignment_pub.g_la_status_cm_approved,
                     pv_assignment_pub.g_la_status_cm_added,
                     pv_assignment_pub.g_la_status_cm_bypassed,
                     pv_assignment_pub.g_la_status_cm_app_for_pt,
                     pv_assignment_pub.g_la_status_cm_timeout)
   order by assign_sequence;

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      pv_assignment_pvt.send_notification (
       p_api_version_number   => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE
       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       ,p_itemtype            => itemType
       ,p_itemkey             => itemKey
       ,p_activity_id         => actid
       ,P_route_stage         => pv_assignment_pub.g_r_status_matched
       ,p_partner_id          => null
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      pv_assignment_pvt.update_routing_stage (
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_itemType            => itemtype,
         p_itemKey             => itemKey,
         p_routing_stage       => pv_assignment_pub.g_r_status_offered,
         p_active_but_open_flag => 'N',
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      l_assignment_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_assignment_type);

      if l_assignment_type = g_wf_lkup_single then

         open lc_get_pt_id(pc_itemtype => itemtype, pc_itemkey => itemkey);
         fetch lc_get_pt_id into l_partner_id, l_assign_sequence;

         if lc_get_pt_id%notfound then

            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.SET_TOKEN('TEXT', 'Cannot find Partner ID for itemkey: ' || itemkey );
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         end if;

         -- make sure there is only one partner in SINGLE assignment

         fetch lc_get_pt_id into l_partner_id, l_assign_sequence;

         if lc_get_pt_id%found then

            fnd_message.Set_Name('PV', 'PV_MULTIPLE_PRTNR_SINGLE');
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         end if;

         close lc_get_pt_id;

         pv_assignment_pvt.set_offered_attributes (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => itemType,
            p_itemkey             => itemKey,
            p_partner_id          => l_partner_id,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

         if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      elsif l_assignment_type = g_wf_lkup_serial then

         open lc_get_pt_id(pc_itemtype => itemtype, pc_itemkey => itemkey);
         fetch lc_get_pt_id into l_partner_id, l_assign_sequence;

         if lc_get_pt_id%notfound then

            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.SET_TOKEN('TEXT', 'Cannot find Partner ID for itemkey: ' || itemkey );
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         end if;

         close lc_get_pt_id;

         wf_engine.SetItemAttrNumber (itemtype => itemType,
                                      itemkey  => itemKey,
                                      aname    => g_wf_attr_next_serial_rank,
                                      avalue   => l_assign_sequence);

      elsif l_assignment_type = g_wf_lkup_broadcast then

         pv_assignment_pvt.set_offered_attributes (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => itemType,
            p_itemkey             => itemKey,
            p_partner_id          => null,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

         if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;


      elsif l_assignment_type = g_wf_lkup_joint then

         pv_assignment_pvt.set_offered_attributes (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => itemType,
            p_itemkey             => itemKey,
            p_partner_id          => null,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

         if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      else

         fnd_message.Set_Name('PV', 'PV_INVALID_ASSIGN_TYPE');
         fnd_message.SET_TOKEN('TYPE', l_assignment_type);
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;

      l_resultout := 'COMPLETE:' || l_assignment_type;

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end GET_ASSIGNMENT_TYPE;



procedure SERIAL_NEXT_PARTNER (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'SERIAL_NEXT_PARTNER';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

   l_partner_id           number;
   l_next_partner_id      number;
   l_current_seq          pls_integer;
   l_next_seq             pls_integer;

   l_assignment_log_rec   PV_ASSIGNMENT_PVT.assignment_log_rec_type;
   l_assignment_log_id   number;
   l_lead_id             number;
   l_lead_workflow_id    number;
   l_lead_assignment_id   number;
   l_next_lead_assignment_id   number;

   cursor lc_get_pt_id (pc_itemtype varchar2,
                        pc_itemkey  varchar2,
                        pc_sequence number) is
   select la.partner_id, la.assign_sequence, a.lead_id, a.lead_workflow_id, la.lead_assignment_id
   from   pv_lead_workflows a, pv_lead_assignments la
   where  la.wf_item_type    = pc_itemtype
   and    la.wf_item_key     = pc_itemkey
   and    la.assign_sequence >= pc_sequence
   and    la.status in ( pv_assignment_pub.g_la_status_cm_approved,
                         pv_assignment_pub.g_la_status_cm_app_for_pt,
                         pv_assignment_pub.g_la_status_cm_bypassed,
                         pv_assignment_pub.g_la_status_cm_timeout)
   and     la.wf_item_type = a.wf_item_type
   and      la.wf_item_key = a.wf_item_key
   order by assign_sequence;

BEGIN
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_current_seq := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_next_serial_rank);
      if l_current_seq <> -999 then

         open lc_get_pt_id (pc_itemtype => itemtype,
                            pc_itemkey => itemkey,
                            pc_sequence => l_current_seq);

         fetch lc_get_pt_id into l_partner_id, l_current_seq, l_lead_id, l_lead_workflow_id, l_lead_assignment_id;

         if lc_get_pt_id%found then
            fetch lc_get_pt_id into l_next_partner_id, l_next_seq, l_lead_id, l_lead_workflow_id, l_next_lead_assignment_id;
         end if;

         close lc_get_pt_id;

      end if;

      if l_partner_id is null then

         l_resultout := 'COMPLETE:' || g_wf_lkup_false;

      else

         pv_assignment_pvt.set_offered_attributes (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => itemType,
            p_itemkey             => itemKey,
            p_partner_id          => l_partner_id,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

         if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

         wf_engine.SetItemAttrNumber (itemtype => itemType,
                                      itemkey  => itemKey,
                                      aname    => g_wf_attr_current_serial_rank,
                                      avalue   => l_current_seq);

         wf_engine.SetItemAttrNumber (itemtype => itemType,
                                      itemkey  => itemKey,
                                      aname    => g_wf_attr_next_serial_rank,
                                      avalue   => nvl(l_next_seq, -999));

         l_assignment_log_rec.LEAD_ID          := l_lead_id;
         l_assignment_log_rec.FROM_LEAD_STATUS := 'MATCHED';
         l_assignment_log_rec.TO_LEAD_STATUS   := 'OFFERED';
         l_assignment_log_rec.WF_ITEM_TYPE     := itemtype;
         l_assignment_log_rec.WF_ITEM_KEY      := itemkey;
         l_assignment_log_rec.WORKFLOW_ID      := l_lead_workflow_id;
         l_assignment_log_rec.partner_id       := l_partner_id;
         l_assignment_log_rec.lead_assignment_id := l_lead_assignment_id;

         PV_ASSIGNMENT_PVT.Create_assignment_log_row (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_assignment_log_rec  => l_assignment_log_rec,
            x_assignment_id       => l_assignment_log_id,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data);

         if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

         l_resultout := 'COMPLETE:' || g_wf_lkup_true;

      end if;

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end SERIAL_NEXT_PARTNER;


procedure WAIT_ON_OFFER (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'WAIT_ON_OFFER';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

   l_assignment_type      varchar2(30);
   l_pt_org_rs_id         number;
   l_lead_id              number;
   l_access_id            number;
   l_customer_id          number;
   l_address_id           number;
   l_partner_id           number;

   cursor lc_get_partner_org (pc_itemtype  varchar2,
                              pc_itemkey   varchar2) is
   select
          b.resource_id            partner_org_rs_id
   from   pv_lead_assignments la,
          jtf_rs_resource_extns b
   where
          la.wf_item_type = pc_itemtype
   and    la.wf_item_key  = pc_itemkey
   and    la.status       = pv_assignment_pub.g_la_status_cm_app_for_pt
   and    la.partner_id   = b.source_id
   and    b.category      = 'PARTNER';

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_partner_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => g_wf_attr_partner_id);
      pv_assignment_pvt.send_notification (
       p_api_version_number   => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE
       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       ,p_itemtype            => itemType
       ,p_itemkey             => itemKey
       ,p_activity_id         => actid
       ,P_route_stage         => pv_assignment_pub.g_r_status_offered
       ,p_partner_id          => l_partner_id
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      l_assignment_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_assignment_type);
      if l_assignment_type = g_wf_lkup_joint then

         l_lead_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => g_wf_attr_opportunity_id);

         l_customer_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => g_wf_attr_customer_id);

         l_address_id  := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => g_wf_attr_address_id);

         wf_engine.SetItemAttrNumber (itemtype => itemType,
                          itemkey  => itemKey,
                     aname    => g_wf_attr_wf_activity_id,
                avalue   => actid);


         open lc_get_partner_org (pc_itemtype => itemtype, pc_itemkey => itemkey);

         loop
            fetch lc_get_partner_org into l_pt_org_rs_id;
            exit when lc_get_partner_org%notfound;

            pv_assign_util_pvt.updateaccess(
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_itemtype            => itemType,
               p_itemkey             => itemKey,
               p_current_username    => NULL,
               p_lead_id             => l_lead_id,
               p_customer_id         => l_customer_id,
               p_address_id          => l_address_id,
               p_access_action       => pv_assignment_pub.G_ADD_ACCESS,
               p_resource_id         => l_pt_org_rs_id,
               p_access_type         => pv_assignment_pub.G_PT_ORG_ACCESS,
               x_access_id           => l_access_id,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end loop;
         close lc_get_partner_org;

         if l_pt_org_rs_id is not null then

            pv_assignment_pvt.update_routing_stage (
               p_api_version_number   => 1.0,
               p_init_msg_list        => FND_API.G_FALSE,
               p_commit               => FND_API.G_FALSE,
               p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
               p_itemType             => itemtype,
               p_itemKey              => itemKey,
               p_routing_stage        => pv_assignment_pub.g_r_status_active,
               p_active_but_open_flag => 'Y',
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end if;
      end if;

      wf_standard.block(itemtype  => itemtype,
                        itemkey   => itemkey,
                        actid     => actid,
                        funcmode  => 'RUN',
                        resultout => l_resultout);

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := g_wf_lkup_offer_timedout;

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end WAIT_ON_OFFER;


procedure PROCESS_OFFER_OUTCOME (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'PROCESS_OFFER_OUTCOME';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_assignment_type      varchar2(30);
   l_offer_outcome        varchar2(30);
   l_username             varchar2(100);
   l_response             varchar2(30);
   l_rank                 pls_integer;
   l_lead_id              number;
   l_access_id            number;
   l_partner_id           number;
   l_resource_id          number;
   l_assignment_id        number;
   l_customer_id          number;
   l_partner_org_rs_id    number;
   l_address_id           number;
   l_lc_partner_rs_id     NUMBER;
   l_username_tbl         pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_response_tbl         pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_resource_id_tbl      pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();
   l_partner_id_tbl       pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();
   l_assignment_id_tbl    pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

   -- this can be written using just joins (wf_item_activity_statuses,
   -- wf_process_activities, wf_activity_transitions) but if the
   -- timeout transition in WF is removed, it will not work

   cursor lc_chk_for_timeout (pc_itemtype           varchar2,
                              pc_itemkey            varchar2,
                              pc_from_activity_name varchar2,
                              pc_to_activity_id     number) is
   select a.activity_result_code
   from wf_item_activity_statuses a
   where a.item_type = pc_itemtype
   and   a.item_key  = pc_itemkey
   and   a.process_activity =
   (select d.from_process_activity
    from wf_process_activities c, wf_activity_transitions d
    where d.to_process_activity = pc_to_activity_id
    and d.from_process_activity = c.instance_id
    and c.activity_name = pc_from_activity_name and rownum < 2);

   cursor lc_get_pt_response (pc_itemtype   varchar2,
                              pc_itemkey    varchar2,
                              pc_partner_id number) is
   select la.lead_assignment_id, la.partner_id, la.status
   from   pv_lead_assignments    la
   where  la.wf_item_type       = pc_itemtype
   and    la.wf_item_key        = pc_itemkey
   and    la.partner_id         = pc_partner_id;


   -- reusable sql
   cursor lc_get_all_pt_response (pc_itemtype   varchar2,
                                  pc_itemkey    varchar2) is
   select la.lead_assignment_id, la.partner_id, la.status
   from   pv_lead_assignments    la
   where  la.wf_item_type       = pc_itemtype
   and    la.wf_item_key        = pc_itemkey;

   cursor lc_get_offered_to_for_pt (pc_itemtype    varchar2,
                                    pc_itemkey     varchar2,
                                    pc_partner_id  number,
                                    pc_notify_type varchar2) is
   select usr.user_name, pn.resource_id
   from pv_lead_assignments la,
        pv_party_notifications pn,
	fnd_user usr
   where la.wf_item_type  = pc_itemtype
   and   la.wf_item_key   = pc_itemkey
   and   la.partner_id    = pc_partner_id
   and   la.lead_assignment_id = pn.lead_assignment_id
   and   pn.notification_type  = pc_notify_type
   and   pn.user_id = usr.user_id       ;


   cursor lc_get_uniq_cm_for_pt (pc_itemtype    varchar2,
                                 pc_itemkey     varchar2,
                                 pc_partner_id  number,
                                 pc_notify_type varchar2) is
   select usr.user_name, pn.resource_id
   from pv_lead_assignments la,
        pv_party_notifications pn,
	fnd_user usr
   where la.wf_item_type  = pc_itemtype
   and   la.wf_item_key   = pc_itemkey
   and   la.partner_id    = pc_partner_id
   and   la.lead_assignment_id = pn.lead_assignment_id
   and   pn.notification_type  = pc_notify_type
   and   pn.user_id = usr.user_id
   and   not exists
   (select 1
    from pv_lead_assignments la2,
         pv_party_notifications pn2
   where la2.wf_item_type  = pc_itemtype
   and   la2.wf_item_key   = pc_itemkey
   and   la2.partner_id   <> la.partner_id
   and   la2.status       in (pv_assignment_pub.g_la_status_cm_timeout,
                              pv_assignment_pub.g_la_status_cm_approved,
                              pv_assignment_pub.g_la_status_cm_bypassed,
                              pv_assignment_pub.g_la_status_cm_app_for_pt,
                              pv_assignment_pub.g_la_status_pt_approved)
   and   la2.lead_assignment_id = pn2.lead_assignment_id
   and   pn2.notification_type  = pc_notify_type
   and   pn2.user_id = pn.user_id );

   -- for removing sales team partners when timeout ( cm_bypassed, cm_approved, cm_timeout)
   cursor lc_get_pt_org (pc_itemtype  varchar2,
                         pc_itemkey   varchar2) is
   select b.resource_id            partner_org_rs_id
   from   pv_lead_assignments la,
          jtf_rs_resource_extns b
   where
          la.wf_item_type = pc_itemtype
   and    la.wf_item_key  = pc_itemkey
   and    la.status       = pv_assignment_pub.g_la_status_pt_timeout
   and    la.partner_id   = b.source_id
   and    b.category      = 'PARTNER';

   -- for removing sales team partners when lost chance
   cursor lc_get_pt_lc_org (pc_itemtype  varchar2,
                         pc_itemkey   varchar2) is
   select b.resource_id            partner_org_rs_id
   from   pv_lead_assignments la,
          jtf_rs_resource_extns b
   where
          la.wf_item_type = pc_itemtype
   and    la.wf_item_key  = pc_itemkey
   and    la.status       = pv_assignment_pub.g_la_status_lost_chance
   and    la.partner_id   = b.source_id
   and    b.category      = 'PARTNER';

   cursor lc_get_partner_org (pc_itemtype  varchar2,
                              pc_itemkey   varchar2) is
   select
          b.resource_id            partner_org_rs_id
   from   pv_lead_assignments la,
          jtf_rs_resource_extns b
   where
          la.wf_item_type = pc_itemtype
   and    la.wf_item_key  = pc_itemkey
   and    la.status      in (pv_assignment_pub.g_la_status_cm_app_for_pt,
                             pv_assignment_pub.g_la_status_pt_approved)
   and    la.partner_id   = b.source_id
   and    b.category      = 'PARTNER';

   cursor lc_get_lost_chance_pt (pc_itemtype   varchar2,
                                 pc_itemkey    varchar2,
                                 pc_rank       number) is
   select la.lead_assignment_id, la.partner_id
   from   pv_lead_assignments    la
   where  la.wf_item_type       = pc_itemtype
   and    la.wf_item_key        = pc_itemkey
   and    la.assign_sequence    > pc_rank
   and    la.status in (pv_assignment_pub.g_la_status_cm_timeout,
                        pv_assignment_pub.g_la_status_cm_bypassed,
                        pv_assignment_pub.g_la_status_cm_app_for_pt,
                        pv_assignment_pub.g_la_status_cm_approved);

BEGIN
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_assignment_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_assignment_type);

      l_lead_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => g_wf_attr_opportunity_id);

      l_customer_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_customer_id);

      l_address_id  := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_address_id);

      -- check to see if timeout happened

      open lc_chk_for_timeout ( pc_itemtype       => itemtype,
                                pc_itemkey        => itemkey,
                                pc_from_activity_name => g_wf_fn_pt_response_block,
                                pc_to_activity_id => actid);

      fetch lc_chk_for_timeout into l_offer_outcome;
      close lc_chk_for_timeout;

      if l_offer_outcome is null then

         -- outcome is null if CM_APP_FOR_PT or CM_ADD_APP_FOR_PT

         l_offer_outcome := g_wf_lkup_offer_approved;

      elsif l_offer_outcome = g_wf_lkup_offer_timedout then

         if l_assignment_type in (g_wf_lkup_single, g_wf_lkup_serial) then

            -- partner_id is set in single and serial assignment

            l_partner_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_partner_id);

            open lc_get_pt_response(pc_itemtype   => itemtype,
                                    pc_itemkey    => itemkey,
                                    pc_partner_id => l_partner_id);

            loop
               fetch lc_get_pt_response into l_assignment_id, l_partner_id, l_response;
               exit when lc_get_pt_response%notfound;

               l_assignment_id_tbl.extend;
               l_partner_id_tbl.extend;
               l_response_tbl.extend;
               l_assignment_id_tbl(l_assignment_id_tbl.last) := l_assignment_id;
               l_partner_id_tbl(l_partner_id_tbl.last)       := l_partner_id;
               l_response_tbl(l_response_tbl.last)           := l_response;

            end loop;
            close lc_get_pt_response;

         elsif l_assignment_type in (g_wf_lkup_broadcast, g_wf_lkup_joint) then

            open lc_get_all_pt_response(pc_itemtype   => itemtype,
                                        pc_itemkey    => itemkey);

            loop
               fetch lc_get_all_pt_response into l_assignment_id, l_partner_id, l_response;
               exit when lc_get_all_pt_response%notfound;

               l_assignment_id_tbl.extend;
               l_partner_id_tbl.extend;
               l_response_tbl.extend;
               l_assignment_id_tbl(l_assignment_id_tbl.last) := l_assignment_id;
               l_partner_id_tbl(l_partner_id_tbl.last)       := l_partner_id;
               l_response_tbl(l_response_tbl.last)           := l_response;

            end loop;
            close lc_get_all_pt_response;

         end if; -- assignment type check

         if l_response_tbl.count = 0 then

            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Cannot find assignment (itemkey): ' || itemkey);
            fnd_msg_pub.Add;

            raise FND_API.G_EXC_ERROR;

         end if;

         for i in 1 .. l_response_tbl.count loop

            -- for single and serial, this loop should only be executed once

            if l_response_tbl(i) in (pv_assignment_pub.g_la_status_cm_approved,
                                     pv_assignment_pub.g_la_status_cm_bypassed,
                                     pv_assignment_pub.g_la_status_cm_timeout) then

               -- partner timed out because status was not changed

               pv_assignment_pvt.UpdateAssignment (
                  p_api_version_number  => 1.0
                  ,p_init_msg_list      => FND_API.G_FALSE
                  ,p_commit             => FND_API.G_FALSE
                  ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                  ,p_action             => pv_assignment_pub.g_asgn_action_status_update
                  ,p_lead_assignment_id => l_assignment_id_tbl(i)
                  ,p_status_date        => sysdate
                  ,p_status             => pv_assignment_pub.g_la_status_pt_timeout
                  ,p_reason_code        => NULL
                  ,p_rank               => NULL
                  ,x_msg_count          => l_msg_count
                  ,x_msg_data           => l_msg_data
                  ,x_return_status      => l_return_status);

               if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
               end if;

               -- remove all partner contacts for partner from access

               l_username_tbl.delete;
               l_resource_id_tbl.delete;

               open lc_get_offered_to_for_pt (pc_itemtype => itemtype,
                                           pc_itemkey     => itemkey,
                                           pc_partner_id  => l_partner_id_tbl(i),
                                           pc_notify_type => pv_assignment_pub.g_notify_type_offered_to);

               loop
                  fetch lc_get_offered_to_for_pt into l_username, l_resource_id;
                  exit when lc_get_offered_to_for_pt%notfound;

                  l_username_tbl.extend;
                  l_resource_id_tbl.extend;
                  l_username_tbl(l_username_tbl.last)       := l_username;
                  l_resource_id_tbl(l_resource_id_tbl.last) := l_resource_id;

               end loop;
               close lc_get_offered_to_for_pt;

               for i in 1 .. l_username_tbl.count loop

                  pv_assign_util_pvt.updateaccess(
                     p_api_version_number  => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_FALSE,
                     p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                     p_itemtype            => itemType,
                     p_itemkey             => itemKey,
                     p_current_username    => l_username_tbl(i),
                     p_lead_id             => l_lead_id,
                     p_customer_id         => null,
                     p_address_id          => null,
                     p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
                     p_resource_id         => l_resource_id_tbl(i),
                     p_access_type         => pv_assignment_pub.g_pt_access,
                     x_access_id           => l_access_id,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data);

                  if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                     raise FND_API.G_EXC_ERROR;
                  end if;

               end loop;

               -- remove all CMs for partner from access if there is no more partner for the CM

               l_username_tbl.delete;
               l_resource_id_tbl.delete;

               open lc_get_uniq_cm_for_pt (pc_itemtype    => itemtype,
                                           pc_itemkey     => itemkey,
                                           pc_partner_id  => l_partner_id_tbl(i),
                                           pc_notify_type => pv_assignment_pub.g_notify_type_matched_to);
               loop
                  fetch lc_get_uniq_cm_for_pt into l_username, l_resource_id;
                  exit when lc_get_uniq_cm_for_pt%notfound;

                  l_username_tbl.extend;
                  l_resource_id_tbl.extend;
                  l_username_tbl(l_username_tbl.last)       := l_username;
                  l_resource_id_tbl(l_resource_id_tbl.last) := l_resource_id;

               end loop;
               close lc_get_uniq_cm_for_pt;

               for i in 1 .. l_username_tbl.count loop

                  pv_assign_util_pvt.updateaccess(
                     p_api_version_number  => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_FALSE,
                     p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                     p_itemtype            => itemType,
                     p_itemkey             => itemKey,
                     p_current_username    => l_username_tbl(i),
                     p_lead_id             => l_lead_id,
                     p_customer_id         => null,
                     p_address_id          => null,
                     p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
                     p_resource_id         => l_resource_id_tbl(i),
                     p_access_type         => pv_assignment_pub.g_cm_access,
                     x_access_id           => l_access_id,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data);

                  if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                     raise FND_API.G_EXC_ERROR;
                  end if;

               end loop;
            end if;
         end loop;



         open lc_get_pt_org (pc_itemtype => itemtype, pc_itemkey => itemkey);

         loop
            fetch lc_get_pt_org into l_partner_org_rs_id;
            exit when lc_get_pt_org%notfound;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'partner org rs id for timeout '||l_partner_org_rs_id);
               fnd_msg_pub.Add;
            END IF;

            pv_assign_util_pvt.updateaccess(
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_itemtype            => itemType,
               p_itemkey             => itemKey,
               p_current_username    => NULL,
               p_lead_id             => l_lead_id,
               p_customer_id         => l_customer_id,
               p_address_id          => l_address_id,
               p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
               p_resource_id         => l_partner_org_rs_id,
               p_access_type         => pv_assignment_pub.G_PT_ORG_ACCESS,
               x_access_id           => l_access_id,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end loop;
         close lc_get_pt_org;


      elsif l_offer_outcome = g_wf_lkup_offer_withdrawn then

         pv_assignment_pvt.removeRejectedFromAccess (
                                    p_api_version_number  => 1.0,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                                    p_itemtype            => itemType,
                                    p_itemkey             => itemKey,
                                    p_partner_id          => NULL,
                                    x_return_status       => l_return_status,
                                    x_msg_count           => l_msg_count,
                                    x_msg_data            => l_msg_data);

         if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      end if;  -- l_offer_outcome

      if l_offer_outcome = g_wf_lkup_offer_approved then

        if l_assignment_type in (g_wf_lkup_serial, g_wf_lkup_broadcast) then

            if l_assignment_type = g_wf_lkup_broadcast then
               l_rank := -1;
            else
               l_rank := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                     itemkey   => itemkey,
                                                     aname     => g_wf_attr_current_serial_rank);
            end if;

            open lc_get_lost_chance_pt (pc_itemtype  => itemtype,
                                        pc_itemkey   => itemkey,
                                        pc_rank      => l_rank);
            loop

               fetch lc_get_lost_chance_pt into l_assignment_id, l_partner_id;
               exit when lc_get_lost_chance_pt%notfound;

               l_assignment_id_tbl.extend;
               l_partner_id_tbl.extend;
               l_assignment_id_tbl(l_assignment_id_tbl.last) := l_assignment_id;
               l_partner_id_tbl(l_partner_id_tbl.last) := l_partner_id;

            end loop;

            close lc_get_lost_chance_pt;

            for i in 1 .. l_assignment_id_tbl.count loop

               pv_assignment_pvt.UpdateAssignment (
                  p_api_version_number  => 1.0
                  ,p_init_msg_list      => FND_API.G_FALSE
                  ,p_commit             => FND_API.G_FALSE
                  ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                  ,p_action             => pv_assignment_pub.g_asgn_action_status_update
                  ,p_lead_assignment_id => l_assignment_id_tbl(i)
                  ,p_status_date        => sysdate
                  ,p_status             => pv_assignment_pub.g_la_status_lost_chance
                  ,p_reason_code        => NULL
                  ,p_rank               => NULL
                  ,x_msg_count          => l_msg_count
                  ,x_msg_data           => l_msg_data
                  ,x_return_status      => l_return_status);

               if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
               end if;

               -- remove all partner contacts for partner from access

               l_username_tbl.delete;
               l_resource_id_tbl.delete;

               open lc_get_offered_to_for_pt (pc_itemtype => itemtype,
                                           pc_itemkey     => itemkey,
                                           pc_partner_id  => l_partner_id_tbl(i),
                                           pc_notify_type => pv_assignment_pub.g_notify_type_offered_to);

               loop
                  l_username_tbl.extend;
                  l_resource_id_tbl.extend;

                  fetch lc_get_offered_to_for_pt into l_username_tbl(l_username_tbl.last),
                                                      l_resource_id_tbl(l_username_tbl.last);
                  exit when lc_get_offered_to_for_pt%notfound;

               end loop;

               close lc_get_offered_to_for_pt;
               l_username_tbl.trim;
               l_resource_id_tbl.trim;

               for i in 1 .. l_username_tbl.count loop

                  pv_assign_util_pvt.updateAccess(
                     p_api_version_number  => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_FALSE,
                     p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                     p_itemtype            => itemType,
                     p_itemkey             => itemKey,
                     p_current_username    => l_username_tbl(i),
                     p_lead_id             => l_lead_id,
                     p_customer_id         => null,
                     p_address_id          => null,
                     p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
                     p_resource_id         => l_resource_id_tbl(i),
                     p_access_type         => pv_assignment_pub.G_PT_ACCESS,
                     x_access_id           => l_access_id,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data);

                  if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                     raise FND_API.G_EXC_ERROR;
                  end if;

               end loop;

               -- remove all CMs for partner from access that are not CMs of the approved partner

               l_username_tbl.delete;
               l_resource_id_tbl.delete;

               open lc_get_uniq_cm_for_pt (pc_itemtype    => itemtype,
                                           pc_itemkey     => itemkey,
                                           pc_partner_id  => l_partner_id_tbl(i),
                                           pc_notify_type => pv_assignment_pub.g_notify_type_matched_to);
               loop
                  l_username_tbl.extend;
                  l_resource_id_tbl.extend;

                  fetch lc_get_uniq_cm_for_pt into l_username_tbl(l_username_tbl.last),
                                                   l_resource_id_tbl(l_username_tbl.last);
                  exit when lc_get_uniq_cm_for_pt%notfound;

               end loop;

               close lc_get_uniq_cm_for_pt;
               l_username_tbl.trim;
               l_resource_id_tbl.trim;

               for i in 1 .. l_username_tbl.count loop

                  pv_assign_util_pvt.updateAccess(
                     p_api_version_number  => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_FALSE,
                     p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                     p_itemtype            => itemType,
                     p_itemkey             => itemKey,
                     p_current_username    => l_username_tbl(i),
                     p_lead_id             => l_lead_id,
                     p_customer_id         => null,
                     p_address_id          => null,
                     p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
                     p_resource_id         => l_resource_id_tbl(i),
                     p_access_type         => pv_assignment_pub.G_CM_ACCESS,
                     x_access_id           => l_access_id,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data);

                  if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                     raise FND_API.G_EXC_ERROR;
                  end if;

               end loop;
            end loop; -- lost_chance

            open lc_get_pt_lc_org (pc_itemtype => itemtype, pc_itemkey => itemkey);

            loop
               fetch lc_get_pt_lc_org into l_lc_partner_rs_id;
               exit when lc_get_pt_lc_org%notfound;

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'partner org rs id for timeout '||l_partner_org_rs_id);
                  fnd_msg_pub.Add;
               END IF;

               pv_assign_util_pvt.updateaccess(
                  p_api_version_number  => 1.0,
                  p_init_msg_list       => FND_API.G_FALSE,
                  p_commit              => FND_API.G_FALSE,
                  p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                  p_itemtype            => itemType,
                  p_itemkey             => itemKey,
                  p_current_username    => NULL,
                  p_lead_id             => l_lead_id,
                  p_customer_id         => l_customer_id,
                  p_address_id          => l_address_id,
                  p_access_action       => pv_assignment_pub.G_REMOVE_ACCESS,
                  p_resource_id         => l_lc_partner_rs_id,
                  p_access_type         => pv_assignment_pub.G_PT_ORG_ACCESS,
                  x_access_id           => l_access_id,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data);

               if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
               end if;

            end loop;
            close lc_get_pt_lc_org;
         end if;  -- end l_assignment_type in serial,broadcast

         -- for single, serial, broadcast, joint
         -- add partner org to access for approved partner



         open lc_get_partner_org (pc_itemtype => itemtype, pc_itemkey => itemkey);

         loop
            fetch lc_get_partner_org into l_partner_org_rs_id;
            exit when lc_get_partner_org%notfound;

            pv_assign_util_pvt.updateaccess(
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_itemtype            => itemType,
               p_itemkey             => itemKey,
               p_current_username    => NULL,
               p_lead_id             => l_lead_id,
               p_customer_id         => l_customer_id,
               p_address_id          => l_address_id,
               p_access_action       => pv_assignment_pub.G_ADD_ACCESS,
               p_resource_id         => l_partner_org_rs_id,
               p_access_type         => pv_assignment_pub.G_PT_ORG_ACCESS,
               x_access_id           => l_access_id,
               x_return_status       => l_return_status,
               x_msg_count           => l_msg_count,
               x_msg_data            => l_msg_data);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end loop;
         close lc_get_partner_org;

      end if; -- end l_offer_outcome = g_wf_lkup_offer_approved

      -- in case of serial, we only want to send notification for current partner

      l_partner_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => g_wf_attr_partner_id);


      if l_offer_outcome = g_wf_lkup_offer_timedout then

            pv_assignment_pvt.send_notification (
               p_api_version_number   => 1.0
               ,p_init_msg_list       => FND_API.G_FALSE
               ,p_commit              => FND_API.G_FALSE
               ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
               ,p_itemtype            => itemType
               ,p_itemkey             => itemKey
               ,p_activity_id         => actid
               ,P_route_stage         => pv_assignment_pub.g_r_status_offered
               ,p_partner_id          => l_partner_id
               ,x_return_status       => l_return_status
               ,x_msg_count           => l_msg_count
               ,x_msg_data            => l_msg_data);

            if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

      end if;

      wf_engine.SetItemAttrText (itemtype => itemType,
                                 itemkey  => itemKey,
                                 aname    => g_wf_attr_offer_outcome,
                                 avalue   => l_offer_outcome);

      -- this will also work for serial also as the serial process
      -- is not exited until all pts have responded or current
      -- pt has accepted or the opp is withdrawn

      wf_engine.SetItemAttrText (itemtype => itemType,
                                 itemkey  => itemKey,
                                 aname    => g_wf_attr_routing_outcome,
                                 avalue   => l_offer_outcome);

      l_resultout := 'COMPLETE:' || l_offer_outcome;

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end PROCESS_OFFER_OUTCOME;


procedure BYPASS_PT_APPROVAL_CHK (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'BYPASS_PT_APPROVAL_CHK';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(40);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_assignment_type      varchar2(40);
   l_pt_contact_role_name varchar2(40);
   l_partner_id           number;
   l_status               varchar2(30);

   cursor lc_bypass_pt_ok_chk (pc_itemtype   varchar2,
                               pc_itemkey    varchar2,
                               pc_partner_id number) is
   select la.status
   from   pv_lead_assignments    la
   where  la.wf_item_type  = pc_itemtype
   and    la.wf_item_key   = pc_itemkey
   and    la.partner_id    = pc_partner_id;

   cursor lc_any_bypass_pt_ok_chk (pc_itemtype   varchar2,
                                   pc_itemkey    varchar2) is
   select la.status
   from   pv_lead_assignments    la
   where  la.wf_item_type  = pc_itemtype
   and    la.wf_item_key   = pc_itemkey
   and    la.status        = pv_assignment_pub.g_la_status_cm_app_for_pt;


BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_assignment_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_assignment_type);

      if l_assignment_type in (g_wf_lkup_single, g_wf_lkup_serial) then

         -- partner_id is set in single and serial assignment

         l_partner_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_partner_id);

         open lc_bypass_pt_ok_chk (pc_itemtype => itemtype, pc_itemkey  => itemkey, pc_partner_id => l_partner_id);
         fetch lc_bypass_pt_ok_chk into l_status;
         close lc_bypass_pt_ok_chk;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Bypass PT chk: ' || l_status);
            fnd_msg_pub.Add;
         END IF;

      elsif l_assignment_type = g_wf_lkup_joint then

         open lc_any_bypass_pt_ok_chk (pc_itemtype => itemtype, pc_itemkey  => itemkey);
         fetch lc_any_bypass_pt_ok_chk into l_status;
         close lc_any_bypass_pt_ok_chk;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Bypass PT chk: ' || nvl(l_status, 'N'));
            fnd_msg_pub.Add;
         END IF;

      elsif l_assignment_type = g_wf_lkup_broadcast then

         -- not supported in broadcast

         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_token('TEXT', 'Incorrect WF function usage for assignment type: ' || l_assignment_type);
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;

      else

         fnd_message.Set_Name('PV', 'PV_INVALID_ASSIGN_TYPE');
         fnd_message.SET_TOKEN('TYPE', l_assignment_type);
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;

      if l_status = pv_assignment_pub.g_la_status_cm_app_for_pt then
         l_resultout := 'COMPLETE:' || g_wf_lkup_yes;
      else
         l_resultout := 'COMPLETE:' || g_wf_lkup_no;
      end if;


   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end BYPASS_PT_APPROVAL_CHK;


procedure NEED_PT_OK_CHK (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'NEED_PT_OK_CHK';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(40);
   l_return_status        varchar2(1);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_assignment_type      varchar2(40);
   l_partner_id           number;
   l_pt_contact_role_name varchar2(40);
   l_status               varchar2(30);

   cursor lc_any_need_pt_ok_chk (pc_itemtype   varchar2,
                                 pc_itemkey    varchar2) is
   select la.status
   from   pv_lead_assignments    la
   where  la.wf_item_type  = pc_itemtype
   and    la.wf_item_key   = pc_itemkey
   and    la.status        in (pv_assignment_pub.g_la_status_cm_approved,
                               pv_assignment_pub.g_la_status_cm_added,
                               pv_assignment_pub.g_la_status_cm_bypassed,
                               pv_assignment_pub.g_la_status_cm_timeout);
BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_assignment_type := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => g_wf_attr_assignment_type);

      if l_assignment_type in (g_wf_lkup_single, g_wf_lkup_serial, g_wf_lkup_broadcast) then

         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_token('TEXT', 'Incorrect WF function usage for assignment type: ' || l_assignment_type);
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;

      elsif l_assignment_type = g_wf_lkup_joint then

         open  lc_any_need_pt_ok_chk (pc_itemtype => itemtype, pc_itemkey  => itemkey);
         fetch lc_any_need_pt_ok_chk into l_status;
         close lc_any_need_pt_ok_chk;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Bypass PT chk: ' || nvl(l_status, 'N'));
            fnd_msg_pub.Add;
         END IF;

      else

         fnd_message.Set_Name('PV', 'PV_INVALID_ASSIGN_TYPE');
         fnd_message.SET_TOKEN('TYPE', l_assignment_type);
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;

      if l_status is NULL then
         l_resultout := 'COMPLETE:' || g_wf_lkup_no;
      else
         l_resultout := 'COMPLETE:' || g_wf_lkup_yes;
      end if;

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end NEED_PT_OK_CHK;


procedure WRAPUP_PROCESSING (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'WRAPUP_PROCESSING';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_routing_outcome      varchar2(30);
   l_routing_stage        varchar2(30);
   l_routing_type         varchar2(30);
   l_partner_id           number := NULL;

   l_assignment_type      varchar2(30);

   l_msg_count            number;
   l_msg_data             varchar2(2000);

   l_notify_profile       varchar2(30);
   l_lead_id              number;
   l_notify_pt_flag       varchar2(1);
   l_notify_cm_flag       varchar2(1);
   l_notify_am_flag       varchar2(1);
   l_notify_ot_flag       varchar2(1);
   l_notify_enabled_flag  varchar2(1);
   l_combination_count    pls_integer := 0;
   lc_ref_cursor          pv_assignment_pub.g_ref_cursor_type;

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_routing_outcome := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => g_wf_attr_routing_outcome);

      l_lead_id := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => g_wf_attr_opportunity_id);


      if l_routing_outcome in (pv_workflow_pub.g_wf_lkup_match_rejected,
                               pv_workflow_pub.g_wf_lkup_offer_rejected,
                               pv_workflow_pub.g_wf_lkup_offer_timedout) then

         l_routing_stage := pv_assignment_pub.g_r_status_recycled;

         --000000000000000000000000000000000000000000000000000000000000000000000000
         -- In a joint routing, if at least one of the partners has approved the
         -- routing, the routing status should remain ACTIVE even though the
	 -- other partners may have timed out or rejected the assignment.
         --000000000000000000000000000000000000000000000000000000000000000000000000
         FOR x IN (SELECT routing_type
                   FROM   pv_lead_workflows
                   WHERE  lead_id = l_lead_id AND
                          latest_routing_flag = 'Y')
         LOOP
            l_routing_type := x.routing_type;
         END LOOP;

         -- use global constant vairables instead
         IF (l_routing_type = 'JOINT') THEN
            FOR x IN (SELECT COUNT(*) approved_count
                      FROM   pv_lead_assignments
                      WHERE  wf_item_type = itemtype AND
                             wf_item_key  = itemkey AND
                             status IN (pv_assignment_pub.g_la_status_cm_add_app_for_pt,
			                pv_assignment_pub.g_la_status_cm_app_for_pt,
					pv_assignment_pub.g_la_status_pt_approved))
            LOOP
               IF (x.approved_count > 0) THEN
                  l_routing_stage := PV_ASSIGNMENT_PUB.g_r_status_active;
               END IF;
            END LOOP;
         END IF;
         --000000000000000000000000000000000000000000000000000000000000000000000000


      elsif l_routing_outcome in (pv_workflow_pub.g_wf_lkup_match_withdrawn,
                                  pv_workflow_pub.g_wf_lkup_offer_withdrawn) then

         l_routing_stage := pv_assignment_pub.g_r_status_withdrawn;

         IF l_routing_outcome = pv_workflow_pub.g_wf_lkup_offer_withdrawn  THEN

            l_assignment_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => pv_workflow_pub.g_wf_attr_assignment_type);

            IF l_assignment_type = g_wf_lkup_serial THEN
               l_partner_id :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => g_wf_attr_partner_id);
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'l_partner_id ' || l_partner_id);
               fnd_msg_pub.Add;

            END IF;

         END IF;

      elsif l_routing_outcome in (pv_workflow_pub.g_wf_lkup_offer_approved) then

         l_routing_stage := pv_assignment_pub.g_r_status_active;

      else

         fnd_message.SET_NAME('PV', 'Invalid routing outcome: ' || l_routing_outcome);
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;
      IF l_routing_stage <> pv_assignment_pub.g_r_status_active    THEN
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                fnd_message.Set_Token('TEXT', 'checking and removing preferred partner');
                fnd_msg_pub.Add;
           END IF;
         IF l_lead_id IS NOT NULL THEN
            PV_ASSIGN_UTIL_PVT.removePreferedPartner
            (
             p_api_version_number  => 1.0,
             p_init_msg_list       => FND_API.G_FALSE,
             p_commit              => FND_API.G_FALSE,
             p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
             p_lead_id             => l_lead_id,
             p_item_type           => itemtype,
             p_item_key            => itemkey,
             p_partner_id          => NULL,
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data
            );
           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;


      END IF;
      pv_assignment_pvt.update_routing_stage (
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_itemType            => itemtype,
         p_itemKey             => itemKey,
         p_routing_stage       => l_routing_stage,
         p_active_but_open_flag => 'N',
         x_return_status       => l_return_status,
         x_msg_count           => l_msg_count,
         x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      pv_assignment_pvt.send_notification (
       p_api_version_number   => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE
       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       ,p_itemtype            => itemType
       ,p_itemkey             => itemKey
       ,p_activity_id         => actid
       ,P_route_stage         => l_routing_stage
       ,p_partner_id          => l_partner_id
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      l_resultout := 'COMPLETE:null';

   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
      l_resultout := 'COMPLETE';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end WRAPUP_PROCESSING;

procedure ABANDON_FYI (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'ABANDON_FYI';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_routing_stage        varchar2(30);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_partner_id        NUMBER;


BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      l_partner_id :=  wf_engine.GetItemAttrText(itemtype => itemType,
                   itemkey  => itemKey,
                                  aname    => pv_workflow_pub.g_wf_attr_ext_org_party_id);

      pv_assignment_pvt.send_notification (
       p_api_version_number   => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE
       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       ,p_itemtype            => itemType
       ,p_itemkey             => itemKey
       ,p_activity_id         => actid
       ,P_route_stage         => pv_assignment_pub.g_r_status_abandoned
       ,p_partner_id          => l_partner_id
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;


   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
     l_resultout := 'TIMEOUT';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end ABANDON_FYI;

procedure WITHDRAW_FYI (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'WITHDRAW_FYI';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(30);
   l_return_status        varchar2(1);
   l_routing_stage        varchar2(30);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_partner_id        NUMBER;


BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   if (funcmode = 'RUN') then

      pv_assignment_pvt.send_notification (
       p_api_version_number   => 1.0
       ,p_init_msg_list       => FND_API.G_FALSE
       ,p_commit              => FND_API.G_FALSE
       ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       ,p_itemtype            => itemType
       ,p_itemkey             => itemKey
       ,p_activity_id         => actid
       ,P_route_stage         => pv_assignment_pub.g_r_status_withdrawn
       ,p_partner_id          => NULL
       ,x_return_status       => l_return_status
       ,x_msg_count           => l_msg_count
       ,x_msg_data            => l_msg_data);

      if l_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;


   elsif (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

   elsif (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

   elsif (funcmode = 'TIMEOUT') then
     l_resultout := 'TIMEOUT';

   end if;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

end WITHDRAW_FYI;

procedure GET_PRODUCTS (document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2) IS

-- ----------------------------------------------------------------------------------
-- pklin
-- Eliminated reference to wf_notifications from all the queries
-- ----------------------------------------------------------------------------------
cursor lc_get_products (pc_entity_id number, pc_notification_id number) is
   select c.CONCAT_CAT_PARENTAGE, decode(nvl(b.total_amount,0),0,'', b.total_amount || ' ' || a.currency_code) amount
   from as_leads_all a, as_lead_lines_all b, eni_prod_den_hrchy_parents_v c
   where a.lead_id = pc_entity_id
   and a.lead_id = b.lead_id
   and b.product_cat_set_id = c.category_set_id
   and b.product_category_id = c.category_id;

cursor lc_max_products_length (pc_entity_id number, pc_notification_id number) is
   select max(length(c.CONCAT_CAT_PARENTAGE)), max(length(to_char(b.total_amount) || ' ' || a.currency_code))
   from as_leads_all a, as_lead_lines_all b, eni_prod_den_hrchy_parents_v c
   where a.lead_id = pc_entity_id
   and a.lead_id = b.lead_id
   and b.product_cat_set_id = c.category_set_id
   and b.product_category_id = c.category_id;

cursor lc_get_label (pc_notification_id number) is
   select attribute_code,attribute_label_long
   from ak_attributes_tl ak
   where attribute_application_id = 522
   AND ATTRIBUTE_code in ('ASF_AMOUNT','ASF_PRODUCT_CATEGORY')
   AND ak.language= userenv('LANG');

l_max_length_products number;
l_max_length_amount    number;
l_entity_id           number;
l_notification_id     number;
l_label_amount        varchar2(30);
l_label_products      varchar2(200);
l_products_list       varchar2(4000);
l_has_products        boolean;

BEGIN

   l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_entity_id)+2);

   if display_type = 'text/plain' then
      open lc_max_products_length(pc_entity_id => l_entity_id, pc_notification_id => l_notification_id);
      fetch lc_max_products_length into l_max_length_products, l_max_length_amount;
      close lc_max_products_length;
   end if;

   for l_label_rec in lc_get_label(pc_notification_id => l_notification_id) loop

      if l_label_rec.attribute_code = 'ASF_AMOUNT' then
         l_label_amount := l_label_rec.attribute_label_long;
         l_max_length_amount := greatest(l_max_length_amount, length(l_label_amount));
      elsif l_label_rec.attribute_code = 'ASF_PRODUCT_CATEGORY' then
         l_label_products := l_label_rec.attribute_label_long;
         l_max_length_products := greatest(l_max_length_products, length(l_label_products));
      end if;

   end loop;

   for l_prod_rec in lc_get_products(pc_entity_id => l_entity_id, pc_notification_id => l_notification_id)
   loop
      l_has_products := true;
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

END;

procedure GET_OPPTY_CONTACTS (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

cursor lc_get_contacts (pc_lead_id number) is
SELECT EMAIL_ADDRESS emailAddress, PRIMARY_CONTACT_FLAG primaryContact,
PERSON_PRE_NAME_ADJUNCT title, FIRST_NAME||',' || LAST_NAME fullName,
trim(PHONE_COUNTRY_CODE || ' ' || AREA_CODE || ' ' || PHONE_NUMBER || ' ' ||EXTENSION) phoneNumber
FROM AS_OPPORTUNITY_CONTACTS_V WHERE lead_id = pc_lead_id;

cursor lc_max_lengths (pc_entity_id number) is
SELECT max(length(EMAIL_ADDRESS)),
max(length(PERSON_PRE_NAME_ADJUNCT)), max(length( FIRST_NAME||',' || LAST_NAME)),
max(length(trim(PHONE_COUNTRY_CODE || ' ' || AREA_CODE || ' ' || PHONE_NUMBER || ' ' ||EXTENSION)))
FROM AS_OPPORTUNITY_CONTACTS_V WHERE lead_id = pc_entity_id;

cursor lc_get_label (pc_notification_id number) is
select attribute_code,attribute_label_long
from ak_attributes_tl ak
where attribute_application_id = 522
AND ATTRIBUTE_code in ('ASF_EMAIL','ASF_PRIMARY','ASF_TITLE','ASF_PHONE','ASF_CONTACT_NAME')
AND ak.language= userenv('LANG');

l_label_title varchar2(50);
l_label_name varchar2(50);
l_label_primary varchar2(50);
l_label_phone varchar2(50);
l_label_email varchar2(50);

l_max_length_email number := 0;
l_max_length_title number := 0;
l_max_length_name number  := 0;
l_max_length_phone number := 0;

l_entity_id       number;
l_notification_id number;
l_contacts_list   varchar2(4000);
l_has_contacts    boolean;

BEGIN

   l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_entity_id)+2);

   if display_type = 'text/plain' then
      open lc_max_lengths(pc_entity_id => l_entity_id);
      fetch lc_max_lengths into l_max_length_email,l_max_length_title,l_max_length_name,l_max_length_phone;
      close lc_max_lengths;
   end if;

   for l_label_rec in lc_get_label(pc_notification_id => l_notification_id) loop

      if l_label_rec.attribute_code = 'ASF_EMAIL' then
         l_label_email := l_label_rec.attribute_label_long;
         l_max_length_email := greatest(l_max_length_email, length(l_label_email));
      elsif l_label_rec.attribute_code = 'ASF_PRIMARY' then
         l_label_primary := l_label_rec.attribute_label_long;
      elsif l_label_rec.attribute_code = 'ASF_TITLE' then
         l_label_title := l_label_rec.attribute_label_long;
         l_max_length_title := greatest(l_max_length_title, length(l_label_title));
      elsif l_label_rec.attribute_code = 'ASF_PHONE' then
         l_label_phone := l_label_rec.attribute_label_long;
         l_max_length_phone := greatest(l_max_length_phone, length(l_label_phone));
      elsif l_label_rec.attribute_code = 'ASF_CONTACT_NAME' then
         l_label_name := l_label_rec.attribute_label_long;
         l_max_length_name := greatest(l_max_length_name, length(l_label_name));
      end if;

   end loop;

   for l_contact_rec in lc_get_contacts(pc_lead_id => l_entity_id)
   loop
      l_has_contacts := true;
      if display_type = 'text/html' then
         l_contacts_list := l_contacts_list || '<tr>' ||
                            '<td nowrap>' || l_contact_rec.title         || '</td>' ||
                            '<td nowrap>' || l_contact_rec.fullName      || '</td>' ||
                            '<td nowrap>' || l_contact_rec.phoneNumber   || '</td>' ||
                            '<td nowrap>' || l_contact_rec.emailAddress  || '</td>' ||
                            '<td align="center">' || l_contact_rec.primaryContact || '</td></tr>';

      elsif display_type  = 'text/plain' then
         l_contacts_list := l_contacts_list ||
                            rpad( nvl(l_contact_rec.title,' ')         , l_max_length_title+2) ||
                            rpad( nvl(l_contact_rec.fullName,' ')      , l_max_length_name+2) ||
                            rpad( nvl(l_contact_rec.phoneNumber,' ')   , l_max_length_phone+2) ||
                            rpad( nvl(l_contact_rec.emailAddress,' ')  , l_max_length_email+2) ||
                            '   ' || l_contact_rec.primaryContact || fnd_global.local_chr(10);
      end if;
   end loop;

   if l_has_contacts and display_type = 'text/html' then
      l_contacts_list := '<table><tr><th align="left">' || l_label_title || '</th><th align="left">' ||
                          l_label_name || '</th><th align="left">' ||
                          l_label_phone || '</th><th align="left">' || l_label_email || '</th><th>' || l_label_primary ||
                          '</th></tr>' || l_contacts_list || '</table>';

   elsif l_has_contacts and display_type = 'text/plain' then
      l_contacts_list := rpad(l_label_title, l_max_length_title+2) || rpad(l_label_name, l_max_length_name+2) ||
                         rpad(l_label_phone, l_max_length_phone+2) || rpad(l_label_email, l_max_length_email+2) ||
                         l_label_primary || fnd_global.local_chr(10) || l_contacts_list;
   end if;

   document := l_contacts_list;

END;

procedure GET_PUBLISH_NOTES (document_id in varchar2,
                              display_type in varchar2,
                              document in out nocopy varchar2,
                              document_type in out nocopy varchar2) IS

cursor lc_get_notes(pc_entity_id number) is
   select entered_date, entered_by_name, notes, NOTES_DETAIL
   from jtf_notes_vl
   where source_object_code = 'OPPORTUNITY'
   AND SOURCE_OBJECT_ID = pc_entity_id
   AND NOTE_STATUS = 'E'  -- only publish notes
   ORDER BY CREATION_DATE DESC;

cursor lc_max_lengths(pc_entity_id number) is
   select max(length(entered_date)), max(length(entered_by_name))
   from jtf_notes_vl
   where source_object_code = 'OPPORTUNITY'
   AND SOURCE_OBJECT_ID = pc_entity_id
   AND NOTE_STATUS = 'E';

cursor lc_get_label (pc_notification_id number) is
   select attribute_code,attribute_label_long
   from ak_attributes_tl ak
   where attribute_application_id = 522
   AND ATTRIBUTE_code in ('ASF_DATE','ASF_CREATED_BY','ASF_NOTE')
   AND ak.language= userenv('LANG');

   l_label_date   varchar2(50);
   l_label_name   varchar2(50);
   l_label_note   varchar2(50);

   l_max_length_date number := 0;
   l_max_length_name number := 0;

   l_entity_id       number;
   l_notification_id number;
   l_notes_break_pos number;
   l_note_size       binary_integer := 4000;
   l_notes_line      varchar2(200);
   l_notes_frag      varchar2(100);
   l_notes_varchar   varchar2(4000);
   l_notes_list      varchar2(10000);
   l_has_notes       boolean;
   l_notes_end       boolean;
   l_first_line      boolean;

begin

   l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_entity_id)+2);

   if display_type = 'text/plain' then
      open lc_max_lengths(pc_entity_id => l_entity_id);
      fetch lc_max_lengths into l_max_length_date,l_max_length_name;
      close lc_max_lengths;
   end if;

   for l_label_rec in lc_get_label(pc_notification_id => l_notification_id) loop

      if l_label_rec.attribute_code = 'ASF_DATE' then
         l_label_date := l_label_rec.attribute_label_long;
         l_max_length_date := greatest(l_max_length_date, length(l_label_date));
      elsif l_label_rec.attribute_code = 'ASF_CREATED_BY' then
         l_label_name := l_label_rec.attribute_label_long;
         l_max_length_name := greatest(l_max_length_name, length(l_label_name));
      elsif l_label_rec.attribute_code = 'ASF_NOTE' then
         l_label_note := l_label_rec.attribute_label_long;
      end if;

   end loop;

   for l_note_rec in  lc_get_notes(pc_entity_id => l_entity_id) loop

      l_has_notes := true;

      l_notes_varchar := dbms_lob.substr(lob_loc => l_note_rec.notes_detail, amount => l_note_size, offset => 1);
      if l_notes_varchar is null or length(l_notes_varchar) = 0 then
         l_notes_varchar := l_note_rec.notes;
      end if;

      if display_type = 'text/html' then
         l_notes_list := l_notes_list  || '<tr valign="top">' ||
                         '<td nowrap>' || l_note_rec.entered_date    || '</td>' ||
                         '<td nowrap>' || l_note_rec.entered_by_name || '</td>' ||
                         '<td wrap>'   || l_notes_varchar || '</td></tr>';

      elsif display_type  = 'text/plain' then

          l_notes_line := rpad( nvl(to_char(l_note_rec.entered_date),' ')     , l_max_length_date+2) ||
                          rpad( nvl(l_note_rec.entered_by_name,' ')  , l_max_length_name+2);

         l_notes_end  := false;
         l_first_line := true;

         while not l_notes_end loop

            l_notes_break_pos := instr(l_notes_varchar,' ',50);
            if l_notes_break_pos = 0 then
               l_notes_break_pos := 101;  -- show only 1st 100 chars
               l_notes_end       := true; -- cannot break the note or notes is less than 50
            end if;

            l_notes_frag := substr(l_notes_varchar, 1, l_notes_break_pos-1);

            if l_first_line then
               l_notes_list := l_notes_list || l_notes_line ||  l_notes_frag || fnd_global.local_chr(10);
            else
               l_notes_list := l_notes_list || lpad(l_notes_frag, length(l_notes_line)+length(l_notes_frag)) || fnd_global.local_chr(10);
            end if;

            l_notes_varchar := substr(l_notes_varchar, l_notes_break_pos+1);

            if length(l_notes_varchar) = 0 then
               l_notes_end  := true;
            end if;

            l_first_line := false;
         end loop;

      end if;

   end loop;

   if l_has_notes and display_type = 'text/html' then
      l_notes_list := '<table><tr><th align="left">' || l_label_date || '</th><th align="left">' ||
                       l_label_name || '</th><th align="left">' || l_label_note || '</th></tr>' || l_notes_list || '</table>';

   elsif l_has_notes and display_type = 'text/plain' then
      l_notes_list := rpad(l_label_date, l_max_length_date+2) || rpad(l_label_name, l_max_length_name+2) ||
                         l_label_note || fnd_global.local_chr(10) || l_notes_list;
   end if;
   document := l_notes_list;

end;

-- ----------------------------------------------------------------------------------
-- get_assign_type_mean
-- ----------------------------------------------------------------------------------
procedure get_assign_type_mean (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2) IS

cursor lc_get_assign_type_mean (pc_lead_id number) is
SELECT LOWER(b.meaning) meaning
FROM   pv_lead_workflows a,
       fnd_lookup_values_vl b
WHERE  a.lead_id = pc_lead_id AND
       a.routing_type = b.lookup_code AND
       b.lookup_type = 'PV_ASSIGNMENT_TYPE';

l_entity_id           number;
l_notification_id     number;

BEGIN
   l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_entity_id)+2);

   FOR x in lc_get_assign_type_mean(l_entity_id) LOOP
      document := x.meaning;
   END LOOP;
END;

-- ----------------------------------------------------------------------------------
-- get_vendor_org_name
-- ----------------------------------------------------------------------------------
procedure get_vendor_org_name (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2) IS

CURSOR lc_get_vendor_org_name (pc_entity_id NUMBER) IS
SELECT otl.name vendor_name
FROM   pv_lead_workflows a,
       fnd_user b,
       hr_all_organization_units o,
       hr_all_organization_units_tl otl,
       per_all_people_f p
WHERE  a.lead_id    = pc_entity_id AND
       a.created_by = b.user_id AND
       o.organization_id = otl.organization_id AND
       otl.language = userenv('lang') AND
       o.organization_id = p.business_group_id AND
       b.employee_id = p.person_id and
       p.effective_start_date <= sysdate and
       p.effective_end_date >= sysdate
       ;

l_entity_id           number;
l_notification_id     number;

BEGIN
   l_entity_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_entity_id)+2);

   FOR x in lc_get_vendor_org_name(pc_entity_id => l_entity_id) LOOP
      document := x.vendor_name;
   END LOOP;
END;

procedure get_accept_user_org (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2) is
l_partner_id          number;
l_notification_id     number;

cursor c1 (pc_notification number, pc_partner_id number) is
select
nvl(h.name, e.party_name) organization
from
   PV_LEAD_ASSIGNMENTS C,
   pv_oppty_routing_logs a,
   pv_partner_profiles d,
   hz_parties e,
   HR_ALL_ORGANIZATION_UNITS_TL h
where
c.wf_item_type = 'PVASGNMT'
and c.wf_item_key = (select substr(context,10,LENGTH(CONTEXT)-10)
                     from wf_notifications where notification_id = pc_notification)
and c.partner_id = pc_partner_id
and c.lead_assignment_id = a.lead_assignment_id
and a.user_response in ('PT_APPROVED', 'CM_APP_FOR_PT')
and c.partner_id  = d.partner_id
and d.partner_party_id = e.party_id
AND A.vendor_business_unit_id = H.ORGANIZATION_ID (+)
AND H.LANGUAGE (+) = USERENV('LANG');

BEGIN
   l_partner_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_partner_id)+2);

   FOR x in c1 (pc_notification => l_notification_id, pc_partner_id => l_partner_id) LOOP
      document := x.organization;
   END LOOP;
END;


procedure get_accept_user_name (
                        document_id in varchar2,
                        display_type in varchar2,
                        document in out nocopy varchar2,
                        document_type in out nocopy varchar2) is

l_partner_id          number;
l_notification_id     number;

cursor c1 (pc_notification number, pc_partner_id number) is
select
case
     when  a.vendor_user_id is null then
         (select hzp.party_name
      from hz_relationships hzr, hz_parties hzp
      where hzr.party_id=g.source_id and hzr.subject_type='PERSON' and
      hzr.subject_id=hzp.party_id and hzr.object_type= 'ORGANIZATION' )
      else (g.source_first_name || ' ' || g.source_last_name)
end person_name
from
   PV_LEAD_ASSIGNMENTS C,
   pv_oppty_routing_logs a,
   jtf_rs_resource_extns g
where
c.wf_item_type = 'PVASGNMT'
and c.wf_item_key = (select substr(context,10,LENGTH(CONTEXT)-10)
                     from wf_notifications where notification_id = pc_notification)
and c.partner_id = pc_partner_id
and c.lead_assignment_id = a.lead_assignment_id
and a.user_response in ('PT_APPROVED', 'CM_APP_FOR_PT')
and nvl(a.vendor_user_id, a.pt_contact_user_id) = g.user_id (+);


BEGIN
   l_partner_id := substr(document_id, 1, instr(document_id, ':')-1);
   l_notification_id := substr(document_id, length(l_partner_id)+2);

   FOR x in c1 (pc_notification => l_notification_id, pc_partner_id => l_partner_id) LOOP
      document := x.person_name;
   END LOOP;
END;


End PV_WORKFLOW_PUB;

/
