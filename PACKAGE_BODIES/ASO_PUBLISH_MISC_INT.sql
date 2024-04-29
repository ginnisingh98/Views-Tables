--------------------------------------------------------
--  DDL for Package Body ASO_PUBLISH_MISC_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_PUBLISH_MISC_INT" as
/* $Header: asoipmsb.pls 120.9.12010000.4 2014/04/29 05:52:29 akushwah ship $ */


GET_MESSAGE_ERROR  EXCEPTION;

Cursor  c_hz_parties(p_party_id NUMBER) IS
SELECT	Party_Name,Person_First_Name,Person_Middle_Name,Person_Last_name,party_type,Person_title
FROM	hz_parties
WHERE	party_id = p_party_id;

Cursor c_quote_header (p_quote_id 	NUMBER) IS
SELECT org_id,party_id, quote_name, quote_number, quote_version, quote_password,
cust_account_id,invoice_to_party_id, invoice_to_party_site_id, quote_header_id,
ordered_date, order_id, total_list_price,total_shipping_charge,total_tax,
total_quote_price,invoice_to_cust_account_id,total_adjusted_amount,
currency_code,resource_id,quote_status_id,minisite_id
FROM aso_quote_headers_all
WHERE  quote_header_id = p_quote_id;
g_quote_header_rec	c_quote_header%ROWTYPE;


Cursor c_quote_statuses( p_status_code VARCHAR2) IS
SELECT quote_status_id
FROM aso_quote_statuses_b
WHERE status_code = p_status_code;
c_quote_statuses_rec c_quote_statuses%ROWTYPE;


Cursor c_istore_lookup(p_message_name VARCHAR2) IS
select LOOKUP_CODE
from fnd_lookups
where lookup_type = 'IBE_WF_NOTIFICATION'
and LOOKUP_CODE = p_message_name
and ENABLED_FLAG = 'Y';
c_wf_notifications c_istore_lookup%ROWTYPE;


Cursor c_msite_resp_name(p_msite_id VARCHAR2, p_resp_id VARCHAR2) is
select display_name
from ibe_msite_resps_vl
where msite_id = to_number(p_msite_id)
and responsibility_id = to_number(p_resp_id);
c_store_name  c_msite_resp_name%rowtype;


--   API Name:  NotifyUserForRegistration
--   Type    :  Public
--   Pre-Req :  Workflow template for the notification should be there in the DB


PROCEDURE NotifyUserForRegistration(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_quote_id          IN   NUMBER,
     p_Send_Name         IN   Varchar2,
     p_Store_Name        IN   Varchar2,
     p_Store_Website     IN   Varchar2,
     p_FND_Password      IN   Varchar2,
     p_email_address     IN   varchar2 := null,
     p_email_language    IN   varchar2 := null,
     x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
     ) IS


	g_ItemType     Varchar2(10) := 'ASOQOTWF';
	g_processName  Varchar2(30) := 'PROCESSMAP';


 	l_adhoc_user  WF_USERS.NAME%TYPE;
 	l_item_key    WF_ITEMS.ITEM_KEY%TYPE;
 	l_item_owner  WF_USERS.NAME%TYPE := 'SYSADMIN';

 	l_partyId               Number;

 	l_notifEnabled  Varchar2(3) := 'Y';
	l_notifName     Varchar2(30) := 'ASOQOTPUBLISHREG';
 	l_OrgId         Number := null;
 	l_UserType      Varchar2(30) := 'ALL';
    l_msite_id      Number := null;

    l_messageName   WF_MESSAGES.NAME%TYPE;
   	l_msgEnabled    VARCHAR2(3) :='Y';

	l_resource_id   number;
	l_first_name    JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE;
	l_last_name     JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE;
    l_email_id      JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE;
	l_full_name     Varchar2(360);

    l_quoteSourceSatusId     Number := null;
    l_quoteDestStatusId      Number := null;


-- bug: 4650509 -- select person_party_id instead of customer_id
	Cursor C_login_User(c_login_name VARCHAR2) IS
	Select USR.person_party_id Name
	From   FND_USER USR
	Where  USR.EMPLOYEE_ID     is null
	and    user_name = c_login_name;

    Cursor C_Name_form_ResourceId(c_resource_id number)IS
    Select SOURCE_FIRST_NAME, SOURCE_LAST_NAME, SOURCE_EMAIL
    From   JTF_RS_RESOURCE_EXTNS
    Where  RESOURCE_ID = c_resource_id;

	l_debug                     VARCHAR2(1);

     -- bug 5221658
     l_display_name varchar2(360);
     l_description varchar2(1000);
     l_start date;
     l_end   date;
     l_fax   varchar2(200);
     l_orig_system varchar2(30);
     l_orig_system_id number;
     l_partition  number;
     l_last_updated_by number;
     l_last_update_date date;
     l_last_update_login number;
     wf_parameters wf_parameter_list_t;

     Cursor c_get_role_details(c_role_name varchar2) is
     Select display_name, description, start_date, expiration_date,
            fax,orig_system, orig_system_id, partition_id ,last_updated_by,
            last_update_date, last_update_login
     From wf_local_roles
     Where name= c_role_name;

