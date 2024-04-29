--------------------------------------------------------
--  DDL for Package Body BIX_SUMMARY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_SUMMARY_PUB" AS
/* $Header: BIXSUMPB.pls 115.19 2003/01/10 00:31:11 achanda ship $: */

g_start_date DATE := NULL;
g_end_date DATE := NULL;


PROCEDURE WRITE_LOG(p_msg VARCHAR2, p_proc_name VARCHAR2) IS
BEGIN
    FND_FILE.PUT_LINE(fnd_file.log,'Load Interactions Log - ' || p_msg || ': '|| p_proc_name);
END WRITE_LOG;

procedure POPULATE_BIX_SUM_GRP_CLS
IS
  CURSOR POP_BIX_SUM_GRP_CLS
  IS
  SELECT interaction_type,
         media_item_type,
         interaction_center_id,
         campaign_id,
         resource_id,
         TO_DATE(to_char(start_ts, 'DD-MM-YYYY-HH24'),'DD-MM-YYYY-HH24') hour,
         interaction_classification,
         SUM(ivr_time) ivr_time,
         SUM(route_time) route_time,
         SUM(party_wait_time) party_wait_time,
         SUM(talk_time) talk_time,
         SUM(wrap_time) wrap_time,
         SUM(idle_time) idle_time,
         SUM(DECODE(interaction_subtype,'TRANSFER',1,NULL)) transfers,
         SUM(DECODE(interaction_subtype,'ABANDON',1,NULL)) abandoned_count,
         SUM(DECODE(interaction_subtype,'ABANDON',party_wait_time,NULL)) wait_time_to_abandon,
         SUM(DECODE(first_interaction_resoln_flag,1,1,NULL)) first_interaction_resoln_count,
         SUM(DECODE(NVL(USER_ATTRIBUTE2,'F'),'T',1,NULL)) interactions_answered_live,
         SUM(preview_time) preview_time,
         SUM(non_productive_time) non_productive_time,
         SUM(response_time) response_time,
         SUM(resolution_time_internal) resolution_time_internal,
         SUM(resolution_time) resolution_time,
         SUM(DECODE(NVL(USER_ATTRIBUTE1,'F'),'T',1,NULL)) number_of_interactions
   FROM  bix_interactions
   GROUP BY interaction_type, media_item_type, interaction_center_id,
   campaign_id, resource_id, to_char(start_ts, 'DD-MM-YYYY-HH24'),
   interaction_classification;

BEGIN
    begin
