--------------------------------------------------------
--  DDL for Package Body IEX_UWQ_SEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_UWQ_SEL_PKG" AS
/* $Header: iextmslb.pls 120.1.12010000.2 2009/01/05 13:20:41 pnaveenk noship $ */


PROCEDURE LogMessage(l_Message varchar2) IS
BEGIN
  if (l_DumpData = 'Y') then
     ast_debug_pub.LogMessage(l_Message, -10, 'Y');
  end if;
END;

PROCEDURE setDefaults IS
BEGIN

   l_eventName         := NULL;
   l_partyId           := 0;
   l_partyType         := NULL;
   l_customerNumber    := 0;
   l_contactId         := 0;
   l_contactNumber     := 0;
   l_eventConfCode     := NULL;
   l_eventId           := 0;
   l_collateralReqNum  := NULL;
   l_collateralId      := 0;
   l_campaignCode      := NULL;
   l_campaignId        := 0;
   l_dnis              := NULL;
   l_callId            := NULL;
   l_ani               := NULL;
   l_accountcode       := 0;
   l_usage             := NULL;
   l_agentID           := NULL;
   l_mediaType         := NULL;
   l_mediaItemID       := NULL;
   l_workitemID        := NULL;
   l_sendername        := NULL;
   l_subject           := NULL;
   l_messageID         := NULL;
   l_MoreAniMatch      := 'N';

END setDefaults;

-- private package to return the param type  value
PROCEDURE   getCallData(p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST) IS
BEGIN

   FOR i IN 1 .. p_mediaTable.COUNT LOOP

	     if ( upper(p_mediaTable(i).param_name) = 'OCCTEVENTNAME' ) then

	         l_eventname := p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) =  'IEU_AMS_CAMPAIGN_ID' ) then

	         l_CampaignID := p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CustomerID' ) THEN

	         l_partyID :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CustomerNumber' ) then

		    l_customerNumber  :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CUSTOMERID' ) THEN

	         l_partyID :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CUSTOMERNUM' ) then

	         l_customerNumber :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CONTACTNUM' ) then

	         l_contactnumber :=  p_mediaTable(i).param_value;

	     ELSIF ( upper(p_mediatable(i).param_name)='EVENTCONFCODE') THEN

	         l_eventConfCode := p_mediaTable(i).param_value;

	     ELSIF ( upper(p_mediatable(i).param_name)='COLREQNUM') THEN

	         l_collateralReqNum := p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'PROMOTIONCODE' ) then

	        l_campaignCode :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTDNIS' ) then

	        l_dnis :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTCALLID' ) then

	        l_callId :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTANI' ) then

	        l_ani :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'ACCOUNTCODE' ) then

	        l_accountCode :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTAGENTID' ) THEN

	        l_agentID :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTMEDIATYPE' ) THEN

	        l_mediaType :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OIEMMESSAGEID' ) THEN

	        l_messageID :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OIEMSUBJECT' ) THEN

	        l_subject :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OIEMSENDERNAME' ) THEN

	        l_sendername :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'WORKITEMID' ) THEN

	        l_workitemID :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTMEDIAITEMID' ) THEN

	        l_mediaItemID :=  p_mediaTable(i).param_value;

       elsif ( upper(p_mediaTable(i).param_name) = 'PARTY_ID' ) THEN

              l_partyId := to_number(p_mediaTable(i).param_value);

	     END IF;

   END LOOP;

END getCallData ;

-- procedure to construct the paramlist to be passed to the form

