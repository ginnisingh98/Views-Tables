--------------------------------------------------------
--  DDL for Package Body RLM_DP_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_DP_SV" as
/*$Header: RLMDPWPB.pls 120.7.12010000.2 2009/12/01 14:46:47 sunilku ship $*/
/*========================== rlm_dp_sv =============================*/

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
PROCEDURE DemandProcessor(
                errbuf                   OUT NOCOPY      VARCHAR2,
                retcode                  OUT NOCOPY      VARCHAR2,
                p_org_id                 NUMBER,
                p_schedule_purpose_code  VARCHAR2,
                p_from_date              VARCHAR2,
                p_to_date                VARCHAR2,
                p_from_customer_ext      VARCHAR2,
                p_to_customer_ext        VARCHAR2,
                p_from_ship_to_ext       VARCHAR2,
                p_to_ship_to_ext         VARCHAR2,
                p_header_id              NUMBER,
                p_dummy                  VARCHAR2,
                p_cust_ship_from_ext     VARCHAR2,
                p_warn_replace_schedule  VARCHAR2,
                p_order_by_schedule_type VARCHAR2 DEFAULT 'N',
                p_child_processes        NUMBER DEFAULT 0,
                p_request_id             NUMBER)
 IS
  --
  v_from_clause        VARCHAR2(32000);
  v_where_clause       VARCHAR2(32000);
  v_order_clause       VARCHAR2(32000);
  v_select_clause      VARCHAR2(32000);
  v_statement          VARCHAR2(32000);
  v_Progress           VARCHAR2(3) := '010';
  v_WF_Enabled         VARCHAR2(1) := 'N';
  v_cursor_id          NUMBER;
  v_errbuf             VARCHAR2(2000);
  v_retcode            NUMBER;
  v_header_id          NUMBER;
  v_schedule_header_id NUMBER;
  v_header_ps          NUMBER;
  v_status             NUMBER;
  v_count              NUMBER;
  v_replace_status     BOOLEAN DEFAULT FALSE;
  --
  e_VDFailed           EXCEPTION;
  e_MDFailed           EXCEPTION;
  e_FDFailed           EXCEPTION;
  e_RDFailed           EXCEPTION;
  e_linesLocked        EXCEPTION;
  e_ConfirmationSchedule EXCEPTION;
  e_ReplaceSchedule      EXCEPTION;
  e_testschedule	EXCEPTION;		/* 2554058 */
  --
  TYPE ref_demand_cur IS REF CURSOR;
  c_demand ref_demand_cur;
  --
  v_Sched_rec  RLM_INTERFACE_HEADERS%ROWTYPE;
  v_Group_rec  t_Group_rec;

  l_start_time  NUMBER;
  l_end_time    NUMBER;
  l_val_start_time  NUMBER;
  l_val_end_time    NUMBER;
  l_val_total       NUMBER := 0;
  l_comp_start_time  NUMBER;
  l_comp_end_time    NUMBER;
  l_comp_total       NUMBER := 0;
  l_post_start_time  NUMBER;
  l_post_end_time    NUMBER;
  l_post_total       NUMBER := 0;
  v_msg_text       VARCHAR2(32000);
  l_start_child_time  NUMBER;
  l_end_child_time    NUMBER;
  v_num_child      NUMBER :=0;
  v_child_req_id   g_request_tbl;
  ind              NUMBER DEFAULT 0;
  i                NUMBER DEFAULT 0;
  j                NUMBER DEFAULT 0;
  g_BindVarTab		RLM_CORE_SV.t_dynamic_tab;
  --
  BEGIN
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.start_debug;
        rlm_core_sv.dpush(C_SDEBUG,'DemandProcessor');
        rlm_core_sv.dlog(C_DEBUG,'from date',p_from_date);
        rlm_core_sv.dlog(C_DEBUG,'to date',p_to_date);
        rlm_core_sv.dlog(C_DEBUG,'Org ID', p_org_id);
     END IF;
     --
     SELECT hsecs INTO l_start_time from v$timer;
     --
     rlm_message_sv.populate_req_id;
     --
     MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                                  p_org_id      => p_org_id);
     --
     -- Initialize retCode to success. It will be set to error only
     -- in case of a fatal error, in WHEN OTHERS exception handler blocks
     --
     retcode := 0;
     --
     IF p_header_id IS NOT NULL THEN
       --
       v_from_clause := '
           FROM rlm_interface_headers hdr';
       --
       -- bug 3756599
       v_where_clause := '
          WHERE hdr.process_status IN (:k_PS_AVAILABLE, :k_PS_PARTIAL_PROCESSED, :k_PS_ERROR) AND header_id = :p_header_id ';

       g_BindVarTab(g_BindVarTab.COUNT+1) := rlm_core_sv.k_PS_AVAILABLE;
       g_BindVarTab(g_BindVarTab.COUNT+1) := rlm_core_sv.k_PS_PARTIAL_PROCESSED;
       g_BindVarTab(g_BindVarTab.COUNT+1) := rlm_core_sv.k_PS_ERROR;
       g_BindVarTab(g_BindVarTab.COUNT+1) := p_header_id;
       --
     ELSE
       --
       v_from_clause := '
           FROM rlm_interface_headers hdr';
       v_where_clause := '
           WHERE hdr.process_status IN (:k_PS_AVAILABLE, :k_PS_PARTIAL_PROCESSED, :k_PS_ERROR) ';
       g_BindVarTab(g_BindVarTab.COUNT+1) := rlm_core_sv.k_PS_AVAILABLE;
       g_BindVarTab(g_BindVarTab.COUNT+1) := rlm_core_sv.k_PS_PARTIAL_PROCESSED;
       g_BindVarTab(g_BindVarTab.COUNT+1) := rlm_core_sv.k_PS_ERROR;
       --
       -- Addition of customer to the where clause
       --
       IF (p_from_customer_ext IS NOT NULL) THEN
           --
           v_where_clause := v_where_clause || ' AND nvl(hdr.customer_ext,hdr.ece_tp_translator_code) BETWEEN :p_from_customer_ext and nvl(:p_to_customer_ext,:p_from_customer_ext)';
           --
           g_BindVarTab(g_BindVarTab.COUNT+1) := p_from_customer_ext;
           g_BindVarTab(g_BindVarTab.COUNT+1) := p_to_customer_ext;
           g_BindVarTab(g_BindVarTab.COUNT+1) := p_from_customer_ext;
           --
       END IF;
       --
       -- Add the Ship From External to the where clause ER 3883413
       --
       IF p_cust_ship_from_ext is NOT NULL THEN
        --
        v_where_clause :=  v_where_clause || ' AND header_id NOT IN (Select header_id from rlm_schedule_interface_lines_v ril
        where ((ril.cust_ship_from_org_ext <> :p_cust_ship_from_ext) OR (ril.cust_ship_from_org_ext is  NULL)) AND
        ril.process_status <> 5)' ;
        --
        g_BindVarTab(g_BindVarTab.COUNT+1) := p_cust_ship_from_ext;
        --
       END IF ;
       --
       -- Addition of ship to  to the where clause
       --
       IF (p_from_ship_to_ext IS NOT NULL) THEN
           --
           v_where_clause :=  v_where_clause || '  AND hdr.ece_tp_location_code_ext BETWEEN :p_from_ship_to_ext AND nvl(:p_to_ship_to_ext,:p_from_ship_to_ext) ';
           --
           g_BindVarTab(g_BindVarTab.COUNT+1) := p_from_ship_to_ext;
           g_BindVarTab(g_BindVarTab.COUNT+1) := p_to_ship_to_ext;
           g_BindVarTab(g_BindVarTab.COUNT+1) := p_from_ship_to_ext;
           --
       END IF;
       --
       -- Addition of date Validation to the where clause
       --
       IF (p_from_date IS NOT NULL) THEN
         --
         v_where_clause :=  v_where_clause ||' AND hdr.sched_generation_date BETWEEN to_date(:p_from_date,''YYYY/MM/DD HH24:MI:SS'') AND nvl( to_date(:p_to_date, ''YYYY/MM/DD HH24:MI:SS''), to_date(:p_from_date, ''YYYY/MM/DD HH24:MI:SS'')) ';
         --
         g_BindVarTab(g_BindVarTab.COUNT+1) := p_from_date;
         g_BindVarTab(g_BindVarTab.COUNT+1) := p_to_date;
         g_BindVarTab(g_BindVarTab.COUNT+1) := p_from_date;
         --
       END IF;
       --
       -- Addition of schedule_purpose_code
       --
       IF (p_schedule_purpose_code IS NOT NULL) THEN
        --
        v_where_clause :=  v_where_clause ||'
        AND hdr.schedule_purpose = :p_schedule_purpose_code ';
        --
        g_BindVarTab(g_BindVarTab.COUNT+1) := p_schedule_purpose_code;
        --
       END IF;
       --
       -- The above query may need modification in order to use some particular
       -- index for performance purposes
     END IF;
     --
     IF(p_request_id IS NOT NULL) THEN
       --
       g_BindVarTab.DELETE;
       v_where_clause := ' WHERE hdr.request_id = :p_request_id ';
       g_BindVarTab(g_BindVarTab.COUNT+1) := p_request_id;
       --
     END IF;
     --
     -- 2554058 : Added hdr.edi_test_indicator in the following select clause
     --
     v_select_clause  := 'SELECT hdr.header_id, hdr.process_status,
				 hdr.edi_test_indicator ';

     -- stype
     g_order_by_schedule_type := p_order_by_schedule_type;
     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'g_order_by_schedule_type',g_order_by_schedule_type);
     END IF;
     --
     IF g_order_by_schedule_type = 'N' THEN
       --
       v_order_clause  := '
           ORDER BY hdr.ece_tp_translator_code,
                    hdr.ece_tp_location_code_ext,
                    hdr.sched_generation_date,
                    hdr.edi_control_num_2,
                    hdr.edi_control_num_3,
                    DECODE(hdr.schedule_type, ''PLANNING_RELEASE'', 1,
                    ''SHIPPING'', 2, ''SEQUENCED'', 3) ,
                    hdr.schedule_reference_num ,
                    DECODE(hdr.schedule_purpose, ''ADD'', 1,
                    ''CONFIRMATION'', 2, ''ORIGINAL'', 3,
                    ''REPLACE'', 4, ''REPLACE_ALL'', 5, ''CANCELLATION'', 6,
                    ''CHANGE'', 7, ''DELETE'', 8),
                    hdr.creation_date';
       --
     ELSE
       --
       v_order_clause  := '
           ORDER BY hdr.ece_tp_translator_code,
                    hdr.ece_tp_location_code_ext,
                    DECODE(hdr.schedule_type, ''PLANNING_RELEASE'', 1,
                    ''SHIPPING'', 2, ''SEQUENCED'', 3) ,
                    hdr.sched_generation_date,
                    hdr.edi_control_num_2,
                    hdr.edi_control_num_3,
                    hdr.schedule_reference_num ,
                    DECODE(hdr.schedule_purpose, ''ADD'', 1,
                    ''CONFIRMATION'', 2, ''ORIGINAL'', 3,
                    ''REPLACE'', 4, ''REPLACE_ALL'', 5,''CANCELLATION'', 6,
                    ''CHANGE'', 7, ''DELETE'', 8),
                    hdr.creation_date';
       --
     END IF;
     --
     v_Statement  := v_select_clause || ' '
                     || v_from_clause || ' '
                     || v_where_clause
                     || v_order_clause;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'The select Statement is:
      ', v_Statement);
     END IF;
     --
     IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'g_BindVarTab.COUNT',g_BindVarTab.COUNT );
     END IF;
     --
     RLM_CORE_SV.OpenDynamicCursor(c_demand, v_statement, g_BindVarTab);
     --
     LOOP
       BEGIN
         --
	 -- 2554058 : Added edi_test_indicator in the following fetch statement
         --
         FETCH c_demand INTO v_header_id, v_header_ps, edi_test_indicator;
         --
         IF (l_debug <> -1) THEN
            rlm_core_sv.dlog(C_DEBUG, '==============================');
            rlm_core_sv.dlog(C_DEBUG,'Header Id:', v_header_id);
            rlm_core_sv.dlog(C_DEBUG,'v_header_ps:', v_header_ps);
         END IF;
         --
         EXIT WHEN c_demand%NOTFOUND;
         --
         rlm_message_sv.initialize_messages;
         --
         -- bug 2721219
         --
         RLM_FORECAST_SV.k_REPLACE_FLAG := TRUE;
         RLM_FORECAST_SV.g_designator_tab.delete;

         IF v_header_ps IN (rlm_core_sv.k_PS_ERROR,
                            rlm_core_sv.k_PS_PARTIAL_PROCESSED) THEN
           --
           update rlm_interface_headers_all
           set process_status = rlm_core_sv.k_PS_AVAILABLE
           where header_id = v_header_id;
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,' No of headers updated:', SQL%ROWCOUNT);
           END IF;
           --
           update rlm_interface_lines
           set process_status = rlm_core_sv.k_PS_AVAILABLE,
               dsp_child_process_index = NULL
           where header_id = v_header_id
           and process_status = rlm_core_sv.k_PS_ERROR;
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,' No of lines updated:', SQL%ROWCOUNT);
           END IF;
           --
           --Bugfix 6453415 Start <<modified the below query>>
           delete from rlm_demand_exceptions rde
           where rde.interface_header_id = v_header_id
           and (rde.interface_line_id in (select ril.line_id
                                           from rlm_interface_lines ril
                                          where ril.header_id = rde.interface_header_id)
                or exception_level = 'E'
                or message_name    = 'RLM_WARN_DROPPED_ITEMS'); --Bugfix 8844817
           --Bugfix 6453415 End
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,' No of demand exceptions lines deleted:', SQL%ROWCOUNT);
           END IF;
           --
           --Bugfix 6453415 Start
           update rlm_demand_exceptions
           set request_id = rlm_message_sv.g_conc_req_id
           where  interface_header_id = v_header_id;
           --Bugfix 6453415 End
           --
         END IF;
         --
         fnd_profile.get('RLM_WF_ENABLED', v_WF_Enabled);
         --
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'Workflow Enabled set to: ', v_WF_Enabled);
         END IF;
         --
         v_num_child := p_child_processes;
         --
         -- If Profile Workflow Enabled set to No then
         --
         IF (nvl(v_WF_Enabled, 'N') = 'N')  THEN
           --{
           SELECT hsecs INTO l_val_start_time from v$timer;
           rlm_validatedemand_sv.GroupValidateDemand(v_header_id, v_status);
           SELECT hsecs INTO l_val_end_time from v$timer;
           l_val_total:=l_val_total+(l_val_end_time-l_val_start_time)/100;
           --
          IF (v_status = rlm_core_sv.k_PROC_ERROR) OR
             (rlm_validatedemand_sv.g_schedule_PS = rlm_core_sv.k_PS_ERROR)
          THEN
             --
             RAISE e_VDFailed;
             --
          ELSIF (rlm_validatedemand_sv.g_schedule_PS <> rlm_core_sv.k_PS_ERROR)
          THEN
             --
             IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG,'Before PostValidation');
             END IF;
             --
             SELECT hsecs INTO l_post_start_time from v$timer;
             RLM_TPA_SV.PostValidation;
             SELECT hsecs INTO l_post_end_time from v$timer;
             l_post_total:=l_post_total+(l_post_end_time-l_post_start_time)/100;
             COMMIT;
             --
          END IF;
          --
          -- Check for test indicator (Bug 2554058)
          --
          IF edi_test_indicator = 'T' then
           --
	   IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'Test schedule found');
           END IF;
	   --
           raise e_testschedule;
           --
          END IF;
          --
          -- Lock the headers and Populate v_sched_rec
          --
           IF NOT LockHeader(v_Header_Id, v_Sched_rec) THEN
              --
              v_progress := '015';
	      --
              IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'header not locked');
              END IF;
	      --
              raise e_headerLocked;
              --
           END IF;
           --
           -- Check for confirmation schedule
           --
           IF v_Sched_rec.schedule_purpose = k_CONFIRMATION THEN
              --
  	      IF (l_debug <> -1) THEN
                 rlm_core_sv.dlog(C_DEBUG,'RLM_CONF_SCH_RCD');
              END IF;
	      --
              raise e_ConfirmationSchedule;
              --
           END IF;
           --
           -- Call Sweeper Program here
           -- (Enhancement bug# 1062039)
           --
           g_warn_replace_schedule := p_warn_replace_schedule;

           SELECT hsecs INTO l_comp_start_time from v$timer;
           --
           RLM_REPLACE_SV.CompareReplaceSched(v_Sched_rec,
                                              p_warn_replace_schedule,
                                              v_replace_status);
           --
           SELECT hsecs INTO l_comp_end_time from v$timer;
           --
           IF v_replace_status = FALSE THEN
              --
              RAISE e_ReplaceSchedule;
              --
           END IF;
           --
           -- fetch Group in Group Tab
           --
           IF v_num_child > 1 THEN /* Parallel DSP */
             --
             -- submit concurrent program requests
             --
             CreateChildGroups (v_header_id,
                                v_num_child);
             --
             IF NOT LockHeader(v_header_id, v_Sched_rec) THEN
              --
              IF (l_debug <> -1) THEN
               rlm_core_sv.dlog(C_DEBUG, 'Header not locked after
                            CreateChildGroups');
              END IF;
              --
              RAISE e_HeaderLocked;
              --
             END IF;
             --
             -- Parallelize if more than 1 group found
             --
             IF (v_num_child > 1) THEN
               --
               SELECT hsecs INTO l_start_child_time from v$timer;
               --
               SubmitChildRequests(v_header_id,
                                 v_num_child,
                                 v_child_req_id);
               --
               ProcessChildRequests(v_header_id,
                                  v_child_req_id);

               SELECT hsecs INTO l_end_child_time from v$timer;
               v_msg_text:='Total Time spent in DSP Child Requests - '|| (l_end_child_time-l_start_child_time)/100 ;
               fnd_file.put_line(fnd_file.log, v_msg_text);

               v_child_req_id.delete;
               --
             ELSE
               --
               ProcessGroups (v_sched_rec,
                              v_header_id,
                              1, k_SEQ_DSP);
               --
             END IF;
             --
           ELSE /* Sequential Processing */
             --
             ProcessGroups (v_sched_rec,
                           v_header_id,
                           NULL,
			   k_SEQ_DSP);

             --
           END IF; /*check for parallelization*/
           --
           UpdateHeaderPS(v_Sched_rec.header_id,
                          v_Sched_rec.schedule_header_id);
           --
           rlm_message_sv.dump_messages(v_header_id);
           --
           PurgeInterfaceLines(v_header_id);
           --
           COMMIT;
           --}
         ELSE
           -- If Profile Workflow Enabled set to Yes then
           --       -- Call Workflow version of DSP
           --{
           g_warn_replace_schedule := p_warn_replace_schedule;
           --
           IF NOT LockHeader(v_header_id, v_Sched_rec) THEN
            --
            IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'Header not locked');
            END IF;
            --
            RAISE e_HeaderLocked;
            --
           END IF;
           --
           rlm_wf_sv.StartDSPProcess(v_errbuf, v_retcode, v_header_id,
                                     v_Sched_rec,v_num_child);
           --
           retcode := v_retcode;
           --
           COMMIT;
           --}
         END IF;
         --
       EXCEPTION
         --
         WHEN e_ConfirmationSchedule THEN
           --
           IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'RLM_CONF_SCH_RCD');
           END IF;
           --
           rlm_message_sv.app_error(
                x_ExceptionLevel => rlm_message_sv.k_warn_level,
                x_MessageName => 'RLM_CONF_SCH_RCD',
                x_InterfaceHeaderId => v_sched_rec.header_id,
                x_InterfaceLineId => null,
                x_ScheduleHeaderId => v_sched_rec.schedule_header_id,
                x_ScheduleLineId => NULL,
                x_OrderHeaderId => v_group_rec.setup_terms_rec.header_id,
                x_OrderLineId => NULL,
                x_Token1 => 'SCHED_REF',
                x_Value1 => v_sched_rec.schedule_reference_num);
           --
           UpdateGroupPS(v_Sched_rec.header_id,
                         v_Sched_rec.Schedule_header_id,
                         v_Group_rec,
                         rlm_core_sv.K_PS_PROCESSED,
                         'ALL');
           --
           UpdateHeaderPS(v_Sched_rec.header_id,
                          v_Sched_rec.Schedule_header_id);
           --
           rlm_message_sv.dump_messages(v_header_id);
           PurgeInterfaceLines(v_header_id);  /*2699981*/
           --
           COMMIT;
           --
         WHEN NO_DATA_FOUND THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'No data found ');
           END IF;
           --
           rlm_message_sv.dump_messages(v_header_id);
           --
         WHEN e_VDFailed THEN
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Validate Demand Failed');
           END IF;
           --
           ROLLBACK;
           --
           UpdateGroupPS(v_header_id,
                         v_schedule_header_id,
                         v_Group_rec,
                          rlm_core_sv.k_PS_ERROR,
                         'ALL');
           --
           UpdateHeaderPS(v_header_id,
                          v_schedule_header_id);
           --
           rlm_message_sv.dump_messages(v_header_id);
           --
           COMMIT;
           --
         WHEN e_ReplaceSchedule THEN
           --
           ROLLBACK;
           --
           UpdateGroupPS(v_Sched_rec.header_id,
                         v_Sched_rec.schedule_header_id,
                         v_Group_rec,
                         rlm_core_sv.k_PS_ERROR);

           --
           UpdateHeaderPS(v_header_id, v_schedule_header_id);
           rlm_message_sv.dump_messages(v_header_id);
           --
           COMMIT;
           --
	/* Bug 2554058 */
        --
        WHEN e_testschedule THEN
           --
	   IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG, 'request ID', RLM_MESSAGE_SV.g_conc_req_id);
	   END IF;
           --
           rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_warn_level,
              x_MessageName => 'RLM_TEST_SCHEDULE_DETECTED',
              x_InterfaceHeaderId => v_header_id,
              x_InterfaceLineId => NULL,
              x_OrderLineId => NULL,
              x_Token1 => 'SCHED_REF',
              x_Value1 =>rlm_core_sv.get_schedule_reference_num(v_header_id));
           --
           rlm_message_sv.dump_messages(v_header_id);
           PurgeInterfaceLines(v_header_id);   /*2699981*/
           --
           COMMIT;
           --
         WHEN e_headerLocked THEN
           --
           ROLLBACK;
           --
           UpdateGroupPS(v_header_id,
                         v_schedule_header_id,
                         v_Group_rec,
                         rlm_core_sv.k_PS_ERROR,
                         'ALL');
           --
           /* UpdateHeaderPS(v_header_id,
                          v_schedule_header_id); */
	   --
           rlm_message_sv.app_error(
              x_ExceptionLevel => rlm_message_sv.k_error_level,
              x_MessageName => 'RLM_HEADER_LOCK_NOT_OBTAINED',
              x_InterfaceHeaderId => v_header_id,
              x_InterfaceLineId => NULL,
              x_OrderLineId => NULL,
              x_Token1 => 'SCHED_REF',
              x_Value1 => rlm_core_sv.get_schedule_reference_num(v_header_id));
           --
  	   IF (l_debug <> -1) THEN
              rlm_core_sv.dlog(C_DEBUG,'Header could not be locked');
              rlm_core_sv.dpop(C_SDEBUG, 'RLM_LOCK_NOT_OBTAINED');
           END IF;
           --
           rlm_message_sv.dump_messages(v_header_id);
           --
           COMMIT;
           --
         WHEN OTHERS THEN
           --
           ROLLBACK;
           --
           retcode := 2;
           --
           IF (l_debug <> -1) THEN
             rlm_core_sv.dlog(C_DEBUG,'when others');
             rlm_core_sv.dlog(C_DEBUG, 'Return Code', retcode);
             rlm_core_sv.dlog(C_DEBUG, 'ERROR:', SUBSTR(SQLERRM,1,200));
   	     rlm_core_sv.dlog(C_DEBUG, 'request ID', RLM_MESSAGE_SV.g_conc_req_id);
	   END IF;
           --
           UpdateGroupPS(v_header_id,
                             v_schedule_header_id,
                             v_Group_rec,
                             rlm_core_sv.k_PS_ERROR,
                             'ALL');
           --
           UpdateHeaderPS(v_header_id,
                          v_schedule_header_id);
           --
           rlm_message_sv.sql_error('rlm_dp_sv.DemandProcessor', v_Progress);
           --
           rlm_message_sv.dump_messages(v_header_id);
           --
           COMMIT;
           --
       END;
       --
     END LOOP;
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'rowcount' , c_demand%ROWCOUNT);
     END IF;
     --
     IF c_demand%ROWCOUNT = 0 THEN
        --
        rlm_message_sv.initialize_messages;
        --
        rlm_message_sv.app_error(
           x_ExceptionLevel => rlm_message_sv.k_error_level,
           x_MessageName => 'RLM_NO_DATA_FOR_CRITERIA',
           x_InterfaceHeaderId => null,
           x_InterfaceLineId => NULL,
           x_ScheduleHeaderId => null,
           x_ScheduleLineId => NULL,
           x_OrderHeaderId => null,
           x_OrderLineId => NULL,
           x_ErrorText => 'No data found for ',
           x_Token1 => 'SCHEDULE_PURPOSE',
           x_value1 => p_schedule_purpose_code,
           x_Token2 => 'FROM_CUSTOMER_EXT',
           x_value2 => p_from_customer_ext,
           x_Token3 => 'TO_CUSTOMER_EXT',
           x_value3 => p_to_customer_ext);
        --
  	IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG,'RLM_NO_DATA_FOR_CRITERIA' );
        END IF;
	--
        rlm_message_sv.dump_messages;
        --
     END IF;
     --
     CLOSE c_demand;
     --
     RunExceptionReport(x_requestId => rlm_message_sv.g_conc_req_id,
                        x_OrgId     => p_org_id);

     SELECT hsecs INTO l_end_time from v$timer;

     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'ValidateDemandTime', l_val_total);
        rlm_core_sv.dlog(C_DEBUG,'PostValidateTime', l_post_total);
        rlm_core_sv.dlog(C_DEBUG,'CompScheduleTime', l_comp_total);
        rlm_core_sv.dlog(C_DEBUG,'ManageDemandTime', g_md_total);
        rlm_core_sv.dlog(C_DEBUG,'ManageForecastTime', g_mf_total);
        rlm_core_sv.dlog(C_DEBUG,'RecDemandTime', g_rd_total);
        rlm_core_sv.dlog(C_DEBUG,'DSPTime', (l_end_time-l_start_time)/100);
      END IF;

     v_msg_text:='Total Time spent in Validatedemand call - '||l_val_total;
     fnd_file.put_line(fnd_file.log, v_msg_text);

     v_msg_text:='Total Time spent in Postvalidation call - '||l_post_total ;
     fnd_file.put_line(fnd_file.log, v_msg_text);

     v_msg_text:='Total Time spent in CompareSched call - '||l_comp_total ;
     fnd_file.put_line(fnd_file.log, v_msg_text);

     v_msg_text:='Total Time spent in Managedemand call - '|| g_md_total;
     fnd_file.put_line(fnd_file.log, v_msg_text);

     v_msg_text:='Total Time spent in Manageforecast call - '|| g_mf_total ;
     fnd_file.put_line(fnd_file.log, v_msg_text);

     v_msg_text:='Total Time spent in RecDemand call - '|| g_rd_total ;
     fnd_file.put_line(fnd_file.log, v_msg_text);

     v_msg_text:='Total Time spent in DSP call - '||
                 (l_end_time-l_start_time)/100 ;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     --
     v_msg_text := 'Return Code from DSP concurrent program - ' || retcode;
     fnd_file.put_line(fnd_file.log, v_msg_text);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Return Code', retcode);
        rlm_core_sv.dpop(C_SDEBUG);
        rlm_core_sv.stop_debug;
     END IF;
     --
