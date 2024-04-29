--------------------------------------------------------
--  DDL for Package Body HZ_MIXNM_DYNAMIC_PKG_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MIXNM_DYNAMIC_PKG_GENERATOR" AS
/*$Header: ARHXGENB.pls 120.33.12010000.3 2008/11/06 06:47:55 rgokavar ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

TYPE INDEXVARCHAR30List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE INDEXVARCHAR60List IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;
TYPE NUMBERList IS TABLE OF NUMBER;
TYPE INDEXVARCHAR1List IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE INDEXIDList IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

G_O_ALL_ATTRIBUTE_NAMES             INDEXVARCHAR30List;
G_O_DATA_TYPE                       INDEXVARCHAR30List;
G_O_DATA_LENGTH                     NUMBERList;
G_O_DE_COLUMN_NAMES                 INDEXVARCHAR30List;
G_P_ALL_ATTRIBUTE_NAMES             INDEXVARCHAR30List;
G_P_DATA_TYPE                       INDEXVARCHAR30List;
G_P_DATA_LENGTH                     NUMBERList;
G_P_DE_COLUMN_NAMES                 INDEXVARCHAR30List;
G_MAX_LENGTH                        NUMBER := 400;
G_SETUP_LOADED                      VARCHAR2(1) := 'N';

G_ATTRIBUTE_GROUP_NAME_TAB          INDEXVARCHAR30List;
G_ATTRIBUTE_NAME_TAB                INDEXVARCHAR30List;
G_ATTRIBUTE_GROUP_ISTART_TAB        INDEXIDList;
G_ATTRIBUTE_GROUP_IEND_TAB          INDEXIDList;
G_ATTRIBUTE_GROUP_ID_TAB            INDEXIDList;

G_O_WINNER_ATTRIBUTE_NAMES          INDEXVARCHAR30List;
G_O_WINNER_DATA_SRC                 INDEXVARCHAR30List;
G_P_WINNER_ATTRIBUTE_NAMES          INDEXVARCHAR30List;
G_P_WINNER_DATA_SRC                 INDEXVARCHAR30List;

g_indent                            CONSTANT VARCHAR2(10) := '  ';
g_sep                               CONSTANT VARCHAR2(2) := '%#';
g_to_char                           CONSTANT VARCHAR2(10) := 'TO_CHAR(';
g_to_number                         CONSTANT VARCHAR2(10) := 'TO_NUMBER(';
g_to_date                           CONSTANT VARCHAR2(10) := 'TO_DATE(';

--------------------------------------
-- private procedures and functions
--------------------------------------

/**
 * PRIVATE PROCEDURE l, li, ll, lli, fp
 *
 * DESCRIPTION
 *    Utilities to write line or format line.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_package_name               Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE l(
    str                             IN     VARCHAR2
) IS
BEGIN
    HZ_GEN_PLSQL.add_line(str);
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,str);
END l;

PROCEDURE li(
    str                             IN     VARCHAR2
) IS
BEGIN
    HZ_GEN_PLSQL.add_line(g_indent||str);
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,g_indent||str);
END li;

PROCEDURE ll(
    str                             IN     VARCHAR2
) IS
BEGIN
    HZ_GEN_PLSQL.add_line(str, false);
    -- FND_FILE.PUT(FND_FILE.LOG,str);
END ll;

PROCEDURE lli(
    str                             IN     VARCHAR2
) IS
BEGIN
    HZ_GEN_PLSQL.add_line(g_indent||str, false);
    -- FND_FILE.PUT(FND_FILE.LOG,g_indent||str);
END lli;

FUNCTION fp(
    p_parameter                     IN     VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    RETURN RPAD(p_parameter,35);
END fp;


PROCEDURE getBulkCreateWhereCondition
IS
BEGIN

    li('  WHERE d_user_entered.'||'party_id BETWEEN p_from_party_id AND p_to_party_id');
    li('  AND d_user_entered.actual_content_source = ''SST''');
    li('  AND d_user_entered.effective_end_date IS NULL');

END getBulkCreateWhereCondition;

-- where clause for import data load during create
PROCEDURE getImportCreateWhereCondition
IS
BEGIN
    li('  WHERE d_user_entered.'||'party_id = sg.party_id ');
    li('  AND sg.int_row_id = i.rowid ');
    li('  AND i.interface_status is null ');
    li('  AND i.batch_id = P_BATCH_ID ');
    li('  AND i.party_orig_system = P_WU_OS ');
    li('  AND i.party_orig_system_reference between P_FROM_OSR and P_TO_OSR ');
    li('  AND d_user_entered.actual_content_source = ''SST''');
    li('  AND d_user_entered.effective_end_date IS NULL');

END getImportCreateWhereCondition;

PROCEDURE getBulkUpdateWhereCondition
IS
BEGIN

    li('  WHERE sst.'||'party_id BETWEEN p_from_party_id AND p_to_party_id');
    li('  AND sst.actual_content_source = ''SST''');
    li('  AND sst.effective_end_date IS NULL');


END getBulkUpdateWhereCondition;

-- where clause for import data load during update
PROCEDURE getImportUpdateWhereCondition
IS
BEGIN

    li('  WHERE sst.'||'party_id = sg.party_id ');
    li('  AND sg.int_row_id = i.rowid ');
    li('  AND i.interface_status is null ');
    li('  AND i.batch_id = P_BATCH_ID ');
    li('  AND i.party_orig_system = P_WU_OS ');
    li('  AND i.party_orig_system_reference between P_FROM_OSR and P_TO_OSR ');
    li('  AND sst.actual_content_source = ''SST''');
    li('  AND sst.effective_end_date IS NULL');

END getImportUpdateWhereCondition;

/**
 * PRIVATE PROCEDURE Gen_PackageHeader
 *
 * DESCRIPTION
 *     Generate package header.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_package_name               Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_PackageHeader (
    p_package_name                  IN     VARCHAR2
) IS
BEGIN
l('CREATE OR REPLACE PACKAGE BODY '||p_package_name||' AS');
l('');
l('/*=======================================================================+');
l(' |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|');
l(' |                          All rights reserved.                         |');
l(' +=======================================================================+');
l(' | NAME '||p_package_name);
l(' |');
l(' | DESCRIPTION');
l(' |   This package body is generated by TCA mix-n-match project. ');
l(' |');
l(' | HISTORY');
l(' |  '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')||'      Generated.');
l(' |');
l(' *=======================================================================*/');
l('');
END Gen_PackageHeader;

/**
 * PRIVATE PROCEDURE Gen_PackageTail
 *
 * DESCRIPTION
 *     Generate package tail.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_package_name               Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_PackageTail (
    p_package_name                  IN     VARCHAR2
) IS
BEGIN
  l('END '||p_package_name||';');
END Gen_PackageTail;

/**
 * PRIVATE PROCEDURE Get_Index
 *
 * DESCRIPTION
 *   Return the index of a name in a name list.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * IN:
 *   p_list                         Name list.
 *   p_name                         Name you want to search.
 *
 * MODIFICATION HISTORY
 *
 *   04-30-2002    Jianying Huang   o Created.
 */

FUNCTION Get_Index (
    p_list                          IN     INDEXVARCHAR30List,
    p_name                          IN     VARCHAR2
) RETURN NUMBER IS

    l_start                         NUMBER;
    l_end                           NUMBER;
    l_middle                        NUMBER;

BEGIN

    l_start := 1;  l_end := p_list.COUNT;

    WHILE l_start <= l_end LOOP
      l_middle := ROUND((l_end+l_start)/2);

      IF p_name = p_list(l_middle) THEN
        RETURN l_middle;
      ELSIF p_name > p_list(l_middle) THEN
        l_start := l_middle+1;
      ELSE
        l_end := l_middle-1;
      END IF;
    END LOOP;

    RETURN 0;

END Get_Index;

/**
 * PRIVATE PROCEDURE Load_AllAttrAndGroup
 *
 * DESCRIPTION
 *     Generate package tail.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_entity_name                Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Load_AllAttrAndGroup IS
    l_status VARCHAR2(255);
    l_owner1 VARCHAR2(255);
    l_temp VARCHAR2(255);

    CURSOR c_all_attributes (
      p_entity_name                 VARCHAR2,
      l_apps_schema                 VARCHAR2,
      l_ar_schema                   VARCHAR2
    ) IS
    -- Bug 4697840
   select aa.argument_name, aa.data_type, aa.data_length, party.column_name
     from sys.all_arguments aa, (
          select min(a.sequence) id
            from sys.all_arguments a
           where a.object_name = 'GET_' ||upper (p_entity_name)||'_REC'
             and a.type_subname = upper (p_entity_name) || '_REC_TYPE'
             and a.data_level = 0
             and a.object_id in (
                 select b.object_id
                   from sys.all_objects b
                  where b.object_name = 'HZ_PARTY_V2PUB'
                    and b.owner = l_apps_schema
                    and b.object_type = 'PACKAGE')) temp1, (
          select column_name
            from sys.all_tab_columns c
           where c.table_name = 'HZ_PARTIES'
             and c.owner = l_ar_schema
             and exists (
                 select null
                   from sys.all_tab_columns c2
                  where c2.owner = l_ar_schema
                    and c2.column_name = c.column_name
                    and c2.table_name = 'HZ_' ||upper (p_entity_name) || '_PROFILES')
             and c.column_name not like 'ATTRIBUTE%'
             and c.column_name not like 'GLOBAL_ATTRIBUTE%'
             and c.column_name not in ('APPLICATION_ID')) party
    where aa.object_name = 'GET_' ||upper (p_entity_name)||'_REC'
      and aa.data_level = 1
      and aa.data_type <> 'PL/SQL RECORD'
      and aa.argument_name not in ('CONTENT_SOURCE_TYPE',
          'ACTUAL_CONTENT_SOURCE', 'APPLICATION_ID')
      and aa.sequence > temp1.id
      and aa.object_id in (
          select b.object_id
            from sys.all_objects b
           where b.object_name = 'HZ_PARTY_V2PUB'
             and b.owner = l_apps_schema
             and b.object_type = 'PACKAGE')
      and aa.argument_name = party.column_name (+)
    union all
   select 'BANK_CODE' argument_name, 'VARCHAR2' data_type,
          30 data_length, null column_name
     from dual
    union all
   select 'BANK_OR_BRANCH_NUMBER' argument_name, 'VARCHAR2' data_type,
          60 data_length, null column_name
     from dual
    union all
   select 'BRANCH_CODE' argument_name, 'VARCHAR2' data_type,
          30 data_length, null column_name
     from dual
    order by argument_name;

    l_entity_name                   VARCHAR2(30);

    CURSOR c_group IS
      SELECT attribute_group_name, attribute_name, entity_attr_id
      FROM hz_entity_attributes
      WHERE attribute_name IS NOT NULL
      ORDER BY attribute_group_name;

    l_group                         INDEXVARCHAR30List;
    j                               NUMBER;
    total                           NUMBER;
    l_index                         NUMBER;
    l_length                        NUMBER;
    l_data_type                     VARCHAR2(30);
    l_apps_schema                           VARCHAR2(255);
    l_ar_schema                             VARCHAR2(255);
    l_bool                          BOOLEAN;
BEGIN

    l_apps_schema := hz_utility_v2pub.Get_AppsSchemaName;
    l_ar_schema := hz_utility_v2pub.Get_SchemaName('AR');

    IF G_SETUP_LOADED = 'Y' THEN
      RETURN;
    END IF;

    --load attributes for organization and person

    FOR i IN 1..2 LOOP
      IF i = 1 THEN
        l_entity_name := 'organization' ;
      ELSE
        l_entity_name := 'person' ;
      END IF;

      OPEN c_all_attributes(l_entity_name, l_apps_schema, l_ar_schema);
      IF l_entity_name = 'organization' THEN
        FETCH c_all_attributes BULK COLLECT INTO
          G_O_ALL_ATTRIBUTE_NAMES, G_O_DATA_TYPE, G_O_DATA_LENGTH, G_O_DE_COLUMN_NAMES;
      ELSE
        FETCH c_all_attributes BULK COLLECT INTO
        G_P_ALL_ATTRIBUTE_NAMES, G_P_DATA_TYPE, G_P_DATA_LENGTH, G_P_DE_COLUMN_NAMES;
      END IF;
      CLOSE c_all_attributes;

    END LOOP;

    -- load group

    OPEN c_group;
    FETCH c_group BULK COLLECT INTO l_group, G_ATTRIBUTE_NAME_TAB, G_ATTRIBUTE_GROUP_ID_TAB;
    CLOSE c_group;

    j := 0; total := 0;
    FOR i IN 1..l_group.COUNT+1 LOOP
      IF i = l_group.COUNT+1 OR
         (i > 1 AND
          l_group(i-1) <> l_group(i))
      THEN

        IF total > 1 THEN
          j := j + 1;
          G_ATTRIBUTE_GROUP_NAME_TAB(j) := l_group(i-1);
          G_ATTRIBUTE_GROUP_ISTART_TAB(j) := i-total;
          G_ATTRIBUTE_GROUP_IEND_TAB(j) := i-1;
        END IF;

        IF i = l_group.COUNT+1 THEN
          EXIT;
        END IF;

        total := 0;
      END IF;

      l_index := Get_Index(G_O_ALL_ATTRIBUTE_NAMES, G_ATTRIBUTE_NAME_TAB(i));
      IF l_index = 0 THEN
        l_index := Get_Index(G_P_ALL_ATTRIBUTE_NAMES, G_ATTRIBUTE_NAME_TAB(i));
        l_data_type := G_P_DATA_TYPE(l_index);
        l_length := G_P_DATA_LENGTH(l_index);
      ELSE
        l_data_type := G_O_DATA_TYPE(l_index);
        l_length := G_O_DATA_LENGTH(l_index);
      END IF;

      IF l_data_type = 'NUMBER' THEN
        l_length := 50;
      ELSIF l_data_type = 'DATE' THEN
        l_length := 25;
      END IF;
      l_length := l_length+40;

      IF l_length > G_MAX_LENGTH THEN
        G_MAX_LENGTH := l_length;
      END IF;

      total := total + 1;
    END LOOP;

    G_SETUP_LOADED := 'Y';

END Load_AllAttrAndGroup;

/**
 * PRIVATE PROCEDURE Get_NameListInAGroup
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Get_NameListInAGroup (
    p_group_name                       IN     VARCHAR2,
    x_group_name                       OUT    NOCOPY INDEXVARCHAR30List,
    x_group_id                         OUT    NOCOPY INDEXIDList
) IS

    l_index                            NUMBER;
    j                                  NUMBER := 0;

BEGIN

    IF p_group_name IS NULL THEN
      RETURN;
    END IF;

    l_index := Get_Index(G_ATTRIBUTE_GROUP_NAME_TAB, p_group_name);
    IF  l_index > 0 THEN
      FOR i IN G_ATTRIBUTE_GROUP_ISTART_TAB(l_index)..G_ATTRIBUTE_GROUP_IEND_TAB(l_index) LOOP
        j := j + 1;
        x_group_name(j) := G_ATTRIBUTE_NAME_TAB(i);
        x_group_id(j) := G_ATTRIBUTE_GROUP_ID_TAB(i);
      END LOOP;
    END IF;

END Get_NameListInAGroup;

/**
 * PRIVATE PROCEDURE Gen_ProcedureUtilForBulk
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 *   12-05-2003    Kate shan        o add code to genrate import related
 *                                    procedure and log
 */

PROCEDURE Gen_ProcedureUtilForBulk (
    p_mode                          IN     VARCHAR2,
    p_procedure_name                IN     VARCHAR2 := NULL
) IS
BEGIN

    IF p_mode = 'Header' THEN
      l('PROCEDURE '||p_procedure_name||' (');
      li(fp('p_from_party_id')||'IN     NUMBER,');
      li(fp('p_to_party_id')||'IN     NUMBER,');
      li(fp('p_commit_size')||'IN     NUMBER');
      l(') IS');
    ELSIF p_mode = 'ImportHeader' THEN
      l('PROCEDURE '||p_procedure_name||' (');
      li(fp('p_wu_os')||'IN     VARCHAR2,');
      li(fp('p_from_osr')||'IN     VARCHAR2,');
      li(fp('p_to_osr')||'IN     VARCHAR2,');
      li(fp('p_batch_id')||'IN     NUMBER,');
      li(fp('p_request_id')||'IN     NUMBER,');
      li(fp('p_program_id')||'IN     NUMBER,');
      li(fp('p_program_application_id')||'IN     NUMBER');
      l(') IS');
    ELSIF p_mode = 'Log' THEN
      li('write_log(''p_from_party_id = ''||p_from_party_id);');
      li('write_log(''p_to_party_id = ''||p_to_party_id);');
      li('write_log(''p_commit_size = ''||p_commit_size);');
      l('');
    ELSIF p_mode = 'ImportLog' THEN
      li('write_log(''p_wu_os = ''||p_wu_os);');
      li('write_log(''p_from_osr = ''||p_from_osr);');
      li('write_log(''p_to_osr = ''||p_to_osr);');
      li('write_log(''p_batch_id = ''||p_batch_id);');
      li('write_log(''p_request_id = ''||p_request_id);');
      li('write_log(''p_program_id = ''||p_program_id);');
      li('write_log(''p_program_application_id = ''||p_program_application_id);');
      l('');
    ELSIF p_mode = 'NullBody' THEN
      l('BEGIN');
      li('NULL;');
      l('END '||p_procedure_name||';');
      l('');
    END IF;

END Gen_ProcedureUtilForBulk;

/**
 * PRIVATE PROCEDURE Gen_CodeForCursor
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 *   12-05-2003    Kate shan        o add p_purpose for differentiate
 *                                    import and bulk. Do not generate
 *                                    commit related variable during import
 */

PROCEDURE Gen_CodeForCursor (
    p_option                        IN     VARCHAR2,
    p_cursor_name                   IN     VARCHAR2 DEFAULT NULL,
    p_bulk_flag                     IN     VARCHAR2 DEFAULT NULL,
    p_purpose                       IN     VARCHAR2 DEFAULT 'BULK'
) IS
BEGIN

    IF p_option = 'DECLARE' THEN

      li(fp('rows')||'NUMBER := 500;');
      IF UPPER(p_purpose) = 'BULK' THEN
        li(fp('i_commit')||'NUMBER;');
      END IF;
      li(fp('l_last_fetch')||'BOOLEAN := FALSE;');
      l('');

    ELSIF p_option = 'OPEN' THEN

      li('-- initilize env variables.');
      IF UPPER(p_purpose) = 'BULK' THEN
        li('i_commit := 0;');
      END IF;
      li('l_last_fetch := FALSE;');
      l('');
      li('OPEN '||p_cursor_name||';');
      li('LOOP');
      lli('  FETCH '||p_cursor_name||' ');

      IF p_bulk_flag = 'Y' THEN
        l('BULK COLLECT INTO');
      ELSE
        l('INTO');
      END IF;

    ELSIF p_option = 'FETCH' THEN

      li('  IF '||p_cursor_name||'%NOTFOUND THEN');
      li('    l_last_fetch := TRUE;');
      li('  END IF;');

    ELSIF p_option = 'CLOSE' THEN

      li('  IF l_last_fetch = TRUE THEN');
      li('    EXIT;');
      li('  END IF;');
      li('END LOOP;');
      li('CLOSE '||p_cursor_name||';');
      IF UPPER(p_purpose) = 'BULK' THEN
        li('COMMIT;');
      END IF;

    END IF;

END Gen_CodeForCursor;