FUNCTION  constructparam RETURN VARCHAR2  IS
l_paramlist VARCHAR2(500);
BEGIN

   l_paramlist := '';
   IF ( l_partyId <> 0 ) THEN

      l_paramlist := l_paramlist  || 'PARTY_ID' || '="' || l_partyId ||'" ';

   END IF;

   IF ( l_partyType is not NULL) then
      l_paramlist := l_paramlist || 'PARTY_TYPE' || '="' || l_partyType || '" ';
   END IF;

   IF ( l_contactid <> 0 )  THEN

       l_paramlist := l_paramlist  || 'PARTY_CONTACT_ID' || '="' || l_contactId ||'" ';

   END IF;

   IF ( l_eventid <> 0 ) THEN

       l_paramlist := l_paramlist  || 'EVENT_REG_ID' || '="' || l_eventId ||'" ';

   END IF;

   IF ( l_collateralId <> 0 ) THEN

       l_paramlist := l_paramlist  || 'COLL_REQ_ID' || '="' || l_collateralId ||'" ';

   END IF;

   IF (l_campaignId <> 0 ) THEN

      l_paramlist := l_paramlist  || 'CAMPAIGN_ID' || '="' || l_campaignId ||'" ';

   END IF;

   IF ( l_callId is not NULL ) THEN

      l_paramlist := l_paramlist  || 'TM_CALL_ID' || '="' || l_callID ||'" ';

   END IF;

   IF ( l_accountcode <> 0 )  THEN

       l_paramlist := l_paramlist  || 'CUST_ACCOUNT_ID' || '="' || l_accountCode ||'" ';

   END IF;

   IF ( l_eventname is not NULL )  THEN

       l_paramlist := l_paramlist  || 'UWQ_EVENTNAME' || '="' || l_eventname ||'" ';

   END IF;


   IF ( l_dnis is not NULL )  THEN

       l_paramlist := l_paramlist  || 'TM_DNIS' || '="' || l_dnis ||'" ';

   END IF;

   IF ( l_ani is not null )  THEN

       l_paramlist := l_paramlist  || 'TM_ANI' || '="' || l_ani ||'" ';

   END IF;

   IF ( l_mediaType is not null )  THEN

       l_paramlist := l_paramlist  || 'UWQ_MEDIATYPE' || '="' || l_mediatype ||'" ';

   END IF;

   IF ( l_mediaItemID is not null)  THEN

       l_paramlist := l_paramlist  || 'UWQ_MEDIAITEM_ID' || '="' || l_mediaItemID || '" ';

   END IF;

   IF ( l_workitemID is not null )  THEN

       l_paramlist := l_paramlist  || 'UWQ_WORKITEM_ID' || '="' || l_workitemID ||'" ';

   END IF;

   IF ( l_sendername is not null )  THEN

       l_paramlist := l_paramlist  || 'EM_SENDERNAME' || '="' || l_sendername ||'" ';

   END IF;

   IF ( l_subject is not null )  THEN

       l_paramlist := l_paramlist  || 'EM_SUBJECT' || '="' || l_subject ||'" ';

   END IF;

   IF ( l_messageID is not null )  THEN

       l_paramlist := l_paramlist  || 'EM_MESSAGE_ID' || '="' || l_messageID ||'" ';

   END IF;

   IF (l_MoreAniMatch = 'Y') then

	 l_Usage := 'QUERY_ANI';

   END IF;

   IF ((l_usage is null) and (l_partyId = 0)) THEN

      l_usage := 'QUERY_LKP';

   END IF;

   -- append the usage parameter
   l_paramlist := l_paramlist  || 'CALLED_FROM = "UWQ" ';

   if (l_usage is not null) then
	 l_paramlist := l_paramlist || ' USAGE' || '="' || l_usage ||'" ';
   end if;

   if (l_dumpData = 'Y') then
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_paramList);
	 FND_FILE.NEW_LINE(FND_FILE.OUTPUT, 2);
   end if;

   RETURN l_paramlist;

END constructparam;

-- procedure get details from event confirmation number
PROCEDURE getDtlsFromEvent IS

   CURSOR C_GetEventDetails(x_eventConfCode varchar2) IS
      SELECT registrant_party_Id,registrant_contact_Id,event_offer_Id
	FROM  ams_event_registrations_v
	WHERE confirmation_code = x_eventConfCode;


BEGIN

   OPEN C_GetEventDetails(l_eventConfCode);
   FETCH C_GetEventDetails INTO l_partyId, l_contactId, l_eventId;
   IF ( c_geteventdetails%NOTFOUND) THEN
      l_partyId:=0;
      l_contactid := 0;
      l_eventid := 0;
   END IF;
   CLOSE C_GetEventDetails;
