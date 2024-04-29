--------------------------------------------------------
--  DDL for Package Body IES_TELESALES_BP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_TELESALES_BP_PKG" AS
/* $Header: iestsbpb.pls 120.1 2005/06/16 11:16:32 appldev  $ */
PROCEDURE create_sales_lead(
 p_api_version number,
 p_user_name varchar2,
 p_customer_id number,
 p_contact_id number,
 p_project_name varchar2,
 p_channel_code varchar2,
 p_budget_amount number,
 p_budget_status_code varchar2,
 p_currency_code varchar2,
 p_decision_timeframe_code varchar2,
 p_description varchar2,
 p_source_promotion_id number,
 p_status_code varchar2,
 p_interest_type_id number,
 p_primary_interest_code_id number,
 p_secondary_interest_code_id number,
 x_sales_lead_id OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2
 )
is
  l_msg_data		  VARCHAR2(2000);
  my_message          VARCHAR2(2000);
BEGIN

 x_sales_lead_id := 0;
 x_msg_count := 1;
 FND_MESSAGE.SET_NAME ('IES', 'IES_LEAD_API_OBSOLETE');
 l_msg_data   := FND_MESSAGE.GET;
 x_msg_data := l_msg_data;
 return;

END CREATE_SALES_LEAD;

PROCEDURE CREATE_INTEREST(
 p_api_version number,
 p_user_name varchar2,
 p_party_type varchar2,
 p_party_id number,
 p_party_site_id number,
 p_contact_id number,
 p_interest_type_id number,
 p_primary_interest_code_id number,
 p_secondary_interest_code_id number,
 x_interest_id OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2
 )
is
l_user_id number;
l_interest_rec AS_INTEREST_PUB.interest_rec_type;
l_interest_use_code varchar2(80);
l_return_status varchar2(10);
l_msg_data varchar2(4000);
l_msg_count number;
l_count number;
l_interest_out_id number;
my_message varchar2(2000);

begin

 	SELECT user_id
 	INTO   l_user_id
 	FROM   FND_USER
 	where user_name = p_user_name;

	FND_GLOBAL.apps_initialize(l_user_id, null, null, null);

  	l_interest_rec.interest_type_id := p_interest_type_id;
  	l_interest_rec.primary_interest_code_id  := p_primary_interest_code_id;
  	l_interest_rec.secondary_interest_code_id  := p_secondary_interest_code_id;

	if p_party_type = 'PERSON' then
		l_interest_use_code := 'CONTACT_INTEREST';
	elsif p_party_type = 'ORGANIZATION' then
		l_interest_use_code := 'COMPANY_CLASSIFICATION' ;
	end if;

	AS_INTEREST_PUB.Create_Interest(
				p_api_version_number     => 2.0 ,
			     p_init_msg_list          => FND_API.G_FALSE,
			     p_commit                 => FND_API.G_FALSE,
				p_interest_rec           => l_interest_rec,
				p_customer_id            => p_party_id,
			     p_address_id             => p_party_site_id,
			     p_contact_id             => null,
			     p_lead_id                => null,
			     p_interest_use_code      => l_interest_use_code,
			     p_check_access_flag      => 'N',
				p_admin_flag             => null,
				p_admin_group_id         => null,
				p_identity_salesforce_id => null,
				p_access_profile_rec     => null,
				p_return_status          => l_return_status,
				p_msg_count              => l_msg_count,
				p_msg_data               => l_msg_data,
				p_interest_out_id        => l_interest_out_id);

--	 DBMS_OUTPUT.PUT_LINE('x_return_status:' || l_return_status);
--	 DBMS_OUTPUT.PUT_LINE('x_msg_data:     ' || l_msg_data);
--	 DBMS_OUTPUT.PUT_LINE('x_msg_count:     ' || l_msg_count);


 l_count := FND_MSG_PUB.Count_Msg;
-- dbms_output.put_line('There are ' || l_count || ' messages.');
 FOR l_index IN 1..l_count LOOP
    my_message := FND_MSG_PUB.Get(
        p_msg_index   =>  l_index,
       p_encoded     =>  FND_API.G_FALSE);
