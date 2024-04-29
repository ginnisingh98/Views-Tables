--------------------------------------------------------
--  DDL for Package Body IEM_SERVICEREQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SERVICEREQUEST_PVT" AS
/* $Header: iemvsrvb.pls 120.3.12010000.3 2009/08/10 09:16:45 sanjrao ship $ */
--
--
-- Purpose: Wrapper API for ServiceRequest
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  3/24/2002    Created
--  Liang Xia  1/30/2003    Rewrite wrappers to compliance with CS changes in 115.9
--  				        Branching on iemvsrvb.pls 115.3, iemvsrvs.pls 115.2
--                          Working CS file version:
--                          cspsrs.pls 115.46
--                          cspsrb.pls 115.55
--                          csvsrs.pls 115.65
--                          csvsrb.pls 115.193
--  Liang Xia  8/25/2003    Create Update_Status_Wrap based on 1159 release
--                          cspsrs.pls 115.49
--                          cspsrb.pls 115.63
--                          csvsrs.pls 115.67
--                          csvsrb.pls 115.222
--  Liang Xia  10/17/2003   Pass cust_pref_lang_code, last_update_channel to
--                          updated SR api, default last_update_channel as "EMAIL"
--                          for 115.10 compliance

--  Liang Xia  08/16/2004  Added fnd_global.apps_initialize for Update_Status on 115.10
--				       to accomendate new feature of resp-type mapping feature
--					  bug 3788494 ( iemvsrvs.pls 115.3 )
--  PKESANI    02/09/2006  As a part of ACSR project, added procedure IEM_CREATE_SR
--                         as a wrapper API for auto create SR.
--  Sanjana Rao 10-aug-2009  Made changes on the procedure IEM_CREATE_SR, bug 8677528
-- ---------   ------  -----------------------------------------

-- Enter procedure, function bodies as shown below

/*GLOBAL VARIABLES AVAILABLE TO THE PUBLIC FOR CALLING
  ===================================================*/

PROCEDURE Create_ServiceRequest_Wrap
( p_api_version			  IN      NUMBER,
  p_init_msg_list		  IN      VARCHAR2 	:= null,
  p_commit			       IN      VARCHAR2 	:= null,
  x_return_status		  OUT  NOCOPY   VARCHAR2,
  x_msg_count			  OUT  NOCOPY   NUMBER,
  x_msg_data			  OUT  NOCOPY   VARCHAR2,
  p_resp_appl_id		  IN      NUMBER		:= NULL,
  p_resp_id			      IN      NUMBER		:= NULL,
  p_user_id			      IN      NUMBER		:= NULL,
  p_login_id			  IN      NUMBER		:= NULL,
  p_org_id			      IN      NUMBER		:= NULL,
  p_request_id            IN      NUMBER                := NULL,
  p_request_number		  IN      VARCHAR2		:= NULL,
  p_service_request_rec           IN      service_request_rec_type,
  p_notes                         IN      notes_table,
  p_contacts                      IN      contacts_table,
  x_request_id			  OUT  NOCOPY   NUMBER,
  x_request_number		  OUT  NOCOPY   VARCHAR2,
  x_interaction_id        OUT   NOCOPY  NUMBER,
  x_workflow_process_id   OUT   NOCOPY  NUMBER
)

