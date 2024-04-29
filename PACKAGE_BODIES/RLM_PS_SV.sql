--------------------------------------------------------
--  DDL for Package Body RLM_PS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_PS_SV" as
/*$Header: RLMDPPSB.pls 120.5.12010000.2 2009/09/01 07:46:29 sunilku ship $*/
/*========================== rlm_ps_sv========================*/
--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
TYPE g_number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
g_BindVarTab		RLM_CORE_SV.t_dynamic_tab;
g_interface_headers_tab   g_number_tbl_type;
g_schedule_headers_tab    g_number_tbl_type;
--
PROCEDURE PurgeSchedule(errbuf OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY NUMBER,
                        p_org_id         NUMBER,
			p_execution_mode VARCHAR2,
			p_translator_code_from VARCHAR2,
                        p_translator_code_to VARCHAR2,
                        p_customer VARCHAR2,
			p_ship_to_address_id_from NUMBER,
			p_ship_to_address_id_to NUMBER,
                        p_issue_date_from VARCHAR2,
			p_issue_date_to VARCHAR2,
			p_schedule_type VARCHAR2,
                        p_schedule_ref_no VARCHAR2 ,
			p_delete_beyond_days NUMBER,
                        p_authorization VARCHAR2,
                        p_status NUMBER)

 IS
  --
  v_from_clause        VARCHAR2(32000);
  v_where_clause       VARCHAR2(32000);
  v_order_clause       VARCHAR2(32000);
  v_forupdate_clause   VARCHAR2(32000);
  v_select_clause      VARCHAR2(32000);
  v_statement_oe       VARCHAR2(32000);
  v_statement_rlm      VARCHAR2(32000);
  v_Progress           VARCHAR2(3) := '010';
  v_WF_Enabled         VARCHAR2(1) := 'N';
  v_cursor_id          NUMBER;
  v_errbuf             VARCHAR2(2000);
  v_retcode            NUMBER;
  v_sched_header_id    NUMBER;
  v_sched_line_id      NUMBER;
  v_interface_header   NUMBER;
  v_interface_line     NUMBER;
  v_order_header       NUMBER;
  v_order_line         NUMBER;
  v_line_count         NUMBER;
  v_line_count2        NUMBER;
  v_open_flag          VARCHAR2(1);
  v_order_exists       BOOLEAN;
  v_partial_schedule   BOOLEAN;
  x_request_id         NUMBER;
  e_no_data_found      EXCEPTION;
