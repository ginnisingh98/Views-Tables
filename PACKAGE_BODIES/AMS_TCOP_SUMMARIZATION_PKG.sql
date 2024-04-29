--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_SUMMARIZATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_SUMMARIZATION_PKG" AS
/* $Header: amsvtcmb.pls 115.2 2004/05/18 11:20:36 mayjain noship $ */

-- Global Constants that will be used through out the package
LOG_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
LOG_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
LOG_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
LOG_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
LOG_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
LOG_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

TYPE     NUMBER_ARRAY IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_SUMMARIZATION_PKG
-- Purpose
--
-- This package contains all the program units for summarizing
-- contacts made through fatigue schedules
--
-- History
--
-- NOTE
--
-- End of Comments
-- Private procedure to write debug message to FND_LOG table
--
PROCEDURE write_debug_message(p_log_level       NUMBER,
                              p_procedure_name  VARCHAR2,
                              p_label           VARCHAR2,
                              p_text            VARCHAR2
                              )
IS
   l_module_name  VARCHAR2(400);
   DELIMETER    CONSTANT   VARCHAR2(1) := '.';
   LABEL_PREFIX CONSTANT   VARCHAR2(30) := 'TCOPContactSummarization';

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

   AMS_UTILITY_PVT.write_conc_log('['||G_PACKAGE_NAME||DELIMETER||p_procedure_name||DELIMETER||LABEL_PREFIX||'-'||p_label||']'||p_text);
   --dbms_output.put_line(p_label||': '||p_text);


END write_debug_message;
-- ===============================================================
-- Start of Comments
-- Name
-- DELETE_CONTACT_SUMMARIZATION
--
-- Purpose
-- This procedure deletes contact summarization information for all the
-- parties present in the given a list
--
PROCEDURE   DELETE_CONTACT_SUMMARIZATION(p_list_header_id   NUMBER,
                                         p_activity_id         NUMBER
                                        )
IS
BEGIN

   delete from ams_tcop_contact_sum_dtl
   where contact_summary_id in
   (select summary.contact_summary_id
    from   ams_tcop_contact_summary summary,
           ams_list_entries list_entry
    where list_entry.enabled_flag = 'Y'
    and   list_entry.list_header_id = p_list_header_id
    and   list_entry.party_id = summary.party_id );

   delete from ams_tcop_contact_summary
   where party_id in
   (select party_id
    from   ams_list_entries
    where enabled_flag = 'Y'
    and   list_header_id = p_list_header_id);

    -- Delete the records for (party_id,media_id) combination
    delete from ams_tcop_channel_sum_dtl
    where channel_summary_id in
    (select summary.channel_summary_id
     from   ams_tcop_channel_summary summary,
            ams_list_entries list_entry
     where  list_entry.party_id = summary.party_id
     and    list_entry.list_header_id = p_list_header_id
     and    summary.media_id = p_activity_id
     and    list_entry.enabled_flag = 'Y');

    delete from ams_tcop_channel_summary
    where party_id in
    (select summary.PARTY_ID
     from   ams_tcop_channel_summary summary,
            ams_list_entries list_entry
     where  list_entry.party_id = summary.party_id
     and    list_entry.list_header_id = p_list_header_id
     and    summary.media_id = p_activity_id
     and    list_entry.enabled_flag = 'Y');


END DELETE_CONTACT_SUMMARIZATION;

-- ===============================================================
-- Start of Comments
-- Name
-- SUMMARIZE_LIST_CONTACTS
--
-- Purpose
-- This procedure considers the set of parties available in the given Target Group.
-- For these parties, it summarizes the number of contacts made by fatiguing schedules in the periods
-- specified in the Fatigue Rule Setup
--
PROCEDURE SUMMARIZE_LIST_CONTACTS( p_list_header_id NUMBER,
                                   p_activity_id    NUMBER
                                 )
