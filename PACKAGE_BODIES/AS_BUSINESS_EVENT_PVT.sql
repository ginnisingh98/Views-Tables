--------------------------------------------------------
--  DDL for Package Body AS_BUSINESS_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_BUSINESS_EVENT_PVT" as
/* $Header: asxvbevb.pls 120.1 2005/06/14 01:33:53 appldev  $ */

--
-- NAME
--   AS_BUSINESS_EVENT_PVT
--
-- HISTORY
--   9/17/2003        SUMAHALI        CREATED
--
--

G_PKG_NAME      CONSTANT VARCHAR2(30):='AS_BUSINESS_EVENT_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12):='asxvbevb.pls';

G_DUMMY_DATE    CONSTANT DATE := to_date('11/11/9999', 'MM/DD/YYYY');

TYPE AS_EVENT_REC_T IS RECORD (
    event_name  VARCHAR2(240),
    event_key   VARCHAR2(240),
    event_code  VARCHAR2(1)
);
TYPE AS_EVENT_TABLE_T IS TABLE OF AS_EVENT_REC_T INDEX BY BINARY_INTEGER;


FUNCTION Event_data_delete
-- Rule function for event data deletions used as the last subscription to AS events
 (p_subscription_guid  IN RAW,
  p_event              IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
 l_key VARCHAR2(240);
BEGIN
  SAVEPOINT Event_data_delete;

  l_key := p_event.GetEventKey();

  DELETE FROM as_event_data
  WHERE event_key = l_key;

  RETURN 'SUCCESS';

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'EVENT_DATA_DELETE', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'WARNING');

    RETURN 'WARNING';

  WHEN OTHERS  THEN
    ROLLBACK TO Event_data_delete;

    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'EVENT_DATA_DELETE', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');

    RETURN 'ERROR';
END;

FUNCTION event(p_event_name IN VARCHAR2) RETURN VARCHAR2
-----------------------------------------------
-- Return event name if the entered event exist
-- Otherwise return NOTFOUND
-----------------------------------------------
IS
 RetEvent VARCHAR2(240);
BEGIN
  SELECT name INTO RetEvent
    FROM wf_events
   WHERE name = p_event_name;
  IF SQL%NOTFOUND THEN
    RetEvent := 'NOTFOUND';
  END IF;
  RETURN RetEvent;
END event;


FUNCTION exist_subscription(p_event_name IN VARCHAR2) RETURN VARCHAR2
-----------------------------------------------------------------------
-- Return 'Y' if the subscription exist
-- Otherwise it returns 'N'
-----------------------------------------------------------------------
IS
 CURSOR cu0 IS
  SELECT 'Y'
    FROM wf_events eve,
         wf_event_subscriptions sub
   WHERE eve.name   = p_event_name
     AND eve.status = 'ENABLED'
     AND eve.guid   = sub.event_filter_guid
     AND UPPER(sub.rule_function) = 'AS_BUSINESS_EVENT_PVT.EVENT_DATA_DELETE'
     AND sub.status = 'ENABLED'
     AND sub.source_type = 'LOCAL'
     AND EXISTS (
       SELECT 'X'
       FROM wf_event_subscriptions sub1
       WHERE sub1.event_filter_guid = eve.guid
       AND UPPER(sub1.rule_function) <> 'AS_BUSINESS_EVENT_PVT.EVENT_DATA_DELETE'
       AND sub1.status = 'ENABLED'
       AND sub1.source_type = 'LOCAL')
;


 l_yn  VARCHAR2(1);
BEGIN
 OPEN cu0;
  FETCH cu0 INTO l_yn;
  IF cu0%NOTFOUND THEN
     l_yn := 'N';
  END IF;
 CLOSE cu0;
 RETURN l_yn;
END exist_subscription;


FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2
-----------------------------------------------------
-- Return Item_Key according to As Event to be raised
-- Item_Key is <Event_Name>-AS_BUSINESS_EVENT_S.nextval
-----------------------------------------------------
IS
 RetKey VARCHAR2(240);
BEGIN
 SELECT p_event_name || AS_BUSINESS_EVENT_S.nextval INTO RetKey FROM DUAL;
 RETURN RetKey;
END item_key;


PROCEDURE Copy_Event_Data(
    p_old_event_key IN VARCHAR2,
    p_new_event_key IN VARCHAR2
) IS
BEGIN
    insert into AS_EVENT_DATA (
        EVENT_DATA_ID,
        EVENT_KEY, OBJECT_STATE,
        LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CHAR01, CHAR02, CHAR03, CHAR04, CHAR05, CHAR06, CHAR07, CHAR08,
        CHAR09, CHAR10, CHAR11, CHAR12, CHAR13, CHAR14, CHAR15, CHAR16,
        CHAR17, CHAR18, CHAR19, CHAR20, CHAR21, CHAR22, CHAR23, CHAR24,
        CHAR25, CHAR26, CHAR27, CHAR28, CHAR29, CHAR30, CHAR31, CHAR32,
        CHAR33, CHAR34, CHAR35, CHAR36, CHAR37, CHAR38, CHAR39, CHAR40,
        CHAR41, CHAR42, CHAR43, CHAR44, CHAR45, CHAR46, CHAR47, CHAR48,
        CHAR49, CHAR50, CHAR51, CHAR52, CHAR53, CHAR54, CHAR55, CHAR56,
        CHAR57, CHAR58, CHAR59, CHAR60, CHAR61, CHAR62, CHAR63, CHAR64,
        CHAR65, CHAR66, CHAR67, CHAR68, CHAR69, CHAR70, CHAR71, CHAR72,
        CHAR73, CHAR74, CHAR75, CHAR76, CHAR77, CHAR78, CHAR79, CHAR80,
        NUM01, NUM02, NUM03, NUM04, NUM05, NUM06, NUM07, NUM08, NUM09,
        NUM10, NUM11, NUM12, NUM13, NUM14, NUM15, NUM16, NUM17, NUM18,
        NUM19, NUM20, NUM21, NUM22, NUM23, NUM24, NUM25, NUM26, NUM27,
        NUM28, NUM29, NUM30,
        DATE01, DATE02, DATE03, DATE04, DATE05, DATE06, DATE07, DATE08,
        DATE09, DATE10, DATE11, DATE12, DATE13, DATE14, DATE15
    )
    select
        AS_EVENT_DATA_S.nextval,
        p_new_event_key, OBJECT_STATE,
        SYSDATE, SYSDATE, CREATED_BY, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CHAR01, CHAR02, CHAR03, CHAR04, CHAR05, CHAR06, CHAR07, CHAR08,
        CHAR09, CHAR10, CHAR11, CHAR12, CHAR13, CHAR14, CHAR15, CHAR16,
        CHAR17, CHAR18, CHAR19, CHAR20, CHAR21, CHAR22, CHAR23, CHAR24,
        CHAR25, CHAR26, CHAR27, CHAR28, CHAR29, CHAR30, CHAR31, CHAR32,
        CHAR33, CHAR34, CHAR35, CHAR36, CHAR37, CHAR38, CHAR39, CHAR40,
        CHAR41, CHAR42, CHAR43, CHAR44, CHAR45, CHAR46, CHAR47, CHAR48,
        CHAR49, CHAR50, CHAR51, CHAR52, CHAR53, CHAR54, CHAR55, CHAR56,
        CHAR57, CHAR58, CHAR59, CHAR60, CHAR61, CHAR62, CHAR63, CHAR64,
        CHAR65, CHAR66, CHAR67, CHAR68, CHAR69, CHAR70, CHAR71, CHAR72,
        CHAR73, CHAR74, CHAR75, CHAR76, CHAR77, CHAR78, CHAR79, CHAR80,
        NUM01, NUM02, NUM03, NUM04, NUM05, NUM06, NUM07, NUM08, NUM09,
        NUM10, NUM11, NUM12, NUM13, NUM14, NUM15, NUM16, NUM17, NUM18,
        NUM19, NUM20, NUM21, NUM22, NUM23, NUM24, NUM25, NUM26, NUM27,
        NUM28, NUM29, NUM30,
        DATE01, DATE02, DATE03, DATE04, DATE05, DATE06, DATE07, DATE08,
        DATE09, DATE10, DATE11, DATE12, DATE13, DATE14, DATE15
    from AS_EVENT_DATA where event_key = p_old_event_key;
END Copy_Event_Data;


