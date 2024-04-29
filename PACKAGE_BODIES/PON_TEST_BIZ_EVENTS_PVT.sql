--------------------------------------------------------
--  DDL for Package Body PON_TEST_BIZ_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_TEST_BIZ_EVENTS_PVT" AS
-- $Header: PONVTBEB.pls 120.2 2005/10/04 12:00:24 sapandey noship $

FUNCTION TEST( p_subscription_guid        in      raw,
               p_event                    in  out nocopy  wf_event_t
             ) return varchar2
IS
   pos number := 1;
   l_log VARCHAR2(3000);
   l_param_list wf_parameter_list_t;
   l_event_name VARCHAR2(25);
   l_object_id  NUMBER;
   l_object_id2 NUMBER;

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN  --{ Start of Test Subscription Function

   l_param_list := p_event.GETPARAMETERLIST;
   pos := l_param_list.LAST;

   WHILE(POS IS NOT NULL) LOOP

        IF (l_param_list(POS).GETNAME() IS NOT NULL) THEN
                l_log := l_log||' {'||l_param_list(pos).getName()||':'||l_param_list(pos).getValue()||'},';
        END IF;
                pos := l_param_list.PRIOR(pos);

        END LOOP;


   --
   -- Derive synthetic variables
   --
   IF ( p_event.GETEVENTNAME = 'oracle.apps.pon.event.negotiation.publish') THEN
       l_event_name := 'negotiation.publish';
       l_object_id  := to_number(p_event.GETEVENTKEY); --auction_header_id
       l_object_id2 := 0;
   ELSIF ( p_event.GETEVENTNAME = 'oracle.apps.pon.event.response.publish') THEN
       l_event_name := 'response.publish';
       l_object_id  := to_number(p_event.GETEVENTKEY); --bid_number
       l_object_id2 := 0;
   ELSIF ( p_event.GETEVENTNAME = 'oracle.apps.pon.event.response.disqualify') THEN
       l_event_name := 'response.disqualify';
       l_object_id  := to_number(p_event.GETEVENTKEY); --bid_number
       l_object_id2 := 0;
   ELSIF ( p_event.GETEVENTNAME = 'oracle.apps.pon.event.negotiation.award_approval_start') THEN
       l_event_name := 'award_approval_start';
       l_object_id  := to_number( SUBSTR(p_event.GETEVENTKEY,0,INSTR(p_event.GETEVENTKEY,'-') -1) ); --auction_header_id - award_appr_ame_trans_id
       l_object_id2 := to_number( SUBSTR(p_event.GETEVENTKEY, INSTR(p_event.GETEVENTKEY,'-') +1) ); --auction_header_id - award_appr_ame_trans_id
   ELSIF ( p_event.GETEVENTNAME = 'oracle.apps.pon.event.negotiation.award_complete') THEN
       l_event_name := 'award_complete';
       l_object_id  := to_number(p_event.GETEVENTKEY); --auction_header_id
       l_object_id2 := 0;
   ELSIF ( p_event.GETEVENTNAME = 'oracle.apps.pon.event.purchaseorder.initiate') THEN
       l_event_name := 'purchaseorder.initiate';
       l_object_id  := to_number( SUBSTR(p_event.GETEVENTKEY,0,INSTR(p_event.GETEVENTKEY,'-') -1) ); --auction_header_id - wf_ponc ompl_current_round
       l_object_id2 := to_number( SUBSTR(p_event.GETEVENTKEY, INSTR(p_event.GETEVENTKEY,'-') +1) ); --auction_header_id - wf_ponc ompl_current_round
   END IF;


   INSERT INTO PON_ACTION_HISTORY
   (
        OBJECT_ID       ,
        OBJECT_ID2      ,
        OBJECT_TYPE_CODE,
        SEQUENCE_NUM    ,
        ACTION_TYPE     ,
        ACTION_DATE     ,
        ACTION_USER_ID  ,
        ACTION_NOTE
   )
   VALUES
   (
        l_object_id ,
        l_object_id2,
        l_event_name,
        0           ,
        'BUSINESS_EVENT',
        SYSDATE     ,
        -1          ,
        SUBSTR('Business Event fired with parameter values - '||l_log,0,2000)
   );

   commit;

   RETURN NULL;

END; --{ End of Test Subscription Function



END PON_TEST_BIZ_EVENTS_PVT;

/