IS
 -- l_api_version	       CONSTANT	NUMBER		:= 2.0;
 -- l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Create_ServiceRequest';
 -- l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;

  l_api_name            VARCHAR2(255):='Create_ServiceRequest_Wrap';
  l_api_version_number  NUMBER:=2.0;
  --Added by LiangXia on Dec18,2002 for CS changes in 115.9
  l_cs_version_number   NUMBER:=3.0;


  l_userid    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
  l_login    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(2000);
  l_index                NUMBER := 1;

  l_service_request_rec  CS_ServiceRequest_PUB.service_request_rec_type;
  l_notes                CS_ServiceRequest_PUB.notes_table;
  l_contacts             CS_ServiceRequest_PUB.contacts_table;

  --Added by LiangXia on Dec18,2002 for CS changes in 115.9
  l_individual_owner    NUMBER;
  l_group_owner         NUMBER;
  l_individual_type     VARCHAR2(200);

  IEM_SERVICEREQUEST_NOT_CREATE EXCEPTION;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  Create_ServiceRequest_Wrap;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

    CS_ServiceRequest_PUB.initialize_rec(l_service_request_rec);

 -- IF p_service_request_rec is not null then
    l_service_request_rec.request_date := p_service_request_rec.request_date;
    l_service_request_rec.type_id      := p_service_request_rec.type_id;
    l_service_request_rec.type_name   := p_service_request_rec.type_name;
     l_service_request_rec.status_id   := p_service_request_rec.status_id;
	l_service_request_rec.status_name  :=   p_service_request_rec.status_name;
     l_service_request_rec.severity_id :=    p_service_request_rec.severity_id;
	l_service_request_rec.severity_name :=   p_service_request_rec.severity_name;
     l_service_request_rec.urgency_id   :=   p_service_request_rec.urgency_id;
	l_service_request_rec.urgency_name  :=   p_service_request_rec.urgency_name;
     l_service_request_rec.closed_date  := p_service_request_rec.closed_date;
     l_service_request_rec.owner_id     := p_service_request_rec.owner_id;
     l_service_request_rec.owner_group_id :=  p_service_request_rec.owner_group_id;
     l_service_request_rec.publish_flag  := p_service_request_rec.publish_flag;
     l_service_request_rec.summary     := p_service_request_rec.summary;
     l_service_request_rec.caller_type := p_service_request_rec.caller_type;
     l_service_request_rec.customer_id := p_service_request_rec.customer_id;
     l_service_request_rec.customer_number := p_service_request_rec.customer_number;
     l_service_request_rec.employee_id     := p_service_request_rec.employee_id;
	l_service_request_rec.employee_number  := p_service_request_rec.employee_number;
     l_service_request_rec.verify_cp_flag  := p_service_request_rec.verify_cp_flag;
     l_service_request_rec.customer_product_id := p_service_request_rec.customer_product_id;
     l_service_request_rec.platform_id    := p_service_request_rec.platform_id;
     l_service_request_rec.platform_version	:= p_service_request_rec.platform_version;
     l_service_request_rec.db_version := p_service_request_rec.db_version;
     l_service_request_rec.platform_version_id :=  p_service_request_rec.platform_version_id;
     l_service_request_rec.cp_component_id := p_service_request_rec.cp_component_id;
     l_service_request_rec.cp_component_version_id := p_service_request_rec.cp_component_version_id;
     l_service_request_rec.cp_subcomponent_id := p_service_request_rec.cp_subcomponent_id;
     l_service_request_rec.cp_subcomponent_version_id := p_service_request_rec.cp_subcomponent_version_id;
     l_service_request_rec.language_id := p_service_request_rec.language_id;
     l_service_request_rec.language   :=  p_service_request_rec.language;
     l_service_request_rec.cp_ref_number  := p_service_request_rec.cp_ref_number;
     l_service_request_rec.inventory_item_id   := p_service_request_rec.inventory_item_id ;
     l_service_request_rec.inventory_item_conc_segs :=  p_service_request_rec.inventory_item_conc_segs;
     l_service_request_rec.inventory_item_segment1  :=  p_service_request_rec.inventory_item_segment1;
     l_service_request_rec.inventory_item_segment2  :=  p_service_request_rec.inventory_item_segment2;
     l_service_request_rec.inventory_item_segment3  :=  p_service_request_rec.inventory_item_segment3;
     l_service_request_rec.inventory_item_segment4  :=  p_service_request_rec.inventory_item_segment4;
     l_service_request_rec.inventory_item_segment5  :=  p_service_request_rec.inventory_item_segment5;
     l_service_request_rec.inventory_item_segment6  :=  p_service_request_rec.inventory_item_segment6;
     l_service_request_rec.inventory_item_segment7  :=  p_service_request_rec.inventory_item_segment7;
     l_service_request_rec.inventory_item_segment8  :=  p_service_request_rec.inventory_item_segment8;
     l_service_request_rec.inventory_item_segment9  :=  p_service_request_rec.inventory_item_segment9;
     l_service_request_rec.inventory_item_segment10 :=  p_service_request_rec.inventory_item_segment10;
     l_service_request_rec.inventory_item_segment11 :=  p_service_request_rec.inventory_item_segment11;
     l_service_request_rec.inventory_item_segment12 := p_service_request_rec.inventory_item_segment12;
     l_service_request_rec.inventory_item_segment13 :=  p_service_request_rec.inventory_item_segment13;
     l_service_request_rec.inventory_item_segment14 :=  p_service_request_rec.inventory_item_segment14;
     l_service_request_rec.inventory_item_segment15 :=  p_service_request_rec.inventory_item_segment15;
     l_service_request_rec.inventory_item_segment16 :=  p_service_request_rec.inventory_item_segment16;
     l_service_request_rec.inventory_item_segment17 :=  p_service_request_rec.inventory_item_segment17;
     l_service_request_rec.inventory_item_segment18 :=  p_service_request_rec.inventory_item_segment18;
     l_service_request_rec.inventory_item_segment19 :=  p_service_request_rec.inventory_item_segment19;
     l_service_request_rec.inventory_item_segment20 :=  p_service_request_rec.inventory_item_segment20;
	l_service_request_rec.inventory_item_vals_or_ids := p_service_request_rec.inventory_item_vals_or_ids;
     l_service_request_rec.inventory_org_id          := p_service_request_rec.inventory_org_id;
     l_service_request_rec.current_serial_number     := p_service_request_rec.current_serial_number;
     l_service_request_rec.original_order_number     := p_service_request_rec.original_order_number;
     l_service_request_rec.purchase_order_num        := p_service_request_rec.purchase_order_num;
     l_service_request_rec.problem_code              := p_service_request_rec.problem_code;
     l_service_request_rec.exp_resolution_date       := p_service_request_rec.exp_resolution_date;
     l_service_request_rec.install_site_use_id       := p_service_request_rec.install_site_use_id;
     l_service_request_rec.request_attribute_1       := p_service_request_rec.request_attribute_1;
     l_service_request_rec.request_attribute_2       := p_service_request_rec.request_attribute_2;
     l_service_request_rec.request_attribute_3       := p_service_request_rec.request_attribute_3;
     l_service_request_rec.request_attribute_4       := p_service_request_rec.request_attribute_4;
     l_service_request_rec.request_attribute_5       := p_service_request_rec.request_attribute_5;
     l_service_request_rec.request_attribute_6       := p_service_request_rec.request_attribute_6;
     l_service_request_rec.request_attribute_7       := p_service_request_rec.request_attribute_7;
     l_service_request_rec.request_attribute_8       := p_service_request_rec.request_attribute_8;
     l_service_request_rec.request_attribute_9       := p_service_request_rec.request_attribute_9;
     l_service_request_rec.request_attribute_10      := p_service_request_rec.request_attribute_10;
     l_service_request_rec.request_attribute_11      := p_service_request_rec.request_attribute_11;
     l_service_request_rec.request_attribute_12      := p_service_request_rec.request_attribute_12;
     l_service_request_rec.request_attribute_13      := p_service_request_rec.request_attribute_13;
     l_service_request_rec.request_attribute_14      := p_service_request_rec.request_attribute_14;
     l_service_request_rec.request_attribute_15      := p_service_request_rec.request_attribute_15;
     l_service_request_rec.request_context           := p_service_request_rec.request_context ;
     l_service_request_rec.bill_to_site_use_id       := p_service_request_rec.bill_to_site_use_id;
     l_service_request_rec.bill_to_contact_id        := p_service_request_rec.bill_to_contact_id;
     l_service_request_rec.ship_to_site_use_id       := p_service_request_rec.ship_to_site_use_id;
     l_service_request_rec.ship_to_contact_id        := p_service_request_rec.ship_to_contact_id ;
     l_service_request_rec.resolution_code           := p_service_request_rec.resolution_code;
     l_service_request_rec.act_resolution_date       := p_service_request_rec.act_resolution_date;
     l_service_request_rec.public_comment_flag       := p_service_request_rec.public_comment_flag ;
     l_service_request_rec.parent_interaction_id     := p_service_request_rec.parent_interaction_id;
     l_service_request_rec.contract_service_id       := p_service_request_rec.contract_service_id;
     l_service_request_rec.contract_service_number   := p_service_request_rec.contract_service_number;
     l_service_request_rec.contract_id               := p_service_request_rec.contract_id;
     l_service_request_rec.project_number            := p_service_request_rec.project_number;
     l_service_request_rec.qa_collection_plan_id     := p_service_request_rec.qa_collection_plan_id;
     l_service_request_rec.account_id                := p_service_request_rec.account_id;
     l_service_request_rec.resource_type             := p_service_request_rec.resource_type;
     l_service_request_rec.resource_subtype_id       := p_service_request_rec.resource_subtype_id;
     l_service_request_rec.cust_po_number            := p_service_request_rec.cust_po_number;
     l_service_request_rec.cust_ticket_number        := p_service_request_rec.cust_ticket_number;
     l_service_request_rec.sr_creation_channel       := p_service_request_rec.sr_creation_channel;
     l_service_request_rec.obligation_date           := p_service_request_rec.obligation_date ;
     l_service_request_rec.time_zone_id              := p_service_request_rec.time_zone_id ;
     l_service_request_rec.time_difference           := p_service_request_rec.time_difference ;
     l_service_request_rec.site_id                   := p_service_request_rec.site_id;
     l_service_request_rec.customer_site_id          := p_service_request_rec.customer_site_id;
     l_service_request_rec.territory_id              := p_service_request_rec.territory_id;
     l_service_request_rec.initialize_flag           := p_service_request_rec.initialize_flag;
     l_service_request_rec.cp_revision_id            := p_service_request_rec.cp_revision_id;
     l_service_request_rec.inv_item_revision         := p_service_request_rec.inv_item_revision;
     l_service_request_rec.inv_component_id          := p_service_request_rec.inv_component_id;
     l_service_request_rec.inv_component_version     := p_service_request_rec.inv_component_version;
     l_service_request_rec.inv_subcomponent_id       := p_service_request_rec.inv_subcomponent_id;
     l_service_request_rec.inv_subcomponent_version  := p_service_request_rec.inv_subcomponent_version;