/**
 * PRIVATE PROCEDURE Gen_CodeForCommit
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_CodeForCommit (
    p_write_log                     IN     BOOLEAN := true,
    p_prefix                        IN     VARCHAR2 := '  '
) IS
BEGIN

    li(p_prefix||'IF SQL%FOUND THEN');

    IF p_write_log THEN
      li(p_prefix||'  write_log(SQL%ROWCOUNT||'' records have been created / updated.'');');
      l('');
    END IF;

    li(p_prefix||'  i_commit := i_commit + SQL%ROWCOUNT;');
    li(p_prefix||'  IF i_commit >= p_commit_size THEN');
    li(p_prefix||'    COMMIT;');
    li(p_prefix||'    i_commit := 0;');
    li(p_prefix||'  END IF;');
    li(p_prefix||'END IF;');
    l('');

END Gen_CodeForCommit;

/**
 * PRIVATE PROCEDURE Gen_CodeForWhoColumns
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_CodeForWhoColumns (
    p_insert_update_flag            IN     VARCHAR2,
    p_option                        IN     VARCHAR2,
    p_prefix                        IN     VARCHAR2,
    p_extended_who_flag             IN     VARCHAR2
) IS
BEGIN

    IF p_insert_update_flag = 'I' THEN
      IF p_option = 'LIST' THEN

        l(p_prefix||'created_by,');
        l(p_prefix||'creation_date,');
        l(p_prefix||'last_update_login,');
        l(p_prefix||'last_update_date,');
        ll(p_prefix||'last_updated_by');

        IF p_extended_who_flag = 'Y' THEN
          l(',');
          l(p_prefix||'request_id,');
          l(p_prefix||'program_application_id,');
          l(p_prefix||'program_id,');
          ll(p_prefix||'program_update_date');
        END IF;

      ELSE  -- IF p_option = 'LIST' THEN

        l(p_prefix||'g_created_by,');
        l(p_prefix||'SYSDATE,');
        l(p_prefix||'g_last_update_login,');
        l(p_prefix||'SYSDATE,');
        ll(p_prefix||'g_last_updated_by');

        IF p_extended_who_flag = 'Y' THEN
          l(',');
          l(p_prefix||'g_request_id,');
          l(p_prefix||'g_program_application_id,');
          l(p_prefix||'g_program_id,');
          ll(p_prefix||'SYSDATE');
        END IF;

      END IF;

    ELSE -- IF p_insert_update_flag = 'I' THEN

      l(p_prefix||'last_updated_by = g_last_updated_by,');
      l(p_prefix||'last_update_login = g_last_update_login,');
      ll(p_prefix||'last_update_date = SYSDATE');

      IF p_extended_who_flag = 'Y' THEN
        l(',');
        l(p_prefix||'request_id = g_request_id,');
        l(p_prefix||'program_application_id = g_program_application_id,');
        l(p_prefix||'program_id = g_program_id,');
        ll(p_prefix||'program_update_date = SYSDATE');
      END IF;

    END IF;

END Gen_CodeForWhoColumns;

/**
 * PRIVATE PROCEDURE Gen_CodeForOtherAttributes
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_CodeForOtherAttributes (
    p_option                        IN     VARCHAR2,
    p_prefix                        IN     VARCHAR2
) IS
BEGIN

    IF p_option = 'LIST' THEN
      l(p_prefix||'content_source_type,');
      l(p_prefix||'actual_content_source,');
--      l(p_prefix||'created_by_module,');
      ll(p_prefix||'application_id');
    ELSE
      l(p_prefix||'''USER_ENTERED'',');
      l(p_prefix||'''SST'',');
--      l(p_prefix||'''TCA-MIXNMATCH-CONCPROGRAM'',');
      ll(p_prefix||'222');
    END IF;

END Gen_CodeForOtherAttributes;

/**
 * PRIVATE PROCEDURE Format_AttributeName
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

FUNCTION Format_AttributeName (
    p_attribute_name                IN     VARCHAR2
) RETURN VARCHAR2 IS

    str1                            VARCHAR2(30);

BEGIN

    str1 := LOWER(p_attribute_name);
    IF LENGTHB(str1) > 28 THEN
      str1 := SUBSTRB(str1,3);
    END IF;
    RETURN str1;

END Format_AttributeName;

/**
 * PRIVATE PROCEDURE Declare_AllAttributes
 *
 * DESCRIPTION
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Createda
 *   17-12-2004	   Dhaval Mehta	    SSM SST Project
 *				    ~ Added parameter p_attributes_date for
 *				      the list of attributes setup for
 *				      SST Display method 'By Date'.
 */

PROCEDURE Declare_Attributes (
    p_entity_name                   IN     VARCHAR2,
    p_restricted_attributes         IN     INDEXVARCHAR30List,
    p_attributes_date               IN     INDEXVARCHAR30List,
    x_normal_attributes             OUT NOCOPY   INDEXVARCHAR30List
) IS

    l_all_attribute_names           INDEXVARCHAR30List;
    l_data_type                     INDEXVARCHAR30List;
    l_data_length                   NUMBERList;
    l_index                         NUMBER;
    l_type                          VARCHAR2(30);
    j                               NUMBER;
    str1                            VARCHAR2(100);
    l_index_date		    NUMBER;

BEGIN

    IF p_entity_name = 'organization' THEN
      l_all_attribute_names := G_O_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_O_DATA_TYPE;
      l_data_length := G_O_DATA_LENGTH;
    ELSE
      l_all_attribute_names := G_P_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_P_DATA_TYPE;
      l_data_length := G_P_DATA_LENGTH;
    END IF;

    j := 0;
    FOR i IN 1..l_all_attribute_names.COUNT LOOP
      If(p_entity_name = 'organization' OR
	 (p_entity_name = 'person' AND
         l_all_attribute_names(i) <> 'BANK_CODE' AND
         l_all_attribute_names(i) <> 'BANK_OR_BRANCH_NUMBER' AND
         l_all_attribute_names(i) <> 'BRANCH_CODE')) Then
      str1 := Format_AttributeName(l_all_attribute_names(i));

      l_index := Get_Index(p_restricted_attributes, l_all_attribute_names(i));
      -- SSM SST Project : check if attribute is 'By Date' type
      l_index_date := Get_Index(p_attributes_date, l_all_attribute_names(i));

      -- SSM SST Project :
      -- If the attribute is not 'By Rank' and not 'By Date'
      -- it is unrestricted attribute.
      -- Declare a table of the data type of attribute
      -- and local variable of this table type
      IF (l_index = 0 AND l_index_date = 0) THEN
        j := j+1; x_normal_attributes(j) := l_all_attribute_names(i);

        l_type := l_data_type(i);
        IF l_type = 'VARCHAR2' THEN
          l_type := 'VARCHAR2('||l_data_length(i)||')';
        END IF;

        li('TYPE t_'||str1||' IS TABLE OF '||l_type||' INDEX BY BINARY_INTEGER;');
        li(fp('i_'||str1)||'t_'||str1||';');

      ELSIF l_index_date <> 0 THEN
      -- SSM SST Project :
      -- it attribute is 'By Date',
      -- Declare a table of the data type of attribute
      -- and local variable of this table type
        l_type := l_data_type(i);
        IF l_type = 'VARCHAR2' THEN
          l_type := 'VARCHAR2('||l_data_length(i)||')';
        END IF;

      -- SSM SST Project :
      -- also declare variable to store actual_content_source
      -- for this attribute during BULK COLLECT
      -- i.e. knownas
        li('TYPE t_'||str1||' IS TABLE OF '||l_type||' INDEX BY BINARY_INTEGER;');
        li(fp('i_'||str1)||'t_'||str1||';');
	li(fp(str1)||'INDEXVARCHARlist;');
      ELSE
      -- SSM SST Project :
      -- it attribute is 'By Rank',
      -- Declare a local variable of type table VARCHARlist
        li(fp('i_'||str1)||'INDEXVARCHARlist;');
      END IF;
     END IF;
    END LOOP;

    IF p_entity_name = 'organization' THEN
      li('TYPE t_duns_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;');
      li(fp('i_duns_number')||'t_duns_number;');
    ELSE
      li(fp('i_person_name')||'INDEXVARCHARlist;');
    END IF;
    l('');

END Declare_Attributes;

/**
 * PRIVATE PROCEDURE Gen_CommonProceduresForConc
 *
 * DESCRIPTION
 *     Generate common procedures for concurrent program.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 *   17-12-2004    Dhaval Mehta     o SSM SST Integration Project
 *   				      ~ Added code to generate new procedure
 *   				        update_exception_table_date. This
 *   				        procedure is to populate exception
 *   				        table for 'By Date' attributes.
 */

PROCEDURE Gen_CommonProceduresForConc IS

    l_procedure_name          VARCHAR2(30);

BEGIN

    /*===============================================================
     + declare global type and variables
     +===============================================================*/

    l('TYPE INDEXIDlist IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;');
    l('TYPE INDEXVARCHARlist IS TABLE OF VARCHAR2('||G_MAX_LENGTH||') INDEX BY BINARY_INTEGER;');
    l('');
    l(fp('g_created_by')||'NUMBER;');
    l(fp('g_last_update_login')||'NUMBER;');
    l(fp('g_last_updated_by')||'NUMBER;');
    l(fp('g_request_id')||'NUMBER;');
    l(fp('g_program_application_id')||'NUMBER;');
    l(fp('g_program_id')||'NUMBER;');
    l('');

    /*===============================================================
     + write_log
     +===============================================================*/
     --Bug 7188240
     --Changed to do conditional logging based on FND DEBUG Logging profile.
     --Added If condition.

    l_procedure_name := 'write_log';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('str')||'IN     VARCHAR2');
    l(') IS');
    l('BEGIN');
    li('IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN');
    li('FND_FILE.PUT_LINE(FND_FILE.LOG,');
    li('  TO_CHAR(SYSDATE, ''YYYY/MM/DD HH:MI:SS'')||'' -- ''||str);');
    li('END IF;');
    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + write_out
     +===============================================================*/

    l_procedure_name := 'write_out';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('str')||'IN     VARCHAR2');
    l(') IS');
    l('BEGIN');
    li('FND_FILE.PUT_LINE(FND_FILE.OUTPUT,str);');
    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + reset_who
     +===============================================================*/

    l_procedure_name := 'reset_who';

    l('PROCEDURE '||l_procedure_name || ' (');
    li('p_request_id  NUMBER := hz_utility_v2pub.request_id, ');
    li('p_program_id NUMBER := hz_utility_v2pub.program_id,  ');
    li('p_program_application_id NUMBER := hz_utility_v2pub.program_application_id ');
    l(') IS');
    l('BEGIN');
    li('g_created_by := hz_utility_v2pub.created_by;');
    li('g_last_update_login := hz_utility_v2pub.last_update_login;');
    li('g_last_updated_by := hz_utility_v2pub.last_updated_by;');
    li('g_request_id := p_request_id;');
    li('g_program_id := p_program_id;');
    li('g_program_application_id := p_program_application_id;');
    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + update_rel_party_name
     +===============================================================*/

    l_procedure_name := 'update_rel_party_name';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_party_id')||'IN     NUMBER');
    l(') IS');
    li(fp('CURSOR c_party IS'));
    li('  SELECT r.party_id, r.object_id, o.party_name, r.subject_id, s.party_name');
    li('  FROM hz_relationships r, hz_parties s, hz_parties o ');
    li('  WHERE (r.subject_id = p_party_id OR r.object_id = p_party_id)');
    li('  AND r.party_id IS NOT NULL');
    li('  AND r.subject_table_name = ''HZ_PARTIES''');
    li('  AND r.object_table_name = ''HZ_PARTIES''');
    li('  AND r.directional_flag = ''F''');
    li('  AND r.subject_id = s.party_id');
    li('  AND r.object_id = o.party_id;');
    l('');
    li(fp('i_party_id')||'INDEXIDlist;');
    li(fp('i_subject_id')||'INDEXIDlist;');
    li(fp('i_object_id')||'INDEXIDlist;');
    li('TYPE NAMElist IS TABLE OF HZ_PARTIES.PARTY_NAME%TYPE;');
    li(fp('i_subject_name')||'NAMElist;');
    li(fp('i_object_name')||'NAMElist;');
    l('');
    l('BEGIN');
    li('OPEN c_party;');
    li('FETCH c_party BULK COLLECT INTO ');
    li('  i_party_id, i_object_id, i_object_name, i_subject_id, i_subject_name;');
    li('CLOSE c_party;');
    li('');
    li('FORALL i IN 1..i_party_id.COUNT');
    li('  UPDATE hz_parties');
    li('  SET party_name = i_subject_name(i)||''-''||i_object_name(i)||''-''||party_number');
    li('  WHERE party_id = i_party_id(i);');
    l('');
    li('FOR i IN 1..i_party_id.COUNT LOOP');
    li('  '||l_procedure_name||'(i_party_id(i));');
    li('END LOOP;');
    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + update_exception_table
     +===============================================================*/

    l_procedure_name := 'update_exception_table';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_create_update_flag')||'IN     VARCHAR2,');
    li(fp('p_i_party_id')||'IN     INDEXIDlist,');
    li(fp('p_attribute_name')||'IN     VARCHAR2,');
    li(fp('p_entity_attr_id')||'IN     NUMBER,');
    li(fp('p_value_list')||'IN     INDEXVARCHARlist,');
    li(fp('p_winner')||'IN     VARCHAR2');
    l(') IS');
    li(fp('i_party_id1')||'INDEXIDlist;');
    li(fp('i_party_id2')||'INDEXIDlist;');
    li(fp('i_value_list1')||'INDEXVARCHARlist;');
    li(fp('i_value_list2')||'INDEXVARCHARlist;');
    li(fp('i_entity_attr_id')||'INDEXIDlist;');
    li(fp('total1')||'NUMBER := 0;');
    li(fp('total2')||'NUMBER := 0;');
    l('BEGIN');
    li('write_log(''processing exceptions on ''||LOWER(p_attribute_name)||''...'');');
    li('FOR i IN 1..p_i_party_id.COUNT LOOP');
    li('  IF p_value_list(i) IS NOT NULL AND');
    li('     INSTRB(p_value_list(i), '''||g_sep||'''||p_winner) = 0');
    li('  THEN');
    li('    total1 := total1 + 1;');
    li('    i_party_id1(total1) := p_i_party_id(i);');
    li('    i_value_list1(total1) := p_value_list(i);');
    li('  END IF;');
    li('END LOOP;');
    l('');
    li('IF p_create_update_flag = ''C'' THEN');
    li('  FORALL i IN 1..total1');
    li('    INSERT INTO hz_win_source_exceps (');
    li('      party_id, ');
    li('      entity_attr_id, ');
    li('      content_source_type,');
    li('      exception_type,');
    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','Y');
    l('');
    li('    ) VALUES (');
    li('      i_party_id1(i),');
    li('      p_entity_attr_id,');
    li('      trim(SUBSTRB(i_value_list1(i),INSTRB(i_value_list1(i), '''||
       g_sep||''')+2)),');
    li('      ''Migration'',');
    Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','Y');
    l('');
    li('    );');
    l('');
    li('  IF total1 > 0 THEN');
    li('    write_log(''created ''||sql%ROWCOUNT||'' exceptions.'');');
    li('  END IF;');
    l('');
    li('ELSE');
    li('  FOR i IN 1..p_i_party_id.COUNT LOOP');
    li('    IF p_value_list(i) IS NULL OR ');
    li('       (p_value_list(i) IS NOT NULL AND');
    li('        INSTRB(p_value_list(i), '''||g_sep||'''||p_winner) > 0)');
    li('    THEN');
    li('      total2 := total2 + 1;');
    li('      i_party_id2(total2) := p_i_party_id(i);');
    li('      i_value_list2(total2) := p_value_list(i);');
    li('    END IF;');
    li('  END LOOP;');
    l('');
    li('  FORALL i IN 1..total2');
    li('    DELETE hz_win_source_exceps');
    li('    WHERE party_id = i_party_id2(i)');
    li('    AND entity_attr_id = p_entity_attr_id;');
    l('');
    li('  IF total2 > 0 THEN');
    li('    write_log(''Deleted ''||sql%ROWCOUNT||'' exceptions.'');');
    li('  END IF;');
    l('');
    li('  FORALL i IN 1..total1');
    li('    UPDATE hz_win_source_exceps');
    li('    SET content_source_type = '||
      'trim(SUBSTRB(i_value_list1(i),INSTRB(i_value_list1(i), '''||g_sep||''')+2)),');
    li('        exception_type = ''Migration'',');
    Gen_CodeForWhoColumns('U','',g_indent||'        ','Y');
    l('');
    li('    WHERE party_id = i_party_id1(i)');
    li('    AND entity_attr_id = p_entity_attr_id;');
    l('');
    li('  IF total1 > 0 THEN');
    li('    write_log(''Updated ''||sql%ROWCOUNT||'' exceptions.'');');
    li('  END IF;');
    l('');
    li('  FORALL i IN 1..total1');
    li('    INSERT INTO hz_win_source_exceps (');
    li('      party_id, ');
    li('      entity_attr_id,');
    li('      content_source_type,');
    li('      exception_type,');
    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','Y');
    l('');
    li('    )');
    li('    SELECT');
    li('      i_party_id1(i),');
    li('      p_entity_attr_id,');
    li('      trim(SUBSTRB(i_value_list1(i),INSTRB(i_value_list1(i), '''||
      g_sep||''')+2)),');
    li('      ''Migration'',');
    Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','Y');
    l('');
    li('    FROM dual');
    li('    WHERE NOT EXISTS (');
    li('      SELECT ''Y''');
    li('      FROM hz_win_source_exceps');
    li('      WHERE party_id = i_party_id1(i)');
    li('      AND entity_attr_id = p_entity_attr_id );');
    l('');
    li('  IF total1 > 0 THEN');
    li('    write_log(''Created ''||sql%ROWCOUNT||'' exceptions.'');');
    li('  END IF;');
    li('END IF;');
    l('END '||l_procedure_name||';');
    l('');

     /*===============================================================
      + SSM SST Project : update_exception_table for Date Attributes
      +===============================================================*/

    l_procedure_name := 'update_exception_table_date';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_create_update_flag')||'IN     VARCHAR2,');
    li(fp('p_i_party_id')||'IN     INDEXIDlist,');
    li(fp('p_attribute_name')||'IN     VARCHAR2,');
    li(fp('p_entity_attr_id')||'IN     NUMBER,');
    li(fp('p_winner')||'IN     INDEXVARCHARlist');
    l(') IS');
    li(fp('total1')||'NUMBER := 0;');
    l('BEGIN');
    li('write_log(''processing exceptions on ''||LOWER(p_attribute_name)||''...'');');
    li('    total1 := p_i_party_id.COUNT;');
    l('');
    li('IF p_create_update_flag = ''C'' THEN');
    li('  FORALL i IN 1..total1');
    li('    INSERT INTO hz_win_source_exceps (');
    li('      party_id, ');
    li('      entity_attr_id, ');
    li('      content_source_type,');
    li('      exception_type,');
    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','Y');
    l('');
    li('    ) VALUES (');
    li('      p_i_party_id(i),');
    li('      p_entity_attr_id,');
    li('      p_winner(i),');
    li('      ''MRR'',');
    Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','Y');
    l('');
    li('    );');
    l('');
    li('  IF total1 > 0 THEN');
    li('    write_log(''created ''||sql%ROWCOUNT||'' exceptions.'');');
    li('  END IF;');
    l('');
    li('ELSE');
    l('');
    li('  FOR i IN 1..total1 loop');
    li('    UPDATE hz_win_source_exceps');
    li('    SET content_source_type = p_winner(i),');
    li('        exception_type = ''MRR'',');
    Gen_CodeForWhoColumns('U','',g_indent||'        ','Y');
    l('');
    li('    WHERE party_id = p_i_party_id(i)');
    li('    AND entity_attr_id = p_entity_attr_id;');
    l('');
    li('  IF sql%NOTFOUND THEN');
    li('    INSERT INTO hz_win_source_exceps (');
    li('      party_id, ');
    li('      entity_attr_id, ');
    li('      content_source_type,');
    li('      exception_type,');
    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','Y');
    l('');
    li('    ) VALUES (');
    li('      p_i_party_id(i),');
    li('      p_entity_attr_id,');
    li('      p_winner(i),');
    li('      ''MRR'',');
    Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','Y');
    l('');
    li('    );');
    l('');
    li('  END IF;');
    li(' end loop;');
    li('  IF total1 > 0 THEN');
    li('    write_log(''Updated ''||sql%ROWCOUNT||'' exceptions.'');');
    li('  END IF;');
    l('');
    li('END IF;');
    l('END '||l_procedure_name||';');
    l('');

END Gen_CommonProceduresForConc;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *
 * MODIFICATION HISTORY
 *
 */
