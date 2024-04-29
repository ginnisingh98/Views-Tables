--------------------------------------------------------
--  DDL for Package Body PV_ENRL_PREREQ_BINS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENRL_PREREQ_BINS_PUB" AS
 /* $Header: pvxpebib.pls 120.3 2008/01/08 08:19:17 hekkiral ship $ */

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
G_PKG_NAME   CONSTANT VARCHAR2(30) := 'PV_ENRL_PREREQ_BINS_PUB';
g_log_to_file        VARCHAR2(5)  := 'N';
g_module_name        VARCHAR2(60);

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                              Exceptions to Catch                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_index_columns_existed    EXCEPTION;
PRAGMA EXCEPTION_INIT(g_index_columns_existed, -1408);

-- -----------------------------------------------------
-- ORA-00955: name is already used by an existing object
-- -----------------------------------------------------
g_name_already_used        EXCEPTION;
PRAGMA EXCEPTION_INIT(g_index_columns_existed, -955);

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;

END Debug;

--=============================================================================+
--| Procedure                                                                  |
--|    get_matched_partners                                                    |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE get_matched_partners(
    x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_program_id                 IN   NUMBER
   ,x_matched_id_tbl             OUT  NOCOPY  JTF_NUMBER_TABLE
)
IS
   CURSOR lc_partner_selection(c_program_id NUMBER) IS
      SELECT a.attribute_id, a.operator,
             b.attribute_value, b.attribute_to_value,
             a.selection_criteria_id,
             c.return_type,
             d.currency_code
      FROM   pv_enty_select_criteria a,
             pv_selected_attr_values b,
             pv_attributes_vl c,
             pv_process_rules_b d,
             pv_partner_program_b e
      WHERE  a.attribute_id          = c.attribute_id AND
             a.selection_criteria_id = b.selection_criteria_id (+) AND
             a.process_rule_id       = d.process_rule_id AND
             d.process_rule_id       = e.prereq_process_rule_id AND
             e.program_id            = c_program_id
      ORDER  BY a.attribute_id, b.selection_criteria_id;

   CURSOR c_get_partner_id IS
      SELECT partner_id
      FROM   pv_partner_profiles
      WHERE  status = 'A';

   CURSOR c_get_prereq (c_program_id NUMBER) IS
      SELECT change_from_program_id
      FROM pv_pg_enrl_change_rules rule
      WHERE rule.change_to_program_id = c_program_id
            AND rule.change_direction_code = 'PREREQUISITE'
            AND rule.EFFECTIVE_FROM_DATE <= SYSDATE
            AND NVL(rule.EFFECTIVE_TO_DATE, SYSDATE+1) >= SYSDATE
            AND rule.ACTIVE_FLAG = 'Y';

   CURSOR c_is_no_prereq_membership(c_program_id NUMBER, c_partner_id NUMBER) IS
      SELECT 1
      FROM dual
      WHERE not exists(
         SELECT 1
         FROM pv_pg_memberships memb
         WHERE memb.program_id = c_program_id
            AND memb.partner_id = c_partner_id
            AND memb.MEMBERSHIP_STATUS_CODE = 'ACTIVE'
            AND memb.START_DATE <= SYSDATE
            AND NVL(memb.ACTUAL_END_DATE,NVL(memb.ORIGINAL_END_DATE,SYSDATE+1)) >= SYSDATE
      );

  i                     NUMBER := 1;
  l_cnt                 NUMBER := 1;
  l_attr_matched_id_tbl JTF_NUMBER_TABLE;
  l_matched_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_attr_tbl            JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_attr_opr_tbl        JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
  l_val_attr_tbl        JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
  l_partner_details     JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000();
  l_flagcount           JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100();
  l_attr_data_type_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
  l_distance_tbl        JTF_NUMBER_TABLE;
  l_distance_uom        varchar2(100);
  l_message             varchar2(32000);
  l_previous_attr_id    NUMBER;
  l_previous_sc_id      NUMBER;
  l_delimiter           VARCHAR2(10) := '+++';
  l_prereq_exist        BOOLEAN;
  l_no_membership       BOOLEAN;

