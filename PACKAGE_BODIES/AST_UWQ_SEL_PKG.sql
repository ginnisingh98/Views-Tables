--------------------------------------------------------
--  DDL for Package Body AST_UWQ_SEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_SEL_PKG" AS
/* $Header: asttmslb.pls 120.1 2006/01/09 03:17:37 rkumares noship $ */
------------------------------------------------------------------------------
--  Procedure	: setDefaults
--  Usage	:
--  Description	: This procedure sets the default every time
--- this package gets executed

   l_eventName          varchar2(60);
   l_partyId            number;
   l_partyType          varchar2(30);
   --l_customerNumber     number;
   l_customerNumber     varchar2(30);
   l_contactId          number;
   --l_contactNumber      number;
   l_contactNumber      varchar2(30);
   l_eventConfCode      varchar2(30);
   l_eventId            number;
   l_collateralReqNum   VARCHAR2(30) ;
   l_collateralId       number;
   l_campaignCode       varchar2(30);
   --l_campaignId         number;
   l_sourcecodeID     number;
   l_CampScheduleID     number;
   l_dnis               varchar2(30);
   l_callId             varchar2(80);
   l_ani                varchar2(40);
   l_accountCode        varchar2(40);
   l_accountId          number;
   l_usage              varchar2(60);
   l_agentID            varchar2(60);
   l_mediaType          varchar2(80);
   l_mediaItemID        varchar2(60);
   l_workitemID         varchar2(60);
   l_sendername         varchar2(60);
   l_subject            varchar2(60);
   l_messageID          varchar2(60);
   l_MoreAniMatch       varchar2(10);
   /** added by vimpi on 19th october */
   l_task_id            varchar2(60) ;
   l_source_code        varchar2(60) ;
   l_source_code_id     varchar2(60) ;
   l_customer_trx_id    number;
   l_trx_view_by         varchar2(60) ;
   l_InvoiceNum         varchar2(60) ;
  l_AccountRolesExist VARCHAR2(10);

   l_xfr_partyId            number;
   l_xfr_sourcecodeID     number;

   l_quoteNum			number;
   l_quoteID			number;
   l_orderNum			number;
   l_orderID			number;
   l_marketingPin		varchar2(30);
   l_ContractNum 		varchar2(120);
   l_ContractNumMod		varchar2(120);
   l_ServiceKey 		varchar2(30);
   l_SRNum			varchar2(64);

   -- kmahajan - added for bug 2695645
   l_customerID               number;

--for handlefootask function below..jraj..11/5/02
   l_source_object_type varchar2(300);
   l_source_campaign_id number;
   l_nm_party_id        number;

   l_blocked			boolean;

PROCEDURE LogMessage(l_Message varchar2) IS
BEGIN
  if (l_DumpData = 'Y') then
     ast_debug_pub.LogMessage(l_Message, -10, 'Y');
  end if;
END;

PROCEDURE setDefaults IS
BEGIN

   l_eventName         := '';
   l_partyId           := 0;
   l_partyType         := '';
   l_customerNumber    := '';
   l_contactId         := 0;
   l_contactNumber     := '';
   l_eventConfCode     := '';
   l_eventId           := 0;
   l_collateralReqNum  := '';
   l_collateralId      := 0;
   l_campaignCode      := '';
   --l_campaignId        := 0;
   l_campScheduleID    := 0;
   l_sourcecodeID    := 0;
   l_dnis              := '';
   l_callId            := '';
   l_ani               := '';
   l_accountCode       := '';
   l_accountId         := 0;
   l_usage             := '';
   l_agentID           := '';
   l_mediaType         := '';
   l_mediaItemID       := '';
   l_workitemID        := '';
   l_sendername        := '';
   l_subject           := '';
   l_messageID         := '';
   l_MoreAniMatch      := 'N';
   --added by vimpi on 11th feb/2001
   l_customer_trx_id   := 0;
   l_trx_view_by        := '' ;
   l_AccountRolesExist := 'N';
   l_xfr_partyId           := 0;
   l_xfr_sourcecodeID    := 0;

   l_quoteNum			:= 0;
   l_quoteID			:= 0;
   l_orderNum			:= 0;
   l_orderID			:= 0;
   l_marketingPin		:= '';
   l_ContractNum 		:= '';
   l_ContractNumMod		:= '';
   l_ServiceKey 		:= '';
   l_SRNum			:= '';

   l_blocked 			:= false;

   -- kmahajan - added for bug 2695645
   l_customerID          := 0;

END setDefaults;

