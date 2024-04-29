--------------------------------------------------------
--  DDL for Package Body PV_CATEGORY_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_CATEGORY_MIGRATION" AS
/* $Header: pvsphmib.pls 120.0 2005/05/27 15:25:11 appldev noship $ */

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_log_to_file        VARCHAR2(5)  := 'Y';
g_pkg_name           VARCHAR2(30) := 'PV_CATEGORY_MIGRATION';
g_api_name           VARCHAR2(30);



/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);

PROCEDURE Set_Message(
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL,
    p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);


--=============================================================================+
--| Public Procedure                                                           |
--|    Category_Migration                                                      |
--|                                                                            |
--| Purpose                                                                    |
--|    This script is used to migrate pv_enty_attr_values and                  |
--|    pv_selected_attr_values to single product hierarchy.                    |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================

PROCEDURE Category_Migration (
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_trace_mode       IN  VARCHAR2,
    p_log_to_file      IN  VARCHAR2 := 'Y')
IS
   l_status               BOOLEAN;
   l_no_data_found        BOOLEAN := TRUE;
   l_string               VARCHAR2(300);
   l_update_ddl           VARCHAR2(4000);
   l_pv_schema            VARCHAR2(30);
   l_index_tablespace     VARCHAR2(30);
   l_rows_inserted        NUMBER;
   l_revert_entity_attr   BOOLEAN := FALSE;
   l_revert_selected_attr BOOLEAN := FALSE;


   CURSOR c_enty_attr_values IS
      SELECT DISTINCT
             b.code old_value, b.product_category_id
      FROM   pv_enty_attr_values a,
      (
      select interest_type code,
             TO_CHAR(interest_type_id) id,
             product_category_id
      from   as_interest_types_vl
      union
      select i.interest_type ||'/'||p.code code,
             i.interest_type_id ||'/'||p.interest_code_id id,
             p.product_category_id
      from   as_interest_types_vl i, as_interest_codes_vl p
      where  i.interest_type_id*1 = p.interest_type_id and
             p.parent_interest_code_id is null
      union
      select i.interest_type ||'/'||p.code ||'/'||s.code code,
             i.interest_type_id ||'/'||p.interest_code_id ||'/'||s.interest_code_id id,
             s.product_category_id
      from   as_interest_types_vl i, as_interest_codes_vl p,
             as_interest_codes_vl s
      where  i.interest_type_id = p.interest_type_id and
             p.interest_type_id = s.interest_type_id*1 and
             s.parent_interest_code_id = p.interest_code_id
      ) b
      WHERE  a.attr_value = b.id AND
             a.attribute_id IN (1, 510) AND
             b.product_category_id IS NULL;


   CURSOR c_selected_attr_values IS
      SELECT  DISTINCT
              a.attribute_value old_value
      FROM    pv_selected_attr_values a,
              pv_enty_select_criteria c,
      (
      select interest_type code,
             TO_CHAR(interest_type_id) id,
             product_category_id
      from   as_interest_types_vl
      union
      select i.interest_type ||'/'||p.code code,
             i.interest_type_id ||'/'||p.interest_code_id id,
             p.product_category_id
      from   as_interest_types_vl i, as_interest_codes_vl p
      where  i.interest_type_id*1 = p.interest_type_id and
             p.parent_interest_code_id is null
      union
      select i.interest_type ||'/'||p.code ||'/'||s.code code,
             i.interest_type_id ||'/'||p.interest_code_id ||'/'||s.interest_code_id id,
             s.product_category_id
      from   as_interest_types_vl i, as_interest_codes_vl p,
             as_interest_codes_vl s
      where  i.interest_type_id = p.interest_type_id and
             p.interest_type_id = s.interest_type_id*1 and
             s.parent_interest_code_id = p.interest_code_id
      ) b
      WHERE  b.id = a.attribute_value AND
             a.selectioN_criteria_id    = c.selection_criteria_id AND
             c.attribute_id IN (1, 510) AND
             b.product_category_id IS NULL;


   l_insert_into_table1 VARCHAR2(32000) :=
     'INSERT INTO pv_single_prod_h_mappings
      SELECT a.enty_attr_val_id,
             b.product_category_id new_value,
             b.code old_value
      FROM   pv_enty_attr_values a,
      (
            select to_char(interest_type_id) code, product_category_id
            from   as_interest_types_b
            union
            select to_char(i.interest_type_id)||''/''||p.interest_code_id code,
                   p.product_category_id
            from   as_interest_types_b i, as_interest_codes_b p
            where  i.interest_type_id*1 = p.interest_type_id and
                   p.parent_interest_code_id is null
      union
      select to_char(i.interest_type_id)||''/''||p.interest_code_id||''/''||
             s.interest_code_id code,
             s.product_category_id
      from   as_interest_types_b i, as_interest_codes_b p, as_interest_codes_b s
      where  i.interest_type_id = p.interest_type_id and
             p.interest_type_id = s.interest_type_id*1 and
             s.parent_interest_code_id = p.interest_code_id
      ) b
      WHERE  a.attr_value = b.code AND
             a.attribute_id IN (1, 510)';

   l_insert_into_table2 VARCHAR2(32000) :=
     'INSERT INTO pv_single_prod_h_mappings2
      SELECT  a.attr_value_id,
              b.product_category_id new_value,
              a.attribute_value old_value
      FROM    pv_selected_attr_values a,
              pv_enty_select_criteria c,
      (
      select to_char(interest_type_id) code, product_category_id
      from   as_interest_types_b
      union
      select to_char(i.interest_type_id)||''/''||p.interest_code_id code,
             p.product_category_id
      from   as_interest_types_b i, as_interest_codes_b p
      where  i.interest_type_id*1 = p.interest_type_id and
             p.parent_interest_code_id is null
      union
      select to_char(i.interest_type_id)||''/''||p.interest_code_id||''/''||
             s.interest_code_id code,
             s.product_category_id
      from   as_interest_types_b i, as_interest_codes_b p, as_interest_codes_b s
      where  i.interest_type_id = p.interest_type_id and
             p.interest_type_id = s.interest_type_id*1 and
            s.parent_interest_code_id = p.interest_code_id
      ) b
      WHERE  b.code = a.attribute_value AND
             a.selectioN_criteria_id    = c.selection_criteria_id AND
             c.attribute_id IN (1, 510)';

   -- -----------------------------------------------------------------------------
   -- This cursor is used for retrieving PV schema.
   -- -----------------------------------------------------------------------------
   CURSOR c_pv_schema IS
      SELECT i.tablespace,
             i.index_tablespace,
             u.oracle_username
      FROM   fnd_product_installations i,
             fnd_application a,
             fnd_oracle_userid u
      WHERE  a.application_short_name = 'PV' AND
             a.application_id = i.application_id AND
             u.oracle_id = i.oracle_id;

