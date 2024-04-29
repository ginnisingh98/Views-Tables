--------------------------------------------------------
--  DDL for Package Body OKL_UWQ_SEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UWQ_SEL_PKG" AS
/* $Header: OKLRUWQB.pls 120.5 2006/08/11 10:47:52 gboomina noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

------------------------------------------------------------------------------
--  Procedure	: setDefaults
--  Usage	:
--  Description	: This procedure sets the default every time
--- this package gets executed
   l_eventName          VARCHAR2(60);
   l_partyId            NUMBER;
   l_partyType          VARCHAR2(30);
   l_customerNumber     NUMBER;
   l_contactId          NUMBER;
   l_contactNumber      NUMBER;
   l_eventConfCode      VARCHAR2(30);
   l_eventId            NUMBER;
   l_collateralReqNum   VARCHAR2(30) ;
   l_collateralId       NUMBER;
   l_campaignCode       VARCHAR2(30);
   l_campaignId         NUMBER;
   l_campaignCodeID     NUMBER;
   l_CampScheduleID     NUMBER;
   l_dnis               VARCHAR2(30);
   l_callId             VARCHAR2(80);
   l_ani                VARCHAR2(40);
   l_accountCode        NUMBER;
   l_usage              VARCHAR2(60);
   l_agentID            VARCHAR2(60);
   l_mediaType          VARCHAR2(80);
   l_mediaItemID        VARCHAR2(60);
   l_workitemID         VARCHAR2(60);
   l_sendername         VARCHAR2(60);
   l_subject            VARCHAR2(60);
   l_messageID          VARCHAR2(60);
   l_MoreAniMatch       VARCHAR2(10);

PROCEDURE setDefaults IS
BEGIN
   l_eventName         := '';
   l_partyId           := 0;
   l_partyType         := '';
   l_customerNumber    := 0;
   l_contactId         := 0;
   l_contactNumber     := 0;
   l_eventConfCode     := '';
   l_eventId           := 0;
   l_collateralReqNum  := '';
   l_collateralId      := 0;
   l_campaignCode      := '';
   l_campaignId        := 0;
   l_campScheduleID    := 0;
   l_campaignCodeID    := 0;
   l_dnis              := '';
   l_callId            := '';
   l_ani               := '';
   l_accountcode       := 0;
   l_usage             := '';
   l_agentID           := '';
   l_mediaType         := '';
   l_mediaItemID       := '';
   l_workitemID        := '';
   l_sendername        := '';
   l_subject           := '';
   l_messageID         := '';
   l_MoreAniMatch      := 'N';
END setDefaults;
-- private package to return the param type  value
PROCEDURE   getCallData(p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST) IS
BEGIN
   FOR i IN 1 .. p_mediaTable.COUNT LOOP
	     IF ( UPPER(p_mediaTable(i).param_name) = 'OCCTEVENTNAME' ) THEN
	         l_eventname := p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) =  'IEU_AMS_CAMPAIGN_ID' ) THEN
	         l_CampaignID := p_mediaTable(i).param_value;
		ELSIF ( UPPER(p_mediaTable(i).param_name) =  'CAMPAIGN_SCHEDULE_ID' ) THEN
	         l_CampScheduleID := p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'CustomerID' ) THEN
	         l_partyID :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'CustomerNumber' ) THEN
		    l_customerNumber  :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'CUSTOMERID' ) THEN
	         l_partyID :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'CUSTOMERNUM' ) THEN
	         l_customerNumber :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'CONTACTNUM' ) THEN
	         l_contactnumber :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediatable(i).param_name)='EVENTCONFCODE') THEN
	         l_eventConfCode := p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediatable(i).param_name)='COLREQNUM') THEN
	         l_collateralReqNum := p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'PROMOTIONCODE' ) THEN
	        l_campaignCode :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OCCTDNIS' ) THEN
	        l_dnis :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OCCTCALLID' ) THEN
	        l_callId :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OCCTANI' ) THEN
	        l_ani :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'ACCOUNTCODE' ) THEN
	        l_accountCode :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OCCTAGENTID' ) THEN
	        l_agentID :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OCCTMEDIATYPE' ) THEN
	        l_mediaType :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OIEMMESSAGEID' ) THEN
	        l_messageID :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OIEMSUBJECT' ) THEN
	        l_subject :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OIEMSENDERNAME' ) THEN
	        l_sendername :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'WORKITEMID' ) THEN
	        l_workitemID :=  p_mediaTable(i).param_value;
	     ELSIF ( UPPER(p_mediaTable(i).param_name) = 'OCCTMEDIAITEMID' ) THEN
	        l_mediaItemID :=  p_mediaTable(i).param_value;
       ELSIF ( UPPER(p_mediaTable(i).param_name) = 'PARTY_ID' ) THEN
              l_partyId := TO_NUMBER(p_mediaTable(i).param_value);
	     END IF;
   END LOOP;
END getCallData ;
-- procedure to construct the paramlist to be passed to the form
FUNCTION  constructparam RETURN VARCHAR2  IS
l_paramlist VARCHAR2(3000);
BEGIN
   l_paramlist := '';
   IF ( l_partyId <> 0 ) THEN
      l_paramlist := l_paramlist  || 'PARTY_ID' || '="' || l_partyId ||'" ';
   END IF;
   IF ( l_partyType IS NOT NULL ) THEN
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
   IF (l_CampaignCodeID <> 0) THEN
      l_paramlist := l_paramlist  || 'SOURCE_CAMPAIGN_ID' || '="' || l_campaignCodeId ||'"

';
   END IF;
   IF (l_CampaignCode <> 0) THEN
      l_paramlist := l_paramlist  || 'CAMPAIGN_SOURCE_CODE' || '="' || l_campaignCode ||'"

';
   END IF;
   IF (l_CampScheduleID <> 0) THEN
      l_paramlist := l_paramlist  || 'CAMPAIGN_SCHEDULE_ID' || '="' || l_campScheduleId ||'"

';
   END IF;
   IF ( l_callID IS NOT NULL ) THEN
      l_paramlist := l_paramlist  || 'TM_CALL_ID' || '="' || l_callID ||'" ';
   END IF;
   IF ( l_accountcode <> 0 )  THEN
       l_paramlist := l_paramlist  || 'CUST_ACCOUNT_ID' || '="' || l_accountCode ||'" ';
   END IF;
   IF ( l_eventname IS NOT NULL )  THEN
       l_paramlist := l_paramlist  || 'UWQ_EVENTNAME' || '="' || l_eventname ||'" ';
   END IF;
   IF ( l_dnis IS NOT NULL )  THEN
       l_paramlist := l_paramlist  || 'TM_DNIS' || '="' || l_dnis ||'" ';
   END IF;
   IF ( l_ani IS NOT NULL)  THEN
       l_paramlist := l_paramlist  || 'TM_ANI' || '="' || l_ani ||'" ';
   END IF;
   IF ( l_mediaType IS NOT NULL  )  THEN
       l_paramlist := l_paramlist  || 'UWQ_MEDIATYPE' || '="' || l_mediatype ||'" ';
   END IF;
   IF ( l_mediaItemID IS NOT NULL)  THEN
       l_paramlist := l_paramlist  || 'UWQ_MEDIAITEM_ID' || '="' || l_mediaItemID || '" ';
   END IF;
   IF ( l_workitemID IS NOT NULL )  THEN
       l_paramlist := l_paramlist  || 'UWQ_WORKITEM_ID' || '="' || l_workitemID ||'" ';
   END IF;
   IF ( l_sendername IS NOT NULL )  THEN
       l_paramlist := l_paramlist  || 'EM_SENDERNAME' || '="' || l_sendername ||'" ';
   END IF;
   IF ( l_subject IS NOT NULL )  THEN
       l_paramlist := l_paramlist  || 'EM_SUBJECT' || '="' || l_subject ||'" ';
   END IF;
   IF ( l_messageID IS NOT NULL) THEN
       l_paramlist := l_paramlist  || 'EM_MESSAGE_ID' || '="' || l_messageID ||'" ';
   END IF;
   IF (l_MoreAniMatch = 'Y') THEN
	 l_Usage := 'QUERY_ANI';
   END IF;
   IF ((l_usage IS NULL) AND (l_partyId = 0)) THEN
      l_usage := 'QUERY_LKP';
   END IF;
   -- append the usage parameter
   l_paramlist := l_paramlist  || ' CALLED_FROM = "UWQ" ';
   IF (l_usage IS NOT NULL) THEN
	 l_paramlist := l_paramlist || ' USAGE' || '="' || l_usage ||'" ';
   END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Param List Before Return ' || l_paramList);
  END IF;
  RETURN l_paramlist;
EXCEPTION
  WHEN OTHERS THEN
     l_paramlist := ' CALLED_FROM = "UWQ" ';
     RETURN l_paramlist;
END constructparam;
-- procedure get details from event confirmation number
PROCEDURE getDtlsFromEvent IS
   CURSOR C_GetEventDetails(x_eventConfCode VARCHAR2) IS
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
PROCEDURE Getcampaigncode IS
/*
      SELECT campaign_id
      FROM ams_campaigns_all_b
      WHERE translate(inbound_phone_no,'0123456789()/\-. ','0123456789')=x_inbound_phone
	    AND status_code ='ACTIVE';
   CURSOR c_campaignId(x_inbound_phone VARCHAR2) IS
     SELECT SOC.SOURCE_CODE_ID, SOC.SOURCE_CODE, SOC.SOURCE_CODE_FOR_ID
     FROM aMS_SOURCE_CODES SOC, AMS_ACT_CONTACT_POINTS AACP
     WHERE SOC.SOURCE_CODE_FOR_ID = AACP.ACT_CONTACT_USED_BY_ID AND
      SOC.ARC_SOURCE_CODE_FOR = AACP.ARC_CONTACT_USED_BY AND
      SOC.ACTIVE_FLAG = 'Y' AND AACP.CONTACT_POINT_TYPE = 'PHONE'
      AND AACP.CONTACT_POINT_VALUE = x_inbound_phone;
   CURSOR c_campaigncode(x_campaigncode VARCHAR2) IS
      SELECT source_code_id, source_code_for_id
	    FROM ams_source_codes
	    WHERE source_code = x_campaignCode
	    AND active_flag = 'Y';
      lx_CampaignCode varchar2(100);
      lx_CampaignCodeId number;
      lx_CampaignId     number;
*/
BEGIN
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside Campaign Code Match');
   END IF;