-- private package to return the param type  value
PROCEDURE   getCallData(p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST) IS
BEGIN

   FOR i IN 1 .. p_mediaTable.COUNT LOOP
	LogMessage('MediaData[' || i || ']: ' || p_mediaTable(i).param_name || ' = ' || p_mediaTable(i).param_value);
	     if ( upper(p_mediaTable(i).param_name) = 'OCCTEVENTNAME' ) then
	         l_eventname := p_mediaTable(i).param_value;
	/* 3/13/3 - kmahajan - this is long obsolete
	     elsif ( upper(p_mediaTable(i).param_name) =  'IEU_AMS_CAMPAIGN_ID' ) then
	         l_CampaignID := p_mediaTable(i).param_value;
	*/
		elsif ( upper(p_mediaTable(i).param_name) =  'CAMPAIGN_SCHEDULE_ID' ) then
	         l_CampScheduleID := p_mediaTable(i).param_value;
             --added by vimpi on 11th feb 2002
	     elsif ( upper(p_mediaTable(i).param_name) = 'INVOICENUM' ) THEN

	         l_InvoiceNum :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CUSTOMERNUMBER' ) then

		    l_customerNumber  :=  p_mediaTable(i).param_value;

	     --elsif ( upper(p_mediaTable(i).param_name) = 'CUSTOMERID' ) THEN
	     elsif (p_mediaTable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID) THEN

	         l_customerID := to_number(p_mediaTable(i).param_value);

	     --elsif ( upper(p_mediaTable(i).param_name) = 'CUSTOMERNUM' ) then
	     elsif (p_mediaTable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_PARTY_NUMBER) then

	         l_customerNumber :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'CONTACTNUM' ) then

	         l_contactnumber :=  p_mediaTable(i).param_value;

	     ELSIF ( upper(p_mediatable(i).param_name)='EVENTCONFCODE') THEN

	         l_eventConfCode := p_mediaTable(i).param_value;

	     ELSIF ( upper(p_mediatable(i).param_name)='COLREQNUM') THEN

	         l_collateralReqNum := p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'PROMOTIONCODE' ) then

	        l_campaignCode :=  p_mediaTable(i).param_value;

	     --elsif ( upper(p_mediaTable(i).param_name) = 'OCCTDNIS' ) then
	     elsif (p_mediaTable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_DNIS) then

	        l_dnis :=  p_mediaTable(i).param_value;

	     elsif ( upper(p_mediaTable(i).param_name) = 'OCCTCALLID' ) then

	        l_callId :=  p_mediaTable(i).param_value;

	     --elsif ( upper(p_mediaTable(i).param_name) = 'OCCTANI' ) then
	     elsif (p_mediaTable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_ANI) then

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

              l_customerID := to_number(p_mediaTable(i).param_value);

		-- added for Warm Transfer functionality
		elsif (upper(p_mediaTable(i).param_name) = 'XFR_PARTY_ID') THEN
			l_xfr_partyId := to_number(p_mediaTable(i).param_value);
			l_usage := 'QUERY_TRANSFER';
		elsif (upper(p_mediaTable(i).param_name) = 'XFR_SOURCE_CODE_ID') THEN
			l_xfr_sourcecodeID :=  p_mediaTable(i).param_value;

	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_QUOTE_NUMBER) THEN
	         l_quoteNum := to_number(p_mediaTable(i).param_value);
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_ORDER_NUMBER) THEN
	         l_orderNum := to_number(p_mediaTable(i).param_value);
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_COLLATERAL_REQUEST_NUMBER) THEN
	         l_collateralReqNum := p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_ACCOUNT_NUMBER) THEN
	         l_accountCode :=  p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_EVENT_REGISTRATION_CODE) THEN
	         l_eventConfCode := p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_MARKETING_PIN) THEN
	         l_marketingPin := p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_CONTRACT_NUMBER) THEN
	         l_ContractNum := p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_CONTRACT_NUMBER_MODIFIER) THEN
	         l_ContractNumMod := p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_KEY) THEN
	         l_ServiceKey := p_mediaTable(i).param_value;
	     ELSIF (p_mediatable(i).param_name = CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_REQUEST_NUMBER) THEN
	         l_SRNum := p_mediaTable(i).param_value;

		-- added to check if the agent is already on a call (prereq: UWQ bug 2495619)
		elsif (p_mediaTable(i).param_name = 'UWQ_BLOCK_MODE') THEN
			if p_mediaTable(i).param_value = 'T' then
				l_blocked := true;
  LogMessage('UWQ_BLOCK_MODE = T');
			else
				l_blocked := false;
			end if;

	     END IF;

   END LOOP;

END getCallData ;

-- procedure to construct the paramlist to be passed to the form

FUNCTION  constructparam RETURN VARCHAR2  IS
l_paramlist VARCHAR2(3000);
BEGIN

   l_paramlist := '';
   if ( l_xfr_partyId <> 0 ) THEN
      l_paramlist := l_paramlist  || 'PARTY_ID' || '="' || l_xfr_partyId ||'" ';
   elsif ( l_partyId <> 0 ) THEN
      l_paramlist := l_paramlist  || 'PARTY_ID' || '="' || l_partyId ||'" ';
   end if;

   IF ( l_partyType is not NULL ) then
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

  /* 3/13/3 - kmahajan - this is long obsolete
   IF (l_campaignId <> 0 ) THEN

      l_paramlist := l_paramlist  || 'CAMPAIGN_ID' || '="' || l_campaignId ||'" ';

   END IF;
  */

   if (l_xfr_sourcecodeID <> 0) THEN
      l_paramlist := l_paramlist  || 'SOURCE_CAMPAIGN_ID' || '="' || l_xfr_sourcecodeID ||'" ';
   elsif (l_sourcecodeID <> 0) THEN
      l_paramlist := l_paramlist  || 'SOURCE_CAMPAIGN_ID' || '="' || l_sourcecodeID ||'" ';
   end if;

   if (l_CampaignCode is not null) THEN

      l_paramlist := l_paramlist  || 'CAMPAIGN_SOURCE_CODE' || '="' || l_campaignCode ||'" ';

   end if;

   IF (l_CampScheduleID <> 0) THEN

      l_paramlist := l_paramlist  || 'CAMPAIGN_SCHEDULE_ID' || '="' || l_campScheduleId ||'" ';

   END IF;

   IF ( l_callID is not null ) THEN

      l_paramlist := l_paramlist  || 'TM_CALL_ID' || '="' || l_callID ||'" ';

   END IF;

   IF ( l_accountID <> 0 )  THEN

       l_paramlist := l_paramlist  || 'CUST_ACCOUNT_ID' || '="' || l_accountId ||'" ';

   END IF;
   --added by vimpi on 11thfeb 2002
   IF ( l_customer_trx_id <> 0  )  THEN

       l_paramlist := l_paramlist  || 'Customer_TRX_ID' || '="' || l_customer_trx_id ||'" ';

   END IF;
   IF ( l_trx_view_by is not null  )  THEN

       l_paramlist := l_paramlist  || 'TRX_VIEW_BY' || '="' || l_trx_view_by ||'" ';

   END IF;

   IF ( l_eventname is not null )  THEN

       l_paramlist := l_paramlist  || 'UWQ_EVENTNAME' || '="' || l_eventname ||'" ';

   END IF;


   IF ( l_dnis is not null )  THEN

       l_paramlist := l_paramlist  || 'TM_DNIS' || '="' || l_dnis ||'" ';


   END IF;

   IF ( l_ani is not null)  THEN

       l_paramlist := l_paramlist  || 'TM_ANI' || '="' || l_ani ||'" ';

   END IF;


   IF ( l_mediaType is not null  )  THEN

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

   IF ( l_messageID is not null) THEN

       l_paramlist := l_paramlist  || 'EM_MESSAGE_ID' || '="' || l_messageID ||'" ';

   END IF;

   IF (l_MoreAniMatch = 'Y') then

	 l_Usage := 'QUERY_ANI';

   END IF;

   IF ((l_usage is null) and (l_partyId = 0) and (l_xfr_partyID = 0)) THEN

      l_usage := 'QUERY_LKP';

   END IF;

   -- append the usage parameter
   l_paramlist := l_paramlist  || ' CALLED_FROM = "UWQ" ';

   if (l_usage is not null) then
	 l_paramlist := l_paramlist || ' USAGE' || '="' || l_usage ||'" ';
   end if;

  LogMessage('Param List Before Return:' || l_paramList);
  RETURN l_paramlist;