--    dbms_output.put_line(substr(my_message,1,255));
 END LOOP;


 x_return_status := l_return_status;
 x_interest_id := l_interest_out_id;
 x_msg_count := l_msg_count;
 x_msg_data := l_msg_data;

END CREATE_INTEREST;


PROCEDURE CREATE_OPP_FOR_LEAD(
 p_api_version number,
 p_user_name varchar2,
 p_sales_lead_id number,
 x_opp_id OUT NOCOPY /* file.sql.39 change */ number,
 x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
 x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
 x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2)
 is

  l_application_id   NUMBER := 279;
  l_commit            VARCHAR2(10) := FND_API.G_FALSE;
  l_return_status     VARCHAR2(10) := 'S';
  l_msg_count         NUMBER  := 0;
  l_msg_data          VARCHAR2(4000) default NULL;
  l_opp_id NUMBER;
  l_user_id    NUMBER;
  l_resource_id    NUMBER;
  l_count NUMBER := 0;
  my_message          VARCHAR2(2000);

BEGIN
 SELECT user_id
 INTO   l_user_id
 FROM   FND_USER
 where user_name = p_user_name;

 SELECT resource_id
 INTO   l_resource_id
 FROM  jtf_rs_resource_extns
 WHERE user_name = p_user_name;


 FND_GLOBAL.APPS_INITIALIZE(l_user_id, null, 279);

 FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;


  AS_SALES_LEADS_PUB.Create_Opportunity_For_Lead(
           p_api_version_number     => 2.0
          ,p_init_msg_list          => FND_API.G_FALSE
          ,p_commit                 => FND_API.G_FALSE
          ,p_validation_level       => 90
          ,P_Check_Access_Flag      => 'Y'
          ,P_Admin_Flag             => 'N'
          ,P_Admin_Group_Id         => NULL
	     ,P_Identity_Salesforce_Id => l_resource_id
          ,P_Sales_Lead_Profile_Tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL
          ,P_SALES_LEAD_ID          => p_sales_lead_id
          ,x_return_status          => l_return_status
          ,x_msg_count              => l_msg_count
          ,x_msg_data               => l_msg_data
          ,x_opportunity_id         => l_opp_id );


     l_count := FND_MSG_PUB.Count_Msg;
--     dbms_output.put_line('There are ' || l_count || ' messages.');
     FOR l_index IN 1..l_count LOOP
          my_message := FND_MSG_PUB.Get(
               p_msg_index   =>  l_index,
               p_encoded     =>  FND_API.G_FALSE);
--         dbms_output.put_line(substr(my_message,1,255));
     END LOOP;

 x_return_status := l_return_status;
 x_opp_id := l_opp_id;
 x_msg_count := l_msg_count;
 x_msg_data := l_msg_data;
END CREATE_OPP_FOR_LEAD;

procedure submit_collateral_to_fm(
p_api_version number,
p_deliverable_id number,
p_email	varchar2,
p_subject varchar2,
p_party_id number,
p_user_name varchar2,
p_user_note varchar2,
x_request_id OUT NOCOPY /* file.sql.39 change */ number,
x_return_status OUT NOCOPY /* file.sql.39 change */ varchar2,
x_msg_count OUT NOCOPY /* file.sql.39 change */ number,
x_msg_data OUT NOCOPY /* file.sql.39 change */ varchar2) is

l_request_id number;
l_content_id number;
l_user_id number;
l_return_status varchar2(10);
l_request_type varchar2(15);
l_msg_count number;
l_msg_data varchar2(4000);
l_content_xml varchar2(2000);