------jngeorge---------------07/12/01
     l_service_request_rec.tier                       := p_service_request_rec.tier;
     l_service_request_rec.tier_version               := p_service_request_rec.tier_version;
     l_service_request_rec.operating_system           := p_service_request_rec.operating_system;
     l_service_request_rec.operating_system_version   := p_service_request_rec.operating_system_version;
     l_service_request_rec.database                   := p_service_request_rec.database;
     l_service_request_rec.cust_pref_lang_id          := p_service_request_rec.cust_pref_lang_id;
     l_service_request_rec.category_id                := p_service_request_rec.category_id;
     l_service_request_rec.group_type                 := p_service_request_rec.group_type;
     l_service_request_rec.group_territory_id         := p_service_request_rec.group_territory_id;
     l_service_request_rec.inv_platform_org_id        := p_service_request_rec.inv_platform_org_id;
     l_service_request_rec.component_version          := p_service_request_rec.component_version;
     l_service_request_rec.subcomponent_version       := p_service_request_rec.subcomponent_version;
     l_service_request_rec.product_revision           := p_service_request_rec.product_revision;
     l_service_request_rec.comm_pref_code             := p_service_request_rec.comm_pref_code;
     ---- Added for Post 11.5.6 Enhancement
	-- added by Liang in 115.10 for client for update last_update_channel
     l_service_request_rec.cust_pref_lang_code        := P_service_request_rec.cust_pref_lang_code;
     l_service_request_rec.last_update_channel        := p_service_request_rec.last_update_channel;

     --Added by LiangXia on Dec 19,2002 to for CS changes in 115.9
     l_service_request_rec.creation_program_code      := 'EMAILCENTER';
--  end if;

  l_notes.delete;
  IF p_notes.count>0 THEN
    FOR i in p_notes.FIRST..p_notes.LAST LOOP
        l_notes(l_index).NOTE                       := p_notes(i).NOTE;
        l_notes(l_index).NOTE_DETAIL                := p_notes(i).NOTE_DETAIL;
        l_notes(l_index).NOTE_TYPE                  := p_notes(i).NOTE_TYPE;
        l_notes(l_index).NOTE_CONTEXT_TYPE_01       := p_notes(i).NOTE_CONTEXT_TYPE_01;
        l_notes(l_index).NOTE_CONTEXT_TYPE_ID_01    := p_notes(i).NOTE_CONTEXT_TYPE_ID_01;
        l_notes(l_index).NOTE_CONTEXT_TYPE_02       := p_notes(i).NOTE_CONTEXT_TYPE_02;
        l_notes(l_index).NOTE_CONTEXT_TYPE_ID_02    := p_notes(i).NOTE_CONTEXT_TYPE_ID_02;
        l_notes(l_index).NOTE_CONTEXT_TYPE_03       := p_notes(i).NOTE_CONTEXT_TYPE_03;
        l_notes(l_index).NOTE_CONTEXT_TYPE_ID_03    := p_notes(i).NOTE_CONTEXT_TYPE_ID_03;
	    l_index:=l_index+1;
    END LOOP;
 END IF;

  l_contacts.delete;
  l_index := 1;
  IF p_contacts.count>0 THEN
    FOR x in p_contacts.FIRST..p_contacts.LAST LOOP
        l_contacts(l_index).SR_CONTACT_POINT_ID        :=   p_contacts(x).SR_CONTACT_POINT_ID;
        l_contacts(l_index).PARTY_ID                   :=   p_contacts(x).PARTY_ID;
        l_contacts(l_index).CONTACT_POINT_ID           :=   p_contacts(x).CONTACT_POINT_ID;
        l_contacts(l_index).CONTACT_POINT_TYPE         :=   p_contacts(x).CONTACT_POINT_TYPE;
        l_contacts(l_index).PRIMARY_FLAG               :=   p_contacts(x).PRIMARY_FLAG;
        l_contacts(l_index).CONTACT_TYPE               :=   p_contacts(x).CONTACT_TYPE;
	   l_index:=l_index+1;
    END LOOP;
  END IF;



CS_ServiceRequest_PUB.Create_ServiceRequest (
                  p_api_version           => l_cs_version_number,
                  p_init_msg_list         => p_init_msg_list,
      		      p_commit	              => p_commit,
                  x_return_status         =>l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_resp_appl_id		  => p_resp_appl_id,
                  p_resp_id			      => p_resp_id,
                  p_user_id			      => p_user_id,
                  p_login_id			  => p_login_id,
                  p_org_id			      => p_org_id,
                  p_request_id            => p_request_id,
                  p_request_number		  => p_request_number,
                  p_service_request_rec   => l_service_request_rec,
                  p_notes                 => l_notes,
                  p_contacts              => l_contacts,
                  x_request_id			  => x_request_id,
                  x_request_number		  => x_request_number,
                  x_interaction_id        => x_interaction_id,
                  x_workflow_process_id   => x_workflow_process_id,

                  --Added by liangxia on Dec18, 2002 for CS changes in 115.9
                  x_individual_owner => l_individual_owner,
                  x_group_owner => l_group_owner,
                  x_individual_type => l_individual_type
                  );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_SERVICEREQUEST_NOT_CREATE;
   end if;

   x_return_status := l_return_status ;

   --Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

EXCEPTION
    WHEN IEM_SERVICEREQUEST_NOT_CREATE THEN
        ROLLBACK TO Create_ServiceRequest_Wrap;
        x_return_status := l_return_status ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO Create_ServiceRequest_Wrap;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO Create_ServiceRequest_Wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

    WHEN OTHERS THEN
            ROLLBACK TO Create_ServiceRequest_Wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    END;