EXCEPTION
  when others then
	LogMessage('Exception in constructparam. Param List: ' || l_paramList);
	LogMessage('SQLCODE: ' || SQLCODE);
	LogMessage('SQLERRM: ' || SQLERRM);

     l_paramlist := ' CALLED_FROM = "UWQ" ';
	LogMessage('Param List reset to:' || l_paramList);

     return l_paramlist;

END constructparam;

-- procedure get details from event confirmation number
PROCEDURE getDtlsFromEvent IS

   CURSOR C_GetEventDetails(x_eventConfCode varchar2) IS
      --SELECT registrant_party_Id,registrant_contact_Id,event_offer_Id
	--FROM  ams_event_registrations_v
     SELECT registrant_party_Id,event_offer_Id
	FROM  ams_event_registrations
	WHERE confirmation_code = x_eventConfCode;


BEGIN

   OPEN C_GetEventDetails(l_eventConfCode);
   --FETCH C_GetEventDetails INTO l_partyId, l_contactId, l_eventId;
   FETCH C_GetEventDetails INTO l_partyId, l_eventId;
   IF ( c_geteventdetails%NOTFOUND) THEN
      l_partyId:=0;
      --l_contactid := 0;
      l_eventid := 0;
   END IF;
   CLOSE C_GetEventDetails;
END getDtlsFromEvent;

PROCEDURE Getcampaigncode IS

   CURSOR c_campaignId(x_inbound_phone VARCHAR2) IS
     SELECT SOC.SOURCE_CODE_ID, SOC.SOURCE_CODE
     FROM aMS_SOURCE_CODES SOC, AMS_ACT_CONTACT_POINTS AACP
     WHERE SOC.SOURCE_CODE_FOR_ID = AACP.ACT_CONTACT_USED_BY_ID AND
      SOC.ARC_SOURCE_CODE_FOR = AACP.ARC_CONTACT_USED_BY AND
      SOC.ACTIVE_FLAG = 'Y' AND AACP.CONTACT_POINT_TYPE = 'PHONE'
      AND AACP.CONTACT_POINT_VALUE = x_inbound_phone;

   CURSOR c_campaigncode(x_campaigncode VARCHAR2) IS
      SELECT source_code_id
	    FROM ams_source_codes
	    WHERE source_code = x_campaignCode
	    AND active_flag = 'Y';
      lx_CampaignCode varchar2(100);
      lx_sourcecodeID number;

BEGIN

   LogMessage('Inside Campaign Code Match');
   IF ( l_campaigncode IS NOT NULL ) THEN

      OPEN c_campaigncode(l_CampaignCode);
      FETCH c_campaigncode INTO l_sourcecodeID;
      CLOSE c_campaigncode;

   ELSIF ( l_dnis IS NOT NULL ) THEN
       LogMessage('Inside DNIS Code Match ' || l_dnis);
       OPEN c_campaignid(l_dnis);
       FETCH c_campaignid INTO l_sourcecodeID, l_CampaignCode;
       IF ( c_campaignid%found) THEN
           LogMessage('Inside DNIS Code Match Success : Source Code ' || l_CampaignCode
                || ' Source Code Id ' || l_sourcecodeID);
           FETCH c_campaignid INTO lx_sourcecodeID, lx_CampaignCode;
           IF (c_CampaignId%FOUND) then

	       LogMessage('MoreCampaign Code Match. Will be using default is set ');
               lx_campaignCode := FND_PROFILE.VALUE('AST_DEFAULT_SOURCE_CODE');

               if lx_CampaignCode is not NULL then
                   OPEN c_campaigncode(lx_CampaignCode);
                   FETCH c_campaigncode INTO l_sourcecodeID;
                   IF c_CampaignCode%FOUND THEN
                      l_CampaignCode := lx_CampaignCode;
                   END IF;
                   CLOSE c_campaigncode;
               END IF;
            END IF;
         END IF;
         CLOSE c_campaignid;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      LogMessage('GetCampaignCode Exception Occurred');
      return;

END;


-- procedure to get the collateral request Id from a collateral request confirmation
-- number
PROCEDURE getDtlsFromColReq IS

   CURSOR C_getDtlsFromColReq(x_collateralReqNum number ) IS
      --SELECT quote_header_id,party_id,cust_account_id,l_contactid
      SELECT quote_header_id,party_id,cust_account_id
	    FROM ASO_QUOTE_HEADERS_ALL
	    WHERE quote_number = x_collateralReqNum;
BEGIN

   OPEN C_getDtlsFromColReq(To_number(l_collateralreqnum));
   --FETCH C_getDtlsFromColReq INTO l_collateralId,l_partyId, l_accountID,l_contactId;
   FETCH C_getDtlsFromColReq INTO l_collateralId,l_partyId, l_accountID;
   IF (c_getdtlsfromcolreq%Notfound )THEN
      l_collateralid := 0;
	 l_partyID := 0;
	 l_accountID := 0;
   END IF;
   CLOSE C_getDtlsFromColReq;