IS

   -- Check if there are any global rules
   CURSOR C_GET_GLOBAL_RULE
   IS
   SELECT RULE.RULE_ID
          ,PERIOD.NO_OF_DAYS
   FROM   AMS_TCOP_FR_RULES_SETUP RULE
         ,AMS_TCOP_FR_PERIODS_B period
   WHERE  RULE.RULE_TYPE='GLOBAL'
   AND    RULE.ENABLED_FLAG = 'Y'
   AND    RULE.PERIOD_ID = PERIOD.PERIOD_ID;

   -- Check if there are any Channel Rules for activity_id of the schedule
   CURSOR C_GET_CHANNEL_RULE
   IS
   SELECT rule.RULE_ID,period.no_of_days
   FROM   AMS_TCOP_FR_RULES_SETUP rule
          ,AMS_TCOP_FR_PERIODS_B period
   WHERE  rule.RULE_TYPE = 'CHANNEL_BASED'
   AND    rule.CHANNEL_ID = p_activity_id
   AND    rule.ENABLED_FLAG = 'Y'
   AND    rule.period_id = period.period_id;

   -- Get the list of fatiguing schedules along with channel information
   -- which contacted parties in the timeframe specified in the Channel Rule
   CURSOR C_GET_CHANNEL_SUMMARY(p_list_header_id   NUMBER,
                                p_activity_id     NUMBER,
                                p_no_of_days  NUMBER)
   IS
   SELECT contact.party_id,
          contact.schedule_id
   FROM AMS_TCOP_CONTACTS contact, AMS_LIST_ENTRIES list_entry
   WHERE contact.MEDIA_ID = p_activity_id
   AND (contact_date between (sysdate - p_no_of_days) and sysdate)
   AND contact.PARTY_ID = list_entry.PARTY_ID
   AND list_entry.list_header_id = p_list_header_id
   AND list_entry.enabled_flag = 'Y'
   order by contact.party_id;

   -- Cursor to select the list of fatiguing schedules which contacted parties
   -- during the time frame set in the Global Rule
   CURSOR C_GET_GLOBAL_SUMMARY (p_list_header_id  NUMBER, p_no_of_days NUMBER)
   IS
   SELECT contact.party_id,
          contact.schedule_id
   FROM AMS_TCOP_CONTACTS contact, AMS_LIST_ENTRIES list_entry
   WHERE (contact_date between (sysdate - p_no_of_days) and sysdate)
   AND contact.PARTY_ID = list_entry.PARTY_ID
   AND list_entry.list_header_id = p_list_header_id
   AND list_entry.enabled_flag = 'Y'
   order by contact.party_id;


   CURSOR C_GET_CONTACT_SUM_NEXT_SEQ
   IS
   SELECT AMS_TCOP_CONTACT_SUM_S.nextval
   FROM DUAL;

   --CURSOR C_GET_CONTACT_SUM_DTL_NEXT_SEQ
   --IS
   --SELECT AMS_TCOP_CONTACT_SUM_DTL_S.nextval
   --FROM DUAL;

   CURSOR C_GET_CHNL_SUM_NEXT_SEQ
   IS
   SELECT AMS_TCOP_CHNL_SUM_S.nextval
   FROM DUAL;

   CURSOR C_GET_CHNL_SUM_DTL_NEXT_SEQ
   IS
   SELECT AMS_TCOP_CHNL_SUM_DTL_S.nextval
   FROM DUAL;

   TYPE NUMBER_ARRAY IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   -- Get the list of schedules which fatigued the parties

   -- Local Variables
   l_rule_id         NUMBER;
   l_last_party_id   NUMBER;
   l_media_id        NUMBER;
   j                 NUMBER;
   k                 NUMBER;
   l_sequence_id     NUMBER;
   l_total_contact_count NUMBER;
   l_chnl_sum_id     NUMBER;
   l_contact_sum_id  NUMBER;
   l_total_fatigue_contact   NUMBER;
   l_num_days_global_rule  NUMBER;
   l_last_media_id   NUMBER;
   l_num_days_channel_rule   NUMBER;

   -- Local Arrays
   l_temp_party_id_list     NUMBER_ARRAY;
   l_schedule_id_list  NUMBER_ARRAY;
   l_contact_count_list  NUMBER_ARRAY;
   l_temp_media_id_list     NUMBER_ARRAY;
   l_temp_rule_id_list      NUMBER_ARRAY;
   l_chnl_sum_id_list    NUMBER_ARRAY;
   L_CHNL_SUM_DTL_ID_LIST  NUMBER_ARRAY;
   L_CHNL_SUM_ID_LIST_FOR_DTL NUMBER_ARRAY;
   l_contact_sum_id_list    NUMBER_ARRAY;
   --l_contact_sum_id_dtl_list    NUMBER_ARRAY;
   l_contact_sum_id_list_for_dtl    NUMBER_ARRAY;
   l_total_count_list    NUMBER_ARRAY;
   l_final_party_id_list   NUMBER_ARRAY;
   l_final_media_id_list NUMBER_ARRAY;
   l_final_rule_id_list  NUMBER_ARRAY;
   l_final_schedule_id_list   NUMBER_ARRAY;


   PROCEDURE_NAME   CONSTANT        VARCHAR2(30) := 'SUMMARIZE_LIST_CONTACTS';