PROCEDURE Update_ServiceRequest_Wrap(
  p_api_version            IN     NUMBER,
  p_init_msg_list          IN     VARCHAR2      := null,
  p_commit                 IN     VARCHAR2      := null,
  x_return_status          OUT    NOCOPY VARCHAR2,
  x_msg_count              OUT    NOCOPY NUMBER,
  x_msg_data               OUT    NOCOPY VARCHAR2,
  p_request_id             IN     NUMBER        := NULL,
  p_request_number         IN     VARCHAR2      := NULL,
  p_audit_comments         IN     VARCHAR2      := NULL,
  p_object_version_number  IN     NUMBER,
  p_resp_appl_id           IN     NUMBER        := NULL,
  p_resp_id                IN     NUMBER        := NULL,
  p_last_updated_by        IN     NUMBER,
  p_last_update_login      IN     NUMBER        := NULL,
  p_last_update_date       IN     DATE,
  p_service_request_rec    IN     service_request_rec_type,
  p_notes                  IN     notes_table,
  p_contacts               IN     contacts_table,
  p_called_by_workflow     IN     VARCHAR2      := FND_API.G_FALSE,
  p_workflow_process_id    IN     NUMBER        := NULL,
  x_workflow_process_id    OUT    NOCOPY NUMBER,
  x_interaction_id         OUT    NOCOPY NUMBER
)
IS
 -- l_api_version	       CONSTANT	NUMBER		:= 2.0;
 -- l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Update_ServiceRequest_Wrap';
 -- l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;

  l_api_name            VARCHAR2(255):='Update_ServiceRequest_Wrap';
  l_api_version_number  NUMBER:= 2.0;

  --Added by LiangXia on Dec18,2002 for CS changes in 115.9
  l_cs_version_number   NUMBER:=3.0;

  l_userid    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
  l_login    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(2000);
  l_index                NUMBER := 1;

  l_service_request_rec  CS_ServiceRequest_PUB.service_request_rec_type;
  l_notes                CS_ServiceRequest_PUB.notes_table;
  l_contacts             CS_ServiceRequest_PUB.contacts_table;

  IEM_SERVICEREQUEST_NOT_UPDATED EXCEPTION;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  Update_ServiceRequest_Wrap;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

    CS_ServiceRequest_PUB.initialize_rec(l_service_request_rec);

 -- IF p_service_request_rec is not null then
    l_service_request_rec.request_date := p_service_request_rec.request_date;
    l_service_request_rec.type_id      := p_service_request_rec.type_id;
    l_service_request_rec.type_name   := p_service_request_rec.type_name;
     l_service_request_rec.status_id   := p_service_request_rec.status_id;
	l_service_request_rec.status_name  :=   p_service_request_rec.status_name;
     l_service_request_rec.severity_id :=    p_service_request_rec.severity_id;
	l_service_request_rec.severity_name :=   p_service_request_rec.severity_name;
     l_service_request_rec.urgency_id   :=   p_service_request_rec.urgency_id;
	l_service_request_rec.urgency_name  :=   p_service_request_rec.urgency_name;
     l_service_request_rec.closed_date  := p_service_request_rec.closed_date;
     l_service_request_rec.owner_id     := p_service_request_rec.owner_id;
     l_service_request_rec.owner_group_id :=  p_service_request_rec.owner_group_id;
     l_service_request_rec.publish_flag  := p_service_request_rec.publish_flag;
     l_service_request_rec.summary     := p_service_request_rec.summary;
     l_service_request_rec.caller_type := p_service_request_rec.caller_type;
     l_service_request_rec.customer_id := p_service_request_rec.customer_id;
     l_service_request_rec.customer_number := p_service_request_rec.customer_number;
     l_service_request_rec.employee_id     := p_service_request_rec.employee_id;
	l_service_request_rec.employee_number  := p_service_request_rec.employee_number;
     l_service_request_rec.verify_cp_flag  := p_service_request_rec.verify_cp_flag;
     l_service_request_rec.customer_product_id := p_service_request_rec.customer_product_id;
     l_service_request_rec.platform_id    := p_service_request_rec.platform_id;
     l_service_request_rec.platform_version	:= p_service_request_rec.platform_version;
     l_service_request_rec.db_version := p_service_request_rec.db_version;
     l_service_request_rec.platform_version_id :=  p_service_request_rec.platform_version_id;
     l_service_request_rec.cp_component_id := p_service_request_rec.cp_component_id;
     l_service_request_rec.cp_component_version_id := p_service_request_rec.cp_component_version_id;
     l_service_request_rec.cp_subcomponent_id := p_service_request_rec.cp_subcomponent_id;
     l_service_request_rec.cp_subcomponent_version_id := p_service_request_rec.cp_subcomponent_version_id;
     l_service_request_rec.language_id := p_service_request_rec.language_id;
     l_service_request_rec.language   :=  p_service_request_rec.language;
     l_service_request_rec.cp_ref_number  := p_service_request_rec.cp_ref_number;
     l_service_request_rec.inventory_item_id   := p_service_request_rec.inventory_item_id ;
     l_service_request_rec.inventory_item_conc_segs :=  p_service_request_rec.inventory_item_conc_segs;
     l_service_request_rec.inventory_item_segment1  :=  p_service_request_rec.inventory_item_segment1;
     l_service_request_rec.inventory_item_segment2  :=  p_service_request_rec.inventory_item_segment2;
     l_service_request_rec.inventory_item_segment3  :=  p_service_request_rec.inventory_item_segment3;
     l_service_request_rec.inventory_item_segment4  :=  p_service_request_rec.inventory_item_segment4;
     l_service_request_rec.inventory_item_segment5  :=  p_service_request_rec.inventory_item_segment5;
     l_service_request_rec.inventory_item_segment6  :=  p_service_request_rec.inventory_item_segment6;
     l_service_request_rec.inventory_item_segment7  :=  p_service_request_rec.inventory_item_segment7;
     l_service_request_rec.inventory_item_segment8  :=  p_service_request_rec.inventory_item_segment8;
     l_service_request_rec.inventory_item_segment9  :=  p_service_request_rec.inventory_item_segment9;
     l_service_request_rec.inventory_item_segment10 :=  p_service_request_rec.inventory_item_segment10;
     l_service_request_rec.inventory_item_segment11 :=  p_service_request_rec.inventory_item_segment11;
     l_service_request_rec.inventory_item_segment12 := p_service_request_rec.inventory_item_segment12;
     l_service_request_rec.inventory_item_segment13 :=  p_service_request_rec.inventory_item_segment13;
     l_service_request_rec.inventory_item_segment14 :=  p_service_request_rec.inventory_item_segment14;
     l_service_request_rec.inventory_item_segment15 :=  p_service_request_rec.inventory_item_segment15;
     l_service_request_rec.inventory_item_segment16 :=  p_service_request_rec.inventory_item_segment16;
     l_service_request_rec.inventory_item_segment17 :=  p_service_request_rec.inventory_item_segment17;
     l_service_request_rec.inventory_item_segment18 :=  p_service_request_rec.inventory_item_segment18;
     l_service_request_rec.inventory_item_segment19 :=  p_service_request_rec.inventory_item_segment19;
     l_service_request_rec.inventory_item_segment20 :=  p_service_request_rec.inventory_item_segment20;
	l_service_request_rec.inventory_item_vals_or_ids := p_service_request_rec.inventory_item_vals_or_ids;
     l_service_request_rec.inventory_org_id          := p_service_request_rec.inventory_org_id;
     l_service_request_rec.current_serial_number     := p_service_request_rec.current_serial_number;
     l_service_request_rec.original_order_number     := p_service_request_rec.original_order_number;
     l_service_request_rec.purchase_order_num        := p_service_request_rec.purchase_order_num;
     l_service_request_rec.problem_code              := p_service_request_rec.problem_code;
     l_service_request_rec.exp_resolution_date       := p_service_request_rec.exp_resolution_date;
     l_service_request_rec.install_site_use_id       := p_service_request_rec.install_site_use_id;
     l_service_request_rec.request_attribute_1       := p_service_request_rec.request_attribute_1;
     l_service_request_rec.request_attribute_2       := p_service_request_rec.request_attribute_2;
     l_service_request_rec.request_attribute_3       := p_service_request_rec.request_attribute_3;
     l_service_request_rec.request_attribute_4       := p_service_request_rec.request_attribute_4;
     l_service_request_rec.request_attribute_5       := p_service_request_rec.request_attribute_5;
     l_service_request_rec.request_attribute_6       := p_service_request_rec.request_attribute_6;
     l_service_request_rec.request_attribute_7       := p_service_request_rec.request_attribute_7;
     l_service_request_rec.request_attribute_8       := p_service_request_rec.request_attribute_8;
     l_service_request_rec.request_attribute_9       := p_service_request_rec.request_attribute_9;
     l_service_request_rec.request_attribute_10      := p_service_request_rec.request_attribute_10;
     l_service_request_rec.request_attribute_11      := p_service_request_rec.request_attribute_11;
     l_service_request_rec.request_attribute_12      := p_service_request_rec.request_attribute_12;
     l_service_request_rec.request_attribute_13      := p_service_request_rec.request_attribute_13;
     l_service_request_rec.request_attribute_14      := p_service_request_rec.request_attribute_14;
     l_service_request_rec.request_attribute_15      := p_service_request_rec.request_attribute_15;
     l_service_request_rec.request_context           := p_service_request_rec.request_context ;
     l_service_request_rec.bill_to_site_use_id       := p_service_request_rec.bill_to_site_use_id;
     l_service_request_rec.bill_to_contact_id        := p_service_request_rec.bill_to_contact_id;
     l_service_request_rec.ship_to_site_use_id       := p_service_request_rec.ship_to_site_use_id;
     l_service_request_rec.ship_to_contact_id        := p_service_request_rec.ship_to_contact_id ;
     l_service_request_rec.resolution_code           := p_service_request_rec.resolution_code;
     l_service_request_rec.act_resolution_date       := p_service_request_rec.act_resolution_date;
     l_service_request_rec.public_comment_flag       := p_service_request_rec.public_comment_flag ;
     l_service_request_rec.parent_interaction_id     := p_service_request_rec.parent_interaction_id;
     l_service_request_rec.contract_service_id       := p_service_request_rec.contract_service_id;
     l_service_request_rec.contract_service_number   := p_service_request_rec.contract_service_number;
     l_service_request_rec.contract_id               := p_service_request_rec.contract_id;
     l_service_request_rec.project_number            := p_service_request_rec.project_number;
     l_service_request_rec.qa_collection_plan_id     := p_service_request_rec.qa_collection_plan_id;
     l_service_request_rec.account_id                := p_service_request_rec.account_id;
     l_service_request_rec.resource_type             := p_service_request_rec.resource_type;
     l_service_request_rec.resource_subtype_id       := p_service_request_rec.resource_subtype_id;
     l_service_request_rec.cust_po_number            := p_service_request_rec.cust_po_number;
     l_service_request_rec.cust_ticket_number        := p_service_request_rec.cust_ticket_number;
     l_service_request_rec.sr_creation_channel       := p_service_request_rec.sr_creation_channel;
     l_service_request_rec.obligation_date           := p_service_request_rec.obligation_date ;
     l_service_request_rec.time_zone_id              := p_service_request_rec.time_zone_id ;
     l_service_request_rec.time_difference           := p_service_request_rec.time_difference ;
     l_service_request_rec.site_id                   := p_service_request_rec.site_id;
     l_service_request_rec.customer_site_id          := p_service_request_rec.customer_site_id;
     l_service_request_rec.territory_id              := p_service_request_rec.territory_id;
     l_service_request_rec.initialize_flag           := p_service_request_rec.initialize_flag;
     l_service_request_rec.cp_revision_id            := p_service_request_rec.cp_revision_id;
     l_service_request_rec.inv_item_revision         := p_service_request_rec.inv_item_revision;
     l_service_request_rec.inv_component_id          := p_service_request_rec.inv_component_id;
     l_service_request_rec.inv_component_version     := p_service_request_rec.inv_component_version;
     l_service_request_rec.inv_subcomponent_id       := p_service_request_rec.inv_subcomponent_id;
     l_service_request_rec.inv_subcomponent_version  := p_service_request_rec.inv_subcomponent_version;