BEGIN
   -- ----------------------------------------------------------------------------
   -- Initialize variables.
   -- ----------------------------------------------------------------------------
   IF p_trace_mode = 'Y' THEN
       dbms_session.set_sql_trace(TRUE);
   ELSE
       dbms_session.set_sql_trace(FALSE);
   END IF;

   IF (p_log_to_file <> 'Y') THEN
      g_log_to_file := 'N';
   ELSE
      g_log_to_file := 'Y';
   END IF;

   g_api_name := 'Category_Migration';


   -- ----------------------------------------------------------------------------
   -- Starts migration.
   -- ----------------------------------------------------------------------------

   -- -----------------------------------------------------------------------
   -- Revert Single Product Hierarchy back to Sales Product Hierarchy.
   -- This is to ensure that this concurrent program is re-runnable.
   -- -----------------------------------------------------------------------
   Debug('(1).');
   Set_Message(
      p_msg_name      => 'PV_SPH_REVERT_BACK'
   );

   FOR x IN (SELECT 'x' row_exists FROM pv_single_prod_h_mappings) LOOP
      l_revert_entity_attr := TRUE;
   END LOOP;

   FOR x IN (SELECT 'x' row_exists FROM pv_single_prod_h_mappings2) LOOP
      l_revert_selected_attr := TRUE;
   END LOOP;

   -- -----------------------------------------------------------------------
   -- pv_enty_attr_values: revert back to Sales Product Hierarchy.
   -- -----------------------------------------------------------------------
   IF (l_revert_entity_attr) THEN
     l_update_ddl :=
     'UPDATE pv_enty_attr_values a
      SET    attr_value = (SELECT old_value
                           FROM   pv_single_prod_h_mappings b
                           WHERE  a.enty_attr_val_id = b.enty_attr_val_id)
      WHERE  EXISTS       (SELECT 1
                           FROM   pv_single_prod_h_mappings c
                           WHERE  a.enty_attr_val_id = c.enty_attr_val_id)';

      l_string := SUBSTR(l_update_ddl, 1, 300);

      EXECUTE IMMEDIATE l_update_ddl;

      Set_Message(
         p_msg_name      => 'PV_SPH_ROWS_UPDATED',
         p_token1        => 'ROWS',
         p_token1_value  => SQL%ROWCOUNT
      );

   END IF;


   -- -----------------------------------------------------------------------
   -- pv_selected_attr_values: revert back to Sales Product Hierarchy.
   -- -----------------------------------------------------------------------
   IF (l_revert_selected_attr) THEN
     l_update_ddl :=
     'UPDATE pv_selected_attr_values a
      SET    attribute_value =
                          (SELECT old_value
                           FROM   pv_single_prod_h_mappings2 b
                           WHERE  a.attr_value_id = b.attr_value_id)
      WHERE  EXISTS       (SELECT 1
                           FROM   pv_single_prod_h_mappings2 c
                           WHERE  a.attr_value_id = c.attr_value_id)';

      l_string := SUBSTR(l_update_ddl, 1, 300);

      EXECUTE IMMEDIATE l_update_ddl;

      Set_Message(
         p_msg_name      => 'PV_SPH_ROWS_UPDATED',
         p_token1        => 'ROWS',
         p_token1_value  => SQL%ROWCOUNT
      );
   END IF;

   -- -----------------------------------------------------------------------
   -- Check if all the data in pv_enty_attr_values have proper mapping.
   -- -----------------------------------------------------------------------
   l_no_data_found := TRUE;

   Debug('-');
   Debug('-');
   Debug('(2).');
   Set_Message(
      p_msg_name      => 'PV_SPH_NO_MAPPING',
      p_token1        => 'TABLE',
      p_token1_value  => 'pv_enty_attr_values'
   );
   Debug('-');
   Debug('------------------------------------------------------------');

   FOR x IN c_enty_attr_values LOOP
      Debug(LPAD(x.old_value, 60));
      l_no_data_found := FALSE;
   END LOOP;

   IF (l_no_data_found) THEN
      Debug('-');
      Debug('-');
      Set_Message(
         p_msg_name      => 'PV_SPH_NO_ROWS_RETURNED'
      );
      Debug('-');

   ELSE
      Debug('-');
      Debug('-');
      Set_Message(
         p_msg_name      => 'PV_SPH_OPERATION_ABORTED'
      );
      Debug('-');
      Debug('-');

      RETCODE := '1';

      RETURN;
   END IF;


   Debug('-');
   Debug('-');
   Debug('(3).');
   Set_Message(
      p_msg_name      => 'PV_SPH_NO_MAPPING',
      p_token1        => 'TABLE',
      p_token1_value  => 'pv_selected_attr_values'
   );
   Debug('-');
   Debug('------------------------------------------------------------');
   Debug('-');
   Debug('-');

   FOR x IN c_selected_attr_values LOOP
      Debug(LPAD(x.old_value, 60));
      l_no_data_found := FALSE;
   END LOOP;

   IF (l_no_data_found) THEN
      Set_Message(
         p_msg_name      => 'PV_SPH_NO_ROWS_RETURNED'
      );
      Debug('-');

   ELSE
      Debug('-');
      Debug('-');
      Set_Message(
         p_msg_name      => 'PV_SPH_OPERATION_ABORTED'
      );
      Debug('-');
      Debug('-');

      RETCODE := '1';

      RETURN;
   END IF;


   Debug('-');
   Debug('-');
   Debug('==============================================================');
   Set_Message(
      p_msg_name      => 'PV_SPH_DATA_VALIDATION_DONE'
   );
   Debug('==============================================================');
   Debug('-');
   Debug('-');

   Debug('(4).');

   Set_Message(
      p_msg_name      => 'PV_SPH_POPULATE_MAPPING',
      p_token1        => 'TABLE1',
      p_token1_value  => 'pv_single_prod_h_mappings',
      p_token2        => 'TABLE2',
      p_token2_value  => 'pv_enty_attr_values'
   );

   Debug('-');

   -- -------------------------------------------------------------------------
   -- Retrieve PV schema name. The schema for PV may not always be "PV". It
   -- depends on the implementation. Hence, we can't hard code the name.
   -- -------------------------------------------------------------------------
   FOR x IN c_pv_schema LOOP
      l_pv_schema        := x.oracle_username;
      l_index_tablespace := x.index_tablespace;
   END LOOP;


   BEGIN
      l_string := 'DROP INDEX ' || l_pv_schema || '.pv_single_prod_h_mappings_u1';
      EXECUTE IMMEDIATE l_string;

      EXCEPTION
         WHEN OTHERS THEN
            null;
   END;

   l_string := 'TRUNCATE TABLE ' || l_pv_schema || '.pv_single_prod_h_mappings';
   EXECUTE IMMEDIATE l_string;

   l_string := SUBSTR(l_insert_into_table1, 1, 300);
   EXECUTE IMMEDIATE l_insert_into_table1;

   l_rows_inserted := SQL%ROWCOUNT;

   Set_Message(
      p_msg_name      => 'PV_SPH_ROWS_INSERTED',
      p_token1        => 'ROWS',
      p_token1_value  => l_rows_inserted
   );

   l_string := 'CREATE UNIQUE INDEX ' || l_pv_schema ||
               '.pv_single_prod_h_mappings_u1 ' ||
               'ON pv_single_prod_h_mappings (enty_attr_val_id) ' ||
               'TABLESPACE ' || l_index_tablespace;
   EXECUTE IMMEDIATE l_string;

   l_string := 'ANALYZE TABLE ' || l_pv_schema ||
               '.pv_single_prod_h_mappings COMPUTE STATISTICS';
   EXECUTE IMMEDIATE l_string;



   Debug('-');
   Debug('(5).');
   Set_Message(
      p_msg_name      => 'PV_SPH_POPULATE_MAPPING',
      p_token1        => 'TABLE1',
      p_token1_value  => 'pv_single_prod_h_mappings2',
      p_token2        => 'TABLE2',
      p_token2_value  => 'pv_selected_attr_values'
   );

   Debug('-');

   BEGIN
      l_string := 'DROP INDEX ' || l_pv_schema || '.pv_single_prod_h_mappings2_u1';
      EXECUTE IMMEDIATE l_string;

      EXCEPTION
         WHEN OTHERS THEN
            null;
   END;


   l_string := 'TRUNCATE TABLE ' || l_pv_schema || '.pv_single_prod_h_mappings2';
   EXECUTE IMMEDIATE l_string;


   l_string := SUBSTR(l_insert_into_table2, 1, 300);
   EXECUTE IMMEDIATE l_insert_into_table2;

   l_rows_inserted := SQL%ROWCOUNT;
   Set_Message(
      p_msg_name      => 'PV_SPH_ROWS_INSERTED',
      p_token1        => 'ROWS',
      p_token1_value  => l_rows_inserted
   );


   l_string := 'CREATE UNIQUE INDEX ' || l_pv_schema ||
               '.pv_single_prod_h_mappings2_u1 ' ||
               'ON pv_single_prod_h_mappings2 (attr_value_id) ' ||
               'TABLESPACE ' || l_index_tablespace;
   EXECUTE IMMEDIATE l_string;

   l_string := 'ANALYZE TABLE ' || l_pv_schema ||
               '.pv_single_prod_h_mappings2 COMPUTE STATISTICS';
   EXECUTE IMMEDIATE l_string;

   Debug('-');


   -- -----------------------------------------------------------------------
   -- Update pv_enty_attr_values
   -- -----------------------------------------------------------------------
   Debug('(6).');
   Set_Message(
      p_msg_name      => 'PV_SPH_UPDATE_TABLE',
      p_token1        => 'TABLE',
      p_token1_value  => 'pv_enty_attr_values'
   );
   Debug('-');

   l_update_ddl :=
     'UPDATE pv_enty_attr_values a
      SET    attr_value = (SELECT new_value
                           FROM   pv_single_prod_h_mappings b
                           WHERE  a.enty_attr_val_id = b.enty_attr_val_id)
      WHERE  EXISTS       (SELECT 1
                           FROM   pv_single_prod_h_mappings c
                           WHERE  a.enty_attr_val_id = c.enty_attr_val_id)';

   l_string := SUBSTR(l_update_ddl, 1, 300);

   EXECUTE IMMEDIATE l_update_ddl;

   Set_Message(
      p_msg_name      => 'PV_SPH_ROWS_UPDATED',
      p_token1        => 'ROWS',
      p_token1_value  => SQL%ROWCOUNT
   );
   Debug('-');
   Debug('-');


   -- -----------------------------------------------------------------------
   -- Update pv_selected_attr_values
   -- -----------------------------------------------------------------------
   Debug('(7).');
   Set_Message(
      p_msg_name      => 'PV_SPH_UPDATE_TABLE',
      p_token1        => 'TABLE',
      p_token1_value  => 'pv_selected_attr_values'
   );
   Debug('-');

   l_update_ddl :=
     'UPDATE pv_selected_attr_values a
      SET    attribute_value =
                          (SELECT new_value
                           FROM   pv_single_prod_h_mappings2 b
                           WHERE  a.attr_value_id = b.attr_value_id)
      WHERE  EXISTS       (SELECT 1
                           FROM   pv_single_prod_h_mappings2 c
                           WHERE  a.attr_value_id = c.attr_value_id)';

   l_string := SUBSTR(l_update_ddl, 1, 300);

   EXECUTE IMMEDIATE l_update_ddl;

   Set_Message(
      p_msg_name      => 'PV_SPH_ROWS_UPDATED',
      p_token1        => 'ROWS',
      p_token1_value  => SQL%ROWCOUNT
   );
   Debug('-');
   Debug('-');



   Set_Message(
      p_msg_name      => 'PV_SPH_MIGRATION_COMPLETED'
   );
   Debug('-');
   Set_Message(
      p_msg_name      => 'PV_SPH_VIEW_MAPPING_TABLE',
      p_token1        => 'TABLE1',
      p_token1_value  => 'pv_enty_attr_values',
      p_token2        => 'TABLE2',
      p_token2_value  => 'pv_single_prod_h_mappings'
   );

   Debug('-');
   Debug('SELECT old_value, new_value');
   Debug('FROM   pv_single_prod_h_mappings;');
   Debug('-');
   Debug('-');

   Set_Message(
      p_msg_name      => 'PV_SPH_VIEW_MAPPING_TABLE',
      p_token1        => 'TABLE1',
      p_token1_value  => 'pv_selected_attr_values',
      p_token2        => 'TABLE2',
      p_token2_value  => 'pv_single_prod_h_mappings2'
   );

   Debug('-');
   Debug('SELECT old_value, new_value');
   Debug('FROM   pv_single_prod_h_mappings2;');
   Debug('-');
   Debug('-');


   EXCEPTION
      WHEN OTHERS THEN
         Debug('Exception raised while running the script...');
         Debug('SQLCODE : ' || SQLCODE);
         Debug('SQLERRM : ' || SQLERRM);
         Debug('-');
         Debug('Error encountered while executing the following statement:');
         Debug(l_string);
         Debug('-');
         Debug('-');

         errbuf   := SQLERRM;
         retcode  := FND_API.G_RET_STS_UNEXP_ERROR;
         l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);

END CATEGORY_MIGRATION;



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
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_type);
   FND_MESSAGE.Set_Token(p_token_type, p_msg_string);

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         p_msg_string
      );
   END IF;
END Debug;
-- =================================End of Debug================================

--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
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
PROCEDURE Set_Message(
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL,
    p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   FND_MESSAGE.Set_Name('PV', p_msg_name);

   IF (p_token1 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token1, p_token1_value);
   END IF;

   IF (p_token2 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token2, p_token2_value);
   END IF;

   IF (p_token3 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token3, p_token3_value);
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(
         p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         FALSE
      );
   END IF;

   IF (g_log_to_file = 'N') THEN
      FND_MSG_PUB.Add;

   ELSIF (g_log_to_file = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,  fnd_message.get);
   END IF;

END Set_Message;
-- ==============================End of Set_Message==============================


end PV_CATEGORY_MIGRATION;

/