BEGIN
   --FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ------------------------------------------------------------------------
   -- Get partner selection attribute value and append them to the record
   -- of tables, l_match_attr_rec.
   -- The following code also performs AND/OR logic.  Attribute values
   -- involved in an OR logic will be concatenated in a string separated
   -- by a delimiter.
   -- ------------------------------------------------------------------------
   FOR x IN lc_partner_selection(p_program_id) LOOP
      IF (l_previous_attr_id = x.attribute_id AND
          l_previous_sc_id   = x.selection_criteria_id)
      THEN
         l_val_attr_tbl(i - 1) := l_val_attr_tbl(i - 1) ||
                                    l_delimiter || x.attribute_value;

         IF (x.return_type = 'CURRENCY') THEN
            l_val_attr_tbl(i - 1) := l_val_attr_tbl(i - 1) || ':::' ||
               x.currency_code || ':::' || TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
         END IF;
      ELSE
         l_val_attr_tbl.EXTEND;
         l_attr_tbl.EXTEND;
         l_attr_data_type_tbl.EXTEND;
         l_attr_opr_tbl.EXTEND;

         l_val_attr_tbl(i)         := x.attribute_value;
         l_attr_tbl(i)             := x.attribute_id;
         l_attr_data_type_tbl(i)   := x.return_type;
         l_attr_opr_tbl(i)         := x.operator;

         IF (x.return_type = 'CURRENCY') THEN
            l_val_attr_tbl(i) := l_val_attr_tbl(i) || ':::' ||
               x.currency_code || ':::' || TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
         END IF;

         IF (x.operator = 'BETWEEN') THEN
            l_attr_opr_tbl(i) := '>=';

            i := i + 1;
            l_val_attr_tbl.EXTEND;
            l_attr_tbl.EXTEND;
            l_attr_data_type_tbl.EXTEND;
            l_attr_opr_tbl.EXTEND;
            l_attr_opr_tbl(i)       := '<=';
            l_attr_tbl(i)           := x.attribute_id;
            l_attr_data_type_tbl(i) := x.return_type;
            l_attr_data_type_tbl(i) := x.attribute_to_value;

            IF (x.return_type = 'CURRENCY') THEN
               l_val_attr_tbl(i) := l_val_attr_tbl(i) || ':::' ||
                  x.currency_code || ':::' || TO_CHAR(SYSDATE, 'yyyymmddhh24miss');
            END IF;
         END IF;

         i := i + 1;
      END IF;

      l_previous_attr_id := x.attribute_id;
      l_previous_sc_id   := x.selection_criteria_id;
   END LOOP;

   Debug('l_attr_tbl.count = ' || l_attr_tbl.count);
   IF l_attr_tbl.count > 0 THEN
      --Debug('l_attr_tbl.count > 0');

      --FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;

      pv_match_v2_pub.manual_match(
           p_api_version_number     => 1.0
         , p_attr_id_tbl            => l_attr_tbl
         , p_attr_value_tbl         => l_val_attr_tbl
         , p_attr_operator_tbl      => l_attr_opr_tbl
         , p_attr_data_type_tbl     => l_attr_data_type_tbl
         , p_attr_selection_mode    => 'OR'
         , p_att_delmter            => '+++'
         , p_selection_criteria     => 'ALL'
         , p_resource_id            => NULL
         , p_lead_id                => NULL
         , p_auto_match_flag        => 'N'
         , p_get_distance_flag      => 'F'
         , p_top_n_rows_by_profile  => 'F'
         , x_matched_id             => l_attr_matched_id_tbl
         , x_partner_details        => l_partner_details
         , x_distance_tbl           => l_distance_tbl
         , x_distance_uom_returned  => l_distance_uom
         , x_flagcount              => l_flagcount
         , x_return_status          => x_return_status
         , x_msg_count              => x_msg_count
         , x_msg_data               => x_msg_data
      );
      --FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Debug('x_return_status <> FND_API.G_RET_STS_SUCCESS');
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
   ELSE -- IF l_attr_tbl.count = 0
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- If there is no attribute, l_attr_matched_id_tbl will not be set (will be null)
      -- go to ELSIF (l_attr_matched_id_tbl is null)
   END IF;

   Debug('x_return_status: ' || x_return_status);

   IF (l_attr_matched_id_tbl is not null) THEN
      Debug('l_attr_matched_id_tbl.count = ' || l_attr_matched_id_tbl.count);
      FOR i IN 1..l_attr_matched_id_tbl.count LOOP
         Debug('before: l_attr_matched_id_tbl(' || i || '):'  || l_attr_matched_id_tbl(i));
         --Debug('before: p_partner_details(' || i || '):'  || l_partner_details(i));
         l_prereq_exist := false;
         l_no_membership := false;
         FOR x IN c_get_prereq (p_program_id) LOOP
            Debug('after: x.change_from_program_id = ' || x.change_from_program_id);
            l_prereq_exist := true;
            FOR y IN c_is_no_prereq_membership(x.change_from_program_id, l_attr_matched_id_tbl(i)) LOOP
               Debug('prereq exists but no active membership');
               l_no_membership := true;
            END LOOP;
            EXIT WHEN l_no_membership;
         END LOOP;
         IF (l_prereq_exist) THEN
            IF (not l_no_membership) THEN
               l_matched_id_tbl.extend;
               l_matched_id_tbl(l_cnt) := l_attr_matched_id_tbl(i);
               l_cnt := l_cnt + 1;
            END IF;
         ELSIF (NOT l_prereq_exist) THEN
            --Debug('no prereq exist: l_attr_matched_id_tbl(' || i || '):'  || l_attr_matched_id_tbl(i));
            l_matched_id_tbl.extend;
            l_matched_id_tbl(l_cnt) := l_attr_matched_id_tbl(i);
            l_cnt := l_cnt + 1;
         END IF;
      END LOOP;
   ELSIF (l_attr_matched_id_tbl is null) THEN
      Debug('l_attr_matched_id_tbl is null');
      FOR x IN c_get_partner_id LOOP
         Debug('before: x.partner_id = ' || x.partner_id);
         l_prereq_exist := false;
         l_no_membership := false;
         FOR y IN c_get_prereq (p_program_id) LOOP
            Debug('after: y.change_from_program_id = ' || y.change_from_program_id);
            l_prereq_exist := true;
            FOR z IN c_is_no_prereq_membership(y.change_from_program_id, x.partner_id) LOOP
               Debug('prereq exists but no active membership');
               l_no_membership := true;
            END LOOP;
            EXIT WHEN l_no_membership;
         END LOOP;
         IF (l_prereq_exist) THEN
            IF (not l_no_membership) THEN
               l_matched_id_tbl.extend;
               l_matched_id_tbl(l_cnt) := x.partner_id;
               l_cnt := l_cnt + 1;
            END IF;
         ELSIF (NOT l_prereq_exist) THEN
            --Debug('no prereq exist: x.partner_id = ' || x.partner_id);
            l_matched_id_tbl.extend;
            l_matched_id_tbl(l_cnt) := x.partner_id;
            l_cnt := l_cnt + 1;
         END IF;
      END LOOP;
   END IF;

   x_matched_id_tbl := l_matched_id_tbl;

   Debug('END get_matched_partners');

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END get_matched_partners;