------jngeorge---------------07/12/01
     l_service_request_rec.tier                       := p_service_request_rec.tier;
     l_service_request_rec.tier_version               := p_service_request_rec.tier_version;
     l_service_request_rec.operating_system           := p_service_request_rec.operating_system;
     l_service_request_rec.operating_system_version   := p_service_request_rec.operating_system_version;
     l_service_request_rec.database                   := p_service_request_rec.database;
     l_service_request_rec.cust_pref_lang_id          := p_service_request_rec.cust_pref_lang_id;
     l_service_request_rec.category_id                := p_service_request_rec.category_id;
     l_service_request_rec.group_type                 := p_service_request_rec.group_type;
     l_service_request_rec.group_territory_id         := p_service_request_rec.group_territory_id;
     l_service_request_rec.inv_platform_org_id        := p_service_request_rec.inv_platform_org_id;
     l_service_request_rec.component_version          := p_service_request_rec.component_version;
     l_service_request_rec.subcomponent_version       := p_service_request_rec.subcomponent_version;
     l_service_request_rec.product_revision           := p_service_request_rec.product_revision;
     l_service_request_rec.comm_pref_code             := p_service_request_rec.comm_pref_code;
     ---- Added for Post 11.5.6 Enhancement
     ---- Changed by Liang for 115.10 for Client to update Last_update_channel
     l_service_request_rec.cust_pref_lang_code        := P_service_request_rec.cust_pref_lang_code;
     l_service_request_rec.last_update_channel        := p_service_request_rec.last_update_channel;

     --Added by LiangXia on Dec 19,2002 to for CS changes in 115.9
     l_service_request_rec.last_update_program_code     := 'EMAILCENTER';
--  end if;


  l_notes.delete;
  IF p_notes.count>0 THEN
    FOR i in p_notes.FIRST..p_notes.LAST LOOP
        l_notes(l_index).NOTE                       := p_notes(i).NOTE;
        l_notes(l_index).NOTE_DETAIL                := p_notes(i).NOTE_DETAIL;
        l_notes(l_index).NOTE_TYPE                  := p_notes(i).NOTE_TYPE;
        l_notes(l_index).NOTE_CONTEXT_TYPE_01       := p_notes(i).NOTE_CONTEXT_TYPE_01;
        l_notes(l_index).NOTE_CONTEXT_TYPE_ID_01    := p_notes(i).NOTE_CONTEXT_TYPE_ID_01;
        l_notes(l_index).NOTE_CONTEXT_TYPE_02       := p_notes(i).NOTE_CONTEXT_TYPE_02;
        l_notes(l_index).NOTE_CONTEXT_TYPE_ID_02    := p_notes(i).NOTE_CONTEXT_TYPE_ID_02;
        l_notes(l_index).NOTE_CONTEXT_TYPE_03       := p_notes(i).NOTE_CONTEXT_TYPE_03;
        l_notes(l_index).NOTE_CONTEXT_TYPE_ID_03    := p_notes(i).NOTE_CONTEXT_TYPE_ID_03;
	    l_index:=l_index+1;
    END LOOP;
 END IF;

  l_contacts.delete;
  l_index := 1;
  IF p_contacts.count>0 THEN
    FOR x in p_contacts.FIRST..p_contacts.LAST LOOP
        l_contacts(l_index).SR_CONTACT_POINT_ID        :=   p_contacts(x).SR_CONTACT_POINT_ID;
        l_contacts(l_index).PARTY_ID                   :=    p_contacts(x).PARTY_ID;
        l_contacts(l_index).CONTACT_POINT_ID           :=    p_contacts(x).CONTACT_POINT_ID;
        l_contacts(l_index).CONTACT_POINT_TYPE         :=    p_contacts(x).CONTACT_POINT_TYPE;
        l_contacts(l_index).PRIMARY_FLAG               :=    p_contacts(x).PRIMARY_FLAG;
        l_contacts(l_index).CONTACT_TYPE               :=    p_contacts(x).CONTACT_TYPE;
	   l_index:=l_index+1;
    END LOOP;
  END IF;