--  p_org_id             NUMBER := NULL;
  x_purge_rec          rlm_message_sv.t_PurExp_rec;
  v_statement          VARCHAR2(32000);
  v_int_statement      VARCHAR2(32000);
  v_arch_statement     VARCHAR2(32000);
  v_schedule_ref_no    NUMBER;
  v_schedule_source    VARCHAR2(10) := 'X';
  --
  TYPE ref_demand_cur IS REF CURSOR;
  c_demand ref_demand_cur;
  oe_demand ref_demand_cur;
  --
  CURSOR c IS
  	SELECT *
 	FROM oe_order_lines_all
	WHERE line_id = v_order_line;
  --
  v_Sched_rec  OE_ORDER_LINES_ALL%ROWTYPE;
  --
  BEGIN
     --
     MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                                  p_org_id      => p_org_id);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.start_debug;
        rlm_core_sv.dpush(C_SDEBUG,'PurgeSchedule');
     END IF;
     --
     rlm_message_sv.populate_req_id;
     --
     IF(p_schedule_ref_no IS NOT NULL) THEN
       --
       v_schedule_source := substr(p_schedule_ref_no,1,1);
       v_schedule_ref_no := to_number(substr(p_schedule_ref_no,2));
       --
     END IF;
     --
     --where caluse
     --
     v_where_clause := BuildQuery (p_execution_mode,
			   p_translator_code_from,
                           p_translator_code_to,
                           p_customer,
			   p_ship_to_address_id_from,
			   p_ship_to_address_id_to,
                           p_issue_date_from,
			   p_issue_date_to,
			   p_schedule_type,
			   v_schedule_ref_no,
			   p_delete_beyond_days,
                           p_authorization,
                           p_status);
     --
     --no criteria specified by the user
     --
     IF (v_where_clause = 'WHERE rh.header_id=rl.header_id') THEN
       raise e_no_data_found;
     END IF;
     --
     -- Final Queries
     --
     v_arch_statement := 'select distinct rh.header_id
                          from rlm_schedule_headers rh, rlm_schedule_lines_all rl '
                          || v_where_clause
                          || ' and rh.process_status = :k_ps_5'
                          || ' and rh.org_id = rl.org_id';

     v_int_statement := 'select distinct rh.header_id
                         from rlm_interface_headers rh, rlm_interface_lines_all rl '
                         || v_where_clause
                         ||' and 5 = :k_ps_5'
                         ||' and rh.org_id = rl.org_id';

     g_BindVarTab(g_BindVarTab.COUNT+1):=5;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'v_arch_statement', v_arch_statement);
        rlm_core_sv.dlog(C_DEBUG, 'v_int_statement', v_int_statement);
        rlm_core_sv.dlog(C_DEBUG, 'v_schedule_source', v_schedule_source);
        rlm_core_sv.dlog(C_DEBUG, '============================');
        rlm_core_sv.dlog(C_DEBUG, 'Printing Bind Variable Values');
        rlm_core_sv.dlog(C_DEBUG, 'g_BindVarTab.COUNT', g_BindVarTab.COUNT);
        --
        FOR i IN 1..g_BindVarTab.COUNT LOOP
          rlm_core_sv.dlog(C_DEBUG, 'g_BindVarTab('||i||')', g_BindVarTab(i));
        END LOOP;
        --
        rlm_core_sv.dlog(C_DEBUG, '============================');
     END IF;
     --
     -- interface only
     --
     IF(p_status = 1 or p_status = 2 or p_status = 3) THEN
       --{
       RLM_CORE_SV.OpenDynamicCursor(c_demand, v_int_statement, g_BindVarTab);
       FETCH c_demand INTO v_sched_header_id;
       --
       IF c_demand%NOTFOUND THEN
         raise e_no_data_found;
       END IF;
       --
       CLOSE c_demand;
       --
       IF(v_schedule_source <> 'S') THEN
         --
         PurgeInterface(p_execution_mode=>p_execution_mode,
                        p_authorization=>p_authorization,
                        p_ship_to_address_id_from=>p_ship_to_address_id_from,
                        p_ship_to_address_id_to=>p_ship_to_address_id_to,
                        p_statement=>v_int_statement);
         --
       ELSE
         raise e_no_data_found;
       END IF;
       --}
       -- archive only
       --
     ELSIF(p_status = 4) THEN
       --{
       -- Test for no schedules matching the criteria
       --
       RLM_CORE_SV.OpenDynamicCursor(c_demand, v_arch_statement, g_BindVarTab);
       FETCH c_demand INTO v_sched_header_id;
       --
       IF c_demand%NOTFOUND THEN
         raise e_no_data_found;
       END IF;
       --
       CLOSE c_demand;
       --
       IF(v_schedule_source <> 'I') THEN
         --
         PurgeArchive(  p_execution_mode=>p_execution_mode,
                        p_authorization=>p_authorization,
                        p_ship_to_address_id_from=>p_ship_to_address_id_from,
                        p_ship_to_address_id_to=>p_ship_to_address_id_to,
                        p_statement=>v_arch_statement);
         --
       ELSE
         raise e_no_data_found;
       END IF;
       --}
     ELSE
       --{
       -- check for matching interface and archive schedules
       --
       RLM_CORE_SV.OpenDynamicCursor(c_demand, v_int_statement, g_BindVarTab);
       FETCH c_demand INTO v_sched_header_id;
       --
       IF c_demand%NOTFOUND THEN
         --{
         CLOSE c_demand;
         RLM_CORE_SV.OpenDynamicCursor(c_demand, v_arch_statement, g_BindVarTab);
         FETCH c_demand INTO v_sched_header_id;
         --
         IF c_demand%NOTFOUND THEN
           --
           CLOSE c_demand;
           raise e_no_data_found;
           --
         END IF;
         --}
       END IF;
       --
       IF(v_schedule_source <> 'S') THEN
         --
         PurgeInterface(p_execution_mode=>p_execution_mode,
                        p_authorization=>p_authorization,
                        p_ship_to_address_id_from=>p_ship_to_address_id_from,
                        p_ship_to_address_id_to=>p_ship_to_address_id_to,
                        p_statement=>v_int_statement);
         --
       END IF;
       --
       IF(v_schedule_source <> 'I') THEN
         --
         PurgeArchive(  p_execution_mode=>p_execution_mode,
                        p_authorization=>p_authorization,
                        p_ship_to_address_id_from=>p_ship_to_address_id_from,
                        p_ship_to_address_id_to=>p_ship_to_address_id_to,
                        p_statement=>v_arch_statement);
        --
       END IF;
       --}
     END IF;
     --
     -- Purge rlm_demand_exceptions
     --
     FORALL counter in 1..g_schedule_headers_tab.COUNT
       --
       DELETE from rlm_demand_exceptions
       where schedule_header_id= g_schedule_headers_tab(counter)
       and request_id <> fnd_global.conc_request_id;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'No of Schedule Exception Lines Deleted ', SQL%ROWCOUNT);
       END IF;
       --
     FORALL counter in 1..g_interface_headers_tab.COUNT
       --
       DELETE from rlm_demand_exceptions
       where interface_header_id= g_interface_headers_tab(counter)
       and request_id <> fnd_global.conc_request_id;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'No of Interface Exception Lines Deleted ', SQL%ROWCOUNT);
       END IF;
     --
     -- runreport
     --
     RunReport  (p_org_id                   => p_org_id,
                 p_execution_mode          => p_execution_mode,
	         p_translator_code_from    => p_translator_code_from,
                 p_translator_code_to      => p_translator_code_to,
                 p_customer                => p_customer,
	         p_ship_to_address_id_from => p_ship_to_address_id_from,
	         p_ship_to_address_id_to   => p_ship_to_address_id_to,
                 p_issue_date_from         => p_issue_date_from,
	         p_issue_date_to           => p_issue_date_to,
	         p_schedule_type           => p_schedule_type,
	         p_schedule_ref_no         => v_schedule_ref_no,
	         p_delete_beyond_days      => p_delete_beyond_days,
                 p_authorization           => p_authorization,
                 p_status                  => p_status);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG);
        rlm_core_sv.stop_debug;
     END IF;
     --