--=============================================================================+
--| Procedure                                                                  |
--|    Exec_Create_Elig_Prgm                                                   |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Exec_Create_Elig_Prgm ( ERRBUF              OUT  NOCOPY VARCHAR2,
                                  RETCODE             OUT  NOCOPY VARCHAR2,
                                  p_log_to_file       IN VARCHAR2 := 'Y')
IS
   -- -----------------------------------------------------------------------
   -- Cursors
   -- -----------------------------------------------------------------------
   CURSOR c_get_program_ids IS
      SELECT prg.program_id
      FROM pv_partner_program_b prg
      WHERE prg.program_status_code = 'ACTIVE'
          AND prg.program_level_code = 'MEMBERSHIP'
          AND NVL(prg.allow_enrl_until_date, SYSDATE +1) >= SYSDATE
          AND prg.enabled_flag = 'Y';

   -- -----------------------------------------------------------------------
   -- Local Variables
   -- -----------------------------------------------------------------------
   l_api_package_name       VARCHAR2(30) := 'PV_ENRL_PREREQ_BINS_PUB';
   l_matched_id_tbl         JTF_NUMBER_TABLE;
   l_mirror_table           VARCHAR2(30);
   l_cache_table            VARCHAR2(30);
   l_pv_schema_name         VARCHAR2(30);
   l_user_id                NUMBER := FND_GLOBAL.USER_ID();
   l_total_start            NUMBER;
   l_start                  NUMBER;
   l_elapsed_time           NUMBER;
   l_return_status          VARCHAR2(100);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(500);
   l_end_refresh_flag       BOOLEAN;
   l_elapsed_time2          NUMBER;
   l_refresh_type           VARCHAR2(30);
   l_incr_timestamp         VARCHAR2(50);
