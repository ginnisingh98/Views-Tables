--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_REFERRAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_REFERRAL" AS
/* $Header: asxvlrpb.pls 120.1 2005/06/24 17:10:46 appldev ship $ */

-- PROCEDURE
--    Update_sales_referral_lead
--
-- PURPOSE
--    Update sales lead from referral screen.
--
-- PARAMETERS

--
-- NOTES
--
----------------------------------------------------------------------

PROCEDURE Update_sales_referral_lead(
   P_Api_Version_Number		IN   NUMBER,
   P_Init_Msg_List		    IN   VARCHAR2     := FND_API.G_FALSE,
   P_Commit			        IN   VARCHAR2     := FND_API.G_FALSE,
   P_Validation_Level		IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   P_Check_Access_Flag		IN   VARCHAR2     := FND_API.G_MISS_CHAR,
   P_Admin_Flag			    IN   VARCHAR2     := FND_API.G_MISS_CHAR,
   P_Admin_Group_Id		    IN   NUMBER       := FND_API.G_MISS_NUM,
   P_identity_salesforce_id	IN   NUMBER       := FND_API.G_MISS_NUM,
   P_Sales_Lead_Profile_Tbl	    IN   AS_UTILITY_PUB.Profile_Tbl_Type := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
   P_SALES_LEAD_Rec		    IN   AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                         DEFAULT AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
   p_overriding_usernames       IN  t_overriding_usernames,
   X_Return_Status		    OUT NOCOPY   VARCHAR2,
   X_Msg_Count			    OUT NOCOPY   NUMBER,
   X_Msg_Data			    OUT NOCOPY   VARCHAR2
   )
   IS

   l_api_version		    CONSTANT NUMBER := 2.0;
   l_api_name			    CONSTANT VARCHAR2(30) := 'Update_sales_referral_lead';
   l_full_name			    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status		    VARCHAR2(1);


   l_sales_lead_id		    AS_SALES_LEADS.sales_lead_id%type;
   l_referral_status		    AS_SALES_LEADS.referral_status%type;
   l_referred_by		    AS_SALES_LEADS.referred_by%type;
   l_sales_lead_log_id		    number;
   l_lead_referral_status           VARCHAR2(100);
    l_msg_data		            VARCHAR2(10000):='';
   my_message VARCHAR2(2000);
   CURSOR  lc_sales_lead (pc_sales_lead_id number) IS
   SELECT lead.referred_by, lead.referral_status
   FROM AS_SALES_LEADS LEAD
   WHERE LEAD.SALES_LEAD_ID = pc_sales_lead_id;

BEGIN

   -------------------- initialize -------------------------
   SAVEPOINT Update_sales_referral_lead;

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name||': start');

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         P_Api_Version_Number,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;


   ----------------------- validate ----------------------
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': validate');

   IF (P_SALES_LEAD_Rec.sales_lead_id is null) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('PV', 'PV_NO_LEAD_FOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;


   OPEN lc_sales_lead (pc_sales_lead_id => P_SALES_LEAD_Rec.sales_lead_id);
   FETCH lc_sales_lead INTO  l_referred_by, l_referral_status;
   CLOSE lc_sales_lead;

   	--l_msg_data:=l_msg_data || '** Referral Status from table  :'|| l_referral_status;
	--l_msg_data:=l_msg_data || '** Referral Status from record :'|| P_SALES_LEAD_Rec.REFERRAL_STATUS;

   -------------------------- call API --------------------
   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': update');
   l_lead_referral_status:=P_SALES_LEAD_Rec.REFERRAL_STATUS;

--main if,
--if referral type is null, do nothing.
IF( P_SALES_LEAD_Rec.referral_type is null) THEN
	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
		fnd_message.Set_Token('TEXT', 'In ' || l_api_name || 'Referral Type is null');
		fnd_msg_pub.Add;
	END IF;
	--l_msg_data:=l_msg_data || ' Referral Type is null  ';
end if;

