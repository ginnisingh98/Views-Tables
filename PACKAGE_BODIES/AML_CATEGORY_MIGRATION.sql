--------------------------------------------------------
--  DDL for Package Body AML_CATEGORY_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_CATEGORY_MIGRATION" AS
/* $Header: amlcateb.pls 120.0.12010000.1 2008/10/23 06:55:46 sariff noship $ */
-- This variable is used to store the application id for ASF
G_APPLICATION_ID NUMBER := 522;

-- Transaction date is committed in batches of this size

G_BATCH_SIZE       CONSTANT  NUMBER       := 10000;
G_RET_STS_WARNING  CONSTANT  VARCHAR2(1)  :=   'W';
G_SCHEMA_NAME                VARCHAR2(32) :=   null;
G_INDEX_SUFFIX     CONSTANT  VARCHAR2(4)  :=  '_MT1';


/*----------------------------------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *----------------------------------------------------------------------------------------------------*/
PROCEDURE AML_DEBUG(msg IN VARCHAR2);


/*----------------------------------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  MIGRATE_LEAD_LINES
 |
 | PURPOSE
 |  Due to single product hierarchy architecture, lead line should move from
 |  using interest_type_id, primary_interest_code_id, secondary_interest_code_id
 |  to category_id, category_set_id.
 |
 | NOTES
 |
 | HISTORY
 |   01/12/2004  SOLIN    Created
 |
 |   05/24/2004  BMUTHUKR For bug# 3642822.Increased the width of desc and code variables.
 |
 |   06/22/2004	 bmuthukr Modified the program to create temp indexes, disable triggers before
 |                        migration. After the migration is done all these will be reverted.
 |                        Also changed the update statements. Now udpate will be done in
 |                        batches of 10000 records.
 |
 |
 *----------------------------------------------------------------------------------------------------*/

PROCEDURE Load_Schema_Name IS
    l_status            VARCHAR2(2);
    l_industry          VARCHAR2(2);
    l_oracle_schema     VARCHAR2(32) := 'OSM';
    l_schema_return     BOOLEAN;
BEGIN
  if (G_SCHEMA_NAME is null) then
      l_schema_return := FND_INSTALLATION.get_app_info('AS', l_status, l_industry, l_oracle_schema);
      G_SCHEMA_NAME := l_oracle_schema;
  end if;
END;

PROCEDURE Enable_Triggers IS
BEGIN
   --Enable sales lead line trigger..
    execute immediate('alter trigger AS_SALES_LEAD_LINES_BIUD enable');
END;

PROCEDURE Disable_Triggers IS
BEGIN
   --Disable sales lead line trigger..
   execute immediate('alter trigger AS_SALES_LEAD_LINES_BIUD disable');
END;

PROCEDURE Create_temp_index(p_table         IN VARCHAR2,
                            p_index_columns IN VARCHAR2) IS

l_check_tspace_exist varchar2(100);
l_index_tablespace   varchar2(100);
l_sql_stmt           varchar2(2000);
l_user               varchar2(2000);
l_index_name         varchar2(100);

begin
   -- Temp index is created on as_sales_lead_lines table.
   l_user := USER;

   -- Name for temporary index created for migration
   l_index_name := p_table || G_INDEX_SUFFIX;

   AD_TSPACE_UTIL.get_tablespace_name('AS', 'TRANSACTION_INDEXES','N',l_check_tspace_exist,l_index_tablespace);

   l_sql_stmt :=    'create index ' || l_index_name || ' on '
                     || G_SCHEMA_NAME||'.'
                     || p_table || '(' || p_index_columns || ') '
                     ||' tablespace ' || l_index_tablespace || '  nologging '
                     ||'parallel 8';

   execute immediate l_sql_stmt;

   l_sql_stmt := 'alter index '|| l_user ||'.' || l_index_name || ' noparallel ';
   execute immediate l_sql_stmt;

   aml_debug('User is   '||l_user);

   -----------------
   -- Gather Stats--
   -----------------
   dbms_stats.gather_index_stats(l_user,l_index_name,estimate_percent => 10);

END Create_temp_index;

PROCEDURE Drop_Temp_Index(p_table  IN VARCHAR2) IS

l_sql_stmt         varchar2(2000);
l_index_name       varchar2(100);
l_user             varchar2(2000);