-- This function is for subscribing, for testing/debugging of business events,
-- to business events raised by Opportunity and customer sales team modules
-- which log data to as_event_data table. It copies the event_data to new rows
-- in the same as_event_data table so that the debug data can be seen after it
-- is automatically deleted. It creates a new event_key like 'debug<sequence>',
-- The first rows contain the event parameters one by one. The parameter name is
-- stored in CHAR01 and value in CHAR02. Two pseudo parameters EVENT_NAME and
-- EVENT_KEY are added. The subsequent rows contain as_event_data corresponding
-- to the event key received. It is the users responsibility to delete these
-- debug rows from the as_event_data table.
FUNCTION Test_event
-- Rule function for event data deletions used as the last subscription to AS events
 (p_subscription_guid  IN RAW,
  p_event              IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
 l_api_name     CONSTANT VARCHAR2(30) := 'Test_event';
 l_inded        NUMBER;
 l_event_name   VARCHAR2(240) := p_event.GetEventName();
 l_key          VARCHAR2(240) := p_event.GetEventKey();
 l_new_key      VARCHAR2(240);
 l_param        WF_PARAMETER_T;
 l_parameters   WF_PARAMETER_LIST_T := p_event.GetParameterList();
 l_debug        BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
 l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Test_event';
BEGIN
    SAVEPOINT Test_event;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: ' || l_api_name || ' start');
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Event Name = ' || l_event_name || ', key = ' || l_key);
    END IF;

    l_new_key := item_key( 'debug' );


    FOR l_index IN 1..l_parameters.last LOOP
        l_param := l_parameters(l_index);
        insert into AS_EVENT_DATA (
            EVENT_DATA_ID,
            EVENT_KEY, OBJECT_STATE, CHAR01, CHAR02,
            LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
        )
        values (
            AS_EVENT_DATA_S.nextval,
            l_new_key, 'AAA', l_param.GetName(), l_param.GetValue(),
            SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
            FND_GLOBAL.CONC_LOGIN_ID
        );
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                l_param.GetName() || ' : ' || l_param.GetValue()) ;
        END IF;
    END LOOP;

    insert into AS_EVENT_DATA (
        EVENT_DATA_ID,
        EVENT_KEY, OBJECT_STATE, CHAR01, CHAR02,
        LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
    )
    values (
        AS_EVENT_DATA_S.nextval,
        l_new_key, 'AAA', 'EVENT_NAME', l_event_name,
        SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
        FND_GLOBAL.CONC_LOGIN_ID
    );

    insert into AS_EVENT_DATA (
        EVENT_DATA_ID,
        EVENT_KEY, OBJECT_STATE, CHAR01, CHAR02,
        LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
    )
    values (
        AS_EVENT_DATA_S.nextval,
        l_new_key, 'AAA', 'EVENT_KEY', l_key,
        SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
        FND_GLOBAL.CONC_LOGIN_ID
    );

    Copy_Event_Data(l_key, l_new_key);

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: ' || l_api_name || ' end');
    END IF;

    RETURN 'SUCCESS';

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'TEST_EVENT', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'WARNING');

    RETURN 'WARNING';

  WHEN OTHERS  THEN
    ROLLBACK TO Test_event;

    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'TEST_EVENT', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');

    RETURN 'ERROR';
END Test_event;

PROCEDURE AddParamEnvToList
------------------------------------------------------
-- Add Application-Context parameter to the enter list
------------------------------------------------------
( x_list              IN OUT NOCOPY  WF_PARAMETER_LIST_T,
  p_user_id           IN VARCHAR2  DEFAULT NULL,
  p_resp_id           IN VARCHAR2  DEFAULT NULL,
  p_resp_appl_id      IN VARCHAR2  DEFAULT NULL,
  p_security_group_id IN VARCHAR2  DEFAULT NULL,
  p_org_id            IN VARCHAR2  DEFAULT NULL)
IS
 l_user_id           VARCHAR2(255) := p_user_id;
 l_resp_appl_id      VARCHAR2(255) := p_resp_appl_id;
 l_resp_id           VARCHAR2(255) := p_resp_id;
 l_security_group_id VARCHAR2(255) := p_security_group_id;
 l_org_id            VARCHAR2(255) := p_org_id;
 l_param             WF_PARAMETER_T;
 l_rang              NUMBER;
