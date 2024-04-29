--------------------------------------------------------
--  DDL for Package Body BIX_SERVER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_SERVER_PUB" AS
/* $Header: BIXSERSB.pls 115.6 2003/01/10 02:46:55 achanda ship $: */
procedure POPULATE_BIX_SERVER_SUM_CP
IS
  CURSOR POP_BIX_SERVER_SUM_CP
  IS
  SELECT SUM(busy_counts) busy_counts,
         SUM(connect_counts) connect_counts,
         SUM(answering_machine_counts) answering_machine_counts,
         SUM(modem_counts) modem_counts,
         SUM(sit_counts) sit_counts,
         SUM(rna_counts) rna_counts,
         SUM(other_counts) other_counts,
         SUM(withdrawn_dials) withdrawn_dials,
         SUM(average_wait_time) average_wait_time,
         SUM(std_dev_wait_time) std_dev_wait_time,
         SUM(minimum_wait_time) minimum_wait_time,
         SUM(maximum_wait_time) maximum_wait_time,
         SUM(total_wait_time) total_wait_time,
         SUM(number_agents_predictive) number_agents_predictive,
         SUM(number_working_dialers) number_working_dialers,
         SUM(number_abandons) number_abandons,
         SUM(abandon_percentage) abandon_percentage,
         SUM(dials_per_minute) dials_per_minute,
         SUM(number_agents_outbound) number_agents_outbound,
         SUM(number_calls_outcome_1) number_calls_outcome_1,
         SUM(number_calls_outcome_2) number_calls_outcome_2,
         SUM(number_calls_outcome_3) number_calls_outcome_3,
         SUM(number_records_remaining) number_records_remaining,
         SUM(number_records_start_of_day) number_records_start_of_day,
         SUM(num_recs_to_be_released_next_1) num_recs_to_be_released_next_1,
         site_id site_id,
         campaign_id campaign_id,
         list_id list_id,
         to_char(minute, 'DD-Mon-YY HH') hour
   FROM  BIX_SERVER_CP
   GROUP BY site_id, campaign_id, list_id, to_char(minute, 'DD-Mon-YY HH');
BEGIN

     FOR recs in POP_BIX_SERVER_SUM_CP LOOP

         INSERT INTO BIX_SERVER_SUM_CP
         (
          server_sum_cp_id,
          site,
          campaign_id,
          list_id,
          hour,
          busy_counts,
          connect_counts,
          answering_machine_counts,
          modem_counts,
          sit_counts,
          rna_counts,
          other_counts,
          withdrawn_dials,
          average_wait_time,
          std_dev_wait_time,
          minimum_wait_time,
          maximum_wait_time,
          total_wait_time,
          number_agents_predictive,
          number_working_dialers,
          number_abandons,
          abandon_percentage,
          dials_per_minute,
          number_agents_outbound,
          number_calls_outcome_1,
          number_calls_outcome_2,
          number_calls_outcome_3,
          number_records_remaining,
          number_records_start_of_day,
          number_records_to_be_released)
          VALUES(
          bix_server_sum_cp_s.nextval,
          recs.site_id,
          recs.campaign_id,
          recs.list_id,
          recs.hour,
          recs.busy_counts,
          recs.connect_counts,
          recs.answering_machine_counts,
          recs.modem_counts,
          recs.sit_counts,
          recs.rna_counts,
          recs.other_counts,
          recs.withdrawn_dials,
          recs.average_wait_time,
          recs.std_dev_wait_time,
          recs.minimum_wait_time,
          recs.maximum_wait_time,
          recs.total_wait_time,
          recs.number_agents_predictive,
          recs.number_working_dialers,
          recs.number_abandons,
          recs.abandon_percentage,
          recs.dials_per_minute,
          recs.number_agents_outbound,
          recs.number_calls_outcome_1,
          recs.number_calls_outcome_2,
          recs.number_calls_outcome_3,
          recs.number_records_remaining,
          recs.number_records_start_of_day,
          recs.num_recs_to_be_released_next_1);
       END LOOP;
END POPULATE_BIX_SERVER_SUM_CP;
procedure POPULATE_BIX_SERVER_X
IS
BEGIN
   populate_bix_server_sum_cp;
   exception
     when others then null;
END POPULATE_BIX_SERVER_X;

procedure POPULATE_BIX_SERVER_X(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2)
IS
BEGIN
declare
  l_message varchar2(2000);
 begin
   BIX_SERVER_PUB.POPULATE_BIX_SERVER_X;
 exception
   WHEN OTHERS THEN
      errbuf := sqlerrm;
      retcode := '-20001';
      l_message := errbuf;
      FND_FILE.put_line(FND_FILE.log,l_message);
      raise;
 end;
END POPULATE_BIX_SERVER_X; /* end of conc mgr for POPULATE_BIX_SERVER_X */

END BIX_SERVER_PUB;

/