EXCEPTION
  --
  WHEN e_no_data_found THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'No schedules to delete' );
     END IF;
     --
     --runreport
     --
     RunReport(  p_org_id                   => p_org_id,
                 p_execution_mode          => p_execution_mode,
                 p_translator_code_from    => p_translator_code_from,
                 p_translator_code_to      => p_translator_code_to,
                 p_customer                => p_customer,
	         p_ship_to_address_id_from => p_ship_to_address_id_from,
	         p_ship_to_address_id_to   => p_ship_to_address_id_to,
                 p_issue_date_from         => p_issue_date_from,
	         p_issue_date_to           => p_issue_date_to,
	         p_schedule_type           => p_schedule_type,
	         p_schedule_ref_no         => v_schedule_ref_no,
	         p_delete_beyond_days      => p_delete_beyond_days,
                 p_authorization           => p_authorization,
                 p_status                  => p_status);
     --
     rlm_message_sv.sql_error('rlm_ps_sv.PurgeSchedule', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
  WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'When others - Purge Schedule' );
     END IF;
     --
     --runreport
     --
     RunReport(  p_org_id                   => p_org_id,
                 p_execution_mode          => p_execution_mode,
                 p_translator_code_from    => p_translator_code_from,
                 p_translator_code_to      => p_translator_code_to,
                 p_customer                => p_customer,
	         p_ship_to_address_id_from => p_ship_to_address_id_from,
	         p_ship_to_address_id_to   => p_ship_to_address_id_to,
                 p_issue_date_from         => p_issue_date_from,
	         p_issue_date_to           => p_issue_date_to,
	         p_schedule_type           => p_schedule_type,
	         p_schedule_ref_no         => v_schedule_ref_no,
	         p_delete_beyond_days      => p_delete_beyond_days,
                 p_authorization           => p_authorization,
                 p_status                  => p_status);
     --
     rlm_message_sv.sql_error('rlm_ps_sv.PurgeSchedule', v_Progress);
     rlm_message_sv.dump_messages;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     raise;
     --
END PurgeSchedule;


/* Purge Archive*/


PROCEDURE PurgeArchive(p_execution_mode VARCHAR2,
                      p_authorization VARCHAR2,
                      p_ship_to_address_id_from NUMBER,
	              p_ship_to_address_id_to NUMBER,
                      p_statement VARCHAR2)

IS

  v_from_clause        VARCHAR2(32000);
  v_where_clause       VARCHAR2(32000);
  v_order_clause       VARCHAR2(32000);
  v_forupdate_clause   VARCHAR2(32000);
  v_select_clause      VARCHAR2(32000);
  v_statement_oe       VARCHAR2(32000);
  v_statement_rlm      VARCHAR2(32000);
  v_Progress           VARCHAR2(3) := '010';
  v_WF_Enabled         VARCHAR2(1) := 'N';
  v_cursor_id          NUMBER;
  v_errbuf             VARCHAR2(2000);
  v_retcode            NUMBER;
  v_process_status     NUMBER;
  v_sched_header_id    NUMBER;
  v_sched_line_id      NUMBER;
  v_interface_header   NUMBER;
  v_interface_line     NUMBER;
  v_order_header       NUMBER;
  v_order_line         NUMBER;
  v_line_count         NUMBER;
  v_line_count2        NUMBER;
  v_open_flag          VARCHAR2(1);
  v_order_exists       BOOLEAN;
  v_partial_schedule   BOOLEAN;
  x_request_id         NUMBER;
  e_no_data_found      EXCEPTION;
  p_org_id             NUMBER := NULL;
  x_purge_rec          rlm_message_sv.t_PurExp_rec;
  --
  TYPE ref_demand_cur IS REF CURSOR;
  c_demand ref_demand_cur;
  oe_demand ref_demand_cur;
  --
  CURSOR c IS
  	select *
 	from oe_order_lines_all
	where line_id = v_order_line;
  --
  v_Sched_rec  OE_ORDER_LINES_ALL%ROWTYPE;
  --