CS_ServiceRequest_PUB.Update_ServiceRequest (
                  p_api_version           => l_cs_version_number,
                  p_init_msg_list         => p_init_msg_list,
      		      p_commit	              => p_commit,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_request_id		      => p_request_id,
                  p_request_number	      => p_request_number,
                  p_audit_comments	      => p_audit_comments,
                  p_object_version_number => p_object_version_number,
                  p_resp_appl_id          => p_resp_appl_id,
                  p_resp_id               => p_resp_id,
                  p_last_updated_by       => p_last_updated_by,
                  p_last_update_login     => p_last_update_login,
                  p_last_update_date      => p_last_update_date,
                  p_service_request_rec   => l_service_request_rec,
                  p_notes                 => l_notes,
                  p_contacts              => l_contacts,
                  p_called_by_workflow    => p_called_by_workflow,
                  p_workflow_process_id   => p_workflow_process_id,
                  x_workflow_process_id   => x_workflow_process_id,
                  x_interaction_id        => x_interaction_id );


   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_SERVICEREQUEST_NOT_UPDATED;
   end if;

    x_return_status := l_return_status ;
   --Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

EXCEPTION
    WHEN IEM_SERVICEREQUEST_NOT_UPDATED THEN
        ROLLBACK TO Update_ServiceRequest_Wrap;
        x_return_status := l_return_status ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO Update_ServiceRequest_Wrap;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO Update_ServiceRequest_Wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

    WHEN OTHERS THEN
            ROLLBACK TO Update_ServiceRequest_Wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    END;


PROCEDURE initialize_rec(
  p_sr_record                   IN OUT NOCOPY service_request_rec_type
) AS
BEGIN
  p_sr_record.request_date               := FND_API.G_MISS_DATE;
  p_sr_record.type_id                    := FND_API.G_MISS_NUM;
  p_sr_record.type_name                  := FND_API.G_MISS_CHAR;
  p_sr_record.status_id                  := FND_API.G_MISS_NUM;
  p_sr_record.status_name                := FND_API.G_MISS_CHAR;
  p_sr_record.severity_id                := FND_API.G_MISS_NUM;
  p_sr_record.severity_name              := FND_API.G_MISS_CHAR;
  p_sr_record.urgency_id                 := FND_API.G_MISS_NUM;
  p_sr_record.urgency_name               := FND_API.G_MISS_CHAR;
  p_sr_record.closed_date                := FND_API.G_MISS_DATE;
  p_sr_record.owner_id                   := FND_API.G_MISS_NUM;
  p_sr_record.owner_group_id             := FND_API.G_MISS_NUM;
  p_sr_record.publish_flag               := FND_API.G_MISS_CHAR;
  p_sr_record.summary                    := FND_API.G_MISS_CHAR;
  p_sr_record.caller_type                := FND_API.G_MISS_CHAR;
  p_sr_record.customer_id                := FND_API.G_MISS_NUM;
  p_sr_record.customer_number            := FND_API.G_MISS_CHAR;
  p_sr_record.employee_id                := FND_API.G_MISS_NUM;
  p_sr_record.employee_number            := FND_API.G_MISS_CHAR;
  p_sr_record.verify_cp_flag             := FND_API.G_MISS_CHAR;
  p_sr_record.customer_product_id        := FND_API.G_MISS_NUM;
  p_sr_record.platform_id                := FND_API.G_MISS_NUM;
  p_sr_record.platform_version		 := FND_API.G_MISS_CHAR;
  p_sr_record.db_version		 := FND_API.G_MISS_CHAR;
  p_sr_record.platform_version_id        := FND_API.G_MISS_NUM;
  p_sr_record.cp_component_id               := FND_API.G_MISS_NUM;
  p_sr_record.cp_component_version_id       := FND_API.G_MISS_NUM;
  p_sr_record.cp_subcomponent_id            := FND_API.G_MISS_NUM;
  p_sr_record.cp_subcomponent_version_id    := FND_API.G_MISS_NUM;
  p_sr_record.language_id                := FND_API.G_MISS_NUM;
  p_sr_record.language                   := FND_API.G_MISS_CHAR;
  p_sr_record.cp_ref_number              := FND_API.G_MISS_NUM;
  p_sr_record.inventory_item_id          := FND_API.G_MISS_NUM;
  p_sr_record.inventory_item_conc_segs   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment1    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment2    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment3    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment4    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment5    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment6    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment7    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment8    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment9    := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment10   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment11   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment12   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment13   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment14   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment15   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment16   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment17   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment18   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment19   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_segment20   := FND_API.G_MISS_CHAR;
  p_sr_record.inventory_item_vals_or_ids := 'V';
  p_sr_record.inventory_org_id           := FND_API.G_MISS_NUM;
  p_sr_record.current_serial_number      := FND_API.G_MISS_CHAR;
  p_sr_record.original_order_number      := FND_API.G_MISS_NUM;
  p_sr_record.purchase_order_num         := FND_API.G_MISS_CHAR;
  p_sr_record.problem_code               := FND_API.G_MISS_CHAR;
  p_sr_record.exp_resolution_date        := FND_API.G_MISS_DATE;
  p_sr_record.install_site_use_id        := FND_API.G_MISS_NUM;
  p_sr_record.request_attribute_1        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_2        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_3        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_4        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_5        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_6        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_7        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_8        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_9        := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_10       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_11       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_12       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_13       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_14       := FND_API.G_MISS_CHAR;
  p_sr_record.request_attribute_15       := FND_API.G_MISS_CHAR;
  p_sr_record.request_context            := FND_API.G_MISS_CHAR;
  p_sr_record.bill_to_site_use_id        := FND_API.G_MISS_NUM;
  p_sr_record.bill_to_contact_id         := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_site_use_id        := FND_API.G_MISS_NUM;
  p_sr_record.ship_to_contact_id         := FND_API.G_MISS_NUM;
  p_sr_record.resolution_code            := FND_API.G_MISS_CHAR;
  p_sr_record.act_resolution_date        := FND_API.G_MISS_DATE;
  p_sr_record.public_comment_flag        := FND_API.G_MISS_CHAR;
  p_sr_record.parent_interaction_id      := FND_API.G_MISS_NUM;
  p_sr_record.contract_service_id        := FND_API.G_MISS_NUM;
  p_sr_record.contract_service_number    := FND_API.G_MISS_CHAR;
  p_sr_record.qa_collection_plan_id      := FND_API.G_MISS_NUM;
  --p_sr_record.account_id                 := FND_API.G_MISS_NUM;
  p_sr_record.resource_type              := FND_API.G_MISS_CHAR;
  p_sr_record.resource_subtype_id        := FND_API.G_MISS_NUM;
  p_sr_record.cust_po_number             := FND_API.G_MISS_CHAR;
  p_sr_record.cust_ticket_number         := FND_API.G_MISS_CHAR;
  p_sr_record.sr_creation_channel        := FND_API.G_MISS_CHAR;
  p_sr_record.obligation_date            := FND_API.G_MISS_DATE;
  p_sr_record.time_zone_id               := FND_API.G_MISS_NUM;
  p_sr_record.time_difference            := FND_API.G_MISS_NUM;
  p_sr_record.site_id                    := FND_API.G_MISS_NUM;
  p_sr_record.customer_site_id           := FND_API.G_MISS_NUM;
  p_sr_record.territory_id               := FND_API.G_MISS_NUM;
  p_sr_record.initialize_flag            := G_INITIALIZED;
  p_sr_record.cp_revision_id             := FND_API.G_MISS_NUM;
  p_sr_record.inv_item_revision          := FND_API.G_MISS_CHAR;
  p_sr_record.inv_component_id           := FND_API.G_MISS_NUM;
  p_sr_record.inv_component_version      := FND_API.G_MISS_CHAR;
  p_sr_record.inv_subcomponent_id        := FND_API.G_MISS_NUM;
  p_sr_record.inv_subcomponent_version   := FND_API.G_MISS_CHAR;
