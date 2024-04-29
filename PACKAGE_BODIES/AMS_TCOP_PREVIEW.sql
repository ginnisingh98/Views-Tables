--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_PREVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_PREVIEW" AS
/* $Header: amsvtcpb.pls 120.14 2006/05/24 00:18:32 batoleti ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_PREVIEW
-- Purpose
--
-- This package contains all the program units for traffic cop preview
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Declare some of the Types
TYPE  DATE_TABLE  IS TABLE of DATE INDEX BY BINARY_INTEGER;
TYPE  NUMBER_TABLE  IS TABLE of NUMBER INDEX BY BINARY_INTEGER;

-- Declare some of the Global Variables

-- Nested Tables
G_PARTY_TGROUP_LIST  JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
G_PARTY_LIST         JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
G_FATIGUE_PARTY_LIST JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
G_FATIGUE_BY_PARTY_LIST JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
G_FATIGUE_BY_SCHEDULE_LIST JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();

-- Index By Tables
G_PRVW_DATE_LIST     DATE_TABLE;

-- Scalar variables
G_PRVW_REQUEST_ID    NUMBER;
G_ACTIVITY_ID        NUMBER;
G_SCHEDULE_ID        NUMBER;
G_GLOBAL_MAX_CONTACT    NUMBER :=0;
G_GLOBAL_NO_OF_DAYS  NUMBER:=0;
G_CHANNEL_MAX_CONTACT    NUMBER:=0;
G_CHANNEL_NO_OF_DAYS  NUMBER:=0;
G_NO_SCHEDULE_PIPELINE BOOLEAN := FALSE;
G_PREVIEW_START_DATE DATE;
G_PREVIEW_END_DATE DATE;

--Global Variable for the Period
G_GLOBAL_NO_OF_PERIOD  NUMBER;


-- Global Constants
LOG_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
-- Private procedure to write debug message to FND_LOG table
PROCEDURE write_debug_message(p_log_level       NUMBER,
                              p_procedure_name  VARCHAR2,
                              p_label           VARCHAR2,
                              p_text            VARCHAR2
                              )
IS
   l_module_name  VARCHAR2(400);
   DELIMETER    CONSTANT   VARCHAR2(1) := '.';
   LABEL_PREFIX CONSTANT   VARCHAR2(15) := 'WFScheduleExec';

BEGIN
   IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      -- Set the Module Name
      l_module_name := 'ams'||DELIMETER||'plsql'||DELIMETER||G_PACKAGE_NAME||DELIMETER||p_procedure_name||DELIMETER||LABEL_PREFIX||'-'||p_label;


      -- Log the Message
      AMS_UTILITY_PVT.debug_message(p_log_level,
                                    l_module_name,
                                    p_text
                                    );
   END IF;



      --dbms_output.put_line(l_module_name||': '||p_text);

END write_debug_message;
-- ===============================================================
-- Start of Comments
-- Name
-- CREATE_PREVIEW_REQUEST
--
-- Purpose
-- This procedure creates a preview request
--

PROCEDURE   CREATE_PREVIEW_REQUEST( p_list_header_id   IN    NUMBER
                                   ,p_total_preview_size IN  NUMBER
                                  )
IS
   -- Cursor to get the next sequence number
   CURSOR C_GET_PRVW_RQST_ID
   IS
   SELECT ams_tcop_prvw_requests_s.nextval
   FROM DUAL;


   -- Use Autonomous Transaction to commit the data
   PRAGMA   AUTONOMOUS_TRANSACTION;
BEGIN

   -- Get the next sequence number
   OPEN C_GET_PRVW_RQST_ID;
   FETCH C_GET_PRVW_RQST_ID
   INTO G_PRVW_REQUEST_ID;
   CLOSE C_GET_PRVW_RQST_ID;

   IF (G_GLOBAL_NO_OF_PERIOD IS NULL ) THEN
		G_GLOBAL_NO_OF_PERIOD := 7;
   END IF;

   -- Create a row in AMS_TCOP_PRVW_REQUESTS



   INSERT INTO
   AMS_TCOP_PRVW_REQUESTS
   (
   REQUEST_ID,
   GENERATION_DATE,
   STATUS,
   LIST_HEADER_ID,
   TOTAL_PREVIEW_SIZE,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   OBJECT_VERSION_NUMBER,
   PROJECTED_FATIGUE_PERIOD
   )
   VALUES
   (
   G_PRVW_REQUEST_ID,
   sysdate,
   'NEW',
   p_list_header_id,
   p_total_preview_size,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.USER_ID,
   FND_GLOBAL.USER_ID,
   1,
   G_GLOBAL_NO_OF_PERIOD
   );
   commit;
END CREATE_PREVIEW_REQUEST;
-- ===============================================================
-- Start of Comments
-- Name
-- PREVIEW_FATIGUE
--
-- Purpose
-- This procedure does preview projection for the target group
-- specified by the list_header_id
--
PROCEDURE   CALCULATE_PREVIEW_DATE_RANGE(p_start_date  IN  Date,p_camp_end_date  IN  Date)
IS
   l_prvw_start_date			date;
   l_num_days_between			NUMBER;
   l_prvw_days				NUMBER;
   l_fatigue_start_date			DATE;
   l_fatigue_end_date			DATE;
   l_temp_fatigue_start_date	DATE;
   PROCEDURE_NAME CONSTANT    VARCHAR2(30) := 'CALCULATE_PREVIEW_DATE_RANGE';
BEGIN

   IF (G_GLOBAL_NO_OF_PERIOD IS NULL) THEN
	G_GLOBAL_NO_OF_PERIOD := 7;
  END IF;
 G_PRVW_DATE_LIST.DELETE;
  IF (trunc(p_start_date) <= trunc(sysdate)) THEN
      l_fatigue_start_date := trunc(sysdate);
   ELSIF (trunc(p_start_date) > trunc(sysdate)) THEN
		l_temp_fatigue_start_date := trunc(p_start_date - G_GLOBAL_NO_OF_PERIOD);

			IF (trunc(l_temp_fatigue_start_date) <= trunc(sysdate)) THEN
				l_fatigue_start_date := trunc(sysdate);
			ELSE
				l_fatigue_start_date := l_temp_fatigue_start_date;
	END IF;
   END IF;


   l_fatigue_end_date := trunc(p_start_date + G_GLOBAL_NO_OF_PERIOD);
   IF (trunc(l_fatigue_end_date) >= trunc(p_camp_end_date)) THEN
			l_fatigue_end_date :=	trunc(p_camp_end_date);
   END IF;

  IF (trunc(l_fatigue_end_date) >= trunc(sysdate) OR trunc(p_camp_end_date) >= trunc(sysdate)) THEN
       l_num_days_between := trunc(l_fatigue_end_date - l_fatigue_start_date);
		FOR i in 1 .. l_num_days_between+1
      LOOP
         G_PRVW_DATE_LIST(i) := l_fatigue_start_date + (i -1);
      END LOOP;
END IF;


     -- Print the Date Range
   For i in G_PRVW_DATE_LIST.FIRST .. G_PRVW_DATE_LIST.LAST
   LOOP

   write_debug_message(LOG_LEVEL_EVENT,
                    PROCEDURE_NAME,
                    'PRINT_DATE_RANGE',
                    'Date '||to_char(i)||' ='||to_char(G_PRVW_DATE_LIST(i))
                    );

   END LOOP;

END CALCULATE_PREVIEW_DATE_RANGE;
-- ===============================================================
-- Start of Comments
-- Name
-- APPEND_GLOBAL_FATIGUE_LIST
--
-- Purpose
-- Append the given list to the global list
--
PROCEDURE APPEND_GLOBAL_FATIGUE_LIST(p_fatigue_party_list 	JTF_NUMBER_TABLE,
												 p_fatigue_by_party_list JTF_NUMBER_TABLE,
												 p_fatigue_by_schedule_list JTF_NUMBER_TABLE
												 )
IS

l_global_count		NUMBER;
l_input_count		NUMBER;
PROCEDURE_NAME CONSTANT    VARCHAR2(30) := 'APPEND_GLOBAL_FATIGUE_LIST';
BEGIN
   write_debug_message(LOG_LEVEL_EVENT,
                    PROCEDURE_NAME,
                    'INPUT_PARTY_LIST_NEEDS_TO_BE_COPIED',
                    'Total number of entries in the input fatigue party list = '||to_char(p_fatigue_party_list.count)
                   );


   write_debug_message(LOG_LEVEL_EVENT,
                    PROCEDURE_NAME,
                    'INPUT_ENTRY_LIST_NEEDS_TO_BE_COPIED',
                    'Total number of ids in the input fatigue entry list = '||to_char(p_fatigue_by_party_list.count)
                   );


   write_debug_message(LOG_LEVEL_EVENT,
                    PROCEDURE_NAME,
                    'INPUT_FATIGUE_BY_SCHEDULE_LIST_NEEDS_TO_BE_COPIED',
                    'Total number of fatigue by schedules in the input list = '||to_char(p_fatigue_by_schedule_list.count)
                   );



	-- Append the G_FATIGUE_PARTY_LIST
	l_input_count := p_FATIGUE_PARTY_LIST.COUNT;
	IF (l_input_count > 0) THEN
      l_global_count := G_FATIGUE_PARTY_LIST.COUNT;
      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_ENTRY_LIST_BEFORE_COPY',
                       'Total number of entries in the global fatigue party list = '||to_char(l_global_count)
                      );

		FOR i in p_fatigue_party_list.FIRST .. p_fatigue_party_list.LAST
		LOOP
			G_FATIGUE_PARTY_LIST.EXTEND;
			G_FATIGUE_PARTY_LIST(l_global_count + 1) := p_fatigue_party_list(i);
         l_global_count := l_global_count + 1;
		END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_PARTY_ENTRY_LIST_AFTER_COPY',
                       'After copying Total number of entries in the global fatigue party list = '||to_char(G_FATIGUE_PARTY_LIST.COUNT)
                      );
	END IF;

	-- Append the G_FATIGUE_BY_PARTY_LIST
	l_input_count := p_FATIGUE_BY_PARTY_LIST.COUNT;
	IF (l_input_count > 0) THEN
      l_global_count := G_FATIGUE_BY_PARTY_LIST.COUNT;
      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_BY_ENTRY_LIST_BEFORE_COPY',
                       'Before copying Total number of entries in the global fatigue by list = '||to_char(l_global_count)
                      );


		FOR i in p_fatigue_by_party_list.FIRST .. p_fatigue_by_party_list.LAST
		LOOP
			G_FATIGUE_BY_PARTY_LIST.EXTEND;
			G_FATIGUE_BY_PARTY_LIST(l_global_count + 1) := p_fatigue_by_party_list(i);
         l_global_count := l_global_count + 1;
		END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_BY_ENTRY_LIST_AFTER_COPY',
                       'After copying Total number of entries in the global fatigue by list = '||to_char(G_FATIGUE_BY_PARTY_LIST.count)
                      );
	END IF;

	-- Append the G_FATIGUE_BY_SCHEDULE_LIST
	l_input_count := p_FATIGUE_BY_SCHEDULE_LIST.COUNT;
	IF (l_input_count > 0) THEN
      l_global_count := G_FATIGUE_BY_SCHEDULE_LIST.COUNT;
      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_BY_SCHEDULE_LIST_BEFORE_COPY',
                       'Before copying Total number of entries in the global fatigue by schedule list = '||to_char(l_global_count)
                      );

		FOR i in p_fatigue_by_schedule_list.FIRST .. p_fatigue_by_schedule_list.LAST
		LOOP
			G_FATIGUE_BY_SCHEDULE_LIST.EXTEND;
			G_FATIGUE_BY_SCHEDULE_LIST(l_global_count + 1) := p_fatigue_by_schedule_list(i);
         l_global_count := l_global_count + 1;
		END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_BY_SCHEDULE_LIST_AFTER_COPY',
                       'After copying Total number of entries in the global fatigue by schedule list = '||to_char(l_global_count)
                      );
	END IF;

END APPEND_GLOBAL_FATIGUE_LIST;
-- ===============================================================
-- Start of Comments
-- Name
-- DELETE_FROM_LIST
--
-- Purpose
-- Now, simulate future contact. Basically as if the overlapping
PROCEDURE DELETE_FROM_LIST(p_delete_from_list IN OUT NOCOPY jtf_number_table,
                           p_delete_list      IN  jtf_number_table
                           )
IS

l_temp_list jtf_number_table := jtf_number_table();
l_temp_idx NUMBER;
l_temp_num NUMBER;

BEGIN
   IF (p_delete_from_list.count > 0 and p_delete_list.count > 0) THEN
      FOR i in p_delete_list.first .. p_delete_list.last
      LOOP
         IF (p_delete_from_list.count > 0 ) THEN
         FOR j in p_delete_from_list.first .. p_delete_from_list.last
         LOOP
            IF (p_delete_from_list.exists(j)) THEN
               IF ((p_delete_list(i) = p_delete_from_list(j))
                 ) THEN
                  p_delete_from_list.delete(j);
               END IF;
            END IF;
         END LOOP;
         END IF;
      END LOOP;
   END IF;

   l_temp_idx := 0;
   IF (p_delete_from_list.count > 0)
   THEN
	FOR j in p_delete_from_list.first .. p_delete_from_list.last
	LOOP
	    BEGIN
		l_temp_num := p_delete_from_list(j);
		l_temp_idx := l_temp_idx + 1;
		l_temp_list.extend;
		l_temp_list(l_temp_idx) := l_temp_num;

	    EXCEPTION
		WHEN NO_DATA_FOUND THEN null;
	    END;
	END LOOP;
   END IF;

   p_delete_from_list := l_temp_list;

END DELETE_FROM_LIST;
-- ===============================================================
-- Start of Comments
-- Name
-- SIMULATE_FUTURE_CONTACT
--
-- Purpose
-- Now, simulate future contact. Basically as if the overlapping
-- target group members are being contacted by the schedules in the pipeline
--
PROCEDURE   SIMULATE_FUTURE_CONTACTS(p_preview_start_date IN    DATE
                                    ,p_preview_end_date   IN    DATE
                                   ,p_list_header_id     IN    NUMBER
)
IS
   -- Cursor to get schedules in pipeline
   /* Reverted changes for Bugfix: 4261272. Fix for SQL repository issue: 11756057 */
   /* Bug Fix 4990567: SQL ID 14423512. A new index AMS_CAMPAIGN_SCHEDULES_B_N13 was created */
   /* -- batoleti commented this cursor.
   CURSOR C_GET_SCHEDULE_IN_PIPELINE
   IS
   SELECT CSCH.SCHEDULE_ID,CSCH.ACTIVITY_ID,CSCH.START_DATE_TIME
   FROM   AMS_CAMPAIGN_SCHEDULES_B CSCH,
          AMS_ACT_LISTS ACT_LIST,
          AMS_LIST_HEADERS_ALL LIST_HEADER
   WHERE  CSCH.START_DATE_TIME BETWEEN
                                  p_preview_start_date AND p_preview_end_date
   AND    CSCH.STATUS_CODE in ('AVAILABLE','ACTIVE')
   AND    CSCH.SCHEDULE_ID <> G_SCHEDULE_ID
   AND    ACT_LIST.LIST_USED_BY = 'CSCH'
   AND    ACT_LIST.LIST_USED_BY_ID = CSCH.SCHEDULE_ID
   AND    ACT_LIST.LIST_HEADER_ID = LIST_HEADER.LIST_HEADER_ID
   AND    ACT_LIST.LIST_ACT_TYPE = 'TARGET'
   AND    LIST_HEADER.APPLY_TRAFFIC_COP = 'Y'
   AND    EXISTS
          (SELECT LIST_ENTRY1.PARTY_ID
           FROM   AMS_LIST_ENTRIES LIST_ENTRY1
                  ,AMS_LIST_ENTRIES LIST_ENTRY2
           WHERE  LIST_HEADER.LIST_HEADER_ID = LIST_ENTRY1.LIST_HEADER_ID
           AND    LIST_ENTRY1.PARTY_ID = LIST_ENTRY2.PARTY_ID
           AND    LIST_ENTRY2.LIST_HEADER_ID = p_list_header_id
         )
    ORDER BY CSCH.START_DATE_TIME
   ;
   */
    -- batoleti uncommented this cursor...
    -- batoleti Ref. bug# 5234351... added leading(ACT_LIST)  hint to the below query.
   CURSOR C_GET_SCHEDULE_IN_PIPELINE
   IS
   SELECT /*+ leading(ACT_LIST) */ CSCH.SCHEDULE_ID,CSCH.ACTIVITY_ID,CSCH.START_DATE_TIME
   FROM   AMS_CAMPAIGN_SCHEDULES_B CSCH,
          AMS_ACT_LISTS ACT_LIST,
          AMS_LIST_HEADERS_ALL LIST_HEADER
   WHERE  TRUNC(CSCH.START_DATE_TIME) BETWEEN
                                  p_preview_start_date AND p_preview_end_date
   AND    CSCH.STATUS_CODE in ('AVAILABLE','ACTIVE')
   AND    CSCH.SCHEDULE_ID <> G_SCHEDULE_ID
   AND    ACT_LIST.LIST_USED_BY = 'CSCH'
   AND    ACT_LIST.LIST_USED_BY_ID = CSCH.SCHEDULE_ID
   AND    ACT_LIST.LIST_HEADER_ID = LIST_HEADER.LIST_HEADER_ID
   AND    ACT_LIST.LIST_ACT_TYPE = 'TARGET'
   AND    LIST_HEADER.APPLY_TRAFFIC_COP = 'Y'
   AND    EXISTS
          (SELECT LIST_ENTRY1.PARTY_ID
           FROM   AMS_LIST_ENTRIES LIST_ENTRY1
                  ,AMS_LIST_ENTRIES LIST_ENTRY2
           WHERE  LIST_HEADER.LIST_HEADER_ID = LIST_ENTRY1.LIST_HEADER_ID
           AND    LIST_ENTRY1.PARTY_ID = LIST_ENTRY2.PARTY_ID
           AND    LIST_ENTRY2.LIST_HEADER_ID = p_list_header_id
         )
    ORDER BY CSCH.START_DATE_TIME
   ;

   /* End Bugfix: 4990567. */
   -- Get overlapping target group members for this schedule
   CURSOR C_GET_OVERLAPPING_MEMBER(p_schedule_id   NUMBER)
   IS
   SELECT LIST_ENTRY1.PARTY_ID
   FROM   AMS_LIST_ENTRIES LIST_ENTRY1
         ,AMS_LIST_ENTRIES LIST_ENTRY2
         ,AMS_CAMPAIGN_SCHEDULES_B CSCH
         ,AMS_ACT_LISTS ACT_LIST
         ,AMS_LIST_HEADERS_ALL LIST_HEADER
   WHERE  LIST_ENTRY1.LIST_HEADER_ID = p_list_header_id
   AND    LIST_ENTRY2.PARTY_ID = LIST_ENTRY1.PARTY_ID
   AND    LIST_ENTRY2.LIST_HEADER_ID = LIST_HEADER.LIST_HEADER_ID
   AND    ACT_LIST.LIST_USED_BY = 'CSCH'
   AND    ACT_LIST.LIST_USED_BY_ID = CSCH.SCHEDULE_ID
   AND    CSCH.SCHEDULE_ID = p_SCHEDULE_ID
   AND    ACT_LIST.LIST_ACT_TYPE='TARGET'
   AND    ACT_LIST.LIST_HEADER_ID = LIST_HEADER.LIST_HEADER_ID;

   CURSOR C_GET_RULE_DTLS(p_activity_id NUMBER)
   IS
   SELECT rule.rule_id rule_id
          ,rule.rule_type rule_type
          ,period.no_of_days no_of_days
          ,rule.max_contact_allowed max_contact_allowed
   FROM   ams_tcop_fr_rules_setup rule,
          ams_tcop_fr_periods_b period
   WHERE  rule.ENABLED_FLAG = 'Y'
   AND    (rule.CHANNEL_ID is null
          OR (rule.CHANNEL_ID = p_activity_id) )
   AND    rule.RULE_TYPE in ('GLOBAL' , 'CHANNEL_BASED')
   AND    rule.PERIOD_ID = period.PERIOD_ID
   ORDER BY (rule.MAX_CONTACT_ALLOWED * period.NO_OF_DAYS);

   CURSOR C_GET_GLOBAL_FATIGUE_LIST(p_no_of_days   NUMBER,
                                    p_preview_date Date,
                                    p_contact_party_list JTF_NUMBER_TABLE
                                    )
   IS
   SELECT /*+ leading(party_list) +*/
          CONTACT.PARTY_ID, COUNT(CONTACT.PARTY_ID)
   FROM   AMS_TCOP_CONTACTS CONTACT,
          (SELECT COLUMN_VALUE PARTY_ID
          FROM    TABLE(CAST(p_contact_party_list as JTF_NUMBER_TABLE))
          ) party_list
   WHERE CONTACT.PARTY_ID = PARTY_LIST.PARTY_ID
   AND   CONTACT_DATE BETWEEN TRUNC(p_preview_date - p_no_of_days)
                              AND TRUNC(p_preview_date)
   GROUP BY CONTACT.PARTY_ID;


   CURSOR C_GET_GLBL_SIMULATED_FTG_LIST(p_no_of_days   NUMBER,
                                          p_preview_date Date,
                                          p_contact_party_list JTF_NUMBER_TABLE
                                         )
   IS
   SELECT /*+ leading(party_list) +*/
          CONTACT.PARTY_ID, COUNT(CONTACT.PARTY_ID)
   FROM   AMS_TCOP_PRVW_CONTACTS CONTACT,
          (SELECT COLUMN_VALUE PARTY_ID
          FROM    TABLE(CAST(p_contact_party_list as JTF_NUMBER_TABLE))
          ) party_list
   WHERE CONTACT.PARTY_ID = PARTY_LIST.PARTY_ID
   AND   CONTACT_DATE BETWEEN TRUNC(p_preview_date - p_no_of_days)
                              AND TRUNC(p_preview_date)
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_GET_CHANNEL_FATIGUE_LIST(p_activity_id  NUMBER,
                                     p_no_of_days   NUMBER,
                                     p_preview_date Date,
                                     p_contact_party_list JTF_NUMBER_TABLE
                                    )
   IS
   SELECT /*+ leading(party_list) +*/
          CONTACT.PARTY_ID,
          COUNT(CONTACT.PARTY_ID)
   FROM   AMS_TCOP_CONTACTS CONTACT,
          (SELECT COLUMN_VALUE PARTY_ID
          FROM    TABLE(CAST(p_contact_party_list as JTF_NUMBER_TABLE))
          ) party_list
   WHERE CONTACT.PARTY_ID = PARTY_LIST.PARTY_ID
   AND   CONTACT.MEDIA_ID = p_activity_id
   AND   CONTACT_DATE BETWEEN TRUNC(p_preview_date - p_no_of_days)
                              AND TRUNC(p_preview_date)
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_GET_CHNL_SIMULATED_FTG_LIST(p_activity_id  NUMBER,
                                        p_no_of_days   NUMBER,
                                        p_preview_date Date,
                                        p_contact_party_list JTF_NUMBER_TABLE
                                         )
   IS
   SELECT /*+ leading(party_list) +*/
          CONTACT.PARTY_ID, COUNT(CONTACT.PARTY_ID)
   FROM   AMS_TCOP_PRVW_CONTACTS CONTACT,
          AMS_CAMPAIGN_SCHEDULES_B CSCH,
          (SELECT COLUMN_VALUE PARTY_ID
          FROM    TABLE(CAST(p_contact_party_list as JTF_NUMBER_TABLE))
          ) party_list
   WHERE CONTACT.PARTY_ID = PARTY_LIST.PARTY_ID
   AND   CSCH.SCHEDULE_ID = CONTACT.SCHEDULE_ID
   AND   CSCH.ACTIVITY_ID = p_activity_id
   AND   CONTACT_DATE BETWEEN TRUNC(p_preview_date - p_no_of_days)
                              AND TRUNC(p_preview_date)
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_CHECK_PARTY_IN_CONTACT_LIST(p_contact_party_list   JTF_NUMBER_TABLE
                                        , p_party_id   NUMBER
                                       )
   IS
   SELECT party_list.party_id
   FROM
   (SELECT column_value party_id
    FROM TABLE(CAST(p_contact_party_list as JTF_NUMBER_TABLE))
   ) party_list
   WHERE party_list.party_id=p_party_id;

   CURSOR C_GET_NEXT_PRVW_CONTACT
   IS
   SELECT AMS_TCOP_PRVW_CONTACTS_S.NEXTVAL
   FROM DUAL;


   l_schedule_id_list            NUMBER_TABLE;
   l_contact_id_list             JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_schedule_activity_id_list   NUMBER_TABLE;
   l_schedule_start_date_list    DATE_TABLE;

   l_contact_party_list          JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_fatigue_party_list          JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_global_contact_party_list   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_global_contact_count_list   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_channel_contact_party_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_channel_contact_count_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_temp_contact_party_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_temp_contact_count_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   l_fatigue_index   NUMBER;
   l_contact_index   NUMBER;
   l_global_contact_count NUMBER;
   l_channel_contact_count NUMBER;
   l_party_id        NUMBER;
   l_schedule_id        NUMBER;
   l_contact_id        NUMBER;
   l_contact_date    DATE;

   -- List of Constants
   PROCEDURE_NAME CONSTANT    VARCHAR2(30) := 'SIMULATE_FUTURE_CONTACTS';


