--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_ENGINE_PKG" AS
/* $Header: amsvtcrb.pls 115.2 2004/05/18 11:20:50 mayjain noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_ENGINE_PKG
-- Purpose
--
-- This package contains all the program units for traffic cop
-- Engine
--
-- History
--
-- 3/1/2004 mayjain fix for bug 3470706
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Start of Comments
-- Name
-- Apply_Fatigue_Rules
--
-- Purpose
-- This procedure applies fatigue rules on the Target Group of Schedule.
--
-- Declare Some Global Variables used by all the procedures in the package
--
-- This variable is list of all the parties fatigued
G_Fatigue_Party_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

-- This variable is list of all the list_entry_id that are associated
-- with fatigue parties
G_Fatigue_Entry_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

-- This is a list of list_entry_id associated with the list
-- of schedules which fatigued the parties. This list may contain
-- duplicate entries.
G_Fatigue_By_Entry_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

-- This is a list of list_entry_id associated with the list
-- of schedules which fatigued the parties
G_Fatigue_By_Schedule_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

-- Global Constants that will be used through out the package
LOG_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
LOG_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
LOG_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
LOG_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
LOG_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
LOG_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

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
   AMS_UTILITY_PVT.write_conc_log('['||G_PACKAGE_NAME||DELIMETER||p_procedure_name||DELIMETER||LABEL_PREFIX||'-'||p_label||']'||p_text);

      --dbms_output.put_line(l_module_name||': '||p_text);

END write_debug_message;


-- Append the given list to the global list
PROCEDURE APPEND_GLOBAL_FATIGUE_LIST(p_fatigue_party_list 	JTF_NUMBER_TABLE,
												 p_fatigue_entry_list	JTF_NUMBER_TABLE,
												 p_fatigue_by_entry_list JTF_NUMBER_TABLE,
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
                    'Total number of ids in the input fatigue entry list = '||to_char(p_fatigue_entry_list.count)
                   );

   write_debug_message(LOG_LEVEL_EVENT,
                    PROCEDURE_NAME,
                    'INPUT_FATIGUE_BY_ENTRY_LIST_NEEDS_TO_BE_COPIED',
                    'Total number of fatigue by entries in the input list = '||to_char(p_fatigue_by_entry_list.count)
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

	-- Append the G_FATIGUE_ENTRY_LIST
	l_input_count := p_FATIGUE_ENTRY_LIST.COUNT;
	IF (l_input_count > 0) THEN
      l_global_count := G_FATIGUE_ENTRY_LIST.COUNT;
      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_ENTRY_LIST_BEFORE_COPY',
                       'Before copying Total number of entries in the global fatigue list_entry list = '||to_char(l_global_count)
                      );
		FOR i in p_fatigue_entry_list.FIRST .. p_fatigue_entry_list.LAST
		LOOP
			G_FATIGUE_ENTRY_LIST.EXTEND;
			G_FATIGUE_ENTRY_LIST(l_global_count + 1) := p_fatigue_entry_list(i);
         l_global_count := l_global_count + 1;
		END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_ENTRY_LIST_AFTER_COPY',
                       'After copying Total number of entries in the global fatigue list_entry list = '||to_char(G_FATIGUE_ENTRY_LIST.COUNT)
                      );
	END IF;

	-- Append the G_FATIGUE_BY_ENTRY_LIST
	l_input_count := p_FATIGUE_BY_ENTRY_LIST.COUNT;
	IF (l_input_count > 0) THEN
      l_global_count := G_FATIGUE_BY_ENTRY_LIST.COUNT;
      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_BY_ENTRY_LIST_BEFORE_COPY',
                       'Before copying Total number of entries in the global fatigue by list = '||to_char(l_global_count)
                      );
		FOR i in p_fatigue_by_entry_list.FIRST .. p_fatigue_by_entry_list.LAST
		LOOP
			G_FATIGUE_BY_ENTRY_LIST.EXTEND;
			G_FATIGUE_BY_ENTRY_LIST(l_global_count + 1) := p_fatigue_by_entry_list(i);
         l_global_count := l_global_count + 1;
		END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GLOBAL_FATIGUE_BY_ENTRY_LIST_AFTER_COPY',
                       'After copying Total number of entries in the global fatigue by list = '||to_char(G_FATIGUE_BY_ENTRY_LIST.count)
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



-- This function checks if the given partyId is already in the global
-- fatigue list G_Fatigue_Party_List
--
FUNCTION IS_PARTY_IN_FATIGUE_LIST(p_party_id		NUMBER)
RETURN BOOLEAN
IS

CURSOR C_GET_PARTY(p_party_id		NUMBER)
IS
SELECT party_list.party_id
FROM
(SELECT column_value party_id
 FROM TABLE(CAST(G_Fatigue_Party_List as JTF_NUMBER_TABLE))
) party_list
WHERE party_list.party_id=p_party_id;

l_party_id	NUMBER;

BEGIN

	OPEN C_GET_PARTY(p_party_id);
	FETCH C_GET_PARTY INTO l_party_id;
	CLOSE C_GET_PARTY;

	IF (l_party_id IS NULL) THEN
		return false;
   else
	   return true;
	END IF;

END IS_PARTY_IN_FATIGUE_LIST;

-- This function returns the equivalent contact_type of marketing
-- channels. TCA recognizes CONTACT_TYPEs as lookup code of
-- lookup type CONTACT_TYPE
-- For example, Seeded Activity Id for Marketing channel EMAIL = 20
-- It's Equivalent CONTACT_TYPE lookup code in TCA is EMAIL
FUNCTION INTERPRET_UOM_CODE(p_interact_uom_code	VARCHAR2)
RETURN	NUMBER
IS
BEGIN
   IF (p_interact_uom_code = 'MONTH') THEN
      return 30;
   ELSIF (p_interact_uom_code = '30_DAY_PERIOD') THEN
      return 30;
   ELSIF (p_interact_uom_code = 'DAY') THEN
      return 1;
   ELSIF (p_interact_uom_code = 'WEEK') THEN
      return 7;
   ELSIF (p_interact_uom_code = 'YEAR') THEN
      return 365;
   ELSE
      return null;
   END IF;

END;

-- This function returns the equivalent contact_type of marketing
-- channels. TCA recognizes CONTACT_TYPEs as lookup code of
-- lookup type CONTACT_TYPE
-- For example, Seeded Activity Id for Marketing channel EMAIL = 20
-- It's Equivalent CONTACT_TYPE lookup code in TCA is EMAIL
FUNCTION GET_TCA_SUPPORTED_CONTACT_TYPE(p_activity_id	NUMBER)
RETURN VARCHAR2
IS
BEGIN
   IF (p_activity_id = 20) THEN
      return 'EMAIL';
   ELSIF (p_activity_id = 10) THEN
      return 'FAX';
   ELSIF (p_activity_id = 460) THEN
      return 'CALL';
   ELSIF (p_activity_id = 480) THEN
      return 'MAIL';
   ELSE
      return null;
   END IF;

END GET_TCA_SUPPORTED_CONTACT_TYPE;

-- ===============================================================
-- Start of Comments
-- Name
-- Apply_Fatigue_Rules
--
-- Purpose
   -- This API will add parties to the Global Fatigue List based on the following:
   -- 1. The Opt-In preferences for the parties must have been set
   -- 2. The number of contacts already reached the maximum threshold as per the contact preferences.
--
PROCEDURE  APPLY_PARTY_OPT_IN_PREFERENCES(p_list_header_id	NUMBER,
                                          p_activity_id     NUMBER
                                         )
IS

-- This cursor gets all the party preferences both Global and Channel specific
-- Global Preferences are those where contact_type=ALL and Channel specific preferences
-- Supported channels in TCA which also overlap with Marketing
-- are EMAIL,FAX,CALL and MAIL
CURSOR C_GET_PARTY_PREFERENCES(p_list_header_id	NUMBER,
		               p_channel 	VARCHAR2 )
IS
SELECT 	list_entry.party_id
   ,list_entry.list_entry_id
	,pref.CONTACT_TYPE
	,pref.MAX_NO_OF_INTERACTIONS
	,pref.MAX_NO_OF_INTERACT_UOM_CODE
FROM HZ_CONTACT_PREFERENCES pref,
     ams_list_entries list_entry
WHERE list_entry.LIST_HEADER_ID = p_list_header_id
AND pref.contact_level_table='HZ_PARTIES'
AND pref.contact_level_table_id = list_entry.PARTY_ID
AND (pref.CONTACT_TYPE = 'ALL' or pref.CONTACT_TYPE = p_channel)
AND pref.PREFERENCE_CODE = 'DO'-- this indicates it's an OPT-IN preferences
AND (pref.PREFERENCE_TOPIC_TYPE is null
     or  pref.PREFERENCE_TOPIC_TYPE = 'CONTACT_USAGE')
AND pref.STATUS = 'A'
AND (pref.MAX_NO_OF_INTERACTIONS IS NOT NULL)
AND (pref.MAX_NO_OF_INTERACT_UOM_CODE IS NOT NULL);

-- This cursor gets only the Global party preferences
-- Global Preferences where contact_type=ALL
-- This Cursor will be used when the Schedule Channel is not one of these
-- EMAIL,FAX,CALL and MAIL
CURSOR C_GET_GLOBAL_PARTY_PREFERENCES(p_list_header_id	NUMBER)
IS
SELECT	list_entry.party_id party_id
			,list_entry.list_entry_id list_entry_id
			,pref.CONTACT_TYPE CONTACT_TYPE
			,pref.MAX_NO_OF_INTERACTIONS MAX_NO_OF_INTERACTIONS
			,pref.MAX_NO_OF_INTERACT_UOM_CODE MAX_NO_OF_INTERACT_UOM_CODE
FROM HZ_CONTACT_PREFERENCES pref,
     ams_list_entries list_entry
WHERE list_entry.LIST_HEADER_ID = p_list_header_id
AND pref.contact_level_table='HZ_PARTIES'
AND pref.contact_level_table_id = list_entry.PARTY_ID
AND pref.CONTACT_TYPE = 'ALL'
AND pref.PREFERENCE_CODE = 'DO'-- this indicates it's an OPT-IN preferences
AND (pref.PREFERENCE_TOPIC_TYPE is null
     or  pref.PREFERENCE_TOPIC_TYPE = 'CONTACT_USAGE')
AND pref.STATUS = 'A'
AND (pref.MAX_NO_OF_INTERACTIONS IS NOT NULL)
AND (pref.MAX_NO_OF_INTERACT_UOM_CODE IS NOT NULL);

-- This cursor is to select how many times a party has been contacted
-- by fatiguing schedules
CURSOR C_GET_PARTY_CONTACTS(p_party_id		NUMBER,
                            p_no_of_days	NUMBER)
IS
SELECT count(party_id)
FROM ams_tcop_contacts contact
WHERE party_id = p_party_id
AND contact_date between sysdate and (sysdate - p_no_of_days);


-- This cursor is to select all the contacts made by the fatiguing schedules
-- within a time frame specified in the HZ_CONTACT_PREFERENCES
CURSOR C_GET_CONTACTED_SCHEDULE(p_party_id		NUMBER,
									 	  p_no_of_days  NUMBER
									    )
IS
SELECT schedule_id
FROM AMS_TCOP_CONTACTS
WHERE party_id = p_party_id
AND contact_date between sysdate and (sysdate - p_no_of_days);

l_party_id	NUMBER;
l_max_no_of_interaction	NUMBER;
l_max_no_of_interact_uom_code VARCHAR2(30);
l_contact_type VARCHAR2(30);
l_no_of_days	NUMBER;
l_duplicate_party	BOOLEAN;
l_party_contact_count NUMBER;
i  NUMBER;

l_Fatigue_Party_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_Fatigue_Entry_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_Fatigue_By_Entry_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
l_Fatigue_By_Schedule_List JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

BEGIN
   -- Get Equivalent Channel code as recognized by TCA
   l_contact_type := GET_TCA_SUPPORTED_CONTACT_TYPE(p_activity_id);

   IF (l_contact_type is not null) then
      -- The schedule channel is one of the channels that TCA recognizes
      FOR C1 in C_GET_PARTY_PREFERENCES(p_list_header_id,l_contact_type)
      LOOP
         l_no_of_days := INTERPRET_UOM_CODE(C1.MAX_NO_OF_INTERACT_UOM_CODE);

         IF (l_no_of_days is not null) THEN

            -- Get the number of contacts made within the time frame specified
            -- by the party Opt in preference
            OPEN C_GET_PARTY_CONTACTS (C1.party_id,l_no_of_days);
            FETCH C_GET_PARTY_CONTACTS INTO l_party_contact_count;
            CLOSE C_GET_PARTY_CONTACTS;


            IF (l_party_contact_count >= C1.MAX_NO_OF_INTERACTIONS) THEN
               -- Add the party to the fatigue list, if the party is not already added
               l_duplicate_party := IS_PARTY_IN_FATIGUE_LIST(C1.party_id);

               IF (NOT(l_duplicate_party)) THEN
                  i := 1;
                  --Get the list of schedules which fatigued this party
                  FOR C2 in C_GET_CONTACTED_SCHEDULE(C1.party_id,l_no_of_days)
                  LOOP

                     IF (NOT(l_Fatigue_By_Schedule_List.EXISTS(i))) THEN
                        l_Fatigue_By_Schedule_List.EXTEND;
                     END IF;

                     IF (NOT(l_Fatigue_By_Entry_List.EXISTS(i))) THEN
                        l_Fatigue_By_Entry_List.EXTEND;
                     END IF;

                     l_Fatigue_By_Schedule_List(i) := C2.schedule_id;
                     l_Fatigue_By_Entry_List(i) := C1.list_entry_id;


                     i := i + 1;
                  END LOOP;

                  -- Create/Update fatigue party list and fatigue entry list
                  IF (NOT(l_Fatigue_Party_List.EXISTS(1))) THEN
                     l_Fatigue_Party_List.EXTEND;
                  END IF;

                  IF (NOT(l_Fatigue_Entry_List.EXISTS(1))) THEN
                     l_Fatigue_Entry_List.EXTEND;
                  END IF;

                  l_Fatigue_Party_List(1) := C1.party_id;
                  l_Fatigue_Entry_List(1) := C1.list_entry_id;

                  APPEND_GLOBAL_FATIGUE_LIST(l_Fatigue_Party_List,
                                             l_Fatigue_Entry_List,
                                             l_Fatigue_By_Entry_List,
                                             l_Fatigue_By_Schedule_List
                                             );

                  -- Reset the Collection Variables
                  l_Fatigue_Party_List.DELETE;
                  l_Fatigue_Entry_List.DELETE;
                  l_Fatigue_By_Entry_List.DELETE;
                  l_Fatigue_By_Schedule_List.DELETE;


				   END IF;

			   END IF;

         END IF;

      END LOOP;

   END IF;

END APPLY_PARTY_OPT_IN_PREFERENCES;


PROCEDURE Apply_Fatigue_Rules (
          p_schedule_id NUMBER
          )
IS
   STATUS CONSTANT VARCHAR2(30) := 'ACTIVE';


	-- Get Target Group List Header Id
	CURSOR C_Get_List_Header(p_schedule_id NUMBER)
   IS
   SELECT header.LIST_HEADER_ID
   FROM   AMS_LIST_HEADERS_ALL header
          ,AMS_ACT_LISTS act_list
   WHERE header.LIST_HEADER_ID = act_list.LIST_HEADER_ID
   and   act_list.LIST_ACT_TYPE = 'TARGET'
   and   act_list.LIST_USED_BY = 'CSCH'
   and act_list.LIST_USED_BY_ID = p_schedule_id;

   -- Get Schedule Details
   CURSOR C_GET_SCHEDULE_DETAILS(p_schedule_id	NUMBER)
   IS
   SELECT activity_id
   FROM AMS_CAMPAIGN_SCHEDULES_B
   WHERE SCHEDULE_ID = p_schedule_id;


   CURSOR C_GET_RULE_DTLS(p_schedule_id NUMBER)
   IS
   SELECT rule_id,rule_type
   FROM   ams_tcop_fr_rules_setup rule,
          ams_campaign_schedules_b schedule,
          ams_tcop_fr_periods_b period
   WHERE  rule.ENABLED_FLAG = 'Y'
   AND    (rule.CHANNEL_ID is null
          OR (rule.CHANNEL_ID = schedule.activity_id) )
   AND    rule.RULE_TYPE in ('GLOBAL' , 'CHANNEL_BASED')
   AND    schedule.SCHEDULE_ID = p_schedule_id
   AND    rule.PERIOD_ID = period.PERIOD_ID
   ORDER BY (rule.MAX_CONTACT_ALLOWED * period.NO_OF_DAYS);

   CURSOR c_Get_Global_Fatigue_list1(p_list_header_id number,
                                    p_rule_id number)
   IS
   SELECT list.LIST_ENTRY_ID,summary.party_id
   FROM ams_tcop_contact_summary summary,
        ams_list_entries list
   WHERE list.LIST_HEADER_ID = p_list_header_id
   AND   summary.PARTY_ID = list.PARTY_ID
   AND   list.ENABLED_FLAG = 'Y'
   AND   summary.total_contacts >= (SELECT max_contact_allowed
                                   FROM ams_tcop_fr_rules_setup
				                       WHERE rule_id =p_rule_id);

   CURSOR c_Get_Global_Fatigue_list2(p_list_header_id number,
                                    p_rule_id number,
                                    p_already_fatigued_list JTF_NUMBER_TABLE
                                    )
   IS
   SELECT list.LIST_ENTRY_ID,summary.party_id
   FROM ams_tcop_contact_summary summary,
        ams_list_entries list
   WHERE list.LIST_HEADER_ID = p_list_header_id
   AND   summary.PARTY_ID = list.PARTY_ID
   AND   list.ENABLED_FLAG = 'Y'
   AND   summary.total_contacts >= (SELECT max_contact_allowed
                                   FROM ams_tcop_fr_rules_setup
				                       WHERE rule_id =p_rule_id)
   AND   list.party_id not in
                 (SELECT column_value
                  FROM TABLE(CAST(p_already_fatigued_list as JTF_NUMBER_TABLE))
                 );
   -- Get the list of parties already over contacted by the channel specific rule
   CURSOR c_Get_Channel_Fatigue_list1(p_list_header_id number,
                                     p_rule_id number,
                                     p_media_id number
                                    )
   IS
   SELECT list.LIST_ENTRY_ID,summary.party_id
   FROM ams_tcop_channel_summary summary,
        ams_list_entries list
   WHERE list.LIST_HEADER_ID = p_list_header_id
   AND   summary.PARTY_ID = list.PARTY_ID
   AND   list.ENABLED_FLAG = 'Y'
   AND   summary.media_id = p_media_id
   AND   summary.total_contacts >= (SELECT max_contact_allowed
                                   FROM ams_tcop_fr_rules_setup
				                       WHERE rule_id =p_rule_id);

   -- Get the list of parties already over contacted by the channel specific rule
   -- But don't consider the list of parties already fatigued by another rule
   CURSOR c_Get_Channel_Fatigue_list2(p_list_header_id number,
                                     p_rule_id number,
                                     p_media_id number,
                                     p_already_fatigued_list   JTF_NUMBER_TABLE
                                    )
   IS
   SELECT list.LIST_ENTRY_ID,summary.party_id
   FROM ams_tcop_channel_summary summary,
        ams_list_entries list
   WHERE list.LIST_HEADER_ID = p_list_header_id
   AND   summary.PARTY_ID = list.PARTY_ID
   AND   list.ENABLED_FLAG = 'Y'
   AND   summary.media_id = p_media_id
   AND   summary.total_contacts >= (SELECT max_contact_allowed
                                   FROM ams_tcop_fr_rules_setup
				                       WHERE rule_id =p_rule_id)
   AND   list.party_id not in
                 (SELECT column_value
                  FROM TABLE(CAST(p_already_fatigued_list as JTF_NUMBER_TABLE))
                 );
   -- Cursor to select the schedules which have already fatigued
   -- people as per the Global Rule
   /**
   CURSOR c_Get_Global_Fatigue_By_List(p_list_header_id number,
                                       p_rule_id number)
   IS
   SELECT list.LIST_ENTRY_ID,sum_dtl.SCHEDULE_ID
   FROM ams_tcop_contact_summary summary,
        ams_list_entries list,
	ams_tcop_contact_sum_dtl sum_dtl
   WHERE list.LIST_HEADER_ID =
   AND   summary.PARTY_ID = list.PARTY_ID
   AND   summary.total_contacts = (SELECT max_contact_allowed
				   FROM ams_tcop_fr_rules_setup
				   WHERE rule_id = p_rule_id)
   AND   summary.CONTACT_SUMMARY_ID = sum_dtl.CONTACT_SUMMARY_ID;
   **/

   -- Cursor to select the schedules which have already fatigued
   -- people as per the Global Rule
   --
   -- Note: Leading Hint is used to improve the performance of the query.
   -- This hint is used to make sure that the optimizer will make the
   -- party_list, the Nested Table as the driving table.
   -- This table should be the driving table since it will
   -- be the smallest table in the join.
   CURSOR c_Get_Global_Fatigue_By_List(p_list_header_id  NUMBER
                                       ,p_ftg_party_list JTF_NUMBER_TABLE)
   IS
   SELECT /*+ leading(party_list) +*/
   list.LIST_ENTRY_ID,sum_dtl.SCHEDULE_ID
   FROM ams_tcop_contact_summary summary,
        ams_list_entries list,
        ams_tcop_contact_sum_dtl sum_dtl,
        (SELECT column_value party_id
	      FROM TABLE(CAST(p_ftg_party_list as JTF_NUMBER_TABLE))
        ) party_list
   WHERE summary.CONTACT_SUMMARY_ID = sum_dtl.CONTACT_SUMMARY_ID
   AND   list.ENABLED_FLAG = 'Y'
   AND   list.list_header_id = p_list_header_id
   AND   summary.party_id = list.party_id
   AND   summary.party_id = party_list.party_id;

   -- Cursor to select the schedules which have already fatigued
   -- people as per the Channel Rule
   --
   -- Note: Leading Hint is used to improve the performance of the query.
   -- This hint is used to make sure that the optimizer will make the
   -- party_list, the Nested Table as the driving table.
   -- This table should be the driving table since it will
   -- be the smallest table in the join.
   CURSOR c_Get_Channel_Fatigue_By_List(p_ftg_party_list JTF_NUMBER_TABLE,
                                        p_media_id       NUMBER,
                                        p_list_header_id NUMBER
                                       )
   IS
   SELECT /*+ leading(party_list) +*/
   list.LIST_ENTRY_ID,sum_dtl.SCHEDULE_ID
   FROM ams_tcop_channel_summary summary,
        ams_list_entries list,
        ams_tcop_channel_sum_dtl sum_dtl,
        (SELECT column_value party_id
	      FROM TABLE(CAST(p_ftg_party_list as JTF_NUMBER_TABLE))
        ) party_list
   WHERE summary.CHANNEL_SUMMARY_ID = sum_dtl.CHANNEL_SUMMARY_ID
   AND   summary.party_id = list.party_id
   AND   summary.party_id = party_list.party_id
   AND   summary.media_id = p_media_id
   AND   list.list_header_id = p_list_header_id;

   -- Get the List of parties not fatigued and will be contacted
   CURSOR C_GET_CONTACTED_PARTY (p_list_header_id  NUMBER,p_fatigue_party_list JTF_NUMBER_TABLE)
   IS
   (SELECT list_entry.PARTY_ID
   FROM   AMS_LIST_ENTRIES list_entry
   WHERE  list_entry.list_header_id = p_list_header_id
   AND    list_entry.ENABLED_FLAG = 'Y')
   MINUS
                       (SELECT column_value
                        FROM TABLE(CAST(p_FATIGUE_PARTY_LIST as JTF_NUMBER_TABLE))
                        );

   -- Get the Sequence value
   CURSOR C_GET_NEXT_CONTACT_SEQ
   IS
   SELECT AMS_TCOP_CONTACTS_S.NEXTVAL
   FROM DUAL;

   -- Get the Sequence value