END getDtlsFromColReq;

-- private procedure to get the party associated with a quote number
PROCEDURE getDtlsFromQuoteNum IS

   CURSOR C_getDtlsFromQuoteNum(x_QuoteNum number ) IS
      SELECT quote_header_id,party_id
	    FROM ASO_QUOTE_HEADERS_ALL
	    WHERE quote_number = x_QuoteNum;
	    -- and max_version_flag = 'Y';
BEGIN

   LogMessage('In getDtlsFromQuoteNum');
   OPEN C_getDtlsFromQuoteNum(l_quoteNum);
   FETCH C_getDtlsFromQuoteNum INTO l_quoteID,l_partyId;
   IF (c_getdtlsfromQuoteNum%Notfound )THEN
      l_quoteID := 0;
	 l_partyID := 0;
   END IF;
   CLOSE C_getDtlsFromQuoteNum;

END getDtlsFromQuoteNum;

-- private procedure to get the party associated with an order number
PROCEDURE getDtlsFromOrderNum IS

   CURSOR C_getDtlsFromOrderNum(x_OrderNum number ) IS
      SELECT o.header_id, a.party_id
	    FROM oe_order_headers_all o, hz_cust_accounts a
	    where o.order_number = x_OrderNum
	    and a.cust_account_id = o.sold_to_org_id;
BEGIN

   LogMessage('In getDtlsFromOrderNum');
   OPEN C_getDtlsFromOrderNum(l_OrderNum);
   FETCH C_getDtlsFromOrderNum INTO l_OrderID,l_partyId;
   IF (c_getdtlsfromOrderNum%Notfound )THEN
      l_OrderID := 0;
	 l_partyID := 0;
   END IF;
   CLOSE C_getDtlsFromOrderNum;

END getDtlsFromOrderNum;

-- private procedure to get the party and source code associated with a Marketing Pin
PROCEDURE getDtlsFromMPin IS

   CURSOR C_getDtlsFromMPin(x_MPin number ) IS
      SELECT s.source_code, s.source_code_id, nvl(l.party_id,0)
	    FROM ams_list_entries l, ams_source_codes s
	    where l.pin_code = x_MPin
	    and l.source_code = s.source_code;
BEGIN

   LogMessage('In getDtlsFromMPin');
   OPEN C_getDtlsFromMPin(l_MarketingPin);
   FETCH C_getDtlsFromMPin INTO l_campaignCode, l_sourceCodeID, l_partyId;
   IF (c_getdtlsfromMPin%Notfound )THEN
      l_campaignCode := '';
	 l_sourcecodeID := 0;
	 l_partyID := 0;
   END IF;
   CLOSE C_getDtlsFromMPin;

END getDtlsFromMPin;

-- private procedure to get the party associated with a contract
PROCEDURE getDtlsFromContractNum IS

   CURSOR C_getDtlsFromContractNum(x_ContractNum varchar2, x_ContractNumMod varchar2 default null) IS
      SELECT to_number(p.object1_id1)
	    FROM okc_k_party_roles_b p , okc_k_headers_b k
	    where k.contract_number = x_ContractNum
	    and k.contract_number_modifier = nvl(x_ContractNumMod, k.contract_number_modifier)
	    and k.id = p.dnz_chr_id
	    and p.primary_yn = 'Y'
	    and p.jtot_object1_code = 'OKX_PARTY';
		--and p.object1_id2 = '#';
BEGIN

   LogMessage('In getDtlsFromContractNum');
   if l_ContractNumMod = '' then
   	OPEN C_getDtlsFromContractNum(l_ContractNum, null);
   else
   	OPEN C_getDtlsFromContractNum(l_ContractNum, l_ContractNumMod);
   end if;
   FETCH C_getDtlsFromContractNum INTO l_partyId;
   IF (c_getdtlsfromContractNum%Notfound )THEN
	 l_partyID := 0;
   END IF;
   CLOSE C_getDtlsFromContractNum;

END getDtlsFromContractNum;

-- private procedure to get the party associated with a Service Key
PROCEDURE getDtlsFromServiceKey IS

   CURSOR C_getDtlsFromServiceKey(x_ServiceKey varchar2 ) IS
      SELECT owner_party_id
	    FROM csi_item_instances
	    where instance_number = x_ServiceKey
	    and owner_party_source_table = 'HZ_PARTIES';
BEGIN

   LogMessage('In getDtlsFromServiceKey');
   OPEN C_getDtlsFromServiceKey(l_ServiceKey);
   FETCH C_getDtlsFromServiceKey INTO l_partyId;
   IF (c_getdtlsfromServiceKey%Notfound )THEN
	 l_partyID := 0;
   END IF;
   CLOSE C_getDtlsFromServiceKey;

END getDtlsFromServiceKey;

-- private procedure to get the party associated with a Service Request
PROCEDURE getDtlsFromSRNum IS

   CURSOR C_getDtlsFromSRNum(x_SRNum varchar2 ) IS
      SELECT customer_id
	    FROM cs_incidents_all_b
	    where incident_number = x_SRNum;
BEGIN

   LogMessage('In getDtlsFromSRNum');
   OPEN C_getDtlsFromSRNum(l_SRNum);
   FETCH C_getDtlsFromSRNum INTO l_partyId;
   IF (c_getdtlsfromSRNum%Notfound )THEN
	 l_partyID := 0;
   END IF;
   CLOSE C_getDtlsFromSRNum;

END getDtlsFromSRNum;