PROCEDURE Gen_PartyName (
     p_entity_name                   IN     VARCHAR2
) IS
BEGIN

    l(',');
    IF p_entity_name = 'organization' THEN
      li('      party_name = ');
      li('        SUBSTRB(i_organization_name(i),1,'||
         'INSTRB(i_organization_name(i),'''||g_sep||''')-1),');
      li('      customer_key = ');
      li('        DECODE(party_name,');
      li('               SUBSTRB(i_organization_name(i),1,'||
         'INSTRB(i_organization_name(i),'''||g_sep||''')-1),');
      li('               customer_key,');
      li('               hz_fuzzy_pub.generate_key (');
      li('                 ''ORGANIZATION'',');
      li('                 SUBSTRB(i_organization_name(i),1,'||
         'INSTRB(i_organization_name(i),'''||g_sep||''')-1)))');
    ELSE
      li('      party_name = ');
      li('        DECODE(trim(party_name), ');
      li('               trim(person_first_name||'' ''||person_last_name),');
      li('               trim(SUBSTRB(i_person_first_name(i),1,'||
         'INSTRB(i_person_first_name(i),'''||g_sep||''')-1)||'' ''||');
      li('                    SUBSTRB(i_person_last_name(i),1,'||
         'INSTRB(i_person_last_name(i),'''||g_sep||''')-1)),');
      li('               SUBSTRB(SUBSTRB(i_person_name(i),1,'||
         'INSTRB(i_person_name(i),'''||g_sep||''')-1),1,360)),');
      li('       customer_key = ');
      li('         DECODE(person_first_name,');
      li('                SUBSTRB(i_person_first_name(i),1,'||
         'INSTRB(i_person_first_name(i),'''||g_sep||''')-1),');
      li('                DECODE(person_last_name,');
      li('                  SUBSTRB(i_person_last_name(i),1,'||
         'INSTRB(i_person_last_name(i),'''||g_sep||''')-1),');
      li('                  customer_key,');
      li('                  hz_fuzzy_pub.generate_key (');
      li('                    ''PERSON'',null,null,null,null,null,null,');
      li('                    SUBSTRB(i_person_first_name(i),1,'||
         'INSTRB(i_person_first_name(i),'''||g_sep||''')-1),');
      li('                    SUBSTRB(i_person_last_name(i),1,'||
         'INSTRB(i_person_last_name(i),'''||g_sep||''')-1))))');
    END IF;

END Gen_PartyName;

PROCEDURE Gen_RelationshipPartyName IS
BEGIN

/*
    li('  write_log(''update party name of relationship parties.'');');
    l('');
    li('  FOR i IN 1..subtotal LOOP');
    li('    update_rel_party_name(i_party_id(i));');
    li('  END LOOP;');
*/
    l('');
--    Gen_CodeForCommit(false);

END Gen_RelationshipPartyName;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *
 * MODIFICATION HISTORY
 *
 */

PROCEDURE Gen_WriteOutputFileForCreate IS
BEGIN

    li('  FOR i IN 1..i_sst_profile_id.COUNT LOOP');
    li('    write_out(''party id = ''||i_party_id(i)||'', sst profile id = ''||i_sst_profile_id(i));');
    li('  END LOOP;');
    l('');

END Gen_WriteOutputFileForCreate;

PROCEDURE Gen_WriteOutputFileForUpdate IS
BEGIN

    li('  FOR i IN create_start..create_end LOOP');
    li('    write_out(''created : party id = ''||i_party_id(i)||'', sst profile id = ''||i_sst_profile_id(i));');
    li('  END LOOP;');
    l('');
    li('  FOR i IN update_start..update_end LOOP');
    li('    write_out(''updated : party id = ''||i_party_id(i)||'', sst profile id = ''||i_profile_id(i));');
    li('  END LOOP;');
    l('');

END Gen_WriteOutputFileForUpdate;


/**
 * PRIVATE PROCEDURE date_cursor_create
 *
 * DESCRIPTION
 * 	This procedure is used to generate cursor for
 * 	passed attribute_id setup as 'By Date' for
 * 	BulkCreateSST and ImportCreateSST procedures.
 * 	Select the attribute and corresponding actual_content_source
 * 	from the last updated profile among the visible data
 * 	sources for this attribute.
 *
	CURSOR c_KNOWN_AS5 IS
	SELECT user_entered.known_as5, user_entered.actual_content_source
	FROM ( SELECT row_number() over
		(partition by ue.party_id order by ue.last_update_date desc nulls last) rank,
		ue.known_as5 , ue.actual_content_source
	    	FROM hz_organization_profiles ue
		WHERE ue.party_id BETWEEN p_from_party_id AND p_to_party_id
	    	AND ue.effective_end_date IS NULL
	    	AND ue.actual_content_source in ( 'DNB' ,'USER_ENTERED' ...)
	    AND NOT EXISTS (
		USER_ENTERED profile
	    AND EXISTS (
		NON SST, USER_ENTERED profile
	  ) user_entered
	WHERE user_entered.rank = 1

 * MODIFICATION HISTORY
 *
 *  17-12-2004	Dhaval Metha	SSM SST Project
 *  				~ Created.
 */
procedure date_cursor_create(attr_id IN NUMBER,
	attr_name IN VARCHAR2,
	p_entity_name IN VARCHAR2,
	p_purpose IN VARCHAR2) IS
cursor data_sources is
select content_source_type
from hz_select_data_sources
where entity_attr_id = attr_id
and ranking <> 0;

i_content_source_type           INDEXVARCHAR30List;
l_cursor_name_date                  VARCHAR2(30);
l_prefix VARCHAR2(30);

Begin
    OPEN data_sources;
    FETCH data_sources BULK COLLECT INTO i_content_source_type;
    CLOSE data_sources;

    l_cursor_name_date := attr_name||'_';
    l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));

    li('CURSOR '||l_cursor_name_date||' IS');
    li('  SELECT ');

    l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
    ll(l_prefix||'user_entered.'||LOWER(attr_name));
    l(',');
    ll(l_prefix||'user_entered.actual_content_source');

    l('');
    li('  FROM');
      li('( SELECT ');
      li('	row_number() over ');
      ll('	(partition by ue.party_id order by ue.last_update_date desc nulls last) rank, ');
      li(l_prefix||'ue.'||LOWER(attr_name));
      l(',');
      li(l_prefix||'ue.actual_content_source');
      li('  FROM ');
      IF ( UPPER(p_purpose) = 'BULK') THEN
          ll(RPAD(l_prefix,7+LENGTHB(g_indent))||'hz_'||p_entity_name||'_profiles ue');
	  li('  WHERE ue.'||'party_id BETWEEN p_from_party_id AND p_to_party_id');
      ELSIF ( UPPER(p_purpose) = 'IMPORT') THEN
          ll(RPAD(l_prefix,7+LENGTHB(g_indent))||
	  'hz_'||p_entity_name||'_profiles ue');
	  l(',');
	  li('       hz_imp_parties_sg sg,');
	  li('       hz_imp_parties_int i');
	  li('  WHERE ue.'||'party_id = sg.party_id ');
	  li('  AND sg.int_row_id = i.rowid ');
	  li('  AND i.interface_status is null ');
	  li('  AND i.batch_id = P_BATCH_ID ');
	  li('  AND i.party_orig_system = P_WU_OS ');
	  li('  AND i.party_orig_system_reference between P_FROM_OSR and P_TO_OSR ');
      END IF;
      li('  AND ue.effective_end_date IS NULL');
      li('  AND ue.actual_content_source in (');
      FOR i IN 1..i_content_source_type.COUNT LOOP
	  if i <> 1 then
		l(',');
	  end if;
          l(''''||i_content_source_type(i)||'''');
      END LOOP;
      l(')');
      li('  AND NOT EXISTS (');
      li('    SELECT ''Y''');
      li('    FROM hz_'||p_entity_name||'_profiles entity');
      li('    WHERE entity.party_id = ue.party_id');
      li('    AND entity.actual_content_source = ''USER_ENTERED''');
      li('    AND entity.effective_end_date IS NULL )');
      li('  --');
      li('  -- at least one third party profile exists for this party.');
      li('  --');
      li('  AND EXISTS (');
      li('    SELECT ''Y''');
      li('    FROM hz_'||p_entity_name||'_profiles entity');
      li('    WHERE entity.party_id = ue.party_id');
      li('    AND entity.actual_content_source NOT IN (''USER_ENTERED'',''SST'')');
      li('    AND entity.effective_end_date IS NULL )');
      li(') user_entered');
      li('   WHERE user_entered.rank = 1');
      l(';');
END date_cursor_create;

/**
 * PRIVATE PROCEDURE date_cursor_update
 *
 * DESCRIPTION
 * 	This procedure is used to generate cursor for
 * 	passed attribute_id setup as 'By Date' for
 * 	BulkUpdateSST and ImportUpdateSST procedures.
 * 	Select the attribute and corresponding actual_content_source
 * 	from the last updated profile among the visible data
 * 	sources for this attribute.
 *
	CURSOR c_KNOWN_AS5 IS
	SELECT user_entered.known_as5, user_entered.actual_content_source
	FROM ( SELECT decode(fnd_profile.value ('HZ_PROFILE_VERSION'),'NEW_VERSION','C',
			'NO_VERSION','U',
			decode(trunc(ue.effective_start_date),trunc(sysdate),'U','C')) create_update_flag,
           	ue.organization_profile_id,
	        ue.party_id,row_number() over
		(partition by ue.party_id order by ue.last_update_date desc nulls last) rank,
		ue.known_as5 , ue.actual_content_source
	    	FROM hz_organization_profiles ue
		WHERE ue.party_id BETWEEN p_from_party_id AND p_to_party_id
	    	AND ue.effective_end_date IS NULL
	    	AND ue.actual_content_source in ( 'DNB' ,'USER_ENTERED' ...)
	    AND EXISTS (
		USER_ENTERED profile
	    AND EXISTS (
		SST profile
	  ) user_entered
	WHERE user_entered.rank = 1
	ORDER BY create_update_flag

 * MODIFICATION HISTORY
 *
 *  17-12-2004	Dhaval Metha	SSM SST Project
 *  				~ Created.
 */
procedure date_cursor_update(attr_id IN NUMBER,
	attr_name IN VARCHAR2,
	p_entity_name IN VARCHAR2,
	p_purpose IN VARCHAR2) IS
cursor data_sources is
select content_source_type
from hz_select_data_sources
where entity_attr_id = attr_id
and ranking <> 0;

i_content_source_type           INDEXVARCHAR30List;
l_cursor_name_date                  VARCHAR2(30);
l_prefix VARCHAR2(30);

Begin
    OPEN data_sources;
    FETCH data_sources BULK COLLECT INTO i_content_source_type;
    CLOSE data_sources;

    l_cursor_name_date := attr_name||'_';
    l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));

    li('CURSOR '||l_cursor_name_date||' IS');
    li('  SELECT ');

    l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
    ll(l_prefix||'user_entered.'||LOWER(attr_name));
    l(',');
    ll(l_prefix||'user_entered.actual_content_source');

    l('');
    li('  FROM ( ');
    li('  SELECT decode(fnd_profile.value (''HZ_PROFILE_VERSION''),''NEW_VERSION'',''C'',''NO_VERSION'',''U'',decode(trunc(sst.effective_start_date),trunc(sysdate),''U'',''C'')) create_update_flag, ');
l(l_prefix||'ue.'||p_entity_name||'_profile_id,');
    ll(l_prefix||'ue.party_id,');
--      li('( SELECT ');
      li('	row_number() over ');
      ll('	(partition by ue.party_id order by ue.last_update_date desc nulls last) rank, ');
      li(l_prefix||'ue.'||LOWER(attr_name));
      l(',');
      li(l_prefix||'ue.actual_content_source');
      li('  FROM ');
      ll(RPAD(l_prefix,7+LENGTHB(g_indent))||
         'hz_'||p_entity_name||'_profiles sst');
        l(',');
      IF ( UPPER(p_purpose) = 'BULK') THEN
          ll(RPAD(l_prefix,7+LENGTHB(g_indent))||'hz_'||p_entity_name||'_profiles ue');
	  li('  WHERE ue.'||'party_id BETWEEN p_from_party_id AND p_to_party_id');
      ELSIF ( UPPER(p_purpose) = 'IMPORT') THEN
          ll(RPAD(l_prefix,7+LENGTHB(g_indent))||
	  'hz_'||p_entity_name||'_profiles ue');
	  l(',');
	  li('       hz_imp_parties_sg sg,');
	  li('       hz_imp_parties_int i');
	  li('  WHERE ue.'||'party_id = sg.party_id ');
	  li('  AND sg.int_row_id = i.rowid ');
	  li('  AND i.interface_status is null ');
	  li('  AND i.batch_id = P_BATCH_ID ');
	  li('  AND i.party_orig_system = P_WU_OS ');
	  li('  AND i.party_orig_system_reference between P_FROM_OSR and P_TO_OSR ');
      END IF;
      li('  AND sst.'||'party_id = ue.party_id ');
      li('  AND sst.effective_end_date IS NULL');
      li('  AND sst.actual_content_source=''SST''');
      li('  AND ue.effective_end_date IS NULL');
      li('  AND ue.actual_content_source in (');
      FOR i IN 1..i_content_source_type.COUNT LOOP
	  if i <> 1 then
		l(',');
	  end if;
          l(''''||i_content_source_type(i)||'''');
      END LOOP;
      l(')');
    li('  AND EXISTS (');
    li('    SELECT ''Y''');
    li('    FROM hz_'||p_entity_name||'_profiles entity');
    li('    WHERE entity.party_id = ue.party_id');
    li('    AND entity.actual_content_source = ''USER_ENTERED''');
    li('    AND entity.effective_end_date IS NULL )');
    li(') user_entered');
    li('   WHERE user_entered.rank = 1');
    li('ORDER BY create_update_flag,user_entered.party_id;');
END date_cursor_update;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *  p_entity_name                   IN     VARCHAR2,
 *  p_purpose                       IN     VARCHAR2
 *
 * MODIFICATION HISTORY
 *
 *  p_purpose is added for import data load
 *  p_purpose = 'Bulk'  will generate MixNMatch Load procedure
 *  p_purpose = 'Import' will generate Import Load procedure
 *
 *  07-12-2004	Dhaval Mehta	SSM SST Project
 *  				~ Added code to generate cursors
 *  				  for 'By Date' attributes.
 *  				~ Bulk collect the values for date attributes
 *  				  and use them in same insert statement as
 *  				  'By Rank' attributes
 *  				~ populate the exception table for
 *  				  'By Date' attributes.
 */

PROCEDURE Gen_BulkCreateSST (
    p_entity_name                   IN     VARCHAR2,
    p_purpose                       IN     VARCHAR2
) IS

    CURSOR c_restricted_attributes IS
      SELECT e.attribute_name, e.entity_attr_id,
             e.group_flag, s.content_source_type
      FROM
        (SELECT e.attribute_name, e.entity_attr_id, 'N' group_flag
         FROM hz_entity_attributes e
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         UNION
         SELECT e.attribute_group_name,
                MIN(entity_attr_id) entity_attr_id,
                'Y' group_flag
         FROM hz_entity_attributes e
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND NOT EXISTS (
           SELECT 'Y'
           FROM hz_entity_attributes e1
           WHERE e.attribute_group_name = e1.attribute_name)
         GROUP BY e.attribute_group_name) e,
        hz_select_data_sources s
      WHERE EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 )
      AND s.entity_attr_id = e.entity_attr_id
      AND s.ranking > 0
      ORDER BY e.attribute_name, s.ranking;

    i_attribute_name                INDEXVARCHAR30List;
    i_uq_attribute_name             INDEXVARCHAR30List;
    i_entity_attr_id                INDEXIDList;
    i_uq_entity_attr_id             INDEXIDList;
    i_group_flag                    INDEXVARCHAR1List;
    i_uq_group_flag                 INDEXVARCHAR1List;
    i_content_source_type           INDEXVARCHAR30List;
    i_uq_data_type                  INDEXVARCHAR30List;
    i_uq_winner_source              INDEXVARCHAR30List;
    i_normal_attributes             INDEXVARCHAR30List;

    CURSOR c_sources IS
      SELECT UNIQUE s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.entity_attr_id = s.entity_attr_id
      AND s.ranking > 0;

    i_sources                       INDEXVARCHAR30List;

    CURSOR c_groups IS
      SELECT e.attribute_group_name, e.attribute_name
      FROM hz_entity_attributes e,
        (SELECT UNIQUE attribute_group_name
         FROM hz_entity_attributes
         WHERE entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         GROUP BY attribute_group_name
         HAVING COUNT(*) > 1) e1
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.attribute_group_name = e1.attribute_group_name
      AND e.attribute_group_name <> e.attribute_name
      AND EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 );

    i_group_name                    INDEXVARCHAR30List;
    i_uq_group_attributes           INDEXVARCHAR30List;

    l_all_attribute_names           INDEXVARCHAR30List;
    l_data_type                     INDEXVARCHAR30List;
    l_data_length                   NUMBERList;
    l_de_column_names               INDEXVARCHAR30List;

    l_procedure_name                VARCHAR2(30);
    l_cursor_name                   VARCHAR2(30);
-- Bug 4171892
    l_prefix                        VARCHAR2(1000);
    str1                            VARCHAR2(1000);
    str2                            VARCHAR2(1000);
    str3                            VARCHAR2(1000);
    l_start                         NUMBER;
    l_end                           NUMBER;
    l_index                         NUMBER;
    l_index1                        NUMBER;
    m                               NUMBER := 0;
    k                               NUMBER := 0;
    l_has_party_name                BOOLEAN := FALSE;
    l_has_dated_party_name          BOOLEAN := FALSE;


-- SSM SST Project :
-- Cursor to pick attributes setup for 'By Date' method
-- local variables for generating dynamic package
-- Bug 6472658 : ORDER BY Clause added.
 CURSOR c_date_attributes IS
         SELECT distinct e.attribute_name, e.entity_attr_id
         FROM hz_entity_attributes e,
         hz_select_data_sources s
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND EXISTS (
         SELECT 'Y'
         FROM hz_select_data_sources s1
         WHERE s1.entity_attr_id = e.entity_attr_id
         AND s1.ranking < 0 )
         AND s.entity_attr_id = e.entity_attr_id
         AND s.ranking < 0
         ORDER BY e.attribute_name;

    i_attribute_group_name_date         INDEXVARCHAR30List;
    i_primary_entity_attr_id_date       INDEXIDList;
    i_group_attribute_name_date         INDEXVARCHAR30List;
    i_group_entity_attr_id_date         INDEXIDList;
    i_attribute_name_date               INDEXVARCHAR30List;
    i_entity_attr_id_date               INDEXIDList;
    l_index_date                        NUMBER;
    i_data_type                         VARCHAR2(60);
    l_cursor_name_date                  VARCHAR2(30);

BEGIN

    IF p_entity_name = 'organization' THEN
      l_procedure_name := p_purpose || 'CreateOrgSST';
      l_all_attribute_names := G_O_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_O_DATA_TYPE;
      l_data_length := G_O_DATA_LENGTH;
      l_de_column_names := G_O_DE_COLUMN_NAMES;
    ELSE
      l_procedure_name := p_purpose || 'CreatePersonSST';
      l_all_attribute_names := G_P_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_P_DATA_TYPE;
      l_data_length := G_P_DATA_LENGTH;
      l_de_column_names := G_P_DE_COLUMN_NAMES;
    END IF;

    /*===============================================================
     + start to build the procedure
     +===============================================================*/

    If UPPER(p_purpose) = 'BULK' THEN
      Gen_ProcedureUtilForBulk('Header',l_procedure_name);
    ELSE
      Gen_ProcedureUtilForBulk('ImportHeader',l_procedure_name);
    END IF;

    /*===============================================================
     + declare local variables
     +
     +   TYPE t_branch_flag IS TABLE OF VARCHAR2(50);
     +   i_branch_flag                  t_branch_flag;
     +   TYPE t_ceo_name IS TABLE OF VARCHAR2(70);
     +   i_ceo_name                     t_ceo_name;
     +   ...
     +===============================================================*/

    -- bulk load attributes' setup.

    OPEN c_restricted_attributes;
    FETCH c_restricted_attributes BULK COLLECT INTO
      i_attribute_name, i_entity_attr_id,
      i_group_flag, i_content_source_type;
    CLOSE c_restricted_attributes;
-- SSM SST Project : fetch the 'By Date' attributes
    OPEN c_date_attributes;
    FETCH c_date_attributes BULK COLLECT INTO
        i_attribute_name_date, i_entity_attr_id_date;
    CLOSE c_date_attributes;
-- SSM SST Project : If no attribute is setup, package is not required
    IF (i_attribute_name.COUNT = 0 AND i_attribute_name_date.COUNT = 0) THEN
      Gen_ProcedureUtilForBulk('NullBody', l_procedure_name);
      RETURN;
    END IF;

    -- declare local variables