IF( P_SALES_LEAD_Rec.referral_type is not null) THEN

  --If referral status is changed, we need to update lead and insert row in log table
  --and send notification based on status
  IF (l_referral_status is null OR l_referral_status <> l_lead_referral_status) THEN

       AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': status changed');
      -- Call API to create log entry


      AS_SALES_LEADS_LOG_PKG.Insert_Row(
            px_log_id                => l_sales_lead_log_id ,
            p_sales_lead_id          => P_SALES_LEAD_Rec.sales_lead_id,
            p_created_by             => fnd_global.user_id,
            p_creation_date          => sysdate,
            p_last_updated_by        => fnd_global.user_id,
            p_last_update_date       => sysdate,
            p_last_update_login      => FND_GLOBAL.CONC_LOGIN_ID,
            p_request_id             => P_SALES_LEAD_Rec.request_id,
            p_program_application_id => P_SALES_LEAD_Rec.program_application_id,
            p_program_id             => P_SALES_LEAD_Rec.program_id,
            p_program_update_date    => P_SALES_LEAD_Rec.program_update_date,
            p_status_code            => P_SALES_LEAD_Rec.REFERRAL_STATUS,
            p_assign_to_person_id    => P_SALES_LEAD_Rec.assign_to_person_id,
            p_assign_to_salesforce_id=> P_SALES_LEAD_Rec.assign_to_salesforce_id,
            p_reject_reason_code     => P_SALES_LEAD_Rec.reject_reason_code,
            p_assign_sales_group_id  => P_SALES_LEAD_Rec.assign_sales_group_id,
            p_lead_rank_id           => P_SALES_LEAD_Rec.lead_rank_id,
            p_qualified_flag         => P_SALES_LEAD_Rec.qualified_flag,
	        p_category		     => g_log_lead_referral_category
            );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     -- l_msg_data:=l_msg_data || '** after inserted log row';
      IF (--l_lead_referral_status = g_referral_status_sub or
	  l_lead_referral_status = g_referral_status_acc  or
	  l_lead_referral_status = g_referral_status_dec or
	  --l_lead_referral_status = g_referral_status_comm_ltr or
	  l_lead_referral_status = g_referral_status_comm_acc or
	  l_lead_referral_status = g_referral_status_comm_rej
	 ) then

          -- Send OUT NOCOPY  email notification
	  AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': notification');
	 l_msg_data:=l_msg_data || '** while notifying';

	  AS_SALES_LEAD_REFERRAL.Notify_Party (
		p_api_version        => 1.0
		,p_init_msg_list     => FND_API.g_false
		,p_commit            => FND_API.g_false
		,p_validation_level  => FND_API.g_valid_level_full

		,p_lead_id	     => P_SALES_LEAD_Rec.sales_lead_id
		,p_lead_status	     => l_lead_referral_status
		,p_salesforce_id     => P_identity_salesforce_id

		,p_overriding_usernames => AS_SALES_LEAD_REFERRAL.G_MISS_OVER_USERNAMES_TBL
		,x_Msg_Count         => x_msg_count
		,x_Msg_Data          => x_msg_data
		,x_Return_Status     => x_return_status
	);

            l_msg_data:=l_msg_data || x_msg_Data;
	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;

   END IF;

    -- Update the referral status in as_sales_leads table

  l_msg_data:=l_msg_data || '** before calling Update sales lead';

            as_sales_leads_pub.update_sales_lead(

	    P_Api_Version_Number         => l_api_version,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => P_Check_Access_Flag,
            P_Admin_Flag                 => P_Admin_Flag,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_identity_salesforce_id     => P_identity_salesforce_id,
            P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl,
            P_SALES_LEAD_Rec             => P_SALES_LEAD_Rec,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data
        );
 l_msg_data:=l_msg_data || x_msg_Data;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
END IF;  -- end of main if (referral type is not null)



   IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
   ELSIF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
   END IF;

   -------------------- finish --------------------------


-- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   AS_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, l_full_name ||': end');
  -- x_msg_data:=l_msg_data;

EXCEPTION

   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Update_sales_referral_lead;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
	/*FOR l_index IN 1..FND_MSG_PUB.Count_Msg LOOP
            my_message := FND_MSG_PUB.Get(
                    p_msg_index   =>  l_index,
                    p_encoded     =>  FND_API.G_FALSE);

		loop
		exit when my_message is null;
		l_msg_data:= l_msg_data ||  substr( my_message, 1, 250 );
		my_message := substr( my_message, 251 );
		end loop;

   END LOOP;*/
  --x_msg_data:=l_msg_data;
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Update_sales_referral_lead;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

      --x_msg_data:=l_msg_data;
   WHEN OTHERS THEN
      ROLLBACK TO Update_sales_referral_lead;
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
      --x_msg_data:=l_msg_data;
END Update_sales_referral_lead;



---------------------------------------------------------------------
-- PROCEDURE
--    Notify_Party
--
-- PURPOSE
--    Notifies people when referral status is changed
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------