BEGIN

     IF (l_debug <> -1) THEN
        rlm_core_sv.dpush(C_SDEBUG,'PurgeArchive');
     END IF;
     --fetch header_id from the select statement
     RLM_CORE_SV.OpenDynamicCursor(c_demand, p_statement, g_BindVarTab);

     LOOP

       BEGIN

         FETCH c_demand INTO v_sched_header_id;

         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Schedule Header Id',v_sched_header_id);
         END IF;

         EXIT WHEN c_demand%NOTFOUND;

         -- get all other header information

          SELECT ECE_TP_TRANSLATOR_CODE, SCHEDULE_REFERENCE_NUM,
                 SCHEDULE_TYPE, SCHED_GENERATION_DATE,'SCHEDULE',
                 PROCESS_STATUS
          INTO  x_purge_rec.ECE_TP_TRANSLATOR_CODE,
                x_purge_rec.SCHEDULE_REFERENCE_NUM,
                x_purge_rec.SCHEDULE_TYPE,
                x_purge_rec.SCHED_GENERATION_DATE,
                x_purge_rec.ORIGIN_TABLE,/*2261812*/
                v_process_status
          FROM  rlm_schedule_headers
          WHERE header_id = v_sched_header_id;

          --check for partially selected schedule

          IF(p_ship_to_address_id_from IS NOT NULL) THEN

            select count(*) into v_line_count from rlm_schedule_lines
            where header_id = v_sched_header_id
            AND ship_to_address_id between p_ship_to_address_id_from
            AND nvl(p_ship_to_address_id_to, p_ship_to_address_id_from);

            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_line_count1',v_line_count);
            END IF;

            select count(*) into v_line_count2 from rlm_schedule_lines
            where header_id = v_sched_header_id;

            IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'v_line_count2',v_line_count2);
            END IF;

            v_partial_schedule :=FALSE;

            IF(v_line_count2 > v_line_count) THEN

              --partial selection of a schedule

              IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'partial ship to location selection for',v_sched_header_id);
              END IF;

              --insert exception

              rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_PARTIAL_SELECTION',
                                      x_ErrorText => 'RLM_PARTIAL_SELECTION',
                                      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec);

              v_partial_schedule := TRUE;

            END IF;

          END IF; --end partial



         --check for open orders

         v_order_exists:=FALSE;

         IF(v_process_status =5 or v_process_status=7) THEN

           v_order_exists:=CheckOpenOrder(v_sched_header_id,x_purge_rec);

         END IF;

         IF (v_order_exists = TRUE OR v_partial_schedule = TRUE) THEN

           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Open Order found or Partial Schedule For Schedule Header Id',
				v_sched_header_id);
           END IF;

           null;

         ELSE

           IF(p_execution_mode = 'P') THEN

             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'Execution Mode',p_execution_mode);
             END IF;

	     --delete schedules

             select count(*) into v_line_count from rlm_schedule_headers where header_id = v_sched_header_id;

             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'v_line_count_process',v_line_count);
             END IF;


             IF(v_line_count > 0) THEN

               --check for delete schedules with authorization
               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'checking for authorization...');
               END IF;

               IF(p_authorization = 'Y') THEN

                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'Deleting...',v_sched_header_id);
                 END IF;


                 --store exception
                 rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'SUCCESS',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );


                 delete from rlm_schedule_lines where header_id = v_sched_header_id;
                 delete from rlm_schedule_headers where header_id = v_sched_header_id;
                 g_schedule_headers_tab(g_schedule_headers_tab.COUNT+1):= v_sched_header_id;

               ELSE


                 select count(*) into v_line_count from rlm_schedule_lines where header_id = v_sched_header_id and item_detail_type = '3';

                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'v_line_count_detail',v_line_count);
                 END IF;


                 IF(v_line_count > 0) THEN


                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'Authorization exists, Retaining....',v_sched_header_id);
                   END IF;

                   --store exception retained
                   rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_AUTHORIZATION_FOUND',
                                      x_ErrorText => 'RLM_AUTHORIZATION_FOUND',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec );

                   null;

                 ELSE

                   --store exception

                   rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'SUCCESS',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );



                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'Authorization not found, deleting....',v_sched_header_id);
                   END IF;

                   delete from rlm_schedule_lines where header_id = v_sched_header_id;
                   delete from rlm_schedule_headers where header_id = v_sched_header_id;


                   --delete exceptions associated with the schedule

                   g_schedule_headers_tab(g_schedule_headers_tab.COUNT+1):= v_sched_header_id;

                 END IF; --check for item_detail = 3

               END IF;  --p_authorization

             END IF; --check for process status in purge mode


           ELSE

	     --view mode

             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'Execution Mode',p_execution_mode);
             END IF;

             --check for process status in view mode

             select count(*) into v_line_count from rlm_schedule_headers where header_id = v_sched_header_id;

             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'v_line_count_status',v_line_count);
             END IF;

             IF(v_line_count > 0) THEN

               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'checking for authorization...');
               END IF;

               IF(p_authorization = 'Y') THEN

                 --store exception purgable
                 rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'PURGABLE',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );

                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'Purgable...(view)',v_sched_header_id);
                 END IF;

                 null;

               ELSE


                 select count(*) into v_line_count from rlm_schedule_lines where header_id = v_sched_header_id and item_detail_type = '3';

                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'v_line_count_detail',v_line_count);
                 END IF;

                 IF(v_line_count > 0) THEN

                   --store exception retained
                   rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_AUTHORIZATION_FOUND',
                                      x_ErrorText => 'RLM_AUTHORIZATION_FOUND',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec );


                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'Authorization found..not purgable..(view)',v_sched_header_id);
                   END IF;

                   null;

                 ELSE

                   null;

                   --store exception purgable
                   rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'PURGABLE',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );


                   IF (l_debug <> -1) THEN
                      rlm_core_sv.dlog(C_DEBUG,'Authorization not found.. purgable..(view)',v_sched_header_id);
                   END IF;


                 END IF; --check for item_detail = 3

               END IF; --p_authorization check

             END IF; --check process status in view mode

           END IF; --check execution_mode view or purge

         END IF; --order exists true/false

       END;

     END LOOP;
     --
     commit;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'success');
        rlm_core_sv.dpop(C_SDEBUG,'PurgeArchive');
     END IF;


EXCEPTION

  when others then

    rlm_message_sv.sql_error('rlm_ps_sv.PurgeArchive', v_Progress);
    rlm_message_sv.dump_messages;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;


END PurgeArchive;


/* Purge_Interface */


PROCEDURE PurgeInterface(p_execution_mode VARCHAR2,
                        p_authorization VARCHAR2,
                        p_ship_to_address_id_from NUMBER,
			p_ship_to_address_id_to NUMBER,
                        p_statement VARCHAR2)