BEGIN
	l_debug := ASO_QUOTE_UTIL_PVT.is_debug_enabled;
     IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Enable_Debug_Pvt;
	END IF;

    IF l_debug = 'Y' THEN
	    ASO_QUOTE_UTIL_PVT.Debug('API NotifyUserForRegistration started');
    END IF;

    x_return_status :=  FND_API.g_ret_sts_success;

        -- check istore lookup to find message name for quoting
        FOR c_wf_notifications In c_istore_lookup(l_notifName) LOOP
          g_ItemType := 'IBEALERT';
        END LOOP;

	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Check if this notification is enabled.');
	   END IF;

        l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('NotifyUserForRegistration : Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
		   ASO_QUOTE_UTIL_PVT.Debug('NotifyUserForRegistration : p_send_name '||upper(p_send_name));
	   END IF;

        If l_notifEnabled = 'Y' Then
        	 l_adhoc_user := upper(p_send_name);

  		FOR c_rec IN c_login_user(l_adhoc_user) LOOP
            l_adhoc_user := 'HZ_PARTY:'||c_rec.Name;
            l_partyId    := c_rec.Name;
        END LOOP;

      	/* l_orgId := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)); */ --Commented Code  Yogeshwar (MOAC)

	--New Code Start Yogeshwar (MOAC)
	FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
	    l_resource_id := c_quote_rec.resource_id;
	    l_msite_id := c_quote_rec.minisite_id;
	    l_orgid := c_quote_rec.org_id;
	END LOOP ;
       -- New Code End (MOAC)

	getUserType(l_partyId,l_UserType);

	  IF l_debug = 'Y' THEN
		  ASO_QUOTE_UTIL_PVT.Debug('Get Message - Org_id: '||to_char(l_orgId) ||' User Type: '||l_userType);
	  END IF;

        FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
			l_resource_id := c_quote_rec.resource_id;
            l_msite_id := c_quote_rec.minisite_id;
		END LOOP;

 		FOR c_jtf_rs_rec In C_Name_form_ResourceId(l_resource_id) LOOP
			l_first_name :=  c_jtf_rs_rec.source_first_name;
			l_last_name  :=  c_jtf_rs_rec.source_last_name;
            l_email_id   :=  c_jtf_rs_rec.source_email;
		END LOOP;
		l_full_name := l_last_name || ', ' || l_first_name;


	 IF l_debug = 'Y' THEN
		 ASO_QUOTE_UTIL_PVT.Debug('Calling Mapping api...'|| 'Org_id :' || l_OrgId);
	 END IF;

   if( g_ItemType = 'IBEALERT') Then

     IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
         p_org_id           => l_OrgId,
         p_msite_id         => l_msite_id,
         p_user_type        => l_UserType,
         p_notif_name       => l_notifName,
         x_enabled_flag     => l_msgEnabled,
         x_wf_message_name  => l_MessageName,
         x_return_status    => x_return_status,
         x_msg_data         => x_msg_data,
         x_msg_count        => x_msg_count);

      ELSE
        l_MessageName := l_notifName;

      END IF;


	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
	END IF;

        if( x_return_status= FND_API.G_RET_STS_ERROR ) then
	       raise FND_API.G_EXC_ERROR;
        elsif( x_return_status= FND_API.G_RET_STS_UNEXP_ERROR ) then
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        -- bug 5221658, setting the notification preference and e-mail so the
	   -- the new fnd user created gets the notification by e-mail

       open c_get_role_details(l_adhoc_user);
       fetch c_get_role_details into l_display_name, l_description ,
                                     l_start, l_end,l_fax,
                                     l_orig_system, l_orig_system_id, l_partition, l_last_updated_by,
                                     l_last_update_date, l_last_update_login;
       close c_get_role_details;

	   IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Printing the details for the role: '||l_adhoc_user);
		ASO_QUOTE_UTIL_PVT.Debug('l_display_name : '||l_display_name);
		ASO_QUOTE_UTIL_PVT.Debug('l_description : '||l_description);
		ASO_QUOTE_UTIL_PVT.Debug('l_start : '||l_start);
		ASO_QUOTE_UTIL_PVT.Debug('l_end : '||l_end);
		ASO_QUOTE_UTIL_PVT.Debug('l_fax : '||l_fax);
		ASO_QUOTE_UTIL_PVT.Debug('l_orig_system : '||l_orig_system);
		ASO_QUOTE_UTIL_PVT.Debug('l_orig_system_id : '||l_orig_system_id);
		ASO_QUOTE_UTIL_PVT.Debug('l_partition : '||l_partition);
		ASO_QUOTE_UTIL_PVT.Debug('l_last_updated_by : '||l_last_updated_by);
		ASO_QUOTE_UTIL_PVT.Debug('l_last_update_date : '||l_last_update_date);
		ASO_QUOTE_UTIL_PVT.Debug('l_last_update_login : '||l_last_update_login);
		ASO_QUOTE_UTIL_PVT.Debug('p_email_address : '||p_email_address);
	   END IF;


       wf_parameters := NULL;
       wf_event.AddParameterToList('USER_NAME',
                              l_adhoc_user, wf_parameters);
       wf_event.AddParameterToList('DISPLAYNAME',
                              l_display_name, wf_parameters);
       wf_event.AddParameterToList('DESCRIPTION',
                              l_description, wf_parameters);
       wf_event.AddParameterToList('RAISEERRORS',
                              'TRUE', wf_parameters);
       wf_event.AddParameterToList('ORCLWORKFLOWNOTIFICATIONPREF',
                              'MAILHTML', wf_parameters);
       wf_event.AddParameterToList('MAIL',
                               nvl(p_email_address,l_email_id), wf_parameters);
       wf_event.AddParameterToList('FACSIMILETELEPHONENUMBER',
                               l_fax, wf_parameters);
       wf_event.AddParameterToList('LAST_UPDATED_BY',l_last_updated_by,wf_parameters);
       wf_event.AddParameterToList('LAST_UPDATE_DATE',
                              l_last_update_date,wf_parameters);
       wf_event.AddParameterToList('LAST_UPDATE_LOGIN',l_last_update_login
                              ,wf_parameters);

       /* Commented as per code change for Bug 8711723
	  IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Before Calling propagate_role API');
	  END IF;


       wf_local_synch.propagate_role(p_orig_system     =>l_orig_system,
                                     p_orig_system_id  =>l_orig_system_id,
                                     p_attributes      => wf_parameters,
                                     p_start_date      =>l_start,
                                     p_expiration_date =>l_end);
        */

         /*** Code change start for Bug 8711723 ***/

	 IF l_debug = 'Y' THEN
	    ASO_QUOTE_UTIL_PVT.Debug('NotifyUserForRegistration :Bug : 8711723 , Before Calling propagate_user API 1');
	 END IF;

	 wf_local_synch.propagate_user(p_orig_system     =>l_orig_system,
                                       p_orig_system_id  =>l_orig_system_id,
                                       p_attributes      => wf_parameters,
                                       p_start_date      =>l_start,
                                       p_expiration_date =>l_end);

	 /*** Code change end for Bug 8711723 ***/

	  IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('After Calling propagate_role API');
	  END IF;

      -- end bug 5221658

            If l_msgEnabled = 'Y' Then

         l_item_key := l_notifName||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_send_name;

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Create and Start Process with Item Key: '||l_item_key);
	END IF;

  		wf_engine.CreateProcess(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		process   => g_processName);

  		wf_engine.SetItemUserKey(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		userkey  	=> l_item_key);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	=> 'MESSAGE',
   		avalue  	=> l_MessageName);

  		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	=> 'SENDTO',
   		avalue  	=> l_adhoc_user);

          wf_engine.SetItemAttrText(
		itemtype  => g_ItemType,
		itemkey   => l_item_key,
		aname  	=> 'SALESREP_F_NAME',
		avalue => l_first_name);

          wf_engine.SetItemAttrText(
		itemtype  => g_ItemType,
		itemkey   => l_item_key,
		aname     => 'SALESREP_L_NAME',
		avalue    => l_last_name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'SALESREP_EMAIL_ID',
   		avalue    => l_email_id );

   		wf_engine.SetItemAttrText(
   		itemtype   => g_ItemType,
   		itemkey    => l_item_key,
   		aname  	   => 'QUOTEID',
   		avalue     => p_quote_id);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'USERID',
   		avalue    => p_Send_Name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'PASSWORD',
   		avalue    => p_FND_Password);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'MSITE_RESP_ID',
   		avalue    => p_Store_Name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'SPECIALITY_STORE_WEBSITE',
   		avalue    => p_Store_Website);

   		wf_engine.SetItemOwner(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		owner     => l_item_owner);

   		wf_engine.StartProcess(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key);

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Process Started');
	END IF;

   End If;
 End If;

 IF l_debug = 'Y' THEN
	ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
 END IF;