END getDtlsFromEvent;

PROCEDURE getcampaigncode IS

   CURSOR c_campaignId(x_inbound_phone VARCHAR2) IS
      SELECT campaign_id
      FROM ams_campaigns_all_b
	    WHERE translate(inbound_phone_no,'0123456789()/\-. ','0123456789')=x_inbound_phone
	    AND status_code ='ACTIVE';

   CURSOR c_campaigncode(x_campaigncode VARCHAR2) IS
      SELECT campaign_id
	    FROM ams_p_campaigns_v
	    WHERE source_code = x_campaignCode
	    AND status_code ='ACTIVE';

BEGIN

   IF ( l_campaigncode IS NOT NULL ) THEN
      OPEN c_campaigncode(l_campaigncode);
      FETCH c_campaigncode INTO l_campaignid;
      IF ( c_campaigncode%found) THEN
	        CLOSE c_campaigncode;
	        RETURN;
      END IF;
      CLOSE c_campaigncode;
    ELSIF ( l_dnis IS NOT NULL ) THEN
      OPEN c_campaignid(l_dnis);
      FETCH c_campaignid INTO l_campaignid;
      IF ( c_campaignid%found) THEN
	       CLOSE c_campaignid;
	       RETURN;
      END IF;
      CLOSE c_campaignid;
    END IF;

END;

-- procedure to get the collateral request Id from a collateral request confirmation
-- number
PROCEDURE getDtlsFromColReq IS

   CURSOR C_getDtlsFromColReq(x_collateralReqNum number ) IS
      SELECT quote_header_id,party_id,cust_account_id,l_contactid
	    FROM ASO_QUOTE_HEADERS_ALL
	    WHERE quote_number = x_collateralReqNum;
BEGIN

   OPEN C_getDtlsFromColReq(To_number(l_collateralreqnum));
   FETCH C_getDtlsFromColReq INTO l_collateralId,l_partyId, l_accountCode,l_contactId;
   IF (c_getdtlsfromcolreq%Notfound )THEN
      l_collateralid := 0;
   END IF;
   CLOSE C_getDtlsFromColReq;

END getDtlsFromColReq;

-- private procedure to get the partyId

PROCEDURE GetDtlsFromConNum IS


	CURSOR C_getDtlsFromConNum(x_contactNum varchar2 ) IS
	SELECT p.party_id, p.object_id
	FROM   JTF_PARTIES_V p, jtf_party_relationships_v rel
	WHERE  p.party_number = x_contactNum ;

BEGIN
	OPEN C_getDtlsFromConNum (l_contactNumber);
	FETCH  C_getDtlsFromConNum INTO l_contactId, l_partyId ;
	CLOSE C_getDtlsFromConNum;

END GetDtlsFromConNum;


PROCEDURE GetDtlsFromCustNum IS

   CURSOR C_GetCustId(x_custnum VARCHAR2) IS
      SELECT party_id
	FROM jtf_parties_v
	WHERE party_number = x_custnum;


BEGIN
   OPEN c_getcustid(l_customernumber);
   FETCH c_getcustid INTO l_partyId;
   CLOSE c_getcustid;

END GetDtlsFromCustNum;

PROCEDURE GetDtlsFromAccountNum IS

   CURSOR C_GetCustId(x_account_num VARCHAR2) IS
      SELECT party_id
	FROM hz_cust_accounts
	WHERE account_number = x_account_num;


BEGIN
   OPEN c_getcustid(l_accountCode);
   FETCH c_getcustid INTO l_partyId;
   CLOSE c_getcustid;

END GetDtlsFromAccountNum;