begin
   -----------------
   -- Drop index  --
   -----------------
   l_user := USER;

   -- Name for temporary index created for migration
   l_index_name := p_table || G_INDEX_SUFFIX;

   l_sql_stmt := 'drop index ' || l_user||'.' || l_index_name || ' ';

   execute immediate l_sql_stmt;
END Drop_Temp_Index;

PROCEDURE Display_category_mappings IS
l_no_data_found    BOOLEAN := TRUE;

 --- Cursor to check if all the interest types/codes are mapped.
   CURSOR c_interest_codes IS
   SELECT to_char(interest_type_id) code, description meaning
     FROM as_interest_types_vl
    WHERE  product_category_id IS NULL
    UNION
   SELECT to_char(i.interest_type_id)||'/'||p.interest_code_id code,
          i.description||'/'||p.description meaning
     FROM as_interest_types_vl i, as_interest_codes_vl p
    WHERE i.interest_type_id*1 = p.interest_type_id
      AND p.parent_interest_code_id is null
      AND p.product_category_id IS NULL
    UNION
   SELECT to_char(i.interest_type_id)||'/'||p.interest_code_id||'/'||
          s.interest_code_id code, i.description||'/'||p.description||'/'||s.description meaning
     FROM as_interest_types_vl i,  as_interest_codes_vl p, as_interest_codes_vl s
    WHERE i.interest_type_id = p.interest_type_id
      AND p.interest_type_id = s.interest_type_id*1
      AND s.parent_interest_code_id = p.interest_code_id
      AND s.product_category_id IS NULL;

   CURSOR c_lead_line_values IS
   SELECT distinct to_char(interest.interest_type_id) code ,interest.description meaning
     FROM as_sales_lead_lines line, as_interest_types_vl interest
    WHERE line.interest_type_id = interest.interest_type_id
      AND line.primary_interest_code_id is null
      AND line.secondary_interest_code_id is null
      AND interest.product_category_id is null
    UNION
   SELECT distinct to_char(interest.interest_type_id)||'/'||pic.interest_code_id code,
          interest.description||'/'||pic.description meaning
     FROM as_sales_lead_lines line, as_interest_codes_vl pic, as_interest_types_vl interest
    WHERE line.primary_interest_code_id = pic.interest_code_id
      AND pic.interest_type_id = interest.interest_type_id
      AND pic.parent_interest_code_id is null
      AND line.secondary_interest_code_id is null
      AND pic.product_category_id is null
    UNION
   SELECT distinct to_char(interest.interest_type_id)||'/'||pic.interest_code_id||'/'||sic.interest_code_id code,
          interest.description||'/'||pic.description||'/'||sic.description meaning
     FROM as_sales_lead_lines line, as_interest_codes_vl sic, as_interest_codes_vl pic, as_interest_types_vl interest
    WHERE line.secondary_interest_code_id = sic.interest_code_id
      AND line.primary_interest_code_id = sic.parent_interest_code_id
      AND sic.interest_type_id = interest.interest_type_id
	       and sic.parent_interest_code_id = pic.interest_code_id
	       and pic.product_category_id is null;

   CURSOR c_sales_lead_line_int IS
   SELECT to_char(lead.interest_type_id) code
     FROM as_sales_lead_lines lead
    WHERE lead.interest_type_id not in (SELECT int.interest_type_id
                                          FROM as_interest_types_b int)
    UNION
   SELECT lead.interest_type_id||'/'||lead.primary_interest_code_id code
     FROM as_sales_lead_lines lead
    WHERE lead.primary_interest_code_id not in (SELECT pic.interest_code_id
                                                  FROM as_interest_codes_b pic
	                                         WHERE pic.parent_interest_code_id IS null)
    UNION
   SELECT lead.interest_type_id||'/'||lead.primary_interest_code_id||'/'||lead.secondary_interest_code_id  code
     FROM as_sales_lead_lines lead
    WHERE lead.secondary_interest_code_id not in (SELECT  sic.interest_code_id
                                                    FROM as_interest_codes_b sic
                                                   WHERE sic.parent_interest_code_id is not null) ;

--

Begin

 -- -----------------------------------------------------------------------
   -- Check interest_code_id
   -- -----------------------------------------------------------------------
   AML_DEBUG('(1). The following interest code combinations are not mapped...');
   AML_DEBUG('-');

   l_no_data_found := TRUE;

   AML_DEBUG('     Code                                 Meaning');
   AML_DEBUG('-------------------------------------------------------------------------------------');

   FOR x IN c_interest_codes LOOP