EXCEPTION
  --
  WHEN OTHERS THEN
     --
     retcode := 2;
     rlm_message_sv.sql_error('rlm_dp_sv.DemandProcessor', v_Progress);
     rlm_message_sv.dump_messages(v_header_id);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'Return Code', retcode);
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
        rlm_core_sv.stop_debug;
     END IF;
     raise;
     --
END DemandProcessor;

/*===========================================================================

  PROCEDURE NAME:    PurgeInterfaceLines

===========================================================================*/

PROCEDURE PurgeInterfaceLines(x_header_id IN NUMBER)
IS
  --
  v_Progress VARCHAR2(3) := '010';
  v_process_status   NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'PurgeInterfaceLines');
     rlm_core_sv.dlog(C_DEBUG, 'x_header_id',x_header_id);
  END IF;
  --
  select process_status into v_process_status
  from rlm_interface_headers
  where header_id = x_header_id;
  --
  DELETE FROM RLM_INTERFACE_HEADERS
  WHERE header_id = x_header_id
  and  process_Status = rlm_core_sv.k_PS_PROCESSED;
  --
  IF(v_process_status <> rlm_core_sv.k_PS_PARTIAL_PROCESSED) THEN
    --
    DELETE FROM RLM_INTERFACE_LINES
    WHERE header_id = x_header_id
    and  process_Status = rlm_core_sv.k_PS_PROCESSED;
    --
  ELSE
    --
    DELETE FROM RLM_INTERFACE_LINES
    WHERE header_id = x_header_id
    and  process_Status = rlm_core_sv.k_PS_PROCESSED
    and  item_detail_type <> rlm_rd_sv.k_MRP_FORECAST;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'Lines deleted ', SQL%ROWCOUNT);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
     --
     rlm_message_sv.sql_error('rlm_dp_sv.PurgeInterfaceLines', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'No records to delete' );
        rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_dp_sv.PurgeInterfaceLines', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END PurgeInterfaceLines;