-- private procedure to get the partyId
PROCEDURE GetDtlsFromConNum IS
/* kmahajan - just pass back the Party_id of the relationship instead
	CURSOR C_getDtlsFromConNum(x_contactNum varchar2 ) IS
	 SELECT rel.subject_id, rel.object_id
      FROM   hz_parties p, hz_relationships rel
      WHERE  p.party_number = x_contactNum
      AND    p.party_id = rel.party_id
      AND    rel.subject_type = 'PERSON'
      AND    rel.object_table_name = 'HZ_PARTIES'
      AND    rel.subject_table_name = 'HZ_PARTIES'
      AND    rel.object_type = 'ORGANIZATION';
*/
	CURSOR C_getDtlsFromConNum(x_contactNum varchar2 ) IS
     	SELECT party_id, party_type
		FROM hz_parties
		WHERE party_number = x_contactNum
		AND party_type = 'PARTY_RELATIONSHIP';
BEGIN
	OPEN C_getDtlsFromConNum (l_contactNumber);
	--FETCH  C_getDtlsFromConNum INTO l_contactId, l_partyId ;
	FETCH  C_getDtlsFromConNum INTO l_partyId, l_partyType ;
	IF (C_getDtlsFromConNum%Notfound )THEN
		l_partyid := 0;
		l_partytype := '';
		--l_contactID := 0;
	END IF;
	CLOSE C_getDtlsFromConNum;
END GetDtlsFromConNum;

PROCEDURE GetDtlsFromCustNum IS
   CURSOR C_GetCustId(x_custnum VARCHAR2) IS
      SELECT party_id, party_type
	--FROM jtf_parties_v
	FROM hz_parties
	WHERE party_number = x_custnum;
	--AND party_type in ('ORGANIZATION','PERSON');

BEGIN
   LogMessage('GetDtls from Customer Number');
   OPEN c_getcustid(l_customernumber);
   FETCH c_getcustid INTO l_partyId, l_partyType;
   IF (c_getcustid%Notfound )THEN
	l_partyid := 0;
	l_partytype := '';
   END IF;
   CLOSE c_getcustid;
EXCEPTION
   WHEN OTHERS THEN
      LogMessage('Exception Occurred: GetDtlsFromCustNum ');

END GetDtlsFromCustNum;

-- added by rnori 07-APR-03, for bug# 2885131
PROCEDURE GetDtlsFromCustID IS
   CURSOR C_GetCustId(x_custid NUMBER) IS
   SELECT party_id,party_type
     FROM hz_parties
    WHERE party_id = x_custid;
BEGIN
   LogMessage('GetDtls from Customer ID');
   OPEN c_getcustid(l_customerID);
   FETCH c_getcustid INTO l_partyId,l_partyType;
   IF (c_getcustid%Notfound ) THEN
     l_partyid := 0;
	l_partytype := '';
   END IF;
   CLOSE c_getcustid;
EXCEPTION
   WHEN OTHERS THEN
      LogMessage('Exception Occured: GetDtlsFromCustID ');
END GetDtlsFromCustID;

PROCEDURE GetDtlsFromAccountNum IS

   CURSOR C_GetCustId(x_account_num VARCHAR2) IS
     SELECT hzp.party_id, hza.cust_account_id, hzp.party_type
	FROM hz_cust_accounts hza, hz_parties hzp
     --SELECT hza.party_id, hza.cust_account_id
	--FROM hz_cust_accounts hza
	WHERE hza.account_number = x_account_num  and
	   hza.party_id = hzp.party_id;

  CURSOR C_GetAccountRoles (x_account_num VARCHAR2) is
	select a.cust_account_id
	from hz_cust_accounts a, hz_cust_account_roles ar
	where a.account_number = x_account_num
	and a.cust_account_id = ar.cust_account_id;

BEGIN

   LogMessage('Inside Account Number match ');
   open c_getaccountroles(l_accountCode);
   fetch c_getaccountroles into l_accountID;
   if c_getaccountroles%FOUND then
	l_AccountRolesExist := 'Y';
	l_partyID := 0;
	close c_getaccountroles;
	return;
   end if;
   close c_getaccountroles;
   OPEN c_getcustid(l_accountCode);
   FETCH c_getcustid INTO l_partyId, l_accountID, l_partyType;
   --FETCH c_getcustid INTO l_partyId, l_accountID;
   CLOSE c_getcustid;

EXCEPTION
   WHEN OTHERS THEN
      LogMessage('Exception Inside Account Number match ');

END GetDtlsFromAccountNum;

--added by vimpi on 11th feb 2002
PROCEDURE GetDtlsFromInvoiceNum IS

   CURSOR C_GetCustId( InvoiceNum Number) IS
      SELECT customer_trx_id
	FROM ra_customer_trx
	WHERE trx_number  = to_char(InvoiceNum) ;

BEGIN

   LogMessage('Inside Invoice Number match ');
   OPEN c_getcustid(l_InvoiceNum);
   FETCH c_getcustid INTO l_Customer_Trx_Id ;

   CLOSE c_getcustid;

EXCEPTION
   WHEN OTHERS THEN
      LogMessage('Exception Inside Invoice Number match ');

END GetDtlsFromInvoiceNum;


PROCEDURE GetDtlsFromPhoneNum IS

     CURSOR C_getDtlsFromPhone(x_phonenumber varchar2 ) IS
     SELECT cp.owner_table_id, p.party_type
     FROM   hz_contact_points cp, hz_parties p
     WHERE  cp.transposed_phone_number like x_phonenumber
     AND    cp.owner_table_name = 'HZ_PARTIES'
     AND    cp.status = 'A'
     AND    cp.owner_table_id = p.party_id;