PROCEDURE  Notify_Party (
		p_api_version		IN  NUMBER    := 1.0
		,p_init_msg_list        IN  VARCHAR2  := FND_API.g_false
		,p_commit               IN  VARCHAR2  := FND_API.g_false
		,p_validation_level     IN  NUMBER    := FND_API.g_valid_level_full
		,p_lead_id	            IN  NUMBER
		,p_lead_status	            IN  VARCHAR2
		,p_salesforce_id        IN  NUMBER
		,p_overriding_usernames IN  t_overriding_usernames default G_MISS_OVER_USERNAMES_TBL
		,x_msg_count	        OUT NOCOPY  NUMBER
		,x_msg_data             OUT NOCOPY  VARCHAR2
		,x_return_status        OUT NOCOPY  VARCHAR2
	)
	IS

	l_api_name				CONSTANT VARCHAR2(30) := 'Notify_Party';
	l_api_version			CONSTANT NUMBER       := 1.0;
	l_ptnr_user_name		VARCHAR2(50) :='';
	l_ptnr_org_name			VARCHAR2(100) :='';
	l_notify_role_list		VARCHAR2(2000);
	l_notify_role			VARCHAR2(80);
        l_notify_ptnr_role            VARCHAR2(80);
	l_itemType				CONSTANT VARCHAR2(30)  := g_wf_itemtype_notify;
	l_itemKey				VARCHAR2(30);
	l_user_id				NUMBER;
	l_user_name				fnd_user.user_name%type;
	l_person_id				NUMBER;--as_accesses_all.person_id%type;
	l_resource_id			NUMBER;
	l_customer_name			VARCHAR2(80);
	l_customer_city			VARCHAR2(50);
	l_customer_state		VARCHAR2(30);
	l_customer_country		VARCHAR2(50);
	l_lead_id				NUMBER ;
	l_wf_status_closed		VARCHAR2(20) := g_wf_status_closed;
	l_source_type			VARCHAR2(20) := g_source_type;
	l_user_count			NUMBER := 1;
	l_lead_assignment_id	NUMBER;
	l_party_id				NUMBER;

TYPE UserRecType		IS RECORD (
		user_id				NUMBER,
		user_name			fnd_user.user_name%type
    );

TYPE UserTableType      IS TABLE OF UserRecType   INDEX BY BINARY_INTEGER;
	l_user_table			UserTableType;
	l_lead_status			varchar2(50);

     -- Get lead info
      CURSOR lc_leads (pc_lead_id NUMBER) IS
      select  asl.description, asl.referred_by, asl.referral_type,lkp1.meaning referral_type_meaning,
              asl.referral_status,lkp2.meaning referral_status_meaning, asl.ref_order_number, asl.ref_order_amt,
              asl.ref_comm_amt, asl.ref_decline_reason,lkp3.meaning decline_reason_meaning,
              asl.ref_comm_ltr_status,asl.created_by
      from as_sales_leads asl, as_lookups lkp1, as_lookups lkp2, as_lookups lkp3
      where asl.sales_lead_id = pc_lead_id
      and   asl.referral_type = lkp1.lookup_code(+)
      and   lkp1.lookup_type(+)  = 'REFERRAL_TYPE'
      and   asl.referral_status = lkp2.lookup_code(+)
      and   lkp2.lookup_type(+)  = 'REFERRAL_STATUS'
      and   asl.ref_decline_reason = lkp3.lookup_code(+)
      and   lkp3.lookup_type(+)  = 'DECLINE_REASON';

    -- get lead owner user name from fnd_user
    CURSOR lc_lead_owner (pc_lead_id number) IS
    SELECT lead.assign_to_person_id, usr.user_name, usr.user_id, res.source_id
    FROM    as_sales_leads lead, fnd_user usr, jtf_rs_resource_extns res
    WHERE   lead.sales_lead_id = pc_lead_id
    and     lead.assign_to_person_id = res.source_id
    and     res.user_id = usr.user_id;

    -- Get External Sales Team People - Partner user name
    CURSOR lc_ptnr_users (pc_lead_id number) IS
    SELECT acc.salesforce_id, usr.user_name, usr.user_id
    FROM    as_accesses_all acc, jtf_rs_resource_extns res, fnd_user usr
    WHERE acc.sales_lead_id = pc_lead_id
--    AND   acc. salesforce_role_code  = 'REFERRAL'
    AND   acc.person_id IS NULL
    AND   acc.salesforce_id = res.resource_id
    AND   res.user_id = usr.user_id;

    -- Get Customer Information
	CURSOR  lc_customer (pc_lead_id number) IS
	SELECT  hp.party_name, hp.city, hp.state, hp.country
	FROM	as_sales_leads asl, hz_parties hp
	WHERE	asl.sales_lead_id = pc_lead_id
	AND	    hp.party_id = asl.customer_id;