-- Fix for Bug# 2155981
  p_sr_record.project_number             := FND_API.G_MISS_CHAR;
-----jngeorge-----enhancements-----11.5.6-----07/12/01
  p_sr_record.tier                       := FND_API.G_MISS_CHAR;
  p_sr_record.tier_version               := FND_API.G_MISS_CHAR;
  p_sr_record.operating_system           := FND_API.G_MISS_CHAR;
  p_sr_record.operating_system_version   := FND_API.G_MISS_CHAR;
  p_sr_record.database                   := FND_API.G_MISS_CHAR;
  p_sr_record.cust_pref_lang_id          := FND_API.G_MISS_NUM;
  p_sr_record.category_id                := FND_API.G_MISS_NUM;
  p_sr_record.group_type                 := FND_API.G_MISS_CHAR;
  p_sr_record.group_territory_id         := FND_API.G_MISS_NUM;
  p_sr_record.inv_platform_org_id        := FND_API.G_MISS_NUM;
  p_sr_record.product_revision           := FND_API.G_MISS_CHAR;
  p_sr_record.component_version          := FND_API.G_MISS_CHAR;
  p_sr_record.subcomponent_version       := FND_API.G_MISS_CHAR;
  p_sr_record.comm_pref_code             := FND_API.G_MISS_CHAR;
--- Added for Post 11.5.6 Enhancements
  p_sr_record.cust_pref_lang_code        := FND_API.G_MISS_CHAR;
  p_sr_record.last_update_channel        := 'EMAIL'; --FND_API.G_MISS_CHAR;
-------jngeorge----07/12/01

END initialize_rec;

PROCEDURE Update_Status_Wrap
( p_api_version		IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
  x_return_status	OUT	NOCOPY VARCHAR2,
  x_msg_count		OUT	NOCOPY NUMBER,
  x_msg_data		OUT	NOCOPY VARCHAR2,
  p_resp_appl_id	IN	NUMBER   := NULL,
  p_resp_id		IN	NUMBER   := NULL,
  p_user_id		IN	NUMBER   := NULL,
  p_login_id		IN	NUMBER   := FND_API.G_MISS_NUM,
  p_request_id		IN	NUMBER   := NULL,
  p_request_number	IN	VARCHAR2 := NULL,
  p_object_version_number IN NUMBER,
  p_status_id		IN	NUMBER   := NULL,
  p_status		IN	VARCHAR2 := NULL,
  p_closed_date		IN	DATE     := FND_API.G_MISS_DATE,
  p_audit_comments	IN	VARCHAR2 := NULL,
  p_called_by_workflow	IN	VARCHAR2 := FND_API.G_FALSE,
  p_workflow_process_id	IN	NUMBER   := NULL,
  p_comments		IN	VARCHAR2 := NULL,
  p_public_comment_flag	IN	VARCHAR2 := FND_API.G_FALSE,
  x_interaction_id	OUT	NOCOPY NUMBER
)
IS

  l_api_name            VARCHAR2(255):='Update_Status_Wrap';
  l_api_version_number  NUMBER:= 2.0;
  l_cs_version_number   NUMBER:= 2.0;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(2000);
  l_index                NUMBER := 1;

  l_resp_appl_id	NUMBER   := NULL;
  l_resp_id			NUMBER   := NULL;
  l_user_id			NUMBER   := NULL;
  l_login_id		NUMBER   := FND_API.G_MISS_NUM;
  l_request_id		NUMBER   := NULL;
  l_request_number	VARCHAR2(256) := null;
  l_object_version_number  NUMBER;
  l_status_id		NUMBER   := NULL;
  l_status		    VARCHAR2(30) := NULL;
  l_closed_date		DATE     := FND_API.G_MISS_DATE;
  l_audit_comments	VARCHAR2(2000) := NULL;
  l_called_by_workflow	VARCHAR2(1):= FND_API.G_FALSE;
  l_workflow_process_id	NUMBER   := NULL;
  l_comments		VARCHAR2(2000) := NULL;
  l_public_comment_flag	VARCHAR2(1):= FND_API.G_FALSE;
  l_interaction_id	NUMBER;

  IEM_UPDATE_SR_STATUS_FAIL EXCEPTION;

begin
  -- Standard Start of API savepoint
  SAVEPOINT  Update_Status_Wrap;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

  l_resp_appl_id := p_resp_appl_id;
  l_resp_id	   := p_resp_id;
  l_user_id			   := p_user_id;
  l_login_id		   := p_login_id;
  l_request_id		   := p_request_id;
  l_request_number	   := p_request_number;
  l_object_version_number   := p_object_version_number;
  l_status_id		   := p_status_id;
  l_status		       := p_status;
  l_closed_date		   := p_closed_date;
  l_audit_comments	   := p_audit_comments;
  l_called_by_workflow	:= p_called_by_workflow;
  l_workflow_process_id	 := p_workflow_process_id;
  l_comments		:= p_comments;
  l_public_comment_flag	:= p_public_comment_flag;

fnd_global.apps_initialize( user_id=>l_user_id,
                            resp_id=>l_resp_id,
                            resp_appl_id=>l_resp_appl_id);

CS_SERVICEREQUEST_PUB.Update_Status
                ( p_api_version           => l_cs_version_number,
                  p_init_msg_list         => p_init_msg_list,
      		      p_commit	              => p_commit,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_resp_appl_id	      => l_resp_appl_id,
                  p_resp_id		          => l_resp_id,
                  p_user_id		          => l_user_id,
                  p_login_id		      => l_login_id,
                  p_request_id		      => l_request_id,
                  p_request_number	      => l_request_number,
                  p_object_version_number => l_object_version_number,
                  p_status_id		      => l_status_id,
                  p_status		          => l_status,
                  p_closed_date		      => l_closed_date,
                  p_audit_comments	      => l_audit_comments,
                  p_called_by_workflow	  => l_called_by_workflow,
                  p_workflow_process_id	  => l_workflow_process_id,
                  p_comments		      => l_comments,
                  p_public_comment_flag	  => l_public_comment_flag,
                  x_interaction_id	      => l_interaction_id
                );

   l_interaction_id :=  x_interaction_id;

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_UPDATE_SR_STATUS_FAIL;
   end if;

   x_return_status := l_return_status ;

   --Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