Exception

 When OTHERS Then
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;

 wf_core.context('ASO_IBE_INT', 'NotifyUserForRegistration', p_send_name);
 raise;

 IF l_debug = 'Y' THEN
	ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
 END IF;

END NotifyUserForRegistration;



--   API Name:  NotifyForQuotePublish
--   Type    :  Public
--   Pre-Req :  Workflow template for the notification should be there in the DB


PROCEDURE NotifyForQuotePublish(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_quote_id          IN   NUMBER,
     p_Send_Name         IN   Varchar2,
     p_Comments          IN   Varchar2,
     p_Store_Name        IN   Varchar2,
     p_Store_Website     IN   Varchar2,
     p_url               IN   Varchar2,
     x_return_status     OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
     x_msg_count         OUT NOCOPY /* file.sql.39 change */    NUMBER,
     x_msg_data          OUT NOCOPY /* file.sql.39 change */    VARCHAR2
     ) IS


	g_ItemType     Varchar2(10) := 'ASOQOTWF';
	g_processName  Varchar2(30) := 'PROCESSMAP';


 	l_adhoc_user  WF_USERS.NAME%TYPE;
 	l_item_key    WF_ITEMS.ITEM_KEY%TYPE;
 	l_item_owner  WF_USERS.NAME%TYPE := 'SYSADMIN';

 	l_partyId               Number;

 	l_notifEnabled  Varchar2(3) := 'Y';
	l_notifName      Varchar2(30) := '';
 	l_OrgId         Number := null;
 	l_UserType      Varchar2(30) := 'ALL';
    l_msite_id      Number := null;

    l_messageName   WF_MESSAGES.NAME%TYPE;
   	l_msgEnabled    VARCHAR2(3) :='Y';

	l_resource_id   number;
	l_first_name    JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE;
	l_last_name     JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE;
    l_email_id      JTF_RS_RESOURCE_EXTNS.SOURCE_EMAIL%TYPE;
	l_full_name     Varchar2(360);
    l_cart_name     varchar2(80);

    l_quoteSourceSatusId     Number := null;
    l_quoteDestStatusId      Number := null;

    l_sales_adhoc_user  WF_USERS.NAME%TYPE;
    l_sales_adhoc_user_display WF_USERS.DISPLAY_NAME%TYPE;
    l_nls_language WF_LANGUAGES.NLS_LANGUAGE%TYPE := 'AMERICAN';

    l_notification_preference VARCHAR(100);
    l_role_users VARCHAR(800);
    l_sales_adhoc_role  WF_ROLES.NAME%TYPE;
    l_sales_adhoc_role_display WF_ROLES.DISPLAY_NAME%TYPE;
--bug: 4650509 -- select person_party_id instead of customer_id
	Cursor C_login_User(c_login_name VARCHAR2) IS
       -- Select USR.person_party_id Name
	Select USR.customer_id Name     -- Bug 18057349
	From   FND_USER USR
	Where  USR.EMPLOYEE_ID     is null
	and    user_name = c_login_name;

    Cursor C_Name_form_ResourceId(c_resource_id number)IS
    Select SOURCE_FIRST_NAME, SOURCE_LAST_NAME, SOURCE_EMAIL
    From   JTF_RS_RESOURCE_EXTNS
    Where  RESOURCE_ID = c_resource_id;

    Cursor C_nls_language IS
    select nls_language from wf_languages
    where code = USERENV('LANG');

   l_debug                     VARCHAR2(1);

     -- bug 5221658
     l_display_name varchar2(360);
     l_description varchar2(1000);
     l_start date;
     l_end   date;
     l_fax   varchar2(200);
     l_orig_system varchar2(30);
     l_orig_system_id number;
     l_partition  number;
     l_last_updated_by number;
     l_last_update_date date;
     l_last_update_login number;
     wf_parameters wf_parameter_list_t;

     Cursor c_get_role_details(c_role_name varchar2) is
     Select display_name, description, start_date, expiration_date,
            fax,orig_system, orig_system_id, partition_id ,last_updated_by,
            last_update_date, last_update_login
     From wf_local_roles
     Where name= c_role_name;