/*=========================================================================

PROCEDURE NAME:       LockHeader

===========================================================================*/

FUNCTION LockHeader (x_HeaderId IN  NUMBER, v_Sched_rec OUT NOCOPY RLM_INTERFACE_HEADERS%ROWTYPE)
RETURN BOOLEAN
IS
x_progress      VARCHAR2(3) := '010';

   CURSOR c IS
     SELECT   *
     FROM   rlm_interface_headers
     WHERE  header_id  = x_HeaderId
     and    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                               rlm_core_sv.k_PS_PARTIAL_PROCESSED)
     FOR UPDATE NOWAIT;

BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'LockHeader');
     rlm_core_sv.dlog(C_DEBUG,'Locking RLM_INTERFACE_HEADERS');
  END IF;
  --
  OPEN  c;
  FETCH c INTO v_Sched_rec;
  --
  IF c%NOTFOUND THEN
     raise NO_DATA_FOUND;
  END IF;
  --
  CLOSE c;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  RETURN(TRUE);
  --
EXCEPTION
    --
  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'APP_EXCEPTION.RECORD_LOCK_EXCEPTION error');
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
    RETURN(FALSE);
    --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'No header found with the headerID',
                                                       x_HeaderId);
       rlm_core_sv.dpop(C_SDEBUG, 'NO_DATA_FOUND');
    END IF;
    --
    RETURN(FALSE);
    --
  WHEN OTHERS THEN
    rlm_message_sv.sql_error('rlm_managedemand_sv.lockHeader', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'progress',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
    RAISE;

END LockHeader;

/*===========================================================================

  PROCEDURE NAME:    UpdateGroupPS

===========================================================================*/

PROCEDURE UpdateGroupPS(x_header_id         IN     NUMBER,
                        x_ScheduleHeaderId  IN     NUMBER,
                        x_Group_rec         IN     rlm_dp_sv.t_Group_rec,
                        x_status            IN     NUMBER,
                        x_UpdateLevel       IN  VARCHAR2)
IS
  --
  v_Progress VARCHAR2(3) := '010';
  v_SchedHeaderId          NUMBER;
  v_login_id               NUMBER;
  v_request_id             NUMBER;
  v_program_app_id         NUMBER;
  v_program_id             NUMBER;
  v_program_update_date    DATE:= sysdate;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'UpdateGroupPS');
     rlm_core_sv.dlog(C_DEBUG,'UpdateGroupStatus to ', x_status);
     rlm_core_sv.dlog(C_DEBUG,'x_header_id ', x_header_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_from_org_id ',
                                   x_Group_rec.ship_from_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.order_header_id ',
                                   x_Group_rec.order_header_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.ship_to_org_id ',
                                   x_Group_rec.ship_to_org_id);
     rlm_core_sv.dlog(C_DEBUG,'x_Group_rec.customer_item_id ',
                                   x_Group_rec.customer_item_id);
     rlm_core_sv.dlog(C_DEBUG,'x_UpdateLevel to ', x_UpdateLevel);
     rlm_core_sv.dlog(C_DEBUG, 'request ID', RLM_MESSAGE_SV.g_conc_req_id);
  END IF;
  --
  v_login_id         := fnd_global.login_id ;
  v_request_id       := RLM_MESSAGE_SV.g_conc_req_id ;
  v_program_app_id   := fnd_global.PROG_APPL_ID ;
  v_program_id       := fnd_global.conc_program_id;
  --
  SELECT schedule_header_id
  INTO  v_SchedHeaderId
  FROM rlm_interface_headers
  WHERE header_id = x_header_id;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_SchedHeaderId', v_SchedHeaderId);
  END IF;
  --
  IF x_UpdateLevel  <> 'GROUP' THEN
     --
     UPDATE rlm_interface_lines
     SET    process_status = x_Status,
            LAST_UPDATE_LOGIN         = v_login_id ,
            REQUEST_ID                = v_request_id,
            PROGRAM_APPLICATION_ID    = v_program_app_id,
            PROGRAM_ID                = v_program_id,
            PROGRAM_UPDATE_DATE       = v_program_update_date
     WHERE  header_id  = x_header_id
     AND    process_status <> rlm_core_sv.k_PS_ERROR; -- bug 5134706

     --
     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'No of interface Lines Updated ', SQL%ROWCOUNT);
     END IF;

     UPDATE rlm_schedule_lines sl
     SET    process_status = x_Status,
            LAST_UPDATE_LOGIN         = v_login_id ,
            REQUEST_ID                = v_request_id,
            PROGRAM_APPLICATION_ID    = v_program_app_id,
            PROGRAM_ID                = v_program_id,
            PROGRAM_UPDATE_DATE       = v_program_update_date
     WHERE  sl.header_id                 =  v_SchedHeaderId
     AND    process_status <> rlm_core_sv.k_PS_ERROR -- bug 5134706
     AND    interface_line_id in
            (SELECT line_id
             FROM rlm_interface_lines_all il
             WHERE il.header_id = x_header_id);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'No of Schedule Lines Updated ', SQL%ROWCOUNT);
     END IF;

  ELSE
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Update Group');
     END IF;
     --
     -- JAUTOMO: Update rlm_schedule_lines first before rlm_interface_lines
     --
     UPDATE rlm_schedule_lines sch
     SET    process_status = x_Status,
            LAST_UPDATE_LOGIN         = v_login_id ,
            REQUEST_ID                = v_request_id,
            PROGRAM_APPLICATION_ID    = v_program_app_id,
            PROGRAM_ID                = v_program_id,
            PROGRAM_UPDATE_DATE       = v_program_update_date
     WHERE  header_id  =  v_SchedHeaderId
     AND    interface_line_id in
            (SELECT line_id
             FROM   rlm_interface_lines_all il
             WHERE  header_id  = x_header_id
             AND    industry_attribute15 = x_Group_rec.industry_attribute15
             AND    ship_to_org_id = x_Group_rec.ship_to_org_id
             AND    customer_item_id = x_Group_rec.customer_item_id
             AND    inventory_item_id = x_Group_rec.inventory_item_id
             AND    process_status  IN (rlm_core_sv.k_PS_AVAILABLE,
                                        rlm_core_sv.k_PS_PROCESSED,
                                        rlm_core_sv.k_PS_FROZEN_FIRM));
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'No of Schedule Lines Updated ', SQL%ROWCOUNT);
     END IF;
     --
     UPDATE rlm_interface_lines
     SET    process_status = x_Status,
            LAST_UPDATE_LOGIN         = v_login_id ,
            REQUEST_ID                = v_request_id,
            PROGRAM_APPLICATION_ID    = v_program_app_id,
            PROGRAM_ID                = v_program_id,
            PROGRAM_UPDATE_DATE       = v_program_update_date
     WHERE  header_id  = x_header_id
     AND    industry_attribute15 = x_Group_rec.industry_attribute15
     AND    ship_to_org_id = x_Group_rec.ship_to_org_id
     AND    customer_item_id = x_Group_rec.customer_item_id
     AND    inventory_item_id = x_Group_rec.inventory_item_id
     AND    process_status  IN (rlm_core_sv.k_PS_AVAILABLE,
                                rlm_core_sv.k_PS_PROCESSED,
                                rlm_core_sv.k_PS_FROZEN_FIRM);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'No of interface Lines Updated ', SQL%ROWCOUNT);
     END IF;
     --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_dp_sv.UpdateGroupPS', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END UpdateGroupPS;