/*
   IF ( l_campaigncode IS NOT NULL ) THEN
      OPEN c_campaigncode(l_CampaignCode);
      FETCH c_campaigncode INTO l_campaignCodeId, l_campaignid;
      CLOSE c_campaigncode;
   ELSIF ( l_dnis IS NOT NULL ) THEN
       LogMessage('Inside DNIS Code Match ' || l_dnis);
       OPEN c_campaignid(l_dnis);
       FETCH c_campaignid INTO l_campaignCodeId, l_CampaignCode, l_CampaignID;
       IF ( c_campaignid%found) THEN
           LogMessage('Inside DNIS Code Match Success : Source Code ' || l_CampaignCode
                || ' Source Code Id ' || l_CampaignCodeID);
           FETCH c_campaignid INTO lx_campaignCodeId, lx_CampaignCode, lx_CampaignID;
           IF (c_CampaignId%FOUND) then
	       LogMessage('MoreCampaign Code Match. Will be using default is set ');
               lx_campaignCode := FND_PROFILE.VALUE('AST_DEFAULT_SOURCE_CODE');
               if lx_CampaignCode is not NULL then
                   OPEN c_campaigncode(lx_CampaignCode);
                   FETCH c_campaigncode INTO l_campaignCodeId, l_campaignid;
                   IF c_CampaignCode%FOUND THEN
                      l_CampaignCode := lx_CampaignCode;
                   END IF;
                   CLOSE c_campaigncode;
               END IF;
            END IF;
         END IF;
         CLOSE c_campaignid;
    END IF;
*/
EXCEPTION
    WHEN OTHERS THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'GetCampaignCode Exception Occurred');
      END IF;
      RETURN;