PROCEDURE GetDtlsFromPhoneNum IS

	CURSOR C_getDtlsFromPhoneNum(x_phonenumber varchar2 ) IS
	SELECT party_id, party_type
	FROM   JTF_CONTACT_POINTS_V
	WHERE  phone_number = x_phonenumber ;

	CURSOR C_getDtlsFromAreaPhoneNum(x_AreaCode varchar2, x_phonenumber varchar2 ) IS
	SELECT party_id, party_type
	FROM   JTF_CONTACT_POINTS_V
	WHERE  AREA_CODE = x_AreaCode and PHONE_NUMBER = x_phonenumber;
   -- Changed for bug#7685201 by PNAVEENK on 5-1-2009
	CURSOR C_GetSubObj(p_rel_partyid number) is
	   SELECT object_id, subject_id from
		 HZ_RELATIONSHIPS WHERE PARTY_ID = p_rel_partyid
		 AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
		 AND OBJECT_TABLE_NAME = 'HZ_PARTIES'
		 AND DIRECTIONAL_FLAG = 'F';
   -- End for bug#7685201
     l_rel_partyid  number := NULL;
	l_partyIDNext  number;
	l_partyTypeNext varchar2(50);
	l_AreaCode varchar2(10);
	l_PhoneNumber varchar2(25);


BEGIN

	if length(l_ani) < 4 then
	    return;
     end if;
	if (l_PhoneAreaCodeYN = 'Y') then
		OPEN C_getDtlsFromPhoneNum (l_ani);
		FETCH  C_getDtlsFromPhoneNum INTO l_partyId, l_partyType;
		if C_getDtlsFromPhoneNum%FOUND then
			 FETCH C_getDtlsFromPhoneNum into l_partyIDNext, l_partyTypeNext;
			 IF C_GetDtlsFromPhoneNum%FOUND then
			    l_MoreAniMatch := 'Y';
			 End If;
		end if;
		CLOSE C_getDtlsFromPhoneNum;
	else

	    l_AreaCode := substr(l_ani, 1, l_AreaCodeLength);
	    l_PhoneNumber := substr(l_ani, l_AreaCodeLength+1, l_PhoneNumberLength);
	    Open C_getDtlsFromAreaPhoneNum(l_AReaCode, l_PhoneNumber);
	    fetch C_getDtlsFromAreaPhoneNum INTO l_partyId, l_partyType;
	    IF C_getDtlsFromAreaPhoneNum%FOUND then
		   FETCH C_getDtlsFromAreaPhoneNum into l_partyIDNext, l_partyTypeNext;
		   If C_GetDtlsFromAreaPhoneNum%FOUND then
			  l_MoreAniMatch := 'Y';
		   end if;
	    end if;
	    CLOSE C_getDtlsFromAreaPhoneNum;

	end if;

	if l_PartyType = 'PARTY_RELATIONSHIP' Then

	    l_Usage := 'QUERY_CON';
	    open c_GetSubObj(l_partyid);
	    fetch c_GetSubObj into l_partyID, l_ContactID;
	    if (l_MoreAniMatch <> 'Y') then
	    	 l_PartyType := 'ORGANIZATION';
	    end if;
	    close C_GetSubObj;

	elsif l_partyType = 'PERSON' then

	    l_Usage := 'QUERY_CONSUMER';

     elsif l_partyType = 'ORGANIZATION' then

         l_Usage := 'QUERY_ORG';

	end if;

END GetDtlsFromPhoneNum;


PROCEDURE handleIEXInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) is