/*=========================================================================

PROCEDURE NAME:       UpdateHeaderPS

===========================================================================*/

PROCEDURE UpdateHeaderPS (x_HeaderId    IN   NUMBER,
                          x_ScheduleHeaderId    IN   NUMBER)
IS
  --
  x_progress      VARCHAR2(3) := '010';
  --
  x_HeaderStatus  NUMBER;
  --
  v_tot_recs   NUMBER;
  v_proc_recs  NUMBER;
  v_error_recs NUMBER;
  v_proc_sch   NUMBER := 0;
  v_SchedHeaderId NUMBER DEFAULT NULL;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG,'UpdateHeaderPS');
     rlm_core_sv.dlog(C_DEBUG,'x_HeaderId',x_HeaderId);
     rlm_core_sv.dlog(C_DEBUG, 'request ID', RLM_MESSAGE_SV.g_conc_req_id);
  END IF;
  --
  SELECT schedule_header_id
  INTO  v_SchedHeaderId
  FROM rlm_interface_headers
  WHERE header_id = x_HeaderId;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'v_SchedHeaderId', v_SchedHeaderId);
  END IF;
  --
  -- Clearup the header status when no data found in the Group ref
  -- if the no of error recs = tot recs then all errors
  -- if the no of proc recs = tot recs then all processed
  -- else partial proc
  --
  SELECT count(*)
  INTO v_tot_recs
  FROM rlm_interface_lines
  WHERE header_id = x_HeaderId;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_tot_recs', v_tot_recs);
  END IF;
  --
  SELECT count(*)
  INTO v_error_recs
  FROM rlm_interface_lines
  WHERE header_id = x_HeaderId
  AND   process_status = rlm_core_sv.k_PS_ERROR;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_error_recs', v_error_recs);
  END IF;
  --
  SELECT count(*)
  INTO v_proc_recs
  FROM rlm_interface_lines
  WHERE header_id = x_HeaderId
  AND   process_status = rlm_core_sv.k_PS_PROCESSED;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_proc_recs', v_proc_recs);
  END IF;
  --
  SELECT COUNT(1)
  INTO v_proc_sch
  FROM rlm_schedule_lines
  WHERE process_status = rlm_core_sv.k_PS_PROCESSED
  AND header_id = v_SchedHeaderId;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'v_proc_sch', v_proc_sch);
  END IF;
  --
  IF v_error_recs = v_tot_recs THEN
    --
    IF v_proc_sch = 0 THEN
      --
      x_HeaderStatus := rlm_core_sv.k_PS_ERROR;
      --
    ELSE
      --
      x_HeaderStatus := rlm_core_sv.k_PS_PARTIAL_PROCESSED;
      --
    END IF;
    --
  ELSIF v_proc_recs = v_tot_recs THEN
    --
    x_HeaderStatus := rlm_core_sv.k_PS_PROCESSED;
    --
  ELSE
    --
    x_HeaderStatus := rlm_core_sv.k_PS_PARTIAL_PROCESSED;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'x_HeaderStatus', x_HeaderStatus);
  END IF;
  --
  UPDATE rlm_interface_headers
  SET    process_status            = x_HeaderStatus,
         LAST_UPDATE_LOGIN         = fnd_global.login_id ,
         REQUEST_ID                = RLM_MESSAGE_SV.g_conc_req_id ,
         PROGRAM_APPLICATION_ID    = fnd_global.PROG_APPL_ID ,
         PROGRAM_ID                = fnd_global.conc_program_id,
         PROGRAM_UPDATE_DATE       = sysdate
  WHERE  header_id  = x_HeaderId;
  --
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Number of Interface header updated',SQL%ROWCOUNT);
  END IF;
  --
  UPDATE rlm_schedule_headers
  SET    process_status            = x_HeaderStatus,
         LAST_UPDATE_LOGIN         = fnd_global.login_id ,
         REQUEST_ID                = RLM_MESSAGE_SV.g_conc_req_id ,
         PROGRAM_APPLICATION_ID    = fnd_global.PROG_APPL_ID ,
         PROGRAM_ID                = fnd_global.conc_program_id,
         PROGRAM_UPDATE_DATE       = sysdate
  WHERE  header_id  = v_SchedHeaderId ;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG,'Number of schedule header updated',SQL%ROWCOUNT);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
    --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'NO DATA FOUND ERROR',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_dp_sv.UpdateHeaderStatus', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