BEGIN
    l_debug := ASO_QUOTE_UTIL_PVT.is_debug_enabled;
	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Enable_Debug_Pvt;
	    ASO_QUOTE_UTIL_PVT.Debug('NotifyForQuotePublish : Begin');
	END IF;

    x_return_status :=  FND_API.g_ret_sts_success;


    FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
	    l_quoteSourceSatusId := c_quote_rec.quote_status_id;
    END LOOP;

    FOR c_quote_statuses_rec In c_quote_statuses('ORDER SUBMITTED') LOOP
		l_quoteDestStatusId := c_quote_statuses_rec.quote_status_id;
	END LOOP;

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('SOURCE Status done');
	END IF;

        ASO_VALIDATE_PVT.Validate_Status_Transition(
            p_init_msg_list     => FND_API.G_FALSE,
            p_source_status_id  => l_quoteSourceSatusId,
            p_dest_status_id    => l_quoteDestStatusId,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data);

    IF l_debug = 'Y' THEN
	    ASO_QUOTE_UTIL_PVT.Debug('Calling Validate_Status_Transition done ' || x_return_status );
    END IF;

        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            l_notifName := 'ASOQOTPUBLISHEXEC';
        ELSE
            l_notifName := 'ASOQOTPUBLISHUNEXEC';
            FND_MSG_PUB.initialize;
        END IF;

        -- reset return status code
        x_return_status :=  FND_API.g_ret_sts_success;

        -- check istore lookup to find message name for quoting
        FOR c_wf_notifications In c_istore_lookup(l_notifName) LOOP
          g_ItemType := 'IBEALERT';
        END LOOP;


	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Check if this notification is enabled.');
	   END IF;

        l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('NotifyForQuotePublish:Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
		   ASO_QUOTE_UTIL_PVT.Debug('NotifyForQuotePublish: p_send_name '||p_send_name);
	   END IF;



        If l_notifEnabled = 'Y' Then
        	 l_adhoc_user := upper(p_send_name);

  		FOR c_rec IN c_login_user(l_adhoc_user) LOOP
            l_adhoc_user := 'HZ_PARTY:'||c_rec.Name;
            l_partyId    := c_rec.Name;
        END LOOP;

      	/* l_orgId := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),1,10)); */ --Commented Code Yogeshwar (MOAC)
	--New Code Start yogeshwar (MOAC)
	FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
	    l_resource_id := c_quote_rec.resource_id;
	    l_msite_id := c_quote_rec.minisite_id;
	    l_orgid := c_quote_rec.org_id;
	END LOOP;
       --New Code End Yogeshwar (MOAC)

	getUserType(l_partyId,l_UserType);

	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Get Message - Org_id: '||to_char(l_orgId) ||' User Type: '||l_userType);
	   END IF;

        FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
			l_resource_id := c_quote_rec.resource_id;
            l_msite_id := c_quote_rec.minisite_id;
		END LOOP;

 		FOR c_jtf_rs_rec In C_Name_form_ResourceId(l_resource_id) LOOP
			l_first_name :=  c_jtf_rs_rec.source_first_name;
			l_last_name  :=  c_jtf_rs_rec.source_last_name;
            l_email_id   :=  c_jtf_rs_rec.source_email;
		END LOOP;
		l_full_name := l_last_name || ', ' || l_first_name;

        FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
            l_cart_name := c_quote_rec.quote_name;
        END LOOP;

	  IF l_debug = 'Y' THEN
		  ASO_QUOTE_UTIL_PVT.Debug('Calling Mapping api...'|| 'Org_id :' || l_OrgId);
	  END IF;


       -- get env language
       for c_language_rec In C_nls_language LOOP
          l_nls_language := c_language_rec.nls_language;
       end loop;


   if( g_ItemType = 'IBEALERT') Then

     IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
         p_org_id           => l_OrgId,
         p_msite_id         => l_msite_id,
         p_user_type        => l_UserType,
         p_notif_name       => l_notifName,
         x_enabled_flag     => l_msgEnabled,
         x_wf_message_name  => l_MessageName,
         x_return_status    => x_return_status,
         x_msg_data         => x_msg_data,
         x_msg_count        => x_msg_count);

      ELSE
        l_MessageName := l_notifName;

      END IF;


	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
	END IF;

        if( x_return_status= FND_API.G_RET_STS_ERROR ) then
	       raise FND_API.G_EXC_ERROR;
        elsif( x_return_status= FND_API.G_RET_STS_UNEXP_ERROR ) then
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;

        If l_msgEnabled = 'Y' Then

       -- bug 2107290 # code Start
	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Create workflow adhoc user for Sales Rep');
	   END IF;
        l_sales_adhoc_user := 'QOTU'||to_char(sysdate,'MMDDYYHH24MISS')||'P'||p_quote_id ;
        l_sales_adhoc_user_display := 'QOTU'||to_char(sysdate,'MMDDYYHH24MISS')||'P'||p_quote_id;

        --  l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');

        l_notification_preference := 'MAILTEXT'; -- code change done for Bug Bug 18043503

	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_sales_adhoc_user : '||l_sales_adhoc_user);
		   ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_sales_adhoc_user_display : '||l_sales_adhoc_user_display);
		   ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_notification_preference : '||l_notification_preference);
		   ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_email_id : '||l_email_id);
		   ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: calling wf_directory.CreateAdHocUser ');
	   END IF;
      -- move the CreateAdHocUser Api to a local block -- skm
	  begin

        wf_directory.CreateAdHocUser(
           name                    => l_sales_adhoc_user,
           display_name            => l_sales_adhoc_user_display,
           notification_preference => l_notification_preference,
           email_address           => l_email_id,
           expiration_date         => sysdate + 1,
           language                => l_nls_language);

	  IF l_debug = 'Y' THEN
		  ASO_QUOTE_UTIL_PVT.Debug('Successful creation of Ad Hoc User');
	  END IF;

       exception

	     when others then

		  IF l_debug = 'Y' THEN
			  ASO_QUOTE_UTIL_PVT.Debug ('Create Ad Hoc User failed');
		  END IF;

       end;
		IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Create workflow role user for Sales Rep');
		END IF;

         l_role_users :=  l_adhoc_user ||','||l_sales_adhoc_user;
         l_sales_adhoc_role := 'QOTR'||to_char(sysdate,'MMDDYYHH24MISS')||'P'||p_quote_id;
         l_sales_adhoc_role_display := 'QOTR'||to_char(sysdate,'MMDDYYHH24MISS')||'P'||p_quote_id;

	    IF l_debug = 'Y' THEN
		    ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_sales_adhoc_role '||l_sales_adhoc_role);
		    ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_sales_adhoc_role_display '||l_sales_adhoc_role_display);
		    ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_notification_preference '||l_notification_preference);
		    ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: l_role_users '||l_role_users);
		    ASO_QUOTE_UTIL_PVT.Debug(' NotifyForQuotePublish: calling wf_directory.CreateAdHocRole ');
	    END IF;