BEGIN
/*
   insert into ast_uwq_params  values ('handleOTSBound Called ');
   commit;
*/

   --setCurrentForm('ASTTMPOP');
   p_action_type :=1;
   p_action_name := G_CurrentForm;
   p_action_param := '';

   setDefaults;
   getCallData(p_mediaTable);

   if (l_CampaignID = 0) and (l_profile = 'Y') then
	   getCampaignCode;
   end if;

   if ( l_eventConfCode is not null ) THEN

      getDtlsFromEvent;

      IF ( l_eventid <> 0 ) THEN
	        -- we found the match, hence we can query the event details
	        l_usage := 'QUERY_EVENT';

	        -- open the form using app_navigate.execute
	        p_action_param :=  constructParam;
	        return;

      END IF;
   END IF;

   if ( l_collateralReqNum is not null ) then

      getDtlsFromColReq;

      IF (l_collateralid <> 0 ) then
	         l_usage := 'QUERY_COL';
	         p_action_param :=  constructParam;
	         return;
      END IF;
   END IF;

   if ( l_AccountCode is not NULL ) then

      getDtlsFromAccountNum;
      IF ( l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_CUST';
	        p_action_param := constructparam;
	        RETURN;
      END IF;
   end if;

   if ( l_contactNumber is not NULL ) then

      getDtlsFromConNum;
      IF ( l_contactid <> 0  OR l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_CON';
	        p_action_param := constructparam;
	        RETURN;
      END IF;
   end if;

   if ( l_customerNumber is not null ) then

      getDtlsFromCustNum;
      IF (  l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_CUST';
	        p_action_param := constructparam;
	        RETURN;
      END IF;

   END IF ;

   IF (( l_partyId = 0) and (l_ani is not null )) THEN

       GetDtlsFromPhoneNum;
       p_action_param := constructparam;

   Else
       p_action_param := constructparam;
   END IF;

/*
   insert into ast_uwq_params  values ('handleOTSBound exit : Action Name: '
	    || p_action_Name || ' Action Type : '
	    || to_char(p_action_Type) || ' Action Param: '
	    || p_action_Param );
   commit;
*/

END handleIEXInbound;

PROCEDURE handleEmail (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) is

BEGIN
    handleIEXInbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
END;

PROCEDURE handleIEXOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY varchar2,
				p_action_param OUT NOCOPY varchar2) IS
BEGIN

   p_action_type :=1;
   p_action_name := G_Currentform;
   p_action_param := '';

   setDefaults;
   getCallData(p_mediaTable);
   p_action_param := constructparam;

END handleIEXOutbound ;

PROCEDURE handleOOCInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) IS

BEGIN
	setDefaults;
	getCallData(p_mediaTable);
END;

Procedure setCurrentForm(p_formName varchar2) IS
BEGIN

	G_CurrentForm := upper(p_formName);
END setCurrentForm ;

/*** begin 6197074 7/10/2007
     added by kasreeni on 15th july 2007 by coping the same code from
     from ast_uwq_sel_pkg.handleFooTask
***/

PROCEDURE   getFooData(p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST) IS
BEGIN

   FOR i IN 1 .. p_mediaTable.COUNT LOOP

	     if ( upper(p_mediaTable(i).param_name) = 'TASK_ID' ) then
	         	l_task_id := p_mediaTable(i).param_value;

		elsif ( upper(p_mediaTable(i).param_name) = 'PARTY_ID' ) then
			l_nm_party_id := p_mediaTable(i).param_value;

  		elsif ( upper(p_mediaTable(i).param_name) =  'SOURCE_OBJECT_TYPE' ) then
	         	l_source_object_type := p_mediaTable(i).param_value;

		elsif ( upper(p_mediaTable(i).param_name) =  'SOURCE_CODE_ID' ) then
	         l_source_Code_id := p_mediaTable(i).param_value;

		elsif ( upper(p_mediaTable(i).param_name) =  'SOURCE_CODE' ) then
	         l_source_Code := p_mediaTable(i).param_value;

		elsif ( upper(p_mediaTable(i).param_name) =  'SCHEDULE_ID' ) then
			l_source_campaign_id := p_mediaTable(i).param_value;

	     END IF;

   END LOOP;

END getFooData ;
-- Start bug 6197074 gnramasa 27/July-07
PROCEDURE handleFooTask (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2)
			is
BEGIN
iex_debug_pub.LogMessage('IEX_UWQ_SEL_PKG.handleFooTask :Begin ++');
   l_task_id            := '';
   l_source_code        := '';
   l_source_code_id     := '';
   l_source_campaign_id := 0;
   l_nm_party_id        := 0;

   iex_debug_pub.LogMessage('Calling getFooData ++');
   getFooData(p_mediaTable);
   iex_debug_pub.LogMessage('Returned from getFooData --');
   iex_debug_pub.LogMessage('IEX_UWQ_SEL_PKG.handleFooTask :l_nm_PARTY_ID' || l_nm_PARTY_ID);
   iex_debug_pub.LogMessage('IEX_UWQ_SEL_PKG.handleFooTask :l_Task_ID' || l_Task_ID);
/*
   If l_nm_party_id <> 0 then
	p_action_name := 'IEXRCALL';

    if l_source_code is not null then
		if l_source_code_id is null  and l_source_campaign_id is not null then
		   open c_source_code_id(l_source_campaign_id, l_source_code);
		  fetch c_source_code_id into l_source_code_id;
		  close c_source_code_id;
		 elsif l_source_code_id is null and l_source_campaign_id is null then
		   open c2_source_code_id(l_source_code);
		  fetch c2_source_code_id into l_source_code_id;
		  close c2_source_code_id;
		 end if;
    end if;

	p_action_param := 'PARTY_ID=' || l_nm_PARTY_ID ||' SOURCE_CAMPAIGN_ID=' || l_source_code_id;
	p_action_type := 2;

   elsif (l_source_object_type in ('Party', 'IEX_ACCOUNT', 'IEX_BILLTO', 'IEX_CASES',
           'IEX_DUNNING', 'IEX_INVOICES', 'IEX_PROMISE', 'IEX_DISPUTE',
		   'IEX_DELINQUENCY', 'IEX_STRATEGY', 'IEX_WORKIEM')) then
	  p_action_name := 'IEXRCALL' ;
      p_action_param := 'USAGE=QUERY_TASK TASK_ID='|| l_Task_ID ;
      p_action_type := 1;
   else
       p_action_name := 'JTFTKMAN' ;
       p_action_param := 'TASK_ID=' || l_Task_ID;
       p_action_type := 2;
   end if ;
   p_msg_name := 'NULL' ;
   p_msg_param := 'NULL' ;
   p_dialog_style := 1; */ /* IEU_DS_CONSTS_PUB.G_DS_NONE ; */
--   p_msg_appl_short_name := 'NULL' ;

     If l_nm_PARTY_ID IS NULL OR l_nm_PARTY_ID=0 then
       SELECT customer_id
       INTO l_nm_PARTY_ID
       from jtf_tasks_b
       WHERE task_id=l_Task_ID;
   END if;
    iex_debug_pub.LogMessage('IEX_UWQ_SEL_PKG.handleFooTask :final l_nm_PARTY_ID' || l_nm_PARTY_ID);
   If l_nm_PARTY_ID IS NULL OR l_nm_PARTY_ID=0 then
       iex_debug_pub.LogMessage('IEX_UWQ_SEL_PKG.handleFooTask :Party_id is NULL, So opening the Task manager screen instead of IEXRCALL');
       p_action_name := 'JTFTKMAN' ;
       p_action_param := 'TASK_ID=' || l_Task_ID;
       p_action_type := 2;
   ELSE
           p_action_name := 'IEXRCALL' ;
	   p_action_param := 'PARTY_ID=' || l_nm_PARTY_ID || ' USAGE=QUERY_TASK TASK_ID='|| l_Task_ID ;
	   p_action_type := 1;
   END IF;

  /*
   p_msg_name := 'NULL' ;
   p_msg_param := 'NULL' ;
   p_dialog_style := 1; *//* IEU_DS_CONSTS_PUB.G_DS_NONE ; */
/*   p_msg_appl_short_name := 'NULL' ;  */
END handleFooTask ;

/*** kasreeni end 6197074 7/10/2007 */
-- End bug 6197074 gnramasa 27/July-07
BEGIN
    l_Profile :=  NVL(FND_PROFILE.VALUE('AST_MATCH_CAMP_DNIS'), 'N');
    l_PhoneAreaCodeYN := NVL(FND_PROFILE.VALUE('AST_ANI_WITHOUT_AREACODE'), 'N');
    l_AreaCodeLength  := NVL(FND_PROFILE.VALUE('AST_AREA_CODE_LENGTH'), 3);
    l_PhoneNumberLength := NVL(FND_PROFILE.VALUE('AST_PHONE_NUMBER_LENGTH'), 7);
    l_DumpData := NVL(FND_PROFILE.VALUE('AST_DUMP_PARAMS'), 'N');

END IEX_UWQ_SEL_PKG;

/