BEGIN
   -- Get the list of schedules with the following attributes
   -- 1. The schedule start date is between preview start date and preview end date
   -- 2. The schedule status is 'Available' and 'Active'
   -- 3. There is an overlap with the Target Group members of these schedules
   --    and the schedule being previewed
   OPEN C_GET_SCHEDULE_IN_PIPELINE;
   FETCH C_GET_SCHEDULE_IN_PIPELINE
   BULK COLLECT
   INTO l_schedule_id_list,
        l_schedule_activity_id_list,
        l_schedule_start_date_list;
   CLOSE C_GET_SCHEDULE_IN_PIPELINE;

   IF (l_schedule_id_list.COUNT > 0) THEN
      -- batoleti : The G_NO_SCHEDULE_PIPELINE will be used in calculate_fatigue procedure.
      G_NO_SCHEDULE_PIPELINE:= FALSE;
      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'SCHEDULES_IN_PIPELINE_EXIST',
                          'Total Number of Schedules in Pipeline ='||to_char(l_schedule_id_list.count)
                          );

      FOR i IN l_schedule_id_list.FIRST .. l_schedule_id_list.LAST
      LOOP
         l_schedule_id := l_schedule_id_list(i);
         l_contact_date := l_schedule_start_date_list(i);

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'PROCESS_EACH_SCHEDULE_IN_PIPELINE',
                             'Schedule '||to_char(i)||' Id='||to_char(l_schedule_id) ||' ,Start Date ='||to_char(l_contact_date)||' and Activity Id ='||to_char(l_schedule_activity_id_list(i))
                             );
         -- calculate fatigue and contacts for this schedule
         -- Get the list of parties which will be fatigued
         -- First, Get the List of OverLapping Target Group Members
         OPEN C_GET_OVERLAPPING_MEMBER(l_schedule_id_list(i));
         FETCH C_GET_OVERLAPPING_MEMBER
         BULK COLLECT
         INTO l_contact_party_list;
         CLOSE C_GET_OVERLAPPING_MEMBER;

         IF (l_contact_party_list.count > 0) THEN

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'CHECK_OVERLAPPING_MEMBER',
                                'Overlapping Target Group Member Count = '||to_char(l_contact_party_list.count)
                                );

            FOR C1 IN C_GET_RULE_DTLS(l_schedule_activity_id_list(i))
            LOOP
               -- Apply Global Fatigue Rules
               IF (C1.RULE_TYPE='GLOBAL') THEN
                  -- Check if the already executed schedules influence the fatigue
                  IF (trunc(l_schedule_start_date_list(i) - C1.no_of_days)
                      <= trunc(sysdate))
                  THEN

                     OPEN C_GET_GLOBAL_FATIGUE_LIST
                                          (C1.NO_OF_DAYS,
                                           l_schedule_start_date_list(i),
                                           l_contact_party_list
                                          );

                     FETCH C_GET_GLOBAL_FATIGUE_LIST
                     BULK COLLECT
                     INTO l_temp_contact_party_list,
                          l_temp_contact_count_list;
                     CLOSE C_GET_GLOBAL_FATIGUE_LIST;

                     IF (l_temp_contact_party_list.count > 0) THEN
                        -- Check which parties have exceeded the contact count
                        FOR i in l_temp_contact_party_list.FIRST ..
                                 l_temp_contact_party_list.LAST
                        LOOP
                           IF (l_temp_contact_count_list(i) >=
                                      C1.max_contact_allowed) THEN
                              -- this is a fatigue entry, add to the fatigue list
                              l_fatigue_index := l_fatigue_party_list.count + 1;
                              l_fatigue_party_list.extend;
                              l_fatigue_party_list(l_fatigue_index) :=
                                                       l_temp_contact_party_list(i);
                           ELSE
                              -- this is not a fatigue entry, update the contact list
                              l_contact_index := l_global_contact_party_list.count + 1;
                              l_global_contact_party_list.extend;
                              l_global_contact_count_list.extend;

                              l_global_contact_party_list(l_contact_index) :=
                                                       l_temp_contact_party_list(i);
                              l_global_contact_count_list(l_contact_index) :=
                                                       l_temp_contact_count_list(i);
                           END IF;

                        END LOOP;
                     END IF;

                     l_global_contact_count := l_global_contact_count_list.COUNT;

                     IF (l_fatigue_party_list.count > 0 ) THEN

                        -- Remove from the Contact List the list of parties
                        -- already fatigued by the Global Rule
                        DELETE_FROM_LIST(l_contact_party_list,
                                         l_fatigue_party_list);

                     END IF;

                     -- Reset the list variable since it will be reused
                     l_fatigue_party_list.delete;

                  END IF;

                  -- Now, get the number of contacts made using the
                  -- Simulated Contact information

                  OPEN C_GET_GLBL_SIMULATED_FTG_LIST
                                          (C1.NO_OF_DAYS,
                                           l_schedule_start_date_list(i),
                                           l_contact_party_list
                                           );
                  FETCH C_GET_GLBL_SIMULATED_FTG_LIST
                  BULK COLLECT
                  INTO l_temp_contact_party_list,
                       l_temp_contact_count_list;
                  CLOSE C_GET_GLBL_SIMULATED_FTG_LIST;

                  IF (l_temp_contact_party_list.count > 0) THEN
                     -- Check which parties have exceeded the contact count
                     FOR i in l_temp_contact_party_list.FIRST ..
                              l_temp_contact_party_list.LAST
                     LOOP
                        IF (l_temp_contact_count_list(i) >=
                                   C1.max_contact_allowed) THEN
                           -- this is a fatigue entry, add to the fatigue list
                           l_fatigue_index := l_fatigue_party_list.count + 1;
                           l_fatigue_party_list.extend;
                           l_fatigue_party_list(l_fatigue_index) :=
                                                    l_temp_contact_party_list(i);
                        ELSE
                           -- this is not a fatigue entry
                           -- First, check if this entry exists in the previously
                           -- created global contact list.
                           IF (l_global_contact_count > 0 ) THEN
                              -- if it exists then there is a chance that
                              -- total contacts made in the past and future
                              -- will exceed the max contact allowed

                              l_contact_index := l_global_contact_count + 1;

                              OPEN C_CHECK_PARTY_IN_CONTACT_LIST(
                                      l_global_contact_party_list,
                                      l_temp_contact_party_list(i)
                              );
                              FETCH C_CHECK_PARTY_IN_CONTACT_LIST
                              INTO  l_party_id;
                              CLOSE C_CHECK_PARTY_IN_CONTACT_LIST;

                              -- This Party is already part of the contact list
                              IF (l_party_id is not null) THEN
                                 -- Loop through the entries to find the index
                                 -- ,get the contact count
                                 -- Finally, update the contact count in the global list
                                 IF (l_global_contact_party_list.count > 0) THEN
                                    FOR j in l_global_contact_party_list.FIRST ..
                                           l_global_contact_party_list.LAST
                                    LOOP
                                       IF (l_global_contact_party_list(j) = l_party_id) THEN
                                          -- Retrieve the contact count at that index
                                          l_global_contact_count_list(j) :=
                                            l_temp_contact_count_list(i) +
                                            l_global_contact_count_list(j);

                                       END IF;

                                    END LOOP;
                                 END IF;

                              ELSE
                                 l_global_contact_party_list.extend;
                                 l_global_contact_count_list.extend;

                                 l_global_contact_party_list(l_contact_index) :=
                                                          l_temp_contact_party_list(i);
                                 l_global_contact_count_list(l_contact_index) :=
                                                          l_temp_contact_count_list(i);


                              END IF;

                           ELSE

                              l_global_contact_party_list.extend;
                              l_global_contact_count_list.extend;

                              l_global_contact_party_list(l_contact_index) :=
                                                       l_temp_contact_party_list(i);
                              l_global_contact_count_list(l_contact_index) :=
                                                       l_temp_contact_count_list(i);
                           END IF;

                        END IF;

                     END LOOP; /* loop through l_temp_contact_count_list */
                  END IF;

                  IF (l_global_contact_party_list.count > 0) THEN

                     -- Once again loop through the l_global_contact_party_list to
                     -- eliminate fatigue entries
                     FOR i in l_global_contact_party_list.FIRST ..
                              l_global_contact_party_list.LAST
                     LOOP
                        IF (l_global_contact_count_list(i) >= C1.max_contact_allowed)
                        THEN
                           l_fatigue_index := l_fatigue_party_list.count;
                           l_fatigue_party_list.extend;
                           l_fatigue_party_list(l_fatigue_index + 1) :=
                                               l_global_contact_party_list(i);

                        END IF;
                     END LOOP;
                  END IF;

                  IF (l_fatigue_party_list.count > 0) THEN
                     -- Once again, delete fatigue entries from the contact
                     -- list
                        DELETE_FROM_LIST(l_contact_party_list,
                                         l_fatigue_party_list
                                        );

                     l_fatigue_party_list.delete;
                  END IF;

                  -- Reset some of the Nested Tables which will be reused
                  l_temp_contact_party_list.delete;
                  l_temp_contact_count_list.delete;
                  l_global_contact_party_list.delete;
                  l_global_contact_count_list.delete;


               ELSE
                  -- Check fatigue using the channel rule

                  -- Check if already executed schedules influence the fatigue
                  IF (trunc(l_schedule_start_date_list(i) - C1.no_of_days)
                           <= sysdate) THEN
                     OPEN C_GET_CHANNEL_FATIGUE_LIST
                                          (l_schedule_activity_id_list(i),
                                           C1.NO_OF_DAYS,
                                           l_schedule_start_date_list(i),
                                           l_contact_party_list
                                          );
                     FETCH C_GET_CHANNEL_FATIGUE_LIST
                     BULK COLLECT
                     INTO l_temp_contact_party_list,
                          l_temp_contact_count_list;
                     CLOSE C_GET_CHANNEL_FATIGUE_LIST;

                     IF (l_temp_contact_party_list.count > 0) THEN

                        -- Check which parties have exceeded the contact count
                        FOR i in l_temp_contact_party_list.FIRST ..
                                 l_temp_contact_party_list.LAST
                        LOOP
                           IF (l_temp_contact_count_list(i) >=
                                      C1.max_contact_allowed) THEN
                              -- this is a fatigue entry, add to the fatigue list
                              l_fatigue_index := l_fatigue_party_list.count + 1;
                              l_fatigue_party_list.extend;
                              l_fatigue_party_list(l_fatigue_index) :=
                                                       l_temp_contact_party_list(i);
                           ELSE
                              -- this is not a fatigue entry, update the contact list
                              l_contact_index := l_channel_contact_party_list.count + 1;
                              l_channel_contact_party_list(l_contact_index) :=
                                                       l_temp_contact_party_list(i);
                              l_channel_contact_count_list(l_contact_index) :=
                                                       l_temp_contact_count_list(i);
                           END IF;

                        END LOOP;
                     END IF;

                     l_channel_contact_count := l_channel_contact_count_list.COUNT;

                     IF (l_fatigue_party_list.count > 0 ) THEN

                        -- Remove from the Contact List the list of parties
                        -- already fatigued by the Global Rule
                        DELETE_FROM_LIST(l_contact_party_list,
                                         l_fatigue_party_list);

                        -- Reset the list variable since it will be reused
                        l_fatigue_party_list.delete;
                     END IF;


                  END IF;

                  -- Now, get the number of contacts made using the
                  -- Simulated Contact information

                  OPEN C_GET_CHNL_SIMULATED_FTG_LIST
                                          (l_schedule_activity_id_list(i),
                                           C1.NO_OF_DAYS,
                                           l_schedule_start_date_list(i),
                                           l_contact_party_list
                                           );
                  FETCH C_GET_CHNL_SIMULATED_FTG_LIST
                  BULK COLLECT
                  INTO l_temp_contact_party_list,
                       l_temp_contact_count_list;
                  CLOSE C_GET_CHNL_SIMULATED_FTG_LIST;

                  IF (l_temp_contact_party_list.count > 0) THEN

                     -- Check which parties have exceeded the contact count
                     FOR i in l_temp_contact_party_list.FIRST ..
                              l_temp_contact_party_list.LAST
                     LOOP
                        IF (l_temp_contact_count_list(i) >=
                                   C1.max_contact_allowed) THEN
                           -- this is a fatigue entry, add to the fatigue list
                           l_fatigue_index := l_fatigue_party_list.count + 1;
                           l_fatigue_party_list.extend;
                           l_fatigue_party_list(l_fatigue_index) :=
                                                    l_temp_contact_party_list(i);
                        ELSE
                           -- this is not a fatigue entry
                           -- First, check if this entry exists in the previously
                           -- created channel contact list.
                           IF (l_channel_contact_count > 0 ) THEN
                              -- if it exists then there is a chance that
                              -- total contacts made in the past and future
                              -- will exceed the max contact allowed

                              l_contact_index := l_channel_contact_count + 1;

                              OPEN C_CHECK_PARTY_IN_CONTACT_LIST(
                                      l_channel_contact_party_list,
                                      l_temp_contact_party_list(i)
                              );
                              FETCH C_CHECK_PARTY_IN_CONTACT_LIST
                              INTO  l_party_id;
                              CLOSE C_CHECK_PARTY_IN_CONTACT_LIST;

                              -- This Party is already part of the contact list
                              IF (l_party_id is not null) THEN
                                 -- Loop through the entries to find the index
                                 -- ,get the contact count
                                 -- Finally, update the contact count in the global list
                                 FOR j in l_channel_contact_party_list.FIRST ..
                                        l_channel_contact_party_list.LAST
                                 LOOP
                                    IF (l_channel_contact_party_list(j) = l_party_id)
                                    THEN
                                       -- Retrieve the contact count at that index
                                       l_channel_contact_count_list(j) :=
                                         l_temp_contact_count_list(i) +
                                         l_channel_contact_count_list(j);

                                    END IF;

                                 END LOOP;

                              ELSE

                                 l_channel_contact_party_list.extend;
                                 l_channel_contact_count_list.extend;

                                 l_channel_contact_party_list(l_contact_index) :=
                                                          l_temp_contact_party_list(i);
                                 l_channel_contact_count_list(l_contact_index) :=
                                                          l_temp_contact_count_list(i);

                              END IF;

                           ELSE

                              l_channel_contact_party_list.extend;
                              l_channel_contact_count_list.extend;

                              l_channel_contact_party_list(l_contact_index) :=
                                                       l_temp_contact_party_list(i);
                              l_channel_contact_count_list(l_contact_index) :=
                                                       l_temp_contact_count_list(i);
                           END IF;

                        END IF;

                     END LOOP; /* loop through l_temp_contact_count_list */

                  END IF;

                  IF (l_channel_contact_count_list.count > 0) THEN
                     -- Once again loop through the l_channel_contact_party_list to
                     -- eliminate fatigue entries
                     FOR i in l_channel_contact_party_list.FIRST ..
                              l_channel_contact_party_list.LAST
                     LOOP
                        IF (l_channel_contact_count_list(i) >= C1.max_contact_allowed)
                        THEN
                           l_fatigue_index := l_fatigue_party_list.count;
                           l_fatigue_party_list.extend;
                           l_fatigue_party_list(l_fatigue_index + 1) :=
                              l_channel_contact_party_list(i);

                        END IF;
                     END LOOP;
                  END IF;

                  IF (l_fatigue_party_list.count > 0) THEN
                     -- Once again, delete fatigue entries from the contact
                     -- list
                     DELETE_FROM_LIST(l_contact_party_list,
                                      l_fatigue_party_list
                                      );

                     l_fatigue_party_list.delete;
                  END IF;

               END IF;/* C1.RULE_TYPE='GLOBAL */
            END LOOP;

         END IF;

         IF (l_contact_party_list.count > 0 ) THEN

            -- Generate Sequence number for CONTACT_ID column
            FOR i in l_contact_party_list.FIRST .. l_contact_party_list.LAST
            LOOP
               OPEN C_GET_NEXT_PRVW_CONTACT;
               FETCH C_GET_NEXT_PRVW_CONTACT
               INTO l_contact_id;
               CLOSE C_GET_NEXT_PRVW_CONTACT;

               l_contact_id_list.extend;
	       l_contact_id_list(i) := l_contact_id;

            END LOOP;

            -- Create Contacts in AMS_TCOP_PRVW_CONTACTS
            FORALL i in l_contact_party_list.FIRST .. l_contact_party_list.LAST
            INSERT INTO
            AMS_TCOP_PRVW_CONTACTS
            (
              CONTACT_ID,
              SCHEDULE_ID,
              PARTY_ID,
              PREVIEW_ID,
              CONTACT_DATE,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN
            )
            VALUES
            (
              l_contact_id_list(i),
              l_schedule_id,
              l_contact_party_list(i),
              G_PRVW_REQUEST_ID,
              l_contact_date,
              sysdate,
              FND_GLOBAL.USER_ID,
              sysdate,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.USER_ID

            );
         ELSE
            G_NO_SCHEDULE_PIPELINE := TRUE;

         END IF;

      end LOOP;


    ELSE
       G_NO_SCHEDULE_PIPELINE := TRUE;


   END IF;/*l_schedule_id_list.COUNT > 0*/