END;
-- procedure to get the collateral request Id from a collateral request confirmation
-- number
PROCEDURE getDtlsFromColReq IS
   CURSOR C_getDtlsFromColReq(x_collateralReqNum NUMBER ) IS
      SELECT quote_header_id,party_id,cust_account_id,l_contactid
	    FROM ASO_QUOTE_HEADERS_ALL
	    WHERE quote_number = x_collateralReqNum;
BEGIN
   OPEN C_getDtlsFromColReq(TO_NUMBER(l_collateralreqnum));
   FETCH C_getDtlsFromColReq INTO l_collateralId,l_partyId, l_accountCode,l_contactId;
   IF (c_getdtlsfromcolreq%NOTFOUND )THEN
      l_collateralid := 0;
   END IF;
   CLOSE C_getDtlsFromColReq;
END getDtlsFromColReq;
-- private procedure to get the partyId
PROCEDURE GetDtlsFromConNum IS
	CURSOR C_getDtlsFromConNum(x_contactNum VARCHAR2 ) IS
	SELECT p.party_id, rel.object_id
	FROM   hz_parties p, hz_relationships_v rel
	WHERE  p.party_number = x_contactNum
        AND   p.party_id = rel.party_id;
BEGIN
	OPEN C_getDtlsFromConNum (l_contactNumber);
	FETCH  C_getDtlsFromConNum INTO l_contactId, l_partyId ;
	CLOSE C_getDtlsFromConNum;
