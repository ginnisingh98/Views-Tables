--------------------------------------------------------
--  DDL for Package Body AMS_LISTDEDUPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTDEDUPE_PVT" as
/* $Header: amsvlddb.pls 120.2.12010000.3 2009/06/26 08:09:54 hbandi ship $ */
-- Start of Comments
--
-- NAME
--   AMS_ListDedupe_PVT
--
-- PURPOSE
--   This package is a Private API for managing List Deduplication information in
--   AMS.  It contains specification for pl/sql records and tables
--
-- Functions:
--  Exec_Sql_Stmt (see below for specification)
--  Filter_Word (see below for specification)
--  Dedupe_List (see below for specification)
--
--   Procedures:
--	Write_To_Act_Log (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
--
--  06/29/1999  khung       created
--  07/07/1999  khung       modify -> only one rule per list
--  07/22/1999  khung       changed package name and file name
--  08/02/1999  khung       add write_to_act_log funtion (8i)
--  09/30/1999  khung       add the capability to dedupe the entries
--                          from AMS_IMP_SOURCE_LINE table
--  11/11/1999  choang      Moved Generate_Key from AMS_PartyImport_PVT.
--  01/11/2000  khung       Add more debug code for LIST_RULE checking
--  09/27/2000  vbhandar    Made changes to dedupe_list and c_dedupe_keys cursor
--  10/19/2000  vbhandar    Made changes to dedupe_list to fix problem with dedup not working for more than 1 rank
--  11/07/2000  vbhandar    Made changes to dedupe_list to synchronize enabled flag with non deduped entries
--  11/15/2000  vbhandar    Made changes to filter word to do case insensitive comparison
--  26/06/2001  gjoby       changed the selection query  - For Hornet
--
-- End of Comments

-- global constants
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'AMS_ListDedupe_PVT';
  g_original_text VARCHAR2(50) := 'z!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~';
  g_replace_text  VARCHAR2(50) := 'z';

  TYPE original_key     IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  TYPE replacement_key  IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

  g_original_key        original_key;
  g_replacement_key     replacement_key;
  g_special_enabled     VARCHAR2(1);


/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Exec_Sql_Stmt
--    Type        : Private
--    Function    : This function takes a dunamic SQL stmt and executes it
--
--    Pre-reqs    : None
--    Paramaeters :
--  IN      :
--      p_stmt      VARCHAR2
--
-- End Of Comments

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION Exec_Sql_Stmt (p_stmt VARCHAR2)
RETURN NUMBER
   IS

--  l_sqlerrm           VARCHAR2(1000);
--  l_sqlcode           VARCHAR2(1000);
    l_cursor_name       INTEGER;
    l_rows_processed    INTEGER;
BEGIN

    --executing dynamic sql statement to populate the merge_key field in ams_list_entries.

    l_cursor_name := DBMS_SQL.open_cursor;
    --insert into temp(text2) values('after open cursor');commit;

    DBMS_SQL.parse (l_cursor_name, p_stmt, DBMS_SQL.native);
    --insert into temp(text2) values('after sql parse');commit;

    l_rows_processed := DBMS_SQL.execute (l_cursor_name);
    --insert into temp(text2) values('after execute');commit;

    DBMS_SQL.close_cursor (l_cursor_name);
    --insert into temp(text2) values('after close cursor');commit;

    RETURN  (l_rows_processed);

END Exec_Sql_Stmt;

/*****************************************************************************************/
-- Start of Comments
--
--    NAME
--	Write_To_Act_Log

--    PURPOSE
--	Any log messages we write to the ams_act_logs table are commited even if
--	the whole process is ROLLED BACK because of a processing error.
--	(8i new feature -- AUTONOMOUS TRANSACTIONS)
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--      p_list_header_id    NUMBER
--      p_msg_data          VARCHAR2
--
--    NOTES
--
--
--    HISTORY
--      08/02/1999  khung    created

-- End Of Comments

PROCEDURE Write_To_Act_Log
 (p_list_header_id  IN NUMBER
 ,p_msg_data        IN VARCHAR2,
  p_level           in varchar2 default 'LOW'
 ) IS

--PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

   if nvl(ams_listgeneration_pkg.g_log_level,'HIGH') = 'HIGH' and p_level = 'LOW' then
      return;
   end if;

   ams_listgeneration_pkg.write_to_act_log(p_msg_data,'LIST',p_list_header_id,p_level);

   /*
   ams_listgeneration_pkg.g_message_table(ams_listgeneration_pkg.g_count) := p_msg_data;
   ams_listgeneration_pkg.g_date(ams_listgeneration_pkg.g_count) := sysdate;
   ams_listgeneration_pkg.g_count   := ams_listgeneration_pkg.g_count + 1;
   */

   /* INSERT INTO ams_act_logs
    ( activity_log_id
     ,last_update_date
     ,last_updated_by
     ,creation_date
     ,created_by
     ,last_update_login
     ,object_version_number
     ,act_log_used_by_id
     ,arc_act_log_used_by
     ,log_transaction_id
     ,log_message_text
     ,log_message_level
     ,log_message_type
     ,description
    )
    VALUES
    (
     ams_act_logs_s.nextval,
     sysdate,
     fnd_global.user_id,
     sysdate,
     fnd_global.user_id,
     fnd_global.conc_login_id,
     1, -- object_version_number
     p_list_header_id,
     'LIST',
     ams_act_logs_transaction_id_s.nextval,
     p_msg_data,
     null,
     null,
     null);

    COMMIT; */

END Write_To_Act_Log;

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Filter_Word
--    Type        : Private
--    Function    : Replaces all noise words for the relevant fields in AMS_LIST_ENTRIES
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN    :
--      p_word          VARCHAR2
--      p_substr_len    AMS_LIST_RULE_FIELDS.SUBSTRING_LEN%TYPE
--      p_table_name    AMS_LIST_RULE_FIELDS.FIELD_TABLE_NAME%TYPE
--      p_column_name   AMS_LIST_RULE_FIELDS.FIELD_COLUMN_NAME%TYPE
--
-- End Of Comments

FUNCTION Filter_Word
 (p_word                VARCHAR2
 ,p_substr_len          AMS_LIST_RULE_FIELDS.SUBSTRING_LENGTH%TYPE
 ,p_field_table_name    AMS_LIST_RULE_FIELDS.FIELD_TABLE_NAME%TYPE
 ,p_field_column_name   AMS_LIST_RULE_FIELDS.FIELD_COLUMN_NAME%TYPE
 )
RETURN VARCHAR2

    IS
    -- PL/SQL Block
    -- this will select all noise words for the relevant field in list_entries
    -- table and column name are the PK fields for this table.
    CURSOR c_noise_words (my_field_table_name IN VARCHAR, my_field_column_name IN VARCHAR)
    IS
        SELECT w.original_word, w.replacement_word
          FROM ams_list_word_fields w
         WHERE w.field_table_name = my_field_table_name
           AND w.field_column_name = my_field_column_name;

    l_original_word     ams_list_word_fields.original_word%TYPE;
    l_replacement_word  ams_list_word_fields.replacement_word%TYPE;
    l_word              VARCHAR2(500);

BEGIN
    --we always compare in uppercase.

    l_word := UPPER (p_word);

    OPEN c_noise_words (p_field_table_name, p_field_column_name);
    LOOP
        FETCH c_noise_words INTO l_original_word, l_replacement_word;
        EXIT WHEN c_noise_words%notfound;

        --substituting the original with the replacement words.
        --pv_word := replace(pv_word,pv_original_word,NVL(pv_replacement_word,'NULL'));
        --09/28/2000 VB modified
        --change case to UPPER before comparison because l_word was made UPPER case!!
        IF  (l_word = UPPER(l_original_word))
        THEN
            l_word := NVL (UPPER(l_replacement_word), 'NULL');-- modified vb 11/15/2000
        END IF;
    END LOOP;
    CLOSE c_noise_words;

    -- if the rule specifies to only take into account 1..p_substr_len characters
    IF  (p_substr_len IS NULL)
    THEN
        RETURN  (l_word);
    ELSE
        RETURN  (SUBSTR (l_word, 1, p_substr_len));
    END IF;

END Filter_Word;

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Dedupe_List
--    Type        : Private
--    Function    : Replaces all noise words for the relevant fields in AMS_LIST_ENTRIES
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN		:
--      p_list_header_id                AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE
--      p_enabled_wordreplacement_flag  AMS_LIST_HEADERS_ALL.ENABLED_WORDREPLACEMENT_FLAG%TYPE
--      p_send_to_log                   VARCHAR2 := 'N'
--      p_object_name                   VARCHAR2 := 'AMS_LIST_ENTRIES'
--
--    HISTORY
--      08/02/1999  khung   created
--      09/30/1999  khung   add the capability to dedupe the entries
--                          from AMS_IMP_SOURCE_LINE table
-- End Of Comments

FUNCTION Dedupe_List
 (p_list_header_id        AMS_LIST_HEADERS_ALL.LIST_HEADER_ID%TYPE
 ,p_enable_word_replacement_flag
                          AMS_LIST_HEADERS_ALL.ENABLE_WORD_REPLACEMENT_FLAG%TYPE
 ,p_send_to_log           VARCHAR2 := 'N'
 ,p_object_name           VARCHAR2 := 'AMS_LIST_ENTRIES'
 )
RETURN NUMBER IS
    -- the set of rules associated with a list.
    CURSOR c_list_rules (my_list_header_id IN NUMBER)
    IS SELECT list_rule_id
       FROM ams_list_rule_usages
       WHERE list_header_id = my_list_header_id
       ORDER BY priority;

    -- the list of fields for the list rule which are used to generate the key.
    CURSOR c_rule_fields
           (my_list_rule_id IN
            ams_list_rules_all.list_rule_id%TYPE)
    IS
        SELECT field_table_name,
               field_column_name,
               substring_length,
               word_replacement_code
        FROM ams_list_rule_fields
        WHERE list_rule_id = my_list_rule_id;

    -- perform a check to see if this list has been deduped already.
    CURSOR c_deduped_before (my_list_header_id IN NUMBER)
    IS
        SELECT last_deduped_by_user_id
        FROM ams_list_headers_all
        WHERE list_header_id = my_list_header_id;

    -- get a distinct list of merge keys for the list and a
    -- count of the occurance of each key
    -- we also exclude any records where the dedupe flag is already set.
    CURSOR c_dedupe_keys (my_list_header_id IN NUMBER)
    IS
        SELECT DISTINCT dedupe_key, COUNT (dedupe_key)
        FROM ams_list_entries
         WHERE list_header_id = my_list_header_id
  --    AND marked_as_duplicate_flag IS NULL  --commented by VB
  -- 09/30/2000 because this is a not null column in database
         GROUP BY dedupe_key;


    l_sql_stmt1         VARCHAR2(10000);
    l_sql_stmt2         VARCHAR2(10000);

    --l_sqlerrm         VARCHAR2(1000);
    --l_sqlcode         VARCHAR2(1000);
    l_fields            VARCHAR2(10000);
    --l_temp_fields            VARCHAR2(10000);
    l_no_of_masters     NUMBER := 0;
    l_list_rule_id      ams_list_rules_all.list_rule_id%TYPE;
    --l_list_entry_id   ams_list_entries.list_entry_id%TYPE;
    l_last_dedupe_by    ams_list_headers_all.last_deduped_by_user_id%TYPE;
    l_dedupe_key        ams_list_entries.dedupe_key%TYPE;
    l_dedupe_key_count  NUMBER;
    l_rank_count        NUMBER;
    i                   BINARY_INTEGER := 1;

    TYPE rule_details
    IS TABLE OF c_rule_fields%ROWTYPE
    INDEX BY BINARY_INTEGER;

    list_rules          rule_details;
    empty_list_rules    rule_details;
    l_no_of_duplicates    number := 0;
BEGIN

    IF (p_object_name = 'AMS_LIST_ENTRIES') THEN
        l_sql_stmt1 := 'update ams_list_entries set dedupe_key = ';
    ELSIF (p_object_name = 'AMS_IMP_SOURCE_LINES') THEN
        l_sql_stmt1 := 'update ams_imp_source_lines set dedupe_key = ';
    ELSE
        RETURN 0;
    END IF;

    --performing check to see if this list has been deduped before.
    OPEN c_deduped_before (p_list_header_id);
    FETCH c_deduped_before INTO l_last_dedupe_by;
    CLOSE c_deduped_before;

    IF  (p_send_to_log = 'Y') THEN
        Write_To_Act_Log (p_list_header_id,
                        'Executing dedupe_list procedure' ,'LOW' );
        IF  (p_enable_word_replacement_flag = 'Y') THEN
            Write_To_Act_Log (p_list_header_id,'Enable word replacement flag has been set','LOW' );
        END IF;
        COMMIT;

    END IF;

    -- we must ensure that this flag gets reset to NULL for the list to
    -- ensure accurate results.
    -- if a dedupe has never been perfomed then this field will contains
    -- NULLS and there is no
    -- need to perform this update
    IF  (l_last_dedupe_by IS NOT NULL) THEN
        UPDATE ams_list_entries
           SET dedupe_key = NULL
   --           ,marked_as_duplicate_flag = NULL
    -- because column is not null in database
         WHERE list_header_id = p_list_header_id;

        IF  (p_send_to_log = 'Y') THEN
            Write_To_Act_Log (p_list_header_id,'Dedupe already done. Dedupe key reset to NULL.','LOW') ;
        END IF;

    END IF;

    -- checking to see if there are any List Source Ranks associated
    -- with the List.
    SELECT COUNT (rank)
      INTO l_rank_count
      FROM ams_list_select_actions
     WHERE action_used_by_id = p_list_header_id
       and arc_action_used_by = 'LIST';

    IF  (p_send_to_log = 'Y')
    THEN
        Write_To_Act_Log (p_list_header_id,'No of Ranks for this list = ' ||TO_CHAR (l_rank_count), 'LOW' );
    END IF;

    --getting the list rules for the list.
    OPEN c_list_rules (p_list_header_id);
    LOOP
        FETCH c_list_rules INTO l_list_rule_id;

        IF  (p_send_to_log = 'Y') THEN
            Write_To_Act_Log (p_list_header_id,
                      'List rule id = ' ||TO_CHAR (l_list_rule_id),'LOW');
        END IF;

        IF (c_list_rules%notfound) THEN
          --  DBMS_OUTPUT.PUT_LINE('no list rule provided.');
            IF  (p_send_to_log = 'Y')
            THEN
                Write_To_Act_Log (p_list_header_id,'No more list rule associated with the list' ,'LOW' );
            END IF;

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
            THEN
                 FND_MESSAGE.set_name('AMS', 'AMS_LIST_NO_LIST_RULE');
                 FND_MSG_PUB.add;
            END IF;

            CLOSE c_list_rules;
            RETURN 0;
        END IF;


      IF  (c_list_rules%rowcount > 1) THEN
          --we have more than one rule for this list
          --we must ensure that the key gets reset to NULL for the list to
          -- ensure accurate results.
          -- removed khung 07/07/1999
         IF (p_object_name = 'AMS_LIST_ENTRIES') THEN
             UPDATE ams_list_entries
             SET dedupe_key = NULL
             WHERE list_header_id = p_list_header_id
             AND marked_as_duplicate_flag IS NULL;
             COMMIT;
         END IF;

         IF  (p_send_to_log = 'Y') THEN
             Write_To_Act_Log (p_list_header_id,'Only one rule can be associated with the list','LOW' );
         END IF;

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_LIST_ONLY_ONE_LIST_RULE');
            FND_MSG_PUB.add;
         END IF;

         CLOSE c_list_rules;
         RETURN 0;
      END IF; -- End of if for more than 1 rule count

      Write_To_Act_Log (p_list_header_id, 'starting  rule attributes','LOW' );
        --fetch the rule entries associated with this list.
        OPEN c_rule_fields (l_list_rule_id);
        LOOP
            FETCH c_rule_fields INTO
                         list_rules (i).field_table_name,
                         list_rules (i).field_column_name,
                         list_rules (i).substring_length,
                         list_rules (i).word_replacement_code;
            EXIT WHEN c_rule_fields%notfound;


            -- if the enable word replacement flag is set we construct the sql
            -- to call the filter word function.
            IF  (p_enable_word_replacement_flag = 'Y') THEN
                Write_To_Act_Log (p_list_header_id, 'Calling replace word procedure','LOW' );
                l_fields :=
                  l_fields ||
                      'AMS_ListDedupe_PVT.replace_word(' ||
                      upper(list_rules (i).field_column_name) ||
                      ',' ||
                      '''' ||
                      list_rules (i).word_replacement_code||
                      '''' ||
                      ')' ||
                      '||' ||
                      '''' ||
                      '.' ||
                      '''' ||
                      '||';

            ELSE
            --no substr specified for the rule field.
                IF  (list_rules (i).substring_length IS NULL)
                THEN
                    l_fields :=
                      l_fields ||
                      'upper(' ||
                      list_rules (i).field_column_name ||
                      ')||' ||
                      '''' ||
                      '.' ||
                      '''' ||
                      '||';
                ELSE
                    l_fields :=
                      l_fields ||
                      'upper(substr(' ||
                      list_rules (i).field_column_name ||
                      ',1,' ||
                      TO_CHAR (list_rules (i).substring_length) ||
                      '))||' ||
                      '''' ||
                      '.' ||
                      '''' ||
                      '||';
                END IF;
            END IF;

            i := i + 1;

        END LOOP;   --c_rule_fields

        i := 1;   --reseting to one.
        list_rules := empty_list_rules;   --re-initializing because we can have many rules.
	if c_rule_fields%rowcount = 0 then
	   write_to_act_log(p_list_header_id, 'No attribute defined for the dedupe rule attached to this list/tg. Aborting deduplication process','HIGH');
	   return -1;
	end if;
	CLOSE c_rule_fields;


	-- removing the last '.' from the string as this will cause an invalid syntax error
        -- in the query.

        l_fields := SUBSTR (l_fields, 1, LENGTH (l_fields) - 7);

        --constucting the valid sql to be executed.
        -- 08/02/99 khung, modified using Native Dynamic SQL

        -- removed by khung 09/30/1999 to support AMS_IMP_SOURCE_LINES
        --l_sql_stmt1 := 'update ams_list_entries set dedupe_key =';
        l_sql_stmt2 := l_sql_stmt1;
        l_sql_stmt2 := l_sql_stmt2 ||
                l_fields ||
                ' where list_header_id =' ||
                TO_CHAR (p_list_header_id);


        IF  (p_send_to_log = 'Y')
        THEN
            Write_To_Act_Log (p_list_header_id,'SQL to generate Merge Keys = ' ||l_sql_stmt2,'LOW');
        END IF;

        -- executing the sql to generate the dedupe_key which has also been filtered.

        -- l_no_of_masters := exec_sql_stmt (l_sql_stmt2);

        -- 08/02/99 khung, modified using Native Dynamic SQL
        --EXECUTE IMMEDIATE l_sql_stmt2
        --    INTO l_no_of_masters;

        --09/27/2000 vbhandar,modified Execute immediate , INTO should only be used for single row queries
	--notice that l_no_of_masters is not really used, left it there to keep the signature of the function Dedupe_LIST unchanged.
	 EXECUTE IMMEDIATE l_sql_stmt2;

        COMMIT;

        -- getting a distinct set of merge keys for this list and the count of each occurance of the key.
        -- if there is only one key then we know that there are no duplicates for this key as defined by
        -- the rule.
        -- if there is more than one occurance then we need to choose one of the candidates as the master
        -- and flag the rest as duplicates, we use the RANK for the List Sources to choose a Master
        -- Entries, if no Ranks Exist then we arbitrarily choose a Master.
        OPEN c_dedupe_keys (p_list_header_id);
        LOOP
            FETCH c_dedupe_keys INTO l_dedupe_key, l_dedupe_key_count;
            EXIT WHEN c_dedupe_keys%notfound;

            --there are duplicates, we must choose the master entry and flag the rest as duplicates.
            IF  (l_dedupe_key_count > 1)
            THEN

                IF  (l_rank_count = 0)
                THEN   -- there are no ranks assoociated with the list source so we can choose at random.

                    UPDATE ams_list_entries
                       SET marked_as_duplicate_flag = 'Y',
                           enabled_flag='N'  --modified vb 11/7/2000
                     WHERE list_header_id = p_list_header_id
                       AND dedupe_key = l_dedupe_key
                       AND list_entry_id <> ( SELECT MIN (c.list_entry_id)
                                     FROM ams_list_entries c
                                     WHERE c.list_header_id = p_list_header_id
                                     AND c.dedupe_key = l_dedupe_key
				     AND  enabled_flag='Y' --  added by hbandi for the BUG #8358168
				     );
                ELSE   --there are ranks associated with at least one list source.
                    --modified vb 10/19/2000 to fix bug where dedup not working with more than 1 rank
                    UPDATE ams_list_entries
                       SET marked_as_duplicate_flag = 'Y',enabled_flag='N'--modified vb 11/7/2000
                     WHERE list_header_id = p_list_header_id
                       AND dedupe_key = l_dedupe_key
                       AND list_entry_id <> ( SELECT MIN (c.list_entry_id)
                                              --selecting the master.
                                              FROM ams_list_entries c,
                                              ams_list_select_actions a
                                              WHERE c.list_header_id =
                                                             p_list_header_id
                                                 AND c.dedupe_key = l_dedupe_key
						 AND  enabled_flag='Y' --  added by hbandi for the BUG #8605416
                        AND c.list_select_action_id = a.list_select_action_id);
/*
			AND a.rank =(SELECT min(b.rank)
			              FROM ams_list_select_actions b
                                WHERE b.action_used_by_id = p_list_header_id
                                  and b.arc_action_used_by = 'LIST')
                                GROUP BY a.rank); */
                                            --even if there are no ranks for this sql stmt we will still
                                            --return one row.

                END IF;
            END IF;
        END LOOP;   --c_dedupe_keys loop
        CLOSE c_dedupe_keys;
        --initializing as we may have more than one rule.

        l_fields := NULL;
        l_sql_stmt2 := l_sql_stmt1;

        IF  (p_send_to_log = 'Y')      THEN
           write_to_act_log(p_list_header_id, 'Duplicates identified and marked for this rule','HIGH');
	END IF;

    END LOOP;   --c_list_rules loop

/*    IF  (p_send_to_log = 'Y')
    THEN
        Write_To_Act_Log (p_list_header_id,
                  'All the rules are applied' ||
                  TO_CHAR (SYSDATE, 'DD-MON-RRRR HH24:MM:SS') );
    END IF;*/

    --recording who performed the deduplication and at what time.
    UPDATE ams_list_headers_all
       SET last_deduped_by_user_id = FND_GLOBAL.User_Id
           ,last_dedupe_date = SYSDATE
     WHERE list_header_id = p_list_header_id;

/*    IF  (p_send_to_log = 'Y')
    THEN
        Write_To_Act_Log (p_list_header_id,
                  'DEDUPE LIST: RECORDING WHO DEUPED THE LIST AND THE DATE' ||
                  TO_CHAR (SYSDATE, 'DD-MON-RRRR HH24:MM:SS') );
    END IF;*/

    --recording the number of duplicates found.
    UPDATE ams_list_headers_all
       SET no_of_rows_duplicates = (
            SELECT COUNT (*)
              FROM ams_list_entries
             WHERE list_header_id = p_list_header_id
               AND marked_as_duplicate_flag = 'Y')
     WHERE list_header_id = p_list_header_id
     returning no_of_rows_duplicates into l_no_of_duplicates;

    IF  (p_send_to_log = 'Y')
    THEN
        Write_To_Act_Log (p_list_header_id,'No of duplicates found for this list is ' ||l_no_of_duplicates,'HIGH');
    END IF;

    COMMIT;

    RETURN  (l_no_of_masters);

END Dedupe_List;


--------------------------------------------------------------------
-- PROCEDURE
--    Generate_Key
-- HISTORY
-- 10-Nov-1999 choang      Created.
-- 11-Nov-1999 choang      Moved to AMS_ListDedupe_PVT.
--------------------------------------------------------------------
PROCEDURE Generate_Key (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2  := FND_API.g_false,
   p_validation_level   IN    NUMBER    := FND_API.g_valid_level_full,

   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2,

   p_list_rule_id       IN    NUMBER,
   p_sys_object_id      IN    NUMBER,
   p_sys_object_id_field   IN    VARCHAR2,
   p_word_replacement_flag IN VARCHAR2,
   x_dedupe_key         OUT NOCOPY   VARCHAR2
)
IS
   L_KEY_LENGTH         CONSTANT NUMBER := 500;
   L_API_VERSION        CONSTANT NUMBER := 1.0;
   L_API_NAME           CONSTANT VARCHAR2(30) := 'Generate_Key';
   L_FULL_NAME          CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

   l_dedupe_key         VARCHAR2(4000);
   l_field_column_name  VARCHAR2(30);
   l_field_table_name   VARCHAR2(30);
   l_substring_length   NUMBER;
   --
   -- The following 3 variables used to construct
   -- a SQL statement which has the format:
   --    SELECT word1, word2, etc.
   --    FROM   field_table_name
   --    WHERE  id = p_sys_object_id
   -- This statement is used to retrive the
   -- dedupe key for the specified record.
   l_select_sql         VARCHAR2(4000);
   l_from_sql           VARCHAR2(4000);
   l_where_sql          VARCHAR2(4000);

   l_return_status   VARCHAR2(1);

   --
   -- LIST_RULE_FIELDS defines the tables and columns involved
   -- in generating a key.  The key can also be a substring of
   -- the specified column.
   -- NOTE: Only substring is needed; we do not need to pad
   -- the data if it is shorter than the specified substring
   -- length.
    CURSOR c_fields IS
    SELECT field_table_name,
           field_column_name,
           substring_length
      FROM ams_list_rule_fields
     WHERE list_rule_id = p_list_rule_id;
BEGIN
   --------------------- initialize -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Start');
   END IF;

   IF FND_API.to_boolean (p_init_msg_list) THEN
      -- Clear out the message buffer.
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call (
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ----------------------- generate -----------------------
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message (l_full_name || ': Generate');
   END IF;

   OPEN c_fields;
   LOOP
      FETCH c_fields INTO l_field_table_name, l_field_column_name, l_substring_length;
      IF (c_fields%ROWCOUNT = 0) THEN
         CLOSE c_fields;
         IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name ('AMS', 'AMS_LIST_BAD_DEDUPE_RULE');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
      EXIT WHEN c_fields%NOTFOUND;

      -- if the enable word replacement flag is set we construct the sql
      -- to call the filter word function.
      IF  (p_word_replacement_flag = 'Y') THEN
         --
         -- Construct select SQL clause in the format:
         --    SELECT AMS_ListDedupe_PVT.filter_word ( the_word, the_length, the_table, the_column )
         -- The final result of the query will look like: A.B.C.D
         --
         l_select_sql :=
           l_select_sql ||
                'AMS_ListDedupe_PVT.filter_word (' ||
                l_field_column_name ||
                ',' ||
                NVL (TO_CHAR (l_substring_length), 'NULL') ||
                ',' ||
                '''' ||
                l_field_table_name ||
                '''' ||
                ',' ||
                '''' ||
                l_field_column_name ||
                '''' ||
                ')' ||
                '||' ||
                '''' ||
                '.' ||
                '''' ||
                '||';
      ELSE
      --no substr specified for the rule field.
         IF  (NVL (l_substring_length, 0) = 0) THEN
            l_select_sql :=
              l_select_sql ||
              'UPPER (' ||
              l_field_column_name ||
              ')||' ||
              '''' ||
              '.' ||
              '''' ||
              '||';
         ELSE
            l_select_sql :=
              l_select_sql ||
              'UPPER(SUBSTR(' ||
              l_field_column_name ||
              ',1,' ||
              TO_CHAR (l_substring_length) ||
              '))||' ||
              '''' ||
              '.' ||
              '''' ||
              '||';
         END IF;
      END IF;

/***
      IF p_word_replacement_flag = 'Y' THEN
         l_select_sql :=  l_select_sql ||
                          'AMS_ListDedupe_PVT.filter_word (' || l_field_column_name || ', '
                                                             || l_substring_length || ', '
                                                             || l_field_table_name || ', '
                                                             || '''' || l_field_column_name || '''),'
      ELSE
      END IF;
***/

    END LOOP;
    CLOSE c_fields;

    -- removing the last '.' from the string as this will cause an invalid syntax error
    -- in the query.
    l_select_sql := 'SELECT ' || SUBSTR (l_select_sql, 1, LENGTH (l_select_sql) - 7) || ' ';

    l_from_sql := 'FROM ' || l_field_table_name || ' ';

    l_where_sql := 'WHERE ' || p_sys_object_id_field || ' = :p_sys_object_id';

    EXECUTE IMMEDIATE l_select_sql || l_from_sql || l_where_sql
    INTO l_dedupe_key
    USING p_sys_object_id
    ;
    -------------------- finish --------------------------
    --
    -- Set the out variable.
    -- The returned key may be of greater length than
    -- the allowable key length.
    x_dedupe_key := SUBSTR (l_dedupe_key, 1, L_KEY_LENGTH);

    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
    );

    IF (AMS_DEBUG_HIGH_ON) THEN



    AMS_Utility_PVT.debug_message (l_full_name || ': End');

    END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
END Generate_Key;

FUNCTION Replace_Word(p_word              VARCHAR2,
                        p_replacement_type  VARCHAR2)
  RETURN VARCHAR2
  IS
    l_source_text        VARCHAR2(2000);
    l_text_length        NUMBER;
    l_current_word       VARCHAR2(2000);
    l_key                VARCHAR2(2000);
    l_old_word           VARCHAR2(2000);
    l_count              NUMBER := 0;

    CURSOR C_Word_Rep (x_current_word VARCHAR2,
                       x_replacement_type VARCHAR2) IS
      SELECT upper(replacement_word)
      FROM   hz_word_replacements
      WHERE  upper(original_word) = x_current_word
      AND    type = x_replacement_type;

    CURSOR c_key IS
      SELECT ORIGINAL_WORD,
             REPLACEMENT_WORD
      FROM   HZ_WORD_REPLACEMENTS
      WHERE  TYPE = 'KEY';

  BEGIN

    -- Steps mentioned here are in the context of complete fuzzy key
    -- generation process. (Step 1 is in Generate_Key)
    -- Step 2.
    -- We need to remove 'S so that WILLIAM'S becomes WILLIAM and
    -- it can become BILL if there is a replacement rule from
    -- original word WILLIAM to replacement word BILL
    l_source_text := replace(p_word, '''S ', ' ');

    -- Step 3.
    -- We need to remove any punctuation characters etc.
    -- For example, this will make 134/3, 134-3 etc mapped to 1343 in key for address.
    l_source_text := ltrim(translate(l_source_text, g_original_text, g_replace_text));

    -- Step 3.5.
    -- This step is for removal of special characters.
    -- The special characters will only be replaced if user has
    -- has set up Key Modifiers rules.
    -- This will replace any number of characters to any number of characters mapping for
    -- many european language. See bug 1868161 for detail.

    IF g_special_enabled IS NULL THEN
        OPEN c_key;
        FETCH c_key INTO g_original_key(l_count), g_replacement_key(l_count);
        IF c_key%NOTFOUND THEN
            g_special_enabled := 'N';
        ELSE
            g_special_enabled := 'Y';
        END IF;

        WHILE c_key%FOUND LOOP
            l_count := l_count + 1;
            FETCH c_key INTO g_original_key(l_count), g_replacement_key(l_count);
        END LOOP;
        CLOSE c_key;
    END IF;
    IF g_special_enabled = 'Y' THEN
        FOR i IN g_original_key.FIRST..g_original_key.LAST LOOP
            l_source_text := REPLACE(l_source_text, g_original_key(i), g_replacement_key(i));
        END LOOP;
    END IF;

    -- Step 4.
    -- We need to continue further processing on each word if a group
    -- of words is the input parameter.
    -- For example INTERNATIONAL BUSINESS MACHINES should have rules
    -- applied to each word (INTERNATIONAL, BUSINESS, MACHINES) individually.
    -- Append a blank space on the end of the text so that the loop can
    -- always end with the last word.
    l_source_text := l_source_text || ' ';
    LOOP
      l_text_length := NVL(length(l_source_text),0);
      IF l_text_length = 0
      THEN
          EXIT;
      END IF;
      FOR i IN 1..l_text_length LOOP
        IF substr(l_source_text,i,1) = ' '
        THEN
          l_current_word := substr(l_source_text,0,i-1);
          l_old_word := l_current_word;
          -- Fetch the replacement word for the current word.
          -- If no replacement word is found, then use the original
          -- word
          --
          -- Step 5.
          -- Search a replacement word for the original word.
          -- For example WILLIAM will be replaced by BILL if there is such rule.
          -- If a replacement found, substitute the original word by it
          OPEN C_Word_Rep(l_current_word, p_replacement_type);
          FETCH C_Word_Rep INTO l_current_word;
          IF (C_Word_Rep%NOTFOUND)
          THEN
            l_current_word := l_old_word;
          END IF;
          CLOSE C_Word_Rep;

          -- Step 7.
          -- If profile for cleansing is set, then cleanse the word.
          -- Cleanse converts double letters to single letter, removes
          -- vowels inside a word.
          -- For example : UNIVERSAL - UNVRSL, LITTLE - LTL etc.
          if fnd_profile.value('HZ_CLEANSE_FUZZY_KEY')  = 'Y' then
            l_current_word := hz_common_pub.cleanse(l_current_word);
          end if;

          -- Step 8.
          -- Build the key in a local variable
          -- This removes the white spaces
          l_key := l_key || l_current_word;
          l_source_text := substr(l_source_text,i);
          l_source_text := ltrim(l_source_text);
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
    RETURN l_key;
  END Replace_Word;


END AMS_ListDedupe_PVT;

/