END UpdateHeaderPS;


/*=========================================================================

PROCEDURE NAME:       RunExceptionReport

===========================================================================*/

PROCEDURE RunExceptionReport(x_requestId    IN   NUMBER,
                             x_OrgId        IN   NUMBER)
IS
  --
  x_progress           VARCHAR2(3) := '010';
  x_errors             NUMBER := 0;
  x_request_id         NUMBER := -1;
  v_org_id             NUMBER := 0;
  x_no_copies          NUMBER :=0;
  x_print_style        VARCHAR2(30);
  x_printer            VARCHAR2(30);
  x_save_output_flag   VARCHAR2(1);
  x_result             BOOLEAN;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush('RunExceptionReport');
     rlm_core_sv.dlog('Request Id', x_requestId);
     rlm_core_sv.dlog('Org ID', x_OrgId);
  END IF;
  --
  /** If there are Errors/warnings then only submit Concurrent Request for
         Exception Report. ****/
  --
  Select count(*)
  into x_errors
  from rlm_demand_exceptions
  where request_id = x_requestid
  and exception_level in ('E', 'W', 'I');
  --
  IF (x_errors > 0) then
     --
     x_result :=fnd_concurrent.get_request_print_options(
                                   fnd_global.conc_request_id,
                                   x_no_copies   ,
                                   x_print_style ,
                                   x_printer  ,
                                   x_save_output_flag );
     --
     IF (x_result =TRUE) then
         --
         x_result :=fnd_request.set_print_options(x_printer,
                                      x_print_style,
                                      x_no_copies,
                                      NULL,
                                      'N');
         --
     END IF;
     --
     fnd_request.set_org_id(x_OrgId);
     --
     x_request_id := fnd_request.submit_request ('RLM',
                                          'RLMDPDER',
                                          NULL,
                                          NULL,
                                          FALSE,
                                          x_OrgId,
                                          x_requestId,
                                          x_requestId,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL, --v_sched_num
                                          NULL, --v_sched_num
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog('Report Request Id ', x_request_id);
    END IF;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'NO DATA FOUND ERROR',x_Progress);
       rlm_core_sv.dpop(C_SDEBUG);
    END IF;
    --
  WHEN OTHERS THEN
    --
    rlm_message_sv.sql_error('rlm_dp_sv.RunExceptionReport', x_progress);
    --
    IF (l_debug <> -1) THEN
       rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: OTHER - sql error');
    END IF;
    --
END RunExceptionReport;

/*===========================================================================

  FUNCTION NAME:    CheckForecast

===========================================================================*/

FUNCTION CheckForecast(x_header_id         IN     NUMBER,
                       x_Group_rec         IN     rlm_dp_sv.t_Group_rec)
RETURN BOOLEAN