IS

  v_from_clause        VARCHAR2(32000);
  v_where_clause       VARCHAR2(32000);
  v_order_clause       VARCHAR2(32000);
  v_forupdate_clause   VARCHAR2(32000);
  v_select_clause      VARCHAR2(32000);

  v_statement_oe       VARCHAR2(32000);
  v_statement_rlm      VARCHAR2(32000);
  v_Progress           VARCHAR2(3) := '010';
  v_WF_Enabled         VARCHAR2(1) := 'N';
  v_cursor_id          NUMBER;
  v_errbuf             VARCHAR2(2000);
  v_retcode            NUMBER;
  v_process_status     NUMBER;
  v_sched_header_id    NUMBER;
  v_sched_id           NUMBER;
  v_sched_line_id      NUMBER;
  v_interface_header   NUMBER;
  v_interface_line     NUMBER;
  v_order_header       NUMBER;
  v_order_line         NUMBER;
  v_line_count         NUMBER;
  v_line_count2        NUMBER;
  v_open_flag          VARCHAR2(1);
  v_order_exists       BOOLEAN;
  v_partial_schedule   BOOLEAN;
  x_request_id         NUMBER;
  e_no_data_found      EXCEPTION;
  p_org_id             NUMBER := NULL;
  x_purge_rec          rlm_message_sv.t_PurExp_rec;
  --
  TYPE ref_demand_cur IS REF CURSOR;
  c_demand ref_demand_cur;
  oe_demand ref_demand_cur;
  --
  CURSOR c IS
  	select *
 	from oe_order_lines_all
	where line_id = v_order_line;
  --
  v_Sched_rec  OE_ORDER_LINES_ALL%ROWTYPE;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'PurgeInterface');
  END IF;
  --
  --fetch header_id from the select statement
  --
  RLM_CORE_SV.OpenDynamicCursor(c_demand, p_statement, g_BindVarTab);
  --
  LOOP
     --{
     BEGIN
         --{
         FETCH c_demand INTO v_sched_header_id;
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG,'Schedule Header Id',v_sched_header_id);
         END IF;

         EXIT WHEN c_demand%NOTFOUND;

         -- get all other header information

         SELECT ECE_TP_TRANSLATOR_CODE, SCHEDULE_REFERENCE_NUM,
                SCHEDULE_TYPE, SCHED_GENERATION_DATE,'INTERFACE',
                PROCESS_STATUS
         INTO  x_purge_rec.ECE_TP_TRANSLATOR_CODE,
               x_purge_rec.SCHEDULE_REFERENCE_NUM,
               x_purge_rec.SCHEDULE_TYPE,
               x_purge_rec.SCHED_GENERATION_DATE,
               x_purge_rec.ORIGIN_TABLE, /*2261812*/
               v_process_status
         FROM  rlm_interface_headers
         WHERE header_id = v_sched_header_id;

         --check for partially selected schedule

         IF(p_ship_to_address_id_from IS NOT NULL) THEN

           select count(*) into v_line_count from rlm_interface_lines
           where header_id = v_sched_header_id
           AND ship_to_address_id between p_ship_to_address_id_from
           AND nvl(p_ship_to_address_id_to, p_ship_to_address_id_from);

           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'v_line_count1',v_line_count);
           END IF;

           select count(*) into v_line_count2 from rlm_interface_lines
           where header_id = v_sched_header_id;

           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'v_line_count2',v_line_count2);
           END IF;

           v_partial_schedule :=FALSE;

           IF(v_line_count2 > v_line_count) THEN

             --partial selection of a schedule

             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'partial ship to location selection for',v_sched_header_id);
             END IF;

             --insert exception

             rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_PARTIAL_SELECTION',
                                      x_ErrorText => 'RLM_PARTIAL_SELECTION',
                                      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec);

             v_partial_schedule := TRUE;

           END IF;

         END IF; --end partial
         --
         v_order_exists := FALSE;
         --
         --check for open orders
         --
         IF (v_process_status=7) THEN
           --
           BEGIN
             --
             select header_id
             into v_sched_id
             from rlm_schedule_headers
             where interface_header_id = v_sched_header_id;
             --
             v_order_exists := CheckOpenOrder(v_sched_id,x_purge_rec);
             --
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               --
               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'No link to any archive schedule for ',v_sched_header_id);
               END IF;
               --
           END;
           --
         END IF;
         --
         IF (v_order_exists =TRUE or v_partial_schedule = TRUE) THEN
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Open Order or Partial Schedule For Interface Header Id',
				v_sched_header_id);
           END IF;
           null;
         ELSE
           IF(p_execution_mode = 'P') THEN
             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'Execution Mode',p_execution_mode);
             END IF;
	     --delete schedules
             IF(p_authorization = 'Y') THEN

               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'Deleting...',v_sched_header_id);
               END IF;

               --store exception
               rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'SUCCESS',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );
               --
               delete from rlm_interface_lines where header_id = v_sched_header_id;
               delete from rlm_interface_headers where header_id = v_sched_header_id;
               --
               --delete from archive as well
               --
               delete from rlm_schedule_lines_all
               where header_id = (select header_id
                                  from rlm_schedule_headers
                                  where interface_header_id = v_sched_header_id);
               --
               delete from rlm_schedule_headers where interface_header_id = v_sched_header_id;
               --
               --delete exceptions associated with the schedule
               --
               g_interface_headers_tab(g_interface_headers_tab.COUNT+1):= v_sched_header_id;
               --
             ELSE

               select count(*) into v_line_count from rlm_interface_lines where header_id = v_sched_header_id and item_detail_type = '3';

               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'v_line_count_detail',v_line_count);
               END IF;


               IF(v_line_count > 0) THEN


                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'Authorization exists, Retaining....',v_sched_header_id);
                 END IF;

                 --store exception retained
                 rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_AUTHORIZATION_FOUND',
                                      x_ErrorText => 'RLM_AUTHORIZATION_FOUND',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec );

               ELSE

                 --store exception

                 rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'SUCCESS',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );



                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'Authorization not found, deleting....',v_sched_header_id);
                 END IF;

                 delete from rlm_interface_lines where header_id = v_sched_header_id;
                 delete from rlm_interface_headers where header_id = v_sched_header_id;

                 --delete from archive as well

                 delete from rlm_schedule_lines where header_id = (select header_id from rlm_schedule_headers where interface_header_id = v_sched_header_id);

                 delete from rlm_schedule_headers where interface_header_id = v_sched_header_id;

                 --delete exceptions associated with the schedule
                 g_interface_headers_tab(g_interface_headers_tab.COUNT+1):= v_sched_header_id;

               END IF; --check for item_detail = 3

             END IF;  --p_authorization




           ELSE

	     --view mode-------------------------------------------------

             IF (l_debug <> -1) THEN
                rlm_core_sv.dlog(C_DEBUG,'Execution Mode',p_execution_mode);
             END IF;

             IF(p_authorization = 'Y') THEN

               --store exception purgable
               rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'PURGABLE',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );

               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'Purgable...(view)',v_sched_header_id);
               END IF;

               null;

             ELSE

               select count(*) into v_line_count from rlm_interface_lines where header_id = v_sched_header_id and item_detail_type = '3';

               IF (l_debug <> -1) THEN
                  rlm_core_sv.dlog(C_DEBUG,'v_line_count_detail',v_line_count);
               END IF;

               IF(v_line_count > 0) THEN

                 --store exception retained
                 rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_AUTHORIZATION_FOUND',
                                      x_ErrorText => 'RLM_AUTHORIZATION_FOUND',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec );


                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'Authorization found..not purgable..(view)',v_sched_header_id);
                 END IF;
                 null;

               ELSE

                 null;

                 --store exception purgable
                 rlm_message_sv.insert_purge_row (x_ExceptionLevel => 'X',
                                      x_MessageName => 'PURGABLE',
                                      x_ErrorText => '',
				      x_ScheduleHeaderId => v_sched_header_id,
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'Y',
                                      x_PurgeExp_rec=>x_purge_rec );


                 IF (l_debug <> -1) THEN
                    rlm_core_sv.dlog(C_DEBUG,'Authorization not found.. purgable..(view)',v_sched_header_id);
                 END IF;


               END IF; --check for item_detail = 3

             END IF; --p_authorization check

           END IF; --check execution_mode view or purge

         END IF; --check partial
         --
     END;
     --}
  END LOOP;
  --}
  commit;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'success');
     rlm_core_sv.dpop(C_SDEBUG,'PurgeInterface');
  END IF;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_ps_sv.PurgeInterface', v_Progress);
    rlm_message_sv.dump_messages;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
    END IF;
    --
    raise;