--   CURSOR C_GET_NEXT_FATIGUE_BY_SEQ
--   IS
--   SELECT AMS_TCOP_FATIGUED_BY_S.NEXTVAL
--   FROM DUAL;

   TYPE Number_Table is Table of Number INDEX BY BINARY_INTEGER;

   -- Temporary List Variables
   l_temp_party_list JTF_NUMBER_TABLE;
   l_temp_entry_list JTF_NUMBER_TABLE;
   l_temp_fatigue_by_entry_list JTF_NUMBER_TABLE;
   l_temp_fatigue_by_sched_list JTF_NUMBER_TABLE;
   l_contacted_party_list  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   -- Other Local Arrays
   l_contact_id_list       Number_Table;
--   l_fatigue_by_id_list    Number_Table;

   -- Other Local Variables
   l_list_header_id	NUMBER;
   l_activity_id	NUMBER;
   l_contact_id   NUMBER;
   l_fatigue_entry_list AMS_ListGeneration_PKG.t_number;
   l_label     VARCHAR2(50);
   l_global_rule_id number;
   l_channel_rule_id number;
   L_CONTACTED_PARTY_COUNT    NUMBER;
   l_temp_count number;
   l_count number;
   l_sequence_id	NUMBER;

   -- Constant
   PROCEDURE_NAME  CONSTANT   VARCHAR2(30) := 'APPLY_FATIGUE_RULES';