/*
	CURSOR C_getDtlsFromPhoneNum(x_phonenumber varchar2 ) IS
	SELECT party_id, party_type
	FROM   JTF_CONTACT_POINTS_V
	WHERE  translate(phone_number,'0123456789()/\-. ','0123456789') = x_phonenumber and status = 'A' ;

	CURSOR C_getDtlsFromAreaPhoneNum(x_phonenumber varchar2 ) IS
	SELECT party_id, party_type
	FROM   JTF_CONTACT_POINTS_V
	 WHERE  translate(area_code||phone_number,'0123456789()/\-. ','0123456789')  = x_phonenumber and status = 'A';

	CURSOR C_GetSubObj(p_rel_partyid number) is
	   SELECT object_id, subject_id from
		 HZ_PARTY_RELATIONSHIPS WHERE PARTY_ID = p_rel_partyid;
*/
	CURSOR C_GetSubObj(p_rel_partyid number) is
	   SELECT object_id, subject_id from
		 HZ_RELATIONSHIPS WHERE PARTY_ID = p_rel_partyid and
			object_type = 'ORGANIZATION' and subject_type = 'PERSON';

     l_rel_partyid  number := NULL;
	l_partyIDNext  number;
	l_partyTypeNext varchar2(150);

     l_filtered_ANI    VARCHAR2(60);
     l_transposed_ANI  VARCHAR2(60);

BEGIN
       LogMessage('Inside Phone Number Match, l_Ani:  ' || l_Ani || ' l_NoAreaCodeMatch = ' || l_NoAreaCodeMatch );

/* kmahajan - old code - commented out and replaced by the code following this

	if (l_NoAreaCodeMatch = 'Y') then
	   BEGIN
		OPEN C_getDtlsFromPhoneNum (l_ani);
		FETCH  C_getDtlsFromPhoneNum INTO l_partyId, l_partyType;
		if C_getDtlsFromPhoneNum%FOUND then
                     LogMessage('First ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=  ' || l_PartyType );
		     FETCH C_getDtlsFromPhoneNum into l_partyIDNext, l_partyTypeNext;
		     IF C_GetDtlsFromPhoneNum%FOUND then
		        l_MoreAniMatch := 'Y';
                        LogMessage('More ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=  ' || l_PartyType );
		     End If;
		end if;
		CLOSE C_getDtlsFromPhoneNum;
        EXCEPTION
	   When Others then
              LogMessage('Cursor GetDtlsFromPhoneNum Exception Occurred');
              Close C_GetDtlsFromPhoneNum;
        END;

	else
	   BEGIN
	    Open C_getDtlsFromAreaPhoneNum(l_ani);
	    fetch C_getDtlsFromAreaPhoneNum INTO l_partyId, l_partyType;
	    IF C_getDtlsFromAreaPhoneNum%FOUND then
                LogMessage('First ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=  ' || l_PartyType );
		FETCH C_getDtlsFromAreaPhoneNum into l_partyIDNext, l_partyTypeNext;
		If C_GetDtlsFromAreaPhoneNum%FOUND then
		   l_MoreAniMatch := 'Y';
                   LogMessage('More ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=  ' || l_PartyType );
		end if;
	    end if;
	    CLOSE C_getDtlsFromAreaPhoneNum;
        EXCEPTION
		when others then
                 LogMessage('Cursor GetDtlsFromAreaPhoneNum Exception occurred ');
	         CLOSE C_getDtlsFromAreaPhoneNum;
        END;

	end if;

   --added this if condition for bug number 2096768 by vimpi
	if ( (l_MoreAniMatch = 'Y') and ( l_partyIdNext = 'PARTY_RELATIONSHIP') and
          ( l_PartyId = 'ORGANIZATION' or l_PartyID = 'PERSON')) then
		l_PartyIdNext := l_partyId ;
		l_partyTypeNext := l_partyType ;
     end if ;

	if l_PartyType = 'PARTY_RELATIONSHIP' Then
	  BEGIN

	    l_Usage := 'QUERY_CON';
	    open c_GetSubObj(l_partyid);
	    fetch c_GetSubObj into l_partyID, l_ContactID;
	    if (l_MoreAniMatch <> 'Y') then
	    	 l_PartyType := 'ORGANIZATION';
	    end if;
	    close C_GetSubObj;
       EXCEPTION
	    When Others then
              LogMessage(' Cursor GetSubObj Exception occurred ');
	      close C_GetSubObj;
       END;
	elsif l_partyType = 'PERSON' then

	    l_Usage := 'QUERY_CONSUMER';

     elsif l_partyType = 'ORGANIZATION' then

         l_Usage := 'QUERY_ORG';

	end if;
*/
     l_filtered_ANI := translate(l_ani,
          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$^&*_,|}{[]?<>=";:%',
          '0123456789');

     l_transposed_ANI := null;
     for c in reverse 1..length(l_filtered_ANI) loop
          l_transposed_ANI := l_transposed_ANI || substr(l_filtered_ANI, c, 1);
     end loop;
     l_transposed_ANI := RTRIM(l_transposed_ANI, 0) || '%'; --Added for bug#4043234

     OPEN C_getDtlsFromPhone(l_transposed_ANI);
     FETCH  C_getDtlsFromPhone INTO l_partyId, l_partyType;
     if C_getDtlsFromPhone%FOUND then
          LogMessage('First ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=  ' || l_PartyType );
          FETCH C_getDtlsFromPhone into l_partyIDNext, l_partytypeNext;
          IF C_GetDtlsFromPhone%FOUND then
               l_MoreAniMatch := 'Y';
               LogMessage('More ANI Matched. Party ID ' || l_PartyIDnext || ' l_PartyType=  ' || l_PartyTypenext );
          End If;
     end if;
     CLOSE C_getDtlsFromPhone;

     if l_MoreAniMatch = 'Y' then
          l_usage := 'QUERY_ANI';
     elsif l_partytype = 'ORGANIZATION' then
          l_usage := 'QUERY_ORG';
     elsif l_partytype = 'PERSON' then
          l_usage := 'QUERY_CONSUMER';
     elsif l_partytype = 'PARTY_RELATIONSHIP' then
          l_usage := 'QUERY_RELATIONSHIP';
		/*
-- kmahajan - code below for backward compatibility for IEX
-- remove when IEX also uses multi-match UI
         open c_GetSubObj(l_partyid);
         fetch c_GetSubObj into l_partyID, l_ContactID;
         if (l_MoreAniMatch <> 'Y') then
           l_PartyType := 'ORGANIZATION';
         end if;
         close C_GetSubObj;
	    */
     end if;

	-- kmahajan - if-then-else below added for bug 2454762
	if l_MoreAniMatch = 'Y' then
		l_partyID := 0;
	end if;

      LogMessage('GetDtlsFromPhoneNum done');