-- move the CreateAdHocRole api to a local block --skm
        begin

         wf_directory.CreateAdHocRole(
          role_name           => l_sales_adhoc_role,
          role_display_name   => l_sales_adhoc_role_display,
          language            => l_nls_language,
          notification_preference => l_notification_preference,
          role_users          => l_role_users,
          expiration_date     => sysdate + 1);

	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Successful creation of AdHoc Role');
	   END IF;
        exception

	     when others then

		   IF l_debug = 'Y' THEN
			   ASO_QUOTE_UTIL_PVT.Debug('CreateAdHocRole api failed');
		   END IF;

	   end;

        -- bug 2107290 # code End


         l_item_key := l_notifName||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_send_name;

	   IF l_debug = 'Y' THEN
		   ASO_QUOTE_UTIL_PVT.Debug('Create and Start Process with Item Key: '||l_item_key);
	   END IF;


  		wf_engine.CreateProcess(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		process   => g_processName);

  		wf_engine.SetItemUserKey(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		userkey  	=> l_item_key);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	  => 'MESSAGE',
   		avalue    => l_MessageName);

  		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	  => 'SENDTO',
   		avalue    => l_sales_adhoc_role);

        wf_engine.SetItemAttrText(
		itemtype  => g_ItemType,
		itemkey   => l_item_key,
		aname     => 'SALESREP_F_NAME',
		avalue    => l_first_name);

        wf_engine.SetItemAttrText(
		itemtype  => g_ItemType,
		itemkey   => l_item_key,
		aname     => 'SALESREP_L_NAME',
		avalue    => l_last_name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'SALESREP_EMAIL_ID',
   		avalue    => l_email_id );

   		wf_engine.SetItemAttrText(
   		itemtype   => g_ItemType,
   		itemkey    => l_item_key,
   		aname  	   => 'QUOTEID',
   		avalue     => p_quote_id);

   		wf_engine.SetItemAttrText(
   		itemtype   => g_ItemType,
   		itemkey    => l_item_key,
   		aname  	   => 'QUOTENAME',
   		avalue     => l_cart_name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'COMMENTS',
   		avalue    => p_Comments);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'MSITE_RESP_ID',
   		avalue    => p_Store_Name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'SPECIALITY_STORE_WEBSITE',
   		avalue    => p_Store_Website);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'URL',
   		avalue    => p_url);

   		wf_engine.SetItemOwner(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		owner     => l_item_owner);

   		wf_engine.StartProcess(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key);

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Process Started');
	END IF;

  			End If;
      	End If;

      -- bug 5221658, setting the notification preference and e-mail so the
        -- the new fnd user created gets the notification by e-mail

       open c_get_role_details(l_adhoc_user);
       fetch c_get_role_details into l_display_name, l_description ,
                                     l_start, l_end,l_fax,
                                     l_orig_system, l_orig_system_id, l_partition, l_last_updated_by,
                                     l_last_update_date, l_last_update_login;
       close c_get_role_details;

        IF l_debug = 'Y' THEN
          ASO_QUOTE_UTIL_PVT.Debug('NotifyForQuotePublish:Printing the details for the role: '||l_adhoc_user);
          ASO_QUOTE_UTIL_PVT.Debug('l_display_name : '||l_display_name);
          ASO_QUOTE_UTIL_PVT.Debug('l_description : '||l_description);
          ASO_QUOTE_UTIL_PVT.Debug('l_start : '||l_start);
          ASO_QUOTE_UTIL_PVT.Debug('l_end : '||l_end);
          ASO_QUOTE_UTIL_PVT.Debug('l_fax : '||l_fax);
          ASO_QUOTE_UTIL_PVT.Debug('l_orig_system : '||l_orig_system);
          ASO_QUOTE_UTIL_PVT.Debug('l_orig_system_id : '||l_orig_system_id);
          ASO_QUOTE_UTIL_PVT.Debug('l_partition : '||l_partition);
          ASO_QUOTE_UTIL_PVT.Debug('l_last_updated_by : '||l_last_updated_by);
          ASO_QUOTE_UTIL_PVT.Debug('l_last_update_date : '||l_last_update_date);
          ASO_QUOTE_UTIL_PVT.Debug('l_last_update_login : '||l_last_update_login);
        END IF;


       fnd_preference.put(upper(p_send_name),'WF','MAILTYPE','MAILTEXT');  -- code change done for Bug 18043503

       wf_parameters := NULL;
       wf_event.AddParameterToList('USER_NAME',
                              l_adhoc_user, wf_parameters);
       wf_event.AddParameterToList('DISPLAYNAME',
                              l_display_name, wf_parameters);
       wf_event.AddParameterToList('DESCRIPTION',
                              l_description, wf_parameters);
       wf_event.AddParameterToList('RAISEERRORS',
                              'TRUE', wf_parameters);
       wf_event.AddParameterToList('ORCLWORKFLOWNOTIFICATIONPREF',
                              'MAILHTML', wf_parameters);
       wf_event.AddParameterToList('FACSIMILETELEPHONENUMBER',
                               l_fax, wf_parameters);
       wf_event.AddParameterToList('LAST_UPDATED_BY',l_last_updated_by,wf_parameters);
       wf_event.AddParameterToList('LAST_UPDATE_DATE',
                              l_last_update_date,wf_parameters);
       wf_event.AddParameterToList('LAST_UPDATE_LOGIN',l_last_update_login
                              ,wf_parameters);

       /* Commented as per code change for Bug 8711723
       IF l_debug = 'Y' THEN
          ASO_QUOTE_UTIL_PVT.Debug('Before Calling propagate_role API');
       END IF;

       wf_local_synch.propagate_role(p_orig_system     =>l_orig_system,
                                     p_orig_system_id  =>l_orig_system_id,
                                     p_attributes      => wf_parameters,
                                     p_start_date      =>l_start,
                                     p_expiration_date =>l_end);
       */

       /*** Code change start for Bug 8711723 ***/
       IF l_debug = 'Y' THEN
	     ASO_QUOTE_UTIL_PVT.Debug('Bug : 8711723 , Before Calling propagate_user API 2');
       END IF;

       wf_local_synch.propagate_user(p_orig_system     =>l_orig_system,
                                     p_orig_system_id  =>l_orig_system_id,
                                     p_attributes      => wf_parameters,
                                     p_start_date      =>l_start,
                                     p_expiration_date =>l_end);
       /*** Code change end for Bug 8711723 ***/

       IF l_debug = 'Y' THEN
          ASO_QUOTE_UTIL_PVT.Debug('After Calling propagate_role API');
       END IF;

      -- end bug 5221658





	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
	END IF;
Exception

 When OTHERS Then


  IF l_debug = 'Y' THEN
	  ASO_QUOTE_UTIL_PVT.Debug('Error in NotifiyForQuotePublish');
  END IF;

  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;

 wf_core.context('ASO_IBE_INT', 'NotifyForQuotePublish', p_send_name);
 raise;

-- ASO_Quote_Util_Pvt.Disable_Debug_Pvt;
  IF l_debug = 'Y' THEN
	ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
  END IF;

END NotifyForQuotePublish;


--   API Name:  GetFirstName
--   Type    :  Public
--   Pre-Req :  NO

PROCEDURE GetFirstName(
	document_id	IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	document_type IN OUT NOCOPY /* file.sql.39 change */  	VARCHAR2
) IS

 l_party_id 	number;
 l_first_name  varchar2(150);
 l_order_id    number;
 l_debug       varchar2(1);


Cursor c_b2b_contact(pPartyId Number) IS
Select p.party_id Person_Party_id,l.party_id contact_party_id,p.person_first_name,p.person_last_name,p.party_type
from hz_relationships l,hz_parties p
where l.party_id = pPartyId
and l.subject_id = p.party_id
and l.subject_type = 'PERSON'
and l.subject_table_name = 'HZ_PARTIES';

Begin

	FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
   		l_party_id := c_quote_rec.party_id;
 		l_order_id := c_quote_rec.order_id;
	END LOOP;

	FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
		If  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' Then
 			For c_b2b_contact_rec in c_b2b_contact(l_party_id) Loop
  				l_first_name := upper(rtrim(c_b2b_contact_rec.person_first_name));
 			End Loop;
  		Else
				l_first_name := upper(rtrim(c_hz_parties_rec.person_first_name));
   		End If;
  	END LOOP;

	document := l_first_name;
	document_type := 'text/plain';

End GetFirstName;


--   API Name:  GetLastName
--   Type    :  Public
--   Pre-Req :  No


PROCEDURE GetLastName(
	document_id    IN        VARCHAR2,
	display_type   IN        VARCHAR2,
	document       IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
	document_type  IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
) IS

	l_party_id    number;
	l_last_name  varchar2(150);
	l_order_id    number;

Cursor c_b2b_contact(pPartyId Number) IS
Select p.party_id Person_Party_id,l.party_id contact_party_id,p.person_first_name,p.person_last_name,p.party_type
from hz_relationships l,hz_parties p
where l.party_id = pPartyId
and l.subject_id = p.party_id
and l.subject_type = 'PERSON'
and l.subject_table_name = 'HZ_PARTIES';

Begin

	FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
		l_party_id := c_quote_rec.party_id;
		l_order_id := c_quote_rec.order_id;
	END LOOP;

	FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
		If  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' Then
			For c_b2b_contact_rec in c_b2b_contact(l_party_id) Loop
				l_last_name := upper(rtrim(c_b2b_contact_rec.person_last_name));
			End Loop;
		Else
			l_last_name := upper(rtrim(c_hz_parties_rec.person_last_name));
 		End If;
 	END LOOP;

	document := l_last_name;
	document_type := 'text/plain';

End GetLastName;

--   API Name:  GetTitle
--   Type    :  Public
--   Pre-Req :  No