BEGIN

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'BEGIN',
                       'Beginning Procedure'
                      );

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'WRITE_INPUT_PARAMETERS',
                       'Applying Traffic Cop for Schedule ID '||to_char(p_schedule_id)
                      );
   AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_ENGINE_PKG.Apply_Fatigue_Rules ====> Begin Apply Fatigue Rules for Schedule ID = ' || to_char(p_schedule_id));


	-- 3/1/2004 mayjain fix for bug 3470706 START
	-- This variable is list of all the parties fatigued
	G_Fatigue_Party_List := JTF_NUMBER_TABLE();

	-- This variable is list of all the list_entry_id that are associated
	-- with fatigue parties
	G_Fatigue_Entry_List := JTF_NUMBER_TABLE();

	-- This is a list of list_entry_id associated with the list
	-- of schedules which fatigued the parties. This list may contain
	-- duplicate entries.
	G_Fatigue_By_Entry_List := JTF_NUMBER_TABLE();

	-- This is a list of list_entry_id associated with the list
	-- of schedules which fatigued the parties
	G_Fatigue_By_Schedule_List := JTF_NUMBER_TABLE();
	-- 3/1/2004 mayjain fix for bug 3470706 END

   -- Get Target Group List Header Id
   OPEN C_Get_List_Header(p_schedule_id);
   FETCH C_Get_List_Header INTO l_list_header_id;
   CLOSE C_Get_List_Header;

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GET_LIST_HEADER_ID',
                       'List Header Id = '||to_char(l_list_header_id)
                      );

   -- Get some of the relevant Schedule Details
   OPEN C_GET_SCHEDULE_DETAILS(p_schedule_id);
   FETCH C_GET_SCHEDULE_DETAILS INTO l_activity_id;
   CLOSE C_GET_SCHEDULE_DETAILS;

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'GET_SCHEDULE_DETAILS',
                       'Activity Id = '||to_char(l_activity_id)
                      );

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'BEFORE_CALLING_SUMMARIZATION',
                       'Before Calling Summarization AMS_TCOP_SUMMARIZATION_PKG.SUMMARIZE_LIST_CONTACTS'
                      );

   -- Summarize Contacts
   AMS_TCOP_SUMMARIZATION_PKG.SUMMARIZE_LIST_CONTACTS(l_list_header_id,l_activity_id);

   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       'AFTER_CALLING_SUMMARIZATION',
                       'After Calling Summarization AMS_TCOP_SUMMARIZATION_PKG.SUMMARIZE_LIST_CONTACTS'
                      );

   -- Get the Applicable Rules for this schedule
   l_label := 'GET_RULE_DETAILS_LOOP';
   FOR C1 in C_GET_RULE_DTLS(p_schedule_id)
   LOOP

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Applicable Fatigue Rule Type = '||C1.RULE_TYPE
                         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Applicable Fatigue Rule Id = '||to_char(C1.RULE_ID)
                         );

      --Apply Global Rules to check which parties are fatigued by this rule
      IF (C1.RULE_TYPE = 'GLOBAL') THEN
         l_global_rule_id := C1.RULE_ID;

         l_label := l_label;

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             l_label,
                             'Applicable Rule Is a Global Rule'
                            );


	write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             l_label,
                             'Size of Global Fatigue Party List = ' || to_char(G_fatigue_party_list.count)
                            );

         IF (G_fatigue_party_list.count = 0) THEN

            -- Get the list of Fatigued Entries already reached a threshold
            -- as per the Global Rule
            OPEN c_Get_Global_Fatigue_list1(l_list_header_id,C1.rule_id);
            FETCH c_Get_Global_Fatigue_list1
            BULK COLLECT INTO l_temp_entry_list,l_temp_party_list;
            CLOSE c_Get_Global_Fatigue_list1;

         ELSE
            -- Since some parties have already been fatigued by other more
            -- restrictive rule, don't need to consider those parties again
            OPEN c_Get_Global_Fatigue_list2(l_list_header_id,C1.rule_id
                                                      ,G_fatigue_party_list);
            FETCH c_Get_Global_Fatigue_list2
            BULK COLLECT INTO l_temp_entry_list,l_temp_party_list;
            CLOSE c_Get_Global_Fatigue_list2;

         END IF;

	      IF (l_temp_entry_list.exists(1)) then

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                l_label,
                                'There are parties fatigued by Global Rule and the total number is = '||to_char(l_temp_entry_list.count)
                               );

            -- Get the List of Schedules which are responsible for fatiguing
            -- the entrie
            OPEN c_Get_Global_Fatigue_By_List(l_list_header_id,
                                              l_temp_party_list
                                              );
            FETCH c_Get_Global_Fatigue_By_List
            BULK COLLECT INTO l_temp_fatigue_by_entry_list
                            ,l_temp_fatigue_by_sched_list;
            CLOSE c_Get_Global_Fatigue_By_List;

	         IF (l_temp_fatigue_by_entry_list.exists(1)) then

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   l_label,
                                   ' Number of Schedules found which caused the fatigue = '||to_char(l_temp_fatigue_by_entry_list.count)
                                  );

            END IF;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                l_label,
                                'Copy the Temporary List to Global List'
                               );

            -- Copy the temporary variables into the Global lists
            APPEND_GLOBAL_FATIGUE_LIST(l_temp_party_list,
                             l_temp_entry_list,
                             l_temp_fatigue_by_entry_list,
                             l_temp_fatigue_by_sched_list
                   );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                l_label,
                                'Temporary List Successfully copied to Global List'
                               );
         END IF;

      END IF;

      --Apply Channel based Rules to check which parties are fatigued by this rule
      IF (C1.RULE_TYPE = 'CHANNEL_BASED') THEN
         l_channel_rule_id := C1.RULE_ID;
         l_label := l_label;

         write_debug_message(LOG_LEVEL_EVENT,
                             PROCEDURE_NAME,
                             l_label,
                             'Applicable Rule Is a Channel Rule'
                            );

         -- Get the list of Fatigued Entries already reached a threshold
	      -- as per the Channel Rule
         IF (G_Fatigue_Party_List.count = 0) THEN
            OPEN c_Get_Channel_Fatigue_list1(l_list_header_id,
                                            C1.rule_id,
                                            l_activity_id);
            FETCH c_Get_Channel_Fatigue_list1
            BULK COLLECT INTO l_temp_entry_list,l_temp_party_list;
            CLOSE c_Get_Channel_Fatigue_list1;
         ELSE
            OPEN c_Get_Channel_Fatigue_list2(l_list_header_id,
                                            C1.rule_id,
                                            l_activity_id,
                                            G_fatigue_party_list
                                            );
            FETCH c_Get_Channel_Fatigue_list2
            BULK COLLECT INTO l_temp_entry_list,l_temp_party_list;
            CLOSE c_Get_Channel_Fatigue_list2;
         END IF;

         IF (l_temp_entry_list.exists(1)) then

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                l_label,
                                'Channel Rule has fatigued some parties and the count = '||to_char(l_temp_entry_list.count)
                               );

            -- Get the List of Schedules which are responsible for fatiguing
            -- the entries
            OPEN c_Get_Channel_Fatigue_By_List(l_temp_party_list
                                               ,l_activity_id
                                               ,l_list_header_id
                                               );
            FETCH c_Get_Channel_Fatigue_By_List
            BULK COLLECT INTO l_temp_fatigue_by_entry_list
                           ,l_temp_fatigue_by_sched_list;
            CLOSE c_Get_Channel_Fatigue_By_List;

	         IF (l_temp_fatigue_by_entry_list.exists(1)) then

               write_debug_message(LOG_LEVEL_EVENT,
                                   PROCEDURE_NAME,
                                   l_label,
                                   'Schedules found which caused the fatigue and the number of schedules = '||to_char(l_temp_fatigue_by_entry_list.count)
                                  );

            END IF;

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                l_label,
                                'Copy the Temporary List to Global List'
                               );

            -- Copy the temporary variables into the Global lists
            APPEND_GLOBAL_FATIGUE_LIST(l_temp_party_list,
                                       l_temp_entry_list,
                                       l_temp_fatigue_by_entry_list,
                                       l_temp_fatigue_by_sched_list
                                      );

            write_debug_message(LOG_LEVEL_EVENT,
                                PROCEDURE_NAME,
                                l_label,
                                'Temporary List Successfully copied to Global List'
                               );
         END IF;

      END IF;

   END LOOP;


   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'BEFORE_API_CALL',
                       'Before Calling APPLY_PARTY_OPT_IN_PREFERENCES API'
                      );
   -- Check if party's OPT-IN Preferences are set or not
   -- This API will add parties to the Fatigue List based on the following:
   -- 1. The Opt-In preferences for the parties must have been set
   -- 2. The number of contacts already reached the maximum threshold
   --    as per the contact preferences.
   APPLY_PARTY_OPT_IN_PREFERENCES(l_list_header_id,l_activity_id);

   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       'AFTER_API_CALL',
                       'After Calling APPLY_PARTY_OPT_IN_PREFERENCES API'
                      );

   -- Once the fatigue list is produced, update the AMS_LIST_ENTRIES
   -- , set the enabled_flag to N,MARKED_AS_FATIGUED_FLAG to Y, update the
   -- counts in the List Header
   --
   IF (G_Fatigue_Entry_List.EXISTS(1)) THEN
      l_label := 'DISABLE_LIST_ENTRIES';

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Before Copying the Nested Table to Index By Table'
                         );

      -- First, copy the Nested Table to a Index By Table
      FOR i IN G_Fatigue_Entry_List.FIRST .. G_Fatigue_Entry_List.LAST
      LOOP
         l_fatigue_entry_list(i) := G_Fatigue_Entry_List(i);
      END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Successfully copied Nested Table to Index By Table'
                         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Total Number of fatigued entries = '||to_char(l_fatigue_entry_list.count)
                         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Before Calling AMS_ListGeneration_PKG.UPDATE_FOR_TRAFFIC_COP'
                         );

      AMS_ListGeneration_PKG.UPDATE_FOR_TRAFFIC_COP
                          ( p_list_header_id => l_list_header_id,
                            p_list_entry_id => l_fatigue_entry_list);

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'After Calling AMS_ListGeneration_PKG.UPDATE_FOR_TRAFFIC_COP'
                         );

   END IF;

   l_label := 'SET_TCOP_FATIGUED_BY';
   l_count := G_Fatigue_By_Entry_List.count;
   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       l_label,
                       'Ready to create entries in AMS_TCOP_FATIGUED_BY. Number of entries = '||to_char(l_count)
                      );
   AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_ENGINE_PKG.Apply_Fatigue_Rules ====> Ready to create entries in AMS_TCOP_FATIGUED_BY. Number of entries = '||to_char(l_count));


   --Bulk Insert into AMS_TCOP_FATIGUED_BY table
   IF(l_count > 0) THEN
      -- Create an array of Sequence number