EXCEPTION
	WHEN OTHERS THEN
            LogMessage('GetDtlsFromPhoneNum Exception Occurred');
	    return;

END GetDtlsFromPhoneNum;


PROCEDURE handleOTSInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) is

   foo_action_param varchar2(3000);
BEGIN

   p_action_type :=1;
   p_action_name := G_CurrentForm;
   p_action_param := '';

   setDefaults;
   getCallData(p_mediaTable);

   if l_blocked then
	p_action_type := 2;
	p_action_name := 'AST_MEDIA';
	p_action_param := 'BLOCKED="TRUE" ';
   end if;

   Logmessage('Inside Foo function ');

   if (l_xfr_partyID <> 0) then
	logmessage('Using transferred information');
	p_action_param := p_action_param || constructparam;
	return;
   end if;

   if ((l_profile = 'Y') or (l_campaignCode is not null)) and (l_xfr_sourcecodeID = 0) then
   -- l_xfr_sourcecodeid = 0 indicates no source code has been passed
   -- via a warm transfer; if it has, it takes precedence
	   getCampaignCode;
   end if;

   if ( l_AccountCode is not null ) then

      getDtlsFromAccountNum;
      IF ( l_partyId <> 0 ) THEN
/* kmahajan - change usage when IEX uptakes the multi-match UI
             l_usage := 'QUERY_ACCOUNT';
*/
		   if (l_PartyType = 'ORGANIZATION') then
	           l_usage := 'QUERY_ORG';
             else
			 l_usage := 'QUERY_CONSUMER';
		   end if;
	        p_action_param := p_action_param || constructparam;
	        RETURN;
      END IF;
	 if (l_AccountRolesExist = 'Y') then
-- kmahajan - launch multi-match UI only for eBC - IEX needs to uptake mult-match UI
		   l_usage := 'QUERY_ACCOUNT_ROLE';
	        p_action_param := p_action_param || constructparam;
	  	   if l_usage = 'QUERY_ACCOUNT_ROLE' then
		   -- kmahajan - commented out line below as IEX also uses it
		   -- and p_action_name = 'AST_RC_ALL' then
			p_action_name := 'AST_MEDIA';
   			p_action_type := 2;
		   end if;
	        RETURN;
	 end if;
   end if;

   --added by vimpi on 11thfeb2002
   if (l_InvoiceNum  is not NULL ) then
      GetDtlsFromInvoiceNum  ;
      l_trx_view_by  := 'Delinquency' ;
      l_usage := 'QUERY_TRANSACTION';
      p_action_param := p_action_param || constructparam;
      return;
   end if ;

   if ( l_eventConfCode is not null ) THEN
      getDtlsFromEvent;
      IF ( l_eventid <> 0 ) THEN
	        -- we found the match, hence we can query the event details
	        l_usage := 'QUERY_EVENT';
	        -- open the form using app_navigate.execute
	        p_action_param :=  p_action_param || constructParam;
	        return;
      END IF;
   END IF;

   if ( l_collateralReqNum is not null ) then
      getDtlsFromColReq;
      IF (l_collateralid <> 0 ) then
	         l_usage := 'QUERY_QUOTE';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_contactNumber  is not null ) then
      getDtlsFromConNum;
      --IF ( l_contactid <> 0  OR l_partyId <> 0 ) THEN
      IF ( l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_RELATIONSHIP';
	        p_action_param := p_action_param || constructparam;
	        RETURN;
      END IF;
   end if;

   if ( l_customerNumber is not null ) then
      getDtlsFromCustNum;
      IF (  l_partyId <> 0 ) THEN
         if (l_PartyType = 'ORGANIZATION') then
                l_usage := 'QUERY_ORG';
         elsif (l_PartyType = 'PERSON') then
                l_usage := 'QUERY_CONSUMER';
         else
                l_usage := 'QUERY_RELATIONSHIP';
         end if;
         p_action_param := p_action_param || constructparam;
         RETURN;
      END IF;
   END IF ;

   if ( l_quoteNum <> 0 ) then
      getDtlsFromQuoteNum;
      IF (l_quoteID <> 0 ) then
	         l_usage := 'QUERY_QUOTE';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_orderNum <> 0 ) then
      getDtlsFromOrderNum;
      IF (l_orderID <> 0 ) then
	         l_usage := 'QUERY_ORDER';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_marketingPin is not null ) then
      getDtlsFromMPin;
      IF (l_partyID <> 0 ) then
	         l_usage := 'QUERY_MPIN';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_contractNum is not null ) then
      getDtlsFromContractNum;
      IF (l_partyID <> 0 ) then
	         l_usage := 'QUERY_CONTRACT';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_serviceKey is not null ) then
      getDtlsFromServiceKey;
      IF (l_partyID <> 0 ) then
	         l_usage := 'QUERY_SERVICE_KEY';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_SRNum is not null ) then
      getDtlsFromSRNum;
      IF (l_partyID <> 0 ) then
	         l_usage := 'QUERY_SERVICE_REQUEST';
	         p_action_param :=  p_action_param || constructParam;
	         return;
      END IF;
   END IF;

   if ( l_customerID <> 0 ) then
         getDtlsFromCustID;  -- added by rnori 07-APR-03 bug # 2885131
	    IF (l_partyid <> 0 ) THEN
	       if (l_PartyType = 'ORGANIZATION') then
		      l_usage := 'QUERY_ORG';
		  elsif (l_PartyType = 'PERSON') then
		      l_usage := 'QUERY_CONSUMER';
		  else
		      l_usage := 'QUERY_RELATIONSHIP';
		  end if;
	     --l_partyID := l_customerID; -- commented old code
          --l_usage := 'QUERY_PARTY';
            p_action_param :=  p_action_param || constructParam;
            return;
	    END IF;
   END IF;

   IF (( l_partyId = 0) and (l_ani is not null )) THEN
       GetDtlsFromPhoneNum;
       foo_action_param := constructparam;
       p_action_param := p_action_param || foo_action_param;
	  if l_usage = 'QUERY_ANI' then
	  -- kmahajan - commented out line below as IEX also uses it now
	  -- and p_action_name = 'AST_RC_ALL' then
		p_action_name := 'AST_MEDIA';
   		p_action_type := 2;
	  end if;
   Else
       foo_action_param := constructparam;
       p_action_param := p_action_param || foo_action_param;
   END IF;

   LogMessage('Exiting OTS Inbound Foo Function');