--      AML_DEBUG(RPAD(x.code, 11));
      AML_DEBUG(RPAD(x.code, 30) || '   ' || RPAD(x.meaning, 100));

      l_no_data_found := FALSE;
   END LOOP;

   IF (l_no_data_found) THEN
      AML_DEBUG('No rows returned.');
      AML_DEBUG('-');

   END IF;

   -- -----------------------------------------------------------------------
   -- Check if all the data in as_sales_lead_lines have proper mapping.
   -- -----------------------------------------------------------------------
   l_no_data_found := TRUE;

   AML_DEBUG('-');
   AML_DEBUG('-');
   AML_DEBUG('==============================================================');
   AML_DEBUG('Checking data mapping in as_sales_lead_lines table...');
   AML_DEBUG('==============================================================');
   AML_DEBUG('-');
   AML_DEBUG('-');
   AML_DEBUG('(2).');
   AML_DEBUG('The following data in as_sales_lead_lines do not have a mapping');
   AML_DEBUG('to Single Product Hierarchy.');
   AML_DEBUG('-');
   AML_DEBUG('     Code                                 Meaning');
   AML_DEBUG('-------------------------------------------------------------------------------------');

   FOR x IN c_lead_line_values LOOP
      AML_DEBUG(RPAD(x.code, 30) || '   ' || RPAD(x.meaning, 100));
      l_no_data_found := FALSE;
   END LOOP;


   IF (l_no_data_found) THEN
      AML_DEBUG('-');
      AML_DEBUG('-');
      AML_DEBUG('No rows returned.');
      AML_DEBUG('-');
   END IF;


   AML_DEBUG('==============================================================');
   AML_DEBUG('Checking Stale/Invalid Interest Typed/Codes in as_sales_lead_lines table...');
   AML_DEBUG('==============================================================');
   AML_DEBUG('-');
   AML_DEBUG('-');
   AML_DEBUG('(3).');
   AML_DEBUG('The following data in the Sales Lead Lines donot have ');
   AML_DEBUG('enabled Interest Types/ Interest Codes.');
   AML_DEBUG('-');
   AML_DEBUG('     Code                ');
   AML_DEBUG('---------------------------------------------------');

   FOR x IN c_sales_lead_line_int LOOP
      AML_DEBUG(RPAD(x.code, 30));
      l_no_data_found := FALSE;
   END LOOP;

   IF (l_no_data_found) THEN
      AML_DEBUG('-');
      AML_DEBUG('-');
      AML_DEBUG('No rows returned.');
      AML_DEBUG('-');
   END IF;

End Display_category_mappings;

PROCEDURE MIGRATE_LEAD_LINES (
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_trace_mode       IN  VARCHAR2) IS
l_status                 BOOLEAN;
l_no_data_found          BOOLEAN := TRUE;

l_min_id                 NUMBER  := 0;
l_max_id                 NUMBER  := 0;
l_sales_lead_lines_biud  BOOLEAN := FALSE;
l_trigger                VARCHAR2(200) := NULL;
l_count                  NUMBER := 0;

CURSOR get_min_id IS
SELECT min(sales_lead_line_id)
  FROM as_sales_lead_lines;

CURSOR get_max_id IS
SELECT max(sales_lead_line_id)
  FROM as_sales_lead_lines;

CURSOR get_next_val IS
SELECT as_sales_lead_lines_s.nextval
  FROM dual;

CURSOR Get_Disabled_Triggers(c_schema_name VARCHAR2) IS
SELECT trigger_name
  FROM all_triggers
 WHERE table_owner = c_schema_name
   AND trigger_name = 'AS_SALES_LEAD_LINES_BIUD'
   AND nvl(status,'DISABLED') = 'ENABLED';