BEGIN
   l_rang :=  0;

   IF l_user_id IS NULL THEN
     l_user_id := fnd_profile.value( 'USER_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'USER_ID' );
   l_param.SetValue( l_user_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_id IS NULL THEN
      l_resp_id := fnd_profile.value( 'RESP_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'RESP_ID' );
   l_param.SetValue( l_resp_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_appl_id IS NULL THEN
      l_resp_appl_id := fnd_profile.value( 'RESP_APPL_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'RESP_APPL_ID' );
   l_param.SetValue( l_resp_appl_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF  l_security_group_id IS NULL THEN
       --l_security_group_id := fnd_profile.value( 'SECURITY_GROUP_ID');
       /* BugNo: 3007012 */
       l_security_group_id := fnd_global.security_group_id;
   END IF;
   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'SECURITY_GROUP_ID' );
   l_param.SetValue( l_security_group_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_org_id IS NULL THEN
      l_org_id :=  fnd_profile.value( 'ORG_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName( 'ORG_ID' );
   l_param.SetValue(l_org_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

END;


PROCEDURE raise_event
----------------------------------------------
-- Check if Event exist
-- Check if Event is like 'oracle.apps.as.%'
-- Get the item_key
-- Raise event
----------------------------------------------
(p_event_name          IN   VARCHAR2,
 p_event_key           IN   VARCHAR2,
 p_data                IN   CLOB DEFAULT NULL,
 p_parameters          IN   wf_parameter_list_t DEFAULT NULL)
IS
 l_api_name     CONSTANT VARCHAR2(30) := 'raise_event';
 l_event        VARCHAR2(240);
 l_param        WF_PARAMETER_T;
 l_debug        BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
 l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.raise_event';
BEGIN

 SAVEPOINT as_raise_event;

 -- Debug Message
 IF l_debug THEN
   AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: ' || l_api_name || ' start');
 END IF;

 l_event := event(p_event_name);

 IF l_event = 'NOTFOUND' THEN
    FND_MESSAGE.SET_NAME( 'AS', 'AS_EVENTNOTFOUND');
    FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF SUBSTR(l_event,1,15) <> 'oracle.apps.as.' THEN
   FND_MESSAGE.SET_NAME( 'AS', 'AS_EVENTNOTAS');
   FND_MESSAGE.SET_TOKEN( 'EVENT' ,p_event_name );
   FND_MSG_PUB.ADD;

   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 -- Debug Message
 IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Parameters For Event ' || l_event || ' : ' || p_event_key) ;
    FOR l_index IN 1..p_parameters.last LOOP
        l_param := p_parameters(l_index);
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            l_param.GetName() || ' : ' || l_param.GetValue()) ;
    END LOOP;
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'END Parameters') ;
 END IF;

 Wf_Event.Raise
 ( p_event_name   =>  l_event,
   p_event_key    =>  p_event_key,
   p_parameters   =>  p_parameters,
   p_event_data   =>  p_data);

 -- Debug Message
 IF l_debug THEN
   AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: ' || l_api_name || ' end');
 END IF;
END raise_event;


-- Classifies an Opportunity Status Code and returns one of the following codes
-- O - Open
-- W - Won
-- L - Lost
-- C - Closed
-- I - Invalid status code
FUNCTION Classify_Status(
    p_status    IN VARCHAR2)
RETURN VARCHAR2
IS

  Cursor c_status_flags(p_status VARCHAR2) IS
    select enabled_flag, opp_flag, opp_open_status_flag, win_loss_indicator
    from as_statuses_b
    where status_code = p_status;

l_status_class VARCHAR2(1) := 'I' ;
l_enabled_flag VARCHAR2(1) ;
l_opp_flag VARCHAR2(1) ;
l_opp_open_status_flag VARCHAR2(1) ;
l_win_loss_indicator VARCHAR2(1) ;

BEGIN
    OPEN c_status_flags(p_status);
    FETCH c_status_flags INTO l_enabled_flag, l_opp_flag, l_opp_open_status_flag,
                        l_win_loss_indicator;

    IF c_status_flags%FOUND AND l_enabled_flag = 'Y' AND l_opp_flag = 'Y' THEN
        IF l_opp_open_status_flag = 'Y' THEN
            l_status_class := 'O';
        ELSE
                IF l_win_loss_indicator = 'W' THEN
                    l_status_class := 'W';
                ELSIF l_win_loss_indicator = 'L' THEN
                    l_status_class := 'L';
                ELSE
                    l_status_class := 'C';
                END IF;
        END IF;
    END IF;

    CLOSE c_status_flags;

    RETURN l_status_class;
END;


-- Takes Data snapshot of Opportunity header. Used before and after
-- header update. Take care to keep the function CompareOppSnapShots in sync
-- with this.
PROCEDURE OppDataSnapShot
(p_item_key     IN VARCHAR2,
 p_lead_id      IN NUMBER,
 p_indicator    IN VARCHAR2) IS
BEGIN

  insert into AS_EVENT_DATA (
    EVENT_DATA_ID,
    EVENT_KEY, OBJECT_STATE,
    LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    NUM01, NUM02,
    NUM03, NUM04,
    NUM05,
    NUM06, NUM07,
    NUM08,
    NUM09, NUM10,
    NUM11, NUM12,
    NUM13,
    NUM14,
    NUM15,
    NUM16, NUM17,
    NUM18,
    NUM19,
    NUM20,
    NUM21,

    DATE01, DATE02, DATE03,

    CHAR01, CHAR02,
    CHAR03, CHAR04,
    CHAR05, CHAR06,
    CHAR07,
    CHAR08, CHAR09,
    CHAR10, CHAR11,
    CHAR12,
    CHAR13,
    CHAR14,
    CHAR15, CHAR16,
    CHAR17, CHAR18,
    CHAR19, CHAR20,
    CHAR21, CHAR22,
    CHAR23, CHAR24,
    CHAR25, CHAR26,
    CHAR27, CHAR28,
    CHAR29, CHAR30,
    CHAR31,
    CHAR32,
    CHAR33,
    CHAR34,
    CHAR35,
    CHAR36, CHAR37)
  select
    AS_EVENT_DATA_S.nextval,
    p_item_key, p_indicator,
    SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
    FND_GLOBAL.CONC_LOGIN_ID,

    -- NUM01 - NUM21
    lead_id, customer_id,
    address_id, owner_salesforce_id,
    owner_sales_group_id,
    sales_stage_id, win_probability,
    customer_budget,
    sales_methodology_id, total_amount,
    last_updated_by, created_by,
    close_competitor_id,
    source_promotion_id,
    end_user_customer_id,
    end_user_address_id, org_id,
    price_list_id,
    incumbent_partner_resource_id,
    incumbent_partner_party_id,
    offer_id,

    -- DATE01 - DATE03
    last_update_date, creation_date,
    decision_date,

    -- CHAR01 - CHAR37
    lead_number, status,
    orig_system_reference, channel_code,
    currency_code, close_reason,
    close_competitor_code,
    close_competitor, close_comment,
    description, parent_project,
    auto_assignment_type,
    prm_assignment_type,
    decision_timeframe_code,
    attribute_category, attribute1,
    attribute2, attribute3,
    attribute4, attribute5,
    attribute6, attribute7,
    attribute8, attribute9,
    attribute10, attribute11,
    attribute12, attribute13,
    attribute14, attribute15,
    vehicle_response_code,
    budget_status_code,
    prm_exec_sponsor_flag,
    prm_prj_lead_in_place_flag,
    prm_ind_classification_code,
    prm_lead_type, freeze_flag
  from as_leads_all where lead_id = p_lead_id;

END OppDataSnapShot;


-- Takes Data snapshot of Opportunity Lines. Used before and after
-- line update. Take care to keep the function DiffOppLineSnapShots in sync
-- with this.
PROCEDURE OppLineDataSnapShot
(p_item_key     IN  VARCHAR2,
 p_lead_id      IN  NUMBER,
 p_indicator    IN VARCHAR2) IS
BEGIN

  insert into AS_EVENT_DATA (
    EVENT_DATA_ID,
    EVENT_KEY, OBJECT_STATE,
    LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    NUM01, NUM02,
    NUM03, NUM05,
    NUM12,
    NUM13, NUM14,
    NUM15, NUM19,
    NUM22, NUM23,
    NUM24,

    DATE01, DATE02,
    DATE04, DATE05,
    DATE06,

    CHAR01, CHAR03,
    CHAR06, CHAR07,
    CHAR08, CHAR09,
    CHAR10, CHAR11,
    CHAR12, CHAR13,
    CHAR14, CHAR15,
    CHAR16, CHAR17,
    CHAR18, CHAR19,
    CHAR20, CHAR21,
    CHAR22)
  select
    AS_EVENT_DATA_S.nextval,
    p_item_key, p_indicator,
    SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
    FND_GLOBAL.CONC_LOGIN_ID,

    -- NUM01-03, 05, 12-15, 19, 22-24
    lead_line_id, lead_id,
    last_updated_by, created_by,
    inventory_item_id,
    organization_id, quantity,
    total_amount, org_id,
    offer_id, source_promotion_id,
    price_volume_margin,

    -- DATE01-02, 04-06
    last_update_date, creation_date,
    ship_date, decision_date,
    forecast_date,

    -- CHAR01, 03, 06-22
    status_code, uom_code,
    attribute_category, attribute1,
    attribute2, attribute3,
    attribute4, attribute5,
    attribute6, attribute7,
    attribute8, attribute9,
    attribute10, attribute11,
    attribute12, attribute13,
    attribute14, attribute15,
    rolling_forecast_flag
  from as_lead_lines where lead_id = p_lead_id;

END OppLineDataSnapShot;


-- Takes Data snapshot of SalesTeam. Used before and after SalesTeam
-- update. Take care to keep the function DiffSTeamSnapShots in sync
-- with this.
PROCEDURE OppSTeamDataSnapShot
(p_item_key     IN  VARCHAR2,
 p_lead_id      IN  NUMBER,
 p_indicator    IN VARCHAR2) IS
BEGIN

  insert into AS_EVENT_DATA (
    EVENT_DATA_ID,
    EVENT_KEY, OBJECT_STATE,
    LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    NUM01, NUM02, NUM03, NUM04)
  select
    AS_EVENT_DATA_S.nextval,
    p_item_key, p_indicator,
    SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
    FND_GLOBAL.CONC_LOGIN_ID,

    -- NUM01-09
    salesforce_id, sales_group_id, access_id, lead_id
  from AS_SALES_TEAM_EMP_V where lead_id = p_lead_id;

END OppSTeamDataSnapShot;


-- Takes Data snapshot of SalesTeam. Used before and after SalesTeam
-- update. Take care to keep the function DiffSTeamSnapShots in sync
-- with this.
PROCEDURE CustSTeamDataSnapShot
(p_item_key     IN  VARCHAR2,
 p_cust_id      IN  NUMBER,
 p_indicator    IN VARCHAR2) IS
BEGIN

  insert into AS_EVENT_DATA (
    EVENT_DATA_ID,
    EVENT_KEY, OBJECT_STATE,
    LAST_UPDATE_DATE, CREATION_DATE, CREATED_BY, LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    NUM01, NUM02, NUM03, NUM04, NUM05)
  select
    AS_EVENT_DATA_S.nextval,
    p_item_key, p_indicator,
    SYSDATE, SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.USER_ID,
    FND_GLOBAL.CONC_LOGIN_ID,

    -- NUM01-09
    salesforce_id, sales_group_id, access_id, customer_id, address_id
  from AS_SALES_TEAM_EMP_V where customer_id = p_cust_id and lead_id IS NULL and
                                 sales_lead_id IS NULL;

END CustSTeamDataSnapShot;


-- Compares New and old Opportunity Header SnapShots. Returns a combination of
-- one the following codes:
-- U - Opportunity Updated : Present if code is not N
-- W - Opportunity Won
-- L - Opportunity Lost
-- N - Opportunity not updated : No other code is combined with this
-- Take care to keep the procedure OppDataSnapShot in sync
-- with this.
FUNCTION DiffOppSnapShots(p_event_key  IN VARCHAR2) RETURN VARCHAR2
IS

 l_old_status   VARCHAR(1);
 l_new_status   VARCHAR(1);
 l_RetVal       VARCHAR(4) := 'N';

 Cursor     c_opp_data(p_item_key VARCHAR2, p_indicator VARCHAR2) IS
 select
    NUM01, NUM02,
    NUM03, NUM04,
    NUM05,
    NUM06, NUM07,
    NUM08,
    NUM09, NUM10,
    NUM11, NUM12,
    NUM13,
    NUM14,
    NUM15,
    NUM16, NUM17,
    NUM18,
    NUM19,
    NUM20,
    NUM21,

    DATE01, DATE02, DATE03,

    CHAR01, CHAR02,
    CHAR03, CHAR04,
    CHAR05, CHAR06,
    CHAR07,
    CHAR08, CHAR09,
    CHAR10, CHAR11,
    CHAR12,
    CHAR13,
    CHAR14,
    CHAR15, CHAR16,
    CHAR17, CHAR18,
    CHAR19, CHAR20,
    CHAR21, CHAR22,
    CHAR23, CHAR24,
    CHAR25, CHAR26,
    CHAR27, CHAR28,
    CHAR29, CHAR30,
    CHAR31,
    CHAR32,
    CHAR33,
    CHAR34,
    CHAR35,
    CHAR36, CHAR37
 from as_event_data
 where event_key = p_item_key AND object_state = p_indicator;

 l_old_rec  c_opp_data%ROWTYPE;
 l_new_rec  c_opp_data%ROWTYPE;

BEGIN

    OPEN c_opp_data(p_event_key, 'OLD');
    FETCH c_opp_data INTO l_old_rec;
    CLOSE c_opp_data;

    OPEN c_opp_data(p_event_key, 'NEW');
    FETCH c_opp_data INTO l_new_rec;
    CLOSE c_opp_data;

    IF
        nvl(l_old_rec.NUM01, -99) <> nvl(l_new_rec.NUM01, -99) OR
        nvl(l_old_rec.NUM02, -99) <> nvl(l_new_rec.NUM02, -99) OR
        nvl(l_old_rec.NUM03, -99) <> nvl(l_new_rec.NUM03, -99) OR
        nvl(l_old_rec.NUM04, -99) <> nvl(l_new_rec.NUM04, -99) OR
        nvl(l_old_rec.NUM05, -99) <> nvl(l_new_rec.NUM05, -99) OR
        nvl(l_old_rec.NUM06, -99) <> nvl(l_new_rec.NUM06, -99) OR
        nvl(l_old_rec.NUM07, -99) <> nvl(l_new_rec.NUM07, -99) OR
        nvl(l_old_rec.NUM08, -99) <> nvl(l_new_rec.NUM08, -99) OR
        nvl(l_old_rec.NUM09, -99) <> nvl(l_new_rec.NUM09, -99) OR
        nvl(l_old_rec.NUM10, -99) <> nvl(l_new_rec.NUM10, -99) OR
        nvl(l_old_rec.NUM11, -99) <> nvl(l_new_rec.NUM11, -99) OR
        nvl(l_old_rec.NUM12, -99) <> nvl(l_new_rec.NUM12, -99) OR
        nvl(l_old_rec.NUM13, -99) <> nvl(l_new_rec.NUM13, -99) OR
        nvl(l_old_rec.NUM14, -99) <> nvl(l_new_rec.NUM14, -99) OR
        nvl(l_old_rec.NUM15, -99) <> nvl(l_new_rec.NUM15, -99) OR
        nvl(l_old_rec.NUM16, -99) <> nvl(l_new_rec.NUM16, -99) OR
        nvl(l_old_rec.NUM17, -99) <> nvl(l_new_rec.NUM17, -99) OR
        nvl(l_old_rec.NUM18, -99) <> nvl(l_new_rec.NUM18, -99) OR
        nvl(l_old_rec.NUM19, -99) <> nvl(l_new_rec.NUM19, -99) OR
        nvl(l_old_rec.NUM20, -99) <> nvl(l_new_rec.NUM20, -99) OR
        nvl(l_old_rec.NUM21, -99) <> nvl(l_new_rec.NUM21, -99) OR

        --nvl(l_old_rec.DATE01, G_DUMMY_DATE) <> nvl(l_new_rec.DATE01, G_DUMMY_DATE) OR
        nvl(l_old_rec.DATE02, G_DUMMY_DATE) <> nvl(l_new_rec.DATE02, G_DUMMY_DATE) OR
        nvl(l_old_rec.DATE03, G_DUMMY_DATE) <> nvl(l_new_rec.DATE03, G_DUMMY_DATE) OR

        nvl(l_old_rec.CHAR01, '_$') <> nvl(l_new_rec.CHAR01, '_$') OR
        nvl(l_old_rec.CHAR02, '_$') <> nvl(l_new_rec.CHAR02, '_$') OR
        nvl(l_old_rec.CHAR03, '_$') <> nvl(l_new_rec.CHAR03, '_$') OR
        nvl(l_old_rec.CHAR04, '_$') <> nvl(l_new_rec.CHAR04, '_$') OR
        nvl(l_old_rec.CHAR05, '_$') <> nvl(l_new_rec.CHAR05, '_$') OR
        nvl(l_old_rec.CHAR06, '_$') <> nvl(l_new_rec.CHAR06, '_$') OR
        nvl(l_old_rec.CHAR07, '_$') <> nvl(l_new_rec.CHAR07, '_$') OR
        nvl(l_old_rec.CHAR08, '_$') <> nvl(l_new_rec.CHAR08, '_$') OR
        nvl(l_old_rec.CHAR09, '_$') <> nvl(l_new_rec.CHAR09, '_$') OR
        nvl(l_old_rec.CHAR10, '_$') <> nvl(l_new_rec.CHAR10, '_$') OR
        nvl(l_old_rec.CHAR11, '_$') <> nvl(l_new_rec.CHAR11, '_$') OR
        nvl(l_old_rec.CHAR12, '_$') <> nvl(l_new_rec.CHAR12, '_$') OR
        nvl(l_old_rec.CHAR13, '_$') <> nvl(l_new_rec.CHAR13, '_$') OR
        nvl(l_old_rec.CHAR14, '_$') <> nvl(l_new_rec.CHAR14, '_$') OR
        nvl(l_old_rec.CHAR15, '_$') <> nvl(l_new_rec.CHAR15, '_$') OR
        nvl(l_old_rec.CHAR16, '_$') <> nvl(l_new_rec.CHAR16, '_$') OR
        nvl(l_old_rec.CHAR17, '_$') <> nvl(l_new_rec.CHAR17, '_$') OR
        nvl(l_old_rec.CHAR18, '_$') <> nvl(l_new_rec.CHAR18, '_$') OR
        nvl(l_old_rec.CHAR19, '_$') <> nvl(l_new_rec.CHAR19, '_$') OR
        nvl(l_old_rec.CHAR20, '_$') <> nvl(l_new_rec.CHAR20, '_$') OR
        nvl(l_old_rec.CHAR21, '_$') <> nvl(l_new_rec.CHAR21, '_$') OR
        nvl(l_old_rec.CHAR22, '_$') <> nvl(l_new_rec.CHAR22, '_$') OR
        nvl(l_old_rec.CHAR23, '_$') <> nvl(l_new_rec.CHAR23, '_$') OR
        nvl(l_old_rec.CHAR24, '_$') <> nvl(l_new_rec.CHAR24, '_$') OR
        nvl(l_old_rec.CHAR25, '_$') <> nvl(l_new_rec.CHAR25, '_$') OR
        nvl(l_old_rec.CHAR26, '_$') <> nvl(l_new_rec.CHAR26, '_$') OR
        nvl(l_old_rec.CHAR27, '_$') <> nvl(l_new_rec.CHAR27, '_$') OR
        nvl(l_old_rec.CHAR28, '_$') <> nvl(l_new_rec.CHAR28, '_$') OR
        nvl(l_old_rec.CHAR29, '_$') <> nvl(l_new_rec.CHAR29, '_$') OR
        nvl(l_old_rec.CHAR30, '_$') <> nvl(l_new_rec.CHAR30, '_$') OR
        nvl(l_old_rec.CHAR31, '_$') <> nvl(l_new_rec.CHAR31, '_$') OR
        nvl(l_old_rec.CHAR32, '_$') <> nvl(l_new_rec.CHAR32, '_$') OR
        nvl(l_old_rec.CHAR33, '_$') <> nvl(l_new_rec.CHAR33, '_$') OR
        nvl(l_old_rec.CHAR34, '_$') <> nvl(l_new_rec.CHAR34, '_$') OR
        nvl(l_old_rec.CHAR35, '_$') <> nvl(l_new_rec.CHAR35, '_$') OR
        nvl(l_old_rec.CHAR36, '_$') <> nvl(l_new_rec.CHAR36, '_$') OR
        nvl(l_old_rec.CHAR37, '_$') <> nvl(l_new_rec.CHAR37, '_$')
    THEN
      -- Check if it is opportunity is Won, Lost or Closed or
      -- just updated and fire appropriate event.
      l_RetVal := 'U';
      l_old_status := Classify_Status(l_old_rec.CHAR02);
      l_new_status := Classify_Status(l_new_rec.CHAR02);
      IF l_old_status <> l_new_status THEN
        IF (l_new_status = 'C' OR l_new_status = 'W' OR l_new_status = 'L') AND
           l_old_status <> 'C' AND l_old_status <> 'W' AND l_old_status <> 'L'
        THEN
            l_RetVal := l_RetVal || 'C';
        END IF;
        IF l_new_status = 'W' OR l_new_status = 'L' THEN
            l_RetVal := l_RetVal || l_new_status;
        END IF;
      END IF;
    END IF;

    RETURN l_RetVal;

END DiffOppSnapShots;


-- Compares New and old Opportunity Line SnapShots. If different returns Y
-- else returns N. IF p_delete_flag is TRUE then common records are deleted.
-- Take care to keep the procedure OppLineDataSnapShot in sync with this.
FUNCTION DiffOppLineSnapShots(p_event_key  IN VARCHAR2,
            p_delete_flag IN BOOLEAN) RETURN VARCHAR2
IS

 l_RetVal     VARCHAR(1) := 'N';

 Cursor c_opp_line_old(p_item_key VARCHAR2, p_indicator VARCHAR2) IS
 select
    NUM01, NUM02,
    NUM03, NUM05,
    NUM12,
    NUM13, NUM14,
    NUM15, NUM19,
    NUM22, NUM23,
    NUM24,

    DATE01, DATE02,
    DATE04, DATE05,
    DATE06,

    CHAR01, CHAR03,
    CHAR06, CHAR07,
    CHAR08, CHAR09,
    CHAR10, CHAR11,
    CHAR12, CHAR13,
    CHAR14, CHAR15,
    CHAR16, CHAR17,
    CHAR18, CHAR19,
    CHAR20, CHAR21,
    CHAR22, rowid
 from as_event_data
 where event_key = p_item_key AND object_state = p_indicator ORDER BY NUM01;
 -- Order By is to do a sorted list comparison.

 -- Same cursor as c_opp_line_old
 Cursor c_opp_line_new(p_item_key VARCHAR2, p_indicator VARCHAR2) IS
 select
    NUM01, NUM02,
    NUM03, NUM05,
    NUM12,
    NUM13, NUM14,
    NUM15, NUM19,
    NUM22, NUM23,
    NUM24,

    DATE01, DATE02,
    DATE04, DATE05,
    DATE06,

    CHAR01, CHAR03,
    CHAR06, CHAR07,
    CHAR08, CHAR09,
    CHAR10, CHAR11,
    CHAR12, CHAR13,
    CHAR14, CHAR15,
    CHAR16, CHAR17,
    CHAR18, CHAR19,
    CHAR20, CHAR21,
    CHAR22, rowid
 from as_event_data
 where event_key = p_item_key AND object_state = p_indicator ORDER BY NUM01;
 -- Order By is to do a sorted list comparison.

 l_old_rec  c_opp_line_old%ROWTYPE;
 l_new_rec  c_opp_line_old%ROWTYPE; -- deliberately declared of type old
                                    -- to get errors if both are not same.
 l_old_line_id NUMBER;
 l_new_line_id NUMBER;

BEGIN

    OPEN c_opp_line_old(p_event_key, 'OLD');
    OPEN c_opp_line_new(p_event_key, 'NEW');

    l_old_line_id := 0;
    l_new_line_id := 0;

    -- Standard sorted list comparison algorithm
    LOOP
        IF l_old_line_id <= l_new_line_id THEN
            FETCH c_opp_line_old INTO l_old_rec;
        END IF;

        IF l_new_line_id <= l_old_line_id THEN
            FETCH c_opp_line_new INTO l_new_rec;
        END IF;

        l_old_line_id := l_old_rec.NUM01;
        l_new_line_id := l_new_rec.NUM01;

        IF c_opp_line_old%NOTFOUND OR c_opp_line_new%NOTFOUND THEN
            IF c_opp_line_old%FOUND OR c_opp_line_new%FOUND THEN
                l_RetVal := 'Y';
            END IF;
            EXIT;
        END IF;

        IF
            nvl(l_old_line_id, -99) <> nvl(l_new_line_id, -99) OR
            nvl(l_old_rec.NUM02, -99) <> nvl(l_new_rec.NUM02, -99) OR
            nvl(l_old_rec.NUM03, -99) <> nvl(l_new_rec.NUM03, -99) OR
            nvl(l_old_rec.NUM05, -99) <> nvl(l_new_rec.NUM05, -99) OR
            nvl(l_old_rec.NUM12, -99) <> nvl(l_new_rec.NUM12, -99) OR
            nvl(l_old_rec.NUM13, -99) <> nvl(l_new_rec.NUM13, -99) OR
            nvl(l_old_rec.NUM14, -99) <> nvl(l_new_rec.NUM14, -99) OR
            nvl(l_old_rec.NUM15, -99) <> nvl(l_new_rec.NUM15, -99) OR
            nvl(l_old_rec.NUM19, -99) <> nvl(l_new_rec.NUM19, -99) OR
            nvl(l_old_rec.NUM22, -99) <> nvl(l_new_rec.NUM22, -99) OR
            nvl(l_old_rec.NUM23, -99) <> nvl(l_new_rec.NUM23, -99) OR
            nvl(l_old_rec.NUM24, -99) <> nvl(l_new_rec.NUM24, -99) OR

            --nvl(l_old_rec.DATE01, G_DUMMY_DATE) <> nvl(l_new_rec.DATE01, G_DUMMY_DATE) OR
            nvl(l_old_rec.DATE02, G_DUMMY_DATE) <> nvl(l_new_rec.DATE02, G_DUMMY_DATE) OR
            nvl(l_old_rec.DATE04, G_DUMMY_DATE) <> nvl(l_new_rec.DATE04, G_DUMMY_DATE) OR
            nvl(l_old_rec.DATE05, G_DUMMY_DATE) <> nvl(l_new_rec.DATE05, G_DUMMY_DATE) OR
            nvl(l_old_rec.DATE06, G_DUMMY_DATE) <> nvl(l_new_rec.DATE06, G_DUMMY_DATE) OR

            nvl(l_old_rec.CHAR01, '_$') <> nvl(l_new_rec.CHAR01, '_$') OR
            nvl(l_old_rec.CHAR03, '_$') <> nvl(l_new_rec.CHAR03, '_$') OR
            nvl(l_old_rec.CHAR06, '_$') <> nvl(l_new_rec.CHAR06, '_$') OR
            nvl(l_old_rec.CHAR07, '_$') <> nvl(l_new_rec.CHAR07, '_$') OR
            nvl(l_old_rec.CHAR08, '_$') <> nvl(l_new_rec.CHAR08, '_$') OR
            nvl(l_old_rec.CHAR09, '_$') <> nvl(l_new_rec.CHAR09, '_$') OR
            nvl(l_old_rec.CHAR10, '_$') <> nvl(l_new_rec.CHAR10, '_$') OR
            nvl(l_old_rec.CHAR11, '_$') <> nvl(l_new_rec.CHAR11, '_$') OR
            nvl(l_old_rec.CHAR12, '_$') <> nvl(l_new_rec.CHAR12, '_$') OR
            nvl(l_old_rec.CHAR13, '_$') <> nvl(l_new_rec.CHAR13, '_$') OR
            nvl(l_old_rec.CHAR14, '_$') <> nvl(l_new_rec.CHAR14, '_$') OR
            nvl(l_old_rec.CHAR15, '_$') <> nvl(l_new_rec.CHAR15, '_$') OR
            nvl(l_old_rec.CHAR16, '_$') <> nvl(l_new_rec.CHAR16, '_$') OR
            nvl(l_old_rec.CHAR17, '_$') <> nvl(l_new_rec.CHAR17, '_$') OR
            nvl(l_old_rec.CHAR18, '_$') <> nvl(l_new_rec.CHAR18, '_$') OR
            nvl(l_old_rec.CHAR19, '_$') <> nvl(l_new_rec.CHAR19, '_$') OR
            nvl(l_old_rec.CHAR20, '_$') <> nvl(l_new_rec.CHAR20, '_$') OR
            nvl(l_old_rec.CHAR21, '_$') <> nvl(l_new_rec.CHAR21, '_$') OR
            nvl(l_old_rec.CHAR22, '_$') <> nvl(l_new_rec.CHAR22, '_$')
        THEN -- Both records do not match
            l_RetVal := 'Y';
            IF NOT p_delete_flag THEN
                EXIT;
            END IF;
        ELSE -- Both records match
            IF p_delete_flag THEN
                delete from AS_EVENT_DATA where rowid = l_old_rec.rowid;
                delete from AS_EVENT_DATA where rowid = l_new_rec.rowid;
            END IF;
        END IF;
    END LOOP;

    CLOSE c_opp_line_old;
    CLOSE c_opp_line_new;

    RETURN l_RetVal;

END DiffOppLineSnapShots;


-- Compares New and old Sales Team SnapShots for both Opportunity and Customer.
-- If different returns Y else returns N. IF p_delete_flag is TRUE then common
-- records are deleted.
-- Take care to keep the procedure OppSTeamDataSnapShot and
-- CustSTeamDataSnapShot in sync with this.
-- Because TAP deletes entires SalesTeam and recreates it, access_id and
-- create and update dates are not used in comparison since it would change
-- even without any other change.
FUNCTION DiffSTeamSnapShots(p_event_key  IN VARCHAR2,
            p_delete_flag IN BOOLEAN) RETURN VARCHAR2
IS

 l_RetVal     VARCHAR(1) := 'N';

 Cursor c_sales_team_old(p_item_key VARCHAR2, p_indicator VARCHAR2) IS
 select
    NUM01, NUM02, NUM03, NUM04, NUM05, rowid
 from as_event_data
 where event_key = p_item_key AND object_state = p_indicator
 ORDER BY NUM01, NUM02, NUM05;
 -- Order By is to do a sorted list comparison. Order by Salesforce id and
 -- Sales Group Id since access_id is not used.

 -- Same cursor as c_sales_team_old
 Cursor c_sales_team_new(p_item_key VARCHAR2, p_indicator VARCHAR2) IS
 select
    NUM01, NUM02, NUM03, NUM04, NUM05, rowid
 from as_event_data
 where event_key = p_item_key AND object_state = p_indicator
 ORDER BY NUM01, NUM02, NUM05;
 -- Order By is to do a sorted list comparison.

 l_old_rec  c_sales_team_old%ROWTYPE;
 l_new_rec  c_sales_team_old%ROWTYPE; -- deliberately declared of type old
                                      -- to get errors if both are not same.
 l_delCount NUMBER :=0 ;
 l_old_salesforce_id NUMBER;
 l_new_salesforce_id NUMBER;
 l_old_sales_group_id NUMBER;
 l_new_sales_group_id NUMBER;
 l_old_address_id NUMBER;
 l_new_address_id NUMBER;

BEGIN

    OPEN c_sales_team_old(p_event_key, 'OLD');
    OPEN c_sales_team_new(p_event_key, 'NEW');

    l_old_salesforce_id := 0;
    l_old_sales_group_id := 0;
    l_new_salesforce_id := 0;
    l_new_sales_group_id := 0;

    -- Standard Sorted list comparison. The key is combo of Salesforce_id and
    -- sales_group_id
    LOOP
        IF l_old_salesforce_id < l_new_salesforce_id OR
           (l_old_salesforce_id = l_new_salesforce_id
            AND l_old_sales_group_id <= l_new_sales_group_id)THEN
            FETCH c_sales_team_old INTO l_old_rec;
        END IF;

        IF l_new_salesforce_id < l_old_salesforce_id OR
           (l_new_salesforce_id = l_old_salesforce_id
            AND l_new_sales_group_id <= l_old_sales_group_id)THEN
            FETCH c_sales_team_new INTO l_new_rec;
        END IF;

        l_old_salesforce_id := nvl(l_old_rec.NUM01, -99);
        l_old_sales_group_id := nvl(l_old_rec.NUM02, -99);
        l_old_address_id := nvl(l_old_rec.NUM05, -99);
        l_new_salesforce_id := nvl(l_new_rec.NUM01, -99);
        l_new_sales_group_id := nvl(l_new_rec.NUM02, -99);
        l_new_address_id := nvl(l_new_rec.NUM05, -99);

        IF c_sales_team_old%NOTFOUND OR c_sales_team_new%NOTFOUND THEN
            IF c_sales_team_old%FOUND OR c_sales_team_new%FOUND THEN
                l_RetVal := 'Y';
            END IF;
            EXIT;
        END IF;

        IF
            l_old_salesforce_id <> l_new_salesforce_id OR
            l_old_sales_group_id <> l_new_sales_group_id OR
            l_old_address_id <> l_new_address_id
        THEN -- Both records do not match
            l_RetVal := 'Y';
            IF NOT p_delete_flag THEN
                EXIT;
            END IF;
        ELSE -- Both records match
            IF p_delete_flag THEN
                delete from AS_EVENT_DATA where rowid = l_old_rec.rowid;
                delete from AS_EVENT_DATA where rowid = l_new_rec.rowid;
            END IF;
        END IF;
    END LOOP;

    CLOSE c_sales_team_old;
    CLOSE c_sales_team_new;

    RETURN l_RetVal;

END DiffSTeamSnapShots;


-- Normally this is an subscriber of INT_OPPTY_UPDATE_EVENT. But it can be
-- called directly if the last parameter is AS_BUSINESS_EVENT_PVT.DIRECT_CALL
-- and is set to Y
FUNCTION Raise_update_oppty_event (
    p_subscription_guid     IN RAW,
    p_event                 IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS

    l_api_name              CONSTANT VARCHAR2(30) := 'Raise_update_oppty_event';
    l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_list                  WF_PARAMETER_LIST_T := p_event.GetParameterList();
    l_param                 WF_PARAMETER_T;
    l_event_list            AS_EVENT_TABLE_T;
    l_event_rec             AS_EVENT_REC_T;
    l_sub_exists            VARCHAR2(1);
    l_event_name            VARCHAR2(240);
    l_diff_result           VARCHAR2(4);
    l_event_code            VARCHAR2(1);
    l_i                     NUMBER;
    l_num_events            NUMBER;
    l_raise_count           NUMBER;
    l_upd_event_raised      BOOLEAN;
    l_event_key             VARCHAR2(240) := p_event.getEventKey();
    l_new_event_key         VARCHAR2(240);
    l_direct_call           VARCHAR2(1) := 'N';
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Raise_update_oppty_event';

BEGIN
    SAVEPOINT Raise_update_oppty_event;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    l_num_events := 0;
    l_upd_event_raised := FALSE;

    -- If DIRECT_CALL parameter is the last parameter remove it after noting
    -- its value
    l_i := l_list.last;
    IF l_i >= 1 THEN
        l_param := l_list(l_i);
        IF l_param.GetName() = DIRECT_CALL THEN
            l_direct_call := nvl(l_param.GetValue(), 'N');
            l_list.trim();
        END IF;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Direct Call: ' || l_direct_call);
    END IF;

    l_diff_result := DiffOppSnapShots(l_event_key) ;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Return Value from DiffOppSnapShots: ' || l_diff_result);
    END IF;

    IF l_diff_result <> 'N' THEN
        l_num_events := length(l_diff_result);
    END IF;

    l_raise_count := 0;

    FOR l_i IN 1..l_num_events LOOP
      l_event_code := substr(l_diff_result, l_i, 1);
      IF l_event_code = 'W' THEN
          l_event_name := OPPTY_WON_EVENT;
      ELSIF l_event_code = 'L' THEN
          l_event_name := OPPTY_LOST_EVENT;
      ELSIF l_event_code = 'C' THEN
          l_event_name := OPPTY_CLOSED_EVENT;
      ELSE
          l_event_name := OPPTY_UPDATE_EVENT;
      END IF;

      --  Raise Event ONLY if a subscription to
      --  event exists.
      l_sub_exists := exist_subscription( l_event_name );

      -- Debug Message
      IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription(' || l_event_name || '): ' || l_sub_exists);
      END IF;

      IF l_sub_exists = 'Y' THEN
        IF l_event_code = 'U' THEN
            l_new_event_key := l_event_key;
        ELSE
            l_new_event_key := item_key(l_event_name);
            Copy_Event_Data(l_event_key, l_new_event_key);
        END IF;

        -- Store Event to be raised. Event not raised here since that would
        -- delete the original event record if update event is raised.
        l_event_rec.event_name := l_event_name;
        l_event_rec.event_key := l_new_event_key;
        l_event_rec.event_code := l_event_code;
        l_raise_count := l_raise_count + 1;
        l_event_list(l_raise_count) := l_event_rec;
      END IF;
    END LOOP;

    FOR l_i IN 1..l_raise_count LOOP
        l_event_rec := l_event_list(l_i);
        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Calling AS_BUSINESS_EVENT_PVT.raise_event');
        END IF;

        raise_event(
            p_event_name        => l_event_rec.event_name,
            p_event_key         => l_event_rec.event_key,
            p_parameters        => l_list );

        IF l_event_rec.event_code = 'U' THEN
            l_upd_event_raised := TRUE;
        END IF;
    END LOOP;

    -- If update_event is to be raised then raise it else delete the event_data
    IF NOT l_upd_event_raised THEN
        delete from AS_EVENT_DATA where event_key = l_event_key;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;

  RETURN 'SUCCESS';

EXCEPTION

  WHEN OTHERS  THEN
    ROLLBACK TO Raise_update_oppty_event;

    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    IF l_direct_call <> 'Y' THEN
        WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'RAISE_UPDATE_OPPTY_EVENT', p_event.getEventName(), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');
    END IF;

    RETURN 'ERROR';
END Raise_update_oppty_event;


PROCEDURE Before_Oppty_Update(
    p_lead_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
) IS
l_api_name      CONSTANT VARCHAR2(30) := 'Before_Oppty_Update';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_raise_event   VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Before_Oppty_Update';

BEGIN
   SAVEPOINT Before_Oppty_Update;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- Begin Set l_raise_event = 'Y' if subscription exists to one of
    -- OPPTY UPDATE/CLOSED/WON/LOST Events.
    --  Raise Event ONLY if a subscription to
    --  event exists.
    l_raise_event := exist_subscription( OPPTY_UPDATE_EVENT );

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription: ' || l_raise_event);
    END IF;

    IF l_raise_event <> 'Y' THEN
        --  Raise Event ONLY if a subscription to
        --  event exists.
        l_raise_event := exist_subscription( OPPTY_CLOSED_EVENT );

        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription(CLOSED): ' || l_raise_event);
        END IF;
    END IF;

    IF l_raise_event <> 'Y' THEN
        --  Raise Event ONLY if a subscription to
        --  event exists.
        l_raise_event := exist_subscription( OPPTY_WON_EVENT );

        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription(WON): ' || l_raise_event);
        END IF;
    END IF;

    IF l_raise_event <> 'Y' THEN
        --  Raise Event ONLY if a subscription to
        --  event exists.
        l_raise_event := exist_subscription( OPPTY_LOST_EVENT );

        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription(LOST): ' || l_raise_event);
        END IF;
    END IF;
    -- End Set l_raise_event = 'Y' if subscription exists to one of
    -- OPPTY UPDATE/CLOSED/WON/LOST Events.

    IF l_raise_event = 'Y' THEN
        x_event_key := item_key( OPPTY_UPDATE_EVENT );

        IF p_lead_id IS NOT NULL THEN
            OppDataSnapShot(x_event_key, p_lead_id, 'OLD');
        END IF;
    ELSE
        x_event_key := NULL;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Before_Oppty_Update;


PROCEDURE Update_oppty_post_event(
    p_lead_id   IN NUMBER,
    p_event_key IN VARCHAR2
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'Update_oppty_post_event';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_list          WF_PARAMETER_LIST_T;
l_param         WF_PARAMETER_T;
l_event         WF_EVENT_T;
l_status        VARCHAR2(32);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Update_oppty_post_event';

BEGIN
    SAVEPOINT Update_oppty_post_event;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- Simple Check if it is an Opportunity Update Event
    IF INSTR(p_event_key, OPPTY_UPDATE_EVENT) <> 1 THEN
        FND_MESSAGE.SET_NAME('AS', 'AS_INVALID_EVENT_KEY');
        FND_MESSAGE.SET_TOKEN('KEY' , p_event_key);
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OppDataSnapShot(p_event_key, p_lead_id, 'NEW');

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Done Calling OppDataSnapShot');
    END IF;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

    -- Add Context values to the list
    AddParamEnvToList(l_list);
    l_param := WF_PARAMETER_T( NULL, NULL );

    -- fill the parameters list
    l_list.extend;
    l_param.SetName( 'LEAD_ID' );
    l_param.SetValue( p_lead_id );
    l_list(l_list.last) := l_param;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Calling AS_BUSINESS_EVENT_PVT.raise_event');
    END IF;

    -- Raise Event to do diff and raise actual event(s)
    raise_event(
        p_event_name        => INT_OPPTY_UPDATE_EVENT,
        p_event_key         => p_event_key,
        p_parameters        => l_list );

    /* Comment the above call and uncomment the below to direclty call the
    method to raise events instead of raising an asynchronous event to do so
    l_list.extend;
    l_param.SetName( DIRECT_CALL );
    l_param.SetValue( 'Y' );
    l_list(l_list.last) := l_param;
    l_event := WF_EVENT_T(NULL, NULL, NULL, NULL, l_list, INT_OPPTY_UPDATE_EVENT,
                    p_event_key, NULL, NULL, NULL, NULL, NULL, NULL);
    l_event.setParameterList(l_list);

    l_status := Raise_update_oppty_event(NULL, l_event);
    */

    l_list.DELETE;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Update_oppty_post_event;


-- Normally this is an subscriber of INT_OPP_LINES_UPDATE_EVENT. But it can be
-- called directly if the last parameter is AS_BUSINESS_EVENT_PVT.DIRECT_CALL
-- and is set to Y
FUNCTION Raise_upd_opp_lines_evnt (
    p_subscription_guid     IN RAW,
    p_event                 IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS

    l_api_name              CONSTANT VARCHAR2(30) := 'Raise_upd_opp_lines_evnt';
    l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_list                  WF_PARAMETER_LIST_T := p_event.GetParameterList();
    l_param                 WF_PARAMETER_T;
    l_raise_event           VARCHAR2(1);
    l_oppline_changed       VARCHAR2(1);
    l_i                     NUMBER;
    l_event_key             VARCHAR2(240) := p_event.getEventKey();
    l_direct_call           VARCHAR2(1) := 'N';
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Raise_upd_opp_lines_evnt';

BEGIN
    SAVEPOINT Raise_upd_opp_lines_evnt;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- If DIRECT_CALL parameter is the last parameter remove it after noting
    -- its value
    l_i := l_list.last;
    IF l_i >= 1 THEN
        l_param := l_list(l_i);
        IF l_param.GetName() = DIRECT_CALL THEN
            l_direct_call := nvl(l_param.GetValue(), 'N');
            l_list.trim();
        END IF;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Direct Call: ' || l_direct_call);
    END IF;

    --  Raise Event ONLY if a subscription to
    --  event exists.
    l_raise_event := exist_subscription( OPP_LINES_UPDATE_EVENT );

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription: ' || l_raise_event);
    END IF;

    IF l_raise_event = 'Y' THEN
        l_oppline_changed := DiffOppLineSnapShots(l_event_key, FALSE) ;
        l_raise_event := l_oppline_changed;

        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from DiffOppLineSnapShots: ' || l_oppline_changed);
        END IF;
    END IF;

    IF l_raise_event = 'Y' THEN
        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Calling AS_BUSINESS_EVENT_PVT.raise_event');
        END IF;

        -- Raise Event
        raise_event(
            p_event_name        => OPP_LINES_UPDATE_EVENT,
            p_event_key         => l_event_key,
            p_parameters        => l_list );
    ELSE
        delete from AS_EVENT_DATA where event_key = l_event_key;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;

  RETURN 'SUCCESS';

EXCEPTION

  WHEN OTHERS  THEN
    ROLLBACK TO Raise_upd_opp_lines_evnt;

    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    IF l_direct_call <> 'Y' THEN
        WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'RAISE_UPD_OPP_LINES_EVNT', p_event.getEventName(), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');
    END IF;

    RETURN 'ERROR';
END Raise_upd_opp_lines_evnt;


PROCEDURE Before_Opp_Lines_Update(
    p_lead_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
) IS
l_api_name      CONSTANT VARCHAR2(30) := 'Before_Opp_Lines_Update';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_raise_event   VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Before_Opp_Lines_Update';

BEGIN
   SAVEPOINT Before_Opp_Lines_Update;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    --  Raise Event ONLY if a subscription to
    --  event exists.
    l_raise_event := exist_subscription( OPP_LINES_UPDATE_EVENT );

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription: ' || l_raise_event);
    END IF;

    IF l_raise_event = 'Y' THEN
        x_event_key := item_key( OPP_LINES_UPDATE_EVENT );

        IF p_lead_id IS NOT NULL THEN
            OppLineDataSnapShot(x_event_key, p_lead_id, 'OLD');
        END IF;
    ELSE
        x_event_key := NULL;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Before_Opp_Lines_Update;


PROCEDURE Upd_Opp_Lines_post_event(
    p_lead_id   IN NUMBER,
    p_event_key IN VARCHAR2
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'Upd_Opp_Lines_post_event';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_list          WF_PARAMETER_LIST_T;
l_param         WF_PARAMETER_T;
l_event         WF_EVENT_T;
l_status        VARCHAR2(32);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Upd_Opp_Lines_post_event';

BEGIN
    SAVEPOINT Upd_Opp_Lines_post_event;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- Simple Check if it is an Opportunity Lines Update Event
    IF INSTR(p_event_key, OPP_LINES_UPDATE_EVENT) <> 1 THEN
        FND_MESSAGE.SET_NAME('AS', 'AS_INVALID_EVENT_KEY');
        FND_MESSAGE.SET_TOKEN('KEY' , p_event_key);
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OppLineDataSnapShot(p_event_key, p_lead_id, 'NEW');

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Done Calling OppLineDataSnapShot');
    END IF;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

    -- Add Context values to the list
    AddParamEnvToList(l_list);
    l_param := WF_PARAMETER_T( NULL, NULL );

    -- fill the parameters list
    l_list.extend;
    l_param.SetName( 'LEAD_ID' );
    l_param.SetValue( p_lead_id );
    l_list(l_list.last) := l_param;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Calling AS_BUSINESS_EVENT_PVT.raise_event');
    END IF;

    -- Raise Event to do diff and raise actual event(s)
    raise_event(
        p_event_name        => INT_OPP_LINES_UPDATE_EVENT,
        p_event_key         => p_event_key,
        p_parameters        => l_list );

    /* Comment the above call and uncomment the below to direclty call the
    method to raise events instead of raising an asynchronous event to do so
    l_list.extend;
    l_param.SetName( DIRECT_CALL );
    l_param.SetValue( 'Y' );
    l_list(l_list.last) := l_param;
    l_event := WF_EVENT_T(NULL, NULL, NULL, NULL, l_list, INT_OPP_LINES_UPDATE_EVENT,
                    p_event_key, NULL, NULL, NULL, NULL, NULL, NULL);
    l_event.setParameterList(l_list);

    l_status := Raise_upd_opp_lines_evnt(NULL, l_event);
    */

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Upd_Opp_Lines_post_event;


-- The below method is used to raise events for SalesTeam update of either
-- opportunity or Customer. Normally this is an subscriber of
-- INT_STEAM_UPDATE_EVENT. But it can be
-- called directly if the last parameter is AS_BUSINESS_EVENT_PVT.DIRECT_CALL
-- and is set to Y
FUNCTION Raise_upd_STeam_evnt (
    p_subscription_guid     IN RAW,
    p_event                 IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2
IS

    l_api_name              CONSTANT VARCHAR2(30) := 'Raise_upd_STeam_evnt';
    l_debug                 BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_list                  WF_PARAMETER_LIST_T := p_event.GetParameterList();
    l_param                 WF_PARAMETER_T;
    l_raise_event           VARCHAR2(1);
    l_steam_changed         VARCHAR2(1);
    l_i                     NUMBER;
    l_event_name            VARCHAR2(240);
    l_event_key             VARCHAR2(240) := p_event.getEventKey();
    l_direct_call           VARCHAR2(1) := 'N';
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Raise_upd_STeam_evnt';

BEGIN
    SAVEPOINT Raise_upd_STeam_evnt;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- If DIRECT_CALL parameter is the last parameter remove it after noting
    -- its value
    l_i := l_list.last;
    IF l_i >= 1 THEN
        l_param := l_list(l_i);
        IF l_param.GetName() = DIRECT_CALL THEN
            l_direct_call := nvl(l_param.GetValue(), 'N');
            l_list.trim();
        END IF;
    END IF;

    -- Derive Event Name from Event Key
    IF INSTR(l_event_key, OPP_STEAM_UPDATE_EVENT) = 1 THEN
        l_event_name := OPP_STEAM_UPDATE_EVENT;
    ELSE
        l_event_name := CUST_STEAM_UPDATE_EVENT;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Direct Call: ' || l_direct_call);
    END IF;

    --  Raise Event ONLY if a subscription to
    --  event exists.
    l_raise_event := exist_subscription( l_event_name );

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription: ' || l_raise_event);
    END IF;

    IF l_raise_event = 'Y' THEN
        l_steam_changed := DiffSTeamSnapShots(l_event_key, FALSE) ;
        l_raise_event := l_steam_changed;

        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from DiffSTeamSnapShots: ' || l_steam_changed);
        END IF;
    END IF;

    IF l_raise_event = 'Y' THEN
        -- Debug Message
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Calling AS_BUSINESS_EVENT_PVT.raise_event');
        END IF;

        -- Raise Event
        raise_event(
            p_event_name        => l_event_name,
            p_event_key         => l_event_key,
            p_parameters        => l_list );
    ELSE
        delete from AS_EVENT_DATA where event_key = l_event_key;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;

  RETURN 'SUCCESS';

EXCEPTION

  WHEN OTHERS  THEN
    ROLLBACK TO Raise_upd_STeam_evnt;

    FND_MESSAGE.Set_Name('AS', 'Error number ' || to_char(SQLCODE));
    FND_MSG_PUB.ADD;

    IF l_direct_call <> 'Y' THEN
        WF_CORE.CONTEXT('AS_BUSINESS_EVENT_PVT', 'RAISE_UPD_STEAM_EVNT', p_event.getEventName(), p_subscription_guid);
        WF_EVENT.setErrorInfo(p_event, 'ERROR');
    END IF;

    RETURN 'ERROR';
END Raise_upd_STeam_evnt;


PROCEDURE Before_Opp_STeam_Update(
    p_lead_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
) IS
l_api_name      CONSTANT VARCHAR2(30) := 'Before_Opp_STeam_Update';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_raise_event   VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Before_Opp_STeam_Update';

BEGIN
   SAVEPOINT Before_Opp_STeam_Update;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    --  Raise Event ONLY if a subscription to
    --  event exists.
    l_raise_event := exist_subscription( OPP_STEAM_UPDATE_EVENT );

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription: ' || l_raise_event);
    END IF;

    IF l_raise_event = 'Y' THEN
        x_event_key := item_key( OPP_STEAM_UPDATE_EVENT );

        IF p_lead_id IS NOT NULL THEN
            OppSTeamDataSnapShot(x_event_key, p_lead_id, 'OLD');
        END IF;
    ELSE
        x_event_key := NULL;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Before_Opp_STeam_Update;


PROCEDURE Upd_Opp_STeam_post_event(
    p_lead_id   IN NUMBER,
    p_event_key IN VARCHAR2
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'Upd_Opp_STeam_post_event';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_list          WF_PARAMETER_LIST_T;
l_param         WF_PARAMETER_T;
l_event         WF_EVENT_T;
l_status        VARCHAR2(32);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Upd_Opp_STeam_post_event';

BEGIN
    SAVEPOINT Upd_Opp_STeam_post_event;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- Simple Check if it is an Opportunity Sales Team Update Event
    IF INSTR(p_event_key, OPP_STEAM_UPDATE_EVENT) <> 1 THEN
        FND_MESSAGE.SET_NAME('AS', 'AS_INVALID_EVENT_KEY');
        FND_MESSAGE.SET_TOKEN('KEY' , p_event_key);
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    OppSTeamDataSnapShot(p_event_key, p_lead_id, 'NEW');

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Done Calling OppSTeamDataSnapShot');
    END IF;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

    -- Add Context values to the list
    AddParamEnvToList(l_list);
    l_param := WF_PARAMETER_T( NULL, NULL );

    -- fill the parameters list
    l_list.extend;
    l_param.SetName( 'LEAD_ID' );
    l_param.SetValue( p_lead_id );
    l_list(l_list.last) := l_param;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Calling AS_BUSINESS_EVENT_PVT.raise_event');
    END IF;

    -- Raise Event to do diff and raise actual event(s)
    raise_event(
        p_event_name        => INT_STEAM_UPDATE_EVENT,
        p_event_key         => p_event_key,
        p_parameters        => l_list );

    /* Comment the above call and uncomment the below to direclty call the
    method to raise events instead of raising an asynchronous event to do so
    l_list.extend;
    l_param.SetName( DIRECT_CALL );
    l_param.SetValue( 'Y' );
    l_list(l_list.last) := l_param;
    l_event := WF_EVENT_T(NULL, NULL, NULL, NULL, l_list, INT_STEAM_UPDATE_EVENT,
                    p_event_key, NULL, NULL, NULL, NULL, NULL, NULL);
    l_event.setParameterList(l_list);

    l_status := Raise_upd_STeam_evnt(NULL, l_event);
    */

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Upd_Opp_STeam_post_event;


PROCEDURE Before_Cust_STeam_Update(
    p_cust_id   IN NUMBER,
    x_event_key OUT NOCOPY VARCHAR2
) IS
l_api_name      CONSTANT VARCHAR2(30) := 'Before_Cust_STeam_Update';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_raise_event   VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Before_Cust_STeam_Update';

BEGIN
   SAVEPOINT Before_Cust_STeam_Update;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    --  Raise Event ONLY if a subscription to
    --  event exists.
    l_raise_event := exist_subscription( CUST_STEAM_UPDATE_EVENT );

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Return Value from AS_BUSINESS_EVENT_PVT.exist_subscription: ' || l_raise_event);
    END IF;

    IF l_raise_event = 'Y' THEN
        x_event_key := item_key( CUST_STEAM_UPDATE_EVENT );

        IF p_cust_id IS NOT NULL THEN
            CustSTeamDataSnapShot(x_event_key, p_cust_id, 'OLD');
        END IF;
    ELSE
        x_event_key := NULL;
    END IF;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Before_Cust_STeam_Update;


PROCEDURE Upd_Cust_STeam_post_event(
    p_cust_id   IN NUMBER,
    p_event_key IN VARCHAR2
) IS

l_api_name      CONSTANT VARCHAR2(30) := 'Upd_Cust_STeam_post_event';
l_debug         BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_list          WF_PARAMETER_LIST_T;
l_param         WF_PARAMETER_T;
l_event         WF_EVENT_T;
l_status        VARCHAR2(32);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.bevpv.Upd_Cust_STeam_post_event';

BEGIN
    SAVEPOINT Upd_Cust_STeam_post_event;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' start');
    END IF;

    -- Simple Check if it is an Customer Sales Team Update Event
    IF INSTR(p_event_key, CUST_STEAM_UPDATE_EVENT) <> 1 THEN
        FND_MESSAGE.SET_NAME('AS', 'AS_INVALID_EVENT_KEY');
        FND_MESSAGE.SET_TOKEN('KEY' , p_event_key);
        FND_MSG_PUB.ADD;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    CustSTeamDataSnapShot(p_event_key, p_cust_id, 'NEW');

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Done Calling CustSTeamDataSnapShot');
    END IF;

    -- initialization of object variables
    l_list := WF_PARAMETER_LIST_T();

    -- Add Context values to the list
    AddParamEnvToList(l_list);
    l_param := WF_PARAMETER_T( NULL, NULL );

    -- fill the parameters list
    l_list.extend;
    l_param.SetName( 'CUSTOMER_ID' );
    l_param.SetValue( p_cust_id );
    l_list(l_list.last) := l_param;

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Calling AS_BUSINESS_EVENT_PVT.raise_event');
    END IF;

    -- Raise Event to do diff and raise actual event(s)
    raise_event(
        p_event_name        => INT_STEAM_UPDATE_EVENT,
        p_event_key         => p_event_key,
        p_parameters        => l_list );

    /* Comment the above call and uncomment the below to direclty call the
    method to raise events instead of raising an asynchronous event to do so
    l_list.extend;
    l_param.SetName( DIRECT_CALL );
    l_param.SetValue( 'Y' );
    l_list(l_list.last) := l_param;
    l_event := WF_EVENT_T(NULL, NULL, NULL, NULL, l_list, INT_STEAM_UPDATE_EVENT,
                    p_event_key, NULL, NULL, NULL, NULL, NULL, NULL);
    l_event.setParameterList(l_list);

    l_status := Raise_upd_STeam_evnt(NULL, l_event);
    */

    -- Debug Message
    IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Private API: ' || l_api_name || ' end');
    END IF;
END Upd_Cust_STeam_post_event;

END AS_BUSINESS_EVENT_PVT;

/