BEGIN

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'BEGIN',
                       'Beginning Procedure'
                      );

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'WRITE_INPUT_PARAMETERS',
                       'Summarize Contacts for Target Group. List Header Id = '||to_char(p_list_header_id)
                      );

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'Before Calling Delete_Contact_Summarization',
                       'Before Calling Delete_Contact_Summarization'
                      );
   -- Delete from Summarization Tables all the previous entries
   DELETE_CONTACT_SUMMARIZATION(p_list_header_id,p_activity_id);

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'After calling DELETE_CONTACT_SUMMARIZATION ',
                       'All the entries deleted from summarization tables'
                      );

   -- Check if there are any Global Rules
   OPEN C_GET_GLOBAL_RULE;
   FETCH C_GET_GLOBAL_RULE
   INTO  l_rule_id,l_num_days_global_rule;
   CLOSE C_GET_GLOBAL_RULE;

   IF (l_rule_id IS NOT NULL) THEN

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'Global Rule Id is not null',
                          'Global Rule Id = '||to_char(l_rule_id)
                         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'Global Rule Id is not null',
                          ' No of days specified in Global Rule = '||to_char(l_num_days_global_rule)
                         );
      -- A Global Fatigue Rule is setup in the system
      -- Get the Total Number of Fatiguing Contacts made in the time frame
      -- specified in the Global Fatigue Rule
      OPEN C_GET_GLOBAL_SUMMARY(p_list_header_id,l_num_days_global_rule);
      FETCH C_GET_GLOBAL_SUMMARY
      BULK COLLECT INTO l_temp_party_id_list,l_schedule_id_list;
      CLOSE C_GET_GLOBAL_SUMMARY;

      l_total_fatigue_contact := l_temp_party_id_list.COUNT;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'AFTER BULK FETCH FROM C_GET_GLOBAL_SUMMARY CURSOR ',
                          'Total Number of Fatiguing entries = '||to_char(l_total_fatigue_contact)
                         );

      -- Get the List of Schedules which contacted them in the time period
      -- specified in the Global Fatigue Rule
      IF (l_total_fatigue_contact > 0) THEN
         -- Populate arrays to do a Bulk insert for AMS_TCOP_CONTACT_SUMMARY

         -- Initialize Loop Variables
         l_last_party_id := 0;
         l_total_contact_count := 0;
         FOR i IN l_temp_party_id_list.FIRST .. l_temp_party_id_list.LAST
         LOOP
            IF (l_temp_party_id_list(i) <> l_last_party_id) THEN

               -- Set the Party Id
               j := l_final_party_id_list.COUNT + 1;
               l_final_party_id_list(j) := l_temp_party_id_list(i);

               -- Set the contact_summary_id
               OPEN C_GET_CONTACT_SUM_NEXT_SEQ;
               FETCH C_GET_CONTACT_SUM_NEXT_SEQ
               INTO  l_contact_sum_id;
               CLOSE C_GET_CONTACT_SUM_NEXT_SEQ;
               l_contact_sum_id_list(j) := l_contact_sum_id;

               -- Assign the total contact count
               l_contact_count_list(j) := 1;

            ELSE

               -- Increment the total contact count
               l_contact_count_list(j) := l_contact_count_list(j) + 1;

            END IF;

            -- Set the value for AMS_TCOP_CONTACT_SUM_DTL.contact_summary_id
            l_contact_sum_id_list_for_dtl(i) := l_contact_sum_id;

            --OPEN C_GET_CONTACT_SUM_DTL_NEXT_SEQ;
            --FETCH C_GET_CONTACT_SUM_DTL_NEXT_SEQ
            --INTO l_sequence_id;
            --CLOSE C_GET_CONTACT_SUM_DTL_NEXT_SEQ;

            -- AMS_TCOP_CONTACT_SUM_DTL.summary_dtl_id
            --l_contact_sum_id_dtl_list (i) := l_sequence_id;


            -- set Loop variables
            l_last_party_id := l_temp_party_id_list(i);

         END LOOP;

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'BEFORE BULK UPLOADING AMS_TCOP_CONTACT_SUMMARY',
                             'Total Number of records to be loaded = '||to_char(l_final_party_id_list.COUNT));

         -- Do Bulk Insert into AMS_TCOP_CONTACT_SUMMARY
         FORALL i in l_final_party_id_list.FIRST .. l_final_party_id_list.LAST
         INSERT INTO
         AMS_TCOP_CONTACT_SUMMARY
         (
            CONTACT_SUMMARY_ID,
            RULE_ID,
            PARTY_ID,
            TOTAL_CONTACTS,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
         )
         VALUES
         (
            l_contact_sum_id_list(i),
            l_rule_id,
            l_final_party_id_list(i),
            l_contact_count_list(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
         );

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'AFTER BULK UPLOADING AMS_TCOP_CONTACT_SUMMARY',
                             'BULK UPLOAD COMPLETED SUCCESSFULLY');

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'BEFORE BULK UPLOADING AMS_TCOP_CONTACT_SUM_DTL',
                             'Total Number of records to be loaded = '||to_char(l_schedule_id_list.COUNT));

         -- Do Bulk Insert into AMS_TCOP_CONTACT_SUM_DTL
         FORALL i in l_schedule_id_list.FIRST .. l_schedule_id_list.LAST
         INSERT INTO
         AMS_TCOP_CONTACT_SUM_DTL
         (
            SUMMARY_DTL_ID,
            CONTACT_SUMMARY_ID,
            SCHEDULE_ID,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
         )
         VALUES
         (
            --l_contact_sum_id_dtl_list(i),
	    AMS_TCOP_CONTACT_SUM_DTL_S.nextval,
            l_contact_sum_id_list_for_dtl(i),
            l_schedule_id_list(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
         );

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'AFTER BULK UPLOADING AMS_TCOP_CONTACT_SUM_DTL',
                             'BULK UPLOAD COMPLETED SUCCESSFULLY');

      END IF; /*  (l_party_id_list.COUNT = 0) */


   END IF; /* Global Rule Check */

   -- Some of ther collection variables will be re-used, so reset them
   l_temp_party_id_list.DELETE;
   l_contact_count_list.DELETE;
   l_final_party_id_list.DELETE;
   l_schedule_id_list.DELETE;



   OPEN C_GET_CHANNEL_RULE;
   FETCH C_GET_CHANNEL_RULE
   INTO l_rule_id,l_num_days_channel_rule;
   CLOSE C_GET_CHANNEL_RULE;

   IF (l_rule_id IS NOT NULL) THEN
      -- Get the list of parties and contacted channel information
      -- within the timeperiod specified in the channel rule
      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'CHANNEL RULE NOT NULL',
                          'Channel Rule Id = '||to_char(l_rule_id)
                         );

      OPEN C_GET_CHANNEL_SUMMARY(p_list_header_id,p_activity_id,
                                 l_num_days_channel_rule);
      FETCH C_GET_CHANNEL_SUMMARY
      BULK COLLECT INTO
         l_temp_party_id_list,
         l_schedule_id_list;
      CLOSE C_GET_CHANNEL_SUMMARY;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'AFTER BULK FETCH FROM C_GET_CHANNEL_SUMMARY CURSOR',
                          'Total Number of contacts by channel = '||to_char(l_temp_party_id_list.COUNT));

      IF (l_temp_party_id_list.COUNT > 0) THEN
         -- There are some parties contacted by schedules
         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'CHANNEL CONTACT COUNT GREATER THAN ZERO',
                             'Total number of contacts made by channel greater than zero and the count = '||to_char(l_temp_party_id_list.COUNT)
                             );

         -- Initialize some of the Loop variables
         l_last_party_id := -1;
         l_last_media_id := -1;

         FOR i IN l_temp_party_id_list.FIRST .. l_temp_party_id_list.LAST
         LOOP
            IF ( (l_temp_party_id_list(i)  = l_last_party_id) ) THEN

               -- Increment the count
               l_contact_count_list(j) := l_contact_count_list(j) +1;


            ELSE
               -- Initialize the Arrays to do a bulk upload for AMS_TCOP_CHANNEL_SUMMARY
               j := l_final_party_id_list.count + 1;
               l_final_party_id_list (j) := l_temp_party_id_list(i);
               l_contact_count_list(j) := 1; -- the count starts

               --  Set the sequence value for channel_summary_id
               OPEN C_GET_CHNL_SUM_NEXT_SEQ;
               FETCH C_GET_CHNL_SUM_NEXT_SEQ INTO l_chnl_sum_id;
               CLOSE C_GET_CHNL_SUM_NEXT_SEQ;

               l_chnl_sum_id_list(j) := l_chnl_sum_id;

            END IF;

               -- Set Values for AMS_TCOP_CHANNEL_SUM_DTL
               k := l_chnl_sum_dtl_id_list.count + 1;

               -- Set the sequence value for channel_sum_dtl_id
               OPEN C_GET_CHNL_SUM_DTL_NEXT_SEQ;
               FETCH C_GET_CHNL_SUM_DTL_NEXT_SEQ INTO l_sequence_id;
               CLOSE C_GET_CHNL_SUM_DTL_NEXT_SEQ;

               -- Set values for bulk loading of AMS_TCOP_CHANNEL_SUM_DTL
               l_chnl_sum_dtl_id_list(k) := l_sequence_id;
               l_chnl_sum_id_list_for_dtl(k) := l_chnl_sum_id;

               -- Set the last party id and media id
               l_last_party_id := l_temp_party_id_list(i);


         END LOOP;

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'BEFORE_BULK_UPLOADING_AMS_TCOP_CHANNEL_SUMMARY',
                             'Total number of record uploaded = '||to_char(l_final_party_id_list.count)
                            );

            /* Bulk Upload AMS_TCOP_CHANNEL_SUMMARY */
            FORALL i in l_final_party_id_list.FIRST .. l_final_party_id_list.LAST
            INSERT INTO
            AMS_TCOP_CHANNEL_SUMMARY
            (
               CHANNEL_SUMMARY_ID,
               RULE_ID,
               PARTY_ID,
               MEDIA_ID,
               TOTAL_CONTACTS,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               l_chnl_sum_id_list(i),
               l_rule_id,
               l_final_party_id_list(i),
               p_activity_id,
               l_contact_count_list(i),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID
            );

            /* Bulk Upload AMS_TCOP_CHANNEL_SUM_DTL */
            FORALL i in l_chnl_sum_dtl_id_list.FIRST .. l_chnl_sum_dtl_id_list.LAST
            INSERT INTO
            AMS_TCOP_CHANNEL_SUM_DTL
            (
               CHANNEL_SUM_DTL_ID,
               CHANNEL_SUMMARY_ID,
               SCHEDULE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               l_chnl_sum_dtl_id_list(i),
               l_chnl_sum_id_list_for_dtl(i),
               l_schedule_id_list(i),
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID
            );

      END IF;

   ELSE

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'NO CHANNEL RULE EXISTS',
                          'NO Summarization needed for channel rules'
                         );


   END IF;/* l_rule_id IS null */