BEGIN
   IF p_trace_mode = 'Y' THEN
       dbms_session.set_sql_trace(TRUE);
   ELSE
       dbms_session.set_sql_trace(FALSE);
   END IF;

   -- Schema name is loaded..
   Load_Schema_Name;

   -- First find out the existing state of the triggers
   OPEN Get_Disabled_Triggers(G_SCHEMA_NAME);
   FETCH Get_Disabled_Triggers INTO l_trigger;
   IF Get_Disabled_Triggers%FOUND THEN
      l_sales_lead_lines_biud := true;
   END IF;
   CLOSE Get_Disabled_Triggers;

   -- Disable the sales_lead_line_biud trigger, if that is in enabled status..
   IF l_sales_lead_lines_biud THEN
      Disable_Triggers;
   END IF;

   --Create temp index..
   Create_Temp_Index('AS_SALES_LEAD_LINES','SALES_LEAD_LINE_ID,INTEREST_TYPE_ID,PRIMARY_INTEREST_CODE_ID,SECONDARY_INTEREST_CODE_ID');

   --Get the min sales_lead_line id..
   OPEN Get_Min_Id;
   FETCH Get_Min_Id into l_min_id;
   CLOSE Get_Min_Id;

   --Get the next val for sales_lead_line from the seq..
   OPEN Get_Next_Val;
   FETCH Get_Next_Val into l_max_id;
   CLOSE Get_Next_Val;



   --Display the mappings..
   Display_category_mappings;

   -- Migration starts here..
   --Migration logic changed. Now we have 3 statements..

    -- Initialize counter
    l_count := l_min_id;

    WHILE (l_count <= l_max_id)
    LOOP
       -- Update interest type
        update as_sales_lead_lines l
           set (category_id, category_set_id) =
                (select int.product_category_id, int.product_cat_set_id
                from as_interest_types_b int
                where l.interest_type_id = int.interest_type_id)
         where l.sales_lead_line_id >= l_count
           and l.sales_lead_line_id < l_count+G_BATCH_SIZE
           and l.interest_type_id is not null
           and l.primary_interest_code_id is null
           and l.secondary_interest_code_id is null;

        -- Update primary interest code
        update as_sales_lead_lines l
           set (category_id, category_set_id) =
	       (select int.product_category_id, int.product_cat_set_id
                  from as_interest_codes_b int
                 where l.primary_interest_code_id = int.interest_code_id)
         where l.sales_lead_line_id >= l_count
           and l.sales_lead_line_id < l_count+G_BATCH_SIZE
           and l.primary_interest_code_id is not null
           and l.secondary_interest_code_id is null;

        -- Update secondary interest code
        update as_sales_lead_lines l
           set (category_id, category_set_id) =
               (select int.product_category_id, int.product_cat_set_id
                from as_interest_codes_b int
                where l.secondary_interest_code_id = int.interest_code_id)
         where l.sales_lead_line_id >= l_count
           and l.sales_lead_line_id < l_count+G_BATCH_SIZE
           and l.secondary_interest_code_id is not null;

        -- commit after each batch
        commit;

        l_count := l_count + G_BATCH_SIZE;
    END LOOP;
    COMMIT;

    -- Drop temporary index
    Drop_Temp_Index('AS_SALES_LEAD_LINES');

    -- Enable All the triggers
    If l_sales_lead_lines_biud then
       Enable_Triggers;
    End if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      AML_DEBUG('Expected error');

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      AML_DEBUG('Unexpected error');

  WHEN others THEN
      AML_DEBUG('Exception: others in MIGRATE_LEAD_LINES');
      AML_DEBUG('SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));

      errbuf := SQLERRM;
      retcode := FND_API.G_RET_STS_UNEXP_ERROR;
      --Triggers should be enabled and temp index should be dropped even
      --in the case of exception..
      If l_sales_lead_lines_biud then
         Enable_Triggers;
      End if;

      Drop_Temp_Index('AS_SALES_LEAD_LINES');
      --
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
end MIGRATE_LEAD_LINES;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |  AML_AML_DEBUG
 |
 | PURPOSE
 |  Write debug message
 |
 | NOTES
 |
 |
 | HISTORY
 |   01/12/2004  SOLIN  Created
 *-------------------------------------------------------------------------*/


PROCEDURE AML_DEBUG(msg IN VARCHAR2)
IS
l_length        NUMBER;
l_start         NUMBER := 1;
l_substring     VARCHAR2(255);

l_base          VARCHAR2(12);
BEGIN
--    IF g_debug_flag = 'Y'
--    THEN
        -- chop the message to 255 long
        l_length := length(msg);
        WHILE l_length > 255 LOOP
            l_substring := substr(msg, l_start, 255);
            FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
            -- dbms_output.put_line(l_substring);

            l_start := l_start + 255;
            l_length := l_length - 255;
        END LOOP;

        l_substring := substr(msg, l_start);
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_substring);
        --dbms_output.put_line(l_substring);
--    END IF;
EXCEPTION
WHEN others THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in AML_DEBUG');
      FND_FILE.PUT_LINE(FND_FILE.LOG,
               'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));
END AML_DEBUG;

end AML_CATEGORY_MIGRATION;

/