CURSOR     lc_ptnr_org_name(pc_party_id NUMBER) IS
	SELECT  ORG.PARTY_ID, partner.party_name
    from    AS_SALES_LEADS LEAD, HZ_PARTIES PARTNER, HZ_RELATIONSHIPS REL,HZ_ORGANIZATION_PROFILES ORG
    where   LEAD.REFERRED_BY=REL.PARTY_ID and REL.SUBJECT_ID=PARTNER.PARTY_ID
    and     REL.OBJECT_ID=ORG.PARTY_ID
    and     ORG.internal_flag = 'Y'
    and     ORG.effective_end_date is null
    and     LEAD.referred_by = pc_party_id;

 cursor c_get_meaning (c_lookup_type varchar2, c_lookup_code varchar2) is
  select meaning
    from ar_lookups
   where lookup_type = c_lookup_type
     and   lookup_code = c_lookup_code;


cursor c_get_category (c_user_id number) is
  select category
    from jtf_rs_resource_extns
    where user_id = c_user_id;

cursor c_get_ptnr_full_name (c_user_id number) is
      select  ARLKP.meaning ||' '||puser.person_first_name||' ' || puser.person_last_name partner_contact_name
        from     jtf_rs_resource_extns JS,
                 hz_relationships PCONTACT, hz_relationships PORG,
                 hz_parties PUSER, hz_parties PARTNER, hz_parties VENDOR,
                 hz_organization_profiles HZOP, pv_partner_profiles PVPP,
                 hz_org_contacts HZOC, ar_lookups ARLKP
        where   JS.user_id = c_user_id
        AND     JS.source_id = pcontact.party_id
        AND     PCONTACT.subject_table_name = 'HZ_PARTIES'
        AND     PCONTACT.object_table_name = 'HZ_PARTIES'
        AND     PCONTACT.RELATIONSHIP_TYPE in ('EMPLOYMENT')
        AND     PCONTACT.directional_flag = 'F'
        AND     PCONTACT.STATUS       =  'A'
        AND     PCONTACT.start_date <= SYSDATE
        AND     nvl(PCONTACT.end_date, SYSDATE) >= SYSDATE
        AND     PUSER.party_id  =  PCONTACT.subject_id
        AND     PUSER.PARTY_TYPE   = 'PERSON'
        AND     PUSER.status = 'A'
        AND     HZOC.party_relationship_id  =  PCONTACT.relationship_id
        AND     PORG.subject_id   =  PCONTACT.object_id
        AND     PORG.subject_table_name = 'HZ_PARTIES'
        AND     PORG.object_table_name = 'HZ_PARTIES'
        AND     PORG.RELATIONSHIP_TYPE in ('PARTNER', 'VAD')
        AND     PORG.STATUS       =  'A'
        AND     PORG.start_date <= SYSDATE
        AND     nvl(PORG.end_date, SYSDATE) >= SYSDATE
        AND     PARTNER.party_id  =  PORG.subject_id
        AND     PARTNER.PARTY_TYPE   = 'ORGANIZATION'
        AND     PARTNER.status = 'A'
        AND     VENDOR.party_id = PORG.object_id
        AND     VENDOR.PARTY_TYPE  ='ORGANIZATION'
        AND     VENDOR.status = 'A'
        AND     HZOP.party_id = VENDOR.party_id
        AND     HZOP.effective_end_date is null
        AND     HZOP.internal_flag = 'Y'
        AND     PVPP.partner_id = PORG.party_id
        AND     PVPP.SALES_PARTNER_FLAG   = 'Y'
        AND     PUSER.person_title = ARLKP.lookup_code (+)
        and     ARLKP.lookup_type(+) = 'CONTACT_TITLE';

cursor c_get_ptnr_user_id (c_created_by number) is
          select user_name,user_id
          from jtf_rs_resource_extns
          where user_id = c_created_by;



l_lead_name             as_sales_leads.description%TYPE;
l_referred_by           as_sales_leads.referred_by%TYPE;
l_referral_type         as_sales_leads.referral_type%TYPE;
l_referral_type_meaning        varchar2(100);
l_referral_status       as_sales_leads.referral_status%TYPE;
l_referral_status_meaning     varchar2(100);
l_ref_order_number      as_sales_leads.ref_order_number%TYPE;
l_ref_order_amt         as_sales_leads.ref_order_amt%TYPE;
l_ref_comm_amt          as_sales_leads.ref_comm_amt%TYPE;
l_ref_decline_reason    as_sales_leads.ref_decline_reason%TYPE;
l_ref_decline_reason_meaning    varchar2(100);
l_ref_comm_ltr_status   as_sales_leads.ref_comm_ltr_status%TYPE;
l_ptnr_salesforce_id    as_accesses_all.salesforce_id%TYPE;
l_assign_to_person_id   number;
l_owner_user_name      fnd_user.user_name%TYPE;
l_owner_user_id        fnd_user.user_id%TYPE;
l_owner_source_id       number;
l_ptnr_user_id          number;
l_overriding_usercount  number;
l_count                 number;
l_mesg_data             varchar2(4000):= 'SWKHANNA';
l_workflow_respond_url varchar2(4000) := fnd_profile.value('PV_WORKFLOW_RESPOND_URL');
l_cust_state_meaning  varchar2(100);
l_cust_country_meaning varchar2(100);
l_referral_closedate   date;
l_created_by       number;
l_category          varchar2(100);
l_ptnr_full_name          varchar2(100);

