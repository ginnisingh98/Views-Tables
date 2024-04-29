--------------------------------------------------------
--  DDL for Package Body CAC_TASK_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_TASK_PURGE_PVT" AS
/* $Header: cactkpvb.pls 120.18 2006/07/13 12:22:58 sbarat noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cactkpvb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for the commonly used procedure or    |
 |     function.                                                         |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer             Change                            |
 | ------        ---------------       ----------------------------------|
 | 10-Aug-2005   Swapan Barat          Created                           |
 | 12-Sep-2005   Swapan Barat          Added logic to delete attachments |
 |                                     and calling Note's API to delete  |
 |                                     Notes associated with task        |
 | 19-Jan-2006   Swapan Barat          Added INDEX hint for bug# 4888496 |
 | 02-Feb-2006   Swapan Barat          Added FND_LOG                     |
 | 21-Feb-2006   Swapan Barat          Added call to Field Service,      |
 |                                     UWQ and Interaction History's API |
 | 02-Mar-2006   Swapan Barat          Added Task's Timezone concept     |
 |                                     for bug# 5058905			 |
 | 15-May-2006   Manas Padhiary        Added code to delete from table	 |
 |				               JTF_TASK_ALL_ASSIGNMENT and       |
 |				               Added code to delete record       |
 |				               record from JTF_TASK_PHONE table	 |
 |				               for Bug # 5216358.                |
 | 30-May-2006   Swapan Barat          For bug# 5213367. Using index     |
 |                                     fnd_concurrent_programs_U1,instead|
 |                                     of fnd_concurrent_programs_U2     |
 | 13-Jul-2006   Swapan Barat          Checking template_flag <> 'Y'     |
 |                                     before removing records from      |
 |                                     JTF_TASK_DEPENDS for bug# 5388975 |
 +======================================================================*/

 Procedure PURGE_STANDALONE_TASKS (
      errbuf				OUT  NOCOPY  VARCHAR2,
      retcode				OUT  NOCOPY  VARCHAR2,
      p_creation_date_from          IN   VARCHAR2 ,
      p_creation_date_to            IN   VARCHAR2 ,
      p_last_updation_date_from     IN   VARCHAR2 ,
      p_last_updation_date_to       IN   VARCHAR2 ,
      p_planned_end_date_from       IN   VARCHAR2 ,
      p_planned_end_date_to         IN   VARCHAR2 ,
      p_scheduled_end_date_from     IN   VARCHAR2 ,
      p_scheduled_end_date_to       IN   VARCHAR2 ,
      p_actual_end_date_from        IN   VARCHAR2 ,
      p_actual_end_date_to          IN   VARCHAR2 ,
      p_task_type_id                IN   NUMBER   DEFAULT  NULL ,
      p_task_status_id              IN   NUMBER   DEFAULT  NULL ,
      p_delete_closed_task_only     IN   VARCHAR2 DEFAULT  fnd_api.g_false ,
      p_delete_deleted_task_only    IN   VARCHAR2 DEFAULT  fnd_api.g_false,
      p_no_of_worker                IN   NUMBER   DEFAULT  4 )
 IS
      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	       CONSTANT VARCHAR2(30) := 'PURGE_STANDALONE_TASKS';

      l_sql_string		       VARCHAR2(2000);
      l_request_id                   NUMBER;
      l_request_data                 VARCHAR2(1);
      l_no_of_worker                 NUMBER;
      l_batch_size                   NUMBER;
      l_set_worker                   NUMBER;
      l_start				 NUMBER;
      l_end					 NUMBER;

      l_msg_count                    NUMBER;
      l_msg_data                     VARCHAR2(2000);

      l_tz_enabled_prof              VARCHAR2(10) := fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS');
      l_server_tz_id                 NUMBER := to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
      l_tz_enabled                   VARCHAR2(10) := 'N';

      l_creation_date_from          DATE;
      l_creation_date_to            DATE;
      l_last_updation_date_from     DATE;
      l_last_updation_date_to       DATE;
      l_planned_end_date_from       DATE;
      l_planned_end_date_to         DATE;
      l_scheduled_end_date_from     DATE;
      l_scheduled_end_date_to       DATE;
      l_actual_end_date_from        DATE;
      l_actual_end_date_to          DATE;

    -- Variables holding the status information of each
    -- worker concurrent request

      l_worker_conc_req_phase        VARCHAR2(100);
      l_worker_conc_req_status       VARCHAR2(100);
      l_worker_conc_req_dev_phase    VARCHAR2(100);
      l_worker_conc_req_dev_status   VARCHAR2(100);
      l_worker_conc_req_message      VARCHAR2(512);

    -- Variables holding the status information of
    -- the parent concurrent request

      l_main_conc_req_phase           VARCHAR2(100);
      l_main_conc_req_status          VARCHAR2(100);
      l_main_conc_req_dev_phase       VARCHAR2(100);
      l_main_conc_req_dev_status      VARCHAR2(100);
      l_main_conc_req_message         VARCHAR2(512);
      l_child_message                 VARCHAR2(4000);

      Cursor C_Child_Request(p_request_id    NUMBER) Is
              Select request_id From FND_CONCURRENT_REQUESTS
                                 Where parent_request_id = p_request_id;

      TYPE C_Cur_Type                IS REF CURSOR;
      C_Cur_Ref                      C_Cur_Type;
      TYPE t_tab_num                 Is Table Of NUMBER;
      TYPE t_tab_char                Is Table Of VARCHAR2(80);

      l_tab_task_id                  t_tab_num:=t_tab_num();
      l_tab_task_entity              t_tab_char:=t_tab_char();
      l_worker_conc_req_arr          t_tab_num:=t_tab_num();

      -- predefined error codes for concurrent programs
      l_cp_succ  Constant NUMBER := 0;
      l_cp_warn  Constant NUMBER := 1;
      l_cp_err   Constant NUMBER := 2;

 BEGIN

     SAVEPOINT purge_standalone_tasks;

     IF NOT fnd_api.compatible_api_call (
						    l_api_version,
						    l_api_version,
						    l_api_name,
						    g_pkg_name
	     					     )
     THEN
	  RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     fnd_msg_pub.initialize;

     -- To get concurrent request id as well as data

     l_request_id   := fnd_global.conc_request_id;
     l_request_data := fnd_conc_global.request_data;


     ----------------------------
     -- Procedure level Logging
     ----------------------------
     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
     THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'request_id = '||l_request_id);
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'request_data = '||l_request_data);
     END IF;


     IF l_request_data IS NULL
     THEN

        ----------------------------
        -- Procedure level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_creation_date_from = '||p_creation_date_from);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_creation_date_to = '||p_creation_date_to);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_last_updation_date_from = '||p_last_updation_date_from);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_last_updation_date_to = '||p_last_updation_date_to);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_planned_end_date_from = '||p_planned_end_date_from);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_planned_end_date_to = '||p_planned_end_date_to);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_scheduled_end_date_from = '||p_scheduled_end_date_from);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_scheduled_end_date_to = '||p_scheduled_end_date_to);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_actual_end_date_from = '||p_actual_end_date_from);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_actual_end_date_to = '||p_actual_end_date_to);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_task_type_id = '||p_task_type_id);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_task_status_id = '||p_task_status_id);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_delete_closed_task_only = '||p_delete_closed_task_only);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_delete_deleted_task_only = '||p_delete_deleted_task_only);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'p_no_of_worker = '||p_no_of_worker);
        END IF;


        -- Converting all dates from VARCHAR2 to DATE datatype

        l_creation_date_from          :=TO_DATE(p_creation_date_from, 'YYYY/MM/DD HH24:MI:SS');
        l_creation_date_to            :=TO_DATE(p_creation_date_to, 'YYYY/MM/DD HH24:MI:SS');
        l_last_updation_date_from     :=TO_DATE(p_last_updation_date_from, 'YYYY/MM/DD HH24:MI:SS');
        l_last_updation_date_to       :=TO_DATE(p_last_updation_date_to, 'YYYY/MM/DD HH24:MI:SS');
        l_planned_end_date_from       :=TO_DATE(p_planned_end_date_from, 'YYYY/MM/DD HH24:MI:SS');
        l_planned_end_date_to         :=TO_DATE(p_planned_end_date_to, 'YYYY/MM/DD HH24:MI:SS');
        l_scheduled_end_date_from     :=TO_DATE(p_scheduled_end_date_from , 'YYYY/MM/DD HH24:MI:SS');
        l_scheduled_end_date_to       :=TO_DATE(p_scheduled_end_date_to, 'YYYY/MM/DD HH24:MI:SS');
        l_actual_end_date_from        :=TO_DATE(p_actual_end_date_from, 'YYYY/MM/DD HH24:MI:SS');
        l_actual_end_date_to          :=TO_DATE(p_actual_end_date_to, 'YYYY/MM/DD HH24:MI:SS');

        -- Validation for TO Date.

	  IF ((l_creation_date_to is null) And (l_last_updation_date_to is null)
	    And (l_planned_end_date_to is null) And (l_scheduled_end_date_to is null)
	    And (l_actual_end_date_to is null))
        THEN
	   FND_MESSAGE.Set_Name ('JTF', 'CAC_NO_TO_DATE_PROVIDED');
	   FND_MSG_PUB.Add;
         --fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
	   RAISE fnd_api.g_exc_unexpected_error;
	  End if;


        ----------------------------
        -- Statement level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Deleting data from staging table - JTF_TASK_PURGE');
        END IF;


        -- Cleanup process: Delete all the rows in the staging table corresponding
        -- to completed concurrent programs that have been left behind by an earlier
        -- execution of this concurrent program.

        -- Added INDEX hint by SBARAT on 19/01/2006 for bug# 4888496
        -- Modified by SBARAT on 30/05/2006 for bug# 5213367

        Delete JTF_TASK_PURGE
               Where concurrent_request_id In
                     (Select /*+ INDEX(p fnd_concurrent_programs_U1) */ r.request_id
                                          From fnd_concurrent_requests r ,
                                               fnd_concurrent_programs p
                                          Where r.phase_code = 'C'
                                                And p.concurrent_program_id = r.concurrent_program_id
                                                And p.concurrent_program_name = 'CACTKPUR');

        ----------------------------
        -- Statement level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Checking whether environment is timezone enabled');
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Profile value of Enable Timezone Conversions = '||l_tz_enabled_prof);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Profile value of Server Timezone = '||l_server_tz_id);
        END IF;

        IF (NVL(l_tz_enabled_prof, 'N') = 'Y' AND l_server_tz_id IS NOT NULL)
        THEN
            l_tz_enabled := 'Y';
        END IF;

        ----------------------------
        -- Statement level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Overall timezone status = '||l_tz_enabled);
        END IF;

        ----------------------------
        -- Statement level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Constructing dynamic select statement');
        END IF;


        -- constructing the query

        l_sql_string := 'Select task_id, entity From JTF_TASKS_B Where source_object_type_code = ''TASK''';

        -- when p_creation_date_to is not null
        IF l_creation_date_to IS NOT NULL
        THEN
           l_sql_string := l_sql_string||' And creation_date <= To_Date('''||
                             To_Char(l_creation_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
        END IF;

        -- when p_creation_date_from is not null
        IF l_creation_date_from IS NOT NULL
        THEN
           l_sql_string := l_sql_string||' And creation_date >= To_Date('''||
                             To_Char(l_creation_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
        END IF;

        -- when p_last_updation_date_to is not null
        IF l_last_updation_date_to IS NOT NULL
        THEN
           l_sql_string := l_sql_string||' And last_update_date <= To_Date('''||
                             To_Char(l_last_updation_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
        END IF;

        -- when p_last_updation_date_from is not null
        IF l_last_updation_date_from IS NOT NULL
        THEN
           l_sql_string := l_sql_string||' And last_update_date >= To_Date('''||
                             To_Char(l_last_updation_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
        END IF;

        -- when p_planned_end_date_to is not null
        IF l_planned_end_date_to IS NOT NULL
        THEN
           IF (NVL(l_tz_enabled, 'N') = 'Y')
           THEN
              l_sql_string := l_sql_string||' And Decode(timezone_id, NULL, planned_end_date, '||
                                                        'NVL(HZ_TIMEZONE_PUB.CONVERT_DATETIME(timezone_id, '||
                                                                                               l_server_tz_id||', '||
                                                                                              'planned_end_date), '||
                                                            'planned_end_date'||
                                                            ')'||
                                                        ') <= To_Date('''||
                                 To_Char(l_planned_end_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           ELSE
              l_sql_string := l_sql_string||' And planned_end_date <= To_Date('''||
                                To_Char(l_planned_end_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           END IF;
        END IF;

	  -- when p_planned_end_date_from is not null
        IF l_planned_end_date_from IS NOT NULL
        THEN
           IF (NVL(l_tz_enabled, 'N') = 'Y')
           THEN
              l_sql_string := l_sql_string||' And Decode(timezone_id, NULL, planned_end_date, '||
                                                        'NVL(HZ_TIMEZONE_PUB.CONVERT_DATETIME(timezone_id, '||
                                                                                              l_server_tz_id||', '||
                                                                                             'planned_end_date), '||
                                                            'planned_end_date'||
                                                            ')'||
                                                        ') >= To_Date('''||
                                To_Char(l_planned_end_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';

           ELSE
              l_sql_string := l_sql_string||' And planned_end_date >= To_Date('''||
                                To_Char(l_planned_end_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           END IF;
        END IF;

	  -- when p_scheduled_end_date_to is not null
        IF l_scheduled_end_date_to IS NOT NULL
        THEN
           IF (NVL(l_tz_enabled, 'N') = 'Y')
           THEN
              l_sql_string := l_sql_string||' And Decode(timezone_id, NULL, scheduled_end_date, '||
                                                        'NVL(HZ_TIMEZONE_PUB.CONVERT_DATETIME(timezone_id, '||
                                                                                              l_server_tz_id||', '||
                                                                                             'scheduled_end_date), '||
                                                            'scheduled_end_date'||
                                                            ')'||
                                                        ') <= To_Date('''||
                                To_Char(l_scheduled_end_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           ELSE
              l_sql_string := l_sql_string||' And scheduled_end_date <= To_Date('''||
                                To_Char(l_scheduled_end_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           END IF;
        END IF;

	  -- when p_scheduled_end_date_from is not null
        IF l_scheduled_end_date_from IS NOT NULL
        THEN
           IF (NVL(l_tz_enabled, 'N') = 'Y')
           THEN
              l_sql_string := l_sql_string||' And Decode(timezone_id, NULL, scheduled_end_date, '||
                                                        'NVL(HZ_TIMEZONE_PUB.CONVERT_DATETIME(timezone_id, '||
                                                                                              l_server_tz_id||', '||
                                                                                             'scheduled_end_date), '||
                                                            'scheduled_end_date'||
                                                            ')'||
                                                        ') >= To_Date('''||
                                To_Char(l_scheduled_end_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           ELSE
              l_sql_string := l_sql_string||' And scheduled_end_date >= To_Date('''||
                                To_Char(l_scheduled_end_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           END IF;
        END IF;


	  -- when p_actual_end_date_to is not null
        IF l_actual_end_date_to IS NOT NULL
        THEN
           IF (NVL(l_tz_enabled, 'N') = 'Y')
           THEN
              l_sql_string := l_sql_string||' And Decode(timezone_id, NULL, actual_end_date, '||
                                                        'NVL(HZ_TIMEZONE_PUB.CONVERT_DATETIME(timezone_id, '||
                                                                                              l_server_tz_id||', '||
                                                                                             'actual_end_date), '||
                                                            'actual_end_date'||
                                                            ')'||
                                                        ') <= To_Date('''||
                                To_Char(l_actual_end_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           ELSE
              l_sql_string := l_sql_string||' And actual_end_date <= To_Date('''||
                                To_Char(l_actual_end_date_to,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           END IF;
        END IF;


	  -- when p_actual_end_date_from is not null
        IF l_actual_end_date_from IS NOT NULL
        THEN
           IF (NVL(l_tz_enabled, 'N') = 'Y')
           THEN
              l_sql_string := l_sql_string||' And Decode(timezone_id, NULL, actual_end_date, '||
                                                        'NVL(HZ_TIMEZONE_PUB.CONVERT_DATETIME(timezone_id, '||
                                                                                              l_server_tz_id||', '||
                                                                                             'actual_end_date), '||
                                                            'actual_end_date'||
                                                            ')'||
                                                        ') >= To_Date('''||
                                To_Char(l_actual_end_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           ELSE
              l_sql_string := l_sql_string||' And actual_end_date >= To_Date('''||
                                To_Char(l_actual_end_date_from,'DD-MON-YYYY HH24:MI:SS')||''''||','||'''DD-MON-YYYY HH24:MI:SS'')';
           END IF;
        END IF;


	  -- when p_task_type_id if not null
        IF p_task_type_id IS NOT NULL
        THEN
           l_sql_string := l_sql_string||' And task_type_id='||p_task_type_id;
        END IF;


	  -- when p_task_status_id if not null
        IF p_task_status_id IS NOT NULL
        THEN
           l_sql_string := l_sql_string||' And task_status_id='||p_task_status_id;
        END IF;

	  -- when p_delete_closed_task_only is not null
        IF ((p_delete_closed_task_only IS NOT NULL)
             And (p_delete_closed_task_only = 'Y'))
        THEN
           l_sql_string := l_sql_string||' And NVL(open_flag,''Y'') = ''N''';
        END IF;


	  -- when p_delete_deleted_task_only is not null
        IF ((p_delete_deleted_task_only IS NOT NULL)
             And (p_delete_deleted_task_only = 'Y'))
        THEN
           l_sql_string := l_sql_string||' And NVL(deleted_flag,''N'') = ''Y''';
        END IF;


        ----------------------------
        -- Statement level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Calling dynamic select statement = '||l_sql_string);
        END IF;


        -- Open the cursor and fetch values in variables

        Open C_Cur_Ref For l_sql_string;
        Fetch C_Cur_Ref Bulk Collect Into l_tab_task_id, l_tab_task_entity;
        Close C_Cur_Ref;

        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'No of fetched records = '||l_tab_task_id.count);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Inserting data into staging table - JTF_TASK_PURGE');
        END IF;

        -- Inserting values into JTF_TASK_PURGE

        FORALL i IN l_tab_task_id.FIRST..l_tab_task_id.LAST
            Insert Into JTF_TASK_PURGE(object_type,
                                       object_id,
                                       concurrent_request_id)
                               Values (l_tab_task_entity(i),
                                       l_tab_task_id(i),
                                       l_request_id);


        -- Initializing l_no_of_worker. If p_no_of_worker
        -- is null, then set l_no_of_worker to 4

        l_no_of_worker:=NVL(p_no_of_worker, 4);


        -- Start of main logic for invoking child concurrent-program

        IF (l_tab_task_id.COUNT > 0)
        THEN

           -- Checking whether l_no_of_worker is less than
           -- the no of tasks to be purged. If so, setting
           -- l_no-worker equal to no of tasks to be purged

           IF l_no_of_worker > l_tab_task_id.COUNT
           THEN
              l_no_of_worker := l_tab_task_id.COUNT;
           END IF;


           -- setting batch size i.e. avg. no of tasks to be purged
           -- in a single operation

           l_batch_size:=TRUNC(l_tab_task_id.COUNT/l_no_of_worker);


           -- Initializing l_start and l_end

           l_start:=l_tab_task_id.FIRST;
           l_end:=l_batch_size;


           ----------------------------
           -- Statement level Logging
           ----------------------------
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Final no of workers set = '||l_no_of_worker);
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Batch size = '||l_batch_size);
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Updating JTF_TASK_PURGE to set worker id');
           END IF;


           -- updating worker_id in JTF_TASK_PURGE table

           FOR i IN 1..l_no_of_worker LOOP
               l_set_worker:=i;
               Forall j In l_start..l_end
                      Update JTF_TASK_PURGE Set worker_id=l_set_worker
                             Where concurrent_request_id=l_request_id
                                   And object_id=l_tab_task_id(j);

               l_start:=l_start+l_batch_size;

               IF ((i+1) < l_no_of_worker)
               THEN
                  l_end:=l_end+l_batch_size;
               ELSE
                  l_end:=l_tab_task_id.LAST;
               END IF;

           END LOOP;


           ----------------------------
           -- Statement level Logging
           ----------------------------
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Invoke child concurrent request');
           END IF;


           -- Start child concurrent programs

           FOR j IN 1..l_no_of_worker LOOP
               l_worker_conc_req_arr.EXTEND;
               l_worker_conc_req_arr(j) := fnd_request.submit_request(
                                                           application     =>  'JTF' ,
                                                           program         =>  'CACTKCHPUR' ,
                                                           description     =>  TO_CHAR(j) ,           -- Displayed in the Name column of Requests Screen
                                                           start_time      =>  NULL ,
                                                           sub_request     =>  TRUE ,
                                                           argument1       =>  1 ,                    -- p_api_version_number
                                                           argument2       =>  fnd_api.g_false ,      -- p_init_msg_list
                                                           argument3       =>  fnd_api.g_false ,      -- p_commit
                                                           argument4       =>  j ,                    -- p_worker_id
                                                           argument5       =>  l_request_id           -- p_concurrent_request_id
                                                                     );

               -- If the worker request was not created successfully
               -- raise an unexpected exception and terminate the
               -- process.

               IF l_worker_conc_req_arr(j) = 0
               THEN
                   FND_MESSAGE.Set_Name('JTF', 'CAC_TASK_PURGE_SUBMIT_REQUEST');
                   FND_MSG_PUB.Add;
                   RAISE fnd_api.g_exc_unexpected_error;
               END IF;
           END LOOP;


           ----------------------------
           -- Statement level Logging
           ----------------------------
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Pausing parent concurrent request');
           END IF;


           -- Moving the parent concurrent request to Paused
           -- status in order to start the child

           fnd_conc_global.set_req_globals (
                                            conc_status  => 'PAUSED' ,
                                            request_data => '1'
                                           );

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Commiting so that child concurrent request runs');
           END IF;

           -- Committing so that the worker concurrent program that
           -- was submitted above is started by the concurrent manager.

           COMMIT WORK;

          -- At this point, execution of the parent request, invoked for the
          -- first time, gets over. Here the parent request is moved to a
          -- paused status after which the procedure execution ends.

        END IF;

    ELSE -- When l_request_data Is NOT NULL

        -- If the concurrent request is restarted from the PAUSED state,
        -- this portion of the code is executed. When all the child
        -- requests have completed their work, (their PHASE_CODE
        -- is 'COMPLETED') the concurrent manager restarts the parent. This
        -- time, the request_data returns a Non NULL value and so this
        -- portion of the code is executed.

        l_main_conc_req_dev_status := 'NORMAL';


        ----------------------------
        -- Statement level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Checking the status of child concurrent requests');
        END IF;


        -- check status of worker concurrent request
        -- to arrive at the parent request's
        -- completion status

        FOR r_child_request IN c_child_request(l_request_id) LOOP

            IF fnd_concurrent.get_request_status(
                                                 request_id => r_child_request.request_id ,
                                                 phase      => l_worker_conc_req_phase ,
                                                 status     => l_worker_conc_req_status ,
                                                 dev_phase  => l_worker_conc_req_dev_phase ,
                                                 dev_status => l_worker_conc_req_dev_status,
                                                 message    => l_worker_conc_req_message
                                                )
            THEN

                ----------------------------
                -- Statement level Logging
                ----------------------------
                IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Status of child concurrent request id = '||r_child_request.request_id);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_worker_conc_req_phase = '||l_worker_conc_req_phase);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_worker_conc_req_status = '||l_worker_conc_req_status);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_worker_conc_req_dev_phase = '||l_worker_conc_req_dev_phase);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_worker_conc_req_dev_status = '||l_worker_conc_req_dev_status);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_worker_conc_req_message = '||l_worker_conc_req_message);
                END IF;


                -- If the current worker has completed its work, based
                -- on the return status of the worker, mark the completion
                -- status of the main concurrent request.

                IF l_worker_conc_req_dev_status <> 'NORMAL'
                THEN
                    IF (l_main_conc_req_dev_status IN ('WARNING', 'NORMAL')
                        AND l_worker_conc_req_dev_status IN ('ERROR', 'DELETED', 'TERMINATED'))
                    THEN
                        l_main_conc_req_dev_status := 'ERROR';
                        l_child_message            := l_worker_conc_req_message;

                    ELSIF (l_main_conc_req_dev_status = 'NORMAL'
                           AND l_worker_conc_req_dev_status = 'WARNING')
                    THEN
                        l_main_conc_req_dev_status := 'WARNING';
                        l_child_message            := l_worker_conc_req_message;
                    END IF;

                    ----------------------------
                    -- Statement level Logging
                    ----------------------------
                    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                    THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Set l_main_conc_req_dev_status = '||l_main_conc_req_dev_status);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_child_message = '||l_child_message);
                    END IF;

                END IF;

            ELSE

                ----------------------------
                -- Statement level Logging
                ----------------------------
                IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
                THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Error in checking statuses of child requests');
                END IF;


                -- There was a failure while collecting a child request
                -- status, raising an unexpected exception

                FND_MESSAGE.Set_Name('JTF', 'CAC_TASK_NO_CP_STATUS');
                FND_MSG_PUB.Add;

                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END LOOP;

        -- Set the completion status of the main concurrent request
        -- by raising corresponding exceptions.

        IF l_main_conc_req_dev_status = 'WARNING'
        THEN
            FND_MESSAGE.Set_Name('JTF', 'CAC_TASK_WORKER_RET_STAT_WARN');
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_main_conc_req_dev_status = 'ERROR'
        THEN
            FND_MESSAGE.Set_Name('JTF', 'CAC_TASK_WORKER_RET_STAT_ERR');
            FND_MSG_PUB.Add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- In case of 'NORMAL', setting OUT variable to successful,
        -- committing the work and also truncating JTF_TASK_PURGE table

        IF l_main_conc_req_dev_status = 'NORMAL'
        THEN
           FND_MESSAGE.Set_Name('JTF', 'CAC_TASK_WORKER_RET_STAT_SUCC');
           FND_MSG_PUB.Add;

           l_msg_data:=FND_MSG_PUB.Get(
                                       p_msg_index => FND_MSG_PUB.G_LAST ,
	                                 p_encoded => 'F'
                                      );

           -- Setting the completion status of this concurrent
           -- request as COMPLETED NORMALLY

           errbuf  := l_msg_data;
           retcode := l_cp_succ;

           -- committing the work

           COMMIT WORK;

        END IF;

        ----------------------------
        -- Procedure level Logging
        ----------------------------
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'errbuf = '||errbuf);
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'retcode = '||retcode);
        END IF;

     END IF; -- End of l_request_data Is NULL

 EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	   ROLLBACK TO purge_standalone_tasks;
	   FND_MSG_PUB.Count_And_Get (
	     				    p_count => l_msg_count,
	                            p_data => l_msg_data
	                             );


         IF (l_main_conc_req_dev_status = 'ERROR')
         THEN
            errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
            retcode := l_cp_err;
         ELSIF (l_main_conc_req_dev_status = 'WARNING')
         THEN
            errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
            retcode := l_cp_warn;
         ELSE
            errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
            retcode := l_cp_err;
         END IF;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'fnd_api.g_exc_unexpected_error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_msg_count = '||l_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Error message = '||REPLACE(l_msg_data,CHR(0),' '));
        END IF;


      WHEN OTHERS
      THEN
	   ROLLBACK TO purge_standalone_tasks;
	   FND_MESSAGE.Set_Name ('JTF', 'CAC_TASK_UNKNOWN_ERROR');
	   FND_MESSAGE.Set_Token ('P_TEXT', G_PKG_NAME||'.'||l_api_name||' : '||SQLCODE||': '|| SQLERRM);
	   FND_MSG_PUB.Add;
	   FND_MSG_PUB.Count_And_Get (
	                            p_count => l_msg_count,
	                            p_data => l_msg_data
	                             );


         IF (l_main_conc_req_dev_status = 'ERROR')
         THEN
            errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
            retcode := l_cp_err;
         ELSIF (l_main_conc_req_dev_status = 'WARNING')
         THEN
            errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
            retcode := l_cp_warn;
         ELSE
            errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
            retcode := l_cp_err;
         END IF;

        ----------------------------
        -- Eeception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'OTHERS error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'l_msg_count = '||l_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_STANDALONE_TASKS', 'Error message = '||REPLACE(l_msg_data,CHR(0),' '));
        END IF;


 END PURGE_STANDALONE_TASKS;

 Procedure DELETE_TASK_ATTACHMENTS (
      p_api_version           IN           NUMBER ,
      p_init_msg_list         IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_commit                IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_processing_set_id     IN           NUMBER ,
      x_return_status         OUT  NOCOPY  VARCHAR2 ,
      x_msg_data              OUT  NOCOPY  VARCHAR2 ,
      x_msg_count             OUT  NOCOPY  NUMBER )
 IS
      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	       CONSTANT VARCHAR2(30) := 'DELETE_TASK_ATTACHMENTS';
      l_entity_name      VARCHAR2(40):='JTF_TASKS_B';

      Cursor C_Task_Id Is

      Select temp.object_id From JTF_OBJECT_PURGE_PARAM_TMP temp, fnd_attached_documents fad
                              Where temp.object_type = 'TASK'
                                    And temp.processing_set_id = p_processing_set_id
                                    And NVL(temp.purge_status,'Y') <> 'E'
                                    and fad.entity_name='JTF_TASKS_B'
                                    and fad.pk1_value=to_char(temp.object_id);

      TYPE t_tab_num      Is Table Of NUMBER;

      l_tab_task_id                  t_tab_num:=t_tab_num();

 BEGIN

      SAVEPOINT delete_task_attachments;

      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
						    l_api_version,
						    p_api_version,
						    l_api_name,
						    g_pkg_name
	     					     )
      THEN
	   RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	   fnd_msg_pub.initialize;
      END IF;


      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'p_processing_set_id = '||p_processing_set_id);
      END IF;

      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'Fetching record from JTF_OBJECT_PURGE_PARAM_TMP');
      END IF;


	Open C_Task_Id;
      Fetch C_Task_Id Bulk Collect Into l_tab_task_id;
      Close C_Task_Id;

      IF l_tab_task_id.COUNT > 0
      THEN

      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'Calling FND_ATTACHED_DOCUMENTS2_DKG.Delete_Attachments API to delete attachment');
      END IF;


      -- Deleting attachment information from Attachment table

	    FOR j IN 1..l_tab_task_id.LAST LOOP

             FND_ATTACHED_DOCUMENTS2_PKG.Delete_Attachments (
                                X_entity_name               => 'JTF_TASKS_B' ,
	                          X_pk1_value                 => to_char(l_tab_task_id(j)) ,
                                X_pk2_value                 => NULL ,
                                X_pk3_value                 => NULL ,
                                X_pk4_value                 => NULL ,
                                X_pk5_value                 => NULL ,
                                X_delete_document_flag      => 'Y' ,
                                X_automatically_added_flag  => NULL
                                                             ) ;

          END LOOP;

      END IF;

      IF fnd_api.to_boolean(p_commit)
      THEN
	   COMMIT WORK;
      END IF;

 EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	   ROLLBACK TO delete_task_attachments;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   FND_MSG_PUB.Count_And_Get (
	     				    p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );
        IF l_tab_task_id.COUNT > 0
        THEN
           FORALL j IN l_tab_task_id.FIRST..l_tab_task_id.LAST
                  Update JTF_OBJECT_PURGE_PARAM_TMP Set purge_status='E', purge_error_message=SUBSTRB(x_msg_data,1,4000)
                         Where object_type = 'TASK'
                               And processing_set_id = p_processing_set_id
                               And object_id = l_tab_task_id(j);
        END IF;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'fnd_api.g_exc_unexpected_error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'x_msg_count = '||x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'Error message = '||REPLACE(x_msg_data,CHR(0),' '));
        END IF;

      WHEN OTHERS
      THEN
	   ROLLBACK TO delete_task_attachments;
	   FND_MESSAGE.Set_Name ('JTF', 'CAC_TASK_UNKNOWN_ERROR');
	   FND_MESSAGE.Set_Token ('P_TEXT', G_PKG_NAME||'.'||l_api_name ||' : '||SQLCODE||' : '|| SQLERRM);
	   FND_MSG_PUB.Add;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   FND_MSG_PUB.Count_And_Get (
	                            p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );

        IF l_tab_task_id.COUNT > 0
        THEN
           FORALL j IN l_tab_task_id.FIRST..l_tab_task_id.LAST
                  Update JTF_OBJECT_PURGE_PARAM_TMP Set purge_status='E', purge_error_message=SUBSTRB(x_msg_data,1,4000)
                         Where object_type = 'TASK'
                               And processing_set_id = p_processing_set_id
                               And object_id = l_tab_task_id(j);
        END IF;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'OTHERS error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'x_msg_count = '||x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.DELETE_TASK_ATTACHMENTS', 'Error message = '||REPLACE(x_msg_data,CHR(0),' '));
        END IF;

 END DELETE_TASK_ATTACHMENTS;

 Procedure VALIDATE_STANDALONE_TASK(
     p_api_version                 IN          NUMBER,
     p_init_msg_list               IN          VARCHAR2 DEFAULT fnd_api.g_false,
     p_commit                      IN          VARCHAR2 DEFAULT fnd_api.g_false,
     p_processing_set_id           IN          NUMBER,
     x_return_status               OUT  NOCOPY VARCHAR2,
     x_msg_data                    OUT  NOCOPY VARCHAR2,
     x_msg_count                   OUT  NOCOPY NUMBER)
 IS
     l_api_version  CONSTANT NUMBER := 1.0;
     l_api_name	  CONSTANT VARCHAR2(30) := 'VALIDATE_STANDALONE_TASK';

 BEGIN
      SAVEPOINT validate_standalone_task;

      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
						    l_api_version,
						    p_api_version,
						    l_api_name,
						    g_pkg_name
	     					     )
      THEN
	   RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	   fnd_msg_pub.initialize;
      END IF;


      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'Start of VALIDATE_STANDALONE_TASK');
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'p_processing_set_id = '||p_processing_set_id);
      END IF;

      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'Before calling CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS');
      END IF;

      CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS(
          P_API_VERSION                => 1.0,
          P_INIT_MSG_LIST              => FND_API.G_FALSE ,
          P_COMMIT                     => FND_API.G_FALSE ,
          P_PROCESSING_SET_ID          => p_processing_set_id ,
          P_OBJECT_TYPE                => 'TASK' ,
          X_RETURN_STATUS              => x_return_status ,
          X_MSG_COUNT                  => x_msg_count ,
          X_MSG_DATA                   => x_msg_data);

      IF NOT (x_return_status = fnd_api.g_ret_sts_success)
      THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;

          IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'VALIDATE_STANDALONE_TASK', 'return status error after calling  CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;

      END IF;


      IF fnd_api.to_boolean (p_commit)
      THEN
          COMMIT WORK;
      END IF;

      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'End of VALIDATE_STANDALONE_TASK');
      END IF;

	FND_MSG_PUB.Count_And_Get (
	  		             p_count => x_msg_count,
	                         p_data  => x_msg_data
	                          );

 EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	   ROLLBACK TO validate_standalone_task;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   FND_MSG_PUB.Count_And_Get (
	     				    p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );

         Update JTF_OBJECT_PURGE_PARAM_TMP
                Set purge_status='E',
                    purge_error_message=SUBSTRB(x_msg_data,1,4000)
                Where object_type = 'TASK'
                  And processing_set_id = p_processing_set_id;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'fnd_api.g_exc_unexpected_error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'x_msg_count = '||x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'Error message = '||REPLACE(x_msg_data,CHR(0),' '));
        END IF;

      WHEN OTHERS
      THEN
	   ROLLBACK TO validate_standalone_task;
	   FND_MESSAGE.Set_Name ('JTF', 'CAC_TASK_UNKNOWN_ERROR');
	   FND_MESSAGE.Set_Token ('P_TEXT', G_PKG_NAME||'.'||l_api_name ||' : '||SQLCODE||' : '|| SQLERRM);
	   FND_MSG_PUB.Add;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   FND_MSG_PUB.Count_And_Get (
	                            p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );

         Update JTF_OBJECT_PURGE_PARAM_TMP
                Set purge_status='E',
                    purge_error_message=SUBSTRB(x_msg_data,1,4000)
                Where object_type = 'TASK'
                  And processing_set_id = p_processing_set_id;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'OTHERS error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'x_msg_count = '||x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'Error message = '||REPLACE(x_msg_data,CHR(0),' '));
        END IF;

 END VALIDATE_STANDALONE_TASK;

 Procedure POPULATE_PURGE_TMP (
      errbuf		          OUT  NOCOPY  VARCHAR2,
      retcode			    OUT  NOCOPY  VARCHAR2,
      p_api_version               IN           NUMBER ,
      p_init_msg_list             IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_commit                    IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_worker_id                 IN           NUMBER ,
      p_concurrent_request_id     IN           NUMBER)
 IS
      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	       CONSTANT VARCHAR2(30) := 'POPULATE_PURGE_TMP';

      l_processing_set_id      NUMBER;
      l_return_status          VARCHAR2(10);
      l_msg_data               VARCHAR2(4000);
      l_msg_count              NUMBER;

      Cursor C_Object_Id Is
             Select object_type, object_id
                    From JTF_TASK_PURGE
                    Where concurrent_request_id = p_concurrent_request_id
                          And worker_id = p_worker_id
                          And NVL(purge_status,'Y') <> 'E';

      Cursor C_Error_Tmp Is
             Select object_type, object_id, purge_status, purge_error_message
                              From JTF_OBJECT_PURGE_PARAM_TMP
                              Where object_type = 'TASK'
                                    And processing_set_id = l_processing_set_id
                                    And purge_status IS NOT NULL;

      TYPE t_tab_num          Is Table Of NUMBER;
      TYPE t_tab_char         Is Table Of VARCHAR2(80);
      TYPE t_tab_small_char   Is Table Of VARCHAR2(1);
      TYPE t_tab_long_char    Is Table Of VARCHAR2(4000);

      l_tab_task_id           t_tab_num  := t_tab_num();
      l_task_source_tab       t_tab_char := t_tab_char();
      l_tmp_object_type       t_tab_char := t_tab_char();
      l_tmp_object_id         t_tab_num  := t_tab_num();
      l_tmp_purge_status      t_tab_small_char:=t_tab_small_char();
      l_tmp_purge_error_msg   t_tab_long_char:=t_tab_long_char();

      -- predefined error codes for concurrent programs
      l_cp_succ  Constant NUMBER := 0;
      l_cp_warn  Constant NUMBER := 1;
      l_cp_err   Constant NUMBER := 2;

 BEGIN

      SAVEPOINT populate_purge_tmp;

      IF NOT fnd_api.compatible_api_call (
						    l_api_version,
						    p_api_version,
						    l_api_name,
						    g_pkg_name
	     					     )
      THEN
	   RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	   fnd_msg_pub.initialize;
      END IF;


      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'p_worker_id = '||p_worker_id);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'p_concurrent_request_id = '||p_concurrent_request_id);
      END IF;

      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Fetching data from JTF_TASK_PURGE');
      END IF;


      Open C_Object_Id;
      Fetch C_Object_Id BULK COLLECT INTO l_task_source_tab, l_tab_task_id;
      Close C_Object_Id;


      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'No of records fetched from JTF_TASK_PURGE');
      END IF;


      IF l_tab_task_id.COUNT > 0
      THEN

         Select JTF_OBJECT_PURGE_PROC_SET_S.NEXTVAL
                Into l_processing_set_id
                From DUAL;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Inserting data into temp table - JTF_OBJECT_PURGE_PARAM_TMP');
         END IF;


         Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Insert Into JTF_OBJECT_PURGE_PARAM_TMP (object_type,
                                                        object_id,
                                                        processing_set_id,
                                                        purge_status,
                                                        purge_error_message)
                                                Values (l_task_source_tab(j),
                                                        l_tab_task_id(j),
                                                        l_processing_set_id,
                                                        NULL,
                                                        NULL);

         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.VALIDATE_STANDALONE_TASK', 'Calling wrapper API - VALIDATE_STANDALONE_TASK');
         END IF;

         -- Calling VALIDATE_STANDALONE_TASK to validate standalone tasks

         VALIDATE_STANDALONE_TASK (
                                   p_api_version        => 1.0 ,
                                   p_init_msg_list      => fnd_api.g_false ,
                                   p_commit             => fnd_api.g_false ,
                                   p_processing_set_id  => l_processing_set_id ,
                                   x_return_status      => l_return_status ,
                                   x_msg_count          => l_msg_count ,
                                   x_msg_data           => l_msg_data
                                  );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Calling wrapper API - DELETE_TASK_ATTACHMENTS');
         END IF;


         -- Calling DELETE_TASK_ATTACHMENTS to delete attachments

         DELETE_TASK_ATTACHMENTS (
                                   p_api_version        => 1.0 ,
                                   p_init_msg_list      => fnd_api.g_false ,
                                   p_commit             => fnd_api.g_false ,
                                   p_processing_set_id  => l_processing_set_id ,
                                   x_return_status      => l_return_status ,
                                   x_msg_data           => l_msg_data ,
                                   x_msg_count          => l_msg_count
                                  );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Calling note API - CAC_NOTE_PURGE_PUB.PURGE_NOTES');
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Passing l_processing_set_id = '||l_processing_set_id);
         END IF;


         -- Calling CAC_NOTE_PURGE_PUB.PURGE_NOTES to delete notes

         CAC_NOTE_PURGE_PUB.PURGE_NOTES (
                                         p_api_version           => 1.0 ,
                                         p_init_msg_list         => fnd_api.g_false,
                                         p_commit                => fnd_api.g_false,
                                         x_return_status         => l_return_status ,
                                         x_msg_data              => l_msg_data ,
                                         x_msg_count             => l_msg_count ,
                                         p_processing_set_id     => l_processing_set_id ,
                                         p_object_type           => 'TASK'
                                        ) ;

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Before calling CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS');
         END IF;

         -- Calling CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS to delete data from Field Service

         CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS(
                                          p_api_version             => 1.0,
                                          p_init_msg_list           => fnd_api.g_false,
                                          p_commit                  => fnd_api.g_false,
                                          p_processing_set_id       => l_processing_set_id ,
                                          p_object_type             => 'TASK' ,
                                          x_return_status           => l_return_status,
                                          x_msg_count               => l_msg_count,
                                          x_msg_data                => l_msg_data
                                         );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Before calling IEU_WR_PUB.Purge_Wr_Item');
         END IF;


         -- Calling IEU_WR_PUB.Purge_Wr_Item to delete data from UWQ

         IEU_WR_PUB.Purge_Wr_Item(
                                  p_api_version_number      => 1.0,
                                  p_init_msg_list           => fnd_api.g_false,
                                  p_commit                  => fnd_api.g_false,
                                  p_processing_set_id       => l_processing_set_id ,
                                  p_object_type             => 'TASK' ,
                                  x_return_status           => l_return_status,
                                  x_msg_count               => l_msg_count,
                                  x_msg_data                => l_msg_data
                                 );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Before calling JTF_IH_PURGE.P_Delete_Interactions');
         END IF;


         -- Calling JTF_IH_PURGE.P_Delete_Interactions to delete data from Interaction History

         JTF_IH_PURGE.P_Delete_Interactions(
                                            p_api_version             => 1.0,
                                            p_init_msg_list           => fnd_api.g_false,
                                            p_commit                  => fnd_api.g_false,
                                            p_processing_set_id       => l_processing_set_id ,
                                            p_object_type             => 'TASK' ,
                                            x_return_status           => l_return_status,
                                            x_msg_count               => l_msg_count,
                                            x_msg_data                => l_msg_data
                                           );


         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Calling CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES');
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Passing l_processing_set_id = '||l_processing_set_id);
         END IF;


         --  Calling CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES to delte task entities

         CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES(
                                                p_api_version        => 1.0 ,
                                                p_init_msg_list      => fnd_api.g_false ,
                                                p_commit             => fnd_api.g_false ,
                                                p_processing_set_id  => l_processing_set_id ,
                                                x_return_status      => l_return_status ,
                                                x_msg_data           => l_msg_data ,
                                                x_msg_count          => l_msg_count ,
                                                p_object_type        => 'TASK'
                                               );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success)
         THEN
	      l_return_status := fnd_api.g_ret_sts_unexp_error;
	      RAISE fnd_api.g_exc_unexpected_error;
         END IF;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Updating process_flag of JTF_TASK_PURGE');
         END IF;


         Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Update JTF_TASK_PURGE Set process_flag = 'Y'
                       Where concurrent_request_id = p_concurrent_request_id
                             And worker_id = p_worker_id
                             And object_type = l_task_source_tab(j)
                             And object_id = l_tab_task_id(j);

      END IF;

      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Updating purge_status of JTF_TASK_PURGE');
      END IF;


      Open C_Error_Tmp;
      Fetch C_Error_Tmp BULK COLLECT INTO l_tmp_object_type, l_tmp_object_id, l_tmp_purge_status, l_tmp_purge_error_msg;
      Close C_Error_Tmp;

      IF l_tmp_object_id.COUNT > 0
      THEN
         Forall j In l_tmp_object_id.FIRST..l_tmp_object_id.LAST
                Update JTF_TASK_PURGE Set purge_status = l_tmp_purge_status(j),
                                          purge_error_message = l_tmp_purge_error_msg(j)
                                      Where object_id = l_tmp_object_id(j)
                                            And object_type = l_tmp_object_type(j)
                                            And concurrent_request_id = p_concurrent_request_id
                                            And worker_id = p_worker_id;
      END IF;

     -- setting the message to success

     FND_MESSAGE.Set_Name('JTF', 'CAC_TASK_WORKER_RET_STAT_SUCC');
     FND_MSG_PUB.Add;

     l_msg_data:=FND_MSG_PUB.Get(
                                 p_msg_index => FND_MSG_PUB.G_LAST ,
	                           p_encoded => 'F'
                                );

     -- Setting the completion status of this child concurrent
     -- request as COMPLETED NORMALLY

      errbuf  := l_msg_data;
      retcode := l_cp_succ;

      IF fnd_api.to_boolean(p_commit)
      THEN
	   COMMIT WORK;
      END IF;

      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'errbuf = '||errbuf);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'retcode = '||retcode);
      END IF;

 EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	   ROLLBACK TO populate_purge_tmp;
	   FND_MSG_PUB.Count_And_Get (
	     				    p_count => l_msg_count,
	                            p_data => l_msg_data
	                             );

         IF l_tab_task_id.COUNT > 0
         THEN
            Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                   Update JTF_TASK_PURGE Set process_flag = 'Y' ,
                                             purge_status = 'E' ,
                                             purge_error_message = SUBSTRB(l_msg_data,1,4000)
                          Where concurrent_request_id = p_concurrent_request_id
                                And worker_id = p_worker_id
                                And object_type = l_task_source_tab(j)
                                And object_id = l_tab_task_id(j);
         END IF;

         errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
         retcode := l_cp_err;

        ----------------------------
        -- Exception level Logging
        ----------------------------
         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'fnd_api.g_exc_unexpected_error');
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'l_msg_count = '||l_msg_count);
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Error message = '||REPLACE(l_msg_data,CHR(0),' '));
         END IF;

      WHEN OTHERS
      THEN
	   ROLLBACK TO populate_purge_tmp;
	   FND_MESSAGE.Set_Name ('JTF', 'CAC_TASK_UNKNOWN_ERROR');
	   FND_MESSAGE.Set_Token ('P_TEXT', G_PKG_NAME||'.'||l_api_name ||' : '||SQLCODE||' : '|| SQLERRM);
	   FND_MSG_PUB.Add;
	   FND_MSG_PUB.Count_And_Get (
	                            p_count => l_msg_count,
	                            p_data => l_msg_data
	                             );

         IF l_tab_task_id.COUNT > 0
         THEN
            Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                   Update JTF_TASK_PURGE Set process_flag = 'Y' ,
                                             purge_status = 'E' ,
                                             purge_error_message = SUBSTRB(l_msg_data,1,4000)
                          Where concurrent_request_id = p_concurrent_request_id
                                And worker_id = p_worker_id
                                And object_type = l_task_source_tab(j)
                                And object_id = l_tab_task_id(j);
         END IF;

         errbuf  := SUBSTRB(REPLACE(l_msg_data,CHR(0),' '), 1, 240);
         retcode := l_cp_err;

        ----------------------------
        -- Exception level Logging
        ----------------------------
         IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'OTHERS error');
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'l_msg_count = '||l_msg_count);
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.POPULATE_PURGE_TMP', 'Error message = '||REPLACE(l_msg_data,CHR(0),' '));
         END IF;

 END POPULATE_PURGE_TMP;

 Procedure PURGE_TASK_ENTITIES (
      p_api_version           IN           NUMBER ,
      p_init_msg_list         IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_commit                IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_processing_set_id     IN           NUMBER ,
      x_return_status         OUT  NOCOPY  VARCHAR2 ,
      x_msg_data              OUT  NOCOPY  VARCHAR2 ,
      x_msg_count             OUT  NOCOPY  NUMBER ,
      p_object_type           IN           VARCHAR2 )
 IS
      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	       CONSTANT VARCHAR2(30) := 'PURGE_TASK_ENTITIES';

      Cursor C_Task_Id Is
             Select object_id From JTF_OBJECT_PURGE_PARAM_TMP
                              Where object_type = p_object_type
                                    And processing_set_id = p_processing_set_id
                                    And NVL(purge_status,'Y') <> 'E';

      TYPE t_tab_num      Is Table Of NUMBER;

      l_tab_task_id                  t_tab_num:=t_tab_num();
      l_tab_task_ref_id              t_tab_num:=t_tab_num();
      l_tab_task_audits_id           t_tab_num:=t_tab_num();
      l_tab_rec_rule_id              t_tab_num:=t_tab_num();
      --Added by MPADHIAR for Bug # 5216358
      l_tab_task_contact_id          t_tab_num:=t_tab_num();

 BEGIN

      SAVEPOINT purge_task_entities;

      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
						    l_api_version,
						    p_api_version,
						    l_api_name,
						    g_pkg_name
	     					     )
      THEN
	   RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	   fnd_msg_pub.initialize;
      END IF;


      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'p_processing_set_id = '||p_processing_set_id);
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'p_object_type = '||p_object_type);
      END IF;

      ----------------------------
      -- Statement level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Fetching record from JTF_OBJECT_PURGE_PARAM_TMP');
      END IF;


	Open C_Task_Id;
      Fetch C_Task_Id Bulk Collect Into l_tab_task_id;
      Close C_Task_Id;

      IF l_tab_task_id.COUNT > 0
      THEN

          ----------------------------
          -- Statement level Logging
          ----------------------------
          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_DATES');
          END IF;


          --Delete data from JTF_TASK_DATES table
          Forall j In l_tab_task_id.FIRST.. l_tab_task_id.LAST
                 Delete JTF_TASK_DATES
	                  Where task_id= l_tab_task_id(j);


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_DEPENDS');
         END IF;


         --Delete data from  JTF_TASK_DEPENDS table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Delete JTF_TASK_DEPENDS
	                 Where NVL(template_flag, 'N') <> 'Y'         -- Added for bug# 5388975
                             AND (task_id = l_tab_task_id(j)
	                            or dependent_on_task_id = l_tab_task_id(j));


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_CONTACTS');
         END IF;


         --Delete data from JTF_TASK_CONTACTS table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
	          Delete JTF_TASK_CONTACTS
	                 Where task_id = l_tab_task_id(j)
			 --Added By MPADHIAR for Bug#5216358
			 Returning task_contact_id Bulk Collect Into l_tab_task_contact_id;

         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_PHONES');
         END IF;


        --Delete data from JTF_TASK_PHONES table
	  Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
			Delete  JTF_TASK_PHONES
				WHERE  owner_table_name = 'JTF_TASKS_B'
					AND task_contact_id = l_tab_task_id(j);

	--Added By MPADHIAR for Bug#5216358
	IF l_tab_task_contact_id.COUNT > 0 THEN
		--Delete data from JTF_TASK_PHONES table for phone created for Task Contact
		Forall j In l_tab_task_contact_id.FIRST..l_tab_task_contact_id.LAST
	          Delete  JTF_TASK_PHONES
	                  WHERE  owner_table_name = 'JTF_TASK_CONTACTS'
	                         AND task_contact_id = l_tab_task_contact_id(j);
	END IF;
	--Added By MPADHIAR for Bug#5216358 Ends here

         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_RSC_REQS');
         END IF;


         --Delete data from JTF_TASK_RSC_REQS
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
	          Delete JTF_TASK_RSC_REQS
	                 where task_id = l_tab_task_id(j);


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_REFERENCES_B');
         END IF;


         --Delete data from JTF_TASK_REFERENCES_B table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
	          Delete JTF_TASK_REFERENCES_B
	                 Where task_id = l_tab_task_id(j)
	                 Returning task_reference_id Bulk Collect Into l_tab_task_ref_id;


	   --Delete data from JTF_TASK_REFERENCES_TL table
         IF l_tab_task_ref_id.COUNT > 0
         THEN

            ----------------------------
            -- Statement level Logging
            ----------------------------
            IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_REFERENCES_TL');
            END IF;


	      Forall i In l_tab_task_ref_id.FIRST..l_tab_task_ref_id.LAST
                   Delete JTF_TASK_REFERENCES_TL
                          Where task_reference_id = l_tab_task_ref_id(i);

         END IF;

         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_AUDITS_B');
         END IF;


         --Delete data from JTF_TASK_AUDITS_B table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Delete JTF_TASK_AUDITS_B
                       Where task_id = l_tab_task_id(j)
	                 Returning task_audit_id Bulk Collect Into l_tab_task_audits_id;

	   --Delete data from JTF_TASK_AUDITS_TL table
         IF l_tab_task_audits_id.COUNT > 0
         THEN

            ----------------------------
            -- Statement level Logging
            ----------------------------
            IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_AUDITS_TL');
            END IF;


	      Forall i In l_tab_task_audits_id.FIRST..l_tab_task_audits_id.LAST
	             Delete JTF_TASK_AUDITS_TL
                          Where task_audit_id = l_tab_task_audits_id(i);

         END IF;


         --Modified By MPADHIAR for Bug#5216358
         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_ALL_ASSIGNMENTS');
         END IF;

           --Delete data from JTF_TASK_ALL_ASSIGNMENTS table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
	          Delete JTF_TASK_ALL_ASSIGNMENTS
	                 Where task_id = l_tab_task_id(j);

         --Modified By MPADHIAR for Bug#5216358 Ends here

         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Breaking parent-child relationship for the tasks to be purged in JTF_TASKS_B');
         END IF;


         --Break parent-child relationship for the tasks to be purged
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Update JTF_TASKS_B
	                 Set parent_task_id = NULL
	                 Where parent_task_id = l_tab_task_id(j);


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASKS_B');
         END IF;


         --Delete data from JTF_TASKS_B table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Delete JTF_TASKS_B
	                 Where task_id = l_tab_task_id(j)
                       Returning recurrence_rule_id Bulk Collect Into l_tab_rec_rule_id;


         ----------------------------
         -- Statement level Logging
         ----------------------------
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
         THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASKS_TL');
         END IF;


         --Delete data from JTF_TASKS_TL table
	   Forall j In l_tab_task_id.FIRST..l_tab_task_id.LAST
                Delete JTF_TASKS_TL
	                 Where task_id = l_tab_task_id(j);


         --Delete data from JTF_TASK_RECUR_RULES table
         IF l_tab_rec_rule_id.COUNT > 0
         THEN

            ----------------------------
            -- Statement level Logging
            ----------------------------
            IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
            THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Deleting from table - JTF_TASK_RECUR_RULES');
            END IF;


            Forall j In l_tab_rec_rule_id.FIRST..l_tab_rec_rule_id.LAST
                   Delete JTF_TASK_RECUR_RULES
                          Where recurrence_rule_id = l_tab_rec_rule_id(j)
                                And l_tab_rec_rule_id(j) IS NOT NULL
                                And NOT EXISTS (Select task_id From JTF_TASKS_B
                                                                Where recurrence_rule_id = l_tab_rec_rule_id(j));

         END IF;

      END IF;

      IF fnd_api.to_boolean(p_commit)
      THEN
	   COMMIT WORK;
      END IF;

      ----------------------------
      -- Procedure level Logging
      ----------------------------
      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'End of PURGE_TASK_ENTITIES');
      END IF;

 EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
	   ROLLBACK TO purge_task_entities;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   FND_MSG_PUB.Count_And_Get (
	     				    p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );
        IF l_tab_task_id.COUNT > 0
        THEN
           FORALL j IN l_tab_task_id.FIRST..l_tab_task_id.LAST
                  Update JTF_OBJECT_PURGE_PARAM_TMP Set purge_status='E', purge_error_message=SUBSTRB(x_msg_data,1,4000)
                         Where object_type = p_object_type
                               And processing_set_id = p_processing_set_id
                               And object_id = l_tab_task_id(j);
        END IF;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'fnd_api.g_exc_unexpected_error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'x_msg_count = '||x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Error message = '||REPLACE(x_msg_data,CHR(0),' '));
        END IF;

      WHEN OTHERS
      THEN
	   ROLLBACK TO purge_task_entities;
	   FND_MESSAGE.Set_Name ('JTF', 'CAC_TASK_UNKNOWN_ERROR');
	   FND_MESSAGE.Set_Token ('P_TEXT', G_PKG_NAME||'.'||l_api_name ||' : '||SQLCODE||' : '|| SQLERRM);
	   FND_MSG_PUB.Add;
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
	   FND_MSG_PUB.Count_And_Get (
	                            p_count => x_msg_count,
	                            p_data => x_msg_data
	                             );

        IF l_tab_task_id.COUNT > 0
        THEN
           FORALL j IN l_tab_task_id.FIRST..l_tab_task_id.LAST
                  Update JTF_OBJECT_PURGE_PARAM_TMP Set purge_status='E', purge_error_message=SUBSTRB(x_msg_data,1,4000)
                         Where object_type = p_object_type
                               And processing_set_id = p_processing_set_id
                               And object_id = l_tab_task_id(j);
        END IF;

        ----------------------------
        -- Exception level Logging
        ----------------------------
        IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'OTHERS error');
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'x_msg_count = '||x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'CAC_TASK_PURGE_PVT.PURGE_TASK_ENTITIES', 'Error message = '||REPLACE(x_msg_data,CHR(0),' '));
        END IF;

 END PURGE_TASK_ENTITIES;

END CAC_TASK_PURGE_PVT;

/