--    dbms_output.put_line('POPULATE_BIX_SUM_X=');

    ---dbms_output.put_line('g_Start_date : '|| g_start_date );
    --dbms_output.put_line('g_end_date : '|| g_end_date );

    DELETE FROM bix_sum_grp_cls
    WHERE hour BETWEEN g_start_date AND g_end_date;

    DELETE FROM bix_sum_agt_cls
    WHERE hour BETWEEN g_start_date AND g_end_date;


 FOR call IN  POP_BIX_SUM_GRP_CLS LOOP
     INSERT INTO BIX_SUM_GRP_CLS
     (
     sum_grp_cls_id,
     campaign_id,
     interaction_classification,
     media_item_type,
     interaction_center_id,
     resource_group_id,
     interaction_type,
     hour,
     transfers,
     abandoned_count,
     wait_time_to_abandon,
     interactions_answered_live,
     first_interaction_resoln_count,
     ivr_time,
     route_time,
     party_wait_time,
     speed_to_answer,
     talk_time,
     wrap_time,
     idle_time,
     preview_time,
     non_productive_time,
     response_time,
     resolution_time_internal,
     number_of_interactions
     )
     VALUES
      (
     BIX_SUM_GRP_CLS_S.nextval,
     call.campaign_id,
     call.interaction_classification,
     call.media_item_type,
     call.interaction_center_id,
     call.resource_id,
     call.interaction_type,
     call.hour,
     call.transfers,
     call.abandoned_count,
     call.wait_time_to_abandon,
     call.interactions_answered_live,
     call.first_interaction_resoln_count,
     call.ivr_time,
     call.route_time,
     call.party_wait_time,
     call.party_wait_time,
     call.talk_time,
     call.wrap_time,
     call.idle_time,
     call.preview_time,
     call.non_productive_time,
     call.response_time,
     call.resolution_time_internal,
     call.number_of_interactions
     );

     INSERT INTO BIX_SUM_AGT_CLS
     (
     sum_agt_cls_id,
     campaign_id,
     interaction_classification,
     media_item_type,
     interaction_center_id,
     resource_id,
     resource_group_id,
     interaction_type,
     hour,
     transfers,
     abandoned_count,
     wait_time_to_abandon,
     interactions_answered_live,
     first_interaction_resoln_count,
     ivr_time,
     route_time,
     party_wait_time,
     speed_to_answer_time,
     talk_time,
     wrap_time,
     idle_time,
     preview_time,
     non_productive_time,
     response_time,
     resolution_time_internal,
     number_of_interactions
     )
     VALUES
      (
     BIX_SUM_AGT_CLS_S.nextval,
     call.campaign_id,
     call.interaction_classification,
     call.media_item_type,
     call.interaction_center_id,
     call.resource_id,
     call.resource_id,
     call.interaction_type,
     call.hour,
     call.transfers,
     call.abandoned_count,
     call.wait_time_to_abandon,
     call.interactions_answered_live,
     call.first_interaction_resoln_count,
     call.ivr_time,
     call.route_time,
     call.party_wait_time,
     call.party_wait_time,
     call.talk_time,
     call.wrap_time,
     call.idle_time,
     call.preview_time,
     call.non_productive_time,
     call.response_time,
     call.resolution_time_internal,
     call.number_of_interactions
     );
    END LOOP;
   exception
   WHEN OTHERS THEN
    write_log('Error: '||sqlerrm,' POPULATE_BIX_SUM_GRP_CLS');
    rollback;
    raise;
   end;
END POPULATE_BIX_SUM_GRP_CLS;

procedure POPULATE_BIX_SUM_X
IS
BEGIN
   populate_bix_sum_grp_cls;
   exception
     when others then
     write_log('Error : '||sqlerrm,'POPULATE_BIX_SUM_X');
     rollback;
     raise;
END POPULATE_BIX_SUM_X;

procedure POPULATE_BIX_SUM_X(errbuf out nocopy varchar2,
                             retcode out nocopy varchar2
					    )
IS
BEGIN
declare
  l_message varchar2(2000);
  l_count  NUMBER := 0;
 begin

  SELECT COUNT(*) INTO l_count
  FROM BIX_INTERACTIONS;

/* Since we capture data in summary tables at 1 hour level. We need delete the complete bucket
   and re collect again
*/

  --dbms_output.put_line('Count of rows in interactions : ' || l_count);

  IF l_count > 0 THEN
     SELECT TO_DATE(TO_CHAR(MIN(start_ts),'DD/MM/YYYY HH24'),'DD/MM/YYYY HH24')
            INTO g_start_date
     FROM  bix_interactions;
     SELECT TO_DATE(TO_CHAR(MAX(start_ts),'DD/MM/YYYY HH24'),'DD/MM/YYYY HH24')
            INTO g_end_date
     FROM  bix_interactions;

   --dbms_output.put_line('Start date : '|| g_start_date);
   --dbms_output.put_line('End  date : '|| g_end_date);


    BIX_SUMMARY_PUB.POPULATE_BIX_SUM_X;
    COMMIT;
  END IF;

 exception
   WHEN OTHERS THEN
      errbuf := sqlerrm;
      retcode := sqlcode;
      l_message := errbuf;
      write_log('Error : '||errbuf,'POPULATE_BIX_SUM_X');
      ROLLBACK;
      raise;
 end;
END POPULATE_BIX_SUM_X; /* end of conc mgr for POPULATE_BIX_SUM_X */

END BIX_SUMMARY_PUB;

/