BEGIN
	l_mesg_data := l_mesg_data ||'start notify party';
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version,
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
	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
		fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
		fnd_msg_pub.Add;
	END IF;



	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Notify_Party processing steps
        --  Get Lead Details using sales_lead_id from as_sales_leads
        --  Get a workflow item key from the sequence
        --  Create a workflow process
        --  Set Item Attributes i.e all the info reqd by the wf for that lead. eg. status
        --  Based on the referral_status, figure OUT NOCOPY  who to send the notification to
        --  Launch the process

   -- Get Lead information
   OPEN lc_leads(p_lead_id);
   FETCH lc_leads
   INTO l_lead_name, l_referred_by, l_referral_type,l_referral_type_meaning,
        l_referral_status,l_referral_status_meaning,
        l_ref_order_number, l_ref_order_amt, l_ref_comm_amt,
        l_ref_decline_reason,l_ref_decline_reason_meaning, l_ref_comm_ltr_status,l_created_by;
   CLOSE lc_leads;


   if p_lead_status is not null then
      l_referral_status := p_lead_status;
   end if;


	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
		fnd_message.Set_Token('TEXT', 'In  notify party ref_status' || l_referral_status);
		fnd_msg_pub.Add;
	END IF;

     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', 'In  notify party l_ref_decline_reason' || l_ref_decline_reason);
          fnd_msg_pub.Add;
     END IF;

     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', 'In  notify party l_ref_decline_reason meaning' || l_ref_decline_reason_meaning);
          fnd_msg_pub.Add;
     END IF;


	l_lead_id := p_lead_id;

   -- Get Customer Information
        OPEN	lc_customer (pc_lead_id => l_lead_id);
	FETCH   lc_customer
	INTO	l_customer_name,l_customer_city,l_customer_state,l_customer_country;
	CLOSE   lc_customer;

     -- Get Partner Org Name
	OPEN    lc_ptnr_org_name(pc_party_id => l_referred_by);
	FETCH   lc_ptnr_org_name
	INTO	l_party_id, l_ptnr_org_name;
	CLOSE    lc_ptnr_org_name;


	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'partner_org_name  : '|| l_ptnr_org_name || '  Party_id: ' || l_party_id );
            fnd_msg_pub.Add;
        END IF;

   -- Get Lookup ,meaning for country and state
   open c_get_meaning('STATE',l_customer_state);
   fetch c_get_meaning into l_cust_state_meaning;
   close c_get_meaning;

   open c_get_meaning('COUNTRY',l_customer_country);
   fetch c_get_meaning into l_cust_country_meaning;
   close c_get_meaning;

   open c_get_meaning('REFERRAL_STATUS',l_referral_status);
   fetch c_get_meaning into l_referral_status_meaning;
   close c_get_meaning;

   -- check to see if lead created by partner or vendor
    open c_get_category(l_created_by);
    fetch c_get_category into l_category;
    close c_get_category;

	--setting item key
	SELECT  PV_LEAD_WORKFLOWS_S.nextval
	INTO    l_itemKey
	FROM    dual;


	--setting notify role to a unique id
	l_notify_role := 'AS_' || l_itemKey || '_' || '0';
         l_notify_ptnr_role := 'AS_' || l_itemKey || '_' || 'P';



-- Get recipients of the messages