-- SSM SST Project : pass i_attribute_name_date as extra parameter
    Declare_Attributes(p_entity_name, i_attribute_name, i_attribute_name_date, i_normal_attributes);

    li(fp('i_profile_id')||'INDEXIDlist;');
    li(fp('i_sst_profile_id')||'INDEXIDlist;');
    li(fp('i_entity_attr_id')||'INDEXIDlist;');
    li(fp('i_party_id')||'INDEXIDlist;');
    li(fp('subtotal')||'NUMBER := 0;');
    li(fp('total')||'NUMBER := 0;');

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCursor('DECLARE');
    ELSE
      Gen_CodeForCursor('DECLARE',null, null, 'IMPORT');
    END IF;

    /*===============================================================
     + select for restricted columns (i.e. columns have been selected)
     +
     +   SELECT ...
     +          --
     +          -- processing branch_flag.
     +          DECODE(dnb.branch_flag, NULL,
     +            DECODE(user_entered.branch_flag, NULL,
     +            NULL,
     +            user_entered.branch_flag||'%#USER_ENTERED'),
     +          dnb.branch_flag||'%#DNB') branch_flag,
     +          --
     +          -- processing ceo_name.
     +          DECODE(user_entered.ceo_name, NULL,
     +            DECODE(dnb.ceo_name, NULL,
     +            NULL,
     +            dnb.ceo_name||'%#DNB'),
     +          user_entered.ceo_name||'%#USER_ENTERED') ceo_name,
     +          --
     +          ...
     +===============================================================*/

    l_cursor_name := 'c_entity';
    l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));

    li('CURSOR '||l_cursor_name||' IS');
    li('  SELECT d_user_entered.'||p_entity_name||'_profile_id,');
    ll(l_prefix||'d_user_entered.party_id');

    k := 0;
    FOR i IN 1..i_attribute_name.COUNT+1 LOOP
      IF i = 1 OR
         i = i_attribute_name.COUNT+1 OR
         i_attribute_name(i-1) <> i_attribute_name(i)
      THEN
        IF i > 1 THEN
          l(l_prefix||'NULL,');

          FOR j IN REVERSE l_start..l_end LOOP
            IF l_data_type(l_index) IN ('NUMBER','DATE') THEN
              str1 := g_to_char;  str2 := '';  str3 := ')';
              IF l_data_type(l_index) = 'DATE' THEN
                str2 := ',''YYYY/MM/DD HH:MI:SS''';
              END IF;
            ELSE
              str1 := ''; str2 := '';  str3 := '';
            END IF;

            ll(l_prefix||str1||'d_'||LOWER(i_content_source_type(j))||'.'||
               LOWER(i_attribute_name(i-1))||str2||str3||'||'''||
               g_sep||i_content_source_type(j)||''')');

            IF j = l_start THEN
              ll(' '||LOWER(i_attribute_name(i-1)));
            ELSE
              l(',');
            END IF;
            l_prefix := SUBSTRB(l_prefix, 1, LENGTHB(l_prefix)-2);
          END LOOP;
        END IF;  -- IF i > 1 THEN

        IF i = i_attribute_name.COUNT+1 THEN
          EXIT;
        END IF;

        -- start processing a new attribute group.

        l_start := i; l_end := i; l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
        IF i_group_flag(i) = 'N' THEN
          l_index := Get_Index(l_all_attribute_names, i_attribute_name(i));
        END IF;
        k := k + 1;

        IF i_attribute_name(i) IN ('ORGANIZATION_NAME','PERSON_NAME') THEN
          l_has_party_name := true;
        END IF;

        i_uq_attribute_name(k) := i_attribute_name(i);
        i_uq_entity_attr_id(k) := i_entity_attr_id(i);
        i_uq_group_flag(k) := i_group_flag(i);
        IF i_group_flag(i) = 'N' THEN
          i_uq_data_type(k) := l_data_type(l_index);
        ELSE
          i_uq_data_type(k) := 'VARCHAR2';
        END IF;
        i_uq_winner_source(k) := i_content_source_type(i);

        l(',');
        l(l_prefix||'--');
        l(l_prefix||'-- processing '||LOWER(i_attribute_name(i))||'.');

      ELSE
        l_prefix := l_prefix||'  '; l_end := l_end+1;
      END IF;

      l(l_prefix||'DECODE(d_'||LOWER(i_content_source_type(i))||
        '.'||LOWER(i_attribute_name(i))||', NULL, ');
    END LOOP;

    /*===============================================================
     + select normal columns (i.e. columns not in setup tables and
     + columns not selected)
     +
     +          --
     +          -- processing attribute1.
     +          user_entered.attribute1,
     +          --
     +          -- processing attribute2.
     +          user_entered.attribute2,
     +          ...
     +===============================================================*/

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
      l(l_prefix||'--');
      l(l_prefix||'-- processing '||LOWER(i_normal_attributes(i))||'.');
      ll(l_prefix||'d_user_entered.'||LOWER(i_normal_attributes(i)));
    END LOOP;

    IF p_entity_name = 'organization' THEN
      -- select duns number
      l(',');
      l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
      l(l_prefix||'--');
      l(l_prefix||'-- processing duns_number.');
      ll(l_prefix||'d_user_entered.duns_number');
    END IF;

    /*===============================================================
     + from list
     +
     +   FROM hz_organization_profiles dnb,
     +        hz_organization_profiles user_entered
     +        ...
     +===============================================================*/

    -- fetch all of content source types from setup table.

    OPEN c_sources;
    FETCH c_sources BULK COLLECT INTO i_sources;
    CLOSE c_sources;

    l('');
    li('  FROM');
    IF i_sources.COUNT = 0 THEN
      ll(RPAD(l_prefix,7+LENGTHB(g_indent))||
         'hz_'||p_entity_name||'_profiles d_user_entered');
    ELSE
    FOR i IN 1..i_sources.COUNT LOOP
      IF i > 1 THEN
        l(',');
      END IF;

      ll(RPAD(l_prefix,7+LENGTHB(g_indent))||
         'hz_'||p_entity_name||'_profiles d_'||LOWER(i_sources(i)));
    END LOOP;
    END IF;

    IF ( UPPER(p_purpose) = 'IMPORT') THEN
      l(',');
      li('       hz_imp_parties_sg sg,');
      li('       hz_imp_parties_int i');
    END IF;

    l('');

    /*===============================================================
     + static where clause
     +===============================================================*/

    li('  --');
    li('  -- use party profiles as driving table because in normal');
    li('  -- case the number of organization/person in hz_parties');
    li('  -- might be much smaller than the number of parties.');
    li('  --');

    IF ( UPPER(p_purpose) = 'BULK') THEN
       getBulkCreateWhereCondition;
     ELSE
       getImportCreateWhereCondition;
    END IF;

/*
    li('  WHERE user_entered.'||'party_id BETWEEN p_from_party_id AND p_to_party_id');
    li('  AND user_entered.actual_content_source = ''SST''');
    li('  AND user_entered.effective_end_date IS NULL');
*/
    li('  -- no sst profile exists for this party.');
    li('  --');
    li('  AND NOT EXISTS (');
    li('    SELECT ''Y''');
    li('    FROM hz_'||p_entity_name||'_profiles entity');
    li('    WHERE entity.party_id = d_user_entered.party_id');
    li('    AND entity.actual_content_source = ''USER_ENTERED''');
    li('    AND entity.effective_end_date IS NULL )');
    li('  --');
    li('  -- at least one third party profile exists for this party.');
    li('  --');
    li('  AND EXISTS (');
    li('    SELECT ''Y''');
    li('    FROM hz_'||p_entity_name||'_profiles entity');
    li('    WHERE entity.party_id = d_user_entered.party_id');
    li('    AND entity.actual_content_source NOT IN (''USER_ENTERED'',''SST'')');
    li('    AND entity.effective_end_date IS NULL )');
    li('  --');
    li('  -- we use outer join for each third party data source');
    li('  -- in case the party does not have the specific third');
    li('  -- party profile.');
    li('  --');

    /*===============================================================
     + dynamic where clause
     +
     +   AND dnb.party_id (+) = user_entered.party_id
     +   AND dnb.actual_content_source (+) = 'DNB'
     +   AND dnb.effective_end_date IS NULL
     +   ...
     +===============================================================*/

    k := 0;
    FOR i IN 1..i_sources.COUNT LOOP
      IF i_sources(i) <> 'USER_ENTERED' THEN
        k := 1;
        IF k <> 1 THEN
          l('');
        END IF;
        li('  AND d_'||LOWER(i_sources(i))||'.party_id (+) = d_user_entered.party_id');
        li('  AND d_'||LOWER(i_sources(i))||'.actual_content_source (+) = '''||i_sources(i)||'''');
        lli('  AND d_'||LOWER(i_sources(i))||'.effective_end_date IS NULL');
      END IF;
    END LOOP;
    l(';');
    l('');

-- SSM SST Project :
/*===================================
+ Create Cursors for Date ranked attriubtes
+=====================================*/
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
	date_cursor_create(i_entity_attr_id_date(i),
	i_attribute_name_date(i),
	p_entity_name,
	p_purpose);

        IF i_attribute_name_date(i) in ('PERSON_NAME','ORGANIZATION_NAME')
        THEN
         l_has_dated_party_name := true;
        END IF;


    END LOOP;
    l('');


    /*===============================================================
     + package body
     +===============================================================*/

    l('BEGIN');
    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_ProcedureUtilForBulk('Log',l_procedure_name);
    ELSE
      Gen_ProcedureUtilForBulk('ImportLog',l_procedure_name);
    END IF;

    l('');
    IF UPPER(p_purpose) = 'BULK' THEN
      li('reset_who;');
    ELSE
      li('reset_who(p_request_id, p_program_id, p_program_application_id);');
    END IF;
    l('');
    li('hz_common_pub.disable_cont_source_security;');
    l('');
    li('write_log(''open cursor '||l_cursor_name||''');');
    l('');

    /*===============================================================
     + open cursor
     +===============================================================*/

-- SSM SST Project : Open cursors for 'By Date' attributes
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('OPEN '||i_attribute_name_date(i)||'_;');
    END LOOP;

    IF ( UPPER(p_purpose) = 'BULK') THEN
      Gen_CodeForCursor('OPEN', l_cursor_name, 'Y');
    ELSE
      Gen_CodeForCursor('OPEN', l_cursor_name, 'Y', 'IMPORT');
    END IF;

    li('    i_profile_id,');
    lli('    i_party_id');

    /*===============================================================
     + a list of pl/sql tables into which the cursor bulk collect
     +
     +   i_branch_flag,
     +   i_ceo_name,
     +   ...
     +===============================================================*/

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');
      lli('    i_'||Format_AttributeName(i_uq_attribute_name(i)));
    END LOOP;

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      lli('    i_'||Format_AttributeName(i_normal_attributes(i)));
    END LOOP;

    -- process duns number
    IF p_entity_name = 'organization' THEN
      l(',');
      lli('    i_duns_number');
    END IF;

    l(' LIMIT rows;');

    Gen_CodeForCursor('FETCH', l_cursor_name);

