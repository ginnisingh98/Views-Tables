--------------------------------------------------------
--  DDL for Package Body PV_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ASSIGNMENT_PUB" as
/* $Header: pvxasgnb.pls 120.8 2006/08/24 20:58:04 amaram ship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30):='PV_ASSIGNMENT_PUB';
G_FILE_NAME   CONSTANT VARCHAR2(12):='pvxasgnb.pls';

-- ----------------------------------------------------------------------------------
-- ORA-00054: resource busy and acquire with NOWAIT specified
-- ----------------------------------------------------------------------------------
g_e_resource_busy EXCEPTION;
PRAGMA EXCEPTION_INIT(g_e_resource_busy, -54);


--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    CreateAssignment                                                        |
--|                                                                            |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
procedure CreateAssignment (p_api_version_number  IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                            p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                            p_entity              in  VARCHAR2,
                            p_lead_id             in  NUMBER,
                            p_creating_username   IN  VARCHAR2,
                            p_assignment_type     in  VARCHAR2,
                            p_bypass_cm_ok_flag   in  VARCHAR2,
                            p_partner_id_tbl      in  JTF_NUMBER_TABLE,
                            p_rank_tbl            in  JTF_NUMBER_TABLE,
                            p_partner_source_tbl  in  JTF_VARCHAR2_TABLE_100,
                            p_process_rule_id     in  NUMBER,
                            x_return_status       OUT NOCOPY  VARCHAR2,
                            x_msg_count           OUT NOCOPY  NUMBER,
                            x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'CreateAssignment';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_itemType            varchar2(30);
   l_itemKey             varchar2(30);
   l_user_category       varchar2(30);
   l_org_category        varchar2(30);
   l_pt_org_name         varchar2(100);
   l_am_org_name         varchar2(100);
   l_assignment_rec      pv_assign_util_pvt.ASSIGNMENT_REC_TYPE;
   l_assignment_id       number;
   l_source_id           number;
   l_user_id             number;
   l_vad_id              number;
   l_pt_org_party_id     number;
   l_routing_status      varchar2(30);
   l_wf_status           varchar2(30);
   l_no_channel_mgrs     boolean         := TRUE;
   l_temp_id             number;
   l_lead_number         number;
   l_entity_amount       varchar2(100);
   l_customer_id         number;
   l_customer_name       varchar2(360);
   l_entity_name         varchar2(240);
   l_address_id          number;
   l_lead_contact_id     number;
   l_bulk_running_count  pls_integer := 0;
   l_new_resource_count  pls_integer := 0;
   l_highest_rank_pt_row pls_integer := 1;
   l_lead_workflow_id    number;
   l_prm_keep_flag       varchar2(1);
   l_access_pt_id        number;
   l_chk_pt_status_id    number;
   l_resource_id         NUMBER;
   l_access_id           NUMBER;

   l_has_cm_decision_maker varchar2(1);
   l_has_pt_decision_maker varchar2(1);

   l_attrib_values_rec   pv_assignment_pvt.attrib_values_rec_type;
   l_partner_id_tbl      JTF_NUMBER_TABLE;

   l_party_notify_rec_tbl    pv_assignment_pvt.party_notify_rec_tbl_type;
   l_rs_details_tbl          pv_assign_util_pvt.resource_details_tbl_type := pv_assign_util_pvt.resource_details_tbl_type();
   l_lead_workflow_rec       pv_assign_util_pvt.lead_workflow_rec_type;
   l_ENTYRLS_rec        PV_RULE_RECTYPE_PUB.ENTYRLS_Rec_Type  := PV_RULE_RECTYPE_PUB.G_MISS_ENTYRLS_REC;
   x_entity_rule_applied_id  NUMBER;

   l_oppty_routing_log_rec   PV_ASSIGNMENT_PVT.oppty_routing_log_rec_type;


   -- --------------------------------------------------------------------------------
   -- Checks if the opportunity is "open".
   -- --------------------------------------------------------------------------------
   CURSOR lc_check_open_status IS
      SELECT b.opp_open_status_flag
      FROM   as_leads_all      a,
             as_statuses_b     b
      WHERE  a.lead_id   = p_lead_id AND
             a.status    = b.status_code AND
             b.opp_flag  = 'Y';


   cursor lc_get_assign_type_meaning (pc_assignment_type varchar2) is
      select meaning from pv_lookups
      where  lookup_type = 'PV_ASSIGNMENT_TYPE'
      and    lookup_code = pc_assignment_type;

   cursor lc_get_pt_org_name (pc_partner_id number) is
   select pt.party_name
   from   hz_relationships    pr,
          hz_organization_profiles op,
          hz_parties          pt
   where pr.party_id            = pc_partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');


   cursor lc_opportunity (pc_lead_id number) is
     select ld.customer_id,
            ld.address_id,
            ld.lead_number,
            ld.description,
            ld.total_amount||' '||ld.currency_code,
            pt.party_name,
            lc.lead_contact_id
     from   as_leads_all ld,
            hz_parties   pt,
            as_lead_contacts lc
     where  ld.lead_id = pc_lead_id
     and    ld.customer_id = pt.party_id (+)
     and    ld.lead_id = lc.lead_id (+) for update of ld.lead_id;

   cursor lc_get_user_type (pc_username varchar2) is
   select extn.category,
          extn.source_id,
          fuser.user_id
   from   fnd_user fuser,
          jtf_rs_resource_extns extn
   where  fuser.user_name = pc_username
   and    fuser.user_id   = extn.user_id;

   cursor lc_get_am_org (pc_user_source_id number) is
   select otl.name vendor_name
   from   hr_all_organization_units o,
          hr_all_organization_units_tl otl,
          per_all_people_f p
   where  o.organization_id = otl.organization_id
   and    otl.language = userenv('lang')
   and    o.organization_id = p.business_group_id
   and    p.person_id = pc_user_source_id;

   cursor lc_get_pt_org_id (pc_user_source_id number) is
   select emp.object_id  pt_org_id,
          hp.party_name,
          prof.partner_id
   from   hz_relationships emp,
          pv_partner_profiles prof,
          hz_parties       hp
   where  emp.party_id           = pc_user_source_id
   and    emp.subject_table_name = 'HZ_PARTIES'
   and    emp.object_table_name  = 'HZ_PARTIES'
   and    emp.directional_flag   = 'F'
   and    emp.relationship_code  = 'EMPLOYEE_OF'
   and    emp.relationship_type  = 'EMPLOYMENT'
   and    emp.status            in ('A', 'I')
   and    emp.object_id          = prof.partner_party_id
   and    emp.object_id          = hp.party_id
   and    hp.status             in ('A', 'I');


   cursor lc_get_lead_workflow_id (pc_item_key varchar2)
   is
   select lead_workflow_id
   from   pv_lead_workflows
   where  wf_item_type = 'PVASGNMT'
   and    wf_item_key = pc_item_key;

 -- Start : Rivendell changes
   cursor lc_get_access_details ( pc_lead_id NUMBER)
   is
   select partner_customer_id, prm_keep_flag
   from   as_accesses_all
   where  lead_id = pc_lead_id;
 -- End : Rivendell changes

 -- changin the cursor to check if the partner is inactive or not.
 -- Checking  if any of the partners are inactive.
 -- for bug# 4325252

   cursor lc_chk_pt_status (pc_partner_id number) is
     select   1 num
      from    pv_partner_profiles pvpp
      where   pvpp.partner_id        = pc_partner_id
      and     nvl(pvpp.status,'I') <> 'A';

   cursor lc_validate_vad_pt (pc_partner_id number, pc_vad_id number) is
   select PT_ORG.party_name
   from
          pv_partner_accesses      PT_ACCESS,
          pv_partner_profiles      PT_PROF,
          hz_parties               PT_ORG
   where
          PT_ACCESS.partner_id         = pc_partner_id
   and    PT_ACCESS.partner_id         = PT_PROF.partner_id
   and    PT_PROF.status               = 'A'
   and    PT_PROF.partner_party_id     = PT_ORG.party_id
   and    PT_ORG.status                in ('A', 'I')
   and    PT_ACCESS.vad_partner_id     = pc_vad_id;

 -- Start : Rivendell changes
   CURSOR get_resource_id ( pc_partner_id NUMBER)
   IS
   SELECT resource_id
   FROM   jtf_rs_resource_extns
   WHERE  source_id = pc_partner_id
   AND    category  = 'PARTNER';
 -- End : Rivendell changes

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                      p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

  /* if fnd_profile.value('ASF_PROFILE_DEBUG_MSG_ON') = 'Y' then
      FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   else
      FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;
   end if;           */

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   if (p_assignment_type is NULL) or
       (p_assignment_type NOT IN (pv_workflow_pub.g_wf_lkup_single,
                                  pv_workflow_pub.g_wf_lkup_serial,
                                  pv_workflow_pub.g_wf_lkup_joint,
                                  pv_workflow_pub.g_wf_lkup_broadcast)) then

      fnd_message.SET_NAME('PV', 'PV_INVALID_ASSIGN_TYPE');
      fnd_message.SET_TOKEN('TYPE' , p_assignment_type);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   if p_bypass_cm_ok_flag is NULL then

      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_TOKEN('TEXT' , 'Bypass CM OK Flag Cannot be Null');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   if (p_entity is NULL) or p_entity not in ('OPPORTUNITY') then

      fnd_message.SET_NAME('PV', 'PV_INVALID_ENTITY_TYPE');
      fnd_message.SET_TOKEN('TYPE' , p_entity);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   -- --------------------------------------------------------------------------
   -- Make sure the opportunity is "open".
   -- --------------------------------------------------------------------------
   FOR x IN lc_check_open_status LOOP
      -- -----------------------------------------------------------------------
      -- This is not an "open" opportunity. It cannot be routed.
      -- -----------------------------------------------------------------------
      IF (x.opp_open_status_flag <> 'Y') THEN
         FOR x IN lc_opportunity(p_lead_id) LOOP
            l_entity_name := x.description;
	 END LOOP;

         fnd_message.SET_NAME('PV', 'PV_OPP_ROUTING_CLOSED_OPP');
         fnd_message.SET_TOKEN('OPPORTUNITY_NAME' , l_entity_name);
         fnd_message.SET_TOKEN('LEAD_ID' , p_lead_id);
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;



   if (p_partner_id_tbl.count = 0 or p_partner_id_tbl is null) then

      fnd_message.SET_NAME('PV', 'PV_NO_PRTNR_TO_ROUTE');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   for i in 1..p_partner_id_tbl.count
   loop
      l_chk_pt_status_id := null;
      open  lc_chk_pt_status(p_partner_id_tbl(i));
      fetch lc_chk_pt_status into l_chk_pt_status_id;
      close lc_chk_pt_status;
      if l_chk_pt_status_id is  not null then exit; end if;
   end loop;

   if l_chk_pt_status_id is not null then
      fnd_message.SET_NAME('PV', 'PV_ROUTING_INVALID_PARTNER');
      --fnd_message.SET_TOKEN('TEXT', 'Status of one or more partner is inactive. Unable to initiate assignment process' );
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
   end if;

   l_partner_id_tbl := p_partner_id_tbl;

   open lc_get_user_type (pc_username => p_creating_username);
   fetch lc_get_user_type into l_user_category, l_source_id, l_user_id;
   close lc_get_user_type;

   if l_user_category is null then
      fnd_message.SET_NAME('PV', 'PV_INVALID_USER');
      fnd_message.SET_TOKEN('P_USERNAME', p_creating_username);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
   end if;

   open lc_opportunity(pc_lead_id => p_lead_id);
   fetch lc_opportunity into l_customer_id,   l_address_id, l_lead_number, l_entity_name, l_entity_amount,
              l_customer_name, l_lead_contact_id;
   close lc_opportunity;

   if l_lead_contact_id is null and fnd_profile.value('PV_OPPTY_CONTACT_REQUIRED') = 'Y' then

      fnd_message.SET_NAME('PV', 'PV_OPPTY_CONTACT_REQD');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   if l_lead_number is null then
      fnd_message.SET_NAME('PV', 'PV_LEAD_NOT_FOUND');
      fnd_message.SET_TOKEN('LEAD_ID', p_lead_id);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
   end if;

   -- ---------------------------------------------------------------------------------
   -- Initialize record of table. This is not necessary prior to Oracle 10g.
   -- ---------------------------------------------------------------------------------

   if l_user_category = g_resource_employee then

      l_org_category := g_vendor_org;

      open lc_get_am_org (pc_user_source_id => l_source_id);
      fetch lc_get_am_org into l_am_org_name;
      close lc_get_am_org;

      l_oppty_routing_log_rec.vendor_user_id          := l_user_id;
      l_oppty_routing_log_rec.pt_contact_user_id      := NULL;

   elsif l_user_category = g_resource_party then

      l_org_category := g_external_org;

      open lc_get_pt_org_id (pc_user_source_id => l_source_id);
      fetch lc_get_pt_org_id into l_pt_org_party_id, l_am_org_name, l_vad_id;
      close lc_get_pt_org_id;

      l_oppty_routing_log_rec.vendor_user_id          := NULL;
      l_oppty_routing_log_rec.pt_contact_user_id      := l_user_id;


      if l_pt_org_party_id is null then
         fnd_message.SET_NAME('PV', 'PV_USER_ORG_NOT_FOUND');
         fnd_message.SET_TOKEN('P_USER_NAME' ,p_creating_username );
         fnd_msg_pub.ADD;
         raise FND_API.G_EXC_ERROR;
      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'p_partner_id_tbl.count:' || p_partner_id_tbl.count);
                    fnd_msg_pub.Add;
      end if;


      if p_partner_id_tbl.count = 1 then

         -- check to see if VAD submitted routing to himself (meaning he wants to work on it)
         -- we determine this by checking if the partner_id's subject_id passed in is the same
         -- as the logged in user company party_id
         -- Routing Status will become Active

         if l_vad_id = p_partner_id_tbl(1) then

            -- VAD wants to work on it themselves

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.SET_TOKEN('TEXT' , 'VAD submitting routing to themselves');
               fnd_msg_pub.ADD;
            end if;

            pv_assign_util_pvt.GetWorkflowID (p_api_version_number  => 1.0,
                                             p_init_msg_list       => FND_API.G_FALSE,
                                             p_commit              => FND_API.G_FALSE,
                                             p_validation_level    => p_validation_level,
                                             p_lead_id             => p_lead_id,
                                             p_entity              => p_entity,
                                             x_itemType            => l_itemType,
                                             x_itemKey             => l_itemKey,
                                             x_routing_status      => l_routing_status,
                                             x_wf_status           => l_wf_status,
                                             x_return_status       => x_return_status,
                                             x_msg_count           => x_msg_count,
                                             x_msg_data            => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assignment_pvt.update_routing_stage' );
                    fnd_msg_pub.Add;
            end if;

            pv_assignment_pvt.update_routing_stage (
               p_api_version_number   => 1.0,
               p_init_msg_list        => FND_API.G_FALSE,
               p_commit               => FND_API.G_FALSE,
               p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
               p_itemType             => l_itemtype,
               p_itemKey              => l_itemKey,
               p_routing_stage        => pv_assignment_pub.g_r_status_active,
               p_active_but_open_flag => 'N',
               x_return_status        => x_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;
            -- Oppty_Routing_Log Row


            return;

         end if; --  l_vad_id = p_partner_id_tbl(1)
      end if;  -- p_partner_id_tbl.count = 1

      for i in 1 .. p_partner_id_tbl.count loop

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Running the cursor lc_validate_vad_pt for partner id:' || p_partner_id_tbl(i));
                    fnd_msg_pub.Add;
         end if;

	 open lc_validate_vad_pt (pc_partner_id => p_partner_id_tbl(i), pc_vad_id => l_vad_id);
         fetch lc_validate_vad_pt into l_pt_org_name;
         close lc_validate_vad_pt;

         if l_pt_org_name is null then

            if l_vad_id = p_partner_id_tbl(i) and p_assignment_type <> pv_workflow_pub.g_wf_lkup_joint then

          fnd_message.SET_NAME('PV', 'PV_SELF_ADD_JOINT_ONLY');
          fnd_msg_pub.ADD;
          raise FND_API.G_EXC_ERROR;

       elsif l_vad_id = p_partner_id_tbl(i) and p_assignment_type = pv_workflow_pub.g_wf_lkup_joint then
          null;
       else

          open lc_get_pt_org_name (pc_partner_id => l_partner_id_tbl(i));
          fetch lc_get_pt_org_name into l_pt_org_name;
          close lc_get_pt_org_name;

          fnd_message.SET_NAME('PV', 'PV_NOT_INDIRECTLY_MANAGED');
          fnd_message.SET_TOKEN('P_PARTNER_NAME' , l_pt_org_name);
          fnd_msg_pub.ADD;
          raise FND_API.G_EXC_ERROR;

       end if;
         end if;

      end loop;

   else
      fnd_message.SET_NAME('PV', 'PV_USER_NOT_VALID_CATEGORY');
      fnd_message.SET_TOKEN('P_USER_NAME' ,p_creating_username);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
   end if;      -- l_user_category = g_resource_party

   if p_assignment_type = pv_workflow_pub.g_wf_lkup_serial then
      for v_count IN 1..l_partner_id_tbl.count loop

         if p_rank_tbl(v_count) IS NULL THEN
            fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.SET_TOKEN('TEXT' , 'Rank cannot be null for Serial Assignment');
            fnd_msg_pub.ADD;

            raise FND_API.G_EXC_ERROR;
         end if;
     end loop;
   end if;  -- p_assignment_type = pv_workflow_pub.g_wf_lkup_serial

   if (p_assignment_type = pv_workflow_pub.g_wf_lkup_single and p_partner_id_tbl.count > 1) then

      for v_count IN 1..l_partner_id_tbl.count loop

         if p_rank_tbl(v_count) IS NULL THEN
            fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.SET_TOKEN('TEXT' , 'Rank cannot be null  ');
            fnd_msg_pub.ADD;

            raise FND_API.G_EXC_ERROR;
         end if;

         if p_rank_tbl(v_count) < p_rank_tbl(l_highest_rank_pt_row) then
            l_highest_rank_pt_row := v_count;
         end if;

      end loop;

      for v_count IN 1..l_partner_id_tbl.count loop

         if v_count <> l_highest_rank_pt_row then
            l_partner_id_tbl(v_count) := NULL;
         end if;

      end loop;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.SET_TOKEN('TEXT' , 'Only 1 partner allowed in SINGLE assignment.  ' ||
                  'Highest ranked partner selected: ' || l_partner_id_tbl(l_highest_rank_pt_row));
         fnd_msg_pub.ADD;
      end if;

   end if;

   for i in 1..p_partner_source_tbl.count loop

      if p_partner_source_tbl(i) is NULL OR
         p_partner_source_tbl(i) not in ('CAMPAIGN', 'MATCHING', 'TAP', 'SALESTEAM') then

         fnd_message.SET_NAME('PV', 'PV_NOT_VALID_SOURCE_TYPE');
         fnd_message.SET_TOKEN('P_SOURCE_TYPE' ,p_partner_source_tbl(i));
         fnd_message.SET_TOKEN('P_PARTNER_ID', p_partner_id_tbl(i) );
         fnd_msg_pub.ADD;

         raise FND_API.G_EXC_ERROR;

      end if;

   end loop;

   -- ----------------------------------------------------------------------
   -- setting PRM_KEEP_FLAG to 'Y' for sales team partners
   -- ----------------------------------------------------------------------

  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Running lc_get_access_details cursor' );
                    fnd_msg_pub.Add;
   end if;

   open lc_get_access_details(p_lead_id);
   loop
      fetch lc_get_access_details into l_access_pt_id, l_prm_keep_flag;
      exit when lc_get_access_details%NOTFOUND;
/*
      if l_prm_keep_flag is null OR l_prm_keep_flag = 'N'
      then
         for i in 1 .. p_partner_id_tbl.count loop

            if p_partner_id_tbl(i) = l_access_pt_id then

               update as_accesses_all set prm_keep_flag = 'Y'
               where partner_customer_id = l_access_pt_id
               and lead_id = p_lead_id;

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'Setting prm_keep_flag to Yes for the partner org ');
                  fnd_msg_pub.Add;
               END IF;
             end if;
         end loop;
      end if;
  */
     -- Start: Rivendell Changes
     -- vansub

	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Navigating through partner id table and call pv_assign_util_pvt.updateaccess' );
                    fnd_msg_pub.Add;
        end if;

        FOR i IN 1 .. l_partner_id_tbl.count
        LOOP

            IF l_access_pt_id IS NULL THEN

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Getting resource_id for partner id:' || p_partner_id_tbl(i));
                    fnd_msg_pub.Add;
		end if;

	       OPEN  get_resource_id ( l_partner_id_tbl(i));
               FETCH get_resource_id INTO l_resource_id;
               CLOSE  get_resource_id;

		IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'CAlling pv_assign_util_pvt.updateaccess for resource_id:' || l_resource_id);
                    fnd_msg_pub.Add;
                end if;

               pv_assign_util_pvt.UpdateAccess(
                  p_api_version_number  => 1.0,
                  p_init_msg_list       => FND_API.G_FALSE,
                  p_commit              => FND_API.G_FALSE,
                  p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                  p_itemtype            => l_itemtype,
                  p_itemkey             => l_itemKey,
                  p_current_username    => p_creating_username,
                  p_lead_id             => p_lead_id,
                  p_customer_id         => l_customer_id,
                  p_address_id          => l_address_id,
                  p_access_action       => pv_assignment_pub.G_ADD_ACCESS,
                  p_resource_id         => l_resource_id,
                  p_access_type         => pv_assignment_pub.G_PT_ORG_ACCESS,
                  x_access_id           => l_access_id,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data);

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.SET_TOKEN('TEXT' , 'Added partner to the sales team ..Access Id :'||l_access_id);
                  fnd_msg_pub.ADD;
               end if;
           ELSE
               IF  l_partner_id_tbl(i) =   l_access_pt_id THEN

                    IF l_prm_keep_flag IS NULL OR l_prm_keep_flag = 'N' THEN
                       UPDATE as_accesses_all
                       SET    prm_keep_flag = 'Y'
                       WHERE  partner_customer_id = l_access_pt_id
                       AND    lead_id = p_lead_id;

                       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                          fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                          fnd_message.Set_Token('TEXT', 'Setting prm_keep_flag to Yes for the partner org ');
                          fnd_msg_pub.Add;
                       END IF;
                   END IF;
               END IF;
           END IF;
       END LOOP;
       -- End: Rivendell Changes
  END LOOP;

  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_token('TEXT', 'Calling pv_assign_util_pvt.getWorkFlowId API' );
       fnd_msg_pub.Add;
  end if;

   pv_assign_util_pvt.GetWorkflowID (p_api_version_number  => 1.0,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => p_validation_level,
                                    p_lead_id             => p_lead_id,
                                    p_entity              => p_entity,
                                    x_itemType            => l_itemType,
                                    x_itemKey             => l_itemKey,
                                    x_routing_status      => l_routing_status,
                                    x_wf_status           => l_wf_status,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   if l_wf_status = g_wf_status_open or l_routing_status = g_r_status_active then

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'IN if l_wf_status = g_wf_status_open or l_routing_status = g_r_status_active' );
                    fnd_msg_pub.Add;
      end if;

      fnd_message.SET_NAME('PV', 'PV_EXISTING_WORKFLOW');
      fnd_message.SET_TOKEN('P_LEAD_ID' ,p_lead_id);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   elsif l_wf_status in ('NEW', g_wf_status_closed) then

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'IN elsif l_wf_status is NEW or g_wf_status_closed then' );
                    fnd_msg_pub.Add;
      end if;

      -- the following is executed for new, recycled and abandoned workflows only

      l_itemtype := pv_workflow_pub.g_wf_itemtype_pvasgnmt;

      l_lead_workflow_rec.created_by          := l_user_id;
      l_lead_workflow_rec.last_updated_by     := l_user_id;
      l_lead_workflow_rec.lead_id             := p_lead_id;
      l_lead_workflow_rec.entity              := p_entity;
      l_lead_workflow_rec.wf_item_type        := l_itemtype;
      l_lead_workflow_rec.routing_type        := p_assignment_type;
      l_lead_workflow_rec.routing_status      := pv_assignment_pub.g_r_status_matched;
      l_lead_workflow_rec.wf_status           := pv_assignment_pub.g_wf_status_open;
      l_lead_workflow_rec.bypass_cm_ok_flag   := p_bypass_cm_ok_flag;
      l_lead_workflow_rec.latest_routing_flag := 'Y';

       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assign_util_pvt.Create_LEad_Workflow_Row' );
                    fnd_msg_pub.Add;
      end if;

      pv_assign_util_pvt.Create_lead_workflow_row (
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_workflow_rec        => l_lead_workflow_rec,
         x_ItemKey             => l_itemkey,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assignment_pvt.set_current_routing_flag' );
                    fnd_msg_pub.Add;
      end if;
      pv_assignment_pvt.set_current_routing_flag (
         p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_ItemKey             => l_itemkey,
         p_Entity              => p_entity,
         p_entity_id           => p_lead_id,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Update as_leads_all table with auto_assignment_type = PRM, prm_assignment_type  = p_assignment_type' );
                    fnd_msg_pub.Add;
      end if;

      update as_leads_all
      set auto_assignment_type = 'PRM', prm_assignment_type  = p_assignment_type
      where  lead_id = p_lead_id;

      --    Added part of Rivendell Changes
      --    New Table pv_oppty_routing_logs created to log all the routing changes
      --    for the Routing History Screen

      l_oppty_routing_log_rec.event                   := 'OPPTY_ASSIGN';
      l_oppty_routing_log_rec.lead_id                 := p_lead_id;
      l_oppty_routing_log_rec.lead_workflow_id        := TO_NUMBER(l_itemkey);
      l_oppty_routing_log_rec.routing_type            := p_assignment_type;
      l_oppty_routing_log_rec.latest_routing_flag     := 'Y';
      l_oppty_routing_log_rec.bypass_cm_flag          := p_bypass_cm_ok_flag;
      l_oppty_routing_log_rec.lead_assignment_id      := NULL;
      l_oppty_routing_log_rec.event_date              := SYSDATE;
      l_oppty_routing_log_rec.user_response           := NULL;
      l_oppty_routing_log_rec.reason_code             := NULL;
      l_oppty_routing_log_rec.user_type               := 'LAM';

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assignment_pvt.Create_Oppty_Routing_Log_Row' );
                    fnd_msg_pub.Add;
      end if;

      pv_assignment_pvt.Create_Oppty_Routing_Log_Row (
         p_api_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         p_commit                => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         P_oppty_routing_log_rec => l_oppty_routing_log_rec,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);

      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      for v_count IN 1..l_partner_id_tbl.count loop

         l_assignment_rec := NULL;

         if l_partner_id_tbl(v_count) IS NOT NULL then

            l_rs_details_tbl.delete;     -- since we are using NOCOPY, need to
                                         -- blank out before calling get_partner_info

            if nvl(l_vad_id,-9999) <> l_partner_id_tbl(v_count) then

		IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Getting partner info using pv_assign_util_pvt.get_partner_info for partner id:' || l_partner_id_tbl(v_count) );
                    fnd_msg_pub.Add;
		end if;

               pv_assign_util_pvt.get_partner_info(
                  p_api_version_number      => 1.0
                  ,p_init_msg_list          => FND_API.G_FALSE
                  ,p_commit                 => FND_API.G_FALSE
                  ,p_mode                   => l_org_category
                  ,p_partner_id             => l_partner_id_tbl(v_count)
                  ,p_entity                 => p_entity
                  ,p_entity_id              => p_lead_id
                  ,p_retrieve_mode          => 'BOTH'
                  ,x_rs_details_tbl         => l_rs_details_tbl
                  ,x_vad_id                 => l_vad_id
                  ,x_return_status          => x_return_status
                  ,x_msg_count              => x_msg_count
                  ,x_msg_data               => x_msg_data);

               if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
               end if;

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'Size of l_rs_details_tbl: ' || l_rs_details_tbl.count);
                  fnd_msg_pub.Add;
               END IF;

               if l_rs_details_tbl.count > 0 then

                  l_has_cm_decision_maker := 'N';
                  l_has_pt_decision_maker := 'N';

                  for i in 1 .. l_rs_details_tbl.count loop

                     if l_rs_details_tbl(i).notification_type = g_notify_type_matched_to and
                        l_rs_details_tbl(i).decision_maker_flag = 'Y' then

                        l_has_cm_decision_maker := 'Y';

                     elsif l_rs_details_tbl(i).notification_type = g_notify_type_offered_to and
                        l_rs_details_tbl(i).decision_maker_flag = 'Y' then

                        l_has_pt_decision_maker := 'Y';

                     end if;

                  end loop;

                  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                     fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                     fnd_message.Set_Token('TEXT', 'Has CM decision maker: ' || l_has_cm_decision_maker ||
                                                   ' Has PT decision maker: ' || l_has_pt_decision_maker);
                     fnd_msg_pub.Add;
                  END IF;

                  if l_has_cm_decision_maker <> 'Y' or l_has_pt_decision_maker <> 'Y' then
                     open lc_get_pt_org_name (pc_partner_id => l_partner_id_tbl(v_count));
                     fetch lc_get_pt_org_name into l_pt_org_name;
                     close lc_get_pt_org_name;
                  end if;

                  if l_has_cm_decision_maker <> 'Y' and p_bypass_cm_ok_flag = 'N' then
                     fnd_message.SET_NAME('PV', 'PV_NO_CM_DECISION_MAKER');
                     fnd_message.SET_TOKEN('P_PARTNER_NAME' , l_pt_org_name);
                     fnd_msg_pub.ADD;
                     raise FND_API.G_EXC_ERROR;
                  end if;

                  if l_has_pt_decision_maker <> 'Y' then
                     fnd_message.SET_NAME('PV', 'PV_NO_PT_DECISION_MAKER');
                     fnd_message.SET_TOKEN('P_PARTNER_NAME' , l_pt_org_name);
                     fnd_msg_pub.ADD;
                     raise FND_API.G_EXC_ERROR;
                  end if;

               end if;

            END IF;

            l_assignment_rec.lead_id                := p_lead_id;
            l_assignment_rec.related_party_id       := l_vad_id;

            if l_vad_id is not null then
               l_assignment_rec.related_party_access_code := g_assign_access_update;
            end if;

            l_assignment_rec.partner_id             := l_partner_id_tbl(v_count);
            l_assignment_rec.assign_sequence        := p_rank_tbl(v_count);
            l_assignment_rec.source_type            := p_partner_source_tbl(v_count);
            l_assignment_rec.object_version_number  := 0;
            l_assignment_rec.status_date            := SYSDATE;

            if nvl(l_vad_id, -9999) = l_partner_id_tbl(v_count) then

               l_assignment_rec.status              := pv_assignment_pub.g_la_status_pt_created;
               l_assignment_rec.partner_access_code := g_assign_access_update;

            else

               l_assignment_rec.status              := pv_assignment_pub.g_la_status_assigned;
               l_assignment_rec.partner_access_code := g_assign_access_none;

            end if;

            l_assignment_rec.wf_item_type           := l_itemType;
            l_assignment_rec.wf_item_key            := l_itemKey;

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assign_util_pvt.Create_LEad_assignment_Row' );
                    fnd_msg_pub.Add;
	    end if;

            pv_assign_util_pvt.Create_lead_assignment_row (
               p_api_version_number  => 1.0,
               p_init_msg_list       => FND_API.G_FALSE,
               p_commit              => FND_API.G_FALSE,
               p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
               p_assignment_rec      => l_assignment_rec,
               x_lead_assignment_id  => l_assignment_id,
               x_return_status       => x_return_status     ,
               x_msg_count           => x_msg_count         ,
               x_msg_data            => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

            if l_rs_details_tbl.count > 0 then

               l_new_resource_count := l_rs_details_tbl.count;

               l_party_notify_rec_tbl.WF_ITEM_TYPE.extend       (l_new_resource_count);
               l_party_notify_rec_tbl.WF_ITEM_KEY.extend        (l_new_resource_count);
               l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID.extend (l_new_resource_count);
               l_party_notify_rec_tbl.NOTIFICATION_TYPE.extend  (l_new_resource_count);
               l_party_notify_rec_tbl.RESOURCE_ID.extend        (l_new_resource_count);
               l_party_notify_rec_tbl.USER_ID.extend            (l_new_resource_count);
               l_party_notify_rec_tbl.USER_NAME.extend          (l_new_resource_count);
               l_party_notify_rec_tbl.RESOURCE_RESPONSE.extend  (l_new_resource_count);
               l_party_notify_rec_tbl.RESPONSE_DATE.extend      (l_new_resource_count);
               l_party_notify_rec_tbl.DECISION_MAKER_FLAG.extend(l_new_resource_count);

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                fnd_message.Set_Token('TEXT', 'Adding to pv_party_notifications the following:');
                fnd_msg_pub.Add;
               END IF;

               for i in l_bulk_running_count + 1 .. l_party_notify_rec_tbl.wf_item_type.count loop

                  l_party_notify_rec_tbl.WF_ITEM_TYPE(i)       := l_itemtype;
                  l_party_notify_rec_tbl.WF_ITEM_KEY(i)        := l_itemkey;
                  l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID(i) := l_assignment_id;
                  l_party_notify_rec_tbl.NOTIFICATION_TYPE(i)  := l_rs_details_tbl(i - l_bulk_running_count).notification_type;
                  l_party_notify_rec_tbl.RESOURCE_ID(i)        := l_rs_details_tbl(i - l_bulk_running_count).resource_id;
                  l_party_notify_rec_tbl.USER_ID(i)            := l_rs_details_tbl(i - l_bulk_running_count).user_id;
                  l_party_notify_rec_tbl.USER_NAME(i)          := l_rs_details_tbl(i - l_bulk_running_count).user_name;
                  l_party_notify_rec_tbl.DECISION_MAKER_FLAG(i):= l_rs_details_tbl(i - l_bulk_running_count).decision_maker_flag;

                  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                   fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                   fnd_message.Set_Token('TEXT', 'Assignment ID: ' || l_assignment_id ||
                             '. Notification type: ' || l_party_notify_rec_tbl.NOTIFICATION_TYPE(i) ||
                             '. Decision maker flag: ' || l_party_notify_rec_tbl.decision_maker_flag(i) ||
                             '. Username: ' || l_party_notify_rec_tbl.USER_NAME(i));
                   fnd_msg_pub.Add;
                  END IF;

               end loop;

               l_bulk_running_count := l_bulk_running_count + l_rs_details_tbl.count;

            end if;

         end if;   -- l_partner_id_tbl(v_count) is not null

      end loop; -- l_partner_id_tbl(count)

     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assignment_pvt.bulk_cr_party_notification' );
                    fnd_msg_pub.Add;
      end if;

      pv_assignment_pvt.bulk_cr_party_notification(
         p_api_version_number     => 1.0
         ,p_init_msg_list         => FND_API.G_FALSE
         ,p_commit                => FND_API.G_FALSE
         ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
         ,P_party_notify_Rec_tbl  => l_party_notify_rec_tbl
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      /************************************************************************/
      /*   write access records for the channel managers, partners are later  */
      /************************************************************************/

      l_no_channel_mgrs  := TRUE;

      for i in 1 .. l_party_notify_rec_tbl.RESOURCE_ID.count loop

         if l_party_notify_rec_tbl.notification_type(i) = pv_assignment_pub.g_notify_type_matched_to then

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assig_util_pvt.update access for CMs resource id:' || l_party_notify_rec_tbl.resource_id(i)  );
                    fnd_msg_pub.Add;
            end if;

            pv_assign_util_pvt.updateAccess (
               p_api_version_number  =>  l_api_version_number,
               p_init_msg_list       =>  FND_API.G_FALSE,
               p_commit              =>  FND_API.G_FALSE,
               p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL,
               p_itemtype            =>  l_itemType,
               p_itemkey             =>  l_itemKey,
               p_current_username    =>  p_creating_username,
               p_lead_id             =>  p_lead_id,
               p_customer_id         =>  l_customer_id,
               p_address_id          =>  l_address_id,
               p_access_action       =>  pv_assignment_pub.G_ADD_ACCESS,
               p_resource_id         =>  l_party_notify_rec_tbl.resource_id(i),
               p_access_type         =>  pv_assignment_pub.G_CM_ACCESS,
               x_access_id           =>  l_temp_id,
               x_return_status       =>  x_return_status,
               x_msg_count           =>  x_msg_count,
               x_msg_data            =>  x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

            l_no_channel_mgrs := FALSE;

         end if;

      end loop;

      if l_no_channel_mgrs then
         fnd_message.Set_Name('PV', 'PV_EMPTY_ROLE');
         fnd_msg_pub.Add;
         RAISE FND_API.G_EXC_ERROR;
      end if;

      open  lc_get_assign_type_meaning (pc_assignment_type => p_assignment_type);
      fetch lc_get_assign_type_meaning into l_attrib_values_rec.assignment_type_mean;
      close lc_get_assign_type_meaning;

      l_attrib_values_rec.org_type             := l_org_category;
      l_attrib_values_rec.pt_org_party_id      := l_pt_org_party_id;
      l_attrib_values_rec.am_org_name          := l_am_org_name;
      l_attrib_values_rec.lead_id              := p_lead_id;
      l_attrib_values_rec.lead_number          := l_lead_number;
      l_attrib_values_rec.entity_name          := l_entity_name;
      l_attrib_values_rec.entity_amount        := l_entity_amount;
      l_attrib_values_rec.customer_id          := l_customer_id;
      l_attrib_values_rec.address_id           := l_address_id;
      l_attrib_values_rec.customer_name        := l_customer_name;
      l_attrib_values_rec.assignment_type      := p_assignment_type;
      l_attrib_values_rec.bypass_cm_ok_flag    := p_bypass_cm_ok_flag;
      l_attrib_values_rec.process_rule_id      := p_process_rule_id;
      l_attrib_values_rec.process_name         := pv_workflow_pub.g_wf_pcs_initiate_assignment;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'before calling startworkflow Entity Amount'||l_entity_amount);
         fnd_msg_pub.Add;
      END IF;


	 IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling pv_assignment_pvt.StartWorkflow' );
                    fnd_msg_pub.Add;
          end if;

      pv_assignment_pvt.StartWorkflow( p_api_version_number  => 1.0,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_commit              => FND_API.G_FALSE,
                     p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                     p_itemKey             => l_itemKey,
                     p_itemType            => l_itemType,
                     p_creating_username   => p_creating_username,
                     p_attrib_values_rec   => l_attrib_values_rec,
                     x_return_status       => x_return_status,
                     x_msg_count           => x_msg_count,
                     x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;


      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'process rule id from create assignment'|| p_process_rule_id);
         fnd_msg_pub.Add;
      END IF;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'Calling PV_ASSIGN_UTIL_PVT.checkforErrors ' );
                    fnd_msg_pub.Add;
          end if;


      PV_ASSIGN_UTIL_PVT.checkforErrors ( p_api_version_number   => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         ,p_itemtype           => l_itemtype
         ,p_itemkey            => l_itemkey
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      --
      -- End of API body.
      --

   else
      -- invalid wf_status.  Should not happen since getworkflowid already checks for it
      null;
   end if; -- l_wf_status

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

   FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end CreateAssignment;


procedure process_match_response (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity              in  VARCHAR2,
   p_user_name           IN  VARCHAR2,
   p_lead_id             IN  NUMBER,
   p_partyTbl            in  JTF_NUMBER_TABLE,
   p_rank_Tbl            in  JTF_NUMBER_TABLE,
   p_statusTbl           in  JTF_VARCHAR2_TABLE_100, -- CM_APPROVED,CM_REJECTED,CM_ADDED,NOACTION,CM_APP_FOR_PT,CM_ADD_APP_FOR_PT
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'process_match_response';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_approve_flag             boolean := FALSE;
   l_reject_flag              boolean := FALSE;
   l_no_response_flag         boolean := FALSE;
   l_rejected_cnt         NUMBER := 0;
   l_response            VARCHAR2(50);

   l_assignment_id          NUMBER;
   l_new_lead_assignment_id NUMBER;
   l_user_id                NUMBER;
   l_vad_id                 NUMBER;
   l_cm_rs_id               NUMBER;
   l_bulk_size              NUMBER;
   l_partner_id             NUMBER;
   l_notify_rowid           ROWID;
   l_assign_sequence        PLS_INTEGER;

   l_itemtype               VARCHAR2(30);
   l_itemkey                VARCHAR2(30);
   l_mode                   VARCHAR2(30);
   l_routing_status         VARCHAR2(30);
   l_entity                 VARCHAR2(30);
   l_notify_type            VARCHAR2(30);
   l_decision_maker_flag    VARCHAR2(10);


   l_assignment_type     varchar2(30);
   l_assignment_status   varchar2(30);
   l_match_outcome       varchar2(30);
   l_pt_response         varchar2(30);

   l_assignment_rec          pv_assign_util_pvt.ASSIGNMENT_REC_TYPE;
   l_party_notify_rec_tbl    pv_assignment_pvt.party_notify_rec_tbl_type;
   l_rs_details_tbl          pv_assign_util_pvt.resource_details_tbl_type := pv_assign_util_pvt.resource_details_tbl_type();
   l_pt_response_tbl         g_varchar_table_type := g_varchar_table_type();

   cursor lc_get_assignment_type (pc_lead_id number, pc_entity varchar2) is
      select routing_type from pv_lead_workflows
      where lead_id = pc_lead_id and entity = pc_entity and latest_routing_flag = 'Y';

   cursor lc_get_assignment (pc_lead_id number,
                             pc_username varchar2) is
   select a.wf_item_type
        , a.wf_item_key
        , a.routing_status
        , a.entity
        , b.lead_assignment_id
        , b.assign_sequence
        , b.partner_id
        , b.status
        , c.rowid
        , c.resource_id
        , c.decision_maker_flag
        , c.notification_type
        , c.user_id
   from   pv_lead_workflows a, pv_lead_assignments b, pv_party_notifications c, fnd_user usr
   where  a.lead_id            = pc_lead_id
   and    a.wf_status          = g_wf_status_open
   and    a.wf_item_type       = b.wf_item_type
   and    a.wf_item_key        = b.wf_item_key
   and    b.lead_assignment_id = c.lead_assignment_id
   and    c.user_id            = usr.user_id
   and    usr.user_name        = pc_username;

   cursor lc_chk_match_outcome (pc_itemtype  varchar2,
                                pc_itemkey   varchar2) is
      select status
      from pv_lead_assignments
      where wf_item_type = pc_itemtype
      and   wf_item_key = pc_itemkey
      and   status <> g_la_status_pt_created;

begin

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        fnd_msg_pub.initialize;
    END IF;

   if fnd_profile.value('ASF_PROFILE_DEBUG_MSG_ON') = 'Y' then
      FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   else
      FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
   THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name );
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   open lc_get_assignment_type (pc_lead_id => p_lead_id, pc_entity => p_entity);
   fetch lc_get_assignment_type into l_assignment_type;
   close lc_get_assignment_type;

   if l_assignment_type = pv_workflow_pub.g_wf_lkup_serial then

      for i in 1 .. p_rank_tbl.count loop

         for j in 1+i .. p_rank_tbl.count loop

            if p_rank_tbl(i) = p_rank_tbl(j) then
               fnd_message.Set_Name('PV', 'PV_DUPLICATE_RANK');
               fnd_msg_pub.ADD;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	    end if;

	 end loop;

      end loop;

   end if;

   if l_assignment_type = pv_workflow_pub.g_wf_lkup_single then

      if  p_partyTbl.count > 1 then

         for i in 1 .. p_statusTbl.count loop

            if p_statusTbl(i) = PV_ASSIGNMENT_PUB.g_la_status_cm_rejected then
               l_rejected_cnt := l_rejected_cnt + 1;
            end if;

         end loop;

         if p_partyTbl.count - l_rejected_cnt > 1 then

            fnd_message.Set_Name('PV', 'PV_MULTIPLE_PRTNR_SINGLE');
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         end if;
      end if;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
   THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Getting Assignment Details' );
      fnd_msg_pub.Add;
   END IF;

   open lc_get_assignment (pc_lead_id  => p_lead_id,
                           pc_username => p_user_name);
   loop

      fetch lc_get_assignment into l_itemtype
                                 , l_itemkey
                                 , l_routing_status
                                 , l_entity
                                 , l_assignment_id
                                 , l_assign_sequence
                                 , l_partner_id
                                 , l_assignment_status
                                 , l_notify_rowid
                                 , l_cm_rs_id
                                 , l_decision_maker_flag
                                 , l_notify_type
                                 , l_user_id;

      exit when lc_get_assignment%notfound;



      for i in 1 .. p_partyTbl.last loop

         if l_partner_id = p_partyTbl(i) then

            if l_assign_sequence <> p_rank_Tbl(i) or
               (l_assignment_status <> p_statusTbl(i)) then

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
	       THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_Token('TEXT', 'Calling pv_assignment_pvt.validateResponse' );
		      fnd_msg_pub.Add;
	       END IF;

	       pv_assignment_pvt.validateResponse (
                     p_api_version_number   => 1.0
                     ,p_init_msg_list       => FND_API.G_FALSE
                     ,p_commit              => FND_API.G_FALSE
                     ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                     ,p_response_code       => p_statusTbl(i)
                     ,p_routing_status      => l_routing_status
                     ,p_decision_maker_flag => l_decision_maker_flag
                     ,p_notify_type         => l_notify_type
                     ,x_msg_count           => x_msg_count
                     ,x_msg_data            => x_msg_data
                     ,x_return_status       => x_return_status);

               if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_ERROR;
               end if;

               if l_assignment_status <> p_statusTbl(i) then

		  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
		   THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_Token('TEXT', 'pv_Assignment_pvt.update_party_response' );
		      fnd_msg_pub.Add;
        	  END IF;

                  pv_assignment_pvt.update_party_response (
                      p_api_version_number  => 1.0
                     ,p_init_msg_list      => FND_API.G_FALSE
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                     ,P_rowid              => l_notify_rowid
                     ,p_lead_assignment_id => l_assignment_id
                     ,p_party_resource_id  => l_cm_rs_id
                     ,p_response           => p_statusTbl(i)
                     ,p_reason_code        => NULL
                     ,p_rank               => p_rank_Tbl(i)
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data
                     ,x_return_status      => x_return_status);

                  if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                     raise FND_API.G_EXC_ERROR;
                  end if;

                  IF p_statustbl(i) = g_la_status_cm_rejected  THEN
                     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_Token('TEXT', 'before removing preferred partner by calling pv_assign_util_pvt.removePreferredPartner');
                        fnd_msg_pub.Add;
                     END IF;

                     PV_ASSIGN_UTIL_PVT.removePreferedPartner
                     (
                       p_api_version_number  => 1.0,
                       p_init_msg_list       => FND_API.G_FALSE,
                       p_commit              => FND_API.G_FALSE,
                       p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                       p_lead_id             => p_lead_id,
                       p_item_type           => NULL,
                       p_item_key            => NULL,
                       p_partner_id          => p_partyTbl(i),
                       x_return_status       => x_return_status,
                       x_msg_count           => x_msg_count,
                       x_msg_data            => x_msg_data
                     );
                     IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_ERROR;
                     END IF;

                     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_Token('TEXT', 'after removing preferred partner');
                       fnd_msg_pub.Add;
                     END IF;
                 END IF;
               end if;

               if l_assign_sequence <> p_rank_Tbl(i) then

                  if p_statusTbl(i) in (pv_assignment_pub.g_la_status_cm_added, pv_assignment_pub.g_la_status_cm_add_app_for_pt) then
                     l_response := pv_assignment_pub.g_la_status_cm_approved;
                  else
                     l_response := p_statusTbl(i);
                  end if;

		   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
		   THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_Token('TEXT', 'Calling pv_assignment_pvt.UpdateAssignment' );
		      fnd_msg_pub.Add;
		   END IF;


                  pv_assignment_pvt.UpdateAssignment (
                     p_api_version_number  => 1.0
                     ,p_init_msg_list      => FND_API.G_FALSE
                     ,p_commit             => FND_API.G_FALSE
                     ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
                     ,p_action             => pv_assignment_pub.g_asgn_action_status_update
                     ,p_lead_assignment_id => l_assignment_id
                     ,p_status_date        => sysdate
                     ,p_status             => l_response
                     ,p_reason_code        => NULL
                     ,p_rank               => p_rank_Tbl(i)
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data
                     ,x_return_status      => x_return_status);

                  if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
                     raise FND_API.G_EXC_ERROR;
                  end if;

               end if;
            end if;
            exit;

         end if; -- l_partner_id = p_partyTbl(i)

      end loop; -- 1 .. p_partyTbl.last

   end loop;  -- lc_get_assignment

   close lc_get_assignment;

   if l_itemtype is NULL then
      -- the cursor returned no rows, which means that the person is not in pv_party_notifications)
      -- because of the way the UI is implemented (partner link), this API get's called whenever anyone
      -- changes anything on that page even though the assignment list is not updated
      -- so instead of throwing an exception, just return

      -- fnd_message.set_name('PV', 'PV_NOT_DECISION_MAKER');
      -- fnd_msg_pub.ADD;
      -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      return;
   end if;

   -- check for new partners
   -- Obsoleted for 11.5.10
   l_mode := wf_engine.GetItemAttrText( itemtype => l_itemtype,
                                        itemkey  => l_itemkey,
                                        aname    => pv_workflow_pub.g_wf_attr_organization_type);

   for i in 1 .. p_partyTbl.last loop

      if p_statusTbl(i) in (g_la_status_cm_added,g_la_status_cm_add_app_for_pt) then

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Adding new partner: ' || p_partyTbl(i));
            fnd_msg_pub.Add;
         END IF;

         l_rs_details_tbl.delete;
         l_vad_id := null;

	   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
	   THEN
	      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	      fnd_message.Set_Token('TEXT', 'getting partner info of partner id:' || p_partyTbl(i));
	      fnd_msg_pub.Add;
	   END IF;


         pv_assign_util_pvt.get_partner_info(
            p_api_version_number      => 1.0
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_commit                 => FND_API.G_FALSE
            ,p_mode                   => l_mode
            ,p_partner_id             => p_partyTbl(i)
            ,p_entity                 => l_entity
            ,p_entity_id              => p_lead_id
            ,p_retrieve_mode          => 'PT'
            ,x_rs_details_tbl         => l_rs_details_tbl
            ,x_vad_id                 => l_vad_id
            ,x_return_status          => x_return_status
            ,x_msg_count              => x_msg_count
            ,x_msg_data               => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

         l_assignment_rec.lead_id                := p_lead_id;

         l_assignment_rec.related_party_id       := l_vad_id;
         if l_vad_id is not null then
            l_assignment_rec.related_party_access_code := g_assign_access_update;
         end if;

         l_assignment_rec.partner_id             := p_partyTbl(i);
         l_assignment_rec.partner_access_code    := g_assign_access_none;
         l_assignment_rec.assign_sequence        := p_rank_tbl(i);
         l_assignment_rec.object_version_number  := 0;
         l_assignment_rec.source_type            := g_la_src_type_matching;
         l_assignment_rec.status_date            := SYSDATE;

         if p_statusTbl(i) = g_la_status_cm_added then
            l_assignment_rec.status                 := g_la_status_cm_approved;
         elsif p_statusTbl(i) = g_la_status_cm_add_app_for_pt then
            l_assignment_rec.status                 := g_la_status_cm_app_for_pt;
         end if;

         l_assignment_rec.wf_item_type           := l_itemType;
         l_assignment_rec.wf_item_key            := l_itemKey;

	   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
	   THEN
	      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	      fnd_message.Set_Token('TEXT', 'Calling pv_assign_util_pvt.Create_lead_assignment_row');
	      fnd_msg_pub.Add;
	   END IF;

         pv_assign_util_pvt.Create_lead_assignment_row (
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_assignment_rec      => l_assignment_rec,
            x_lead_assignment_id  => l_new_lead_assignment_id, -- do not overwrite l_assignment_id
            x_return_status       => x_return_status     ,
            x_msg_count           => x_msg_count         ,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

         l_party_notify_rec_tbl.WF_ITEM_TYPE.delete;
         l_party_notify_rec_tbl.WF_ITEM_KEY.delete;
         l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID.delete;
         l_party_notify_rec_tbl.NOTIFICATION_TYPE.delete;
         l_party_notify_rec_tbl.RESOURCE_ID.delete;
         l_party_notify_rec_tbl.USER_ID.delete;
         l_party_notify_rec_tbl.USER_NAME.delete;
         l_party_notify_rec_tbl.RESOURCE_RESPONSE.delete;
         l_party_notify_rec_tbl.RESPONSE_DATE.delete;
         l_party_notify_rec_tbl.DECISION_MAKER_FLAG.delete;

         if l_rs_details_tbl.count > 0 then

            l_bulk_size := l_rs_details_tbl.last + 1;  -- add 1 for the CM

            l_party_notify_rec_tbl.WF_ITEM_TYPE.extend       (l_bulk_size);
            l_party_notify_rec_tbl.WF_ITEM_KEY.extend        (l_bulk_size);
            l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID.extend (l_bulk_size);
            l_party_notify_rec_tbl.NOTIFICATION_TYPE.extend  (l_bulk_size);
            l_party_notify_rec_tbl.RESOURCE_ID.extend        (l_bulk_size);
            l_party_notify_rec_tbl.USER_ID.extend            (l_bulk_size);
            l_party_notify_rec_tbl.USER_NAME.extend          (l_bulk_size);
            l_party_notify_rec_tbl.RESOURCE_RESPONSE.extend  (l_bulk_size);
            l_party_notify_rec_tbl.RESPONSE_DATE.extend      (l_bulk_size);
            l_party_notify_rec_tbl.DECISION_MAKER_FLAG.extend(l_bulk_size);

            for i in 1 .. l_rs_details_tbl.count loop

               l_party_notify_rec_tbl.WF_ITEM_TYPE(i)       := l_itemtype;
               l_party_notify_rec_tbl.WF_ITEM_KEY(i)        := l_itemkey;
               l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID(i) := l_new_lead_assignment_id;
               l_party_notify_rec_tbl.NOTIFICATION_TYPE(i)  := l_rs_details_tbl(i).notification_type;
               l_party_notify_rec_tbl.RESOURCE_ID(i)        := l_rs_details_tbl(i).resource_id;
               l_party_notify_rec_tbl.USER_ID(i)            := l_rs_details_tbl(i).user_id;
               l_party_notify_rec_tbl.USER_NAME(i)          := l_rs_details_tbl(i).user_name;
               l_party_notify_rec_tbl.DECISION_MAKER_FLAG(i):= l_rs_details_tbl(i).decision_maker_flag;

            end loop;

            l_party_notify_rec_tbl.WF_ITEM_TYPE       (l_bulk_size) := l_itemtype;
            l_party_notify_rec_tbl.WF_ITEM_KEY        (l_bulk_size) := l_itemkey;
            l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID (l_bulk_size) := l_new_lead_assignment_id;
            l_party_notify_rec_tbl.NOTIFICATION_TYPE  (l_bulk_size) := g_notify_type_matched_to;
            l_party_notify_rec_tbl.RESOURCE_ID        (l_bulk_size) := l_cm_rs_id;
            l_party_notify_rec_tbl.USER_ID            (l_bulk_size) := l_user_id;
            l_party_notify_rec_tbl.USER_NAME          (l_bulk_size) := p_user_name;
            l_party_notify_rec_tbl.RESOURCE_RESPONSE  (l_bulk_size) := p_statusTbl(i); -- CM_ADDED or CM_ADD_APP_FOR_PT
            l_party_notify_rec_tbl.RESPONSE_DATE      (l_bulk_size) := sysdate;
            l_party_notify_rec_tbl.DECISION_MAKER_FLAG(l_bulk_size) := 'Y';

            pv_assignment_pvt.bulk_cr_party_notification(
               p_api_version_number     => 1.0
               ,p_init_msg_list         => FND_API.G_FALSE
               ,p_commit                => FND_API.G_FALSE
               ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
               ,P_party_notify_Rec_tbl  => l_party_notify_rec_tbl
               ,x_return_status         => x_return_status
               ,x_msg_count             => x_msg_count
               ,x_msg_data              => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end if;
      end if;
   end loop;

   open lc_chk_match_outcome( pc_itemtype => l_itemtype,
                              pc_itemkey  => l_itemkey);
   loop
      fetch lc_chk_match_outcome into l_pt_response;
      exit when lc_chk_match_outcome%notfound;
      l_pt_response_tbl.extend;
      l_pt_response_tbl(l_pt_response_tbl.last) := l_pt_response;
   end loop;

   close lc_chk_match_outcome;

   for i in 1 .. l_pt_response_tbl.count loop

      if l_pt_response_tbl(i) in (g_la_status_cm_approved, g_la_status_cm_added, g_la_status_cm_app_for_pt) then

         l_approve_flag := true;

      elsif l_pt_response_tbl(i) = g_la_status_assigned  then

         l_no_response_flag := true;

      elsif l_pt_response_tbl(i) = g_la_status_cm_rejected  then

         l_reject_flag := true;

      else

         fnd_message.set_name('PV', 'PV_NOT_VALID_ASGNMENT_STATUS');
         fnd_message.set_token('P_PT_RESPONSE', l_pt_response_tbl(i));
         fnd_msg_pub.ADD;

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      end if;

   end loop;

   if not l_no_response_flag then

      -- every decision maker has responded

      if l_approve_flag then

         l_match_outcome := pv_workflow_pub.g_wf_lkup_match_approved;

      elsif l_reject_flag then

         l_match_outcome := pv_workflow_pub.g_wf_lkup_match_rejected;

      end if;

      wf_engine.SetItemAttrText (itemtype => l_itemType,
                                 itemkey  => l_itemKey,
                                 aname    => pv_workflow_pub.g_wf_attr_routing_outcome,
                                 avalue   => l_match_outcome);

      wf_engine.CompleteActivity( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  activity => pv_workflow_pub.g_wf_fn_cm_response_block,
                                  result   => l_match_outcome);

      -- For RUN mode errors, you need to check wf_item_activity_statuses

      PV_ASSIGN_UTIL_PVT.checkforErrors ( p_api_version_number   => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         ,p_itemtype           => l_itemtype
         ,p_itemkey            => l_itemkey
         ,x_return_status      => x_return_status
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

   FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN
      IF sqlcode = -20002 THEN
         fnd_message.Set_Name('PV', 'PV_WF_COMP_ACTY_ERR');
         fnd_msg_pub.Add;
      ELSE
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end process_match_response;


procedure PROCESS_OFFER_RESPONSE (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_entity              in  VARCHAR2
   ,p_lead_id             IN  number
   ,p_partner_id          IN  number
   ,p_user_name           IN  varchar2
   ,p_pt_response         IN  varchar2
   ,p_reason_code         IN  varchar2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'PROCESS_OFFER_RESPONSE';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_notify_rowid        rowid := NULL;
   l_assignment_type     varchar2(30);

   l_pt_org_name            varchar2(100);

   l_assignment_id          number;
   l_access_id              number;
   l_rank                   number;
   l_current_rank           number;
   l_user_id                number;
   l_party_notification_id  number;
   l_customer_id            number;
   l_responder_rs_id        number;
   l_user_is_cm             boolean := false;
   l_party_notify_rec       pv_assign_util_pvt.party_notify_rec_type;
   l_partner_org_rs_id    number;
   l_itemtype            varchar2(30);
   l_itemkey             varchar2(30);
   l_routing_status      varchar2(30);
   l_wf_status           varchar2(30);
   l_decision_maker_flag varchar2(10);
   l_reason_code         varchar2(30);
   l_wf_activity_id      number;

   l_assignment_status   varchar2(30);

   l_username_tab         g_varchar_table_type := g_varchar_table_type();
   l_response_tab         g_varchar_table_type := g_varchar_table_type();
   l_resource_id_tab      g_number_table_type  := g_number_table_type();
   l_partner_id_tab       g_number_table_type  := g_number_table_type();
   l_assignment_id_tab    g_number_table_type  := g_number_table_type();

   cursor lc_validate_reason (pc_lookup_type varchar2, pc_reason_code varchar2) is
   select lookup_code from   pv_lookups
   where  lookup_type = pc_lookup_type
   and    lookup_code = pc_reason_code;

   cursor lc_get_pt_org_name (pc_partner_id number) is
   select pt.party_name
   from   hz_relationships    pr,
          hz_organization_profiles op,
          hz_parties          pt
   where pr.party_id            = pc_partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');

   cursor lc_get_assignment (pc_lead_id     number,
                             pc_entity      varchar2,
                             pc_partner_id  number,
                             pc_notify_type varchar2,
                             pc_username    varchar2)
   is
   select a.wf_item_type, a.wf_item_key, a.routing_status, a.wf_status,
          b.lead_assignment_id, b.status, b.assign_sequence,
          c.rowid, c.resource_id, c.decision_maker_flag, c.user_id
   from   pv_lead_workflows a, pv_lead_assignments b, pv_party_notifications c, fnd_user usr
   where  a.lead_id            = pc_lead_id
   and    a.entity             = pc_entity
   and    a.wf_item_type       = b.wf_item_type
   and    a.wf_item_key        = b.wf_item_key
   and    a.latest_routing_flag = 'Y'
   and    b.partner_id         = pc_partner_id
   and    b.lead_assignment_id = c.lead_assignment_id
   and    c.user_id            = usr.user_id
   and    usr.user_name        = pc_username
   and    c.notification_type  = pc_notify_type;

   cursor lc_any_pt_not_respond_chk (pc_itemtype  varchar2,
                                     pc_itemkey   varchar2) is
      select rowid
      from pv_lead_assignments
      where wf_item_type = pc_itemtype
      and   wf_item_key = pc_itemkey
      and   status in (g_la_status_cm_timeout,
                       g_la_status_cm_bypassed,
                       g_la_status_cm_approved);

   cursor lc_joint_offer_approve_chk (pc_itemtype  varchar2,
                                     pc_itemkey   varchar2) is
      select rowid
      from pv_lead_assignments
      where wf_item_type = pc_itemtype
      and   wf_item_key = pc_itemkey
      and   status in (g_la_status_pt_approved, g_la_status_cm_app_for_pt) and rownum < 2;

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
   and   pn.user_id            = usr.user_id;


   -- improve performance, add in join to access

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
   and   pn.user_id            = usr.user_id
   and   not exists
   (select 1
    from pv_lead_assignments la2,
         pv_party_notifications pn2
   where la2.wf_item_type  = pc_itemtype
   and   la2.wf_item_key   = pc_itemkey
   and   la2.partner_id   <> la.partner_id
   and   la2.status       in (g_la_status_cm_timeout,
                              g_la_status_cm_bypassed,
                              g_la_status_cm_approved,
                              g_la_status_cm_app_for_pt,
                              g_la_status_pt_approved)
   and   la2.lead_assignment_id = pn2.lead_assignment_id
   and   pn2.notification_type  = pc_notify_type
   and   pn2.user_id = pn.user_id );


   cursor lc_get_pt_org (pc_itemtype  varchar2,
                         pc_itemkey   varchar2) is
   select b.resource_id            partner_org_rs_id
   from   pv_lead_assignments la,
          jtf_rs_resource_extns b
   where
          la.wf_item_type = pc_itemtype
   and    la.wf_item_key  = pc_itemkey
   and    la.status       = pv_assignment_pub.g_la_status_pt_rejected
   and    la.partner_id   = b.source_id
   and    b.category      = 'PARTNER'
   and    sysdate between b.start_date_active and nvl(b.end_date_active,sysdate);
begin

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

   if fnd_profile.value('ASF_PROFILE_DEBUG_MSG_ON') = 'Y' then
      FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   else
      FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. p_pt_response=' || p_pt_response);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   if p_pt_response = g_la_status_cm_app_for_pt then

      l_user_is_cm := true;

      open lc_get_assignment (pc_lead_id     => p_lead_id,
                              pc_entity      => p_entity,
                              pc_partner_id  => p_partner_id,
                              pc_notify_type => g_notify_type_matched_to,
                              pc_username    => p_user_name);

   else
      open lc_get_assignment (pc_lead_id     => p_lead_id,
                              pc_entity      => p_entity,
                              pc_partner_id  => p_partner_id,
                              pc_notify_type => g_notify_type_offered_to,
                              pc_username    => p_user_name);
   end if;



   fetch lc_get_assignment into l_itemtype, l_itemkey, l_routing_status, l_wf_status, l_assignment_id, l_assignment_status,
                                l_rank, l_notify_rowid, l_responder_rs_id, l_decision_maker_flag, l_user_id;

   close lc_get_assignment;

 --start of bug fix 5413239
   IF(p_pt_response = g_la_status_cm_app_for_pt and
      l_assignment_status in ('CM_APP_FOR_PT','PT_APPROVED')
   ) then

      fnd_message.Set_Name('PV', 'PV_PARTNER_ALREADY_ACCEPTED');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   --end of bug fix

   -- -----------------------------------------------------------------------------
   -- pklin
   -- lock the row in pv_lead_assignments so no other user can acquire the lock
   -- to this row until the current transaction is completed.
   -- -----------------------------------------------------------------------------
   FOR x IN (SELECT 1
             FROM   pv_lead_assignments
             WHERE  lead_assignment_id = l_assignment_id
             FOR UPDATE NOWAIT)
   LOOP
      null;
   END LOOP;



   if l_notify_rowid is NULL then

      open lc_get_pt_org_name (pc_partner_id => p_partner_id);
      fetch lc_get_pt_org_name into l_pt_org_name;
      close lc_get_pt_org_name;

      if l_user_is_cm then
         fnd_message.Set_Name('PV', 'PV_NOT_CM_FOR_PT');
      else
         fnd_message.Set_Name('PV', 'PV_NOT_CONTACT_FOR_PT');
      end if;

      fnd_message.set_Token('P_PARTNER_NAME', l_pt_org_name);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   if l_wf_status = g_wf_status_closed then
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.set_Token('TEXT', 'Routing has already completed.');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   l_assignment_type := wf_engine.GetItemAttrText( itemtype => l_itemtype,
                                                   itemkey  => l_itemkey,
                                                   aname    => pv_workflow_pub.g_wf_attr_assignment_type);

   if l_assignment_type not in (pv_workflow_pub.g_wf_lkup_single,
                                pv_workflow_pub.g_wf_lkup_serial,
                                pv_workflow_pub.g_wf_lkup_joint,
                                pv_workflow_pub.g_wf_lkup_broadcast) then

      fnd_message.Set_Name('PV', 'PV_NOT_VALID_ASGNMENT_TYPE');
      fnd_message.set_Token('P_ASGNMENT_TYPE', l_assignment_type);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   -- ---------------------------------------------------------------------------
   -- pklin
   -- After a partner rejected an assignment, the same partner cannot approve
   -- the assignment again.
   -- ---------------------------------------------------------------------------
   IF (p_pt_response = 'PT_APPROVED' AND l_assignment_status = 'PT_REJECTED') THEN
         fnd_message.Set_Name('PV', 'PV_CANNOT_APPROVE_AFTER_REJECT');
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   if l_assignment_type = pv_workflow_pub.g_wf_lkup_serial then

      l_current_rank := wf_engine.GetItemAttrNumber( itemtype => l_itemtype,
                                                     itemkey  => l_itemkey,
                                                     aname    => pv_workflow_pub.g_wf_attr_current_serial_rank);
      if l_rank <> l_current_rank then
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.set_Token('TEXT', 'Not partner''s turn yet.  Partner rank is ' || l_rank ||
                                       '.  Current rank is ' || l_current_rank);
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

   end if;

   if l_assignment_type = pv_workflow_pub.g_wf_lkup_joint then

      -- this should only happen in joint and if the user has used the browser back button as
      -- detailed in bug 3258485

      if p_pt_response = 'PT_REJECTED' and l_routing_status = 'ACTIVE' and l_assignment_status = 'PT_APPROVED' then
         fnd_message.Set_Name('PV', 'PV_CANNOT_REJECT_AFTER_APPROVE');
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
   THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Calling pv_assignment_pvt.validateResponse');
      fnd_msg_pub.Add;
   END IF;


   pv_assignment_pvt.validateResponse (
         p_api_version_number   => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         ,p_response_code       => p_pt_response
         ,p_routing_status      => l_routing_status
         ,p_decision_maker_flag => l_decision_maker_flag
         ,p_notify_type         => g_notify_type_offered_to
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
         ,x_return_status       => x_return_status);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_pt_response = g_la_status_pt_rejected then

      if p_reason_code  is NULL then
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.set_Token('TEXT', 'Must specify decline reason');
         fnd_msg_pub.ADD;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      else
         open lc_validate_reason (pc_lookup_type => 'PV_REASON_CODES', pc_reason_code => p_reason_code);
         fetch lc_validate_reason into l_reason_code;
         close lc_validate_reason;

         if l_reason_code is NULL then
            fnd_message.Set_Name('PV', 'PV_NOT_VALID_REASON_CODE');
            fnd_message.set_Token('P_REASON_CODE', p_reason_code);
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

      end if;

   elsif p_pt_response = g_la_status_pt_approved and p_reason_code  is not NULL then

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.set_Token('TEXT', 'Cannot have decline reason when accepting offer');
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   if l_user_is_cm then

      l_party_notify_rec.WF_ITEM_TYPE        := l_itemtype;
      l_party_notify_rec.WF_ITEM_KEY         := l_itemkey;
      l_party_notify_rec.LEAD_ASSIGNMENT_ID  := l_assignment_id;
      l_party_notify_rec.NOTIFICATION_TYPE   := g_notify_type_behalf_of;
      l_party_notify_rec.RESOURCE_ID         := l_responder_rs_id;
      l_party_notify_rec.USER_ID             := l_user_id;
      l_party_notify_rec.USER_NAME           := p_user_name;
      l_party_notify_rec.RESOURCE_RESPONSE   := p_pt_response;
      l_party_notify_rec.RESPONSE_DATE       := sysdate;
      l_party_notify_rec.DECISION_MAKER_FLAG := 'Y';

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
      THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Calling pv_assign_util_pvt.create_party_notification');
      fnd_msg_pub.Add;
      END IF;


      pv_assign_util_pvt.create_party_notification(
         p_api_version_number     => 1.0
         ,p_init_msg_list         => FND_API.G_FALSE
         ,p_commit                => FND_API.G_FALSE
         ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
         ,P_party_notify_Rec      => l_party_notify_rec
         ,x_party_notification_id => l_party_notification_id
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
      THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Calling pv_assignment_pvt.UpdateAssignment');
      fnd_msg_pub.Add;
      END IF;

      pv_assignment_pvt.UpdateAssignment (
         p_api_version_number  => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
         ,p_action             => g_asgn_action_status_update
         ,p_lead_assignment_id => l_assignment_id
         ,p_status_date        => sysdate
         ,p_status             => p_pt_response
         ,p_reason_code        => p_reason_code
         ,p_rank               => NULL
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,x_return_status      => x_return_status);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;

   else

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
      THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Calling pv_assignment_pvt.update_party_response');
      fnd_msg_pub.Add;
      END IF;

      pv_assignment_pvt.update_party_response (
         p_api_version_number  => 1.0
         ,p_init_msg_list      => FND_API.G_FALSE
         ,p_commit             => FND_API.G_FALSE
         ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
         ,P_rowid              => l_notify_rowid
         ,p_lead_assignment_id => l_assignment_id
         ,p_party_resource_id  => l_responder_rs_id
         ,p_response           => p_pt_response
         ,p_reason_code        => p_reason_code
         ,p_rank               => NULL
         ,x_msg_count          => x_msg_count
         ,x_msg_data           => x_msg_data
         ,x_return_status      => x_return_status);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   l_customer_id := wf_engine.GetItemAttrNumber( itemtype => l_itemtype,
                                             itemkey  => l_itemkey,
                                             aname    => pv_workflow_pub.g_wf_attr_customer_id);

   if p_pt_response in (g_la_status_pt_approved, g_la_status_cm_app_for_pt) then

      if l_assignment_type = pv_workflow_pub.g_wf_lkup_joint then

         -- someone else may have already accepted

         if l_routing_status <> pv_assignment_pub.g_r_status_active then


	      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
	      THEN
	      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	      fnd_message.Set_Token('TEXT', 'IN if l_routing_status <> pv_assignment_pub.g_r_status_active then');
	      fnd_msg_pub.Add;
	      END IF;

	      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)
	      THEN
	      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
	      fnd_message.Set_Token('TEXT', 'Calling pv_assignment_pvt.update_routing_stage');
	      fnd_msg_pub.Add;
	      END IF;

            pv_assignment_pvt.update_routing_stage (
               p_api_version_number   => 1.0,
               p_init_msg_list        => FND_API.G_FALSE,
               p_commit               => FND_API.G_FALSE,
               p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
               p_itemType             => l_itemtype,
               p_itemKey              => l_itemKey,
               p_routing_stage        => pv_assignment_pub.g_r_status_active,
               p_active_but_open_flag => 'Y',
               x_return_status        => x_return_status,
               x_msg_count            => x_msg_count,
               x_msg_data             => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;

         end if;

      end if;  -- l_assignment_type

      if l_assignment_type in (pv_workflow_pub.g_wf_lkup_single,
                               pv_workflow_pub.g_wf_lkup_serial,
                               pv_workflow_pub.g_wf_lkup_broadcast) then

         wf_engine.CompleteActivity( itemtype => l_itemtype,
                                     itemkey  => l_itemkey,
                                     activity => pv_workflow_pub.g_wf_fn_pt_response_block,
                                     result   => pv_workflow_pub.g_wf_lkup_offer_approved );

      elsif l_assignment_type = pv_workflow_pub.g_wf_lkup_joint then

         open lc_any_pt_not_respond_chk( pc_itemtype => l_itemtype,
                                         pc_itemkey  => l_itemkey);

         l_notify_rowid := null;
         fetch lc_any_pt_not_respond_chk into l_notify_rowid;
         close lc_any_pt_not_respond_chk;

         if l_notify_rowid is null then

            wf_engine.CompleteActivity( itemtype => l_itemtype,
                                        itemkey  => l_itemkey,
                                        activity => pv_workflow_pub.g_wf_fn_pt_response_block,
                                        result   => pv_workflow_pub.g_wf_lkup_offer_approved );
         end if;

      end if;

   elsif p_pt_response = g_la_status_pt_rejected then

      open lc_get_offered_to_for_pt (pc_itemtype => l_itemtype,
                                  pc_itemkey     => l_itemkey,
                                  pc_partner_id  => p_partner_id,
                                  pc_notify_type => g_notify_type_offered_to);
      loop
         l_username_tab.extend;
         l_resource_id_tab.extend;

         fetch lc_get_offered_to_for_pt into l_username_tab(l_username_tab.last),
                                          l_resource_id_tab(l_username_tab.last);
         exit when lc_get_offered_to_for_pt%notfound;

      end loop;
      close lc_get_offered_to_for_pt;
      l_username_tab.trim;
      l_resource_id_tab.trim;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'before removing preferred partner');
         fnd_msg_pub.Add;
      END IF;

      PV_ASSIGN_UTIL_PVT.removePreferedPartner
      (
        p_api_version_number  => 1.0,
        p_init_msg_list       => FND_API.G_FALSE,
        p_commit              => FND_API.G_FALSE,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        p_lead_id             => p_lead_id,
        p_item_type           => NULL,
        p_item_key            => NULL,
        p_partner_id          => p_partner_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data
      );
      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'after removing preferred partner');
         fnd_msg_pub.Add;
      END IF;


      for i in 1 .. l_username_tab.count loop

	 IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', ' calling pv_assign_util_pvt.updateAccess for user name:' || l_username_tab(i));
         fnd_msg_pub.Add;
         END IF;

	 pv_assign_util_pvt.updateAccess(
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => l_itemType,
            p_itemkey             => l_itemKey,
            p_current_username    => l_username_tab(i),
            p_lead_id             => p_lead_id,
            p_customer_id         => null,
            p_address_id          => null,
            p_access_action       => G_REMOVE_ACCESS,
            p_resource_id         => l_resource_id_tab(i),
            p_access_type         => g_pt_access,
            x_access_id           => l_access_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      end loop;

      -- All the partners who are added to the salesteam to be removed when the partner contact rejects
      -- the opportunity. In case if the routing is done by matching, then the partner do not exist.

      open lc_get_pt_org (pc_itemtype => l_itemType, pc_itemkey => l_itemKey);

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
            p_itemtype            => l_itemType,
            p_itemkey             => l_itemKey,
            p_current_username    => NULL,
            p_lead_id             => p_lead_id,
            p_customer_id         => null,
            p_address_id          => null,
            p_access_action       => G_REMOVE_ACCESS,
            p_resource_id         => l_partner_org_rs_id,
            p_access_type         => G_PT_ORG_ACCESS,
            x_access_id           => l_access_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      end loop;
      close lc_get_pt_org;

      -- remove all CMs for partner from access that are not CMs of the approved partner

      l_username_tab.delete;
      l_resource_id_tab.delete;

      open lc_get_uniq_cm_for_pt (pc_itemtype    => l_itemtype,
                                  pc_itemkey     => l_itemkey,
                                  pc_partner_id  => p_partner_id,
                                  pc_notify_type => g_notify_type_matched_to);
      loop
         l_username_tab.extend;
         l_resource_id_tab.extend;

         fetch lc_get_uniq_cm_for_pt into l_username_tab(l_username_tab.last),
                                             l_resource_id_tab(l_username_tab.last);
         exit when lc_get_uniq_cm_for_pt%notfound;

      end loop;
      close lc_get_uniq_cm_for_pt;
      l_username_tab.trim;
      l_resource_id_tab.trim;

      for i in 1 .. l_username_tab.count loop

         pv_assign_util_pvt.updateAccess(
            p_api_version_number  => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_itemtype            => l_itemType,
            p_itemkey             => l_itemKey,
            p_current_username    => l_username_tab(i),
            p_lead_id             => p_lead_id,
            p_customer_id         => null,
            p_address_id          => null,
            p_access_action       => G_REMOVE_ACCESS,
            p_resource_id         => l_resource_id_tab(i),
            p_access_type         => g_cm_access,
            x_access_id           => l_access_id,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      end loop;

      if l_assignment_type in (pv_workflow_pub.g_wf_lkup_single,
                               pv_workflow_pub.g_wf_lkup_serial) then

         wf_engine.CompleteActivity( itemtype => l_itemtype,
                                     itemkey  => l_itemkey,
                                     activity => pv_workflow_pub.g_wf_fn_pt_response_block,
                                     result   => pv_workflow_pub.g_wf_lkup_offer_rejected );

      elsif l_assignment_type = pv_workflow_pub.g_wf_lkup_broadcast then


         open lc_any_pt_not_respond_chk( pc_itemtype => l_itemtype,
                                         pc_itemkey  => l_itemkey);

         l_notify_rowid := null;
         fetch lc_any_pt_not_respond_chk into l_notify_rowid;
         close lc_any_pt_not_respond_chk;

         if l_notify_rowid is null then

            wf_engine.CompleteActivity( itemtype => l_itemtype,
                                        itemkey  => l_itemkey,
                                        activity => pv_workflow_pub.g_wf_fn_pt_response_block,
                                        result   => pv_workflow_pub.g_wf_lkup_offer_rejected);
         end if;

      elsif l_assignment_type = pv_workflow_pub.g_wf_lkup_joint then


         open lc_any_pt_not_respond_chk( pc_itemtype => l_itemtype,
                                         pc_itemkey  => l_itemkey);

         l_notify_rowid := null;
         fetch lc_any_pt_not_respond_chk into l_notify_rowid;
         close lc_any_pt_not_respond_chk;

         if l_notify_rowid is null then

            l_notify_rowid := null;
            open lc_joint_offer_approve_chk (pc_itemtype => l_itemtype,
                                             pc_itemkey  => l_itemkey);

            fetch lc_joint_offer_approve_chk  into l_notify_rowid;
            close lc_joint_offer_approve_chk;

            if l_notify_rowid is null then

               wf_engine.CompleteActivity( itemtype => l_itemtype,
                                           itemkey  => l_itemkey,
                                           activity => pv_workflow_pub.g_wf_fn_pt_response_block,
                                           result   => pv_workflow_pub.g_wf_lkup_offer_rejected);
            else

               wf_engine.CompleteActivity( itemtype => l_itemtype,
                                           itemkey  => l_itemkey,
                                           activity => pv_workflow_pub.g_wf_fn_pt_response_block,
                                           result   => pv_workflow_pub.g_wf_lkup_offer_approved);
            end if;

         end if;
      end if;

   end if; -- partner response

   l_wf_activity_id := wf_engine.GetItemAttrNumber(itemtype => l_itemtype,
                                                   itemkey  => l_itemkey,
                                                   aname    => pv_workflow_pub.g_wf_attr_wf_activity_id);

   pv_assignment_pvt.send_notification (
      p_api_version_number   => 1.0
      ,p_init_msg_list       => FND_API.G_FALSE
      ,p_commit              => FND_API.G_FALSE
      ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
      ,p_itemtype            => l_itemtype
      ,p_itemkey             => l_itemkey
      ,p_activity_id         => l_wf_activity_id
      ,P_route_stage         => g_r_status_offered
      ,p_partner_id          => p_partner_id
      ,x_return_status       => x_return_status
      ,x_msg_count           => x_msg_count
      ,x_msg_data            => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   -- For RUN mode errors, you need to check wf_item_activity_statuses

   PV_ASSIGN_UTIL_PVT.checkforErrors ( p_api_version_number   => 1.0
      ,p_init_msg_list       => FND_API.G_FALSE
      ,p_commit              => FND_API.G_FALSE
      ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
      ,p_itemtype           => l_itemtype
      ,p_itemkey            => l_itemkey
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;


   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

   FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;

EXCEPTION
   WHEN g_e_resource_busy THEN
      -- --------------------------------------------------------------------
      -- pklin
      -- Capture ORA-00054: resource busy and acquire with NOWAIT specified.
      -- This means the row in pv_lead_assignments is already being locked
      -- by another user/session.
      -- --------------------------------------------------------------------
      fnd_message.Set_Name('PV', 'PV_REQUERY_THE_RECORD');
      fnd_msg_pub.ADD;

      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN
      IF sqlcode = -20002 THEN
         fnd_message.Set_Name('PV', 'PV_WF_COMP_ACTY_ERR');
         fnd_msg_pub.Add;
      ELSE
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end PROCESS_OFFER_RESPONSE;



procedure WITHDRAW_ASSIGNMENT (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_entity              in  VARCHAR2
   ,p_lead_id             IN  NUMBER
   ,p_user_name           IN  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'WITHDRAW_ASSIGNMENT';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_routing_stage       VARCHAR2(30);
   l_activity            VARCHAR2(30);
   l_result              VARCHAR2(30);
   l_assignment_status   VARCHAR2(30);
   l_itemtype            VARCHAR2(30);
   l_itemkey             VARCHAR2(30);
   l_assignment_id       NUMBER;
   l_assignment_id_tbl   g_number_table_type := g_number_table_type();
   l_assignment_type     VARCHAR2(30);
   l_rank                NUMBER;
   l_assign_sequence     NUMBER;
   l_rank_tbl            g_number_table_type := g_number_table_type();
   l_status              VARCHAR2(100);
   l_status_tbl          g_varchar_table_type := g_varchar_table_type();

   l_temp                pls_integer;
   l_user_id             NUMBER;
   l_resource_id         NUMBER;
   l_partner_id          NUMBER;
   l_lead_assignment_id  NUMBER;
   l_party_notification_id  NUMBER;

   l_opp_number          VARCHAR2(30);
   l_customer_name       VARCHAR2(360);
   l_vendor_name         VARCHAR2(100);
   l_opp_name            VARCHAR2(240);
   l_assign_type_mean    VARCHAR2(100);
   l_category            VARCHAR2(30);
   l_ven_user_id         NUMBER;
   l_source_id           NUMBER;
   l_opp_amt             VARCHAR2(100);
   l_lead_number         VARCHAR2(30);

   l_party_notify_rec    pv_assign_util_pvt.party_notify_rec_type;
   l_attrib_values_rec   pv_assignment_pvt.attrib_values_rec_type;

   cursor lc_get_routing_stage (pc_lead_id number, pc_entity varchar2) is
   select a.wf_item_type,
          a.wf_item_key,
          a.routing_status,
          a.routing_type,
          b.lead_number,
          b.description,
          b.total_amount||' '||b.currency_code,
          c.party_name
   from   pv_lead_workflows a
      ,   as_leads_all b
       ,  hz_parties c
   where  a.lead_id = pc_lead_id
     and  b.customer_id = c.party_id
     and  a.latest_routing_flag = 'Y'
     and  a.lead_id = b.lead_id
     and  c.status     in ('A', 'I')
     and  a.entity = pc_entity;

   cursor lc_get_assignment (pc_lead_id number
                           , pc_entity varchar2)
   is
   select b.lead_assignment_id, b.assign_sequence, b.status
   from   pv_lead_workflows a, pv_lead_assignments b
   where  a.lead_id = pc_lead_id and a.latest_routing_flag = 'Y' and a.entity = pc_entity
   and    a.wf_item_type = b.wf_item_type
   and    a.wf_item_key  = b.wf_item_key;


   CURSOR lc_get_cm_id      (pc_itemtype  VARCHAR2,
                             pc_itemkey   VARCHAR2)
   IS
   SELECT la.lead_assignment_id
   from   pv_lead_assignments      la
   where  la.wf_item_type        = pc_itemtype
   and    la.wf_item_key         = pc_itemkey
   and    la.status not in (g_la_status_cm_rejected,
			    g_la_status_pt_rejected,
			    g_la_status_pt_timeout,
			    g_la_status_lost_chance,
			    g_la_status_pt_abandoned
                            );


   CURSOR lc_get_assign_type_meaning (pc_assignment_type varchar2)
   IS
   SELECT meaning
   FROM   pv_lookups
   WHERE  lookup_type = 'PV_ASSIGNMENT_TYPE'
   AND    lookup_code = pc_assignment_type;

   CURSOR lc_get_vendor_cat(pc_lead_id NUMBER)
   IS
   SELECT extn.category
        , extn.source_id
        , pwf.created_by
   FROM   pv_lead_workflows pwf
        , jtf_rs_resource_extns extn
   WHERE  pwf.created_by   = extn.user_id
   AND    pwf.entity = 'OPPORTUNITY'
   AND    pwf.latest_routing_flag = 'Y'
   AND    pwf.lead_id = pc_lead_id;


   CURSOR lc_get_ven_emp_name(pc_source_id NUMBER)
   IS
   select otl.name vendor_name
   from   hr_all_organization_units o,
          hr_all_organization_units_tl otl,
          per_all_people_f p
   where  o.organization_id = otl.organization_id
   and    otl.language = userenv('lang')
   and    o.organization_id = p.business_group_id
   and    p.person_id = pc_source_id;

   CURSOR lc_get_ven_pty_name(pc_source_id NUMBER)
   IS
   select hp.party_name
   from   hz_relationships emp,hz_parties hp
   where  emp.party_id           = pc_source_id
   and    emp.subject_table_name = 'HZ_PARTIES'
   and    emp.object_table_name  = 'HZ_PARTIES'
   and    emp.directional_flag   = 'F'
   and    emp.relationship_code  = 'EMPLOYEE_OF'
   and    emp.relationship_type  = 'EMPLOYMENT'
   and    emp.status            in ('A', 'I')
   and    emp.object_id          = hp.party_id
   and    hp.status             in ('A', 'I');

begin

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

/*   if fnd_profile.value('ASF_PROFILE_DEBUG_MSG_ON') = 'Y' then
      FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   else
      FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;
   end if;    */

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Lead id =' || p_lead_id);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;


   open lc_get_routing_stage (pc_lead_id => p_lead_id, pc_entity => p_entity);

   fetch lc_get_routing_stage into l_itemtype
                                 , l_itemkey
                                 , l_routing_stage
                                 , l_assignment_type
                                 , l_lead_number
                                 , l_opp_name
                                 , l_opp_amt
                                 , l_customer_name;
   close lc_get_routing_stage;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Got the routing stage information: routing stage:'|| l_routing_stage || ': l_itemtype:' || l_itemtype || ':l_itemkey:' || l_itemkey );
      fnd_msg_pub.Add;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', '::l_assignment_type:' || l_assignment_type || '::l_lead_number:' || l_lead_number );
      fnd_msg_pub.Add;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', '::l_opp_name:' || l_opp_name || '::l_opp_amt:' ||l_opp_amt );
      fnd_msg_pub.Add;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT',  '::l_customer_name::' || l_customer_name);
      fnd_msg_pub.Add;
   END IF;
   if l_routing_stage is null then

      fnd_message.Set_Name('PV', 'PV_NO_ASGNMENT');
      fnd_message.set_token('P_LEAD_ID', p_lead_id);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif l_routing_stage in (g_r_status_matched, g_r_status_offered) then

       l_rank := wf_engine.GetItemAttrNumber( itemtype => l_itemtype,
                                              itemkey  => l_itemkey,
                                              aname    => pv_workflow_pub.g_wf_attr_current_serial_rank);

      open lc_get_assignment (pc_lead_id  => p_lead_id, pc_entity => p_entity);
      loop
         fetch lc_get_assignment into l_assignment_id, l_assign_sequence, l_status;
         exit when lc_get_assignment%notfound;

         IF  l_assignment_type = pv_workflow_pub.g_wf_lkup_serial
         AND ( l_assign_sequence < l_rank OR l_status = g_la_status_cm_rejected ) THEN

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT','Partner is not a current partner or the oppty to this partner might have been rejetced by CM');
               fnd_msg_pub.Add;
            END IF;

         ELSIF l_assignment_type in (pv_workflow_pub.g_wf_lkup_broadcast, pv_workflow_pub.g_wf_lkup_joint)
         AND   l_status  not in (pv_assignment_pub.g_la_status_cm_added,
                                 pv_assignment_pub.g_la_status_cm_approved,
                                 pv_assignment_pub.g_la_status_cm_bypassed,
                                 pv_assignment_pub.g_la_status_assigned,
                                 pv_assignment_pub.g_la_status_cm_timeout)
         THEN

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'For Joint Selling and Broadcast the status will not be updated to withdrawn ' ||
                                             'for the partners who are not interested in the opp');
               fnd_msg_pub.Add;
            END IF;

         ELSE

            l_assignment_id_tbl.extend;
            l_rank_tbl.extend;
            l_status_tbl.extend;

            l_assignment_id_tbl(l_assignment_id_tbl.last) := l_assignment_id;
            l_rank_tbl(l_rank_tbl.last)     := l_assign_sequence;
            l_status_tbl(l_status_tbl.last) := l_status;

         END IF;  --  l_assignment_type

      end loop;
      close lc_get_assignment;
 --   Match Withdrawn
      if l_routing_stage = g_r_status_matched then

         for i in 1 .. l_assignment_id_tbl.count loop

            IF  l_assignment_type = pv_workflow_pub.g_wf_lkup_serial
            AND l_status_tbl(i) = g_la_status_cm_rejected THEN

               NULL;

            ELSE

               l_assignment_status := g_la_status_match_withdrawn;
               l_activity          := pv_workflow_pub.g_wf_fn_cm_response_block;
               l_result            := pv_workflow_pub.g_wf_lkup_match_withdrawn;

            END IF;
         end loop;
--    offer withdrawn
      elsif l_routing_stage = g_r_status_offered then

         for i in 1 .. l_assignment_id_tbl.count loop

            IF  l_assignment_type = pv_workflow_pub.g_wf_lkup_serial AND l_rank_tbl(i) < l_rank   THEN

               null;

            ELSIF l_assignment_type in (pv_workflow_pub.g_wf_lkup_broadcast, pv_workflow_pub.g_wf_lkup_joint)
            AND   l_status_tbl(i)  in (pv_assignment_pub.g_la_status_pt_rejected,
                                       pv_assignment_pub.g_la_status_cm_rejected,
                                       pv_assignment_pub.g_la_status_lost_chance)
            THEN

               null;

            ELSE

               l_assignment_status := g_la_status_offer_withdrawn;
               l_activity          := pv_workflow_pub.g_wf_fn_pt_response_block;

               l_result            := pv_workflow_pub.g_wf_lkup_offer_withdrawn;
            END IF;

         end loop;

      end if;    --   2: l_routing_stage

      wf_engine.SetItemAttrText (itemtype => l_itemType,
                                 itemkey  => l_itemKey,
                                 aname    => pv_workflow_pub.g_wf_attr_routing_outcome,
                                 avalue   => l_result);

      for i in 1 .. l_assignment_id_tbl.count loop

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT','Calling pv_assignment_pvt.UpdateAssignment for assignment id:' || l_assignment_id_tbl(i));
               fnd_msg_pub.Add;
            END IF;

         pv_assignment_pvt.UpdateAssignment (
            p_api_version_number  => 1.0
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_action             => g_asgn_action_status_update
            ,p_lead_assignment_id => l_assignment_id_tbl(i)
            ,p_status_date        => sysdate
            ,p_status             => l_assignment_status
            ,p_reason_code        => NULL
            ,p_rank               => NULL
            ,x_msg_count          => x_msg_count
            ,x_msg_data           => x_msg_data
            ,x_return_status      => x_return_status);

         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;

      end loop;

      wf_engine.CompleteActivity( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  activity => l_activity,
                                  result   => l_result);

--  vansub:rivendell
--  Active Withdrawn
   elsif l_routing_stage = g_r_status_active then

  /*
      open lc_get_cm_id      (pc_itemtype  => l_itemtype,
                              pc_itemkey   => l_itemkey);

      fetch lc_get_cm_id into  l_lead_assignment_id;
      close lc_get_cm_id;
*/
      for x in lc_get_cm_id      (pc_itemtype  => l_itemtype,
                              pc_itemkey   => l_itemkey)
      loop
		l_assignment_id_tbl.extend;
		l_assignment_id_tbl(l_assignment_id_tbl.last) := x.lead_assignment_id;
      end loop;


  /*   if l_resource_id is null then

        fnd_message.Set_Name('PV',          'PV_NO_WITHDRAW_RIGHTS');
        fnd_message.Set_Token('P_USERNAME', p_user_name);
        fnd_msg_pub.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     end if;

    l_party_notify_rec.WF_ITEM_TYPE        := l_itemtype;
     l_party_notify_rec.WF_ITEM_KEY         := l_itemkey;
     l_party_notify_rec.LEAD_ASSIGNMENT_ID  := l_lead_assignment_id;
     l_party_notify_rec.NOTIFICATION_TYPE   := g_notify_type_withdrawn_by;
     l_party_notify_rec.RESOURCE_ID         := l_resource_id;
     l_party_notify_rec.USER_ID             := l_user_id;
     l_party_notify_rec.USER_NAME           := p_user_name;
     l_party_notify_rec.RESOURCE_RESPONSE   := g_la_status_active_withdrawn;
     l_party_notify_rec.RESPONSE_DATE       := sysdate;
     l_party_notify_rec.DECISION_MAKER_FLAG := 'Y';

     pv_assign_util_pvt.create_party_notification(
       p_api_version_number     => 1.0
      ,p_init_msg_list         => FND_API.G_FALSE
      ,p_commit                => FND_API.G_FALSE
      ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
      ,P_party_notify_Rec      => l_party_notify_rec
      ,x_party_notification_id => l_party_notification_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data);

     if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
     end if;       */

     for i in 1 .. l_assignment_id_tbl.count loop

	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT','Calling pv_assignment_pvt.UpdateAssignment for assignment id:' || l_assignment_id_tbl(i));
               fnd_msg_pub.Add;
            END IF;

	     pv_assignment_pvt.UpdateAssignment (
	       p_api_version_number  => 1.0
	      ,p_init_msg_list      => FND_API.G_FALSE
	      ,p_commit             => FND_API.G_FALSE
	      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
	      ,p_action             => g_asgn_action_status_update
	      ,p_lead_assignment_id => l_assignment_id_tbl(i) -- l_lead_assignment_id
	      ,p_status_date        => sysdate
	      ,p_status             => g_la_status_active_withdrawn
	      ,p_reason_code        => NULL
	      ,p_rank               => NULL
	      ,x_msg_count          => x_msg_count
	      ,x_msg_data           => x_msg_data
	      ,x_return_status      => x_return_status);


	     if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	     end if;
      end loop;

     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT','Removing rejected sales team by Calling pv_assignment_pvt.removeRejectedFromAccess' );
               fnd_msg_pub.Add;
     END IF;

     pv_assignment_pvt.removeRejectedFromAccess (
      p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_itemtype            => l_itemType,
      p_itemkey             => l_itemKey,
      p_partner_id          => l_partner_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data);

     if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
     end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT','Removing preferred partner by Calling PV_ASSIGN_UTIL_PVT.removePreferedPartner' );
               fnd_msg_pub.Add;
     END IF;

     PV_ASSIGN_UTIL_PVT.removePreferedPartner
     (
      p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_lead_id             => p_lead_id,
      p_item_type           => l_itemType,
      p_item_key             => l_itemKey,
      p_partner_id          => l_partner_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
     );
     if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
     end if;

     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT','Update the routing stage by Calling pv_assignment_pvt.update_routing_stage' );
               fnd_msg_pub.Add;
     END IF;

     pv_assignment_pvt.update_routing_stage (
         p_api_version_number   => 1.0,
         p_init_msg_list        => FND_API.G_FALSE,
         p_commit               => FND_API.G_FALSE,
         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
         p_itemType             => l_itemtype,
         p_itemKey              => l_itemKey,
         p_routing_stage        => pv_assignment_pub.g_r_status_withdrawn,
         p_active_but_open_flag => 'N',
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data);

    if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
       raise FND_API.G_EXC_ERROR;
    end if;


 /*   OPEN   lc_get_assign_type_meaning(l_assignment_type);
    FETCH  lc_get_assign_type_meaning INTO l_assign_type_mean;
    CLOSE  lc_get_assign_type_meaning;


    OPEN lc_get_vendor_cat(p_lead_id);
    FETCH lc_get_vendor_cat
    INTO  l_category, l_source_id, l_ven_user_id;
    CLOSE   lc_get_vendor_cat;

    IF  l_category = 'EMPLOYEE' THEN
        OPEN lc_get_ven_emp_name(l_source_id);
        FETCH lc_get_ven_emp_name  INTO  l_vendor_name;
        CLOSE lc_get_ven_emp_name;
    ELSIF l_category = 'PARTY' THEN
        OPEN lc_get_ven_pty_name(l_source_id);
        FETCH lc_get_ven_pty_name  INTO  l_vendor_name;
        CLOSE lc_get_ven_pty_name;
    END IF;


    l_attrib_values_rec.am_org_name          := l_vendor_name;
    l_attrib_values_rec.lead_id              := p_lead_id;
    l_attrib_values_rec.lead_number          := l_lead_number;
    l_attrib_values_rec.entity_name          := l_opp_name;
    l_attrib_values_rec.entity_amount        := l_opp_amt;
    l_attrib_values_rec.customer_name        := l_customer_name;
    l_attrib_values_rec.assignment_type      := l_assignment_type;
    l_attrib_values_rec.assignment_type_mean := l_assign_type_mean;
    l_attrib_values_rec.process_name         := pv_workflow_pub.g_wf_pcs_withdraw_fyi;

    pv_assignment_pvt.StartWorkflow (
         p_api_version_number   => 1.0,
         p_init_msg_list        => FND_API.G_FALSE,
         p_commit               => FND_API.G_FALSE,
         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
         p_itemKey              => l_itemKey,
         p_itemType             => l_itemType,
         p_creating_username    => p_user_name,
         p_attrib_values_rec    => l_attrib_values_rec,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data);       */


 --  vansub:rivendell
   else

      fnd_message.set_name('PV', 'PV_CANNOT_WITHDRAW_ASGNMENT');
      fnd_message.set_token('P_ROUTING_STAGE', l_routing_stage);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;



   -- For RUN mode errors, you need to check wf_item_activity_statuses

   PV_ASSIGN_UTIL_PVT.checkforErrors ( p_api_version_number   => 1.0
      ,p_init_msg_list       => FND_API.G_FALSE
      ,p_commit              => FND_API.G_FALSE
      ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
      ,p_itemtype           => l_itemtype
      ,p_itemkey            => l_itemkey
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;


   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

   FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      IF sqlcode = -20002 THEN
         fnd_message.Set_Name('PV', 'PV_WF_COMP_ACTY_ERR');
         fnd_msg_pub.Add;
      ELSE
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end WITHDRAW_ASSIGNMENT;


procedure ABANDON_ASSIGNMENT (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_entity              in  VARCHAR2
   ,p_lead_id             IN  NUMBER
   ,p_user_name           IN  VARCHAR2
   ,p_reason_code         IN  varchar2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'ABANDON_ASSIGNMENT';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_temp                pls_integer;
   l_user_id             NUMBER;
   l_resource_id         NUMBER;
   l_partner_id          NUMBER;
   l_lead_assignment_id  NUMBER;
   l_party_notification_id  NUMBER;
   l_assignment_status   VARCHAR2(30);
   l_itemtype            VARCHAR2(30);
   l_itemkey             VARCHAR2(30);
   l_routing_stage       VARCHAR2(30);
   l_wf_status           VARCHAR2(30);

   l_opp_number          VARCHAR2(30);
   l_customer_name       VARCHAR2(360);
   l_partner_org         VARCHAR2(100);
   l_vendor_name         VARCHAR2(100);
   l_opp_name            VARCHAR2(240);
   l_action_reason       VARCHAR2(100);
   l_assign_type_mean    VARCHAR2(100);
   l_assignment_type     VARCHAR2(100);
   l_category            VARCHAR2(30);
   l_ven_user_id         NUMBER;
   l_source_id           NUMBER;
   l_opp_amt             VARCHAR2(100);
   l_customer_id         NUMBER;
   l_address_id          NUMBER;
   l_lead_number         VARCHAR2(30);

   l_user_type_tbl    JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
   l_user_name_tbl    JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();


   l_party_notify_rec    pv_assign_util_pvt.party_notify_rec_type;
   l_attrib_values_rec   pv_assignment_pvt.attrib_values_rec_type;


   cursor lc_all_abandon_chk (pc_itemtype varchar2,
                              pc_itemkey  varchar2) is
   select 1
   from   pv_lead_assignments
   where  wf_item_type = pc_itemtype
   and    wf_item_key  = pc_itemkey
   and    status      in (g_la_status_pt_approved, g_la_status_cm_app_for_pt);

   cursor lc_get_partner_id (pc_user_name varchar2,
                             pc_itemtype  varchar2,
                             pc_itemkey   varchar2) is
   select la.partner_id,
          la.lead_assignment_id,
          fu.user_id,
          re.resource_id
   from   fnd_user                 fu,
          jtf_rs_resource_extns    re,
          hz_relationships         emp,
          pv_partner_profiles      pt,
          pv_lead_assignments      la
   where  fu.user_name           = pc_user_name
   and    fu.user_id             = re.user_id
   and    re.category            = 'PARTY'
   and    re.source_id           = emp.party_id
   and    emp.subject_table_name = 'HZ_PARTIES'
   and    emp.object_table_name  = 'HZ_PARTIES'
   and    emp.directional_flag   = 'F'
   and    emp.relationship_code  = 'EMPLOYEE_OF'
   and    emp.relationship_type  = 'EMPLOYMENT'
   and    emp.status            in ('A', 'I')
   and    emp.object_id          = pt.partner_party_id
   and    pt.partner_id          = la.partner_id
   and    la.wf_item_type        = pc_itemtype
   and    la.wf_item_key         = pc_itemkey
   and    la.status in (g_la_status_pt_approved, g_la_status_cm_app_for_pt);

   cursor lc_get_pt_org_name (pc_partner_id number) is
   select pt.party_name
   from   hz_relationships    pr,
          hz_organization_profiles op,
          hz_parties          pt
   where pr.party_id            = pc_partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');

   CURSOR lc_get_lead_rec(pc_lead_id NUMBER)
   IS
   SELECT  a.prm_assignment_type
         , a.lead_number
         , a.description
         , a.total_amount||' '||a.currency_code
         , b.party_name
   FROM    as_leads_all a, hz_parties b
   WHERE   a.lead_id     = pc_lead_id
   AND     a.customer_id = b.party_id
   and     b.status     in ('A', 'I');

   CURSOR lc_get_assign_type_meaning (pc_assignment_type varchar2)
   IS
   SELECT meaning
   FROM   pv_lookups
   WHERE  lookup_type = 'PV_ASSIGNMENT_TYPE'
   AND    lookup_code = pc_assignment_type;

   CURSOR lc_get_vendor_cat(pc_lead_id NUMBER)
   IS
   SELECT extn.category
        , extn.source_id
        , pwf.created_by
   FROM   pv_lead_workflows pwf
        , jtf_rs_resource_extns extn
   WHERE  pwf.created_by   = extn.user_id
   AND    pwf.entity = 'OPPORTUNITY'
   AND    pwf.latest_routing_flag = 'Y'
   AND    pwf.lead_id = pc_lead_id;

-- performance fix for 11.5.9
/*   CURSOR lc_get_ven_emp_name(pc_source_id NUMBER)
   IS
   select bg.name
   from   per_people_x px,  per_business_groups bg
   where  px.person_id = pc_source_id
   and    px.business_group_id = bg.business_group_id; */

   CURSOR lc_get_ven_emp_name(pc_source_id NUMBER)
   IS
   select otl.name vendor_name
   from   hr_all_organization_units o,
        hr_all_organization_units_tl otl,
     per_all_people_f p
   where  o.organization_id = otl.organization_id
   and    otl.language = userenv('lang')
   and      o.organization_id = p.business_group_id
   and      p.person_id = pc_source_id;

   CURSOR lc_get_ven_pty_name(pc_source_id NUMBER)
   IS
   select hp.party_name
   from   hz_relationships emp,hz_parties hp
   where  emp.party_id           = pc_source_id
   and    emp.subject_table_name = 'HZ_PARTIES'
   and    emp.object_table_name  = 'HZ_PARTIES'
   and    emp.directional_flag   = 'F'
   and    emp.relationship_code  = 'EMPLOYEE_OF'
   and    emp.relationship_type  = 'EMPLOYMENT'
   and    emp.status            in ('A', 'I')
   and    emp.object_id          = hp.party_id
   and    hp.status             in ('A', 'I');


begin

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   if fnd_profile.value('ASF_PROFILE_DEBUG_MSG_ON') = 'Y' then
      FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   else
      FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Lead id =' || p_lead_id);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   pv_assign_util_pvt.GetWorkflowID(p_api_version_number  => 1.0,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => p_validation_level,
                                    p_lead_id             => p_lead_id,
                                    p_entity              => p_entity,
                                    x_itemType            => l_itemType,
                                    x_itemKey             => l_itemKey,
                                    x_routing_status      => l_routing_stage,
                                    x_wf_status           => l_wf_status,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   if l_routing_stage <> g_r_status_active or l_routing_stage is NULL then

      fnd_message.Set_Name('PV', 'PV_CANNOT_ABANDON');
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   open lc_get_partner_id (pc_itemtype  => l_itemtype,
                           pc_itemkey   => l_itemkey,
                           pc_user_name => p_user_name);

   fetch lc_get_partner_id into l_partner_id, l_lead_assignment_id, l_user_id, l_resource_id;
   close lc_get_partner_id;

   if l_partner_id is null then

      fnd_message.Set_Name('PV',          'PV_NO_ABANDON_RIGHTS');
      fnd_message.Set_Token('P_USERNAME', p_user_name);
      fnd_msg_pub.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   l_party_notify_rec.WF_ITEM_TYPE        := l_itemtype;
   l_party_notify_rec.WF_ITEM_KEY         := l_itemkey;
   l_party_notify_rec.LEAD_ASSIGNMENT_ID  := l_lead_assignment_id;
   l_party_notify_rec.NOTIFICATION_TYPE   := g_notify_type_abandoned_by;
   l_party_notify_rec.RESOURCE_ID         := l_resource_id;
   l_party_notify_rec.USER_ID             := l_user_id;
   l_party_notify_rec.USER_NAME           := p_user_name;
   l_party_notify_rec.RESOURCE_RESPONSE   := g_la_status_pt_abandoned;
   l_party_notify_rec.RESPONSE_DATE       := sysdate;
   l_party_notify_rec.DECISION_MAKER_FLAG := 'Y';

   pv_assign_util_pvt.create_party_notification(
      p_api_version_number     => 1.0
      ,p_init_msg_list         => FND_API.G_FALSE
      ,p_commit                => FND_API.G_FALSE
      ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
      ,P_party_notify_Rec      => l_party_notify_rec
      ,x_party_notification_id => l_party_notification_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Updating assignment by calling pv_assignment_pvt.UpdateAssignment  for assignment id:' || l_lead_assignment_id);
      fnd_msg_pub.Add;
   END IF;

   pv_assignment_pvt.UpdateAssignment (
      p_api_version_number  => 1.0
      ,p_init_msg_list      => FND_API.G_FALSE
      ,p_commit             => FND_API.G_FALSE
      ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
      ,p_action             => g_asgn_action_status_update
      ,p_lead_assignment_id => l_lead_assignment_id
      ,p_status_date        => sysdate
      ,p_status             => g_la_status_pt_abandoned
      ,p_reason_code        => p_reason_code
      ,p_rank               => NULL
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
      ,x_return_status      => x_return_status);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'before removing preferred partner');
      fnd_msg_pub.Add;
   END IF;

   PV_ASSIGN_UTIL_PVT.removePreferedPartner
   (
      p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_lead_id             => p_lead_id,
      p_item_type           => NULL,
      p_item_key             => NULL,
      p_partner_id          => l_partner_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
   );
   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'after removing preferred partner');
      fnd_msg_pub.Add;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Removing the rejected salkes team by calling pv_assignment_pvt.removeRejectedFromAccess  ');
      fnd_msg_pub.Add;
   END IF;


   pv_assignment_pvt.removeRejectedFromAccess (
      p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_commit              => FND_API.G_FALSE,
      p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
      p_itemtype            => l_itemType,
      p_itemkey             => l_itemKey,
      p_partner_id          => l_partner_id,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data);

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   open lc_all_abandon_chk (pc_itemtype  => l_itemtype,
                            pc_itemkey   => l_itemkey);

   fetch lc_all_abandon_chk into l_temp;
   close lc_all_abandon_chk;

   if l_temp is null then

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'All partners have abandoned.  Update pv_lead_workflow routing to ABANDONED');
         fnd_msg_pub.Add;
      END IF;
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Updating the routing stage by calling pv_assignment_pvt.update_routing_stage  ');
      fnd_msg_pub.Add;
   END IF;

      pv_assignment_pvt.update_routing_stage (
         p_api_version_number   => 1.0,
         p_init_msg_list        => FND_API.G_FALSE,
         p_commit               => FND_API.G_FALSE,
         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
         p_itemType             => l_itemtype,
         p_itemKey              => l_itemKey,
         p_routing_stage        => pv_assignment_pub.g_r_status_abandoned,
         p_active_but_open_flag => 'N',
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         raise FND_API.G_EXC_ERROR;
      end if;


      OPEN   lc_get_pt_org_name(l_partner_id);
      FETCH  lc_get_pt_org_name into l_partner_org;
      CLOSE  lc_get_pt_org_name;

      OPEN   lc_get_lead_rec(p_lead_id);
      FETCH  lc_get_lead_rec
      INTO   l_assignment_type, l_lead_number,
             l_opp_name, l_opp_amt, l_customer_name;
      CLOSE  lc_get_lead_rec;

      OPEN   lc_get_assign_type_meaning(l_assignment_type);
      FETCH  lc_get_assign_type_meaning INTO l_assign_type_mean;
      CLOSE  lc_get_assign_type_meaning;


      IF p_reason_code IS NOT NULL
      THEN
        SELECT meaning
        INTO   l_action_reason
        FROM   pv_lookups
       WHERE  lookup_type = 'PV_REASON_CODES'
       AND    lookup_code = p_reason_code;
      END IF;

      OPEN lc_get_vendor_cat(p_lead_id);
      FETCH lc_get_vendor_cat
      INTO  l_category, l_source_id, l_ven_user_id;
      CLOSE   lc_get_vendor_cat;

      IF  l_category = 'EMPLOYEE' THEN
          OPEN lc_get_ven_emp_name(l_source_id);
          FETCH lc_get_ven_emp_name
          INTO  l_vendor_name;
          CLOSE lc_get_ven_emp_name;
      ELSIF l_category = 'PARTY' THEN
          OPEN lc_get_ven_pty_name(l_source_id);
          FETCH lc_get_ven_pty_name
          INTO  l_vendor_name;
          CLOSE lc_get_ven_pty_name;
      END IF;


      l_attrib_values_rec.am_org_name          := l_vendor_name;
      l_attrib_values_rec.pt_org_party_id      := l_partner_id;
      l_attrib_values_rec.lead_id              := p_lead_id;
      l_attrib_values_rec.lead_number          := l_lead_number;
      l_attrib_values_rec.entity_name          := l_opp_name;
      l_attrib_values_rec.entity_amount        := l_opp_amt;
      l_attrib_values_rec.customer_name        := l_customer_name;
      l_attrib_values_rec.assignment_type      := l_assignment_type;
      l_attrib_values_rec.assignment_type_mean := l_assign_type_mean;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'Abandoning the workflow by calling pv_assignment_pvt.AbandonWorkflow  ');
      fnd_msg_pub.Add;
   END IF;



      pv_assignment_pvt.AbandonWorkflow (
         p_api_version_number   => 1.0,
         p_init_msg_list        => FND_API.G_FALSE,
         p_commit               => FND_API.G_FALSE,
         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
         p_creating_username    => p_user_name,
         p_attrib_values_rec    => l_attrib_values_rec,
         p_action_reason        => l_action_reason,
         p_partner_org_name     => l_partner_org,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data);


   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

   FND_MSG_PUB.g_msg_level_threshold := FND_API.G_MISS_NUM;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end ABANDON_ASSIGNMENT;


end PV_ASSIGNMENT_PUB;

/