BEGIN
   -- -----------------------------------------------------------------------
   -- Set variables.
   -- -----------------------------------------------------------------------
   l_total_start := dbms_utility.get_time;

   IF (p_log_to_file <> 'Y') THEN
      g_log_to_file := 'N';
   ELSE
      g_log_to_file := 'Y';
   END IF;

   g_module_name := 'Partner Program Eligibilities';

   -- -----------------------------------------------------------------------
   -- Exit the program if there is already a session running.
   -- -----------------------------------------------------------------------
   FOR x IN (SELECT COUNT(*) count
             FROM   v$session
             WHERE  module = g_module_name)
   LOOP
     IF (x.count > 0) THEN
         Debug('There is already a Refresh Eligibilities CC session running.');
         Debug('The program will now exit.');
         RETURN;
      END IF;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- Code Instrumentation
   -- -----------------------------------------------------------------------
   dbms_application_info.set_client_info(
      client_info => 'p_log_to_file = ' || p_log_to_file
   );

   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'STARTUP'
   );

   -- -----------------------------------------------------------------------
   -- Start time message...
   -- -----------------------------------------------------------------------
   FND_MESSAGE.SET_NAME(application => 'PV',
                        name        => 'PV_GET_ELIG_PRGM_START_TIME');
   FND_MESSAGE.SET_TOKEN(token      => 'P_DATE_TIME',
                         value      => TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
   IF(g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get);
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
   ELSE
      FND_MSG_PUB.ADD;
   END IF;

   -- -----------------------------------------------------------------------
   -- Code Instrumentation
   -- -----------------------------------------------------------------------
   l_start := dbms_utility.get_time;
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Pre-Processing....................................................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Pre-Processing'
   );

  -- -----------------------------------------------------------------------
   -- Pre-processing steps including synonym recovery, retrieving PV schema,
   -- retrieving underlying tables for the search and the mirror table,
   -- alter/drop indexes, etc.
   -- -----------------------------------------------------------------------
   PV_CONTEXT_VALUES.Pre_Processing (
      p_synonym_name          => 'PV_PG_ELIG_PROGRAMS',
      p_mirror_synonym_name   => 'PV_PG_ELIG_PROG_MIRR',
      p_temp_synonym_name     => 'PV_PG_ELIG_PROGRAMS_TMP',
      p_log_to_file           => g_log_to_file,
      p_pv_schema_name        => l_pv_schema_name,
      p_search_table          => l_cache_table,
      p_mirror_table          => l_mirror_table,
      p_end_refresh_flag      => l_end_refresh_flag,
      p_out_refresh_type      => l_refresh_type,
      p_module_name           => g_module_name
   );

   Debug('Elapsed Time (Pre-Processing): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
   l_start := dbms_utility.get_time;

   -- ------------------------------------------------------------------
   -- Compute the partners eligibilities for each program
   -- ------------------------------------------------------------------
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Compute the partners eligibilities for each program');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Compute the partners eligibilities for each program'
   );

   FOR x IN c_get_program_ids LOOP
      Debug('x.program_id = ' || x.program_id);
      get_matched_partners (
          x_return_status         => l_return_status
         ,x_msg_count             => l_msg_count
         ,x_msg_data              => l_msg_data
         ,p_program_id            => x.program_id
         ,x_matched_id_tbl        => l_matched_id_tbl
      );

      Debug('get_matched_partners(): x_return_status = ' || l_return_status);

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Debug('get_matched_partners failed when program_id = ' || x.program_id);
         FND_MESSAGE.SET_NAME(application => 'PV',
                              name        => 'PV_MATCH_PARTNERS_FAILED');
         FND_MESSAGE.SET_TOKEN(token      => 'P_PROGRAM_ID',
                               value      => x.program_id);
         IF (g_log_to_file = 'Y') THEN
            FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
            FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );
         ELSE
            FND_MSG_PUB.Add;
         END IF;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      IF (l_matched_id_tbl is not null) THEN
         Debug('l_matched_id_tbl is not null');
         FORALL l_cnt IN 1..l_matched_id_tbl.count
            INSERT
            INTO   PV_PG_ELIG_PROG_MIRR
                   (
                     ELIG_PROGRAM_ID,
                     PROGRAM_ID,
                     PARTNER_ID,
                     ELIGIBILITY_CRIT_CODE,
                     CREATION_DATE,
                     CREATED_BY,
                     LAST_UPDATE_DATE,
                     LAST_UPDATED_BY,
                     LAST_UPDATE_LOGIN ,
                     OBJECT_Version_number
                   )
            VALUES (
                     PV_PG_ELIG_PROGRAMS_S.nextval,
                     x.program_id,
                     l_matched_id_tbl(l_cnt),
                     'PREREQ',
                     SYSDATE,
                     l_user_id,
                     SYSDATE,
                     l_user_id,
                     l_user_id,
                     1.0
                   );
      END IF;
   END LOOP;
         Debug('Load test: Elapsed Time: ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');
         l_start := dbms_utility.get_time;


   -- *****************************************************************
   -- *****************************************************************
   --                    Post Loading Processing
   -- *****************************************************************
   -- *****************************************************************
   Debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
   Debug('Post loading processing...............................................');
   dbms_application_info.set_module(
      module_name => g_module_name,
      action_name => 'Post Processing'
   );
   PV_CONTEXT_VALUES.Post_Processing (
      p_synonym_name          => 'PV_PG_ELIG_PROGRAMS',
      p_mirror_synonym_name   => 'PV_PG_ELIG_PROG_MIRR',
      p_temp_synonym_name     => 'PV_PG_ELIG_PROGRAMS_TMP',
      p_log_to_file           => g_log_to_file,
      p_pv_schema_name        => l_pv_schema_name,
      p_search_table          => l_cache_table,
      p_mirror_table          => l_mirror_table,
      p_incr_timestamp        => l_incr_timestamp,
      p_api_package_name      => l_api_package_name,
      p_module_name           => g_module_name
  );


   COMMIT;

   Debug('Elapsed Time (Total Post-Processing): ' || (DBMS_UTILITY.get_time - l_start) || ' hsec');

   -- -------------------------------------------------------------------------
   -- Display End Time Message.
   -- -------------------------------------------------------------------------
   Debug('=====================================================================');
   FND_MESSAGE.SET_NAME(application => 'PV',
                        name        => 'PV_CREATE_CONTEXT_END_TIME');
   FND_MESSAGE.SET_TOKEN(token   => 'P_DATE_TIME',
                         value  =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

   IF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

   ELSE
      FND_MSG_PUB.Add;
   END IF;

   l_elapsed_time := DBMS_UTILITY.get_time - l_total_start;
   Debug('=====================================================================');
   Debug('Total Elapsed Time: ' || l_elapsed_time || ' hsec' || ' = ' ||
         ROUND((l_elapsed_time/6000), 2) || ' minutes');
   Debug('=====================================================================');

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      IF l_msg_count > 1 THEN
         fnd_msg_pub.reset;
         FOR i IN 1..l_msg_count LOOP
            Debug(fnd_msg_pub.get(p_encoded => fnd_api.g_false));
         END LOOP;
      ELSE
         Debug(l_msg_data);
      END IF;
      RETCODE := '2';
      ROLLBACK;

   WHEN OTHERS THEN
     Debug('OTHERS');
     Debug(SQLCODE || ': ' || SQLERRM);
     RETCODE := '2';
     ROLLBACK;

END Exec_Create_Elig_Prgm;

END PV_ENRL_PREREQ_BINS_PUB;


/