-- If overriding_users passed in, then use that list instead

   IF (p_overriding_usernames is not null and p_overriding_usernames.count > 0  ) THEN
       l_overriding_usercount := p_overriding_usernames.count   ;
       l_count := 1;
       LOOP

      EXIT WHEN l_count = p_overriding_usernames.count+1;
           l_notify_role_list := l_notify_role_list||','||UPPER(p_overriding_usernames(l_count));
           l_count := l_count + 1;


      END LOOP;

      l_notify_role_list := substr(l_notify_role_list,2);


      --
   ELSE
     -- If l_referral_status  not in ('ACCEPTED','DECLINED') then
     -- get lead owner user name from fnd_user
     -- There can be only one owner.
        OPEN lc_lead_owner (pc_lead_id => l_lead_id);
        FETCH lc_lead_owner INTO l_assign_to_person_id, l_owner_user_name, l_owner_user_id, l_owner_source_id;
        CLOSE lc_lead_owner;

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'owner user name  : '|| l_owner_user_name || '  l_owner_user_id: ' || l_owner_user_id);
 fnd_msg_pub.Add;
        END IF;

   --end if;
         l_user_table(l_user_count).user_id := l_owner_user_id;
         l_user_table(l_user_count).user_name := l_owner_user_name;
         l_user_count := l_user_count +1;
        --  members of external sales team
        --  Get Partner User Name

         -- People from external sales team only need to be added only in followig cases:
         -- If Lead is accepted i.e new opportunity created
         -- If Lead is rejected i.e. link to existing opportunity
       IF l_referral_status in ('ACCEPTED','DECLINED') then
           OPEN lc_ptnr_users (pc_lead_id => l_lead_id) ;
           LOOP
               FETCH lc_ptnr_users INTO  l_ptnr_salesforce_id, l_ptnr_user_name, l_ptnr_user_id;
               EXIT WHEN lc_ptnr_users%NOTFOUND;
                      l_user_table(l_user_count).user_id := l_ptnr_user_id;
                      l_user_table(l_user_count).user_name := l_ptnr_user_name;
                      l_user_count := l_user_count +1;
               END LOOP;
               -- just clearing these so they don't mess up later
               l_ptnr_user_name := null;
               l_ptnr_user_id := null;
           CLOSE lc_ptnr_users;
       END IF;
       if l_category = 'PARTY' then
       -- get partner contact user id
          open c_get_ptnr_user_id (l_created_by);
          fetch c_get_ptnr_user_id into l_ptnr_user_name,l_ptnr_user_id;
          close c_get_ptnr_user_id;
          --

       end if;
      -- Get Partner Contact Full Name
        open c_get_ptnr_full_name (l_ptnr_user_id);
        fetch c_get_ptnr_full_name into l_ptnr_full_name;
        close c_get_ptnr_full_name;


        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'l_ptnr_user_name  : '|| l_ptnr_user_name|| '  l_ptnr_user_id: ' || l_ptnr_user_id);
            fnd_msg_pub.Add;
        END IF;

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'l_ptnr_full_name  : '|| l_ptnr_full_name);
            fnd_msg_pub.Add;
        END IF;

      --Forming notify list form user table
       FOR i in 1 .. l_user_table.count LOOP

         if(
           l_user_table(i).user_id is not null
           ) then
          l_notify_role_list := l_notify_role_list || ',' || UPPER(l_user_table(i).user_name);
          end if;

       END LOOP;

       --taking first , OUT NOCOPY  of list
       l_notify_role_list := substr(l_notify_role_list,2);

    END IF; -- overring username clause

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'partner_user_name  : '|| l_ptnr_user_name );
            fnd_msg_pub.Add;
    END IF;


    -- Create Role
    wf_directory.CreateAdHocRole(role_name         => l_notify_role,
                                 role_display_name => l_notify_role,
                                 role_users        => l_notify_role_list);


   -- Create extra role for partner contact if partner created the lead
        wf_directory.CreateAdHocRole(role_name         => l_notify_ptnr_role,
                                     role_display_name => l_notify_ptnr_role,
                                     role_users        => UPPER(l_ptnr_user_name));


        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'Created role  : '|| l_notify_role || ' with members ' || l_notify_role_list);
            fnd_msg_pub.Add;
        END IF;


	IF        (l_referral_status = g_referral_status_sub
			or l_referral_status = g_referral_status_acc
			or l_referral_status = g_referral_status_dec
			or l_referral_status = g_referral_status_comm_ltr
			or l_referral_status = g_referral_status_comm_acc
			or l_referral_status = g_referral_status_comm_rej
            ) then

    	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'Referral Status  changed: ');
            fnd_msg_pub.Add;
		END IF;
		-- Once the parameters for workflow is validated, start the workflow
		wf_engine.CreateProcess (ItemType => l_itemType,
                                 ItemKey  => l_itemKey,
                                 process  => g_wf_pcs_notify_ptnr);

		wf_engine.SetItemUserKey (ItemType => l_itemType,
                                   ItemKey  => l_itemKey,
                                   userKey  => l_itemkey);

		--setting lead status so that it can be used in notify function
		wf_engine.SetItemAttrText (ItemType => l_itemType,
				                   ItemKey  => l_itemKey,
                                    aname    => g_wf_attr_lead_status,
                                    avalue   => l_referral_status);


          --setting lead status so that it can be used in notify function
          wf_engine.SetItemAttrText (ItemType => l_itemType,
                                       ItemKey  => l_itemKey,
                                    aname    => g_wf_attr_lead_status_mean,
                                    avalue   => l_referral_status_meaning);


			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_cust_name,
					    avalue   => l_customer_name);

			wf_engine.SetItemAttrText (ItemType => l_itemType,
					   ItemKey  => l_itemKey,
					   aname    => g_wf_attr_referral_type,
					   avalue   => l_referral_type);

               wf_engine.SetItemAttrText (ItemType => l_itemType,
                            ItemKey  => l_itemKey,
                            aname    => g_wf_attr_referral_type_mean,
                            avalue   => l_referral_type_meaning);

			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					   ItemKey  => l_itemKey,
					   aname    => g_wf_attr_ptnr_user_name,
					   avalue   => l_ptnr_user_name);

			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_cust_state,
					    avalue   => l_customer_state);

    			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_cust_country,
					    avalue   => l_customer_country);

			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_declined_reason,
					    avalue   => l_ref_decline_reason);

               wf_engine.SetItemAttrText ( ItemType => l_itemType,
                             ItemKey  => l_itemKey,
                             aname    => g_wf_attr_dec_reason_mean,
                             avalue   => l_ref_decline_reason_meaning);

			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_ptnr_org_name,
					    avalue   => l_ptnr_org_name);


			wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_referral_commission,
					    avalue   => l_ref_comm_amt);


			wf_engine.SetItemAttrText (ItemType => l_itemType,
				                    ItemKey  => l_itemKey,
                                    aname    => g_wf_attr_create_notify_role,
                                    avalue   => l_notify_role);

               wf_engine.SetItemAttrText (ItemType => l_itemType,
                                          ItemKey  => l_itemKey,
                                          aname    => g_wf_attr_create_ptnr_role,
                                          avalue   => l_notify_ptnr_role);


			wf_engine.SetItemAttrText (ItemType => l_itemType,
				                    ItemKey  => l_itemKey,
                                    aname    => g_wf_attr_accept_notify_role,
                                    avalue   => l_notify_role);

			wf_engine.SetItemAttrText (ItemType => l_itemType,
				                    ItemKey  => l_itemKey,
                                    aname    => g_wf_attr_reject_notify_role,
                                    avalue   => l_notify_role);

			wf_engine.SetItemAttrText (ItemType => l_itemType,
				                       ItemKey  => l_itemKey,
                                       aname    => g_wf_attr_referral_notify_role,
                                       avalue   => l_notify_role);

                        wf_engine.SetItemAttrText (ItemType => l_itemType,
                                       ItemKey  => l_itemKey,
                                       aname    => g_wf_attr_respond_url,
                                       avalue   =>l_workflow_respond_url );


               wf_engine.SetItemAttrText (ItemType => l_itemType,
                                          ItemKey  => l_itemKey,
                                          aname    => g_wf_attr_sales_lead_id,
                                          avalue   =>l_lead_id );

               wf_engine.SetItemAttrText (ItemType => l_itemType,
                                          ItemKey  => l_itemKey,
                                          aname    => g_wf_attr_referred_by,
                                          avalue   =>l_referred_by );

               wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                           ItemKey  => l_itemKey,
                                           aname    =>g_wf_attr_lead_name ,
                                           avalue   => l_lead_name);

              wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                           ItemKey  => l_itemKey,
                                           aname    =>g_wf_attr_created_by ,
                                           avalue   => l_created_by);


               wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                           ItemKey  => l_itemKey,
                                           aname    =>g_wf_attr_category ,
                                           avalue   => l_category);

               wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                           ItemKey  => l_itemKey,
                                           aname    =>g_wf_attr_ptnr_full_name ,
                                           avalue   => l_ptnr_full_name);

		/*	wf_engine.SetItemAttrText ( ItemType => l_itemType,
					    ItemKey  => l_itemKey,
					    aname    => g_wf_attr_referral_closedate,
					    avalue   => l_referral_closedate);*/

      -- l_mesg_data := l_mesg_data ||'End';

	-- Debug Message
	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'Before Start Process ');
            fnd_msg_pub.Add;
	END IF;

		wf_engine.StartProcess (ItemType => l_itemType,
				ItemKey  => l_itemKey);

       -- dbms_output.put_line('started process');

	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'After Start Process ');
            fnd_msg_pub.Add;
	END IF;

    end if;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
 --  x_msg_data := l_mesg_data;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