IS
  --
  v_Progress VARCHAR2(3) := '010';
  v_Count NUMBER := 0;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dpush(C_SDEBUG, 'CheckForecast');
  END IF;
  --
  --
  SELECT count(*) into v_Count
  FROM rlm_interface_lines
  WHERE  header_id  = x_header_id
  AND    industry_attribute15 = x_Group_rec.industry_attribute15
  AND    ship_to_org_id = x_Group_rec.ship_to_org_id
  AND    customer_item_id = x_Group_rec.customer_item_id
  AND    item_detail_type = rlm_rd_sv.k_MRP_FORECAST
  AND    process_status   = rlm_core_sv.k_PS_AVAILABLE;
  --
  IF (l_debug <> -1) THEN
     rlm_core_sv.dlog('No of Forecast Lines for this group', v_Count);
     rlm_core_sv.dpop(C_SDEBUG);
  END IF;

  IF(v_Count>0) THEN
    return (TRUE);
  ELSE
    return (FALSE);
  END IF;

  --
EXCEPTION
  --
  WHEN OTHERS THEN
     --
     rlm_message_sv.sql_error('rlm_dp_sv.CheckForecast', v_Progress);
     --
     IF (l_debug <> -1) THEN
        rlm_core_sv.dpop(C_SDEBUG,'EXCEPTION: '|| SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END CheckForecast;

/*===========================================================================

  PROCEDURE NAME:    CreateChildGroups

===========================================================================*/

PROCEDURE CreateChildGroups(x_header_id            IN NUMBER,
                            x_num_child            IN OUT NOCOPY NUMBER)

IS
 --
 v_index NUMBER;
 v_group_count NUMBER;
 v_Group_rec t_group_rec;
 --
 CURSOR c_group_cur IS
    SELECT   ril.order_header_id,
             ril.blanket_number
    FROM     rlm_interface_headers   rih,
             rlm_interface_lines_all ril
    WHERE    ril.header_id = x_header_id
    AND      ril.header_id = rih.header_id
    AND      ril.process_status in ( rlm_core_sv.k_PS_AVAILABLE,
                                     rlm_core_sv.k_PS_PARTIAL_PROCESSED)
    AND      rih.org_id = ril.org_id
    GROUP BY ril.order_header_id,ril.blanket_number ;
 --
BEGIN
 --
 -- Distribute groups among processes by marking lines
 --  with a child process index
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.dpush(C_SDEBUG, 'CreateChildGroups');
  rlm_core_sv.dlog(C_DEBUG, 'header Id', x_header_id);
  rlm_core_sv.dlog(C_DEBUG, 'Input num of child processes', x_num_child);
 END IF;
 --
 v_index:=1;
 v_group_count:=0;
 --
 OPEN c_group_cur;
 --
 LOOP
  --
  BEGIN
    --
    FETCH c_group_cur INTO
          v_Group_rec.order_header_id,
          v_Group_rec.blanket_number;
    --
    EXIT WHEN c_group_cur%NOTFOUND;
    --
    v_group_count:=v_group_count+1;
    --
    update rlm_interface_lines
    set    dsp_child_process_index = v_index
    where  header_id = x_header_id
    and    nvl(order_header_id,-99) = nvl(v_Group_rec.order_header_id,-99)
    and    nvl(blanket_number,-99) =  nvl(v_Group_rec.blanket_number,-99);
    --
    COMMIT;
    --
    IF (v_index = x_num_child ) THEN
      --
      v_index:=1;
      --
    ELSE
      --
      v_index:= v_index+1;
      --
    END IF;
    --
  END;
  --
  END LOOP;
  --
  CLOSE c_group_cur;
  --
  IF(v_group_count < x_num_child) THEN
    --
    x_num_child := v_group_count;
    --
  END IF;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Actual num of child processes', x_num_child);
    rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
  -- end of marking lines with child process index
  --
EXCEPTION
  --
  When others then
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG, SUBSTRB(SQLERRM, 1, 200));
   END IF;
   --
   raise;

END CreateChildGroups;

/*===========================================================================

  PROCEDURE NAME:    SubmitChildRequests

===========================================================================*/

PROCEDURE SubmitChildRequests(
                x_header_id            IN NUMBER,
                x_num_child            IN NUMBER,
                x_child_req_id         IN OUT NOCOPY g_request_tbl)
IS
  --
  pragma AUTONOMOUS_TRANSACTION;
  i NUMBER;
  v_msg_text VARCHAR2(32000);
  v_OrgId  NUMBER;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpush(C_SDEBUG, 'SubmitChildRequests');
   rlm_core_sv.dlog(C_DEBUG, 'Current Org', MO_GLOBAL.get_current_org_id);
  END IF;
  --
  v_OrgId := MO_GLOBAL.get_current_org_id;
  --
  FOR i in 1..x_num_child LOOP
    --
    fnd_request.set_org_id(v_OrgId);
    --
    x_child_req_id(x_child_req_id.COUNT+1) :=
    fnd_request.submit_request('RLM',
                               'RLMDSPCHILD',
                                NULL,
                                NULL,
                                FALSE,
                                fnd_global.conc_request_id,
                                x_header_id,
                                i,
                                v_OrgId);
    --
    v_msg_text:='Submitting DSP Child Request: '||x_child_req_id(i);
    fnd_file.put_line(fnd_file.log, v_msg_text);
    --
    IF (l_debug <> -1) THEN
     rlm_core_sv.dlog(C_DEBUG, 'DSP Child request', x_child_req_id(i));
    END IF;
    --
  END LOOP;
  --
  COMMIT;
  --
  IF (l_debug <> -1) THEN
   rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  When others then
   --
   IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
   raise;
   --
END SubmitChildRequests;

/*===========================================================================

  PROCEDURE NAME:    ProcessChildRequests

===========================================================================*/

PROCEDURE ProcessChildRequests(x_header_id            IN NUMBER,
                               x_child_req_id         IN g_request_tbl)
IS
  --
  i                NUMBER;
  v_index          NUMBER DEFAULT 0;
  v_group_count    NUMBER DEFAULT 0;
  v_phase          VARCHAR2(80);
  v_reqstatus      VARCHAR2(80);
  v_devphase       VARCHAR2(80);
  v_devstatus      VARCHAR2(80);
  v_reqmessage     VARCHAR2(80);
  v_wait_status    BOOLEAN;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG, 'ProcessChildRequests');
    rlm_core_sv.dlog(C_DEBUG, 'Total number of child requests',
                     x_child_req_id.COUNT);
  END IF;
  --
  /* parent process has to wait until each child request
     is completed before it can update the header.
     child request updates the interface lines after
     completing manage demand, forecast and rec demand */
  --
  FOR i IN x_child_req_id.FIRST..x_child_req_id.LAST LOOP
    --
    v_wait_status := fnd_concurrent.wait_for_request(
                                       x_child_req_id(i),
				       10,     -- check every 10 sec
				       10000,  -- timeout after 10000 sec
				       v_phase,
				       v_reqstatus,
				       v_devphase,
				       v_devstatus,
				       v_reqmessage);
    --
    update rlm_demand_exceptions
    set request_id = RLM_MESSAGE_SV.g_conc_req_id
    where request_id = x_child_req_id(i);
    --
    /* update group status for all lines with child req id*/
    --
    IF (l_debug <> -1) THEN
      rlm_core_sv.dlog(C_DEBUG,'child process index ', i);
      rlm_core_sv.dlog(C_DEBUG, 'v_phase', v_phase);
      rlm_core_sv.dlog(C_DEBUG, 'v_reqstatus', v_reqstatus);
      rlm_core_sv.dlog(C_DEBUG, 'v_devphase', v_devphase);
      rlm_core_sv.dlog(C_DEBUG, 'v_devstatus', v_devstatus);
    END IF;
    --
    IF(upper(v_reqstatus) <> 'NORMAL') THEN
      --
      update rlm_interface_lines
      set    process_status=    rlm_core_sv.k_PS_ERROR
      where  header_id = x_header_id
      and    dsp_child_process_index = i
      and    process_status <> rlm_core_sv.k_PS_PROCESSED;
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'x_header_id', x_header_id);
        rlm_core_sv.dlog(C_DEBUG,'No of interface Lines Updated', SQL%ROWCOUNT);
      END IF;
      --
      update rlm_schedule_lines sch
      set    process_status = rlm_core_sv.k_PS_ERROR
      where  interface_line_id in
           (select line_id
            from   rlm_interface_lines_all il
            where  header_id = x_header_id
            and    dsp_child_process_index = i
            and    process_status <> rlm_core_sv.k_PS_PROCESSED);
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'No of schedule Lines Updated ', SQL%ROWCOUNT);
      END IF;
      --
    END IF;
    --
    COMMIT;
    --
  END LOOP;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpop(C_SDEBUG);
  END IF;
  --
EXCEPTION
  --
  When others then
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG,'Error: '|| SUBSTR(SQLERRM,1,200));
   END IF;
   raise;
   --
END ProcessChildRequests;


/*===========================================================================

  PROCEDURE NAME:    ChildProcess

===========================================================================*/