END GetDtlsFromConNum;
PROCEDURE GetDtlsFromCustNum IS
   CURSOR C_GetCustId(x_custnum VARCHAR2) IS
      SELECT party_id
	FROM hz_parties
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
/*
	CURSOR C_getDtlsFromPhoneNum(x_phonenumber VARCHAR2 ) IS
	SELECT party_id, party_type
	FROM   JTF_CONTACT_POINTS_V
	WHERE  phone_number = x_phonenumber AND status = 'A' ;
	CURSOR C_getDtlsFromAreaPhoneNum(x_phonenumber VARCHAR2 ) IS
	SELECT party_id, party_type
	FROM   JTF_CONTACT_POINTS_V
	 WHERE  (AREA_CODE||PHONE_NUMBER) = x_phonenumber AND status = 'A';
	CURSOR C_GetSubObj(p_rel_partyid NUMBER) IS
	   SELECT object_id, subject_id FROM
		 HZ_PARTY_RELATIONSHIPS WHERE PARTY_ID = p_rel_partyid;
     l_rel_partyid  NUMBER := NULL;
	l_partyIDNext  NUMBER;
	l_partyTypeNext VARCHAR2(150);
 */
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside Phone Number Match, l_Ani:  ' || l_Ani || ' l_NoAreaCodeMatch = '

  || l_NoAreaCodeMatch );

       END IF;
/*
	IF (l_NoAreaCodeMatch = 'Y') THEN
	   BEGIN
		OPEN C_getDtlsFromPhoneNum (l_ani);
		FETCH  C_getDtlsFromPhoneNum INTO l_partyId, l_partyType;
		IF C_getDtlsFromPhoneNum%FOUND THEN
                     LogMessage('First ANI Matched. Party ID ' || l_PartyID || '

l_PartyType=  ' || l_PartyType );
		     FETCH C_getDtlsFromPhoneNum INTO l_partyIDNext, l_partyTypeNext;
		     IF C_GetDtlsFromPhoneNum%FOUND THEN
		        l_MoreAniMatch := 'Y';
                        LogMessage('More ANI Matched. Party ID ' || l_PartyID || '

l_PartyType=  ' || l_PartyType );
		     END IF;
		END IF;
		CLOSE C_getDtlsFromPhoneNum;
        EXCEPTION
	   WHEN OTHERS THEN
              LogMessage('Cursor GetDtlsFromPhoneNum Exception Occurred');
              CLOSE C_GetDtlsFromPhoneNum;
        END;
	ELSE
	   BEGIN
	    OPEN C_getDtlsFromAreaPhoneNum(l_ani);
	    FETCH C_getDtlsFromAreaPhoneNum INTO l_partyId, l_partyType;
	    IF C_getDtlsFromAreaPhoneNum%FOUND THEN
                LogMessage('First ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=  '

|| l_PartyType );
		FETCH C_getDtlsFromAreaPhoneNum INTO l_partyIDNext, l_partyTypeNext;
		IF C_GetDtlsFromAreaPhoneNum%FOUND THEN
		   l_MoreAniMatch := 'Y';
                   LogMessage('More ANI Matched. Party ID ' || l_PartyID || ' l_PartyType=

' || l_PartyType );
		END IF;
	    END IF;
	    CLOSE C_getDtlsFromAreaPhoneNum;
        EXCEPTION
		WHEN OTHERS THEN
                 LogMessage('Cursor GetDtlsFromAreaPhoneNum Exception occurred ');
	         CLOSE C_getDtlsFromAreaPhoneNum;
        END;
	END IF;
	IF l_PartyType = 'PARTY_RELATIONSHIP' THEN
	  BEGIN
	    l_Usage := 'QUERY_CON';
	    OPEN c_GetSubObj(l_partyid);
	    FETCH c_GetSubObj INTO l_partyID, l_ContactID;
	    IF (l_MoreAniMatch <> 'Y') THEN
	    	 l_PartyType := 'ORGANIZATION';
	    END IF;
	    CLOSE C_GetSubObj;
       EXCEPTION
	    WHEN OTHERS THEN
              LogMessage(' Cursor GetSubObj Exception occurred ');
	      CLOSE C_GetSubObj;
       END;
	ELSIF l_partyType = 'PERSON' THEN
	    l_Usage := 'QUERY_CONSUMER';
     ELSIF l_partyType = 'ORGANIZATION' THEN
         l_Usage := 'QUERY_ORG';
	END IF;
      LogMessage('GetDtlsFromPhoneNum done');
*/
EXCEPTION
	WHEN OTHERS THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'GetDtlsFromPhoneNum Exception Occurred');
            END IF;
	    RETURN;