--x_msg_data := 'SWKHANNA1'||l_mesg_data;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
--x_msg_data := 'SWKHANNA2'||l_mesg_data;
   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
--x_msg_data :='SWKHANNA3'|| l_mesg_data;
End Notify_Party;

/* This procedure is called from the workflow process to decide whether to send notification to partner*/
PROCEDURE SEND_PTNR_NTF(
     itemtype       in varchar2,
     itemkey             in varchar2,
     actid               in number,
     funcmode       in varchar2,
     resultout      IN OUT NOCOPY  varchar2
) IS
     l_api_name              CONSTANT VARCHAR2(30) := 'SEND_PTNR_NTF';
     l_api_version_number     CONSTANT NUMBER   := 1.0;


     l_return_status          varchar2(1);
     l_msg_count         number;
     l_msg_data          varchar2(2000);

     l_category       varchar2(100);
     l_ptnr_user_name       varchar2(100);
     l_resultout         varchar2(50);

  BEGIN
     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
     fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
     fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
     fnd_msg_pub.Add;
     END IF;

     if (funcmode = 'RUN') then
         -- Figure OUT NOCOPY  if the lead was created by the partner. Only if the lead was created by the
         -- partner , only then the lead creation email will be sent to the partner contact in addition
        --  to the lead owner from vendor side. The vendor notification is sent both times i.e when the
        -- the lead is created by vendor or partner

          l_category := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_category);

          l_ptnr_user_name := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_ptnr_user_name);

          IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'Category ' || l_category);
               fnd_msg_pub.Add;
          END IF;
          IF (l_category = 'PARTY' and l_ptnr_user_name is not null ) THEN
               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
                    fnd_message.Set_Token('TEXT', 'Category is  ' || l_category);
                    fnd_msg_pub.Add;
               END IF;
               l_resultout := 'COMPLETE:' || 'Y';
          END IF;

     else

          l_resultout := 'COMPLETE:'||'N';
     end if;
     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', 'Function output : ' || l_resultout);
          fnd_msg_pub.Add;
          END IF;
     resultout := l_resultout;

   END SEND_PTNR_NTF;