PROCEDURE GetTitle(
document_id    IN        VARCHAR2,
display_type   IN        VARCHAR2,
document       IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
document_type  IN   OUT NOCOPY /* file.sql.39 change */    VARCHAR2
) IS

l_party_id    		number;
l_order_id    		number;
l_person_title  	HZ_PARTIES.PERSON_TITLE%TYPE;

Cursor c_b2b_contact(pPartyId Number) IS
Select p.party_id Person_Party_id,l.party_id contact_party_id,p.person_first_name,p.person_last_name,p.party_type,p.person_title
from hz_relationships l,hz_parties p
where l.party_id = pPartyId
and l.subject_id = p.party_id
and l.subject_table_name = 'HZ_PARTIES'
and l.subject_type = 'PERSON';

Begin

	FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
		l_party_id := c_quote_rec.party_id;
		l_order_id := c_quote_rec.order_id;
	END LOOP;

	FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
		If  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' Then
			For c_b2b_contact_rec in c_b2b_contact(l_party_id) Loop
				l_person_title := upper(rtrim(c_b2b_contact_rec.person_title));
			End Loop;
		Else
			l_person_title := upper(rtrim(c_hz_parties_rec.person_title));
		End If;
	END LOOP;

	document := l_person_title;
	document_type := 'text/plain';

End GetTitle;

--   API Name:  GetCartName
--   Type    :  Public
--   Pre-Req : No

PROCEDURE GetCartName(
	document_id	    IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
	document_type IN OUT NOCOPY /* file.sql.39 change */  	VARCHAR2
) IS

 l_cart_name varchar2(50);

 Begin

  FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
       l_cart_name := c_quote_rec.quote_name;
  END LOOP;

  document := l_cart_name;
  document_type := 'text/plain';

 End GetCartName;


--   API Name:  getUserType
--   Type    :  Public
--   Pre-Req :  No


Procedure getUserType(pPartyId IN Varchar2,pUserType OUT NOCOPY /* file.sql.39 change */   Varchar2) IS
  l_PartyType  Varchar2(30);
  l_UserType   Varchar2(30) := 'B2B';
BEGIN

  FOR c_hz_parties_rec IN c_hz_parties(pPartyId)  LOOP
      l_PartyType  := rtrim(c_hz_parties_rec.party_type);
  END LOOP;

  If l_PartyType = 'PERSON' Then
     l_userType  := 'B2C';
  End If;

     pUserType  :=  l_userType;

END getUserType;


--   API Name:  GetStoreName
--   Type    :  Public
--   Pre-Req :  No