END SUMMARIZE_LIST_CONTACTS;


-- ===============================================================
-- Start of Comments
-- Name
-- UPDATE_CONTACT_COUNT
--
-- Purpose
-- This procedure updates contact count for all the contacted parties
--
PROCEDURE      UPDATE_CONTACT_COUNT(p_party_id_list   JTF_NUMBER_TABLE
                                    ,p_schedule_id    NUMBER
                                    ,p_activity_id    NUMBER
                                    ,p_global_rule_id NUMBER
                                    ,p_channel_rule_id   NUMBER
                                   )

IS
   -- Verify if new entries need to be created in AMS_TCOP_CONTACT_SUMMARY
   -- and in AMS_TCOP_CONTACT_SUM_DTL
   CURSOR C_GET_EXISTING_PARTY (p_party_id_list   JTF_NUMBER_TABLE)
   IS
   SELECT summary.PARTY_ID,summary.contact_summary_id
   FROM   AMS_TCOP_CONTACT_SUMMARY summary,
          (SELECT column_value party_id
           FROM TABLE(CAST(p_party_id_List as JTF_NUMBER_TABLE))
          ) party_list
   WHERE  summary.party_id=party_list.party_id;

   CURSOR C_GET_NEW_PARTY (p_original_party_id_list   JTF_NUMBER_TABLE
                           ,p_existing_party_id_list  JTF_NUMBER_TABLE
                          )
   IS
   SELECT orig_party_list.PARTY_ID
   FROM   (SELECT column_value party_id
           FROM TABLE(CAST(p_original_party_id_list as JTF_NUMBER_TABLE))
          ) orig_party_list
   WHERE orig_party_list.PARTY_ID NOT IN
          (SELECT column_value
           FROM TABLE(CAST(p_existing_party_id_list as JTF_NUMBER_TABLE))
           );

   CURSOR C_GET_SUM_DTL_SEQ
   IS
   SELECT AMS_TCOP_CONTACT_SUM_DTL_S.NEXTVAL
   FROM DUAL;

   CURSOR C_GET_CONTACT_SUM_SEQ
   IS
   SELECT AMS_TCOP_CONTACT_SUM_S.NEXTVAL
   FROM DUAL;

   CURSOR C_GET_CHNL_SUM_DTL_SEQ
   IS
   SELECT AMS_TCOP_CHNL_SUM_DTL_S.NEXTVAL
   FROM DUAL;

   CURSOR C_GET_CHNL_SUM_SEQ
   IS
   SELECT AMS_TCOP_CHNL_SUM_S.NEXTVAL
   FROM DUAL;

   -- Get existing entries from AMS_TCOP_CHANNEL_SUMMARY
   CURSOR C_GET_EXISTING_PARTY_CHNL (p_party_id_list   JTF_NUMBER_TABLE
                                    ,p_activity_id     NUMBER
                                    )
   IS
   SELECT summary.PARTY_ID,summary.channel_summary_id
   FROM   AMS_TCOP_CHANNEL_SUMMARY summary,
          (SELECT column_value party_id
           FROM TABLE(CAST(p_party_id_List as JTF_NUMBER_TABLE))
          ) party_list
   WHERE  summary.party_id=party_list.party_id
   AND    summary.media_id=p_activity_id;

   -- Get the list of parties which already have a row in
   -- AMS_TCOP_CONTACT_SUMMARY and in AMS_TCOP_CONTACT_SUM_DTL

   l_existing_party_id_list   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_new_party_id_list        JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   l_contact_summary_id_list  NUMBER_ARRAY;
   l_sum_detail_seq_id_list   NUMBER_ARRAY;
   l_contact_sum_seq_id_list  NUMBER_ARRAY;
   l_chnl_sum_seq_id_list  NUMBER_ARRAY;
   l_channel_summary_id_list  NUMBER_ARRAY;
   l_chnl_sum_detail_seq_id_list NUMBER_ARRAY;

   l_sequence_id              NUMBER;
   l_list_count               NUMBER;
   l_no_existing_party_global      BOOLEAN := FALSE;
   l_no_existing_party_channel     BOOLEAN := FALSE;

   --List of Constants
   PROCEDURE_NAME   CONSTANT        VARCHAR2(30) := 'UPDATE_CONTACT_COUNT';