END GetDtlsFromPhoneNum;
PROCEDURE handleOTSInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY VARCHAR2,
			    p_action_param OUT NOCOPY VARCHAR2) IS
   foo_action_param VARCHAR2(3000);
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
--   setCurrentForm('ASTTMPOP');
   p_action_type :=1;
   p_action_name := G_CurrentForm;
   p_action_param := '';
   setDefaults;
   getCallData(p_mediaTable);
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside Foo function ');
   END IF;
   IF (l_CampaignID = 0) AND (l_profile = 'Y') THEN
	   getCampaignCode;
   END IF;
   IF ( l_eventConfCode <> '' ) THEN
      getDtlsFromEvent;
      IF ( l_eventid <> 0 ) THEN
	        -- we found the match, hence we can query the event details
	        l_usage := 'QUERY_EVENT';
	        -- open the form using app_navigate.execute
	        p_action_param :=  constructParam;
	        RETURN;
      END IF;
   END IF;
   IF ( l_collateralReqNum <> '' ) THEN
      getDtlsFromColReq;
      IF (l_collateralid <> 0 ) THEN
	         l_usage := 'QUERY_COL';
	         p_action_param :=  constructParam;
	         RETURN;
      END IF;
   END IF;
   IF ( l_AccountCode <> '' ) THEN
      getDtlsFromAccountNum;
      IF ( l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_CUST';
	        p_action_param := constructparam;
	        RETURN;
      END IF;
   END IF;
   IF ( l_contactNumber <> '' ) THEN
      getDtlsFromConNum;
      IF ( l_contactid <> 0  OR l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_CON';
	        p_action_param := constructparam;
	        RETURN;
      END IF;
   END IF;
   IF ( l_customerNumber <> '' ) THEN
      getDtlsFromCustNum;
      IF (  l_partyId <> 0 ) THEN
	        l_usage := 'QUERY_CUST';
	        p_action_param := constructparam;
	        RETURN;
      END IF;
   END IF ;
   IF (( l_partyId = 0) AND (l_ani IS NOT NULL )) THEN
       GetDtlsFromPhoneNum;
       foo_action_param := constructparam;
       p_action_param := foo_action_param;
   ELSE
       foo_action_param := constructparam;
       p_action_param := foo_action_param;
   END IF;
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Existing OTS Inbound Foo Function');
   END IF;
END handleOTSInbound;
PROCEDURE handleEmail (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY VARCHAR2,
			    p_action_param OUT NOCOPY VARCHAR2) IS
BEGIN
    handleOTSInbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
END;
PROCEDURE handleOTSOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
				p_action_type OUT NOCOPY NUMBER,
				p_action_name OUT NOCOPY VARCHAR2,
				p_action_param OUT NOCOPY VARCHAR2) IS
BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
   p_action_type :=1;
   p_action_name := G_Currentform;
   p_action_param := '';
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside OTS outbound Foo function');
   END IF;
   setDefaults;
   getCallData(p_mediaTable);
   p_action_param := constructparam;
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Exiting OTS Outbound Foo function');
   END IF;
END handleOTSOutbound ;
PROCEDURE handleOCInbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY VARCHAR2,
			    p_action_param OUT NOCOPY VARCHAR2) IS
BEGIN
    handleOTSInbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
   p_action_name := 'IEXRCALL';
   p_action_type := 1;
END;
PROCEDURE handleOCOutbound (p_mediaTable IN SYSTEM.IEU_UWQ_MEDIA_DATA_NST,
			    p_action_type OUT NOCOPY NUMBER,
			    p_action_name OUT NOCOPY VARCHAR2,
			    p_action_param OUT NOCOPY VARCHAR2) IS
BEGIN
   handleOTSOutbound(p_mediaTable, p_action_type, p_action_name, p_action_param);
   p_action_name := 'IEXRCALL';
   p_action_type := 1;
END;
PROCEDURE setCurrentForm(p_formName VARCHAR2) IS
BEGIN
	G_CurrentForm := UPPER(p_formName);
END setCurrentForm ;
BEGIN
    l_Profile :=  NVL(Fnd_Profile.VALUE('AST_MATCH_CAMP_DNIS'), 'N');
    l_DumpData := NVL(Fnd_Profile.VALUE('AST_DUMP_PARAMS'), 'N');
    l_NoAreaCodeMatch := NVL(Fnd_Profile.value('AST_ANI_WITHOUT_AREACODE'), 'N');
END Okl_Uwq_Sel_Pkg;

/
