--------------------------------------------------------
--  DDL for Package Body OKC_INTERACT_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_INTERACT_HISTORY_PVT" AS
/* $Header: OKCCIHAB.pls 120.0 2005/05/25 18:08:08 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  PROCEDURE CREATE_INTERACT_HISTORY (
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_interaction_id OUT NOCOPY NUMBER,
    p_media_type IN varchar2,
    p_action_item_id IN NUMBER,
    p_outcome_id IN NUMBER,
    p_touchpoint1_type IN VARCHAR2,
    p_resource1_id IN NUMBER,
    p_touchpoint2_type IN VARCHAR2,
    p_resource2_id IN NUMBER,
    p_contract_id IN NUMBER,
    p_int_start_date IN DATE,
    p_int_end_date IN DATE,
    p_notes IN varchar2,
    p_notes_detail IN varchar2) IS
    l_interaction_rec JTF_IH_PUB.interaction_rec_type;
    l_interaction_id  NUMBER;
    l_activity_rec JTF_IH_PUB.activity_rec_type;
    l_activity_id  NUMBER;
    l_media_rec JTF_IH_PUB.media_rec_type;
    l_media_id NUMBER := NULL;
    l_note_id number;
  BEGIN

/* Opening Interaction     */

   l_interaction_rec.start_date_time := p_int_start_date;
   l_interaction_rec.end_date_time := p_int_end_date;
   l_interaction_rec.handler_id := G_HANDLER_ID;
   l_interaction_rec.script_id := NULL;
   l_interaction_rec.outcome_id := p_outcome_id;
   l_interaction_rec.result_id := NULL;
   l_interaction_rec.reason_id := NULL;
   l_interaction_rec.touchpoint2_type := p_touchpoint2_type;
   l_interaction_rec.resource_id := p_resource2_id;
   l_interaction_rec.touchpoint1_type := p_touchpoint1_type;
   l_interaction_rec.party_id := p_resource1_id;
   l_interaction_rec.parent_id := NULL;
   l_interaction_rec.object_id := NULL;
   l_interaction_rec.object_type := NULL;
   l_interaction_rec.source_code_id := NULL;
   l_interaction_rec.source_code := NULL;
   JTF_IH_PUB.Open_Interaction
	( p_api_version =>1.0,
       p_init_msg_list => OKC_API.G_FALSE,
       p_commit => OKC_API.G_FALSE,
	  p_user_id => FND_GLOBAL.USER_ID,
--	  p_login_id => FND_GLOBAL.LOGIN_ID,
--	  p_resp_id => NULL,
--	  p_resp_appl_id => NULL,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data =>  x_msg_data,
	  p_interaction_rec => l_interaction_rec,
	  x_interaction_id => l_interaction_id);
   if x_return_status <> 'S' Then
     return;
   end if;

/* Creating Media Item   */

   l_media_rec.media_id := NULL;
   l_media_rec.source_id := 1; /* default */
   l_media_rec.direction := NULL;
   l_media_rec.duration := NULL;
   l_media_rec.end_date_time := sysdate;
   l_media_rec.media_item_type := p_media_type;
--   l_media_rec.media_data := 'CONTRACTS MEDIA';
   l_media_rec.media_item_ref := NULL;
   l_media_rec.source_item_create_date_time := sysdate;
   l_media_rec.start_date_time := sysdate;
   l_media_rec.source_item_id := NULL;
--   l_media_rec.interaction_performed := 'Contract';
   JTF_IH_PUB.Create_MediaItem
	( p_api_version =>1.0,
       p_init_msg_list => OKC_API.G_FALSE,
       p_commit => OKC_API.G_FALSE,
	  p_user_id => FND_GLOBAL.USER_ID,
--	  p_login_id => FND_GLOBAL.LOGIN_ID,
--	  p_resp_id => NULL,
--	  p_resp_appl_id => NULL,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data =>  x_msg_data,
	  p_media_rec => l_media_rec,
	  x_media_id => l_media_id);
   if x_return_status <> 'S' Then
     return;
   end if;

  /* Adding Activity     */

   l_activity_rec.activity_id := NULL;
   l_activity_rec.duration := NULL;
   l_activity_rec.cust_account_id := null;
   l_activity_rec.cust_org_id := null;
   l_activity_rec.role := NULL;
   l_activity_rec.end_date_time := NULL;
   l_activity_rec.start_date_time := sysdate;
   l_activity_rec.task_id := NULL;
   l_activity_rec.doc_id := p_contract_id;
   l_activity_rec.doc_ref := 'OKC_K_HEADERS_V';
   l_activity_rec.media_id := l_media_id;
   l_activity_rec.action_item_id := p_action_item_id;
   l_activity_rec.interaction_id := l_interaction_id;
   l_activity_rec.outcome_id := p_outcome_id;
   l_activity_rec.result_id := NULL;
   l_activity_rec.reason_id := NULL;
--   l_activity_rec.description := 'Activity for Contracts (OKC)';
   l_activity_rec.action_id := NULL;
   l_activity_rec.interaction_action_type := NULL;
   l_activity_rec.object_id := NULL;
   l_activity_rec.object_type := NULL;
   l_activity_rec.source_code_id := NULL;
   l_activity_rec.source_code := NULL;
   JTF_IH_PUB.Add_Activity
	( p_api_version =>1.0,
       p_init_msg_list => OKC_API.G_FALSE,
       p_commit => OKC_API.G_FALSE,
	  p_user_id => FND_GLOBAL.USER_ID,
--	  p_login_id => FND_GLOBAL.LOGIN_ID,
--	  p_resp_id => NULL,
--	  p_resp_appl_id => NULL,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data =>  x_msg_data,
	  p_activity_rec => l_activity_rec,
	  x_activity_id => l_activity_id);
   if x_return_status <> 'S' Then
     return;
   end if;

   /* Close Interaction */

   JTF_IH_PUB.Close_Interaction
	( p_api_version =>1.0,
       p_init_msg_list => OKC_API.G_FALSE,
       p_commit => OKC_API.G_FALSE,
	  p_user_id => FND_GLOBAL.USER_ID,
--	  p_login_id => FND_GLOBAL.LOGIN_ID,
--	  p_resp_id => NULL,
--	  p_resp_appl_id => NULL,
	  x_return_status => x_return_status,
	  x_msg_count => x_msg_count,
	  x_msg_data =>  x_msg_data,
	  p_interaction_id => l_interaction_id);
   if x_return_status <> 'S' Then
     return;
   end if;

   /* Create Note */

   JTF_NOTES_PUB.Create_note
    (p_api_version => 1.0,
    p_jtf_note_id => OKC_API.G_MISS_NUM,
    p_init_msg_list => OKC_API.G_FALSE,
    p_commit => OKC_API.G_FALSE,
    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
    x_return_status	=> x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_source_object_id => l_activity_id,
    p_source_object_code => 'JTF_ACTIVITY',
    p_notes	=> p_notes,
    p_notes_detail => p_notes_detail,
    p_note_status => 'I',
    p_entered_by	=> fnd_global.user_id,
    p_entered_date => sysdate,
     x_jtf_note_id	=> l_note_id,
    p_last_update_date	=> sysdate,
    p_last_updated_by => fnd_global.user_id,
     p_creation_date => sysdate,
    p_created_by => fnd_global.user_id);
   if x_return_status <> 'S' Then
     return;
   end if;
   x_interaction_id := l_interaction_id;
  END  CREATE_INTERACT_HISTORY ;
END OKC_INTERACT_HISTORY_PVT;

/