END handleOTSInbound;

PROCEDURE handleEmail (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) is

BEGIN
    handleOTSInbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
END;

PROCEDURE handleOTSOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY varchar2,
				p_action_param OUT NOCOPY varchar2) IS
BEGIN

   p_action_type :=1;
   p_action_name := G_Currentform;
   p_action_param := '';

   LogMessage('Inside OTS outbound Foo function');
   setDefaults;
   getCallData(p_mediaTable);

   if l_blocked then
	p_action_type := 2;
	p_action_name := 'AST_MEDIA';
	p_action_param := 'BLOCKED="TRUE" ';
   end if;

   l_partyID := l_customerID; -- added by rnori 14-Apr-03 bug # 2897623
   p_action_param := p_action_param || constructparam;
   LogMessage('Exiting OTS Outbound Foo function');

END handleOTSOutbound ;

PROCEDURE handleOCInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) IS

BEGIN
  --added by vimpi on 11th Feb/2002 to incorporate IVR popup by invoice Number
   --getCallData(p_mediaTable);
   -- kmahajan - above line commented out as OTSinbound calls getcalldata also
   --changes ended
    handleOTSInbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
   -- kmahajan - encapsulated this code in if-then-else to support AST_MEDIA for IEX
   if p_action_name <> 'AST_MEDIA' then
	p_action_name := 'IEX_RC_CALL';
   	--kmahajan 10/07/2002 - commented line below
	--anyways, it was redundant; now it's incorrect after introducing l_block
	--p_action_type := 1;
   else
	p_action_param := p_action_param || ' LAUNCH_FUNCTION="IEX_RC_CALL" ';
   end if;

END;

PROCEDURE handleOCOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2) IS

BEGIN
   handleOTSOutbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
   -- kmahajan - encapsulated this code in if-then-else to support AST_MEDIA for IEX
   if p_action_name <> 'AST_MEDIA' then
	p_action_name := 'IEX_RC_CALL';
   	--kmahajan 10/07/2002 - commented line below
	--anyways, it was redundant; now it's incorrect after introducing l_block
	--p_action_type := 1;
   else
	p_action_param := p_action_param || ' LAUNCH_FUNCTION="IEX_RC_CALL" ';
   end if;

END;


Procedure setCurrentForm(p_formName varchar2) IS
BEGIN

	G_CurrentForm := upper(p_formName);
END setCurrentForm ;

/*** added by vimpi on 18th october 20001*/
--modified getFooData and handleFooTask to temp. handle Marketing list node
--call to ebc with additional parameters. jraj 5th Nov. 2002.
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

--modified getFooData and handleFooTask to temp. handle Marketing list node
--call to ebc with additional parameters. jraj 5th Nov. 2002.
PROCEDURE handleFooTask (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY varchar2,
			    p_action_param OUT NOCOPY varchar2,
			    p_msg_name     OUT NOCOPY varchar2,
			    p_msg_param    OUT NOCOPY varchar2,
			    p_dialog_style OUT NOCOPY NUMBER,
			    p_msg_appl_short_name OUT NOCOPY varchar2) is
cursor c_source_code_id(p_schedule_id number, p_source_code varchar2) is
select source_code_id from ams_source_codes where
--source_code_for_id = p_schedule_id and /* Commented for bug#4453994 */
--arc_source_code_for = 'CSCH' and /* Commented for bug#4453994 */
source_code = p_source_code;

cursor c2_source_code_id(p_source_code varchar2) is
select source_code_id from ams_source_codes where
source_code = p_source_code;
BEGIN

   logmessage('Responsibility Application id ' || fnd_profile.value('RESP_APPL_ID')) ;

   l_task_id            := '';
   l_source_code        := '';
   l_source_code_id     := '';
   l_source_campaign_id := 0;
   l_nm_party_id        := 0;

   getFooData(p_mediaTable);

   If l_nm_party_id <> 0 then
	p_action_name := 'AST_RC_ALL';

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

   elsif (l_source_object_type = 'Party') then
      if(fnd_profile.value('RESP_APPL_ID') = '695') then
	    p_action_name := 'IEXRCALL' ;
      else
            p_action_name := 'AST_RC_ALL';
      end if ;
      p_action_param := 'USAGE=QUERY_TASK TASK_ID='|| l_Task_ID ;
      p_action_type := 1;
   else
       p_action_name := 'JTFTKMAN' ;
       p_action_param := 'TASK_ID=' || l_Task_ID;
       p_action_type := 2;
   end if ;
   p_msg_name := 'NULL' ;
   p_msg_param := 'NULL' ;
   p_dialog_style := 1; /* IEU_DS_CONSTS_PUB.G_DS_NONE ; */
   --p_msg_appl_short_name := 'AST' ;
   p_msg_appl_short_name := 'NULL' ;
END handleFooTask ;


BEGIN
    l_Profile :=  NVL(FND_PROFILE.VALUE('AST_MATCH_CAMP_DNIS'), 'N');
    l_DumpData := NVL(FND_PROFILE.VALUE('AST_DUMP_PARAMS'), 'N');
    l_NoAreaCodeMatch := NVL(fnd_profile.value('AST_ANI_WITHOUT_AREACODE'), 'N');

END AST_UWQ_SEL_PKG;

/