PROCEDURE ChildProcess(errbuf                 OUT NOCOPY    VARCHAR2,
                       retcode                OUT NOCOPY    VARCHAR2,
                       p_request_id           IN            NUMBER,
                       p_header_id            IN            NUMBER,
                       p_index                IN            NUMBER,
                       p_org_id               IN            NUMBER)
IS
 --
 v_group_rec          t_group_rec;
 v_sched_rec          rlm_interface_headers%ROWTYPE;
 e_linesLocked	      EXCEPTION;
 e_MDFailed           EXCEPTION;
 e_FDFailed           EXCEPTION;
 e_RDFailed           EXCEPTION;
 v_status             NUMBER;
 v_temp NUMBER;
 --
BEGIN
 --
 rlm_message_sv.populate_req_id;
 --
 IF (l_debug <> -1) THEN
  rlm_core_sv.start_debug;
  rlm_core_sv.dpush(C_SDEBUG, 'ChildProcess');
  rlm_core_sv.dlog(C_DEBUG, 'p_request_id', p_request_id);
  rlm_core_sv.dlog(C_DEBUG, 'p_header_id', p_header_id);
  rlm_core_sv.dlog(C_DEBUG, 'p_index', p_index);
  rlm_core_sv.dlog(C_DEBUG, 'p_org_id', p_org_id);
 END IF;
 --
 -- Initialize retcode to 0 and set to 2 only in case of fatal error
 --
 retcode := 0;
 --
 IF MO_GLOBAL.get_current_org_id IS NULL THEN
  --
  MO_GLOBAL.set_policy_context(p_access_mode => 'S',
                               p_org_id      => p_org_id);
  --
 END IF;
 --
 BEGIN
  --{
  -- populate v_sched_rec
  --
  SELECT *
  INTO   v_sched_rec
  FROM   rlm_interface_headers_all
  WHERE  header_id  = p_header_id
  AND    process_status IN (rlm_core_sv.k_PS_AVAILABLE,
                            rlm_core_sv.k_PS_PARTIAL_PROCESSED);
  --
 EXCEPTION
  --
  WHEN NO_DATA_FOUND THEN
   --
   UpdateGroupPS(p_header_id,
                 null,
                 v_Group_rec,
                 rlm_core_sv.K_PS_ERROR,
                 'ALL');
   COMMIT;
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG, 'when others'|| SUBSTR(SQLERRM,1,200));
     rlm_core_sv.stop_debug;
   END IF;
   --
   RETURN;
   --}
 END;
 --
 ProcessGroups(v_sched_rec,
              p_header_id,
              p_index, k_PARALLEL_DSP);
 --
 IF (l_debug <> -1) THEN
   rlm_core_sv.dlog(C_DEBUG, 'Return Code', retcode);
   rlm_core_sv.dpop(C_SDEBUG);
   rlm_core_sv.stop_debug;
 END IF;
 --
EXCEPTION
 --
 WHEN OTHERS THEN
  --
  retcode := 2;
  --
  update rlm_interface_lines
  set    process_status = rlm_core_sv.k_PS_ERROR
  where  header_id = p_header_id
  and    dsp_child_process_index = p_index;
  --
  update rlm_schedule_lines sch
  set    process_status = rlm_core_sv.k_PS_ERROR
  where  interface_line_id in
                        (select line_id
                         from   rlm_interface_lines_all il
                         where  header_id = p_header_id
                         and    dsp_child_process_index = p_index);
  --
  COMMIT;
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dlog(C_DEBUG, 'Return Code', retcode);
    rlm_core_sv.dlog(C_DEBUG,'When others:'||SUBSTR(SQLERRM,1,200));
    rlm_core_sv.dpop(C_SDEBUG);
    rlm_core_sv.stop_debug;
  END IF;
  --
END ChildProcess;

/*===========================================================================

  PROCEDURE NAME:    ProcessGroups

===========================================================================*/

PROCEDURE ProcessGroups (p_sched_rec IN RLM_INTERFACE_HEADERS%ROWTYPE,
                         p_header_id IN NUMBER,
                         p_index     IN NUMBER DEFAULT NULL,
                         p_dspMode   IN VARCHAR2)
IS
 --
 v_sched_rec RLM_INTERFACE_HEADERS%ROWTYPE;
 v_Group_rec  t_Group_rec;
 e_linesLocked	      EXCEPTION;
 e_MDFailed           EXCEPTION;
 e_FDFailed           EXCEPTION;
 e_RDFailed           EXCEPTION;
 v_status             NUMBER;
 v_temp NUMBER;
 l_md_start_time  NUMBER;
 l_md_end_time    NUMBER;
 l_md_total NUMBER :=0;
 l_mf_start_time  NUMBER;
 l_mf_end_time    NUMBER;
 l_mf_total NUMBER:=0;
 l_rd_start_time  NUMBER;
 l_rd_end_time    NUMBER;
 l_rd_total NUMBER:=0;
 v_msg_text       VARCHAR2(32000);

 -- ER 4299804
 -- Adding ril.start_date_time to the cursor so that the group with the
 -- earliest date will be fetched first in to cursor.This is done as a part of
 -- Eaton ER-Across Item Behaviour for blankets.
 -- CR : added ship_to_customer_id as part of grouping criteria
 --
 CURSOR c_group_cur IS
    SELECT   rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_site_use_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.intrmd_ship_to_id,       --Bugfix 5911991
 	     ril.intmed_ship_to_org_id,   --Bugfix 5911991
             ril.order_header_id,
	     ril.blanket_number,
             min(ril.start_date_time),
             ril.ship_to_customer_id
    FROM     rlm_interface_headers   rih,
             rlm_interface_lines_all ril
    WHERE    ril.header_id = p_header_id
    AND      ril.header_id = rih.header_id
    AND      nvl(ril.dsp_child_process_index,-99) =nvl(p_index, -99)
    AND      ril.process_status in ( rlm_core_sv.k_PS_AVAILABLE,
                                     rlm_core_sv.k_PS_PARTIAL_PROCESSED)
    AND      rih.org_id = ril.org_id
    GROUP BY rih.customer_id,
             ril.ship_from_org_id,
             ril.ship_to_address_id,
             ril.ship_to_site_use_id,
             ril.ship_to_org_id,
             ril.customer_item_id,
             ril.inventory_item_id,
             ril.industry_attribute15,
             ril.intrmd_ship_to_id,       --Bugfix 5911991
	     ril.intmed_ship_to_org_id,   --Bugfix 5911991
             ril.order_header_id,
	     ril.blanket_number,
             ril.ship_to_customer_id
    ORDER BY min(ril.start_date_time),
             ril.ship_to_address_id,
             ril.customer_item_id;
  --