EXCEPTION
    WHEN IEM_UPDATE_SR_STATUS_FAIL THEN
        ROLLBACK TO Update_Status_Wrap;
        x_return_status := l_return_status ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO Update_Status_Wrap;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO Update_Status_Wrap;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

    WHEN OTHERS THEN
            ROLLBACK TO Update_Status_Wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    END;

-------------------------------------------------------------------------------
-- Procedure   : IEM_CREATE_SR
-- Description : auto create service request
-------------------------------------------------------------------------------

PROCEDURE IEM_CREATE_SR
( p_api_version			  IN   NUMBER,
  p_init_msg_list		  IN   VARCHAR2 	:= FND_API.G_FALSE,
  p_commit		          IN   VARCHAR2 	:= FND_API.G_FALSE,
  p_message_id   		  IN   NUMBER,
  p_note		          IN   VARCHAR2,
  p_party_id                      IN   NUMBER,
  p_sr_type_id                    IN   NUMBER,
  p_subject                       IN   VARCHAR2,
  p_employee_flag                 IN   VARCHAR2,
  p_note_type                     IN   VARCHAR2,
  p_contact_id                    IN   NUMBER             := NULL,
  p_contact_point_id              IN   NUMBER             := NULL,
  x_return_status		  OUT  NOCOPY   VARCHAR2,
  x_msg_count			  OUT  NOCOPY  NUMBER,
  x_msg_data			  OUT  NOCOPY  VARCHAR2,
  x_request_id                    OUT  NOCOPY  NUMBER
)

IS
  l_api_name            VARCHAR2(255):='IEM_CREATE_SR';
  l_api_version_number  NUMBER:=1.0;
  l_cs_version_number   NUMBER:=4.0;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(2000);
  l_index               NUMBER := 1;

  l_service_request_rec  CS_ServiceRequest_PUB.service_request_rec_type;
  p_notes                CS_ServiceRequest_PUB.notes_table;
  p_contacts             CS_ServiceRequest_PUB.contacts_table;
  l_sr_create_out_rec    CS_ServiceRequest_PUB.sr_create_out_rec_type;
  p_keyVals_tbl          IEM_ROUTE_PUB.keyVals_tbl_type;

  l_notes                CS_ServiceRequest_PUB.notes_table;
  l_contacts             CS_ServiceRequest_PUB.contacts_table;

  l_summary_prefix      VARCHAR2(80);
  l_summary             VARCHAR2(300);
  l_party_type          VARCHAR2(80);
  l_contact_type          VARCHAR2(80);

   --abhgauta - Debug for Bug 6373644
  l_auto_assign         VARCHAR2(10);

  IEM_SR_NOT_CREATE EXCEPTION;

  CURSOR caller_type
  IS
  SELECT party_type
  FROM  hz_parties a
  WHERE a.party_id = p_party_id
  AND	a.status = 'A'
  AND   a.party_type IN ('ORGANIZATION','PERSON');
    l_coverage_template_id    NUMBER;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  IEM_CREATE_SR;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

  FND_PROFILE.Get('IEM_SR_SUM_PREFIX', l_summary_prefix);

  l_summary :=  l_summary_prefix||' : '|| p_subject ;


  CS_ServiceRequest_PUB.initialize_rec(l_service_request_rec);


  l_service_request_rec.type_id       := p_sr_type_id;
  l_service_request_rec.summary       := l_summary;
  l_service_request_rec.customer_id   := p_party_id;
  l_service_request_rec.sr_creation_channel       := 'EMAIL';
  l_service_request_rec.creation_program_code      := 'EMAILCENTER';

  OPEN caller_type;
  FETCH caller_type INTO l_party_type;

  IF (caller_type%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE caller_type;
  END IF;

  CLOSE caller_type;

  l_service_request_rec.caller_type  := l_party_type; -- 'ORGANIZATION'/'PERSON';

  l_index := 1;

-- Restricting notes to 2000 char only, Sanjana Rao, bug 8677528
        l_notes(l_index).NOTE                       := substrb(p_note,1,2000) ;
        l_notes(l_index).NOTE_TYPE                  := p_NOTE_TYPE;

  IF (p_contact_id IS NOT NULL and p_employee_flag = 'Y' )
  THEN
     l_index := 1;
        l_contacts(l_index).PARTY_ID                   :=  p_contact_id;
        l_contacts(l_index).PRIMARY_FLAG               :=  'Y';
        l_contacts(l_index).CONTACT_POINT_TYPE         :=  'EMAIL';
        l_contacts(l_index).CONTACT_TYPE               :=  'EMPLOYEE';
  ELSE
   IF (p_contact_id IS NOT NULL and p_employee_flag = 'N')
   THEN
	select party_type into l_contact_type
        from hz_parties
        where party_id = p_contact_id;

     l_index := 1;
        l_contacts(l_index).PARTY_ID                   := p_contact_id;
        l_contacts(l_index).contact_point_id           := p_contact_point_id;
	l_contacts(l_index).PRIMARY_FLAG               := 'Y';
        l_contacts(l_index).CONTACT_POINT_TYPE         := 'EMAIL';
        l_contacts(l_index).CONTACT_TYPE               := l_contact_type;

  END IF;
  END IF;

-- abhgauta - Debug for Bug 6373644
l_auto_assign := fnd_profile.value('CS_AUTO_ASSIGN_OWNER_HTML');

l_coverage_template_id:=fnd_profile.value_specific('CS_SR_DEFAULT_COVERAGE');


CS_ServiceRequest_PUB.Create_ServiceRequest (
                  p_api_version           => l_cs_version_number,
                  p_init_msg_list         => FND_API.G_FALSE,
                  p_commit	          => FND_API.G_FALSE,
                  x_return_status         => l_return_status,
                  x_msg_count             => l_msg_count,
                  x_msg_data              => l_msg_data,
                  p_resp_appl_id	  => NULL,
                  p_resp_id		  => NULL,
                  p_user_id		  => NULL,
                  p_login_id		  => NULL,
                  p_org_id		  => NULL,
                  p_request_id            => NULL,
                  p_request_number	  => NULL,
                  p_service_request_rec   => l_service_request_rec,
                  p_notes                 => l_notes,
                  p_contacts              => l_contacts,
                  p_auto_assign           => l_auto_assign,
                  p_auto_generate_tasks		  => 'N',
                  x_sr_create_out_rec	  	  => l_sr_create_out_rec,
                  p_default_contract_sla_ind	  => 'Y',
                  p_default_coverage_template_id  => l_coverage_template_id
                  );

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_SR_NOT_CREATE;
   end if;

   x_return_status := l_return_status ;
   x_request_id     := l_sr_create_out_rec.request_id;

   --Standard check of p_commit
   IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
   END IF;

EXCEPTION
    WHEN IEM_SR_NOT_CREATE THEN
        ROLLBACK TO IEM_CREATE_SR;
        x_return_status := l_return_status ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO IEM_CREATE_SR;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO IEM_CREATE_SR;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

    WHEN OTHERS THEN
            ROLLBACK TO IEM_CREATE_SR;
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
    END;


end IEM_SERVICEREQUEST_PVT;

/