END PurgeInterface;

/* Run Exception Report */

PROCEDURE RunReport( p_org_id NUMBER,
                     p_execution_mode VARCHAR2,
		     p_translator_code_from VARCHAR2,
                     p_translator_code_to VARCHAR2,
                     p_customer VARCHAR2,
		     p_ship_to_address_id_from NUMBER,
		     p_ship_to_address_id_to NUMBER,
                     p_issue_date_from VARCHAR2,
		     p_issue_date_to VARCHAR2,
		     p_schedule_type VARCHAR2,
		     p_schedule_ref_no NUMBER,
		     p_delete_beyond_days NUMBER,
                     p_authorization VARCHAR2,
                     p_status NUMBER)
IS

  x_request_id         NUMBER;
--  p_org_id             NUMBER := NULL;
  v_Progress           VARCHAR2(3) := '010';

BEGIN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpush(C_SDEBUG,'RunReport');
       rlm_core_sv.dlog(C_DEBUG,'Begin Report');
    END IF;
    --
--MOAC Changes    fnd_profile.get('ORG_ID', p_org_id);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Operating unit', p_org_id);
    END IF;
    --
    fnd_request.set_org_id(p_org_id);
    --
    x_request_id := fnd_request.submit_request (application => 'RLM',
					         program => 'RLMPSRP',
					  	 argument1 =>fnd_global.conc_request_id,
						 argument2 =>p_execution_mode,
						 argument3 =>p_translator_code_from,
						 argument4 =>p_translator_code_to,
                                                 argument5 =>p_customer,
						 argument6 =>p_ship_to_address_id_from,
						 argument7 =>p_ship_to_address_id_to,
						 argument8 =>p_issue_date_from,
						 argument9 =>p_issue_date_to,
						 argument10 =>p_schedule_type,
						 argument11 =>p_schedule_ref_no,
						 argument12 =>p_delete_beyond_days,
						 argument13 =>p_authorization,
						 argument14 =>p_status,
                                                 argument15 =>p_org_id
                                                 );
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'Report Request ID', x_request_id);
       rlm_core_sv.dlog(C_DEBUG,'End Report');
       rlm_core_sv.dpop(C_SDEBUG,'RunReport');
    END IF;
    --
EXCEPTION
    --
    WHEN OTHERS THEN
       --
       rlm_message_sv.sql_error('rlm_ps_sv.RunReport', v_Progress);
       rlm_message_sv.dump_messages;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
       END IF;
       --
       raise;
       --
END RunReport;


/* Build Query */

FUNCTION BuildQuery (     p_execution_mode VARCHAR2,
			   p_translator_code_from VARCHAR2,
                           p_translator_code_to VARCHAR2,
                           p_customer VARCHAR2,
			   p_ship_to_address_id_from NUMBER,
			   p_ship_to_address_id_to NUMBER,
                           p_issue_date_from VARCHAR2,
			   p_issue_date_to VARCHAR2,
			   p_schedule_type VARCHAR2,
			   p_schedule_ref_no NUMBER,
			   p_delete_beyond_days NUMBER,
                           p_authorization VARCHAR2,
                           p_status NUMBER)

RETURN VARCHAR2

IS

v_where_clause VARCHAR2(32000);
e_no_data_found      EXCEPTION;
v_Progress           VARCHAR2(3) := '010';
temp_cust            VARCHAR2(360);/*2261960*/