BEGIN
  --
  IF (l_debug <> -1) THEN
    rlm_core_sv.dpush(C_SDEBUG, 'PROCESSGROUPS');
    rlm_core_sv.dlog(C_DEBUG, 'DSP Mode', p_dspMode);
  END IF;
  --
  v_sched_rec := p_sched_rec;
  --
  OPEN c_group_cur;
   --
   LOOP
    --{
    BEGIN
     --{
     -- ER 4299804: Added min_start_date_time to the fetch stmt.
     --
     FETCH c_group_cur INTO
        v_Group_rec.customer_id,
        v_Group_rec.ship_from_org_id,
        v_Group_rec.ship_to_address_id,
        v_Group_rec.ship_to_site_use_id,
        v_Group_rec.ship_to_org_id,
        v_Group_rec.customer_item_id,
        v_Group_rec.inventory_item_id,
        v_Group_rec.industry_attribute15,
        v_Group_rec.intrmd_ship_to_id,       --Bugfix 5911991
        v_Group_rec.intmed_ship_to_org_id,   --Bugfix 5911991
        v_Group_rec.order_header_id,
        v_Group_rec.blanket_number,
        v_Group_rec.min_start_date_time,
        v_Group_rec.ship_to_customer_id;
      --
      EXIT WHEN c_group_cur%NOTFOUND;
      --
      SAVEPOINT GroupDemand;
      --
      IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, '***** Processing new group ****');
      END IF;
      --
      SELECT hsecs INTO l_md_start_time from v$timer;
      --
      IF NOT rlm_manage_demand_sv.LockLines(v_sched_rec.header_id,
                                            v_group_rec)
      THEN
       --
       RAISE e_linesLocked;
       --
      END IF;
      --
      rlm_manage_demand_sv.ManageDemand(v_sched_rec.header_id,
                                        v_sched_rec,
                                        v_group_rec,
                                        v_status);
      --
      SELECT hsecs INTO l_md_end_time from v$timer;
      l_md_total:=l_md_total+(l_md_end_time-l_md_start_time)/100;
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'v_status:',v_status);
      END IF;
      --
      IF v_status = rlm_core_sv.k_PROC_ERROR THEN
       --
       RAISE e_MDFailed;
       --
      END IF;
      --
      SELECT hsecs INTO l_mf_start_time from v$timer;
      --
      rlm_tpa_sv.ManageForecast(v_sched_rec.header_id,
                                v_sched_rec,
                                v_group_rec,
                                v_status);
      --
      SELECT hsecs INTO l_mf_end_time from v$timer;
      l_mf_total:=l_mf_total+(l_mf_end_time-l_mf_start_time)/100;
      --
      IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG,'v_status:',v_status);
      END IF;
      --
      IF v_status = rlm_core_sv.k_PROC_ERROR THEN
       --
       RAISE e_FDFailed;
       --
      END IF;
      --
      SELECT hsecs INTO l_rd_start_time from v$timer;
      --
      rlm_rd_sv.RecDemand(v_sched_rec.header_id,
                          v_sched_rec,
                          v_group_rec,
                          v_status);
      --
      SELECT hsecs INTO l_rd_end_time from v$timer;
      l_rd_total:=l_rd_total+(l_rd_end_time-l_rd_start_time)/100;
      --
      IF v_status = rlm_core_sv.k_PROC_ERROR THEN
       --
       RAISE e_RDFailed;
       --
      END IF;
      --
      UpdateGroupPS(v_Sched_rec.header_id,
                    v_Sched_rec.schedule_header_id,
                    v_Group_rec,
                    rlm_core_sv.k_PS_PROCESSED);
      --
      COMMIT;
      --
      IF (p_dspMode = k_SEQ_DSP) THEN
       --
       IF NOT LockHeader(p_header_id, v_Sched_rec) THEN
        --
        IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header after call ProcessGroups');
        END IF;
        --
        RAISE e_headerLocked;
        --
       END IF;
       --
      END IF;
      --
    EXCEPTION
     --
     WHEN e_MDFailed THEN
       --
       IF (l_debug <> -1) THEN
         rlm_core_sv.dlog(C_DEBUG,'Manage Demand failed group');
       END IF;
       --
       ROLLBACK TO GroupDemand;
       --
       UpdateGroupPS(v_Sched_rec.header_id,
                     v_Sched_rec.schedule_header_id,
                     v_Group_rec,
                     rlm_core_sv.k_PS_ERROR);
       -- Bug#: 2771756 - Start
       -- Bug 4198330 added group information
         rlm_core_sv.dlog(C_DEBUG,'Manage Demand remove messages');
       rlm_message_sv.removeMessages(
               p_header_id       => p_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => v_group_rec.ship_from_org_id,
               p_ship_to_address_id => v_group_rec.ship_to_address_id,
               p_customer_item_id => v_group_rec.customer_item_id,
               p_inventory_item_id => v_group_rec.inventory_item_id);
       -- Bug#: 2771756 - End
       rlm_message_sv.dump_messages(p_header_id);
       --
       COMMIT;
       --
       IF (p_dspMode = k_SEQ_DSP) THEN
        --
        IF NOT LockHeader(p_header_id, v_Sched_rec) THEN
         --
         IF (l_debug <> -1) THEN
          rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_MDFailed');
         END IF;
         --
         RAISE e_HeaderLocked;
         --
        END IF;
        --
       END IF;
       --
     WHEN e_FDFailed THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Forecast Processor failed group');
       END IF;
       --
       ROLLBACK TO GroupDemand;
       --
       UpdateGroupPS(v_Sched_rec.header_id,
                     v_Sched_rec.schedule_header_id,
                     v_Group_rec,
                     rlm_core_sv.k_PS_ERROR);
       -- Bug#: 2771756 - Start
       -- Start bug 4198330  added grouping information
       rlm_message_sv.removeMessages(
               p_header_id       => p_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => v_group_rec.ship_from_org_id,
               p_ship_to_address_id => v_group_rec.ship_to_address_id,
               p_customer_item_id => v_group_rec.customer_item_id,
               p_inventory_item_id => v_group_rec.inventory_item_id);
       -- Bug#: 2771756 - End
       rlm_message_sv.dump_messages(p_header_id);
       --
       COMMIT;
       --
       IF (p_dspMode = k_SEQ_DSP) THEN
        --
        IF NOT LockHeader(p_header_id, v_Sched_rec) THEN
         --
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_FDFailed');
         END IF;
         --
         RAISE e_HeaderLocked;
         --
        END IF;
        --
       END IF;
       --
     WHEN e_RDFailed THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG,'Reconcile Demand failed group');
       END IF;
       --
       ROLLBACK TO GroupDemand;
       --
       UpdateGroupPS(v_Sched_rec.header_id,
                     v_Sched_rec.schedule_header_id,
                     v_Group_rec,
                     rlm_core_sv.k_PS_ERROR);
       -- Bug#: 2771756 - Start
       -- Start bug 4198330 added  grouping information
       rlm_core_sv.dlog(C_DEBUG,' before remove messages');
       rlm_message_sv.removeMessages(
               p_header_id       => p_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => v_group_rec.ship_from_org_id,
               p_ship_to_address_id => v_group_rec.ship_to_address_id,
               p_customer_item_id => v_group_rec.customer_item_id,
               p_inventory_item_id => v_group_rec.inventory_item_id);
       -- Bug#: 2771756 - End
       rlm_message_sv.dump_messages(p_header_id);
       --
       COMMIT;
       --
       IF (p_dspMode = k_SEQ_DSP) THEN
        --
        IF NOT LockHeader(p_header_id, v_Sched_rec) THEN
         --
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_RDFailed');
         END IF;
         --
         RAISE e_HeaderLocked;
         --
        END IF;
        --
       END IF;
       --
     WHEN e_HeaderLocked THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'e_HeaderLocked grp. level exception handler');
       END IF;
       --
       RAISE e_HeaderLocked;
       --
     WHEN OTHERS THEN
       --
       IF (l_debug <> -1) THEN
        rlm_core_sv.dlog(C_DEBUG, 'ERROR::', SUBSTR(SQLERRM,1,200));
       END IF;
       --
       ROLLBACK TO GroupDemand;
       --
       UpdateGroupPS(v_Sched_rec.header_id,
                     v_Sched_rec.schedule_header_id,
                     v_Group_rec,
                     rlm_core_sv.k_PS_ERROR);
       -- Bug#: 2771756 - Start
       -- Start bug 4198330 added grouping information
       rlm_message_sv.removeMessages(
               p_header_id       => p_header_id,
               p_message         => 'RLM_RSO_CREATION_INFO',
               p_message_type    => 'I',
               p_ship_from_org_id => v_group_rec.ship_from_org_id,
               p_ship_to_address_id => v_group_rec.ship_to_address_id,
               p_customer_item_id => v_group_rec.customer_item_id,
               p_inventory_item_id => v_group_rec.inventory_item_id);
       -- Bug#: 2771756 - End
       rlm_message_sv.dump_messages(p_header_id);
       --
       COMMIT;
       --
       IF (p_dspMode = k_SEQ_DSP) THEN
        --
        IF NOT LockHeader(p_header_id, v_Sched_rec) THEN
         --
         IF (l_debug <> -1) THEN
           rlm_core_sv.dlog(C_DEBUG, 'Unable to lock header in e_MDFailed');
         END IF;
         --
         RAISE e_HeaderLocked;
         --
        END IF;
        --
       END IF;
     --}
    END;
    --}
   END LOOP;  /*Loop for fetching groups with same child process index*/
   CLOSE c_group_cur;
   --
   g_md_total := g_md_total + l_md_total;
   g_mf_total := g_mf_total + l_mf_total;
   g_rd_total := g_rd_total + l_rd_total;
   --
   IF (p_dspMode <> k_SEQ_DSP) THEN
    --
    v_msg_text:='Total Time spent in Managedemand call - '|| l_md_total;
    fnd_file.put_line(fnd_file.log, v_msg_text);
    --
    v_msg_text:='Total Time spent in Manageforecast call - '|| l_mf_total ;
    fnd_file.put_line(fnd_file.log, v_msg_text);
    --
    v_msg_text:='Total Time spent in RecDemand call - '|| l_rd_total ;
    fnd_file.put_line(fnd_file.log, v_msg_text);
    --
   END IF;
   --
   IF (l_debug <> -1) THEN
     rlm_core_sv.dpop(C_SDEBUG);
   END IF;
   --
EXCEPTION
    --
    WHEN e_HeaderLocked THEN
     --
     IF c_group_cur%ISOPEN THEN
        CLOSE c_group_cur; --bug 4570658
     END IF;

     IF (l_debug <> -1) THEN
       rlm_core_sv.dlog(C_DEBUG, 'e_HeaderLocked Exception in ProcessGroups');
       rlm_core_sv.dpop(C_SDEBUG);
     END IF;
     --
     RAISE e_HeaderLocked;
     --
    WHEN OTHERS THEN
     --
     IF (l_debug <> -1) THEN
       rlm_message_sv.dump_messages(p_header_id);
       rlm_core_sv.dpop(C_SDEBUG, 'Error: '||SUBSTR(SQLERRM,1,200));
     END IF;
     --
     raise;
     --
END ProcessGroups;

END RLM_DP_SV;

/