-- SSM SST Project : Fetch and BULK COLLECT for 'By Date' attributes
     FOR i IN 1..i_attribute_name_date.COUNT LOOP
	     lli('  FETCH '||i_attribute_name_date(i)||'_ ');
	     l('BULK COLLECT INTO');
	     lli('    i_'||Format_AttributeName(i_attribute_name_date(i)));
	     l(',');
	     lli('    '||Format_AttributeName(i_attribute_name_date(i)));
	     l(' LIMIT rows;');
	     l('');
     END LOOP;
    l('');


    li('  subtotal := i_party_id.COUNT;');
    li('  IF subtotal = 0 AND l_last_fetch THEN');
    li('    EXIT;');
    li('  END IF;');
    li('  total := total + i_party_id.COUNT;');
    l('');
    li('  write_log(''fetched ''||subtotal||'' records.'');');
    l('');

    /*===============================================================
     + reset actual_content_source for user-entered Profiles
     +===============================================================*/

    li('  write_log(''reset actual_content_source for user-entered profiles.'');');
    l('');
    li('  -- reset actual_content_source for user-entered profiles.');
    l('');
    li('  FORALL i IN 1..subtotal');
    li('    UPDATE hz_'||p_entity_name||'_profiles ');
    li('    SET actual_content_source = ''USER_ENTERED''');
    li('    WHERE '||p_entity_name||'_profile_id = i_profile_id(i);');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCommit;
    END IF;
    /*===============================================================
     + select attributes inside an attribute group
     +===============================================================*/

    OPEN c_groups;
    FETCH c_groups BULK COLLECT INTO
      i_group_name, i_uq_group_attributes;
    CLOSE c_groups;

    k := 0;
    FOR i IN 1..i_group_name.COUNT+1 LOOP
      IF i = 1 OR
         i = i_group_name.COUNT+1 OR
         i_group_name(i-1) <> i_group_name(i)
      THEN
        IF i > 1 THEN
          IF i_group_name(i-1) = 'DUNS_NUMBER_C' THEN
            l(',');
            lli('        duns_number');
          END IF;

          l('');
          li('      INTO ');

          FOR j IN l_start..l_end LOOP
            IF j <> l_start THEN
              l(',');
            END IF;
            lli('        i_'||Format_AttributeName(i_uq_group_attributes(j))||'(i)');
          END LOOP;

          IF i_group_name(i-1) = 'DUNS_NUMBER_C' THEN
            l(',');
            lli('        i_duns_number(i)');
          END IF;

          str1 := Format_AttributeName(i_group_name(i-1));
          l('');
          li('      FROM hz_'||p_entity_name||'_profiles');
          li('      WHERE party_id = i_party_id(i)');
          li('      AND effective_end_date IS NULL');
          li('      AND actual_content_source = '||
             'SUBSTRB(i_'||str1||'(i)'||
             ',INSTRB(i_'||str1||'(i)'||', '''||g_sep||''')+2);');

          IF i_group_name(i-1) = 'DUNS_NUMBER_C' THEN
            li('    ELSE');
            li('      i_duns_number(i) := NULL;');
          END IF;
          li('    END IF;');
          li('  END LOOP;');
          l('');

        END IF;  -- IF i > 1 THEN

        IF i = i_group_name.COUNT+1 THEN
          EXIT;
        END IF;

        -- start processing a new attribute group.

        l_start := i; l_end := i;
        li('  write_log(''processing group '||LOWER(i_group_name(i))||''');');
        l('');
        li('  -- process group '||LOWER(i_group_name(i)));
        li('  --');
        li('  FOR i IN 1..subtotal LOOP');
        li('    IF i_'||Format_AttributeName(i_group_name(i))||'(i) IS NOT NULL THEN');
        li('      SELECT');
      ELSE
        l(','); l_end := l_end+1;
      END IF;

      lli('        DECODE('||LOWER(i_uq_group_attributes(i))||',NULL,DECODE(i_'||
          LOWER(i_uq_group_attributes(i))||'(i),NULL,NULL,'''||g_sep||'''||actual_content_source),'||
          LOWER(i_uq_group_attributes(i))||'||'''||g_sep||'''||actual_content_source)');

    END LOOP;

    /*===============================================================
     + create sst profiles
     +===============================================================*/

    li('  write_log(''create sst profiles.'');');
    l('');
    li('  -- insert sst profiles');
    l('');
    li('  FORALL i IN 1..subtotal');
    li('    INSERT INTO hz_'||p_entity_name||'_profiles (');

    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','Y');
    l(',');
    Gen_CodeForOtherAttributes ('LIST',g_indent||'      ');
    l(',');
    li('      '||p_entity_name||'_profile_id,');
    li('      party_id,');
    li('      effective_start_date,');
    lli('      object_version_number');

    /*===============================================================
     + column list of insert statement
     +
     +   duns_number_c,
     +   employees_total,
     +   ...
     +===============================================================*/

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_uq_attribute_name(i)));
    END LOOP;

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_normal_attributes(i)));
    END LOOP;

-- SSM SST Project : Add date attributes in insert statement
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_attribute_name_date(i)));
    END LOOP;

    IF p_entity_name = 'organization' THEN
      l(',');
      lli('      duns_number');
    END IF;

    l('');
    li('    ) VALUES (');

    /*===============================================================
     + value list of insert statement
     +
     +   SUBSTRB(i_duns_number_c(i),1,INSTRB(i_duns_number_c(i),'%#')-1),
     +   TO_NUMBER(SUBSTRB(i_employees_total(i),1, INSTRB(i_employees_total(i),'%#')-1)),
     +   ...
     +===============================================================*/

    Gen_CodeForWhoColumns('I','',g_indent||'      ','Y');
    l(',');
    Gen_CodeForOtherAttributes ('',g_indent||'      ');
    l(',');

    li('      hz_'||p_entity_name||'_profiles_s.nextval,');
    li('      i_party_id(i),');
    li('      SYSDATE,');
    lli('      1');

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');

      str1 := Format_AttributeName(i_uq_attribute_name(i));

      IF i_uq_data_type(i) = 'VARCHAR2' THEN
        str2 := '';  str3 := '';
      ELSIF i_uq_data_type(i) = 'NUMBER' THEN
        str2 := g_to_number; str3 := ')';
      ELSIF i_uq_data_type(i) = 'DATE' THEN
        str2 := g_to_date; str3 := ',''YYYY/MM/DD HH:MI:SS'')';
      END IF;

      lli('      '||str2||'SUBSTRB(i_'||str1||'(i),1,'||
         'INSTRB(i_'||str1||'(i),'''||g_sep||''')-1)'||str3);
    END LOOP;

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      lli('      i_'||Format_AttributeName(i_normal_attributes(i))||'(i)');
    END LOOP;

-- SSM SST Project : Values clause for 'By Date' attributes
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
      l(',');
      lli('      i_'||Format_AttributeName(i_attribute_name_date(i))||'(i)');
    END LOOP;


    IF p_entity_name = 'organization' THEN
      -- process duns number
      l(',');
      li('      i_duns_number(i)');
    END IF;

    l('');
    li('    ) RETURNING '||p_entity_name||'_profile_id BULK COLLECT INTO i_sst_profile_id;');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCommit;
    END IF;

    /*===============================================================
     + denormalize sst to hz_parties (restricted columns only)
     +
     +   duns_number_c =
     +     SUBSTRB(i_duns_number_c(i),1,INSTRB(i_duns_number_c(i),'%#')-1),
     +   employees_total =
     +     TO_NUMBER(SUBSTRB(i_employees_total(i),1, INSTRB(i_employees_total(i),'%#')-1)),
     +   ...
     +===============================================================*/

    li('  write_log(''update denormalized columns in hz_parties.'');');
    l('');

    li('  -- update denormalized columns in hz_parties.');
    l('');
    li('  FORALL i IN 1..subtotal');
    li('    UPDATE hz_parties');
    li('    SET');

    Gen_CodeForWhoColumns('U','',g_indent||'      ','Y');

    FOR i IN 1..l_all_attribute_names.COUNT LOOP
      IF l_de_column_names(i) IS NOT NULL THEN
        l_index := Get_Index(i_uq_attribute_name, l_all_attribute_names(i));
        l_index_date := Get_Index(i_attribute_name_date, l_all_attribute_names(i));

        IF l_index > 0 THEN
          l(',');
          lli('      '||LOWER(l_all_attribute_names(i))||' = ');

          str1 := Format_AttributeName(l_all_attribute_names(i));

          IF i_uq_data_type(l_index) = 'VARCHAR2' THEN
            str2 := '';  str3 := '';
          ELSIF i_uq_data_type(l_index) = 'NUMBER' THEN
            str2 := g_to_number; str3 := ')';
          ELSIF i_uq_data_type(l_index) = 'DATE' THEN
            str2 := g_to_date; str3 := ',''YYYY/MM/DD HH:MI:SS'')';
          END IF;

          ll(str2||'SUBSTRB(i_'||str1||'(i),1,'||
             'INSTRB(i_'||str1||'(i),'''||g_sep||''')-1)'||str3);
        END IF;
-- SSM SST Project : Denormalize 'By Date' columns
	IF l_index_date > 0 THEN
	  l(',');
          lli('      '||LOWER(l_all_attribute_names(i))||' = ');
          ll('i_'||Format_AttributeName(l_all_attribute_names(i))||'(i)');
        END IF;
      END IF;
    END LOOP;

    /*===============================================================
     + denormalize duns_number into hz_parties
     +===============================================================*/

    IF p_entity_name = 'organization' THEN
      l(',');
      lli('      duns_number = i_duns_number (i)');
    END IF;

    /*===============================================================
     + update party_name, customer_key in hz_parties
     +===============================================================*/

    IF l_has_party_name THEN
      Gen_PartyName (p_entity_name);
    END IF;

     IF l_has_dated_party_name THEN
      IF p_entity_name = 'organization' THEN
      l(',');
      lli('      party_name = i_organization_name(i)');
      ELSIF p_entity_name = 'person' THEN
      l(',');
      lli('      party_name = i_person_name(i)');
      END IF;
    END IF;

    li('    WHERE party_id = i_party_id(i);');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCommit;
    END IF;

    /*===============================================================
     + update party_name of relationship parties
     +===============================================================*/

    IF l_has_party_name THEN
      Gen_RelationshipPartyName;
      IF UPPER(p_purpose) = 'BULK' THEN
        Gen_CodeForCommit(false);
      END IF;
    END IF;

    /*===============================================================
     + update exception table to track attributes'  data source
     +===============================================================*/

    li('  write_log(''update exception table.'');');
    l('');

    FOR i IN 1..i_uq_entity_attr_id.COUNT LOOP
      IF i_uq_group_flag(i) = 'N' THEN
        li('  update_exception_table(''C'','||
           'i_party_id,'''||i_uq_attribute_name(i)||''','||
           i_uq_entity_attr_id(i)||','||
           'i_'||Format_AttributeName(i_uq_attribute_name(i))||','''||
           i_uq_winner_source(i)||''');');
        l('');
      END IF;
    END LOOP;

-- SSM SST Project : Update exceptions table for 'By Date' attributes
--		     Also, delete the entries from user overwrite rules
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('  update_exception_table_date(''C'','||
           'i_party_id,'''||i_attribute_name_date(i)||''','||
           i_entity_attr_id_date(i)||','||
 Format_AttributeName(i_attribute_name_date(i))||');');
--           'i_actual_content_source);');
        l('');
    END LOOP;

-- SSM SST Project : Delete the entries from user overwrite rules
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
	li(' delete hz_user_overwrite_rules where entity_attr_id = ' || i_entity_attr_id_date(i) || ' ;');
        l('');
    END LOOP;

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCommit(false);
    END IF;

    /*===============================================================
     + write output file
     +===============================================================*/

    Gen_WriteOutputFileForCreate;

    /*===============================================================
     + update DQM interface table
     +
     + As per talk with Srini, right now DQM can not handle huge
     + data in interface table. User should run DQM sync program
     + after they run this program for mix-n-match.
     +===============================================================*/
    /*
    IF hz_dqm_search_util.is_dqm_available = 'T' THEN
      Gen_CodeForDQM(p_entity_name);
    END IF;
    */

    /*===============================================================
     + close cursor
     +===============================================================*/


    IF ( UPPER(p_purpose) = 'BULK') THEN
      Gen_CodeForCursor('CLOSE', l_cursor_name);
    ELSE
      Gen_CodeForCursor('CLOSE', l_cursor_name, null, 'IMPORT');
    END IF;
-- SSM SST Project : Close 'By Date' cursors
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('CLOSE '||i_attribute_name_date(i)||'_;');
    END LOOP;

    l('');
    li('write_out(total||'' sst profile(s) was(were) created.'');');
    l('');
    li('write_log(total||'' sst profile(s) was(were) successfully created.'');');
    l('END '||l_procedure_name||';');
    l('');

END Gen_BulkCreateSST;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *  p_entity_name                   IN     VARCHAR2,
 *  p_purpose                       IN     VARCHAR2
 *
 * MODIFICATION HISTORY
 *
 *  p_purpose is added for import data load
 *  p_purpose = 'Bulk'  will generate MixNMatch Load procedure
 *  p_purpose = 'Import' will generate Import Load procedure
 *
 *  07-12-2004	Dhaval Mehta	SSM SST Project
 *  				~ Added code to generate cursors
 *  				  for 'By Date' attributes.
 *  				~ Bulk collect the values for date attributes
 *  				  and use them in same insert statement as
 *				  'By Rank' attributes
 *  				~ populate the exception table for
 *  				  'By Date' attributes.
 */

PROCEDURE Gen_BulkUpdateSST (
    p_entity_name                   IN     VARCHAR2,
    p_purpose                       IN     VARCHAR2
) IS

    CURSOR c_restricted_attributes IS
      SELECT e.attribute_name, e.entity_attr_id,
             e.group_flag, s.content_source_type
      FROM
        (SELECT e.attribute_name, e.entity_attr_id, 'N' group_flag
         FROM hz_entity_attributes e
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND e.updated_flag = 'Y'
         UNION
         SELECT e.attribute_group_name,
                MIN(entity_attr_id) entity_attr_id,
                'Y' group_flag
         FROM hz_entity_attributes e
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND e.updated_flag = 'Y'
         AND NOT EXISTS (
           SELECT 'Y'
           FROM hz_entity_attributes e1
           WHERE e.attribute_group_name = e1.attribute_name)
         GROUP BY e.attribute_group_name) e,
        hz_select_data_sources s
      WHERE /*EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 )
      AND */ s.entity_attr_id = e.entity_attr_id
      AND s.ranking > 0
      ORDER BY e.attribute_name, s.ranking;

    CURSOR c_imp_restricted_attributes IS
      SELECT e.attribute_name, e.entity_attr_id,
             e.group_flag, s.content_source_type
      FROM
        (SELECT e.attribute_name, e.entity_attr_id, 'N' group_flag
         FROM hz_entity_attributes e
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         UNION
         SELECT e.attribute_group_name,
                MIN(entity_attr_id) entity_attr_id,
                'Y' group_flag
         FROM hz_entity_attributes e
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND NOT EXISTS (
           SELECT 'Y'
           FROM hz_entity_attributes e1
           WHERE e.attribute_group_name = e1.attribute_name)
         GROUP BY e.attribute_group_name) e,
        hz_select_data_sources s
      WHERE /*EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 )
      AND*/ s.entity_attr_id = e.entity_attr_id
      AND s.ranking > 0
      ORDER BY e.attribute_name, s.ranking;

    i_attribute_name                INDEXVARCHAR30List;
    i_uq_attribute_name             INDEXVARCHAR30List;
    i_entity_attr_id                INDEXIDList;
    i_uq_entity_attr_id             INDEXIDList;
    i_group_flag                    INDEXVARCHAR1List;
    i_uq_group_flag                 INDEXVARCHAR1List;
    i_content_source_type           INDEXVARCHAR30List;
    i_uq_data_type                  INDEXVARCHAR30List;
    i_uq_winner_source              INDEXVARCHAR30List;
    i_normal_attributes             INDEXVARCHAR30List;

    CURSOR c_sources IS
      SELECT UNIQUE s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.updated_flag = 'Y'
      AND e.entity_attr_id = s.entity_attr_id
      AND s.ranking > 0;

    -- this cursor will return all the attribute which as data source
    -- from third party. It's used by the update cursor for import
    -- mixnmatch update is one-time update, it only needs consider
    -- the changed attribute, but for import, we need to consider for
    -- multiple time run. We nee all the attriute which has third party
    -- data source
    CURSOR c_imp_sources IS
      SELECT UNIQUE s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.entity_attr_id = s.entity_attr_id
      AND s.ranking > 0;

    i_sources                       INDEXVARCHAR30List;

    CURSOR c_deselected_sources IS
      SELECT s.entity_attr_id, s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.updated_flag = 'Y'
      AND e.entity_attr_id = s.entity_attr_id
      AND s.ranking = 0
      ORDER BY s.entity_attr_id;

    i_deentity_attr_id              INDEXIDList;
    i_deselected_sources            INDEXVARCHAR30List;

    CURSOR c_groups IS
      SELECT e.attribute_group_name, e.attribute_name
      FROM hz_entity_attributes e,
        (SELECT UNIQUE attribute_group_name
         FROM hz_entity_attributes
         WHERE entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         GROUP BY attribute_group_name
         HAVING COUNT(*) > 1) e1
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.attribute_group_name = e1.attribute_group_name
      AND e.attribute_group_name <> e.attribute_name
      AND e.updated_flag = 'Y'
      AND EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
--        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 )
        ;

    -- return the groups which has third party data source
    -- used by import
    CURSOR c_imp_groups IS
      SELECT e.attribute_group_name, e.attribute_name
      FROM hz_entity_attributes e,
        (SELECT UNIQUE attribute_group_name
         FROM hz_entity_attributes
         WHERE entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         GROUP BY attribute_group_name
         HAVING COUNT(*) > 1) e1
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.attribute_group_name = e1.attribute_group_name
      AND e.attribute_group_name <> e.attribute_name
      AND EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
--        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 );


    i_group_name                    INDEXVARCHAR30List;
    i_uq_group_attributes           INDEXVARCHAR30List;

    l_all_attribute_names           INDEXVARCHAR30List;
    l_data_type                     INDEXVARCHAR30List;
    l_data_length                   NUMBERList;
    l_de_column_names               INDEXVARCHAR30List;

    l_procedure_name                VARCHAR2(30);
    l_cursor_name                   VARCHAR2(30);
-- Bug 4171892
    l_prefix                        VARCHAR2(1000);
    str1                            VARCHAR2(1000);
    str2                            VARCHAR2(1000);
    str3                            VARCHAR2(1000);
    l_start                         NUMBER;
    l_end                           NUMBER;
    l_index                         NUMBER;
    l_index1                        NUMBER;
    m                               NUMBER := 0;
    k                               NUMBER := 0;
    l_has_party_name                BOOLEAN := FALSE;
    l_has_dated_party_name          BOOLEAN := FALSE;


-- SSM SST Project :
-- Cursor to pick attributes setup for 'By Date' method for BULK update
-- local variables for generating dynamic package
-- Bug 6472658 : ORDER BY Clause added.
 CURSOR c_date_attributes IS
         SELECT distinct e.attribute_name, e.entity_attr_id
         FROM hz_entity_attributes e,
         hz_select_data_sources s
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND EXISTS (
         SELECT 'Y'
         FROM hz_select_data_sources s1
         WHERE s1.entity_attr_id = e.entity_attr_id
         AND s1.ranking < 0 )
         AND s.entity_attr_id = e.entity_attr_id
         AND e.updated_flag = 'Y'
         AND s.ranking < 0
         ORDER BY e.attribute_name;

    i_attribute_group_name_date         INDEXVARCHAR30List;
    i_primary_entity_attr_id_date       INDEXIDList;
    i_group_attribute_name_date         INDEXVARCHAR30List;
    i_group_entity_attr_id_date         INDEXIDList;
    i_attribute_name_date               INDEXVARCHAR30List;
    i_entity_attr_id_date               INDEXIDList;
    l_index_date                        NUMBER;
    i_data_type                         VARCHAR2(60);
    l_cursor_name_date                  VARCHAR2(30);

-- SSM SST Project :
-- Cursor to pick attributes setup for 'By Date' method for Import Load
-- Bug 6472658 : ORDER BY Clause added.
 CURSOR c_date_attributes_imp IS
         SELECT distinct e.attribute_name, e.entity_attr_id
         FROM hz_entity_attributes e,
         hz_select_data_sources s
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND EXISTS (
         SELECT 'Y'
         FROM hz_select_data_sources s1
         WHERE s1.entity_attr_id = e.entity_attr_id
         AND s1.ranking < 0 )
         AND s.entity_attr_id = e.entity_attr_id
         AND s.ranking < 0
         ORDER BY e.attribute_name;


BEGIN

    IF p_entity_name = 'organization' THEN
      l_procedure_name := p_purpose || 'UpdateOrgSST';
      l_all_attribute_names := G_O_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_O_DATA_TYPE;
      l_data_length := G_O_DATA_LENGTH;
      l_de_column_names := G_O_DE_COLUMN_NAMES;
    ELSE
      l_procedure_name := p_purpose || 'UpdatePersonSST';
      l_all_attribute_names := G_P_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_P_DATA_TYPE;
      l_data_length := G_P_DATA_LENGTH;
      l_de_column_names := G_P_DE_COLUMN_NAMES;
    END IF;

    /*===============================================================
     + start to build the procedure
     +===============================================================*/

    If UPPER(p_purpose) = 'BULK' THEN
      Gen_ProcedureUtilForBulk('Header',l_procedure_name);
    ELSE
      Gen_ProcedureUtilForBulk('ImportHeader',l_procedure_name);
    END IF;


    /*===============================================================
     + declare local variables
     +
     +   TYPE t_branch_flag IS TABLE OF VARCHAR2(50);
     +   i_branch_flag                  t_branch_flag;
     +   TYPE t_ceo_name IS TABLE OF VARCHAR2(70);
     +   i_ceo_name                     t_ceo_name;
     +   ...
     +===============================================================*/

    -- bulk load attributes' setup.

    If UPPER(p_purpose) = 'BULK' THEN
      OPEN c_restricted_attributes;
      FETCH c_restricted_attributes BULK COLLECT INTO
        i_attribute_name, i_entity_attr_id,
        i_group_flag, i_content_source_type;
      CLOSE c_restricted_attributes;

-- SSM SST Project : fetch the 'By Date' attributes
      OPEN c_date_attributes;
      FETCH c_date_attributes BULK COLLECT INTO
        i_attribute_name_date, i_entity_attr_id_date;
      CLOSE c_date_attributes;

    ELSE
      OPEN c_imp_restricted_attributes;
      FETCH c_imp_restricted_attributes BULK COLLECT INTO
        i_attribute_name, i_entity_attr_id,
        i_group_flag, i_content_source_type;
      CLOSE c_imp_restricted_attributes;

-- SSM SST Project : fetch the 'By Date' attributes
      OPEN c_date_attributes_imp;
      FETCH c_date_attributes_imp BULK COLLECT INTO
        i_attribute_name_date, i_entity_attr_id_date;
      CLOSE c_date_attributes_imp;

    END IF;

-- SSM SST Project : If no attribute is setup, package is not required
    IF (i_attribute_name.COUNT = 0 AND i_attribute_name_date.COUNT = 0) THEN
      Gen_ProcedureUtilForBulk('NullBody', l_procedure_name);
      RETURN;
    END IF;

    -- declare local variables

-- SSM SST Project : pass i_attribute_name_date as extra parameter
    Declare_Attributes(p_entity_name, i_attribute_name, i_attribute_name_date, i_normal_attributes);

    li(fp('i_profile_id')||'INDEXIDlist;');
    li(fp('i_sst_profile_id')||'INDEXIDlist;');
    li(fp('i_create_update_flag')||'INDEXVARCHARlist;');
    li(fp('i_entity_attr_id')||'INDEXIDlist;');
    li(fp('i_party_id')||'INDEXIDlist;');
    li(fp('subtotal')||'NUMBER := 0;');
    li(fp('total')||'NUMBER := 0;');
    li(fp('create_start')||'NUMBER := 0;');
    li(fp('create_end')||'NUMBER := 0;');
    li(fp('update_start')||'NUMBER := 0;');
    li(fp('update_end')||'NUMBER := 0;');
    li(fp('j')||'NUMBER := 0;');
    li(fp('k')||'NUMBER := 0;');

    IF ( UPPER(p_purpose) = 'BULK') THEN
      Gen_CodeForCursor('DECLARE');
    ELSE
      Gen_CodeForCursor('DECLARE', null, null, 'IMPORT');
    END IF;
    /*===============================================================
     + select for restricted columns (i.e. columns have been selected)
     +
     +   SELECT ...
     +          --
     +          -- processing branch_flag.
     +          DECODE(dnb.branch_flag, NULL,
     +            DECODE(user_entered.branch_flag, NULL,
     +            NULL,
     +            user_entered.branch_flag||'%#USER_ENTERED'),
     +          dnb.branch_flag||'%#DNB') branch_flag,
     +          --
     +          -- processing ceo_name.
     +          DECODE(user_entered.ceo_name, NULL,
     +            DECODE(dnb.ceo_name, NULL,
     +            NULL,
     +            dnb.ceo_name||'%#DNB'),
     +          user_entered.ceo_name||'%#USER_ENTERED') ceo_name,
     +          --
     +          ...
     +===============================================================*/

    l_cursor_name := 'c_entity';
    l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));

   -- Bug 4239549.
    li('CURSOR '||l_cursor_name||' IS');
    li('  SELECT /*+ leading(i) use_nl(sg) index(sg,hz_imp_parties_sg_n1) */');
    li('decode(fnd_profile.value (''HZ_PROFILE_VERSION''),''NEW_VERSION'',''C'',''NO_VERSION'',''U'',decode(trunc(sst.effective_start_date),trunc(sysdate),''U'',''C'')) create_update_flag,');
    l(l_prefix||'sst.'||p_entity_name||'_profile_id,');
    ll(l_prefix||'sst.party_id');

    k := 0;
    FOR i IN 1..i_attribute_name.COUNT+1 LOOP
      IF i = 1 OR
         i = i_attribute_name.COUNT+1 OR
         i_attribute_name(i-1) <> i_attribute_name(i)
      THEN
        IF i > 1 THEN
          l(l_prefix||'NULL,');

          FOR j IN REVERSE l_start..l_end LOOP
            IF l_data_type(l_index) IN ('NUMBER','DATE') THEN
              str1 := g_to_char;  str2 := '';  str3 := ')';
              IF l_data_type(l_index) = 'DATE' THEN
                str2 := ',''YYYY/MM/DD HH:MI:SS''';
              END IF;
            ELSE
              str1 := ''; str2 := '';  str3 := '';
            END IF;

            ll(l_prefix||str1||'d_'||LOWER(i_content_source_type(j))||'.'||
               LOWER(i_attribute_name(i-1))||str2||str3||'||'''||
               g_sep||i_content_source_type(j)||''')');

            IF j = l_start THEN
              ll(' '||LOWER(i_attribute_name(i-1)));
            ELSE
              l(',');
            END IF;
            l_prefix := SUBSTRB(l_prefix, 1, LENGTHB(l_prefix)-2);
          END LOOP;
        END IF;  -- IF i > 1 THEN

        IF i = i_attribute_name.COUNT+1 THEN
          EXIT;
        END IF;

        -- start processing a new attribute group.

        l_start := i; l_end := i; l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
        IF i_group_flag(i) = 'N' THEN
          l_index := Get_Index(l_all_attribute_names, i_attribute_name(i));
        END IF;
        k := k + 1;

        IF i_attribute_name(i) IN ('ORGANIZATION_NAME','PERSON_NAME') THEN
          l_has_party_name := true;
        END IF;

        i_uq_attribute_name(k) := i_attribute_name(i);
        i_uq_entity_attr_id(k) := i_entity_attr_id(i);
        i_uq_group_flag(k) := i_group_flag(i);
        IF i_group_flag(i) = 'N' THEN
          i_uq_data_type(k) := l_data_type(l_index);
        ELSE
          i_uq_data_type(k) := 'VARCHAR2';
        END IF;
        i_uq_winner_source(k) := i_content_source_type(i);

        l(',');
        l(l_prefix||'--');
        l(l_prefix||'-- processing '||LOWER(i_attribute_name(i))||'.');
      ELSE
        l_prefix := l_prefix||'  '; l_end := l_end+1;
      END IF;

      l(l_prefix||'DECODE(d_'||LOWER(i_content_source_type(i))||
        '.'||LOWER(i_attribute_name(i))||', NULL, ');
    END LOOP;

    /*===============================================================
     + select normal columns (i.e. columns not in setup tables and
     + columns not selected)
     +
     +          --
     +          -- processing attribute1.
     +          sst.attribute1,
     +          --
     +          -- processing attribute2.
     +          sst.attribute2,
     +          ...
     +===============================================================*/

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
      l(l_prefix||'--');
      l(l_prefix||'-- processing '||LOWER(i_normal_attributes(i))||'.');
      ll(l_prefix||'sst.'||LOWER(i_normal_attributes(i)));
    END LOOP;

    IF p_entity_name = 'organization' THEN
      -- select duns number
      l(',');
      l_prefix := RPAD(g_indent,9+LENGTHB(g_indent));
      l(l_prefix||'--');
      l(l_prefix||'-- processing duns_number.');
      ll(l_prefix||'sst.duns_number');
    END IF;

    /*===============================================================
     + from list
     +
     +   FROM hz_organization_profiles dnb,
     +        hz_organization_profiles user_entered
     +        ...
     +===============================================================*/

    -- fetch all of content source types from setup table.

    IF ( UPPER(p_purpose) = 'BULK') THEN
      OPEN c_sources;
      FETCH c_sources BULK COLLECT INTO i_sources;
      CLOSE c_sources;
    ELSE
      OPEN c_imp_sources;
      FETCH c_imp_sources BULK COLLECT INTO i_sources;
      CLOSE c_imp_sources;
    END IF;

    l('');
    lli('  FROM hz_'||p_entity_name||'_profiles sst');
    FOR i IN 1..i_sources.COUNT LOOP
      l(',');
      ll(RPAD(l_prefix,7+LENGTHB(g_indent))||
         'hz_'||p_entity_name||'_profiles d_'||LOWER(i_sources(i)));
    END LOOP;

    IF ( UPPER(p_purpose) = 'IMPORT') THEN
      l(',');
      li('       hz_imp_parties_sg sg,');
      li('       hz_imp_parties_int i');
    END IF;

    l('');

    /*===============================================================
     + static where clause
     +===============================================================*/

    li('  --');
    li('  -- use party profiles as driving table because in normal');
    li('  -- case the number of organization/person in hz_parties');
    li('  -- might be much smaller than the number of parties.');
    li('  --');

    IF ( UPPER(p_purpose) = 'BULK') THEN
       getBulkUpdateWhereCondition;
     ELSE
       getImportUpdateWhereCondition;
    END IF;

/*
    li('  WHERE sst.'||'party_id BETWEEN p_from_party_id AND p_to_party_id');
    li('  AND sst.actual_content_source = ''SST''');
    li('  AND sst.effective_end_date IS NULL');
*/
    li('  -- sst profile exists for this party.');
    li('  --');
    li('  AND EXISTS (');
    li('    SELECT ''Y''');
    li('    FROM hz_'||p_entity_name||'_profiles entity');
    li('    WHERE entity.party_id = sst.party_id');
    li('    AND entity.actual_content_source = ''USER_ENTERED''');
    li('    AND entity.effective_end_date IS NULL )');
    li('  -- we use outer join for each third party data source');
    li('  -- in case the party does not have the specific third');
    li('  -- party profile.');
    li('  --');

    /*===============================================================
     + dynamic where clause
     +
     +   AND dnb.party_id (+) = sst.party_id
     +   AND dnb.actual_content_source (+) = 'DNB'
     +   AND dnb.effective_end_date IS NULL
     +   ...
     +===============================================================*/

    FOR i IN 1..i_sources.COUNT LOOP
      IF i <> 1 THEN
        l('');
      END IF;
      li('  AND d_'||LOWER(i_sources(i))||'.party_id (+) = sst.party_id');
      li('  AND d_'||LOWER(i_sources(i))||'.actual_content_source (+) = '''||i_sources(i)||'''');
      li('  AND d_'||LOWER(i_sources(i))||'.effective_end_date IS NULL');
    END LOOP;
    li('ORDER BY create_update_flag, sst.party_id;');
    l('');


-- SSM SST Project :
/*===================================
 * + Create Cursors for Date ranked attriubtes
 * +=====================================*/


FOR i IN 1..i_attribute_name_date.COUNT LOOP
	date_cursor_update(i_entity_attr_id_date(i),
	i_attribute_name_date(i),
	p_entity_name,
	p_purpose);

        IF i_attribute_name_date(i) in ('PERSON_NAME','ORGANIZATION_NAME')
        THEN
         l_has_dated_party_name := true;
        END IF;

    END LOOP;
    l('');

/*===================================
  + Bug 6796587 : Create Cursor to Check if the call is coming
  + from setup change
+=====================================*/
   li('CURSOR c_setup_change IS ');
   li('  SELECT ''Y'' ');
   li('  FROM hz_entity_attributes e ');
   li('  WHERE e.updated_flag = ''Y'' ');
   li('  AND rownum = 1; ');
   l('');
     li('l_call_from_setup_change     VARCHAR2(10); ');
   l('');


    /*===============================================================
     + package body
     +===============================================================*/

    l('BEGIN');

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_ProcedureUtilForBulk('Log',l_procedure_name);
    ELSE
      Gen_ProcedureUtilForBulk('ImportLog',l_procedure_name);
    END IF;

--    Gen_ProcedureUtilForBulk('Log');
    l('');
    IF UPPER(p_purpose) = 'BULK' THEN
      li('reset_who;');
    ELSE
      li('reset_who(p_request_id, p_program_id, p_program_application_id);');
    END IF;
    l('');
    li('hz_common_pub.disable_cont_source_security;');
    l('');
    li('write_log(''open cursor '||l_cursor_name||''');');
    l('');

    /*===============================================================
     + open cursor
     +===============================================================*/

-- SSM SST Project : Open cursors for 'By Date' attributes
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('OPEN '||i_attribute_name_date(i)||'_;');
    END LOOP;

    IF ( UPPER(p_purpose) = 'BULK') THEN
      Gen_CodeForCursor('OPEN', l_cursor_name, 'Y');
    ELSE
      Gen_CodeForCursor('OPEN', l_cursor_name, 'Y', 'IMPORT');
    END IF;

    li('    i_create_update_flag,');
    li('    i_profile_id,');
    lli('    i_party_id');

    /*===============================================================
     + a list of pl/sql tables into which the cursor bulk collect
     +
     +   i_branch_flag,
     +   i_ceo_name,
     +   ...
     +===============================================================*/

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');
      lli('    i_'||Format_AttributeName(i_uq_attribute_name(i)));
    END LOOP;

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      lli('    i_'||Format_AttributeName(i_normal_attributes(i)));
    END LOOP;

    IF p_entity_name = 'organization' THEN
      -- process duns number
      l(',');
      lli('    i_duns_number');
    END IF;

    l(' LIMIT rows;');

    Gen_CodeForCursor('FETCH', l_cursor_name);

-- SSM SST Project : Fetch and BULK COLLECT for 'By Date' attributes
     FOR i IN 1..i_attribute_name_date.COUNT LOOP
             lli('  FETCH '||i_attribute_name_date(i)||'_ ');
             l('BULK COLLECT INTO');
             lli('    i_'||Format_AttributeName(i_attribute_name_date(i)));
             l(',');
             lli('    '||Format_AttributeName(i_attribute_name_date(i)));
             l(' LIMIT rows;');
             l('');
     END LOOP;

    li('  subtotal := i_party_id.COUNT;');
    li('  IF subtotal = 0 AND l_last_fetch THEN');
    li('    EXIT;');
    li('  END IF;');
    li('  total := total + i_party_id.COUNT;');
    l('');
    li('  write_log(''fetched ''||subtotal||'' records.'');');
    l('');

    /*===============================================================
     + select attributes inside an attribute group
     +===============================================================*/

    IF ( UPPER(p_purpose) = 'BULK') THEN
      OPEN c_groups;
      FETCH c_groups BULK COLLECT INTO
        i_group_name, i_uq_group_attributes;
      CLOSE c_groups;
    ELSE
      OPEN c_imp_groups;
      FETCH c_imp_groups BULK COLLECT INTO
        i_group_name, i_uq_group_attributes;
      CLOSE c_imp_groups;
    END IF;

    k := 0;
    FOR i IN 1..i_group_name.COUNT+1 LOOP
      IF i = 1 OR
         i = i_group_name.COUNT+1 OR
         i_group_name(i-1) <> i_group_name(i)
      THEN
        IF i > 1 THEN
          IF i_group_name(i-1) = 'DUNS_NUMBER_C' THEN
            l(',');
            lli('        duns_number');
          END IF;

          l('');
          li('      INTO ');

          FOR j IN l_start..l_end LOOP
            IF j <> l_start THEN
              l(',');
            END IF;
            lli('        i_'||Format_AttributeName(i_uq_group_attributes(j))||'(i)');
          END LOOP;

          IF i_group_name(i-1) = 'DUNS_NUMBER_C' THEN
            l(',');
            lli('        i_duns_number(i)');
          END IF;

          str1 := Format_AttributeName(i_group_name(i-1));
          l('');
          li('      FROM hz_'||p_entity_name||'_profiles');
          li('      WHERE party_id = i_party_id(i)');
          li('      AND effective_end_date IS NULL');
          li('      AND actual_content_source = '||
             'SUBSTRB(i_'||str1||'(i)'||
             ',INSTRB(i_'||str1||'(i)'||', '''||g_sep||''')+2);');

          IF i_group_name(i-1) = 'DUNS_NUMBER_C' THEN
            li('    ELSE');
            li('      i_duns_number(i) := NULL;');
          END IF;
          li('    END IF;');
          li('  END LOOP;');
          l('');

        END IF;  -- IF i > 1 THEN

        IF i = i_group_name.COUNT+1 THEN
          EXIT;
        END IF;

        -- start processing a new attribute group.

        l_start := i; l_end := i;
        li('  write_log(''processing group '||LOWER(i_group_name(i))||''');');
        l('');
        li('  -- process group '||LOWER(i_group_name(i)));
        li('  --');
        li('  FOR i IN 1..subtotal LOOP');
        li('    IF i_'||Format_AttributeName(i_group_name(i))||'(i) IS NOT NULL THEN');
        li('      SELECT');
      ELSE
        l(','); l_end := l_end+1;
      END IF;

      lli('        DECODE('||LOWER(i_uq_group_attributes(i))||',NULL,DECODE(i_'||
          LOWER(i_uq_group_attributes(i))||'(i),NULL,NULL,'''||g_sep||'''||actual_content_source),'||
          LOWER(i_uq_group_attributes(i))||'||'''||g_sep||'''||actual_content_source)');
    END LOOP;

    /*===============================================================
     + put profile ids into 2 table. 1 for create and another for update
     +===============================================================*/

    li('  create_start := 0;  create_end := -1; ');
    li('  update_start := 0;  update_end := -1; ');
    l('');
    li('  FOR i IN 1..subtotal LOOP');
    li('    IF i_create_update_flag(i) = ''C'' THEN');
    li('      IF create_start = 0 THEN create_start := i; END IF;');
    li('    ELSE');
    li('      IF update_start = 0 THEN ');
    li('        update_start := i; ');
    li('        IF create_start > 0 THEN create_end := i-1; END IF;');
    li('      END IF;');
    li('      EXIT;');
    li('    END IF;');
    li('  END LOOP;');
    li('  IF create_start > 0 AND create_end = -1 THEN create_end := subtotal; END IF;');
    li('  IF update_start > 0 AND update_end = -1 THEN update_end := subtotal; END IF;');
    l('');
    li('  write_log((create_end - create_start)||'' record(s) need to be created.'');');
    li('  write_log((update_end - update_start)||'' record(s) need to be updated.'');');
    l('');

    /*===============================================================
     + reset effective_end_date
     +===============================================================*/

    li('  write_log(''end sst profiles which were not created in the same day...'');');
    l('');
    li('  -- reset effective_end_date.');
    l('');
    li('  FORALL i IN create_start..create_end');
    li('    UPDATE hz_'||p_entity_name||'_profiles ');
    li('    SET effective_end_date = TRUNC(SYSDATE-1)');
    li('    WHERE '||p_entity_name||'_profile_id = i_profile_id(i);');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      li('  IF (create_end-create_start) > 0 THEN');
      Gen_CodeForCommit(p_prefix => '    ');
      li('  END IF;');
      l('');
    END IF;

    /*===============================================================
     + create sst profiles
     +===============================================================*/

    li('  write_log(''create new sst profiles for those parties whose sst profiles were end-dated...'');');
    l('');
    li('  -- insert sst profiles');
    l('');
    li('  FORALL i IN create_start..create_end');
    li('    INSERT INTO hz_'||p_entity_name||'_profiles (');

    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','Y');
    l(',');
    Gen_CodeForOtherAttributes ('LIST',g_indent||'      ');
    l(',');
    li('      '||p_entity_name||'_profile_id,');
    li('      party_id,');
    li('      effective_start_date,');
    lli('      object_version_number');

    /*===============================================================
     + column list of insert statement
     +
     +   duns_number_c,
     +   employees_total,
     +   ...
     +===============================================================*/

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_uq_attribute_name(i)));
    END LOOP;

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_normal_attributes(i)));
    END LOOP;

-- SSM SST Project : Add date attributes in insert statement
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_attribute_name_date(i)));
    END LOOP;


    IF p_entity_name = 'organization' THEN
      l(',');
      lli('      duns_number');
    END IF;

    li('    ) VALUES (');

    /*===============================================================
     + value list of insert statement
     +
     +   SUBSTRB(i_duns_number_c(i),1,INSTRB(i_duns_number_c(i),'%#')-1),
     +   TO_NUMBER(SUBSTRB(i_employees_total(i),1, INSTRB(i_employees_total(i),'%#')-1)),
     +   ...
     +===============================================================*/

    Gen_CodeForWhoColumns('I','',g_indent||'      ','Y');
    l(',');
    Gen_CodeForOtherAttributes ('',g_indent||'      ');
    l(',');
    li('      hz_'||p_entity_name||'_profiles_s.nextval,');
    li('      i_party_id(i),');
    li('      SYSDATE,');
    lli('      1');

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');

      str1 := Format_AttributeName(i_uq_attribute_name(i));

      IF i_uq_data_type(i) = 'VARCHAR2' THEN
        str2 := '';  str3 := '';
      ELSIF i_uq_data_type(i) = 'NUMBER' THEN
        str2 := g_to_number; str3 := ')';
      ELSIF i_uq_data_type(i) = 'DATE' THEN
        str2 := g_to_date; str3 := ',''YYYY/MM/DD HH:MI:SS'')';
      END IF;

      lli('      '||str2||'SUBSTRB(i_'||str1||'(i),1,'||
         'INSTRB(i_'||str1||'(i),'''||g_sep||''')-1)'||str3);
    END LOOP;

    FOR i IN 1..i_normal_attributes.COUNT LOOP
      l(',');
      lli('      i_'||Format_AttributeName(i_normal_attributes(i))||'(i)');
    END LOOP;

-- SSM SST Project : Values clause for 'By Date' attributes
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
      l(',');
      lli('      i_'||Format_AttributeName(i_attribute_name_date(i))||'(i)');
    END LOOP;


    IF p_entity_name = 'organization' THEN
      -- process duns number
      l(',');
      li('      i_duns_number(i)');
    END IF;

    li('    ) RETURNING '||p_entity_name||'_profile_id BULK COLLECT INTO i_sst_profile_id;');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      li('  IF (create_end-create_start) > 0 THEN');
      Gen_CodeForCommit(p_prefix => '    ');
      li('  END IF;');
      l('');
    END IF;

    /*===============================================================
     + update sst profiles
     +===============================================================*/

    li('  write_log(''update sst profiles.'');');
    l('');
    li('  -- update sst profiles');
    l('');
    li('  FORALL i IN update_start..update_end');
    li('    UPDATE hz_'||p_entity_name||'_profiles');
    li('    SET');
    Gen_CodeForWhoColumns('U','',g_indent||'      ','Y');

    FOR i IN 1..i_uq_attribute_name.COUNT LOOP
      l(',');

      str1 := Format_AttributeName(i_uq_attribute_name(i));

      IF i_uq_data_type(i) = 'VARCHAR2' THEN
        str2 := '';  str3 := '';
      ELSIF i_uq_data_type(i) = 'NUMBER' THEN
        str2 := g_to_number; str3 := ')';
      ELSIF i_uq_data_type(i) = 'DATE' THEN
        str2 := g_to_date; str3 := ',''YYYY/MM/DD HH:MI:SS'')';
      END IF;

      -- Bug 3613620: replaced str1 with LOWER(i_uq_attribute_name(i))

      lli('      '||LOWER(i_uq_attribute_name(i))||' = '||str2||'SUBSTRB(i_'||str1||'(i),1,'||
          'INSTRB(i_'||str1||'(i),'''||g_sep||''')-1)'||str3);
    END LOOP;

-- SSM SST Project : Denormalize 'By Date' columns
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
      l(',');
      lli('      '||LOWER(i_attribute_name_date(i))||' = ');
      ll('i_'||Format_AttributeName(i_attribute_name_date(i))||'(i)');
    END LOOP;


    IF p_entity_name = 'organization' THEN
      -- process duns number
      l(',');
      lli('      duns_number = i_duns_number(i)');
    END IF;

    l('');
    li('    WHERE '||p_entity_name||'_profile_id = i_profile_id(i);');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      li('  IF (update_end-update_start) > 0 THEN');
      Gen_CodeForCommit(p_prefix => '    ');
      li('  END IF;');
      l('');
    END IF;

    /*===============================================================
     + denormalize sst to hz_parties (restricted columns only)
     +
     +   duns_number_c =
     +     SUBSTRB(i_duns_number_c(i),1,INSTRB(i_duns_number_c(i),'%#')-1),
     +   employees_total =
     +     TO_NUMBER(SUBSTRB(i_employees_total(i),1, INSTRB(i_employees_total(i),'%#')-1)),
     +   ...
     +===============================================================*/

    li('  write_log(''update denormalized columns in hz_parties.'');');
    l('');

    li('  -- update denormalized columns in hz_parties.');
    l('');
    li('  FORALL i IN 1..subtotal');
    li('    UPDATE hz_parties');
    li('    SET');

    Gen_CodeForWhoColumns('U','',g_indent||'      ','Y');

    FOR i IN 1..l_all_attribute_names.COUNT LOOP
      IF l_de_column_names(i) IS NOT NULL THEN
        l_index := Get_Index(i_uq_attribute_name, l_all_attribute_names(i));
        l_index_date := Get_Index(i_attribute_name_date, l_all_attribute_names(i));

        IF l_index > 0 THEN
          l(',');
          lli('      '||LOWER(l_all_attribute_names(i))||' = ');

          str1 := Format_AttributeName(l_all_attribute_names(i));

          IF i_uq_data_type(l_index) = 'VARCHAR2' THEN
            str2 := '';  str3 := '';
          ELSIF i_uq_data_type(l_index) = 'NUMBER' THEN
            str2 := g_to_number; str3 := ')';
          ELSIF i_uq_data_type(l_index) = 'DATE' THEN
            str2 := g_to_date; str3 := ',''YYYY/MM/DD HH:MI:SS'')';
          END IF;

          ll(str2||'SUBSTRB(i_'||str1||'(i),1,'||
             'INSTRB(i_'||str1||'(i),'''||g_sep||''')-1)'||str3);
        END IF;

-- SSM SST Project : Denormalize 'By Date' columns
        IF l_index_date > 0 THEN
          l(',');
          lli('      '||LOWER(l_all_attribute_names(i))||' = ');
          ll('i_'||Format_AttributeName(l_all_attribute_names(i))||'(i)');
        END IF;
      END IF;
    END LOOP;

    /*===============================================================
     + denormalize duns_number into hz_parties
     +===============================================================*/

    IF p_entity_name = 'organization' THEN
      l(',');
      lli('      duns_number = i_duns_number(i)');
    END IF;

    /*===============================================================
     + update party_name, customer_key in hz_parties
     +===============================================================*/

    IF l_has_party_name THEN
      Gen_PartyName (p_entity_name);
    END IF;

    IF l_has_dated_party_name THEN
      IF p_entity_name = 'organization' THEN
      l(',');
      lli('      party_name = i_organization_name(i)');
      ELSIF p_entity_name = 'person' THEN
      l(',');
      lli('      party_name = i_person_name(i)');
      END IF;
    END IF;

    li('    WHERE party_id = i_party_id(i);');
    l('');

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCommit;
    END IF;

    /*===============================================================
     + update party_name of relationship parties
     +===============================================================*/

    IF l_has_party_name THEN
      Gen_RelationshipPartyName;
      IF UPPER(p_purpose) = 'BULK' THEN
        Gen_CodeForCommit(false);
      END IF;
    END IF;

    /*===============================================================
     + update exception table to track attributes' data source
     +===============================================================*/

    li('  write_log(''update exception table.'');');
    l('');

-- SSM SST Project :
-- Delete records from exception talbe for all attributes
-- setup 'By Date' and not having exception type = MRR


  li('  -- Bug 6913856 : Check if the call is coming from setup change ');
  li('  -- We need to delete only if there is setup change. If no setup change');
  li('  -- and call is from regular processing API, then no DELETE is required');
  li('  OPEN c_setup_change; ');
  li('  FETCH c_setup_change INTO l_call_from_setup_change; ');
  li('  IF c_setup_change%NOTFOUND THEN ');
  li('    l_call_from_setup_change := ''N''; ');
  li('    Write_Log(''NO setup for any entity / attribute has been updated. DELETE hz_win_source_exceps call not required.''); ');
  li('  END IF; ');
  li('  CLOSE c_setup_change; ');
  l('');

    FOR j IN 1..i_entity_attr_id_date.COUNT LOOP
     li('  IF l_call_from_setup_change = ''Y'' THEN ');
     li('    Write_Log(''Deleting hz_win_source_exceps for entity_attr_id :'||i_entity_attr_id_date(j)||' '');' );
     l('');
          li('  DELETE hz_win_source_exceps ');
          li('  WHERE party_id BETWEEN i_party_id(1) AND i_party_id(subtotal) ');
          li('  AND exception_type <> ''MRR''');
          li('  AND entity_attr_id = '||i_entity_attr_id_date(j)||';');
          l('');
     li('  END IF; ');
    END LOOP;

    OPEN c_deselected_sources;
    FETCH c_deselected_sources BULK COLLECT INTO i_deentity_attr_id, i_deselected_sources;
    CLOSE c_deselected_sources;

    FOR i IN 1..i_uq_entity_attr_id.COUNT LOOP
      IF i_uq_group_flag(i) = 'N' THEN

-- SSM SST Project :
-- Delete records from exception talbe for all attributes
-- setup 'By Rank' and having exception type = MRR
    /* Bug 4228765 : Donot delete MRR records here as it is
 * 		     deleted in main conc program earlier
          li('  DELETE hz_win_source_exceps ');
          li('  WHERE party_id BETWEEN i_party_id(1) AND i_party_id(subtotal) ');
          li('  AND exception_type = ''MRR''');
          li('  AND entity_attr_id = '||i_uq_entity_attr_id(i)||';');
          l('');
*/
        li('  update_exception_table(''U'','||
           'i_party_id,'''||i_uq_attribute_name(i)||''','||
           i_uq_entity_attr_id(i)||','||
           'i_'||Format_AttributeName(i_uq_attribute_name(i))||','''||
           i_uq_winner_source(i)||''');');
        l('');
      END IF;
    END LOOP;

    FOR i IN 1..i_deentity_attr_id.COUNT+1 LOOP
      IF i = 1 OR
         i = i_deentity_attr_id.COUNT+1 OR
         i_deentity_attr_id(i-1) <> i_deentity_attr_id(i)
      THEN
        IF i > 1 THEN
         li('IF l_call_from_setup_change = ''Y'' THEN ');
         li('Write_Log(''Deleting hz_win_source_exceps for entity_attr_id :'||i_deentity_attr_id(i-1)||' '');' );
         l('');
          li('  DELETE hz_win_source_exceps ');
          li('  WHERE party_id BETWEEN i_party_id(1) AND i_party_id(subtotal) ');
          li('  AND content_source_type IN ('||substrb(str1,2)||')');
          li('  AND entity_attr_id = '||i_deentity_attr_id(i-1)||';');
          l('');
         li('END IF; ');
        END IF;  -- IF i > 1 THEN

        IF i = i_deentity_attr_id.COUNT+1 THEN
          EXIT;
        END IF;

        str1 := '';
      END IF;
--      IF str1 <> '' THEN
	str1 := str1||',';
--      END IF;
      str1 := str1||''''||i_deselected_sources(i)||'''';
    END LOOP;

-- SSM SST Project : Update exceptions table for 'By Date' attributes
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('  update_exception_table_date(''U'','||
           'i_party_id,'''||i_attribute_name_date(i)||''','||
           i_entity_attr_id_date(i)||','||
 Format_AttributeName(i_attribute_name_date(i))||');');
--           'i_actual_content_source);');
        l('');
    END LOOP;

-- SSM SST Project : Delete the entries from user overwrite rules
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
	li(' delete hz_user_overwrite_rules where entity_attr_id = ' || i_entity_attr_id_date(i)||' ;');
        l('');
    END LOOP;

    IF UPPER(p_purpose) = 'BULK' THEN
      Gen_CodeForCommit(false);
    END IF;

    /*===============================================================
     + write output file
     +===============================================================*/

    Gen_WriteOutputFileForUpdate;

    /*===============================================================
     + update DQM interface table
     +
     + As per talk with Srini, right now DQM can not handle huge
     + data in interface table. User should run DQM sync program
     + after they run this program for mix-n-match.
     +===============================================================*/
    /*
    IF hz_dqm_search_util.is_dqm_available = 'T' THEN
      Gen_CodeForDQM(p_entity_name);
    END IF;
    */

    /*===============================================================
     + close cursor
     +===============================================================*/


    IF ( UPPER(p_purpose) = 'BULK') THEN
      Gen_CodeForCursor('CLOSE', l_cursor_name);
    ELSE
      Gen_CodeForCursor('CLOSE', l_cursor_name, null, 'IMPORT');
    END IF;
-- SSM SST Project : Close 'By Date' cursors
    FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('CLOSE '||i_attribute_name_date(i)||'_;');
    END LOOP;
    l('');
    li('write_out(total||'' sst profile(s) was(were) updated.'');');
    l('');
    li('write_log(total||'' sst profile(s) was(were) successfully updated.'');');
    l('END '||l_procedure_name||';');
    l('');

END Gen_BulkUpdateSST;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *
 * MODIFICATION HISTORY
 *
 */

PROCEDURE Gen_CommonProceduresForAPI IS
BEGIN

    /*===============================================================
     + declare global type and variables
     +===============================================================*/

    l('TYPE INDEXEDVARCHARLIST IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;');
    l('');

END Gen_CommonProceduresForAPI;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *
 * MODIFICATION HISTORY
 *
 */

PROCEDURE Gen_UpdateSSTRecord (
    p_entity_name             IN     VARCHAR2
) IS

    CURSOR c_restricted_attributes IS
      SELECT e.attribute_name, e.entity_attr_id,
             s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.attribute_name NOT IN ('BANK_CODE','BANK_OR_BRANCH_NUMBER','BRANCH_CODE')
      AND EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e.entity_attr_id
        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking > 0 )
      AND s.entity_attr_id = e.entity_attr_id
      AND s.ranking > 0
      ORDER BY e.attribute_name, s.ranking;

    i_attribute_name                INDEXVARCHAR30List;
    i_uq_attribute_name             INDEXVARCHAR30List;
    i_entity_attr_id                INDEXIDList;
    i_uq_entity_attr_id             INDEXIDList;
    i_content_source_type           INDEXVARCHAR30List;
    i_uq_data_type                  INDEXVARCHAR60List;
    i_uq_winner_source              INDEXVARCHAR30List;
    i_normal_attributes             INDEXVARCHAR30List;

    CURSOR c_sources IS
      SELECT UNIQUE s.content_source_type
      FROM hz_entity_attributes e,
           hz_select_data_sources s
      WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
      AND e.attribute_name NOT IN ('BANK_CODE','BANK_OR_BRANCH_NUMBER','BRANCH_CODE')
      AND e.entity_attr_id = s.entity_attr_id
      AND s.ranking > 0;

    i_sources                       INDEXVARCHAR30List;

    l_all_attribute_names           INDEXVARCHAR30List;
    l_data_type                     INDEXVARCHAR30List;

    CURSOR c_restricted_groups IS
      SELECT  e.attribute_group_name,
              DECODE(e.attribute_group_name, 'PERSON_NAME',
                     DECODE(e1.attribute_name, 'PERSON_LAST_NAME',
                            e1.entity_attr_id, null),
                     e1.attribute_name,
                     e1.entity_attr_id, null) primary_entity_attr_id,
             e1.attribute_name,
             e1.entity_attr_id
      FROM
        (SELECT attribute_group_name
         FROM hz_entity_attributes
         WHERE entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         GROUP BY attribute_group_name
         HAVING COUNT(entity_attr_id) > 1
        ) e,
        hz_entity_attributes e1
      WHERE e1.attribute_group_name = e.attribute_group_name
      AND e1.attribute_name NOT IN ('BANK_CODE','BANK_OR_BRANCH_NUMBER','BRANCH_CODE')
      AND EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e1.entity_attr_id
        AND s1.content_source_type <> 'USER_ENTERED'
        AND s1.ranking <> 0 )
      ORDER BY e.attribute_group_name, primary_entity_attr_id;

    i_attribute_group_name          INDEXVARCHAR30List;
    i_primary_entity_attr_id        INDEXIDList;
    i_group_attribute_name          INDEXVARCHAR30List;
    i_group_entity_attr_id          INDEXIDList;

    l_procedure_name                VARCHAR2(30);
-- Bug 4171892
    l_prefix                        VARCHAR2(1000);
    str1                            VARCHAR2(1000);
    str2                            VARCHAR2(1000);
    str3                            VARCHAR2(1000);
    l_index                         NUMBER;
    k                               NUMBER := 0;
    j                               NUMBER := 0;
    l_start                         NUMBER := 0;
    l_end                           NUMBER := 0;
    l_group_id                      NUMBER;
    l_index1                        NUMBER := -1;
    l_index2                        NUMBER := -1;
-- Bug 6472658 : ORDER BY Clause added.
      CURSOR c_date_attributes IS
	 SELECT distinct e.attribute_name, e.entity_attr_id
	 FROM hz_entity_attributes e,
	 hz_select_data_sources s
         WHERE e.entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         AND e.attribute_name NOT IN ('BANK_CODE','BANK_OR_BRANCH_NUMBER','BRANCH_CODE')
	 AND EXISTS (
	 SELECT 'Y'
	 FROM hz_select_data_sources s1
	 WHERE s1.entity_attr_id = e.entity_attr_id
	 AND s1.ranking < 0 )
	 AND s.entity_attr_id = e.entity_attr_id
	 AND s.ranking < 0
       ORDER BY e.attribute_name;
--	 ORDER BY e.attribute_name, s.ranking;
/*
     CURSOR c_date_group_name IS
     	SELECT  e.attribute_group_name,
              DECODE(e.attribute_group_name, 'PERSON_NAME',
                     DECODE(e1.attribute_name, 'PERSON_LAST_NAME',
                            e1.entity_attr_id, null),
                     e1.attribute_name,
                     e1.entity_attr_id, null) primary_entity_attr_id,
             e1.attribute_name,
             e1.entity_attr_id
      FROM
        (SELECT attribute_group_name
         FROM hz_entity_attributes
         WHERE entity_name = 'HZ_'||UPPER(p_entity_name)||'_PROFILES'
         GROUP BY attribute_group_name
         HAVING COUNT(entity_attr_id) > 1
        ) e,
        hz_entity_attributes e1
      WHERE e1.attribute_group_name = e.attribute_group_name
      AND EXISTS (
        SELECT 'Y'
        FROM hz_select_data_sources s1
        WHERE s1.entity_attr_id = e1.entity_attr_id
        AND s1.ranking < 0 )
      ORDER BY e.attribute_group_name, primary_entity_attr_id;
*/
    i_attribute_group_name_date		INDEXVARCHAR30List;
    i_primary_entity_attr_id_date	INDEXIDList;
    i_group_attribute_name_date		INDEXVARCHAR30List;
    i_group_entity_attr_id_date		INDEXIDList;
    i_attribute_name_date		INDEXVARCHAR30List;
    i_entity_attr_id_date		INDEXIDList;
    l_index_date			NUMBER;
    i_data_type				VARCHAR2(60);


BEGIN

    IF p_entity_name = 'organization' THEN
      l_all_attribute_names := G_O_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_O_DATA_TYPE;
    ELSE
      l_all_attribute_names := G_P_ALL_ATTRIBUTE_NAMES;
      l_data_type := G_P_DATA_TYPE;
    END IF;

    OPEN c_restricted_attributes;
    FETCH c_restricted_attributes BULK COLLECT INTO
      i_attribute_name, i_entity_attr_id,
      i_content_source_type;
    CLOSE c_restricted_attributes;

    /*===============================================================
     + procedure for setting SST record
     +===============================================================*/

    IF p_entity_name = 'organization' THEN
      l_procedure_name := 'selectOrgHighestRankedValue';
    ELSE
      l_procedure_name := 'selectPerHighestRankedValue';
    END IF;

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_party_id')||'IN     NUMBER,');
    li(fp('x_highest_ranked_value')||'OUT    NOCOPY INDEXEDVARCHARLIST,');
    li(fp('x_highest_ranked_source')||'OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List');
    l(') IS');
    l('  i NUMBER;');
    l('BEGIN');

    IF i_attribute_name.COUNT = 0 THEN
      li('NULL;');
    ELSE

      li('SELECT ');

      k := 0;
      FOR i IN 1..i_attribute_name.COUNT+1 LOOP
        IF i = 1 OR
           i = i_attribute_name.COUNT+1 OR
           i_attribute_name(i-1) <> i_attribute_name(i)
        THEN
          IF i > 1 THEN
            l(l_prefix||'NULL,');

            FOR j IN REVERSE l_start..l_end LOOP
              IF l_data_type(l_index) IN ('NUMBER','DATE') THEN
                str1 := g_to_char;  str2 := '';  str3 := ')';
                IF l_data_type(l_index) = 'DATE' THEN
                  str2 := ',''YYYY/MM/DD HH:MI:SS''';
                END IF;
              ELSE
                str1 := ''; str2 := '';  str3 := '';
              END IF;

              ll(l_prefix||str1||'d_'||LOWER(i_content_source_type(j))||'.'||
                 LOWER(i_attribute_name(i-1))||str2||str3||'||'''||
                 g_sep||i_content_source_type(j)||''')');

              IF j = l_start THEN
                ll(' '||LOWER(i_attribute_name(i-1)));
              ELSE
                l(',');
              END IF;
              l_prefix := SUBSTRB(l_prefix, 1, LENGTHB(l_prefix)-2);
            END LOOP;
          END IF;  -- IF i > 1 THEN

          IF i = i_attribute_name.COUNT+1 THEN
            EXIT;
          END IF;

          IF i > 1 THEN
            l(',');
          END IF;

          -- start processing a new attribute.

          l_start := i; l_end := i; l_prefix := RPAD(g_indent,5+LENGTHB(g_indent));
          l_index := Get_Index(l_all_attribute_names, i_attribute_name(i));
          k := k + 1;
          i_uq_attribute_name(k) := i_attribute_name(i);
          i_uq_entity_attr_id(k) := i_entity_attr_id(i);
          IF l_data_type(l_index) = 'VARCHAR2' THEN
            i_uq_data_type(k) := 'fnd_api.g_miss_char';
          ELSIF l_data_type(l_index) = 'NUMBER' THEN
            i_uq_data_type(k) := 'fnd_api.g_miss_num';
          ELSIF l_data_type(l_index) = 'DATE' THEN
            i_uq_data_type(k) := 'fnd_api.g_miss_date';
          END IF;

          l(l_prefix||'--');
          l(l_prefix||'-- processing '||LOWER(i_attribute_name(i))||'.');
        ELSE
          l_prefix := l_prefix||'  '; l_end := l_end+1;
        END IF;

        l(l_prefix||'DECODE(d_'||LOWER(i_content_source_type(i))||
          '.'||LOWER(i_attribute_name(i))||', NULL, ');
      END LOOP;

      /*===============================================================
       + into clause
       +===============================================================*/

      l('');
      li('INTO');

      l_prefix := RPAD(g_indent,3+LENGTHB(g_indent));

      FOR i IN 1..i_uq_attribute_name.COUNT LOOP
        IF i > 1 THEN
          l(',');
        END IF;
        lli(l_prefix||'x_highest_ranked_value('||i_uq_entity_attr_id(i)||')');
      END LOOP;

      /*===============================================================
       + from list
       +
       +   FROM hz_organization_profiles dnb,
       +        hz_organization_profiles user_entered
       +        ...
       +===============================================================*/

      -- fetch all of content source types from setup table.

      OPEN c_sources;
      FETCH c_sources BULK COLLECT INTO i_sources;
      CLOSE c_sources;

      l('');
      li('FROM hz_'||p_entity_name||'_profiles sst,');
      FOR i IN 1..i_sources.COUNT LOOP
        IF i > 1 THEN
          l(',');
        END IF;

        ll(RPAD(l_prefix,5+LENGTHB(g_indent))||
         'hz_'||p_entity_name||'_profiles d_'||LOWER(i_sources(i)));
      END LOOP;
      l('');

      /*===============================================================
       + static where clause
       +===============================================================*/

      li('WHERE sst.'||'party_id = p_party_id');
      li('AND sst.actual_content_source = ''SST''');
      li('AND sst.effective_end_date IS NULL');
      li('--');

      /*===============================================================
       + dynamic where clause
       +
       +   AND dnb.party_id (+) = sst.party_id
       +   AND dnb.actual_content_source (+) = 'DNB'
       +   AND dnb.effective_end_date IS NULL
       +   ...
       +===============================================================*/

      FOR i IN 1..i_sources.COUNT LOOP
        IF i <> 1 THEN
          l('');
        END IF;
        li('AND d_'||LOWER(i_sources(i))||'.party_id (+) = sst.party_id');
        li('AND d_'||LOWER(i_sources(i))||'.actual_content_source (+) = '''||i_sources(i)||'''');
        lli('AND d_'||LOWER(i_sources(i))||'.effective_end_date IS NULL');
      END LOOP;
      l(';');
      l('');

--      li('FOR i IN 1..x_highest_ranked_value.COUNT LOOP');
      li('i := x_highest_ranked_value.first;');
      li('while i is not null LOOP');
      li('  IF x_highest_ranked_value(i) IS NOT NULL THEN');
      li('    x_highest_ranked_source(i) := SUBSTRB(x_highest_ranked_value(i),'||
         'INSTRB(x_highest_ranked_value(i),'''||g_sep||''')+2);');
      li('    x_highest_ranked_value(i) := SUBSTRB(x_highest_ranked_value(i),1,'||
         'INSTRB(x_highest_ranked_value(i),'''||g_sep||''')-1);');
      li('  END IF;');
      li('i := x_highest_ranked_value.next(i); ');
      li('END LOOP;');
    END IF;

    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + procedure for assigning non-restricted columns
     +===============================================================*/
    OPEN c_date_attributes;
    FETCH c_date_attributes BULK COLLECT INTO
	i_attribute_name_date, i_entity_attr_id_date;
    CLOSE c_date_attributes;

    l_procedure_name := 'assignNonRestrictedColumns';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_new_rec')||'IN     HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('p_sst_rec')||'IN OUT NOCOPY HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE');
    l(') IS');
    l('BEGIN');

    FOR i IN 1..l_all_attribute_names.COUNT LOOP
      IF(l_all_attribute_names(i) <> 'BANK_CODE' AND
	 l_all_attribute_names(i) <> 'BANK_OR_BRANCH_NUMBER' AND
	 l_all_attribute_names(i) <> 'BRANCH_CODE') THEN
      l_index := Get_Index(i_uq_attribute_name, l_all_attribute_names(i));
      l_index_date := Get_Index(i_attribute_name_date, l_all_attribute_names(i));

      IF (l_index = 0 AND l_index_date = 0) THEN
        j := j + 1;
        i_normal_attributes(j) := l_all_attribute_names(i);
      END IF;
      END IF;
    END LOOP;

    IF i_normal_attributes.COUNT = 0 THEN
      li('NULL;');
    ELSE
      FOR i IN 1..i_normal_attributes.COUNT LOOP
        li('p_sst_rec.'||LOWER(i_normal_attributes(i))||
           ' := p_new_rec.'||LOWER(i_normal_attributes(i))||';');
      END LOOP;
      li('p_sst_rec.party_rec := p_new_rec.party_rec;');
    END IF;

    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + procedure to get column NULL property
     +===============================================================*/

    l_procedure_name := 'getColumnNullProperty';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_sst_rec')||'IN     HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
--    l(fp('p_name_list')||'IN     HZ_MIXNM_UTILITY.INDEXVARCHAR30List,');
    li(fp('x_value_is_null_list')||'OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,');
    li(fp('x_value_is_not_null_list')||'OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List');
    l(') IS');
    l('BEGIN');

    IF (i_uq_attribute_name.COUNT = 0 AND i_attribute_name_date.COUNT = 0) THEN
      li('NULL;');
    ELSE
      FOR i IN 1..i_uq_attribute_name.COUNT LOOP
--      li('IF p_name_list.EXISTS('||i_entity_attr_id(i)||') THEN');
      li('IF NVL(p_sst_rec.'||LOWER(i_uq_attribute_name(i))||','||i_uq_data_type(i)||') <> '||i_uq_data_type(i));
      li('THEN');
      li('  x_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''N'';');
      li('  x_value_is_not_null_list('||i_uq_entity_attr_id(i)||') := ''Y'';');
      li('ELSE');
      li('  x_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''Y'';');
      li('  x_value_is_not_null_list('||i_uq_entity_attr_id(i)||') := ''N'';');
--      li('END IF;');
      li('END IF;');

      END LOOP;

      FOR i IN 1..i_attribute_name_date.COUNT LOOP
      	  l_index_date := Get_Index(l_all_attribute_names, i_attribute_name_date(i));
          IF l_data_type(l_index_date) = 'VARCHAR2' THEN
            i_data_type := 'fnd_api.g_miss_char';
          ELSIF l_data_type(l_index_date) = 'NUMBER' THEN
            i_data_type := 'fnd_api.g_miss_num';
          ELSIF l_data_type(l_index_date) = 'DATE' THEN
            i_data_type := 'fnd_api.g_miss_date';
          END IF;

      li('IF NVL(p_sst_rec.'||LOWER(i_attribute_name_date(i))||','||i_data_type||') <> '||i_data_type);
      li('THEN');
      li('  x_value_is_null_list('||i_entity_attr_id_date(i)||') := ''N'';');
-- Bug 4244112 : for date att, x_value_is_not_null_list is always N
      li('  x_value_is_not_null_list('||i_entity_attr_id_date(i)||') := ''N'';');
      li('ELSE');
      li('  x_value_is_null_list('||i_entity_attr_id_date(i)||') := ''Y'';');
      li('  x_value_is_not_null_list('||i_entity_attr_id_date(i)||') := ''N'';');
      li('END IF;');
      END LOOP;


    END IF;

    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + procedure for assigning all of columns
     +===============================================================*/

    l_procedure_name := 'initAttributeList';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_create_update_flag')||'IN     VARCHAR2,');
    li(fp('p_new_rec')||'IN     HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('p_old_rec')||'IN     HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('x_name_list')||'OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List,');
    li(fp('x_new_value_is_null_list')||'OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List');
    l(') IS');
    l('BEGIN');

    IF (i_uq_attribute_name.COUNT = 0 AND i_attribute_name_date.COUNT = 0) THEN
      li('NULL;');
    ELSE
      FOR j IN 1..2 LOOP
        IF j = 1 THEN
          li('IF p_create_update_flag = ''C'' THEN');
        ELSE
          li('ELSE');
        END IF;

        FOR i IN 1..i_uq_attribute_name.COUNT LOOP
          IF j = 1 THEN
            li('  IF NVL(p_new_rec.'||LOWER(i_uq_attribute_name(i))||','||
               i_uq_data_type(i)||') <> '||i_uq_data_type(i));
            li('  THEN');
            li('    x_name_list('||i_uq_entity_attr_id(i)||') := '''||
               LOWER(i_uq_attribute_name(i))||''';');
-- Bug 4201309 : store x_new_value_is_null_list = N also
            li('    x_new_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''N'';');
            li('  ELSE');
            li('    x_new_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''Y'';');
            li('  END IF;');
          ELSE
            li('  IF p_new_rec.'||LOWER(i_uq_attribute_name(i))||' IS NOT NULL THEN');
            li('    IF  p_new_rec.'||LOWER(i_uq_attribute_name(i))||' = '||i_uq_data_type(i)||' THEN');
            li('      x_new_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''Y'';');
            li('    END IF;');
            li('    IF p_new_rec.'||LOWER(i_uq_attribute_name(i))||
               ' <> p_old_rec.'||LOWER(i_uq_attribute_name(i)));
            li('    THEN');
            li('      x_name_list('||i_uq_entity_attr_id(i)||') := '''||
               LOWER(i_uq_attribute_name(i))||''';');
            li('    x_new_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''N'';');
            li('    END IF;');
	    li('  ELSE');
            li('    x_new_value_is_null_list('||i_uq_entity_attr_id(i)||') := ''N'';');
            li('  END IF;');
          END IF;
        END LOOP;

        FOR i IN 1..i_attribute_name_date.COUNT LOOP
-- Bug 4244112 : for date attributes, do not check values
--               always add it to the x_name_list
          IF j = 1 THEN
--            li('  IF NVL(p_new_rec.'||LOWER(i_attribute_name_date(i))||','||
--              i_data_type||') <> '||i_data_type);
--            li('  THEN');
            li('    x_name_list('||i_entity_attr_id_date(i)||') := '''||
               LOWER(i_attribute_name_date(i))||''';');
	    li('      x_new_value_is_null_list('||i_entity_attr_id_date(i)||') := ''N'';');
--            li('  ELSE');
--            li('    x_new_value_is_null_list('||i_entity_attr_id_date(i)||') := ''Y'';');
--            li('  END IF;');
-- Bug 4201309 : for update case, x_new_value_is_null_list if
-- 	         the value is NULL
          ELSE
            li('  IF p_new_rec.'||LOWER(i_attribute_name_date(i))||' IS NULL THEN');
--            li('    IF  p_new_rec.'||LOWER(i_attribute_name_date(i))||' = '||i_data_type||' THEN');
            li('      x_new_value_is_null_list('||i_entity_attr_id_date(i)||') := ''Y'';');
	    li('  ELSE');
	    li('      x_new_value_is_null_list('||i_entity_attr_id_date(i)||') := ''N'';');
            li('  END IF;');
            li('      x_name_list('||i_entity_attr_id_date(i)||') := '''||
               LOWER(i_attribute_name_date(i))||''';');
--            li('  END IF;');
          END IF;

        END LOOP;

      END LOOP;

      li('END IF;');
    END IF;

    l('END '||l_procedure_name||';');
    l('');

    /*===============================================================
     + procedure for setting SST record
     +===============================================================*/

    OPEN c_restricted_groups;
    FETCH c_restricted_groups BULK COLLECT INTO
      i_attribute_group_name, i_primary_entity_attr_id,
      i_group_attribute_name, i_group_entity_attr_id;
    CLOSE c_restricted_groups;

    l_procedure_name := 'createSSTRecord';

    l('PROCEDURE '||l_procedure_name||' (');
    li(fp('p_new_data_source')||'IN     VARCHAR2,');
    li(fp('p_new_rec')||'IN     HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('p_sst_rec')||'IN OUT NOCOPY HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('p_updateable_flag_list')||'IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,');
    li(fp('p_exception_type_list')||'IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List');
    l(') IS');
    l('BEGIN');

    IF (i_uq_attribute_name.COUNT = 0 AND i_attribute_name_date.COUNT = 0) THEN
      li('NULL;');
    ELSE
      l_start := 0; l_end := 0;
      FOR i IN 1..i_attribute_group_name.COUNT+1 LOOP
        IF i = 1 OR
           i = i_attribute_group_name.COUNT+1 OR
           i_attribute_group_name(i-1) <> i_attribute_group_name(i)
        THEN
          IF i <> 1 THEN
            l_index := Get_Index(l_all_attribute_names, i_group_attribute_name(l_start));

            IF l_data_type(l_index) = 'VARCHAR2' THEN
              str1 := 'fnd_api.g_miss_char';
            ELSIF l_data_type(l_index) = 'NUMBER' THEN
              str1 := 'fnd_api.g_miss_num';
            ELSIF l_data_type(l_index) = 'DATE' THEN
              str1 := 'fnd_api.g_miss_date';
            END IF;

            li('ELSIF NVL(p_sst_rec.'||LOWER(i_group_attribute_name(l_start))||','||str1||') <> '||str1||' THEN');

            l_end := i-1;
            FOR j IN REVERSE l_start+1..l_end LOOP
              li('  p_updateable_flag_list('||i_group_entity_attr_id(j)||') := ''N'';');
              li('  p_exception_type_list('||i_group_entity_attr_id(j)||') := NULL;');
            END LOOP;

            li('END IF;');
          END IF;

          IF i = i_attribute_group_name.COUNT+1 THEN
            l('');
            EXIT;
          END IF;

          -- start processing a new attribute group.
          li('-- processing group '||LOWER(i_attribute_group_name(i)));
          li('IF p_updateable_flag_list.EXISTS('||i_group_entity_attr_id(i)||') AND');
          li('   p_updateable_flag_list('||i_group_entity_attr_id(i)||') = ''Y''');
          li('THEN');

          l_group_id := i_group_entity_attr_id(i);   l_start := i;
        ELSE
          l_index := Get_Index(l_all_attribute_names, i_group_attribute_name(i));

          IF l_data_type(l_index) = 'VARCHAR2' THEN
            str1 := 'fnd_api.g_miss_char';
          ELSIF l_data_type(l_index) = 'NUMBER' THEN
            str1 := 'fnd_api.g_miss_num';
          ELSIF l_data_type(l_index) = 'DATE' THEN
           str1 := 'fnd_api.g_miss_date';
          END IF;

          li('  IF NVL(p_new_rec.'||LOWER(i_group_attribute_name(i))||','||str1||') <> '||str1||' OR');
          li('     NVL(p_sst_rec.'||LOWER(i_group_attribute_name(i))||','||str1||') <> '||str1);
          li('  THEN');
          li('    p_updateable_flag_list('||i_group_entity_attr_id(i)||') := ''Y'';');
          li('    p_exception_type_list('||i_group_entity_attr_id(i)||') := p_exception_type_list('||l_group_id||');');
          li('  END IF;');
        END IF;
      END LOOP;

      FOR i IN 1..i_uq_attribute_name.COUNT LOOP
        li('IF p_updateable_flag_list.EXISTS('||i_uq_entity_attr_id(i)||') AND');
        li('   p_updateable_flag_list('||i_uq_entity_attr_id(i)||') = ''Y''');
        li('THEN');
        li('  p_sst_rec.'||LOWER(i_uq_attribute_name(i))||
           ' := p_new_rec.'||LOWER(i_uq_attribute_name(i))||';');
        li('END IF;');
      END LOOP;

      FOR i IN 1..i_attribute_name_date.COUNT LOOP
        li('IF p_updateable_flag_list.EXISTS('||i_entity_attr_id_date(i)||') AND');
        li('   p_updateable_flag_list('||i_entity_attr_id_date(i)||') = ''Y''');
        li('THEN');
        li('  p_sst_rec.'||LOWER(i_attribute_name_date(i))||
           ' := p_new_rec.'||LOWER(i_attribute_name_date(i))||';');
        li('END IF;');
      END LOOP;

      li('IF p_new_data_source = ''USER_ENTERED'' THEN');
      li('  assignNonRestrictedColumns(p_new_rec, p_sst_rec);');
      li('END IF;');
      l('');
    END IF;

    l('END '||l_procedure_name||';');
    l('');

    l_procedure_name := 'updateSSTRecord';

    l('PROCEDURE '||l_procedure_name||' (');
-- Bug 4201309 : add parameter p_create_update_flag
    li(fp('p_create_update_flag')||'IN	VARCHAR2,');
    li(fp('p_new_data_source')||'IN     VARCHAR2,');
    li(fp('p_new_rec')||'IN     HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('p_sst_rec')||'IN OUT NOCOPY HZ_PARTY_V2PUB.'||UPPER(p_entity_name)||'_REC_TYPE,');
    li(fp('p_updateable_flag_list')||'IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR1List,');
    li(fp('p_exception_type_list')||'IN OUT NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List,');
    li(fp('p_new_value_is_null_list')||'IN     HZ_MIXNM_UTILITY.INDEXVARCHAR1List,');
    li(fp('x_data_source_list')||'OUT    NOCOPY HZ_MIXNM_UTILITY.INDEXVARCHAR30List');
    l(') IS');
    li(fp('l_highest_ranked_value')||'INDEXEDVARCHARLIST;');
    li(fp('l_highest_ranked_source')||'HZ_MIXNM_UTILITY.INDEXVARCHAR30List;');
    l('BEGIN');

    IF (i_uq_attribute_name.COUNT = 0 AND i_attribute_name_date.COUNT = 0) THEN
      li('NULL;');
    ELSE
      li('IF p_new_data_source <> ''SST'' AND');
      li('   p_new_value_is_null_list.COUNT > 0 AND');
      li('   p_updateable_flag_list.COUNT > 0');
      li('THEN');
      IF p_entity_name = 'organization' THEN
        li('  selectOrgHighestRankedValue(');
      ELSE
        li('  selectPerHighestRankedValue(');
      END IF;
      li('    p_party_id                => p_new_rec.party_rec.party_id,');
      li('    x_highest_ranked_value    => l_highest_ranked_value,');
      li('    x_highest_ranked_source   => l_highest_ranked_source);');
      li('END IF;');

      FOR i IN 1..i_uq_attribute_name.COUNT LOOP
        li('IF p_updateable_flag_list.EXISTS('||i_uq_entity_attr_id(i)||') AND');
        li('   p_updateable_flag_list('||i_uq_entity_attr_id(i)||') = ''Y''');
        li('THEN');
        li('  IF p_new_data_source <> ''SST'' AND');
        li('     p_new_value_is_null_list.EXISTS('||i_uq_entity_attr_id(i)||') AND');
        li('     p_new_value_is_null_list('||i_uq_entity_attr_id(i)||') = ''Y'' AND');
        li('     p_exception_type_list.EXISTS('||i_uq_entity_attr_id(i)||') AND');
        li('     p_exception_type_list('||i_uq_entity_attr_id(i)||') = ''Migration'' AND');
        li('     l_highest_ranked_source.EXISTS('||i_uq_entity_attr_id(i)||')');
        li('  THEN');
        li('    p_sst_rec.'||LOWER(i_uq_attribute_name(i))||
           ' := l_highest_ranked_value('||i_uq_entity_attr_id(i)||');');
        li('    x_data_source_list('||i_uq_entity_attr_id(i)||')'||
           ' := l_highest_ranked_source('||i_uq_entity_attr_id(i)||');');
        li('  ELSE');
        li('    p_sst_rec.'||LOWER(i_uq_attribute_name(i))||
           ' := p_new_rec.'||LOWER(i_uq_attribute_name(i))||';');
        li('  END IF;');
        li('END IF;');

        IF i_uq_attribute_name(i) = 'SIC_CODE' THEN
          l_index1 := i;
        ELSIF i_uq_attribute_name(i) = 'SIC_CODE_TYPE' THEN
          l_index2 := i;
        END IF;
      END LOOP;

      -- sic_code and sic_code_type are either both unrestricted or both
      -- restricted.

      IF l_index1 > 0 OR l_index2 > 0 THEN
        l('');
        li('-- sync. sic_code and sic_code_type ');
        l('');
        li('IF p_updateable_flag_list.EXISTS('||i_uq_entity_attr_id(l_index1)||') AND');
        li('   p_updateable_flag_list('||i_uq_entity_attr_id(l_index1)||') = ''Y'' AND');
        li('   (NOT p_updateable_flag_list.EXISTS('||i_uq_entity_attr_id(l_index2)||') OR');
        li('    p_updateable_flag_list('||i_uq_entity_attr_id(l_index2)||') = ''N'')');
        li('THEN');
        li('  p_updateable_flag_list('||i_uq_entity_attr_id(l_index2)||') := ''Y'';');
        li('  IF p_exception_type_list.EXISTS('||i_uq_entity_attr_id(l_index1)||') THEN');
        li('    p_exception_type_list('||i_uq_entity_attr_id(l_index2)||
           ') := p_exception_type_list('||i_uq_entity_attr_id(l_index1)||');');
        li('  END IF;');
        li('  IF x_data_source_list.EXISTS('||i_uq_entity_attr_id(l_index1)||') THEN');
        li('    x_data_source_list('||i_uq_entity_attr_id(l_index2)||
           ') := x_data_source_list('||i_uq_entity_attr_id(l_index1)||');');
        li('  END IF;');
        li('  p_sst_rec.'||LOWER(i_uq_attribute_name(l_index2))||
           ' := p_new_rec.'||LOWER(i_uq_attribute_name(l_index2))||';');
        li('END IF;');
        li('IF p_updateable_flag_list.EXISTS('||i_uq_entity_attr_id(l_index2)||') AND');
        li('   p_updateable_flag_list('||i_uq_entity_attr_id(l_index2)||') = ''Y'' AND');
        li('   (NOT p_updateable_flag_list.EXISTS('||i_uq_entity_attr_id(l_index1)||') OR');
        li('    p_updateable_flag_list('||i_uq_entity_attr_id(l_index1)||') = ''N'')');
        li('THEN');
        li('  p_updateable_flag_list('||i_uq_entity_attr_id(l_index1)||') := ''Y'';');
        li('  IF p_exception_type_list.EXISTS('||i_uq_entity_attr_id(l_index2)||') THEN');
        li('    p_exception_type_list('||i_uq_entity_attr_id(l_index1)||
           ') := p_exception_type_list('||i_uq_entity_attr_id(l_index2)||');');
        li('  END IF;');
        li('  IF x_data_source_list.EXISTS('||i_uq_entity_attr_id(l_index2)||') THEN');
        li('    x_data_source_list('||i_uq_entity_attr_id(l_index1)||
           ') := x_data_source_list('||i_uq_entity_attr_id(l_index2)||');');
        li('  END IF;');
        li('  p_sst_rec.'||LOWER(i_uq_attribute_name(l_index1))||
           ' := p_new_rec.'||LOWER(i_uq_attribute_name(l_index1))||';');
        li('END IF;');
        l('');
      END IF;

      FOR i IN 1..i_attribute_name_date.COUNT LOOP
-- Bug 4244112 : for date attributes, assign g_miss
--               if the value is NULL.
-- Bug 4201309 : assign g_miss only if it is create flow
	  l_index_date := Get_Index(l_all_attribute_names, i_attribute_name_date(i));
          IF l_data_type(l_index_date) = 'VARCHAR2' THEN
            i_data_type := 'fnd_api.g_miss_char';
          ELSIF l_data_type(l_index_date) = 'NUMBER' THEN
            i_data_type := 'fnd_api.g_miss_num';
          ELSIF l_data_type(l_index_date) = 'DATE' THEN
            i_data_type := 'fnd_api.g_miss_date';
          END IF;
        li('IF p_updateable_flag_list.EXISTS('||i_entity_attr_id_date(i)||') AND');
        li('   p_updateable_flag_list('||i_entity_attr_id_date(i)||') = ''Y''');
        li('THEN');
	li('  IF p_create_update_flag = ''U'' THEN');
        li('     p_sst_rec.'||LOWER(i_attribute_name_date(i))||
           ' := p_new_rec.'||LOWER(i_attribute_name_date(i))||';');
	li('  ELSE');
        li('     p_sst_rec.'||LOWER(i_attribute_name_date(i))||
           ' := nvl(p_new_rec.'||LOWER(i_attribute_name_date(i))||', ' || i_data_type||');');
        li('  END IF;');
        li('END IF;');
      END LOOP;

      li('IF p_new_data_source IN (''SST'', ''USER_ENTERED'') THEN');
      li('  assignNonRestrictedColumns(p_new_rec, p_sst_rec);');
      li('END IF;');
    END IF;

    l('END '||l_procedure_name||';');
    l('');

END Gen_UpdateSSTRecord;

/**
 * PRIVATE PROCEDURE
 *
 * DESCRIPTION
 *
 * MODIFICATION HISTORY
 *
 */

--------------------------------------
-- public procedures and functions
--------------------------------------

/**
 * PROCEDURE Gen_PackageForConc
 *
 * DESCRIPTION
 *     Generate package HZ_MIXNM_CONC_DYNAMIC_PKG for mix-n-match
 *     concurrent program.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *      p_package_name               Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang    o Created
 */

PROCEDURE Gen_PackageForConc (
    p_package_name                   IN     VARCHAR2
) IS


BEGIN

    -- new a package body object
    HZ_GEN_PLSQL.new(p_package_name, 'PACKAGE BODY');

    Load_AllAttrAndGroup;

    Gen_PackageHeader(p_package_name);

    Gen_CommonProceduresForConc;

    Gen_BulkCreateSST('organization', 'Bulk');
    Gen_BulkUpdateSST('organization', 'Bulk');

    Gen_BulkCreateSST('person', 'Bulk');
    Gen_BulkUpdateSST('person', 'Bulk');

    --  generate procedures for data import
    Gen_BulkCreateSST('organization', 'Import');
    Gen_BulkUpdateSST('organization', 'Import');

    Gen_BulkCreateSST('person', 'Import');
    Gen_BulkUpdateSST('person', 'Import');

    Gen_PackageTail(p_package_name);

    -- compile the package.
    HZ_GEN_PLSQL.compile_code;

END Gen_PackageForConc;

/**
 * PROCEDURE Gen_PackageForAPI
 *
 * DESCRIPTION
 *     Generate package HZ_MIXNM_API_DYNAMIC_PKG for
 *     mix-n-match API.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *      p_package_name              Package name.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-01-2002    Jianying Huang   o Created
 */

PROCEDURE Gen_PackageForAPI (
    p_package_name                  IN     VARCHAR2
) IS
BEGIN

    -- new a package body object
    HZ_GEN_PLSQL.new(p_package_name, 'PACKAGE BODY');

    Load_AllAttrAndGroup;

    Gen_PackageHeader(p_package_name);

    Gen_CommonProceduresForAPI;

    Gen_UpdateSSTRecord('organization');
    Gen_UpdateSSTRecord('person');

    Gen_PackageTail(p_package_name);

    -- compile the package.
    HZ_GEN_PLSQL.compile_code;

END Gen_PackageForAPI;

/*
PROCEDURE Gen_CodeForDQM (
    p_entity_name                IN     VARCHAR2
) IS
BEGIN

    li('  write_log(''Process DQM ...'');');
    l('');
    li('  -- DQM is current available on this site. we need');
    li('  -- to update interface table so the affected parties');
    li('  -- can be picked up when DQM concurrent program starts');
    li('  -- to run. DQM concurrent program is scheduled to run');
    li('  -- periodically.');
    l('');
    li('  FORALL i IN 1..i_party_id.COUNT');
    li('    INSERT INTO hz_dqm_sync_interface (');
    li('      party_id,');
    li('      record_id,');
    li('      entity,');
    li('      operation,');
    li('      staged_flag,');
    Gen_CodeForWhoColumns('I','LIST',g_indent||'      ','N');
    l('');
    li('    ) ');

    IF p_entity_name = 'organization' THEN
      li('    VALUES (');
      li('      i_party_id(i),');
      li('      NULL, ');
      li('      ''PARTY'',');
      li('      ''U'',');
      li('      ''N'',');
      Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','N');
      l('');
      li('    );');
    ELSE
      li('    SELECT');
      li('      i_party_id(i),');
      li('      NULL,');
      li('      ''PARTY'',');
      li('      ''U'',');
      li('      ''N'',');
      Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','N');
      l('');
      li('    FROM dual');
      li('    UNION');
      li('    SELECT');
      li('      i_party_id(i),');
      li('      org_contact_id,');
      li('      ''CONTACTS'',');
      li('      ''U'',');
      li('      ''N'',');
      Gen_CodeForWhoColumns('I','VALUE',g_indent||'      ','N');
      l('');
      li('    FROM hz_party_relationships pr, ');
      li('         hz_org_contacts oc');
      li('    WHERE pr.party_relationship_id = oc.party_relationship_id');
      li('    AND pr.subject_id = i_party_id(i);');
    END IF;
    l('');
    li('  write_log(''Processed ''||SQL%ROWCOUNT||'' records.'');');
    l('');

END Gen_CodeForDQM;
*/

END HZ_MIXNM_DYNAMIC_PKG_GENERATOR;

/