END SIMULATE_FUTURE_CONTACTS;


-- ===============================================================
-- Start of Comments
-- Name
-- CALCULATE_FATIGUE
--
-- Purpose
-- Project fatigue for a given date
--
PROCEDURE   CALCULATE_FATIGUE( p_preview_date    IN    Date
                              ,p_list_header_id  IN    NUMBER)
IS
   CURSOR C_CHECK_PARTY(p_start_date   Date,
                        p_end_date     Date)
   IS
   SELECT PARTY_LIST.PARTY_ID
   FROM
   (SELECT column_value PARTY_ID
   FROM   TABLE(CAST(G_PARTY_LIST as JTF_NUMBER_TABLE)) ) PARTY_LIST
   WHERE EXISTS
         (SELECT PARTY_ID
          FROM AMS_TCOP_CONTACTS
          WHERE PARTY_ID = PARTY_LIST.PARTY_ID
          AND   CONTACT_DATE BETWEEN p_start_date and p_end_date
         );

   CURSOR C_CHECK_PARTY_FOR_CHANNEL(p_start_date   Date,
                                    p_end_date     Date)
   IS
   SELECT PARTY_LIST.PARTY_ID
   FROM
   (SELECT column_value party_id
   FROM   TABLE(CAST(G_PARTY_LIST as JTF_NUMBER_TABLE))) PARTY_LIST
   WHERE EXISTS
         (SELECT PARTY_ID
          FROM AMS_TCOP_CONTACTS
          WHERE PARTY_ID = PARTY_LIST.PARTY_ID
          AND   MEDIA_ID = G_ACTIVITY_ID
          AND   CONTACT_DATE BETWEEN p_start_date and p_end_date
         );

   CURSOR C_GET_GLOBAL_CONTACT_COUNT(p_start_date  date,p_end_date date)
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,COUNT(CONTACT.PARTY_ID)
   FROM AMS_TCOP_CONTACTS CONTACT,
        (SELECT column_value party_id
         FROM   TABLE(CAST(G_PARTY_LIST as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_GET_GLOBAL_SIMULATED_CONTACT(p_start_date  date,p_end_date date)
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,COUNT(CONTACT.PARTY_ID)
   FROM AMS_TCOP_PRVW_CONTACTS CONTACT,
        (SELECT column_value party_id
         FROM   TABLE(CAST(G_PARTY_LIST as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND   PREVIEW_ID = G_PRVW_REQUEST_ID
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_GET_CHNL_SIMULATED_CONTACT(p_start_date  date
                                       ,p_end_date date
                                       )
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,COUNT(CONTACT.PARTY_ID)
   FROM AMS_TCOP_PRVW_CONTACTS CONTACT,
        AMS_CAMPAIGN_SCHEDULES_B CSCH,
        (SELECT column_value party_id
         FROM   TABLE(CAST(G_PARTY_LIST as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND   PREVIEW_ID = G_PRVW_REQUEST_ID
   AND   CSCH.SCHEDULE_ID = CONTACT.SCHEDULE_ID
   AND   CSCH.ACTIVITY_ID = G_ACTIVITY_ID
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_GET_GLOBAL_FATIGUE_BY(p_start_date  date
                                  ,p_end_date date
                                  ,p_fatigue_party_list JTF_NUMBER_TABLE
                                 )
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,CONTACT.SCHEDULE_ID
   FROM AMS_TCOP_CONTACTS CONTACT,
        (SELECT column_value party_id
         FROM   TABLE(CAST(p_fatigue_party_list as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date;

   CURSOR C_GET_CHANNEL_CONTACT_COUNT(p_start_date  date,
                                      p_end_date date)
   IS
   SELECT /*+ leading(party_list) +*/
         CONTACT.PARTY_ID,
         COUNT(CONTACT.PARTY_ID)
   FROM AMS_TCOP_CONTACTS CONTACT,
        (SELECT column_value party_id
         FROM   TABLE(CAST(G_PARTY_LIST as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND   CONTACT.MEDIA_ID = G_Activity_Id
   GROUP BY CONTACT.PARTY_ID;

   CURSOR C_GET_CHANNEL_FATIGUE_BY(p_start_date  date
                                  ,p_end_date date
                                  ,p_fatigue_party_list JTF_NUMBER_TABLE
                                 )
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,CONTACT.SCHEDULE_ID
   FROM AMS_TCOP_CONTACTS CONTACT,
        (SELECT column_value party_id
         FROM   TABLE(CAST(p_fatigue_party_list as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.MEDIA_ID = G_ACTIVITY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date;

   CURSOR C_GET_GLOBAL_PRVW_FTG_BY(p_start_date  date
                                  ,p_end_date date
                                  ,p_fatigue_party_list JTF_NUMBER_TABLE
                                 )
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,CONTACT.SCHEDULE_ID
   FROM AMS_TCOP_PRVW_CONTACTS CONTACT,
        (SELECT column_value party_id
         FROM   TABLE(CAST(p_fatigue_party_list as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date;

   CURSOR C_GET_CHANNEL_PRVW_FTG_BY(p_start_date  date
                                  ,p_end_date date
                                  ,p_fatigue_party_list JTF_NUMBER_TABLE
                                 )
   IS
   SELECT /*+ leading(party_list) +*/
   CONTACT.PARTY_ID,CONTACT.SCHEDULE_ID
   FROM AMS_TCOP_PRVW_CONTACTS CONTACT,
        AMS_CAMPAIGN_SCHEDULES_B CSCH,
        (SELECT column_value party_id
         FROM   TABLE(CAST(p_fatigue_party_list as JTF_NUMBER_TABLE))
        ) party_list
   WHERE CONTACT.PARTY_ID = party_list.PARTY_ID
   AND   CONTACT.SCHEDULE_ID = CSCH.SCHEDULE_ID
   AND   CSCH.ACTIVITY_ID = G_ACTIVITY_ID
   AND   CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date;

   CURSOR C_CHECK_PARTY_IN_CONTACT_LIST(p_contact_party_list   JTF_NUMBER_TABLE
                                        ,p_party_id   NUMBER
                                       )
   IS
   SELECT party_list.party_id
   FROM
   (SELECT column_value party_id
    FROM TABLE(CAST(p_contact_party_list as JTF_NUMBER_TABLE))
   ) party_list
   WHERE party_list.party_id=p_party_id;

   CURSOR GET_SCHEDULE_FROM_CONTACTS(p_party_id number,
                                     p_start_date date,
                                     p_end_date date
                                     )
   IS
   SELECT SCHEDULE_ID
   FROM AMS_TCOP_CONTACTS
   WHERE CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND   PARTY_ID = p_party_id;

   CURSOR GET_CSCH_FROM_CONTACTS_CHNL(p_party_id number,
                                     p_start_date date,
                                     p_end_date date
                                     )
   IS
   SELECT CONTACT.SCHEDULE_ID
   FROM AMS_TCOP_CONTACTS CONTACT
   WHERE CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND   CONTACT.MEDIA_ID = G_ACTIVITY_ID
   AND   CONTACT.PARTY_ID = p_party_id;

   CURSOR GET_SCHEDULE_FROM_PRVW (p_party_id number,
                                     p_start_date date,
                                     p_end_date date,
                                     p_row_num number
                                     )
   IS
   SELECT SCHEDULE_ID
   FROM AMS_TCOP_PRVW_CONTACTS
   WHERE CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND party_id = p_party_id
   AND PREVIEW_ID = G_PRVW_REQUEST_ID
   AND rownum = p_row_num
   ORDER BY CONTACT_DATE;

   CURSOR GET_SCHEDULE_FROM_PREVIEW_CHNL (p_party_id number,
                                           p_start_date date,
                                           p_end_date date,
                                           p_row_num number
                                           )
   IS
   SELECT CONTACT.SCHEDULE_ID
   FROM AMS_TCOP_PRVW_CONTACTS CONTACT,
        AMS_CAMPAIGN_SCHEDULES_B CSCH
   WHERE CONTACT.CONTACT_DATE BETWEEN p_start_date and p_end_date
   AND CSCH.SCHEDULE_ID = CONTACT.SCHEDULE_ID
   AND CSCH.ACTIVITY_ID = G_ACTIVITY_ID
   AND CONTACT.party_id = p_party_id
   AND PREVIEW_ID = G_PRVW_REQUEST_ID
   AND rownum = p_row_num
   ORDER BY CONTACT.CONTACT_DATE;

   -- Get Nextval from AMS_TCOP_PRVW_FATIGUE_S
   CURSOR C_GET_NEXT_FATIGUE
   IS
   SELECT AMS_TCOP_PRVW_FATIGUE_S.NEXTVAL
   FROM DUAL;

   CURSOR C_GET_NEXT_FTG_DTL
   IS
   SELECT ams_tcop_prvw_ftg_dtls_s.NEXTVAL
   FROM DUAL;

   CURSOR C_GET_NEXT_FTG_BY
   IS
   SELECT ams_tcop_prvw_ftg_by_s.nextval
   FROM DUAL;

   l_party_id  NUMBER;
   l_global_fatigue_start_date Date;
   l_channel_fatigue_start_date Date;
   l_apply_global_rule   boolean;
   loop_counter   NUMBER := 0;
   j              NUMBER;
   l_index              NUMBER;
   l_preview_id   NUMBER;
   l_fatigue_dtl_id   NUMBER;
   l_ftg_by_id    NUMBER;
   l_fatigue_count NUMBER;

   l_global_party_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_temp_ftg_prvw_party_list JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_temp_prvw_ftg_by_party JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_temp_prvw_ftg_by_schedule JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_global_contact_count_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_schedule_contact_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_schedule_prvw_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_temp_party_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_temp_contact_count_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_channel_party_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_channel_contact_count_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_temp_fatigue_party_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_temp_fatigue_by_party_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_temp_ftg_by_schedule_list   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_fatigue_detail_list JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_fatigue_detail_id_list JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_fatigue_by_id_list    JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   l_global_rule_val    NUMBER := 0;
   l_channnel_rule_val NUMBER :=0;
BEGIN
   G_PARTY_LIST := G_PARTY_TGROUP_LIST;
   -- Apply fatigue rules based on the schedules already executed
   -- Apply the most restrictive rule first

   --dbms_output.put_line('Calculating Fatigue for Date = '||to_char(p_preview_date));

   -- Get the most retrictive Rule between the Global and the Channel rule
  /* IF ( (nvl(G_Global_Max_Contact,0) * nvl(G_Global_No_Of_Days,0)) >
                   (nvl(G_Channel_Max_Contact,0) * nvl(G_Channel_No_Of_Days,0)) ) THEN

      l_apply_global_rule := true;
   ELSE
      l_apply_global_rule := false;
   END IF;
   --This same condition is written below with more checking conditions...
  */

l_global_rule_val := nvl(G_Global_Max_Contact,0) * nvl(G_Global_No_Of_Days,0);
l_channnel_rule_val:= nvl(G_Channel_Max_Contact,0) * nvl(G_Channel_No_Of_Days,0);



l_apply_global_rule := false;  --initialize to apply channel ...
IF ( (l_global_rule_val > 0) AND (l_channnel_rule_val > 0) AND
     (l_global_rule_val > l_channnel_rule_val)) THEN
   l_apply_global_rule := true;   -- Most restricted rule will take precedence...here its global rule
ELSIF (l_global_rule_val > 0 AND l_channnel_rule_val = 0) THEN
    l_apply_global_rule := true;  -- No channel ftg rule. So, go for global...
    ELSIF (l_global_rule_val = 0 AND l_channnel_rule_val > 0) THEN
    l_apply_global_rule := false;  --No global ftg rule so.. go for channel...
 END IF;




   LOOP

      IF (l_apply_global_rule) THEN
         --dbms_output.put_line('Applying Global Rule');

         -- First, check if any party will be fatigued based on the
         -- schedules which have already been executed
         l_global_fatigue_start_date := p_preview_date - G_GLOBAL_NO_OF_DAYS;
         --dbms_output.put_line('Global Fatigue Start Date = '||to_char(l_global_fatigue_start_date));

         IF (trunc(l_global_fatigue_start_date) <= trunc(sysdate)) THEN
            --dbms_output.put_line('Global Fatigue Start Date Is a Past Date');


            -- check if any of these parties exist in AMS_TCOP_CONTACTS
            OPEN C_CHECK_PARTY(l_global_fatigue_start_date,sysdate);
            FETCH C_CHECK_PARTY
            INTO l_party_id;
            CLOSE C_CHECK_PARTY;

            IF (l_party_id IS NOT NULL) THEN
               --dbms_output.put_line('Global Fatigue Start Date Is a Past Date');
               -- check if any party is fatigued as per the global rule
               OPEN C_GET_GLOBAL_CONTACT_COUNT(l_global_fatigue_start_date,
                                               sysdate);
               FETCH C_GET_GLOBAL_CONTACT_COUNT
               BULK COLLECT
               INTO l_global_party_list
                    ,l_global_contact_count_list;

               CLOSE C_GET_GLOBAL_CONTACT_COUNT;

               IF (l_global_party_list.count > 0) THEN
                  --dbms_output.put_line('Number of people contacted ='||to_char(l_global_party_list.count));

                  -- Get the list of parties which are already fatigued
                  FOR i in l_global_party_list.FIRST .. l_global_party_list.LAST
                  LOOP
                     IF (l_global_contact_count_list(i) >= G_Global_Max_Contact)
                     THEN

                        -- Add this party to the fatigue list
                        j := l_temp_fatigue_party_list.count + 1;
                        l_temp_fatigue_party_list.extend;
                        l_temp_fatigue_party_list(j) := l_global_party_list(i);

                        -- Remove that entry from l_global_party_list
                        l_global_party_list.delete(i);
                        l_global_contact_count_list.delete(i);

                     END IF;
                  END LOOP;
               END IF;

               -- IF there are any fatigued parties found, get the fatigue by
               -- schedule list
               IF (l_temp_fatigue_party_list.count > 0) THEN
                  --dbms_output.put_line('Number of people fatigued by global rule ='||to_char(l_temp_fatigue_party_list.count));

                  OPEN C_GET_GLOBAL_FATIGUE_BY(l_global_fatigue_start_date,
                                               sysdate,
                                               l_temp_fatigue_party_list
                                               );
                  FETCH C_GET_GLOBAL_FATIGUE_BY
                  BULK COLLECT
                  INTO l_temp_fatigue_by_party_list,
                       l_temp_ftg_by_schedule_list;
                  CLOSE C_GET_GLOBAL_FATIGUE_BY;

                  APPEND_GLOBAL_FATIGUE_LIST(l_temp_fatigue_party_list,
                                             l_temp_fatigue_by_party_list,
                                             l_temp_ftg_by_schedule_list
                                            );

                  --Remove the ones already fatigued from the Original Party
                  --List
                  DELETE_FROM_LIST(G_PARTY_LIST,l_temp_fatigue_party_list);

                  -- Reset the temporary variables, to be re-used
                  l_temp_fatigue_party_list.delete;
                  l_temp_fatigue_by_party_list.delete;
                  l_temp_ftg_by_schedule_list.delete;

               END IF;

            END IF;

         END IF;
         -- Now, use the simulated information stored in AMS_TCOP_PRVW_CONTACTS
         -- to verify the contact information
         IF ( NOT(G_NO_SCHEDULE_PIPELINE) ) THEN

            OPEN C_GET_GLOBAL_SIMULATED_CONTACT(l_global_fatigue_start_date,
                                                p_preview_date
                                               );
            FETCH C_GET_GLOBAL_SIMULATED_CONTACT
            BULK COLLECT
            INTO l_temp_party_list,
                 l_temp_contact_count_list;
            CLOSE C_GET_GLOBAL_SIMULATED_CONTACT;

            -- Use the Contact count of already executed schedules
            -- and contact count of the simulated schedules in tandem to decide
            -- fatigue
            IF (l_global_party_list.count > 0) THEN

               FOR i in l_temp_party_list.FIRST
                        .. l_temp_party_list.LAST
               LOOP
                  -- Check if the party already exists in l_global_party_list
                  OPEN C_CHECK_PARTY_IN_CONTACT_LIST(l_global_party_list,
                                                     l_temp_party_list(i)
                                                     );
                  FETCH C_CHECK_PARTY_IN_CONTACT_LIST
                  INTO l_party_id;
                  CLOSE C_CHECK_PARTY_IN_CONTACT_LIST;

                  IF (l_party_id is not null) THEN
                     -- Get the count index
                     FOR j in l_global_party_list.first ..
                              l_global_party_list.last
                     LOOP
                        IF (l_global_party_list(j) = l_party_id) THEN
                           -- if the total contact count exceeds fatigue limit
                           -- then get the contact count
                           IF ((l_global_contact_count_list(j) +
                                l_temp_contact_count_list(i)) >=
                                G_Global_max_contact) THEN
                                -- this entry is fatigued
                                -- now, find out the fatigued by
                                -- it will be a combination of schedules
                                -- in AMS_TCOP_CONTACTS and
                                -- AMS_TCOP_PRVW_CONTACTS
                                OPEN GET_SCHEDULE_FROM_CONTACTS
                                   (l_party_id,
                                    l_global_fatigue_start_date,
                                    sysdate
                                    );
                                 FETCH GET_SCHEDULE_FROM_CONTACTS
                                 BULK COLLECT
                                 INTO l_schedule_contact_list;
                                 CLOSE GET_SCHEDULE_FROM_CONTACTS;

                                 OPEN GET_SCHEDULE_FROM_PRVW
                                    (l_party_id,
                                    l_global_fatigue_start_date,
                                    p_preview_date,
                                    (G_global_max_contact -
                                    l_global_contact_count_list(j))
                                    );
                                 FETCH GET_SCHEDULE_FROM_PRVW
                                 BULK COLLECT
                                 INTO l_schedule_prvw_list;

                                 CLOSE GET_SCHEDULE_FROM_PRVW;

                                 -- Apply the fatigue List and the Fatigue By
                                 -- List
                                 l_index := l_temp_fatigue_party_list.count + 1;
                                 l_temp_fatigue_party_list.extend;
                                 l_temp_fatigue_party_list(l_index) :=
                                                                l_party_id;

                                 FOR k in l_schedule_contact_list.first
                                          .. l_schedule_contact_list.last
                                 loop
                                    l_index := l_temp_fatigue_by_party_list.count + 1;
                                    l_temp_fatigue_by_party_list.extend;
                                    l_temp_ftg_by_schedule_list.extend;

                                    l_temp_fatigue_by_party_list(l_index) :=
                                      l_party_id;
                                    l_temp_ftg_by_schedule_list(l_index)
                                       := l_schedule_contact_list(k);

                                 end loop;

                                 FOR l in l_schedule_prvw_list.first
                                          .. l_schedule_prvw_list.last
                                 loop
                                    l_index := l_temp_fatigue_by_party_list.count + 1;
                                    l_temp_fatigue_by_party_list.extend;
                                    l_temp_ftg_by_schedule_list.extend;

                                    l_temp_fatigue_by_party_list(l_index) :=
                                      l_party_id;
                                    l_temp_ftg_by_schedule_list(l_index)
                                       := l_schedule_prvw_list(l);

                                 end loop;


                           END IF;
                        END IF;
                     END LOOP;
                  ELSE
                     -- check if this party is fatigued or not
                     IF (l_temp_contact_count_list(i) >= G_Global_Max_Contact)
                     THEN
                        -- add to the fatigue list
                        l_index := l_temp_fatigue_party_list.count + 1;
                        l_temp_fatigue_party_list.extend;
                        l_temp_fatigue_party_list(l_index) :=
                           l_temp_party_list(i);

                        -- add this entry to another list which will be used
                        -- to get the fatigue by in one shot
                        l_index := l_temp_ftg_prvw_party_list.count + 1;
                        l_temp_ftg_prvw_party_list.extend;
                        l_temp_ftg_prvw_party_list(l_index) :=
                           l_temp_party_list(i);

                     END IF;
                  END IF;


               END LOOP;

               IF (l_temp_ftg_prvw_party_list.count > 0 ) THEN
                  -- get the corresponding fatigue by
                  OPEN C_GET_GLOBAL_PRVW_FTG_BY(l_global_fatigue_start_date,
                                            p_preview_date,
                                            l_temp_ftg_prvw_party_list);
                  FETCH C_GET_GLOBAL_PRVW_FTG_BY
                  BULK COLLECT
                  INTO l_temp_prvw_ftg_by_party,
                       l_temp_prvw_ftg_by_schedule;
                  CLOSE C_GET_GLOBAL_PRVW_FTG_BY;

                  FOR l in l_temp_prvw_ftg_by_party.FIRST ..
                           l_temp_prvw_ftg_by_party.LAST
                  LOOP
                     -- Add these fatigue by entries to the l_temp_fatigue
                     -- entries
                     l_index := l_temp_fatigue_by_party_list.count + 1;
                     l_temp_fatigue_by_party_list.extend;
                     l_temp_ftg_by_schedule_list.extend;

                     l_temp_fatigue_by_party_list(l_index) :=
                       l_temp_prvw_ftg_by_party(l);
                     l_temp_ftg_by_schedule_list(l_index)
                        := l_temp_prvw_ftg_by_schedule(l);
                  END LOOP;

               END IF;

               APPEND_GLOBAL_FATIGUE_LIST(l_temp_fatigue_party_list,
                                          l_temp_fatigue_by_party_list,
                                          l_temp_ftg_by_schedule_list
                                         );

               --Remove the ones already fatigued from the Original Party
               --List
               DELETE_FROM_LIST(G_PARTY_LIST,l_temp_fatigue_party_list);

               -- Reset the temporary variables, to be re-used
               l_temp_fatigue_party_list.delete;
               l_temp_fatigue_by_party_list.delete;
               l_temp_ftg_by_schedule_list.delete;

            ELSE
               -- no parties exist in the global list
               IF (l_temp_party_list.count > 0) THEN
		       FOR k in l_temp_party_list.first ..
			   l_temp_party_list.last
		       LOOP
			  -- check if any party is going to be fatigued
			  IF (l_temp_contact_count_list(k) >= G_Global_Max_Contact)
			  THEN
			     -- Add to the fatigue list
			     l_index := l_temp_fatigue_party_list.count + 1;
			     l_temp_fatigue_party_list.extend;
			     l_temp_fatigue_party_list(l_index) :=
				l_temp_party_list(k);
			  END IF;
		       END LOOP;
	       END IF;

               IF (l_temp_fatigue_party_list.count > 0 ) THEN
                  -- Now, get the fatigue by
                  OPEN C_GET_GLOBAL_PRVW_FTG_BY(l_global_fatigue_start_date,
                                                  p_preview_date,
                                                  l_temp_fatigue_party_list);
                  FETCH C_GET_GLOBAL_PRVW_FTG_BY
                  BULK COLLECT
                  INTO l_temp_fatigue_by_party_list,
                       l_temp_ftg_by_schedule_list;
                  CLOSE C_GET_GLOBAL_PRVW_FTG_BY;

                  APPEND_GLOBAL_FATIGUE_LIST(l_temp_fatigue_party_list,
                                             l_temp_fatigue_by_party_list,
                                             l_temp_ftg_by_schedule_list
                                            );

                  --Remove the ones already fatigued from the Original Party
                  --List
                  DELETE_FROM_LIST(G_PARTY_LIST,l_temp_fatigue_party_list);

                  -- Reset the temporary variables, to be re-used
                  l_temp_fatigue_party_list.delete;
                  l_temp_fatigue_by_party_list.delete;
                  l_temp_ftg_by_schedule_list.delete;
                  l_temp_fatigue_by_party_list.delete;
                  l_temp_ftg_by_schedule_list.delete;

               END IF;

            END IF;

         END IF;/*NOT(G_NO_SCHEDULE_PIPELINE)*/

         l_apply_global_rule := false;
      ELSE
         --dbms_output.put_line('Apply Channel Rule');
         -- Apply the Channel Specific Rule

         -- First, check if any party will be fatigued based on the
         -- schedules which have already been executed
         l_channel_fatigue_start_date := p_preview_date - G_CHANNEL_NO_OF_DAYS;

         --dbms_output.put_line('Channel Rule Start Date = '|| to_char(l_channel_fatigue_start_date));

         IF (trunc(l_channel_fatigue_start_date) <= trunc(sysdate)) THEN
            -- The applicable start date for fatigue rules is in the past
            --dbms_output.put_line('Channel Rule Start Date Is a Past Date');

            -- Get the list of schedules fatigued by channel rule
            OPEN C_GET_CHANNEL_CONTACT_COUNT(l_channel_fatigue_start_date
                                             ,p_preview_date
                                            );
            FETCH C_GET_CHANNEL_CONTACT_COUNT
            BULK COLLECT
            INTO l_channel_party_list,l_channel_contact_count_list;
            CLOSE C_GET_CHANNEL_CONTACT_COUNT;

            --DBMS_OUTPUT.PUT_LINE('Before Line 1552');

            IF (l_channel_party_list.count > 0) THEN
         --dbms_output.put_line('Number of contacts made through channel rule = '||to_char(l_channel_party_list.count));

               -- Get the list of parties which are already fatigued
               FOR m in l_channel_party_list.FIRST .. l_channel_party_list.LAST
               LOOP
                  IF (l_channel_contact_count_list(m) >= G_Channel_Max_Contact)
                  THEN

                     -- Add this party to the fatigue list
                     j := l_temp_fatigue_party_list.count + 1;
                     l_temp_fatigue_party_list.extend;
                     l_temp_fatigue_party_list(j) := l_channel_party_list(m);

                  END IF;
               END LOOP;
            END IF;
                  --DBMS_OUTPUT.PUT_LINE('After Line 1552: Outside Loop');

            -- IF there are any fatigued parties found, get the fatigue by
            -- schedule list
            IF (l_temp_fatigue_party_list.count > 0) THEN
               --dbms_output.put_line('Number of fatigue entries made through channel rule = '||to_char(l_temp_fatigue_party_list.count));

               OPEN C_GET_CHANNEL_FATIGUE_BY(l_channel_fatigue_start_date,
                                             p_preview_date,
                                             l_temp_fatigue_party_list

                                            );
               FETCH C_GET_CHANNEL_FATIGUE_BY
               BULK COLLECT
               INTO l_temp_fatigue_by_party_list,
                    l_temp_ftg_by_schedule_list;
               CLOSE C_GET_CHANNEL_FATIGUE_BY;

               APPEND_GLOBAL_FATIGUE_LIST(l_temp_fatigue_party_list,
                                          l_temp_fatigue_by_party_list,
                                          l_temp_ftg_by_schedule_list
                                         );

               --Remove the ones already fatigued from the Original Party
               --List
               IF (l_temp_fatigue_party_list.count > 0) THEN
                  --dbms_output.put_line('G Party List Entry = '||to_char(G_PARTY_LIST.count));
                  DELETE_FROM_LIST(G_PARTY_LIST,l_temp_fatigue_party_list);
                  --dbms_output.put_line('After deleting fatigue entries G Party List Entry = '||to_char(G_PARTY_LIST.count));
               END IF;

               -- Reset the temporary variables, to be re-used
               l_temp_fatigue_party_list.delete;
               l_temp_fatigue_by_party_list.delete;
               l_temp_ftg_by_schedule_list.delete;

            END IF;

         END IF;

         -- Now, use the simulated information stored in AMS_TCOP_PRVW_CONTACTS
         -- to verify the contact information
         IF ( NOT(G_NO_SCHEDULE_PIPELINE) ) THEN

            OPEN C_GET_CHNL_SIMULATED_CONTACT(l_channel_fatigue_start_date,
                                                p_preview_date
                                               );
            FETCH C_GET_CHNL_SIMULATED_CONTACT
            BULK COLLECT
            INTO l_temp_party_list,
                 l_temp_contact_count_list;
            CLOSE C_GET_CHNL_SIMULATED_CONTACT;

            -- Use the Contact count of already executed schedules
            -- and contact count of the simulated schedules in tandem to decide
            -- fatigue
            IF (l_channel_party_list.count > 0) THEN

               FOR i in l_temp_party_list.FIRST
                        .. l_temp_party_list.LAST
               LOOP
                  -- Check if the party already exists in l_global_party_list
                  OPEN C_CHECK_PARTY_IN_CONTACT_LIST(l_channel_party_list,
                                                     l_temp_party_list(i)
                                                     );
                  FETCH C_CHECK_PARTY_IN_CONTACT_LIST
                  INTO l_party_id;
                  CLOSE C_CHECK_PARTY_IN_CONTACT_LIST;

                  IF (l_party_id is not null) THEN
                     IF (l_channel_party_list.count > 0 ) THEN
                     -- Get the count index
                     FOR j in l_channel_party_list.first ..
                              l_channel_party_list.last
                     LOOP
                        IF (l_channel_party_list(j) = l_party_id) THEN
                           -- if the total contact count exceeds fatigue limit
                           -- then get the contact count
                           IF ((l_channel_contact_count_list(j) +
                                l_temp_contact_count_list(i)) >=
                                G_channel_max_contact) THEN
                                -- this entry is fatigued
                                -- now, find out the fatigued by
                                -- it will be a combination of schedules
                                -- in AMS_TCOP_CONTACTS and
                                -- AMS_TCOP_PRVW_CONTACTS
                                OPEN GET_CSCH_FROM_CONTACTS_CHNL
                                   (l_party_id,
                                    l_channel_fatigue_start_date,
                                    sysdate
                                    );
                                 FETCH GET_CSCH_FROM_CONTACTS_CHNL
                                 BULK COLLECT
                                 INTO l_schedule_contact_list;
                                 CLOSE GET_CSCH_FROM_CONTACTS_CHNL;

                                 OPEN GET_SCHEDULE_FROM_PREVIEW_CHNL
                                    (l_party_id,
                                    l_channel_fatigue_start_date,
                                    p_preview_date,
                                    (G_channel_max_contact -
                                    l_channel_contact_count_list(j))
                                    );
                                 FETCH GET_SCHEDULE_FROM_PREVIEW_CHNL
                                 BULK COLLECT
                                 INTO l_schedule_prvw_list;

                                 CLOSE GET_SCHEDULE_FROM_PREVIEW_CHNL;

                                 -- Apply the fatigue List and the Fatigue By
                                 -- List
                                 l_index := l_temp_fatigue_party_list.count + 1;
                                 l_temp_fatigue_party_list.extend;
                                 l_temp_fatigue_party_list(l_index) :=
                                                                l_party_id;
                                 IF (l_schedule_contact_list.count > 0) THEN

                                    FOR k in l_schedule_contact_list.first
                                             .. l_schedule_contact_list.last
                                    loop
                                       l_index := l_temp_fatigue_by_party_list.count + 1;
                                       l_temp_fatigue_by_party_list.extend;
                                       l_temp_ftg_by_schedule_list.extend;

                                       l_temp_fatigue_by_party_list(l_index) :=
                                         l_party_id;
                                       l_temp_ftg_by_schedule_list(l_index)
                                          := l_schedule_contact_list(k);

                                    end loop;

                                 END IF;

                                 IF (l_schedule_prvw_list.count > 0) then

                                    FOR l in l_schedule_prvw_list.first
                                             .. l_schedule_prvw_list.last
                                    loop
                                       l_index := l_temp_fatigue_by_party_list.count + 1;
                                       l_temp_fatigue_by_party_list.extend;
                                       l_temp_ftg_by_schedule_list.extend;

                                       l_temp_fatigue_by_party_list(l_index) :=
                                         l_party_id;
                                       l_temp_ftg_by_schedule_list(l_index)
                                          := l_schedule_prvw_list(l);

                                    end loop;

                                 END IF;


                           END IF;
                        END IF;
                     END LOOP;
                     END IF;
                  ELSE
                     -- check if this party is fatigued or not
                     IF (l_temp_contact_count_list(i) >= G_Channel_Max_Contact)
                     THEN
                        -- add to the fatigue list
                        l_index := l_temp_fatigue_party_list.count + 1;
                        l_temp_fatigue_party_list.extend;
                        l_temp_fatigue_party_list(l_index) :=
                           l_temp_party_list(i);

                        -- add this entry to another list which will be used
                        -- to get the fatigue by in one shot
                        l_index := l_temp_ftg_prvw_party_list.count + 1;
                        l_temp_ftg_prvw_party_list.extend;
                        l_temp_ftg_prvw_party_list(l_index) :=
                           l_temp_party_list(i);

                     END IF;
                  END IF;


               END LOOP;

               IF (l_temp_ftg_prvw_party_list.count > 0 ) THEN
                  -- get the corresponding fatigue by
                  OPEN C_GET_CHANNEL_PRVW_FTG_BY(l_channel_fatigue_start_date,
                                            p_preview_date,
                                            l_temp_ftg_prvw_party_list);
                  FETCH C_GET_CHANNEL_PRVW_FTG_BY
                  BULK COLLECT
                  INTO l_temp_prvw_ftg_by_party,
                       l_temp_prvw_ftg_by_schedule;
                  CLOSE C_GET_CHANNEL_PRVW_FTG_BY;

                  IF (l_temp_prvw_ftg_by_party.count > 0 ) THEN

                     FOR l in l_temp_prvw_ftg_by_party.FIRST ..
                              l_temp_prvw_ftg_by_party.LAST
                     LOOP
                        -- Add these fatigue by entries to the l_temp_fatigue
                        -- entries
                        l_index := l_temp_fatigue_by_party_list.count + 1;
                        l_temp_fatigue_by_party_list.extend;
                        l_temp_ftg_by_schedule_list.extend;

                        l_temp_fatigue_by_party_list(l_index) :=
                          l_temp_prvw_ftg_by_party(l);
                        l_temp_ftg_by_schedule_list(l_index)
                           := l_temp_prvw_ftg_by_schedule(l);
                     END LOOP;

                  END IF;

               END IF;

               APPEND_GLOBAL_FATIGUE_LIST(l_temp_fatigue_party_list,
                                          l_temp_fatigue_by_party_list,
                                          l_temp_ftg_by_schedule_list
                                         );

               --Remove the ones already fatigued from the Original Party
               --List
               DELETE_FROM_LIST(G_PARTY_LIST,l_temp_fatigue_party_list);

               -- Reset the temporary variables, to be re-used
               l_temp_fatigue_party_list.delete;
               l_temp_fatigue_by_party_list.delete;
               l_temp_ftg_by_schedule_list.delete;

            ELSE
               -- no parties exist in the global list
               IF (l_temp_party_list.count > 0 ) THEN
                  FOR k in l_temp_party_list.first ..
                      l_temp_party_list.last
                  LOOP
                     -- check if any party is going to be fatigued
                     IF (l_temp_contact_count_list(k) >= G_Channel_Max_Contact)
                     THEN
                        -- Add to the fatigue list
                        l_index := l_temp_fatigue_party_list.count + 1;
                        l_temp_fatigue_party_list.extend;
                        l_temp_fatigue_party_list(l_index) :=
                           l_temp_party_list(k);
                     END IF;
                  END LOOP;
               END IF;
               IF (l_temp_fatigue_party_list.count > 0 ) THEN
                  -- Now, get the fatigue by
                  OPEN C_GET_CHANNEL_PRVW_FTG_BY(l_channel_fatigue_start_date,
                                                  p_preview_date,
                                                  l_temp_fatigue_party_list);
                  FETCH C_GET_CHANNEL_PRVW_FTG_BY
                  BULK COLLECT
                  INTO l_temp_fatigue_by_party_list,
                       l_temp_ftg_by_schedule_list;
                  CLOSE C_GET_CHANNEL_PRVW_FTG_BY;

                  APPEND_GLOBAL_FATIGUE_LIST(l_temp_fatigue_party_list,
                                             l_temp_fatigue_by_party_list,
                                             l_temp_ftg_by_schedule_list
                                            );

                  --Remove the ones already fatigued from the Original Party
                  --List
                  DELETE_FROM_LIST(G_PARTY_LIST,l_temp_fatigue_party_list);

                  -- Reset the temporary variables, to be re-used
                  l_temp_fatigue_party_list.delete;
                  l_temp_fatigue_by_party_list.delete;
                  l_temp_ftg_by_schedule_list.delete;

               END IF;

            END IF;


         END IF;/*NOT(G_NO_SCHEDULE_PIPELINE)*/

         l_apply_global_rule := true;
      END IF;

      loop_counter := loop_counter + 1;

      IF (loop_counter = 2) THEN
         EXIT;
      END IF;

   END LOOP;

   -- Get the next val from AMS_TCOP_PRVW_FATIGUE_S
   OPEN C_GET_NEXT_FATIGUE;
   FETCH C_GET_NEXT_FATIGUE
   INTO l_preview_id;
   CLOSE C_GET_NEXT_FATIGUE;

   l_fatigue_count := G_FATIGUE_PARTY_LIST.COUNT;
   -- Bulk Insert the relevant Tables
   INSERT INTO AMS_TCOP_PRVW_FATIGUE
   (
   PREVIEW_ID,
   REQUEST_ID,
   PREVIEW_DATE,
   FATIGUE_COUNT,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN
   )
   VALUES
   (
   l_preview_id,
   G_PRVW_REQUEST_ID,
   p_preview_date,
   l_fatigue_count,
   sysdate,
   FND_GLOBAL.USER_ID,
   sysdate,
   FND_GLOBAL.USER_ID,
   FND_GLOBAL.USER_ID
   );

   IF (G_FATIGUE_BY_PARTY_LIST.count > 0) THEN

      for k in G_FATIGUE_BY_PARTY_LIST.first .. G_FATIGUE_BY_PARTY_LIST.last
         loop
            OPEN C_GET_NEXT_FTG_BY;
            FETCH C_GET_NEXT_FTG_BY
            INTO l_ftg_by_id;
            CLOSE C_GET_NEXT_FTG_BY;

            l_fatigue_by_id_list.extend;
            l_fatigue_by_id_list(k) := l_ftg_by_id;

      end loop;
   END IF;
   --dbms_output.put_line('l_fatigue_by_id_list count ='|| to_char(l_fatigue_by_id_list.count));
            l_fatigue_detail_id_list.extend(G_FATIGUE_BY_PARTY_LIST.count);

   IF (G_FATIGUE_PARTY_LIST.COUNT > 0) THEN

      FOR i in G_FATIGUE_PARTY_LIST.FIRST .. G_FATIGUE_PARTY_LIST.LAST
      LOOP
         OPEN C_GET_NEXT_FTG_DTL;
         FETCH C_GET_NEXT_FTG_DTL
         INTO  l_fatigue_dtl_id;
         CLOSE C_GET_NEXT_FTG_DTL;

         l_fatigue_detail_list.extend;
         l_fatigue_detail_list(i) := l_fatigue_dtl_id;

         IF (G_FATIGUE_BY_PARTY_LIST.count > 0 ) THEN
            -- Set the correct data for AMS_TCOP_PRVW_FTG_BY
            FOR j IN G_FATIGUE_BY_PARTY_LIST.FIRST .. G_FATIGUE_BY_PARTY_LIST.LAST
            LOOP
               IF (G_FATIGUE_BY_PARTY_LIST(j) = G_FATIGUE_PARTY_LIST(i)) THEN
                  -- set the sequence Id
                  l_fatigue_detail_id_list(j) := l_fatigue_dtl_id;
               END IF;
            END LOOP;
         END IF;
      END LOOP;
   END IF;
   --dbms_output.put_line('Total Fatigue By = '||to_char(G_FATIGUE_BY_PARTY_LIST.count));
   --dbms_output.put_line('Total Fatigue By Schedule= '||to_char(G_FATIGUE_BY_SCHEDULE_LIST.count));

   IF (G_FATIGUE_PARTY_LIST.count > 0 ) THEN
      -- Create Fatigue Details Entries
      FORALL i IN G_FATIGUE_PARTY_LIST.FIRST .. G_FATIGUE_PARTY_LIST.LAST
      INSERT INTO AMS_TCOP_PRVW_FTG_DTLS
      (
        FATIGUE_DETAIL_ID,
        PREVIEW_ID,
        PARTY_ID,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN
      )
      VALUES
      (
         l_fatigue_detail_list(i),
         l_preview_id,
         G_FATIGUE_PARTY_LIST(i),
         sysdate,
         FND_GLOBAL.USER_ID,
         sysdate,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.USER_ID
      );
   END IF;

   IF (G_FATIGUE_BY_SCHEDULE_LIST.count > 0 ) THEN
   --dbms_output.put_line('Accessing 1 '||to_char(l_fatigue_by_id_list(363)));
   --dbms_output.put_line('Accessing 2 '||to_char(l_fatigue_detail_id_list(363)));
   --dbms_output.put_line('Accessing 3 '||to_char(g_fatigue_by_schedule_list(363)));
   -- Create entries in AMS_TCOP_PRVW_FTG_BY
   FORALL i in G_FATIGUE_BY_SCHEDULE_LIST.FIRST .. G_FATIGUE_BY_SCHEDULE_LIST.LAST
   INSERT INTO AMS_TCOP_PRVW_FTG_BY
   (
     FATIGUE_BY_ID,
     FATIGUE_DETAIL_ID,
     SCHEDULE_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN

   )
   VALUES
   (
      l_fatigue_by_id_list(i),
      l_fatigue_detail_id_list(i),
      G_FATIGUE_BY_SCHEDULE_LIST(i),
      sysdate,
      FND_GLOBAL.USER_ID,
      sysdate,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.USER_ID
   );

   END IF;

   -- Reset Global Variables
   G_PARTY_LIST.DELETE;
   G_FATIGUE_PARTY_LIST.DELETE;
   G_FATIGUE_BY_PARTY_LIST.DELETE;
   G_FATIGUE_BY_SCHEDULE_LIST.DELETE;


END CALCULATE_FATIGUE;
-- ===============================================================
-- Start of Comments
-- Name
-- PREVIEW_FATIGUE
--
-- Purpose
-- This procedure does preview projection for the target group
-- specified by the list_header_id
--
PROCEDURE   PREVIEW_FATIGUE(p_list_header_id  IN  NUMBER)
IS
   -- Get Schedule Details
   CURSOR C_GET_SCHEDULE_DETAILS
   IS
   SELECT CSCH.SCHEDULE_ID,CSCH.START_DATE_TIME,CSCH.ACTIVITY_ID,CAMP.ACTUAL_EXEC_END_DATE
   FROM   AMS_CAMPAIGN_SCHEDULES_B CSCH,
          AMS_ACT_LISTS ACT_LIST,ams_campaigns_vl CAMP
   WHERE  ACT_LIST.LIST_HEADER_ID = p_list_header_id
   AND    CSCH.SCHEDULE_ID = ACT_LIST.LIST_USED_BY_ID
   AND    ACT_LIST.LIST_USED_BY = 'CSCH'
   AND    ACT_LIST.LIST_ACT_TYPE='TARGET'
   AND CSCH.CAMPAIGN_ID=CAMP.CAMPAIGN_ID;

   -- Get the list of party Ids to be previewed
   CURSOR C_GET_PARTY_LIST
   IS
   SELECT PARTY_ID
   FROM AMS_LIST_ENTRIES
   WHERE LIST_HEADER_ID = p_list_header_id
   AND   ENABLED_FLAG='Y';

   -- Get Fatigue Rule Details
   CURSOR C_GET_FATIGUE_RULE_DETAILS(p_activity_id    NUMBER)
   IS
   SELECT RULE.RULE_TYPE RULE_TYPE,
          RULE.MAX_CONTACT_ALLOWED MAX_CONTACT_ALLOWED,
          PERIOD.NO_OF_DAYS NO_OF_DAYS
   FROM   AMS_TCOP_FR_PERIODS_B PERIOD,
          AMS_TCOP_FR_RULES_SETUP RULE
   WHERE  RULE.PERIOD_ID = PERIOD.PERIOD_ID
   AND (RULE.CHANNEL_ID IS NULL OR RULE.CHANNEL_ID = p_activity_id);

   l_total_preview_count   NUMBER;
   l_start_date_time       DATE;
   l_schedule_id           NUMBER;
   l_camp_end_date_time	   DATE;
   PROCEDURE_NAME CONSTANT VARCHAR2(30) := 'PREVIEW_FATIGUE';

BEGIN

    write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_INPUT_PARAMS',
                       'INPUT List Header Id = '||to_char(p_list_header_id)
                      );
   -- Get the list of parties to be previewed
   OPEN C_GET_PARTY_LIST;
   FETCH C_GET_PARTY_LIST
   BULK COLLECT
   INTO G_PARTY_TGROUP_LIST;
   CLOSE C_GET_PARTY_LIST;

   l_total_preview_count := G_PARTY_TGROUP_LIST.COUNT;



   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_PREVIEW_COUNT',
                       'Total Preview Count ='||to_char(l_total_preview_count)
                      );

   -- Create Preview Request

   --CREATE_PREVIEW_REQUEST(p_list_header_id,l_total_preview_count);

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'AFTER_PREVIEW_REQUEST_CREATION',
                       'Preview request is already created'
                      );

   -- Get schedule details
   OPEN C_GET_SCHEDULE_DETAILS;
   FETCH C_GET_SCHEDULE_DETAILS
   INTO G_schedule_id,l_start_date_time,G_activity_id,l_camp_end_date_time;
   CLOSE C_GET_SCHEDULE_DETAILS;



   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_SCHEDULE_DETAILS',
                       'Schedule Id = '||to_char(G_SCHEDULE_ID)
                      );

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_SCHEDULE_DETAILS',
                       'Schedule Start Date ='||to_char(l_start_date_time)
                      );

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_SCHEDULE_DETAILS',
                       'Activity Id = '||to_char(G_Activity_Id)
                      );

   -- Calculate Preview Date Range and update global variable G_PRVW_DATE_LIST


 --  CALCULATE_PREVIEW_DATE_RANGE(l_start_date_time);
 CALCULATE_PREVIEW_DATE_RANGE(l_start_date_time,l_camp_end_date_time);




   -- Get Fatigue Rule Information and update Global Variables
   FOR C1 in C_GET_FATIGUE_RULE_DETAILS(G_activity_id)
   LOOP
      IF (C1.RULE_TYPE = 'GLOBAL') THEN
         G_GLOBAL_MAX_CONTACT := C1.MAX_CONTACT_ALLOWED;
         G_GLOBAL_NO_OF_DAYS := C1.NO_OF_DAYS;

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'PRINT_GLOBAL_RULE',
                             'Global Rule: Maximum Contact Allowed = '||to_char(g_global_max_contact)||' in '||to_char(G_GLOBAL_NO_OF_DAYS)||' days.'
                            );
      END IF;

      IF (C1.RULE_TYPE = 'CHANNEL_BASED') THEN
         G_CHANNEL_MAX_CONTACT := C1.MAX_CONTACT_ALLOWED;
         G_CHANNEL_NO_OF_DAYS := C1.NO_OF_DAYS;


         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'PRINT_CHANNEL_RULE',
                             'Global Rule: Maximum Contact Allowed = '||to_char(g_channel_max_contact)||' in '||to_char(G_CHANNEL_NO_OF_DAYS)||' days.'
                            );
      END IF;

   END LOOP;

   -- Now, simulate future contact. Basically as if the overlapping
   -- target group members are being contacted by the schedules in the pipeline
   G_PREVIEW_START_DATE := G_PRVW_DATE_LIST(1);

   G_PREVIEW_END_DATE := G_PRVW_DATE_LIST(G_PRVW_DATE_LIST.COUNT);


   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_PREVIEW_START_DATE',
                       'Preview Start Date ='||to_char(G_PREVIEW_START_DATE)
                      );

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'PRINT_PREVIEW_END_DATE',
                       'Preview End Date ='||to_char(G_PREVIEW_END_DATE)
                      );

   SIMULATE_FUTURE_CONTACTS(G_PREVIEW_START_DATE,
                            G_PREVIEW_END_DATE,
                            p_list_header_id
                           ) ;
   -- Calculate Fatigue for each date
   FOR i in G_PRVW_DATE_LIST.FIRST .. G_PRVW_DATE_LIST.LAST
   LOOP
      CALCULATE_FATIGUE(G_PRVW_DATE_LIST(i),p_list_header_id);

   END LOOP;



   -- Finally Update the Status to COMPLETE
   UPDATE AMS_TCOP_PRVW_REQUESTS
   SET STATUS='COMPLETE',
	   LAST_UPDATE_DATE = sysdate,
	   LAST_UPDATED_BY = FND_GLOBAL.USER_ID
   WHERE REQUEST_ID=G_PRVW_REQUEST_ID;

   DELETE FROM AMS_TCOP_PRVW_CONTACTS
   WHERE PREVIEW_ID = G_PRVW_REQUEST_ID;

   DELETE FROM AMS_TCOP_PRVW_FATIGUE
   WHERE
   REQUEST_ID IN
   (
	   SELECT REQUEST_ID FROM AMS_TCOP_PRVW_REQUESTS
	   WHERE LIST_HEADER_ID = p_list_header_id
	   AND REQUEST_ID <> G_PRVW_REQUEST_ID
   );


   DELETE FROM AMS_TCOP_PRVW_REQUESTS
   WHERE LIST_HEADER_ID = p_list_header_id
   AND REQUEST_ID <> G_PRVW_REQUEST_ID;

END PREVIEW_FATIGUE;

-- ===============================================================
-- Start of Comments
-- Name
-- REFRESH
--
-- Purpose
-- This function is called from Business Event raised through UI
-- ===============================================================
FUNCTION REFRESH(p_subscription_guid   IN       RAW,
                 p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2
IS
   --Local Variables
   l_list_header_id     NUMBER;

BEGIN
   -- Get the Value of LIST_HEADER_ID
   l_list_header_id := p_event.getValueForParameter('LIST_HEADER_ID');


   G_PRVW_REQUEST_ID := p_event.getValueForParameter('PREVIEW_REQUEST_ID');

G_GLOBAL_NO_OF_PERIOD := p_event.getValueForParameter('GLOBAL_NO_OF_PERIOD');

   -- First Update the Status to ACTIVE
   UPDATE AMS_TCOP_PRVW_REQUESTS
   SET STATUS='ACTIVE',
   LAST_UPDATE_DATE = sysdate,
   LAST_UPDATED_BY = FND_GLOBAL.USER_ID
   WHERE REQUEST_ID=G_PRVW_REQUEST_ID;


   PREVIEW_FATIGUE(l_list_header_id);

        return 'SUCCESS';

EXCEPTION

   WHEN OTHERS THEN

      WF_CORE.CONTEXT('AMS_TCOP_PREVIEW','REFRESH',
                        p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');

      -- First Update the Status to ERROR
		UPDATE AMS_TCOP_PRVW_REQUESTS
		SET STATUS='ERROR',
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		WHERE REQUEST_ID=G_PRVW_REQUEST_ID;

		RETURN 'ERROR';

END REFRESH;


-- ===============================================================
-- Start of Comments
-- Name
-- REFRESH
--
-- Purpose
-- This function is called from Business Event raised through
-- Post Target Group Generation Business Event
-- ===============================================================
FUNCTION FORCE_REFRESH(p_subscription_guid   IN       RAW,
                 p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2
IS

    CURSOR C_PREVIEW_SIZE (p_list_header_id NUMBER)
    IS
    SELECT COUNT(PARTY_ID)
    FROM AMS_LIST_ENTRIES
    WHERE LIST_HEADER_ID = p_list_header_id
    AND   ENABLED_FLAG='Y';

   --Local Variables
   l_list_header_id     NUMBER;
   l_total_preview_count   NUMBER;

BEGIN
   -- Get the Value of LIST_HEADER_ID
   l_list_header_id := p_event.getValueForParameter('LIST_HEADER_ID');
   -- Get the Preview Size
    OPEN C_PREVIEW_SIZE (l_list_header_id);
	FETCH C_PREVIEW_SIZE
	INTO l_total_preview_count;
	CLOSE C_PREVIEW_SIZE;



	-- Create Preview Request
	CREATE_PREVIEW_REQUEST(l_list_header_id,l_total_preview_count);

   -- First Update the Status to ACTIVE



   UPDATE AMS_TCOP_PRVW_REQUESTS
   SET STATUS='ACTIVE',
   LAST_UPDATE_DATE = sysdate,
   LAST_UPDATED_BY = FND_GLOBAL.USER_ID
   WHERE REQUEST_ID=G_PRVW_REQUEST_ID;
   PREVIEW_FATIGUE(l_list_header_id);
   return 'SUCCESS';

EXCEPTION

   WHEN OTHERS THEN

      WF_CORE.CONTEXT('AMS_TCOP_PREVIEW','REFRESH',
                        p_event.getEventName( ), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');

      -- First Update the Status to ERROR
		UPDATE AMS_TCOP_PRVW_REQUESTS
		SET STATUS='ERROR',
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = FND_GLOBAL.USER_ID
		WHERE REQUEST_ID=G_PRVW_REQUEST_ID;

		RETURN 'ERROR';

END FORCE_REFRESH;


-- ===============================================================
-- Start of Comments
-- Name
-- GENERATE_PREVIEW
--
-- Purpose
-- This function is called for preprocessing the preview request
-- handling through Preview UI.
-- Parameters
-- p_list_header_id IN ==>  The List Header Id for which preview
--                          needs to be generated
-- ===============================================================
PROCEDURE   REGENERATE_PREVIEW( p_list_header_id  IN  NUMBER)
IS

    CURSOR C_LIST_PRVW_REQUEST_STATUS
    IS
    SELECT REQUEST_ID, STATUS
    FROM AMS_TCOP_PRVW_REQUESTS
    WHERE LIST_HEADER_ID = p_list_header_id
    and REQUEST_ID = (select max(REQUEST_ID) from AMS_TCOP_PRVW_REQUESTS where LIST_HEADER_ID = p_list_header_id);

    CURSOR C_PREVIEW_SIZE
    IS
    SELECT COUNT(PARTY_ID)
    FROM AMS_LIST_ENTRIES
    WHERE LIST_HEADER_ID = p_list_header_id
    AND   ENABLED_FLAG='Y';

   l_total_preview_count   NUMBER;
   l_request_id NUMBER;
   l_status VARCHAR2(30);
   l_raise_event_flag BOOLEAN;

   l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
   l_event_key VARCHAR2(30);

BEGIN

    l_request_id := -1;
    l_status := NULL;
    l_raise_event_flag := TRUE;

    -- Get The Request Id and the Status
    OPEN C_LIST_PRVW_REQUEST_STATUS;
    FETCH C_LIST_PRVW_REQUEST_STATUS
    INTO l_request_id,l_status;
    CLOSE C_LIST_PRVW_REQUEST_STATUS;

    IF (l_request_id = -1)
    THEN
        l_raise_event_flag := TRUE;
    END IF;

    IF ((l_status = 'NEW') OR (l_status = 'ACTIVE'))
    THEN
        BEGIN
            l_raise_event_flag := FALSE;
        END;
    ELSE
        l_raise_event_flag := TRUE;
    END IF;

    IF (l_raise_event_flag = TRUE)
    THEN

        BEGIN
            -- Get the Preview Size
            OPEN C_PREVIEW_SIZE;
            FETCH C_PREVIEW_SIZE
            INTO l_total_preview_count;
            CLOSE C_PREVIEW_SIZE;


            -- Create Preview Request
            CREATE_PREVIEW_REQUEST(p_list_header_id,l_total_preview_count);


			wf_event.AddParameterToList(p_name => 'LIST_HEADER_ID',
										p_value => to_char(p_list_header_id),
										p_parameterlist => l_parameter_list);

			wf_event.AddParameterToList(p_name => 'PREVIEW_REQUEST_ID',
										p_value => to_char(G_PRVW_REQUEST_ID),
										p_parameterlist => l_parameter_list);


			select to_char(sysdate, 'YYYYMMDDHH24MISS') into l_event_key from dual;

			l_event_key := to_char(p_list_header_id) || '_' || l_event_key;

			wf_event.raise( p_event_name => 'oracle.apps.ams.tcop.RefreshPreview',
							p_event_key => l_event_key,
							p_parameters => l_parameter_list);

			l_parameter_list.DELETE;

			commit;


        END;

    END IF;


END REGENERATE_PREVIEW;

--- Added


-- ===============================================================
-- Start of Comments
-- Name
-- GENERATE_PREVIEW
--
-- Purpose
-- This function is called for preprocessing the preview request
-- handling through Preview UI.
-- Parameters
-- p_list_header_id IN ==>  The List Header Id for which preview
--                          needs to be generated
-- ===============================================================
PROCEDURE   REGENERATE_PREVIEW_DAYS( p_list_header_id  IN  NUMBER , p_no_of_days IN NUMBER)
IS

    CURSOR C_LIST_PRVW_REQUEST_STATUS
    IS
    SELECT REQUEST_ID, STATUS
    FROM AMS_TCOP_PRVW_REQUESTS
    WHERE LIST_HEADER_ID = p_list_header_id
    and REQUEST_ID = (select max(REQUEST_ID) from AMS_TCOP_PRVW_REQUESTS where LIST_HEADER_ID = p_list_header_id);

    CURSOR C_PREVIEW_SIZE
    IS
    SELECT COUNT(PARTY_ID)
    FROM AMS_LIST_ENTRIES
    WHERE LIST_HEADER_ID = p_list_header_id
    AND   ENABLED_FLAG='Y';

   l_total_preview_count   NUMBER;
   l_request_id NUMBER;
   l_status VARCHAR2(30);
   l_raise_event_flag BOOLEAN;

   l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
   l_event_key VARCHAR2(30);

BEGIN

    l_request_id := -1;
    l_status := NULL;
    l_raise_event_flag := TRUE;

    G_GLOBAL_NO_OF_PERIOD  :=  p_no_of_days;
    -- Get The Request Id and the Status
    OPEN C_LIST_PRVW_REQUEST_STATUS;
    FETCH C_LIST_PRVW_REQUEST_STATUS
    INTO l_request_id,l_status;
    CLOSE C_LIST_PRVW_REQUEST_STATUS;


    IF (l_request_id = -1)
    THEN
        l_raise_event_flag := TRUE;
    END IF;

    IF ((l_status = 'NEW') OR (l_status = 'ACTIVE'))
    THEN
        BEGIN
            l_raise_event_flag := FALSE;
        END;
    ELSE
        l_raise_event_flag := TRUE;
    END IF;

    IF (l_raise_event_flag = TRUE)
    THEN

        BEGIN
            -- Get the Preview Size
            OPEN C_PREVIEW_SIZE;
            FETCH C_PREVIEW_SIZE
            INTO l_total_preview_count;
            CLOSE C_PREVIEW_SIZE;


            -- Create Preview Request


            CREATE_PREVIEW_REQUEST(p_list_header_id,l_total_preview_count);


			wf_event.AddParameterToList(p_name => 'LIST_HEADER_ID',
										p_value => to_char(p_list_header_id),
										p_parameterlist => l_parameter_list);

			wf_event.AddParameterToList(p_name => 'PREVIEW_REQUEST_ID',
										p_value => to_char(G_PRVW_REQUEST_ID),
										p_parameterlist => l_parameter_list);

			wf_event.AddParameterToList(p_name => 'GLOBAL_NO_OF_PERIOD',
										p_value => to_char(G_GLOBAL_NO_OF_PERIOD),
										p_parameterlist => l_parameter_list);

			select to_char(sysdate, 'YYYYMMDDHH24MISS') into l_event_key from dual;

			l_event_key := to_char(p_list_header_id) || '_' || l_event_key;

			wf_event.raise( p_event_name => 'oracle.apps.ams.tcop.RefreshPreview',
							p_event_key => l_event_key,
							p_parameters => l_parameter_list);

			l_parameter_list.DELETE;

			commit;


        END;

    END IF;


END REGENERATE_PREVIEW_DAYS;

END AMS_TCOP_PREVIEW;

/