BEGIN

     IF (l_debug <> -1) THEN
        rlm_core_sv.dpush(C_SDEBUG,'BuildQuery');
     END IF;
     --
     IF (p_execution_mode IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_execution_mode',p_execution_mode);
       END IF;
       --
     END IF;
     --
     v_where_clause := 'WHERE rh.header_id=rl.header_id';
     --
     -- dynamic sql starts from here
     --
     IF(p_translator_code_from IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_translator_code_from',
                           p_translator_code_from);
          rlm_core_sv.dlog(C_DEBUG,'p_translator_code_to',
                           p_translator_code_to);
       END IF;
       --
       v_where_clause := v_where_clause ||
                         ' AND rh.ece_tp_translator_code between  :p_translator_code_from AND nvl(:p_translator_code_to, :p_translator_code_from)';

       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_translator_code_from;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_translator_code_to;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_translator_code_from;
       --
     END IF;
     --
     IF(p_customer IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_customer',p_customer);
       END IF;
       --
       -- 2261960
       --
       -- Following query is changed as per TCA obsolescence project.
       select	PARTY.PARTY_NAME
       into	temp_cust
       from	HZ_PARTIES PARTY,
		HZ_CUST_ACCOUNTS CUST_ACCT
       where	CUST_ACCT.CUST_ACCOUNT_ID = p_customer
       and	CUST_ACCT.PARTY_ID = PARTY.PARTY_ID;
       --
       v_where_clause := v_where_clause ||
                         ' AND (rh.customer_id = :p_customer OR rh.cust_name_ext = :temp_cust)';
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_customer;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=temp_cust;
       --
     END IF;
     --
     IF(p_ship_to_address_id_from IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_ship_to_address_id_from',
                           p_ship_to_address_id_from);
          rlm_core_sv.dlog(C_DEBUG,'p_ship_to_address_id_to',
                           p_ship_to_address_id_to);
       END IF;
       --
       v_where_clause := v_where_clause ||' AND rl.ship_to_address_id between :p_ship_to_address_id_from AND nvl(:p_ship_to_address_id_to, :p_ship_to_address_id_from)';

       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_ship_to_address_id_from;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_ship_to_address_id_to;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_ship_to_address_id_from;
       --
     END IF;
     --
     IF (p_issue_date_from IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_issue_date_from',p_issue_date_from);
          rlm_core_sv.dlog(C_DEBUG,'p_issue_date_to',p_issue_date_to);
       END IF;
       --
       v_where_clause := v_where_clause || ' AND rh.sched_generation_date between to_date(:p_issue_date_from,''YYYY/MM/DD HH24:MI:SS'') AND to_date(nvl(:p_issue_date_to,:p_issue_date_from), ''YYYY/MM/DD HH24:MI:SS'')';
       --
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_issue_date_from;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_issue_date_to;
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_issue_date_from;
       --
     END IF;
     --
     IF(p_schedule_type IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_schedule_type',p_schedule_type);
       END IF;
       --
       v_where_clause := v_where_clause || ' AND rh.schedule_type = :p_schedule_type ';
       --
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_schedule_type;
       --
     END IF;
     --
     IF (p_delete_beyond_days IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_delete_beyond_days',p_delete_beyond_days);
          rlm_core_sv.dlog(C_DEBUG,'prior to',sysdate-p_delete_beyond_days);
       END IF;
       --
       v_where_clause := v_where_clause || ' AND rh.sched_generation_date < sysdate-:p_delete_beyond_days';
       --
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_delete_beyond_days;
       --
     END IF;
     --
     IF (p_authorization IS NOT NULL) THEN
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_authorization',p_authorization);
       END IF;
       --
     END IF;
     --
     -- header_id overrides all other parameters
     -- Bug 3777594 : Clean up g_BindVarTab, if header_id is provided
     --
     IF (p_schedule_ref_no IS NOT NULL) THEN
       --
       g_BindVarTab.DELETE;
       --
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_schedule_ref_no',p_schedule_ref_no);
       END IF;
       --
       v_where_clause := ' where rh.header_id = rl.header_id AND rh.header_id =:p_schedule_ref_no';
       --
       g_BindVarTab(g_BindVarTab.COUNT+1) :=p_schedule_ref_no;
       --
     END IF;
     --
     IF(p_status IS NOT NULL) THEN
       --{
       IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG,'p_status',p_status);
       END IF;
       --
       -- to be processed
       --
       IF(p_status = 1) THEN
         --
         v_where_clause := v_where_clause || ' AND rh.process_status =:ps_1';
         g_BindVarTab(g_BindVarTab.COUNT+1) :=2;
         --
       END IF;
       --
       -- processed with errors
       --
       IF(p_status = 2) THEN
         --
         v_where_clause := v_where_clause || ' AND rh.process_status = :ps_2';
         g_BindVarTab(g_BindVarTab.COUNT+1) :=4;
         --
       END IF;
       --
       -- partially processed
       --
       IF(p_status = 3) THEN
         --
         v_where_clause := v_where_clause || ' AND rh.process_status = :ps_3';
         g_BindVarTab(g_BindVarTab.COUNT+1) :=7;
         --
       END IF;
       --
       -- processed successfully
       --
       IF(p_status = 4) THEN
         --
         v_where_clause := v_where_clause || ' AND rh.process_status = :ps_4';
         g_BindVarTab(g_BindVarTab.COUNT+1) :=5;
         --
       END IF;
       --
       -- All Status
       --
       IF(p_status = 5) THEN --Added IF Condition as part of Bugfix 8758276
         --
         v_where_clause := v_where_clause || ' AND 8 = :ps_5';
         g_BindVarTab(g_BindVarTab.COUNT+1) := 8;
         --
       END IF;
       --}
     END IF;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Where Clause', v_where_clause);
        rlm_core_sv.dlog(C_DEBUG, '# of bind variables', g_BindVarTab.COUNT);
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     return v_where_clause;
     --
EXCEPTION

  When others then
    rlm_message_sv.sql_error('rlm_ps_sv.BuildQuery', v_Progress);
    rlm_message_sv.dump_messages;
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
    END IF;
    --
    return v_where_clause;

END BuildQuery;


/* Checks for Open Order Associated with a Schedule */

FUNCTION CheckOpenOrder (p_schedule_header_id NUMBER,
                         x_purge_rec          rlm_message_sv.t_PurExp_rec)
RETURN BOOLEAN

IS

  v_from_clause        VARCHAR2(32000);
  v_where_clause       VARCHAR2(32000);
  v_order_clause       VARCHAR2(32000);
  v_forupdate_clause   VARCHAR2(32000);
  v_select_clause      VARCHAR2(32000);

  v_statement_oe       VARCHAR2(32000);
  v_statement_rlm      VARCHAR2(32000);
  v_Progress           VARCHAR2(3) := '010';
  v_WF_Enabled         VARCHAR2(1) := 'N';
  v_cursor_id          NUMBER;
  v_errbuf             VARCHAR2(2000);
  v_retcode            NUMBER;
  v_process_status     NUMBER;
  v_sched_header_id    NUMBER;
  v_sched_line_id      NUMBER;
  v_interface_header   NUMBER;
  v_interface_line     NUMBER;
  v_order_header       NUMBER;
  v_order_line         NUMBER;
  v_line_count         NUMBER;
  v_line_count2        NUMBER;
  v_open_flag          VARCHAR2(1);
  v_order_exists       BOOLEAN;
  v_line_number        NUMBER; --bugfix 6319027
  v_partial_schedule   BOOLEAN;
  x_request_id         NUMBER;
  e_no_data_found      EXCEPTION;
  p_org_id             NUMBER := NULL;

  --
  TYPE ref_demand_cur IS REF CURSOR;
  c_demand ref_demand_cur;
  oe_demand ref_demand_cur;
  --

  CURSOR c IS
  	select *
 	from oe_order_lines_all
	where line_id = v_order_line;
  --
  v_Sched_rec  OE_ORDER_LINES_ALL%ROWTYPE;
  --


BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'CheckOpenOrder');
  END IF;

  v_order_exists := FALSE;

--
/** Commented the code as per bugfix 6319027
  v_statement_oe :='select oe.open_flag, oe.header_id, oe.line_id ,oe.source_document_line_id
                    from oe_order_lines_all oe
                    where (oe.header_id,oe.source_document_id)
                            IN ( select rlm.order_header_id,rlm.header_id
                                 from rlm_schedule_lines rlm
                                where  rlm.header_id = :p_schedule_header_id)';
**/
--
--Modified the code as per bugfix 6319027
  v_statement_oe :='select oe.open_flag, oe.header_id, oe.line_id ,oe.source_document_line_id, scl.line_number
                    from oe_order_lines_all oe,
                         rlm_schedule_lines_all scl
                    where oe.header_id = scl.order_header_id
                    and   oe.source_document_line_id = scl.line_id
                    and   oe.source_document_type_id = 5
                    and   scl.header_id = :p_schedule_header_id' ;
--

    OPEN oe_demand for v_statement_oe using p_schedule_header_id;

    v_order_exists := FALSE;
    v_open_flag := 'N';

    LOOP

      BEGIN

        FETCH oe_demand INTO v_open_flag, v_order_header, v_order_line, v_sched_line_id, v_line_number;  --bugfix 6319027

        EXIT WHEN oe_demand%NOTFOUND;

        IF (l_debug <> -1) THEN
   	   rlm_core_sv.dlog(C_DEBUG,'For Schedule Header Id',p_schedule_header_id);
           rlm_core_sv.dlog(C_DEBUG,'v_open_flag',v_open_flag);
           rlm_core_sv.dlog(C_DEBUG,'v_order_header',v_order_header);
           rlm_core_sv.dlog(C_DEBUG,'v_order_line',v_order_line);
           rlm_core_sv.dlog(C_DEBUG,'Schedule Line Id',v_sched_line_id);
           rlm_core_sv.dlog(C_DEBUG,'Schedule Line Number',v_line_number); --bugfix 6319027
	END IF;

        IF (v_open_flag = 'Y') THEN

          --exception open Order Line

          v_order_exists := TRUE;

          IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'Order_exists',v_order_exists);
          END IF;

          --insert exception

          rlm_message_sv.app_purge_error (x_ExceptionLevel => 'E',
                                      x_MessageName => 'RLM_OPEN_ORDER',
                                      x_ErrorText => 'RLM_OPEN_ORDER',
                                      x_ScheduleHeaderId => p_schedule_header_id,
                                      x_ScheduleLineId => v_sched_line_id,
                                      x_OrderHeaderId => v_order_header,
                                      x_OrderLineId => v_order_line,
                                      x_ScheduleLineNum => v_line_number, --bugfix 6319027
                                      x_conc_req_id => fnd_global.conc_request_id,
                                      x_PurgeStatus => 'N',
                                      x_PurgeExp_rec=>x_purge_rec );

          --EXIT;

        END IF;

      END;

    END LOOP;

  CLOSE oe_demand;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG,'CheckOpenOrder');
  END IF;
  --
  return v_order_exists;

EXCEPTION

When others then
  rlm_message_sv.sql_error('rlm_ps_sv.CheckOpenOrder', v_Progress);
  rlm_message_sv.dump_messages;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
  END IF;
  --
  return FALSE;

END CheckOpenOrder;


END RLM_PS_SV;

/