/* This procedure is called from the workflow process to get the current status of the Lead */
PROCEDURE AS_LEAD_NOTIFY(
	itemtype		in varchar2,
	itemkey			in varchar2,
	actid			in number,
	funcmode		in varchar2,
	resultout	 IN OUT NOCOPY  varchar2
) IS

	l_api_name              CONSTANT VARCHAR2(30) := 'AS_LEAD_NOTIFY';
	l_api_version_number	CONSTANT NUMBER   := 1.0;


	l_return_status		varchar2(1);
	l_msg_count		number;
	l_msg_data		varchar2(2000);

	l_temp_status		varchar2(40);
	l_resultout		varchar2(50);

   BEGIN

	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
	fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
	fnd_msg_pub.Add;
	END IF;

	if (funcmode = 'RUN') then
		l_temp_status := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_lead_status);


		IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
			fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
			fnd_message.Set_Token('TEXT', 'Lead Status in AS_lead_notify ' || l_temp_status);
			fnd_msg_pub.Add;
		END IF;
        -- Lead Submitted
		IF (l_temp_status = g_referral_status_sub ) THEN
               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
                    fnd_message.Set_Token('TEXT', 'Lead Status in AS_lead_notify ' || l_temp_status);
                    fnd_msg_pub.Add;
               END IF;

			l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_sub;
		END IF;
        -- Lead Accepted
		IF ( l_temp_status = g_referral_status_acc) THEN
				l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_acc;
		END IF;
        -- Lead Declined
        IF ( l_temp_status = g_referral_status_dec) THEN
				l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_dec;
		END IF;
        -- Lead Commision Letter Sent
        IF ( l_temp_status = g_referral_status_comm_ltr) THEN
				l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_comm_ltr;
		END IF;
        -- Commission Accepted
        IF ( l_temp_status = g_referral_status_comm_acc) THEN
				l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_comm_acc;
		END IF;
        -- Commission Rejected
        IF ( l_temp_status = g_referral_status_comm_rej) THEN
				l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_comm_rej;
		END IF;

/*
		IF(l_temp_status = g_action_referral) THEN
			l_resultout := 'COMPLETE:' || g_wf_lkup_lead_status_ref;
		END IF;
*/
		--l_resultout := 'COMPLETE:' || l_temp_status;
	else

		l_resultout := 'COMPLETE';
	end if;
	IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		fnd_message.Set_Name('AS', 'AS_DEBUG_MESSAGE');
		fnd_message.Set_Token('TEXT', 'Function output : ' || l_resultout);
		fnd_msg_pub.Add;
		END IF;
	resultout := l_resultout;

   END AS_LEAD_NOTIFY;





End AS_SALES_LEAD_REFERRAL;



/