--      FOR i in G_Fatigue_By_Entry_List.FIRST .. G_Fatigue_By_Entry_List.LAST
--      LOOP
--         OPEN C_GET_NEXT_FATIGUE_BY_SEQ;
--         FETCH C_GET_NEXT_FATIGUE_BY_SEQ
--         INTO l_sequence_id;
--        CLOSE C_GET_NEXT_FATIGUE_BY_SEQ;
--         l_fatigue_by_id_list(i) := l_sequence_id;


--      END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Before Calling BULK Insert into AMS_TCOP_FATIGUE_BY'
                         );
      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Total Number of entries in Fatigue By Entry List ='||to_char(G_Fatigue_By_Entry_List.count)
                         );
      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Total Number of entries in Fatigue By Schedule List ='||to_char(G_Fatigue_By_Schedule_List.count)
                         );

      -- Do a Bulk Insert into AMS_TCOP_FATIGUE_BY Table
      FOR i in G_Fatigue_By_Entry_List.FIRST .. G_Fatigue_By_Entry_List.LAST
      LOOP
         INSERT INTO
         AMS_TCOP_FATIGUED_BY
         (fatigued_by_id,
          list_entry_id,
          schedule_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
         )
         VALUES
         (--l_fatigue_by_id_list(i),
          AMS_TCOP_FATIGUED_BY_S.NEXTVAL,
	  G_Fatigue_By_Entry_List(i),
          G_Fatigue_By_Schedule_List(i),
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID
         );
      END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'After Calling BULK Insert into AMS_TCOP_FATIGUED_BY'
                         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'UPDATE_CONTACT_SUMMARY',
                          'Before Calling AMS_TCOP_SUMMARIZATION_PKG.UPDATE_CONTACT_COUNT'
                         );

   l_label := 'SET_TCOP_CONTACTS';
   write_debug_message(LOG_LEVEL_PROCEDURE,
                       PROCEDURE_NAME,
                       l_label,
                       'Ready to create entries in AMS_TCOP_CONTACTS'
                      );

   END IF;

   -- Get the list of contacted party
   OPEN C_GET_CONTACTED_PARTY(l_list_header_id,g_fatigue_party_list);
   FETCH C_GET_CONTACTED_PARTY
   BULK COLLECT INTO l_contacted_party_list;
   CLOSE C_GET_CONTACTED_PARTY;

   l_contacted_party_count := l_contacted_party_list.count;
   write_debug_message(LOG_LEVEL_EVENT,
                       PROCEDURE_NAME,
                       l_label,
                       'Total Number of contacts = '||
                           to_char(l_contacted_party_count)
                      );

   --Update the AMS_TCOP_CONTACTS table
   IF (l_contacted_party_count > 0) THEN
      -- Create an array of Sequence number
      FOR i in l_contacted_party_list.FIRST .. l_contacted_party_list.LAST
      LOOP
         OPEN C_GET_NEXT_CONTACT_SEQ;
         FETCH C_GET_NEXT_CONTACT_SEQ
         INTO l_CONTACT_ID;
         CLOSE C_GET_NEXT_CONTACT_SEQ;

         l_contact_id_list(i) := l_CONTACT_ID;
      END LOOP;

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'Before Calling BULK Insert into AMS_TCOP_CONTACTS'
                         );

      -- Do a Bulk Insert into AMS_TCOP_CONTACTS Table
      FORALL i in l_contacted_party_list.FIRST .. l_contacted_party_list.LAST
         INSERT INTO
         AMS_TCOP_CONTACTS
         (contact_id,
          party_id,
          schedule_id,
          media_id,
          contact_date,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
         )
         VALUES
         (l_contact_id_list(i),
          l_contacted_party_list(i),
          p_schedule_id,
          l_activity_id,
          sysdate,
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID
         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          l_label,
                          'After Calling BULK Insert into AMS_TCOP_CONTACTS'
                         );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'UPDATE_CONTACT_SUMMARY',
                          'Before Calling AMS_TCOP_SUMMARIZATION_PKG.UPDATE_CONTACT_COUNT'
                         );
      -- Update Summary
      AMS_TCOP_SUMMARIZATION_PKG.UPDATE_CONTACT_COUNT(
                                                      l_contacted_party_list,
                                                      p_schedule_id,
                                                      l_activity_id,
                                                      l_global_rule_id,
                                                      l_channel_rule_id
                                                     );

      write_debug_message(LOG_LEVEL_EVENT,
                          PROCEDURE_NAME,
                          'UPDATE_CONTACT_SUMMARY',
                          'After Calling AMS_TCOP_SUMMARIZATION_PKG.UPDATE_CONTACT_COUNT'
                         );
   END IF;

   -- Update the Request Status to 'ACTIVE' to indicate
   -- that Traffic Cop Engine Processing is going on
   AMS_TCOP_SCHEDULER_PKG.UPDATE_STATUS(p_schedule_id,'COMPLETED');

END Apply_Fatigue_Rules;

END AMS_TCOP_ENGINE_PKG;

/