BEGIN

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'BEGIN',
                       'Beginning Procedure'
                      );

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'DISPLAY_INPUT_PARAMETER',
                       'Schedule Id = '||to_char(p_schedule_id)||', Activity Id = '||to_char(p_activity_id)
                      );

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'DISPLAY_INPUT_PARAMETER',
                       'Global Rule Id = '||to_char(p_global_rule_id)||', Channel Rule Id = '||to_char(p_channel_rule_id)
                      );

   IF (p_global_rule_id is not null) THEN

      l_list_count := p_party_id_list.COUNT;

      IF (l_list_count > 0) THEN

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'INPUT_PARTY_ID_COLLECTION_HAS_ENTRIES',
                             'Input parameter Party Id List Count = '||to_char(l_list_count)
                            );

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'BEFORE CURSOR C_GET_EXISTING_PARTY',
                             'Executing Cursor C_GET_EXISTING_PARTY'
                            );

      -- If there is no global contact rule setup then there is no need
      -- update the AMS_TCOP_CONTACT_SUMMARY



         -- Get the existing party list from the Global Summarization Tables
         OPEN C_GET_EXISTING_PARTY(p_party_id_list);
         FETCH C_GET_EXISTING_PARTY
         BULK COLLECT INTO l_existing_party_id_list,l_contact_summary_id_list;
         CLOSE C_GET_EXISTING_PARTY;

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             'AFTER CURSOR C_GET_EXISTING_PARTY',
                             'Cursor C_GET_EXISTING_PARTY executed successfully'
                            );

         l_list_count := l_existing_party_id_list.COUNT;

         IF (l_list_count > 0) THEN
            -- There are some existing parties in the summarization tables
            -- Create an array of sequence ids to populate SUMMARY_DTL_ID column
            -- of table AMS_TCOP_CONTACT_SUM_DTL

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'EXISTING_PARTIES_IN_GLOBAL_SUMMARY',
                                'Number of Parties exist in Global Contact Summary = '||to_char(l_list_count)
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'START_LOOP_TO_GET_SUM_DTL_SEQ_ARRAY',
                                'Run the cursor C_GET_SUM_DTL_SEQ in a loop to build an array of sequence ids'
                               );
            FOR i in l_existing_party_id_list.FIRST .. l_existing_party_id_list.LAST
            LOOP
               OPEN  C_GET_SUM_DTL_SEQ;
               FETCH C_GET_SUM_DTL_SEQ
               INTO  l_sequence_id;
               CLOSE C_GET_SUM_DTL_SEQ;

               l_sum_detail_seq_id_list(i) := l_sequence_id;

            END LOOP;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE_BULK_UPDATE_CONTACT_SUMMARY',
                                'Bulk update AMS_TCOP_CONTACT_SUMMARY to increment the contact count'
                               );

            -- Bulk Update AMS_TCOP_CONTACT_SUMMARY table
            FORALL i in l_contact_summary_id_list.FIRST .. l_contact_summary_id_list.LAST
            UPDATE AMS_TCOP_CONTACT_SUMMARY
            SET TOTAL_CONTACTS = TOTAL_CONTACTS + 1
            WHERE CONTACT_SUMMARY_ID = l_contact_summary_id_list(i);

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_BULK_UPDATE_CONTACT_SUMMARY',
                                'Bulk update AMS_TCOP_CONTACT_SUMMARY to increment the contact count completed successfully!'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE_BULK_INSERT_CONTACT_SUM_DTL_LABEL1',
                                'Bulk Insert AMS_TCOP_CONTACT_SUM_DTL to have the schedule information '
                               );

            -- Bulk Insert into AMS_TCOP_CONTACT_SUM_DTL
            FORALL i in l_contact_summary_id_list.FIRST .. l_contact_summary_id_list.LAST
            INSERT INTO
            AMS_TCOP_CONTACT_SUM_DTL
            (
               SUMMARY_DTL_ID,
               CONTACT_SUMMARY_ID,
               SCHEDULE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               l_sum_detail_seq_id_list(i),
               l_contact_summary_id_list(i),
               p_schedule_id,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID
            );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_BULK_INSERT_CONTACT_SUM_DTL_LABEL1',
                                'Bulk Insert into AMS_TCOP_CONTACT_SUM_DTL completed successfully'
                               );
            -- Reset some of the collection variables that will be reused
            l_sum_detail_seq_id_list.delete;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'RESET_COLLECTION_VARIABLES_LABEL1',
                                'Reset collection variable l_sum_detail_seq_id_list'
                               );
         ELSE

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NO_PARTY_EXISTS_IN_GLOBAL_CONTACT_SUMMARY_L1',
                                'No party exists in global contact summary among the parties contacted'
                               );

            l_no_existing_party_global := TRUE;


         END IF;


         IF (not(l_no_existing_party_global)) THEN

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'PARTY_EXISTS_IN_GLOBAL_SUMMARY',
                                'Parties already exist in global contact summary'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE CURSOR C_GET_NEW_PARTY_LABEL1',
                                'Executing Cursor C_GET_NEW_PARTY to get the list of parties not present in the global contact summary tables'
                               );
            -- Get the party list not present in the Global Summarization Tables
            OPEN C_GET_NEW_PARTY(p_party_id_list,l_existing_party_id_list);
            FETCH C_GET_NEW_PARTY
            BULK COLLECT INTO l_new_party_id_list;
            CLOSE C_GET_NEW_PARTY;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_CURSOR_C_GET_NEW_PARTY_LABEL1',
                                'Cursor C_GET_NEW_PARTY Executed successfully'
                               );
         ELSE
            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NO_PARTY_EXISTS_IN_GLOBAL_CONTACT_SUMMARY_L2',
                                'Copy the input list to the new_party_list'
                               );

            l_new_party_id_list := p_party_id_list;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NO_PARTY_EXISTS_IN_GLOBAL_CONTACT_SUMMARY_L3',
                                'After Copying the input list to the new_party_list'
                               );
         END IF;

         l_list_count := l_new_party_id_list.COUNT;

         IF (l_list_count > 0) THEN

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NEW_PARTIES_WHICH_DO_NOT_EXIST_IN_GLOBAL_SUMMARY',
                                'Number of new Parties which do not exist in Global Contact Summary = '||to_char(l_list_count)
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'START_LOOP_AND_CREATE_SEQ_ARRAY_LABEL1',
                                'Start a loop and get next sequence id for contact_sum_s and contact_sum_dtl_s'
                               );

            FOR i in l_new_party_id_list.FIRST .. l_new_party_id_list.LAST
            LOOP

               OPEN C_GET_CONTACT_SUM_SEQ;
               FETCH C_GET_CONTACT_SUM_SEQ
               INTO l_sequence_id;
               CLOSE C_GET_CONTACT_SUM_SEQ;

               l_contact_sum_seq_id_list(i) := l_sequence_id;

               OPEN  C_GET_SUM_DTL_SEQ;
               FETCH C_GET_SUM_DTL_SEQ
               INTO  l_sequence_id;
               CLOSE C_GET_SUM_DTL_SEQ;

               l_sum_detail_seq_id_list(i) := l_sequence_id;

            END LOOP;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'END_LOOP_AND_CREATE_SEQ_ARRAY_LABEL2',
                                'Successfully completed the loop to get an array of  next sequence id for contact_sum_s and contact_sum_dtl_s'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE_BULK_INSERT_INTO_CONTACT_SUMMARY',
                                'Bulk Insert the new party ids into the AMS_TCOP_CONTACT_SUMMARY'
                               );

            -- BULK INSERT INTO AMS_TCOP_CONTACT_SUMMARY
            FORALL i in l_new_party_id_list.FIRST .. l_new_party_id_list.LAST
            INSERT INTO
            AMS_TCOP_CONTACT_SUMMARY
            (
               CONTACT_SUMMARY_ID,
               RULE_ID,
               PARTY_ID,
               TOTAL_CONTACTS,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               l_contact_sum_seq_id_list(i),
               p_global_rule_id,
               l_new_party_id_list(i),
               1,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID
            );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_BULK_INSERT_INTO_CONTACT_SUMMARY',
                                'Bulk Insertion of the new party ids into the AMS_TCOP_CONTACT_SUMMARY completed successfully'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_BULK_INSERT_INTO_CONTACT_SUMMARY',
                                'Bulk Insertion of the new party ids into the AMS_TCOP_CONTACT_SUMMARY completed successfully'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE_BULK_INSERT_CONTACT_SUM_DTL_LABEL2',
                                'Bulk Insert AMS_TCOP_CONTACT_SUM_DTL to have the schedule information '
                               );

            -- BULK INSERT INTO AMS_TCOP_CONTACT_SUM_DTL
            FORALL i in l_sum_detail_seq_id_list.FIRST .. l_sum_detail_seq_id_list.LAST
            INSERT INTO
            AMS_TCOP_CONTACT_SUM_DTL
            (
               SUMMARY_DTL_ID,
               CONTACT_SUMMARY_ID,
               SCHEDULE_ID,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               l_sum_detail_seq_id_list(i),
               l_contact_sum_seq_id_list(i),
               p_schedule_id,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID
            );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_BULK_INSERT_CONTACT_SUM_DTL_LABEL2',
                                'After Bulk Insert AMS_TCOP_CONTACT_SUM_DTL to have the schedule information '
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'RESET_COLLECTION_VARIABLES_LABEL2',
                                'Reset collection variable l_existing_party_id_list,l_new_party_id_list'
                               );
            --Reset some of the collections that will be reused later
            l_existing_party_id_list.delete;
            l_new_party_id_list.delete;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_RESET_COLLECTION_VARIABLES_LABEL2',
                                'Successful completion of Reset collection variable l_existing_party_id_list,l_new_party_id_list'
                               );

         ELSE

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NO_NEW_PARTIES_NEED_TO_BE_CREATED_IN_GLOBAL_SUMMARY',
                                'new_party_id_list is zero. No parties need to be created in Contact Summary'
                               );
         END IF;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'BEFORE CURSOR C_GET_EXISTING_PARTY_CHNL',
                          'Executing Cursor C_GET_EXISTING_PARTY_CHNL to get the list of parties not present in the channel contact summary tables'
                         );
      END IF;

      IF (p_channel_rule_id is not null) THEN

         IF (NOT (l_no_existing_party_global)) THEN
            -- There are some existing parties in global contact summary
            -- This step will be skipped if threre are no existing parties
            -- global summary, that means there won't be any entries in channel
            -- summary

            -- Get the existing party list from the Channel Summarization Tables
            OPEN C_GET_EXISTING_PARTY_CHNL(p_party_id_list,p_activity_id);
            FETCH C_GET_EXISTING_PARTY_CHNL
            BULK COLLECT INTO l_existing_party_id_list,l_channel_summary_id_list;
            CLOSE C_GET_EXISTING_PARTY_CHNL;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER CURSOR C_GET_EXISTING_PARTY_CHNL',
                                'Cursor C_GET_EXISTING_PARTY_CHNL executed successfully to get the list of parties not present in the channel contact summary tables'
                               );

            l_list_count := l_existing_party_id_list.count;
            IF (l_list_count > 0) THEN
               -- There are some existing parties in the channel summarization tables
               -- Create an array of sequence ids to populate CHANNEL_SUM_DTL_ID column
               -- of table AMS_TCOP_CHANNEL_SUM_DTL

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'PARTIES_EXIST_IN_CHANNEL_SUMMARY',
                                   'Number of new Parties which exist in Channel Contact Summary = '||to_char(l_list_count)
                                  );

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'START_LOOP_AND_CREATE_SEQ_ARRAY_LABEL2',
                                   'Start a loop and get next sequence id for channel_sum_dtl_s and create an array'
                                  );

               FOR i in l_existing_party_id_list.FIRST .. l_existing_party_id_list.LAST
               LOOP
                  OPEN  C_GET_CHNL_SUM_DTL_SEQ;
                  FETCH C_GET_CHNL_SUM_DTL_SEQ
                  INTO  l_sequence_id;
                  CLOSE C_GET_CHNL_SUM_DTL_SEQ;

                  l_chnl_sum_detail_seq_id_list(i) := l_sequence_id;

               END LOOP;

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'END_LOOP_AND_CREATE_SEQ_ARRAY_LABEL2',
                                   'End loop and get next sequence id for channel_sum_dtl_s with the array populated'
                                  );

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'BEFORE_BULK_UPDATE_CHANNEL_SUMMARY',
                                   'Bulk update AMS_TCOP_CHANNEL_SUMMARY to increment the contact count'
                                  );

               -- Bulk Update AMS_TCOP_CHANNEL_SUMMARY table
               FORALL i in l_channel_summary_id_list.FIRST .. l_channel_summary_id_list.LAST
               UPDATE AMS_TCOP_CHANNEL_SUMMARY
               SET TOTAL_CONTACTS = TOTAL_CONTACTS + 1
               WHERE CHANNEL_SUMMARY_ID = l_channel_summary_id_list(i)
               AND   MEDIA_ID = p_activity_id;

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'AFTER_BULK_UPDATE_CHANNEL_SUMMARY',
                                   'After Bulk update AMS_TCOP_CHANNEL_SUMMARY to increment the contact count'
                                  );

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'BEFORE_BULK_INSERT_CHANNEL_SUM_DTL_L1',
                                   'Before Bulk Insert of AMS_TCOP_CHANNEL_SUM_DTL to populate the schedule information'
                                  );

               -- Bulk Insert into AMS_TCOP_CHANNEL_SUM_DTL
               FORALL i in l_chnl_sum_detail_seq_id_list.FIRST .. l_chnl_sum_detail_seq_id_list.LAST
               INSERT INTO
               AMS_TCOP_CHANNEL_SUM_DTL
               (
                  CHANNEL_SUM_DTL_ID,
                  CHANNEL_SUMMARY_ID,
                  SCHEDULE_ID,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN
               )
               VALUES
               (
                  l_chnl_sum_detail_seq_id_list(i),
                  l_channel_summary_id_list(i),
                  p_schedule_id,
                  sysdate,
                  FND_GLOBAL.USER_ID,
                  sysdate,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.USER_ID
               );

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'AFTER_BULK_INSERT_CHANNEL_SUM_DTL_L2',
                                   'After Bulk Insert of AMS_TCOP_CHANNEL_SUM_DTL to populate the schedule information'
                                  );

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'RESET_COLLECTION_VARIABLES_LABEL3',
                                   'Reset collection variable l_sum_detail_seq_id_list'
                                  );

               --Reset some collection variables
               l_sum_detail_seq_id_list.delete;

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'AFTER_RESET_COLLECTION_VARIABLES_LABEL3',
                                   'Reset collection variable l_sum_detail_seq_id_list'
                                  );
            ELSE

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'NO_EXISTING_PARTIES_IN_CHANNEL_SUMMARY',
                                   'No parties exist in the channel summary tables among the parties contacted'
                                  );
               l_no_existing_party_channel := TRUE;


            END IF;

         ELSE
               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'SKIPPING_EXISTING_PARTIES_IN_CHANNEL_SUMMARY',
                                   'Since no parties exist in the global summary, there will not be any in the channel summary'
                                  );

         END IF;

         IF (NOT (l_no_existing_party_channel)) THEN

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE CURSOR C_GET_NEW_PARTY_LABEL2',
                                'Executing Cursor C_GET_NEW_PARTY to get the list of parties not present in the channel contact summary tables'
                               );

            -- Get the party list not present in the Channel Summarization Tables
            OPEN C_GET_NEW_PARTY(p_party_id_list,l_existing_party_id_list);
            FETCH C_GET_NEW_PARTY
            BULK COLLECT INTO l_new_party_id_list;
            CLOSE C_GET_NEW_PARTY;

         ELSE
            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NO_PARTY_EXISTS_IN_CHANNEL_CONTACT_SUMMARY',
                                'Copy the input list to the new_party_list'
                               );

            l_new_party_id_list := p_party_id_list;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'NO_PARTY_EXISTS_IN_CHANNEL_CONTACT_SUMMARY',
                                'After Copying the input list to the new_party_list'
                               );

         END IF;

         l_list_count := l_new_party_id_list.COUNT;

         IF (l_list_count > 0) THEN

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'CREATE_NEW_PARTIES_IN_CHANNEL_SUMMARY',
                                'Number of new Parties need to be created in Channel Contact Summary = '||to_char(l_list_count)
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'START_LOOP_AND_CREATE_SEQ_ARRAY_LABEL3',
                                'Start a loop and get next sequence id for channel_sum_s,channel_sum_dtl_s and create an array'
                               );

            FOR i in l_new_party_id_list.FIRST .. l_new_party_id_list.LAST
            LOOP

               OPEN C_GET_CHNL_SUM_SEQ;
               FETCH C_GET_CHNL_SUM_SEQ
               INTO l_sequence_id;
               CLOSE C_GET_CHNL_SUM_SEQ;

               l_chnl_sum_seq_id_list(i) := l_sequence_id;

               OPEN  C_GET_CHNL_SUM_DTL_SEQ;
               FETCH C_GET_CHNL_SUM_DTL_SEQ
               INTO  l_sequence_id;
               CLOSE C_GET_CHNL_SUM_DTL_SEQ;

               l_sum_detail_seq_id_list(i) := l_sequence_id;

            END LOOP;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'END_LOOP_AND_CREATE_SEQ_ARRAY_LABEL3',
                                'End a loop and get next sequence id for channel_sum_s,channel_sum_dtl_s and create an array'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE_BULK_INSERT_CHANNEL_SUM',
                                'Before Bulk Insert of AMS_TCOP_CHANNEL_SUMMMARY'
                               );

            -- BULK INSERT INTO AMS_TCOP_CHANNEL_SUMMARY
            FORALL i in l_new_party_id_list.FIRST .. l_new_party_id_list.LAST
            INSERT INTO
            AMS_TCOP_CHANNEL_SUMMARY
            (
               CHANNEL_SUMMARY_ID,
               RULE_ID,
               PARTY_ID,
               MEDIA_ID,
               TOTAL_CONTACTS,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN
            )
            VALUES
            (
               l_chnl_sum_seq_id_list(i),
               p_channel_rule_id,
               l_new_party_id_list(i),
               p_activity_id,
               1,
               sysdate,
               FND_GLOBAL.USER_ID,
               sysdate,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.USER_ID
            );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'AFTER_BULK_INSERT_CHANNEL_SUM',
                                'After Bulk Insert of AMS_TCOP_CHANNEL_SUMMMARY'
                               );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                'BEFORE_BULK_INSERT_CHANNEL_SUM_DTL_L2',
                                'Before Bulk Insert of AMS_TCOP_CHANNEL_SUM_DTL to populate the schedule information'
                               );

            -- BULK INSERT INTO AMS_TCOP_CHANNEL_SUM_DTL
            FORALL i in l_sum_detail_seq_id_list.FIRST .. l_sum_detail_seq_id_list.LAST
               INSERT INTO
               AMS_TCOP_CHANNEL_SUM_DTL
               (
                  CHANNEL_SUM_DTL_ID,
                  CHANNEL_SUMMARY_ID,
                  SCHEDULE_ID,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_LOGIN
               )
               VALUES
               (
                  l_sum_detail_seq_id_list(i),
                  l_chnl_sum_seq_id_list(i),
                  p_schedule_id,
                  sysdate,
                  FND_GLOBAL.USER_ID,
                  sysdate,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.USER_ID
               );

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   'BEFORE_BULK_INSERT_CHANNEL_SUM_DTL_L2',
                                   'Before Bulk Insert of AMS_TCOP_CHANNEL_SUM_DTL to populate the schedule information'
                                  );


         END IF;

      END IF;
   END IF;





END UPDATE_CONTACT_COUNT;
-- ===============================================================
-- Start of Comments
-- Name
-- SUMMARIZE_ALL_FATIGUE_CONTACTS
--
-- Purpose
-- This procedure summarizes all fatiguing contacts for the periods
-- specified in Fatigue Rule Setup
--
PROCEDURE   SUMMARIZE_ALL_FATIGUE_CONTACTS
IS
BEGIN
   null;
END SUMMARIZE_ALL_FATIGUE_CONTACTS;


END AMS_TCOP_SUMMARIZATION_PKG;

/