PROCEDURE GetStoreName(
	document_id	    IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN  OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	document_type IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

 l_store_name varchar2(50);
 l_msite_id   varchar2(25);
 l_resp_id    varchar2(25);
 l_index      number;

Begin

 l_index := instr(document_id, '-');
 l_msite_id := SUBSTR(document_id, 1, l_index-1);
 l_resp_id := SUBSTR(document_id,l_index+1);


  FOR c_store_name In c_msite_resp_name(l_msite_id, l_resp_id) LOOP
       l_store_name := c_store_name.display_name;
  END LOOP;

  document := l_store_name;
  document_type := 'text/plain';

End GetStoreName;

/*
PROCEDURE PublishQuoteLocal(
    p_quote_header_id   IN  NUMBER,
    p_publish_flag      IN  VARCHAR2,
    p_last_update_date  IN  DATE
    ) IS


    P_Api_Version_Number        NUMBER          := 1.0;
    P_Init_Msg_List             VARCHAR2(1)     := FND_API.G_TRUE;
    P_Commit                    VARCHAR2(1)     := FND_API.G_FALSE;
    P_Validation_Level 	        NUMBER          := FND_API.G_VALID_LEVEL_FULL;

    P_Control_Rec		        ASO_QUOTE_PUB.Control_Rec_Type
                                := ASO_QUOTE_PUB.G_Miss_Control_Rec;

    P_Qte_Header_Rec		    ASO_QUOTE_PUB.Qte_Header_Rec_Type
                                := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec;

    P_hd_Price_Attributes_Tbl   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;

    P_hd_Payment_Tbl		    ASO_QUOTE_PUB.Payment_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;

    P_hd_Shipment_Tbl		    ASO_QUOTE_PUB.Shipment_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;

    P_hd_Freight_Charge_Tbl	    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
                                := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl;

    P_hd_Tax_Detail_Tbl		    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
                                := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl;

    P_hd_Attr_Ext_Tbl		    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL;

    P_hd_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;

    P_hd_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;

    P_Qte_Line_Tbl		        ASO_QUOTE_PUB.Qte_Line_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;

    P_Qte_Line_Dtl_Tbl		    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;

    P_Line_Attr_Ext_Tbl		    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_Line_Attribs_Ext_TBL;

    P_line_rltship_tbl		    ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
					            := ASO_QUOTE_PUB.G_MISS_Line_Rltship_Tbl;

    P_Price_Adjustment_Tbl	    ASO_QUOTE_PUB.Price_Adj_Tbl_Type
					            := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;

    P_Price_Adj_Attr_Tbl	    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type
                                := ASO_QUOTE_PUB.G_Miss_PRICE_ADJ_ATTR_Tbl;

    P_Price_Adj_Rltship_Tbl	    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
					            := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl;

    P_Ln_Price_Attributes_Tbl	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl;

    P_Ln_Payment_Tbl		    ASO_QUOTE_PUB.Payment_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_PAYMENT_TBL;

    P_Ln_Shipment_Tbl		    ASO_QUOTE_PUB.Shipment_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_SHIPMENT_TBL;

    P_Ln_Freight_Charge_Tbl	    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
                                := ASO_QUOTE_PUB.G_Miss_Freight_Charge_Tbl;

    P_Ln_Tax_Detail_Tbl		    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					            := ASO_QUOTE_PUB.G_Miss_Tax_Detail_Tbl;

    P_ln_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_Sales_Credit_Tbl;

    P_ln_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type
                                := ASO_QUOTE_PUB.G_MISS_Quote_Party_Tbl;

    X_Qte_Header_Rec		    ASO_QUOTE_PUB.Qte_Header_Rec_Type;

    X_Qte_Line_Tbl		        ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
    X_Qte_Line_Dtl_Tbl		    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
    X_Hd_Price_Attributes_Tbl	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    X_Hd_Payment_Tbl		    ASO_QUOTE_PUB.Payment_Tbl_Type;
    X_Hd_Shipment_Tbl		    ASO_QUOTE_PUB.Shipment_Tbl_Type;
    X_Hd_Freight_Charge_Tbl	    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    X_Hd_Tax_Detail_Tbl		    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    X_hd_Attr_Ext_Tbl		    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    X_hd_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
    X_hd_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
    X_Line_Attr_Ext_Tbl		    ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
    X_line_rltship_tbl		    ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
    X_Price_Adjustment_Tbl	    ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
    X_Price_Adj_Attr_Tbl	    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
    X_Price_Adj_Rltship_Tbl	    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
    X_Ln_Price_Attributes_Tbl	ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
    X_Ln_Payment_Tbl		    ASO_QUOTE_PUB.Payment_Tbl_Type;
    X_Ln_Shipment_Tbl		    ASO_QUOTE_PUB.Shipment_Tbl_Type;
    X_Ln_Freight_Charge_Tbl	    ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
    X_Ln_Tax_Detail_Tbl		    ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
    X_Ln_Sales_Credit_Tbl       ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
    X_Ln_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;


	X_return_status VARCHAR2(1);
	X_msg_count NUMBER;
	X_msg_data VARCHAR2(300);



BEGIN

p_qte_header_rec.quote_header_id    := p_quote_header_id;
p_qte_header_rec.publish_flag       := p_publish_flag;
p_qte_header_rec.last_update_date   := p_last_update_date;

 ASO_QUOTE_PUB.Update_Quote(
    	P_Api_Version_Number => p_api_version_number,
    	P_Init_Msg_List => p_init_msg_list,
    	P_Commit => p_commit,
    	P_Validation_Level => p_validation_level,
        p_qte_header_rec => p_qte_header_rec,
        p_qte_line_tbl => p_qte_line_tbl,
        p_ln_shipment_tbl => p_ln_shipment_tbl,
    	X_Qte_Header_Rec => x_qte_header_rec,
    	X_Qte_Line_Tbl => x_qte_line_tbl,
    	X_Qte_Line_Dtl_Tbl => x_qte_line_dtl_tbl,
    	X_Hd_Price_Attributes_Tbl => x_hd_price_attributes_tbl,
    	X_Hd_Payment_Tbl => x_hd_payment_tbl,
    	X_Hd_Shipment_Tbl => x_hd_shipment_tbl,
    	X_Hd_Freight_Charge_Tbl => x_hd_freight_charge_tbl,
    	X_Hd_Tax_Detail_Tbl	=> x_hd_tax_detail_tbl,
    	X_hd_Attr_Ext_Tbl => x_hd_attr_ext_tbl,
    	X_hd_Sales_Credit_Tbl => x_hd_sales_credit_tbl,
    	X_hd_Quote_Party_Tbl => x_hd_quote_party_tbl,
    	X_Line_Attr_Ext_Tbl	=> x_line_attr_ext_tbl,
    	X_line_rltship_tbl	=> x_line_rltship_tbl,
    	X_Price_Adjustment_Tbl => x_price_adjustment_tbl,
    	X_Price_Adj_Attr_Tbl => x_price_adj_attr_tbl,
    	X_Price_Adj_Rltship_Tbl => x_price_adj_rltship_tbl,
    	X_Ln_Price_Attributes_Tbl => x_ln_price_attributes_tbl,
    	X_Ln_Payment_Tbl => x_ln_payment_tbl,
    	X_Ln_Shipment_Tbl => x_ln_shipment_tbl,
    	X_Ln_Freight_Charge_Tbl => x_ln_freight_charge_tbl,
    	X_Ln_Tax_Detail_Tbl => x_ln_tax_detail_tbl,
    	X_Ln_Sales_Credit_Tbl => x_ln_sales_credit_tbl,
    	X_Ln_Quote_Party_Tbl => x_ln_quote_party_tbl,
        X_return_status => x_return_status,
	    X_msg_count => x_msg_count,
	    X_msg_data => x_msg_data );


END PublishQuoteLocal;

*/

procedure createStoreUser
(
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_user_name                 IN       VARCHAR2,
    p_user_password             IN       VARCHAR2,
    p_email_address             IN       VARCHAR2 DEFAULT  NULL, /*  Add for Bug 7334453  */
    p_email_language            IN       VARCHAR2,
    p_party_id                  IN       NUMBER,
    p_party_type                IN       VARCHAR2,
    x_return_status             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */      NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'create_Store_User' ;
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    G_PKG_NAME                CONSTANT VARCHAR2(30) := 'aso_publish_misc_int';
    l_user_id                 NUMBER;
    l_lang_rec1                hz_person_info_v2pub.PERSON_LANGUAGE_REC_TYPE;
    l_lang_rec2                hz_person_info_v2pub.PERSON_LANGUAGE_REC_TYPE;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(240);
    l_date                    DATE;
    l_id 		              NUMBER;
    l_object_version_number   NUMBER;
    l_ref_id                  NUMBER;
    l_person_party_id         NUMBER;
    l_debug                   VARCHAR2(1);

    Cursor  C_Lang1  (l_party_id number) is
    SELECT language_use_reference_id, object_version_number
    FROM   hz_person_language
    WHERE  party_id=l_party_id and primary_language_indicator='Y';

    Cursor  C_Lang2  (l_party_id number, l_language_name varchar2) is
    SELECT language_use_reference_id, object_version_number
    FROM   hz_person_language
    WHERE  party_id=l_party_id
    AND    language_name=l_language_name
    AND   nvl(status,'A') = 'A';

	Cursor C_B2b_Contact(l_party_id Number) IS
    Select p.party_id Person_Party_id
    from hz_relationships l,hz_parties p
    where l.party_id = l_party_id
    and l.subject_id = p.party_id
    and l.subject_table_name = 'HZ_PARTIES'
    and l.subject_type = 'PERSON';

BEGIN
	l_debug := ASO_QUOTE_UTIL_PVT.is_debug_enabled;
	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Enable_Debug_Pvt;
	END IF;
    -- Standard Start of API savepoint
    SAVEPOINT create_Store_User_int;
    IF l_debug = 'Y' THEN

        ASO_QUOTE_UTIL_PVT.Debug('aso_publish_misc_int: createStoreUser: Start %%%%%%%%%%%%%%%%%%%');

        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser: p_user_name: '|| p_user_name);
        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser: p_user_password:  '|| p_user_password);
        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser: p_email_Address: '|| p_email_address);
        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser: p_email_language: '|| p_email_language);
        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser: p_party_id:    '|| p_party_id);
        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser: p_party_type: '|| p_party_type);

    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Set return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --//////////////////////////////////////////////////////////////////////////
    -- create user id with supplied password
    l_user_id := fnd_user_pkg.CreateUserId (
        x_user_name => p_user_name,
        x_owner => null,
	  x_unencrypted_password => p_user_password,
        x_email_address => p_email_address,  /*  Add for Bug 7334453  */
        x_customer_id => p_party_id );

	ASO_QUOTE_UTIL_PVT.Debug('createStoreUser : after calling fnd_user_pkg.CreateUserId, l_user_id : '||l_user_id);

	fnd_preference.put(p_user_name,'WF','MAILTYPE','MAILTEXT');  -- code change done for Bug 18043503

	ASO_QUOTE_UTIL_PVT.Debug('createStoreUser new : after calling fnd_user_pkg.CreateUserId, set the preference to MAILTEXT');

    --update cutomer id
   /* UPDATE FND_USER
    SET CUSTOMER_ID = p_party_id
    WHERE USER_NAME = p_user_name;
   */

   ASO_QUOTE_UTIL_PVT.Debug('createStoreUser : calling JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_DEF_ROLES for assign roles, p_user_name : '||p_user_name);
   ASO_QUOTE_UTIL_PVT.Debug('createStoreUser : calling JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_DEF_ROLES for assign roles, p_party_type : '||p_party_type);

    -- assign roles
    JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_DEF_ROLES(
      P_USERNAME    =>  p_user_name,
      P_ACCOUNT_TYPE => p_party_type );

    -- assign resp
    JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_DEF_RESP(
      P_USERNAME => p_user_name,
      P_ACCOUNT_TYPE => p_party_type );

    -- CHANGE LANGUAGE PERF

    BEGIN
    --  unset primary language indicator
     l_person_party_id := p_party_id;

     open C_B2b_Contact(p_party_id);
     fetch  C_B2b_Contact INTO l_person_party_id;
     close C_B2b_Contact;

     open C_Lang1(l_person_party_id);
     fetch C_Lang1  INTO   l_id, l_object_version_number;
     close C_Lang1;

    l_lang_rec1.primary_language_indicator := 'N';
    l_lang_rec1.language_use_reference_id := l_id;


  if (l_debug = 'Y') then


        ASO_QUOTE_UTIL_PVT.Debug('Primary Language Indicator '|| l_lang_rec1.primary_language_indicator);

        ASO_QUOTE_UTIL_PVT.Debug('Language use reference id '|| to_char(l_lang_rec1.language_use_reference_id));

   end if;


    hz_person_info_v2pub.update_person_language(
            p_init_msg_list       => FND_API.G_FALSE,
            p_person_language_rec => l_lang_rec1,
            p_object_version_number => l_object_version_number,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);

  if (l_debug = 'Y') then

        ASO_QUOTE_UTIL_PVT.Debug('successful completion of hz_person_info_v2pub.update_person_language - unset Primary Language Indicator');

 end if;
    -- set primary language indicator

     open C_Lang2(l_person_party_id, p_email_language);

     fetch C_Lang2   INTO   l_id, l_object_version_number;

     if(C_Lang2%NOTFOUND) THEN

        l_lang_rec2.primary_language_indicator := 'Y';
        l_lang_rec2.party_id := l_person_party_id;
        l_lang_rec2.language_name := p_email_language;
	   -- Set Created_by_module as SALES in uppercase - skm
        l_lang_rec2.created_by_module := 'SALES';

        if (l_debug = 'Y') then


        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser : Primary Language Indicator '|| l_lang_rec2.primary_language_indicator);

        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser:party_id '|| to_char(l_lang_rec2.party_id));

        ASO_QUOTE_UTIL_PVT.Debug('createStoreUser:language_name '||l_lang_rec2.language_name);

       end if;
        hz_person_info_v2pub.create_person_language(
             p_person_language_rec => l_lang_rec2,
             x_language_use_reference_id => l_ref_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

       if (l_debug = 'Y') then


        ASO_QUOTE_UTIL_PVT.Debug('successful completion of hz_person_info_v2pub.create_person_language');

       end if;

	 ELSE

      l_lang_rec2.primary_language_indicator := 'Y';
      l_lang_rec2.language_use_reference_id := l_id;

       if (l_debug = 'Y') then

        ASO_QUOTE_UTIL_PVT.Debug('Primary Language Indicator '||l_lang_rec2.primary_language_indicator);
        ASO_QUOTE_UTIL_PVT.Debug('Language Use Reference Id '||to_char(l_lang_rec2.language_use_reference_id));

	 end if;

	hz_person_info_v2pub.update_person_language(
            p_person_language_rec => l_lang_rec2,
            p_object_version_number => l_object_version_number,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);
      END IF;

     close C_Lang2;

      EXCEPTION

	WHEN others then

	   FND_MSG_PUB.count_and_get(
	   p_encoded => FND_API.G_FALSE,
	   p_count => x_msg_count,
	   p_data => x_msg_data);

	   if (l_debug = 'Y') then


        ASO_QUOTE_UTIL_PVT.Debug('Error in iStore User Creation');

	   end if;
    end;

    IF l_debug = 'Y' THEN
      ASO_QUOTE_UTIL_PVT.Debug ('End  create_Store_User_int  procedure');
    	ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;

    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      IF l_debug = 'Y' THEN
        ASO_QUOTE_UTIL_PVT.Debug ('Exception  FND_API.G_EXC_ERROR  in createStoreUser');
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
	END IF;

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      IF l_debug = 'Y' THEN
        ASO_QUOTE_UTIL_PVT.Debug ('Exception  FND_API.G_EXC_UNEXPECTED_ERROR in createStoreUser ');
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
	END IF;

    WHEN OTHERS
    THEN
      IF l_debug = 'Y' THEN
        ASO_QUOTE_UTIL_PVT.Debug ('When Others Exception in createStoreUser ');
      END IF;
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_int,
        p_sqlcode                    => SQLCODE,
        p_sqlerrm                    => SQLERRM,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );

END createStoreUser;

PROCEDURE TestUserName(
        p_user_name IN VARCHAR2,
        x_test_user_status OUT NOCOPY VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
        )
IS
        l_api_version_number CONSTANT NUMBER := 1.0;
        l_api_name CONSTANT VARCHAR2(30) := 'TestUserName' ;
	   l_debug                     VARCHAR2(1);
BEGIN

	l_debug := ASO_QUOTE_UTIL_PVT.is_debug_enabled;
	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Enable_Debug_Pvt;
	END IF;

	x_return_status := Fnd_Api.g_ret_sts_success;

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('Calling FND_USER_PKG.TestUserName');
		ASO_QUOTE_UTIL_PVT.Debug('p_user_name '||p_user_name);
	END IF;

	x_test_user_status := Fnd_User_Pkg.TestUserName(p_user_name);

	x_msg_data := fnd_message.get;

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Debug('x_test_user_status '||x_test_user_status);
		ASO_QUOTE_UTIL_PVT.Debug('Successful completion of TestUserName');
		ASO_QUOTE_UTIL_PVT.Debug('Return Status '||x_return_status);
		ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
	END IF;

EXCEPTION

        WHEN OTHERS THEN
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
    Aso_Utility_Pvt.HANDLE_EXCEPTIONS(
            P_API_NAME => l_api_name
           ,P_PKG_NAME => 'ASO_PUBLISH_MISC_INT'
           ,P_EXCEPTION_LEVEL => Aso_Utility_Pvt.G_EXC_OTHERS
           ,P_PACKAGE_TYPE => Aso_Utility_Pvt.G_PUB
           ,X_MSG_COUNT => X_MSG_COUNT
           ,X_MSG_DATA => X_MSG_DATA
           ,X_RETURN_STATUS => X_RETURN_STATUS
        );

	IF l_debug = 'Y' THEN
		ASO_QUOTE_UTIL_PVT.Disable_Debug_Pvt;
	END IF;

END TestUserName;


END aso_publish_misc_int;

/