begin
	SELECT user_id
	INTO   l_user_id
	FROM   FND_USER
	where user_name = p_user_name;

	SELECT jtf_amv_item_id
	INTO   l_content_id
	FROM AMS_DELIVERABLES_VL
	WHERE deliverable_id = p_deliverable_id;

	FND_GLOBAL.APPS_INITIALIZE(l_user_id, null, 279);

	JTF_FM_REQUEST_GRP.START_REQUEST(p_api_version => 1.0,
							   x_return_status => l_return_status,
							   x_msg_count => l_msg_count,
							   x_msg_data => l_msg_data,
							   x_request_id => l_request_id);

	if (l_return_status = 'E') then
		x_return_status := l_return_status;
		x_msg_count := l_msg_count;
		x_msg_data := l_msg_data;
		return;
	end if;


	JTF_FM_REQUEST_GRP.GET_CONTENT_XML(p_api_version => 1.0,
							x_return_status => l_return_status,
							x_msg_count => l_msg_count,
							x_msg_data => l_msg_data,
							p_content_id => l_content_id,
							p_media_type => 'EMAIL',
							p_email => p_email,
							p_user_note => p_user_note,
							p_content_type => 'COLLATERAL',
							p_request_id => l_request_id,
							x_content_xml => l_content_xml);
	if (l_return_status = 'E') then
		x_return_status := l_return_status;
		x_msg_count := l_msg_count;
		x_msg_data := l_msg_data;
		return;
	end if;


	JTF_FM_REQUEST_GRP.SUBMIT_REQUEST (p_api_version => 1.0,
								p_commit => FND_API.G_FALSE,
							 	x_return_status => l_return_status,
								x_msg_count => l_msg_count,
								x_msg_data => l_msg_data,
								p_subject => p_subject,
								p_party_id => p_party_id,
								p_user_id => l_user_id,
								p_queue_response => FND_API.G_TRUE,
								p_content_xml => l_content_xml,
								p_request_id => l_request_id);


	x_return_status := l_return_status;
	x_msg_count := l_msg_count;
	x_msg_data := l_msg_data;
	x_request_id := l_request_id;

end SUBMIT_COLLATERAL_TO_FM;


procedure register_for_event(p_api_version number,
p_source_code varchar2,
p_event_offer_id number,
p_registrant_party_id number,
p_registrant_contact_id number,
p_attendant_party_id number,
p_attendant_contact_id number,
p_user_name varchar2,
p_application_id number,
x_event_registration_id OUT NOCOPY /* file.sql.39 change */ number,
x_confirmation_code OUT NOCOPY /* file.sql.39 change */ varchar2,
x_system_status_code  OUT NOCOPY /* file.sql.39 change */ varchar2,
x_return_status  OUT NOCOPY /* file.sql.39 change */ varchar2,
x_msg_count  OUT NOCOPY /* file.sql.39 change */ number,
x_msg_data  OUT NOCOPY /* file.sql.39 change */ varchar2) is

l_user_id number;
l_event_regs_rec AMS_EVTREGS_PVT.evt_regs_rec_type;
l_event_registration_id number;
l_confirmation_code varchar2(30);
l_system_status_code varchar2(30);
l_return_status varchar2(10);
l_msg_count number;
l_msg_data varchar2(4000);

begin

	SELECT user_id
	INTO   l_user_id
	FROM   FND_USER
	where user_name = p_user_name;

 	FND_GLOBAL.APPS_INITIALIZE(l_user_id, null, p_application_id);
	l_event_regs_rec.source_code := p_source_code;
	l_event_regs_rec.event_offer_id := p_event_offer_id;
	l_event_regs_rec.registrant_party_id := p_registrant_party_id;
	l_event_regs_rec.attendant_party_id := p_attendant_party_id;
	l_event_regs_rec.registrant_contact_id := p_registrant_contact_id;
	l_event_regs_rec.attendant_contact_id := p_attendant_contact_id;
	l_event_regs_rec.owner_user_id  := l_user_id;
	l_event_regs_rec.application_id  := p_application_id;

	AMS_EVTREGS_PUB.Register(
		p_api_version_number => p_api_version,
		p_init_msg_list => FND_API.G_TRUE,
		p_commit => FND_API.G_FALSE,
		p_evt_regs_rec => l_event_regs_rec,
		x_event_registration_id => l_event_registration_id,
		x_confirmation_code => l_confirmation_code,
		x_system_status_code => l_system_status_code,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data);

		x_event_registration_id := l_event_registration_id;
		x_confirmation_code := l_confirmation_code;
		x_system_status_code := l_system_status_code;
		x_return_status := l_return_status;
		x_msg_count := l_msg_count;
		x_msg_data := l_msg_data;

end register_for_event;

END IES_TELESALES_BP_PKG;

/
