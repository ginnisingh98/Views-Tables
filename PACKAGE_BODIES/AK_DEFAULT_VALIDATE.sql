--------------------------------------------------------
--  DDL for Package Body AK_DEFAULT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_DEFAULT_VALIDATE" AS
/* $Header: akdefvlb.pls 120.2 2005/09/29 13:59:39 tshort ship $ */
--****************************************************************
--CREATE PACKAGES
--****************************************************************
  PROCEDURE create_packages(
    P_package_type IN VARCHAR2,
    P_database_object_name IN VARCHAR2,
    P_region_application_id IN NUMBER,
    P_region_code IN VARCHAR2)
  IS
    l_database_object_name      VARCHAR2(30);
    l_number_found              INTEGER;

    -- The following SQL is used to determine if any APIs are defined for object. If
    -- no APIs then exit.
    CURSOR l_object_api_csr(db_obj_name VARCHAR2) IS
      select count(*)
      from
        ak_objects ao,
        ak_object_attributes aoa
      where
        ao.database_object_name = db_obj_name and
        aoa.database_object_name = db_obj_name and
        ((ao.defaulting_api_pkg is not null and
         ao.defaulting_api_proc is not null)
          or
        (ao.validation_api_pkg is not null and
         ao.validation_api_proc is not null)
          or
        (aoa.defaulting_api_pkg is not null and
         aoa.defaulting_api_proc is not null)
          or
        (aoa.validation_api_pkg is not null and
         aoa.validation_api_proc is not null));


    -- The following SQL is used to determine if any APIs are defined for region. If
    -- no APIs then exit.
    CURSOR l_region_api_csr(db_reg_id   NUMBER,
                            db_reg_code VARCHAR2) IS
      select count(*), max(ar.database_object_name)
      from
        ak_regions ar,
        ak_region_items ari
      where
        ar.region_application_id = db_reg_id and
        ar.region_code = db_reg_code and
        ari.region_application_id = db_reg_id and
        ari.region_code = db_reg_code and
        ((ar.region_defaulting_api_pkg is not null and
         ar.region_defaulting_api_proc is not null)
          or
        (ar.region_validation_api_pkg is not null and
         ar.region_validation_api_proc is not null)
          or
        (ari.region_defaulting_api_pkg is not null and
         ari.region_defaulting_api_proc is not null)
          or
        (ari.region_validation_api_pkg is not null and
         ari.region_validation_api_proc is not null));

  BEGIN
    -- Check if there are any APIs defined. If not then exit immediately.
    -- We must handle the following special cases:
    -- 1) Only the object has API's defined, none for regions. Thus
    --    we must create a package for the object but not the region.
    -- 2) Only region has API's defined, none for object. But we
    --    must create packages for BOTH the object and the region. To
    --    be safe we will recreate the object package since it may not
    --    have been created when the object was defined.
    IF P_package_type = 'OBJECT' THEN
      OPEN l_object_api_csr(P_database_object_name);
      FETCH l_object_api_csr INTO l_number_found;
      CLOSE l_object_api_csr;
      IF l_number_found > 0 THEN
        create_record_package(
          'OBJECT',
          P_database_object_name,
          NULL,
          NULL);
      END IF;
    ELSE
      OPEN l_region_api_csr(P_region_application_id,
                            P_region_code);
      FETCH l_region_api_csr INTO l_number_found, l_database_object_name;
      CLOSE l_region_api_csr;
      IF l_number_found > 0 THEN
        create_record_package(
          'OBJECT',
          l_database_object_name,
          NULL,
          NULL);
        create_record_package(
          'REGION',
          NULL,
          P_region_application_id,
          P_region_code);
      END IF;
    END IF;

  END create_packages;


--****************************************************************
--CREATE RECORD PACKAGE
--****************************************************************
  PROCEDURE create_record_package(
    P_package_type IN VARCHAR2,
    P_database_object_name IN VARCHAR2,
    P_region_application_id IN NUMBER,
    P_region_code IN VARCHAR2)
  IS
    l_create_csr                INTEGER;
    l_rows_processed            INTEGER;
    l_database_object_name      VARCHAR2(30);
    l_region_application_id     NUMBER;
    l_region_code               VARCHAR2(30);
    l_attribute_name            VARCHAR2(60);
    l_data_type                 VARCHAR2(30);
    l_missing_const             VARCHAR2(30);
    l_package_name              VARCHAR2(90);
    l_region_note               VARCHAR2(240);
    l_sql_string1               LONG(32000);
    l_sql_string2               LONG(32000);
    l_first_attribute           BOOLEAN := TRUE;
    l_one_attribute_found       BOOLEAN := FALSE;

    -- Yes, Yes, it's a kludge -- but it works well thank you. Based upon the
    -- above input parameters, either the top or bottom select statement will
    -- return rows, but not both. If the P_package_type is OBJECT then we get
    -- attributes from ak_object_attributes. If REGION then we get the attributes
    -- from ak_region_items. This allows the following program to reference
    -- only one cursor for both types.
    CURSOR l_csr( db_obj_name VARCHAR2,
                      db_reg_id NUMBER,
                      db_reg_code VARCHAR2) IS
      select  aa.attribute_application_id,
              aa.attribute_code,
              aa.data_type,
              aa.attribute_value_length
      from    ak_object_attributes aoa,
              ak_attributes aa
      where   aoa.database_object_name = db_obj_name and
              aoa.attribute_application_id = aa.attribute_application_id and
              aoa.attribute_code = aa.attribute_code
    union all
      select  aa.attribute_application_id,
              aa.attribute_code,
              aa.data_type,
              aa.attribute_value_length
      from    ak_region_items ari,
              ak_attributes aa
      where   ari.region_application_id = db_reg_id and
              ari.region_code = db_reg_code and
              ari.attribute_application_id = aa.attribute_application_id and
              ari.attribute_code = aa.attribute_code and
              upper(ari.object_attribute_flag) = 'N';

  BEGIN
    -- Define if we are creating a package for an object or a region. If object, then
    -- only the parameter P_database_object_name is allowed. If region then
    -- P_database_object_name must be NULL. Likewise for region.
    IF P_package_type = 'OBJECT' THEN
      l_package_name          := '"' || trunc_name('AK$' || P_database_object_name, 0, 'F')    || '"';
      l_database_object_name  := P_database_object_name;
      l_region_code           := NULL;
      l_region_application_id := NULL;
    ELSE
      l_package_name          := '"' || trunc_name('AK$' || P_region_code,
                                                   P_region_application_id,
                                                   'T') || '"';
      l_database_object_name  := NULL;
      l_region_code           := P_region_code;
      l_region_application_id := P_region_application_id;
    END IF;

    -- Add a note for the region record structre. It will only contain attributes that are
    -- mark with the flag "object_attribute_flag=Y".
    IF P_package_type = 'REGION' THEN
      l_region_note := '
'||'/*Note: The region record structure will only'        ||'
'||'  contain attributes that have been marked'           ||'
'||'  object_attribute_flag = ''N''. Use the object'      ||'
'||'  record structure for all other attributes.*/';
    END IF;

    -- Define package spec and record name.
    l_sql_string1 := 'CREATE OR REPLACE PACKAGE ' || l_package_name ||' AS ' || l_region_note ||'
'||'  TYPE REC IS RECORD ('                                 ||'
';

    -- Define package body.
    l_sql_string2 := 'CREATE OR REPLACE PACKAGE BODY ' || l_package_name ||' AS '|| l_region_note ||'
'||'  PROCEDURE DEFAULT_MISSING('||'
'||'     P_REC	IN OUT REC)'||'
'||'  IS' ||'
'||'  BEGIN'||'
';

    -- Query database for attributes.
    FOR l_rec IN l_csr(l_database_object_name, l_region_application_id, l_region_code) LOOP
      l_attribute_name := '"' || trunc_name(l_rec.attribute_code, l_rec.attribute_application_id, 'T') || '"';
      l_data_type := upper(rtrim(l_rec.data_type));


      IF l_data_type <> 'URL' THEN
	l_one_attribute_found := TRUE;
        -- Define each element in record structure.
        IF l_first_attribute THEN
          l_first_attribute := false;
        ELSE
          l_sql_string1 := l_sql_string1 || ', ' ||'
';
        END IF;
        l_sql_string1 := l_sql_string1 || '    ' || l_attribute_name || ' ';
        IF l_data_type = 'VARCHAR2' THEN
          l_sql_string1 := l_sql_string1 || 'VARCHAR(' || to_char(l_rec.attribute_value_length) || ')';
        ELSIF l_data_type = 'DATETIME' THEN
          l_sql_string1 := l_sql_string1 || 'DATE';
        ELSIF l_data_type = 'BOOLEAN' THEN
          l_sql_string1 := l_sql_string1 || 'VARCHAR2(1)';
        ELSE
          l_sql_string1 := l_sql_string1 || l_data_type;
        END IF;


        -- Define each statement in the procedure "DEFAULT_MISSING".
        IF instr(l_data_type, 'CHAR') > 0 THEN
          l_missing_const := 'G_MISS_CHAR';
        ELSIF l_data_type = 'NUMBER' THEN
          l_missing_const := 'G_MISS_NUM';
        ELSIF l_data_type = 'DATE' THEN
          l_missing_const := 'G_MISS_DATE';
        END IF;
        l_sql_string2 := l_sql_string2                                                        ||
                         '    P_REC.' || l_attribute_name                                     ||
                         ' := FND_API.' || l_missing_const || ';'               ||'
';
      END IF;

    END LOOP;

    -- If strings are blank, then no attributes were found for object/region. This may or
    -- or may not be OK. For the object, this doesn't make sense, but region may make
    -- sense if there are no attributes marked as "object_attribute_flag=N". In either case
    -- add comments to inform user and a dummy variable so package will compile.
    IF not l_one_attribute_found THEN
      IF P_package_type = 'OBJECT' THEN
        l_sql_string1 := l_sql_string1||'    /* WARNING: No object attributes were found.*/ '||'
';
        l_sql_string2 := l_sql_string2||'    /* WARNING: No object attributes were found.*/ '||'
';
      ELSE
        l_sql_string1 := l_sql_string1||
			'    /* NOTE: No region items were found with object_attribute_flag = ''N''.*/'||'
';
        l_sql_string2 := l_sql_string2||
			'    /* NOTE: No region items were found with object_attribute_flag = ''N''.*/'||'
';
      END IF;
      l_sql_string1 := l_sql_string1                                                        ||
                       '    DUMMY VARCHAR2(1)';
      l_sql_string2 := l_sql_string2||
			'    P_REC.DUMMY := FND_API.G_MISS_CHAR;'||'
';
    END IF;


    -- Complete package spec.
    l_sql_string1 := l_sql_string1||');'||'
'|| '  PROCEDURE DEFAULT_MISSING (P_REC IN OUT REC);'||'
'||'END;';

    -- Complete package body.
    l_sql_string2 := l_sql_string2|| '  END;' ||'
'||'END;';


--update ldh set s=l_sql_string1;
--commit;

    l_create_csr := dbms_sql.open_cursor;

    -- Issue a dynamic SQL statement to create/recreate spec.
    dbms_sql.parse(l_create_csr, l_sql_string1, dbms_sql.v7);
    l_rows_processed := dbms_sql.execute(l_create_csr);

    -- Issue a dynamic SQL statement to create/recreate body.
    dbms_sql.parse(l_create_csr, l_sql_string2, dbms_sql.v7);
    l_rows_processed := dbms_sql.execute(l_create_csr);

    dbms_sql.close_cursor(l_create_csr);

    -- Generic exception trap.
    exception
      when others then
        dbms_sql.close_cursor(l_create_csr);
        raise;

  END create_record_package;


--****************************************************************
--API SHELL
--****************************************************************
  PROCEDURE api_shell (
    p_source_type           IN VARCHAR2,
    p_cur_attribute_appl_id IN NUMBER,
    p_cur_attribute_code    IN VARCHAR2,
    p_object_validation_api IN VARCHAR2,
    p_object_defaulting_api IN VARCHAR2,
    p_object_name           IN VARCHAR2,
    p_region_validation_api IN VARCHAR2,
    p_region_defaulting_api IN VARCHAR2,
    p_region_appl_id        IN NUMBER,
    p_region_code           IN VARCHAR2,
    p_structure             IN OUT NOCOPY VARCHAR2,
    p_data                  IN OUT NOCOPY VARCHAR2,
    p_attr_num              IN NUMBER,
    p_status                OUT NOCOPY VARCHAR2,
    p_message               OUT NOCOPY VARCHAR2)
  IS
    ATTR_VALUE_LEN          CONSTANT INTEGER := 240;
    ATTR_DATATYPE_LEN       CONSTANT INTEGER := 4;
    ATTR_SOURCE_LEN         CONSTANT INTEGER := 1;
    ATTR_CODE_LEN           CONSTANT INTEGER := 30;
    ATTR_ID_LEN             CONSTANT INTEGER := 10;
    ATTR_SIZE_LEN           CONSTANT INTEGER := 5;
    ATTR_DATE_LEN           CONSTANT INTEGER := 14;
    ATTR_NUMBER_LEN         CONSTANT INTEGER := 20;
    ATTR_CODE_OFFSET        CONSTANT INTEGER := ATTR_ID_LEN;
    ATTR_DATATYPE_OFFSET    CONSTANT INTEGER := ATTR_CODE_OFFSET + ATTR_CODE_LEN;
    ATTR_SOURCE_OFFSET      CONSTANT INTEGER := ATTR_DATATYPE_OFFSET + ATTR_DATATYPE_LEN;
    ATTR_DATALEN_OFFSET     CONSTANT INTEGER := ATTR_SOURCE_OFFSET + ATTR_SOURCE_LEN;
    ATTR_DATAPOS_OFFSET     CONSTANT INTEGER := ATTR_DATALEN_OFFSET + ATTR_SIZE_LEN;
    ATTR_TOTAL_SIZE         CONSTANT INTEGER := ATTR_DATAPOS_OFFSET + ATTR_SIZE_LEN;

    TYPE Attr_Rec_Type IS RECORD
    (value                      VARCHAR2(240),
     data_type                  VARCHAR2(4),
     attribute_source           VARCHAR2(1),
     attribute_id               NUMBER,
     attribute_code             VARCHAR2(30)
    );
    TYPE Attr_Tbl_Type          IS TABLE OF Attr_Rec_Type
                                INDEX BY BINARY_INTEGER;

    l_attr_tbl                  Attr_Tbl_Type;

    l_call_api_csr                    INTEGER;
    l_rows_processed            INTEGER;
    l_temp_number               NUMBER(20,6);
    l_temp_char                 VARCHAR2(240);
    l_temp_date                 DATE;
    l_data_len                  INTEGER;
    l_data_value                VARCHAR2(240);
    l_data_type                 VARCHAR2(4);
    l_data_pos                  INTEGER;
    l_value_number              NUMBER(20);
    l_value_date                DATE;
    l_value_char                VARCHAR2(240);
    l_value_len                 INTEGER;
    l_value_counter             INTEGER;
    l_max_bound_values          INTEGER;
    l_attr_id                   NUMBER;
    l_attr_begin                INTEGER;
    l_attr_code_len             INTEGER;
    l_attr_code                 VARCHAR2(30);
    l_attr_code_w_quotes        VARCHAR2(32);
    l_attr_code_source          VARCHAR2(30);
    l_attr_structure            VARCHAR2(90);
    l_obj_rec_name              VARCHAR2(40);
    l_obj_package_name          VARCHAR2(60);
    l_obj_declaration           VARCHAR2(240);
    l_obj_call_default_missing  VARCHAR2(240);
    l_reg_rec_name              VARCHAR2(40);
    l_reg_package_name          VARCHAR2(60);
    l_rec_name_p                VARCHAR2(30);
    l_reg_declaration           VARCHAR2(240);
    l_reg_param                 VARCHAR2(240);
    l_reg_call_default_missing  VARCHAR2(240);
    l_attr_params               VARCHAR2(240);
    l_validation_api            VARCHAR2(240);
    l_defaulting_api            VARCHAR2(240);
    l_bind_variable             VARCHAR2(10);
    l_sql_call_string1          VARCHAR2(2000);
    l_sql_call_string2          VARCHAR2(2000);
    l_sql_string                LONG(32000);
    l_sql_rec_before            LONG(20000);
    l_sql_rec_after             LONG(20000);
    l_status                    VARCHAR2(1);
    l_message                   VARCHAR2(2000);
    l_status_msg_declaration    VARCHAR2(240);
    l_status_msg_return         VARCHAR2(240);

  BEGIN
--update ldh set s=p_structure, s2=p_data;
--commit;
    -- The following are examples of 'structure' and 'object'
    -- parameters.
    --p_structure :=
    --    '       708ORG_ID                        NUM    O      1'   ||
    --    '       708ORG_NAME                      CHAR   O10   21'   ||
    --    '       708CZ5                           DATE   O     31';
    --p_data :=
    --    '123456              '                                      ||
    --    'Barry Lind'                                                ||
    --    '19580910';


    -- Parse object record structure into sql statement, and
    -- load data into l_attr_tbl table. Then bind the sql
    -- statement to the individual data elements of l_attr_tbl.
    l_obj_rec_name     := trunc_name('rec' || p_object_name, 0, 'F');
    l_reg_rec_name     := trunc_name('rec' || p_region_code, p_region_appl_id, 'T');
    l_attr_begin := 1;
    l_value_counter := 1;


    -- Loop through each attribute defined in structure.
    FOR i IN 1..p_attr_num LOOP
      l_attr_id            := to_number(substr(p_structure, l_attr_begin,
                                             ATTR_ID_LEN));
      l_attr_code          := rtrim(substr(p_structure, l_attr_begin + ATTR_CODE_OFFSET,
                                           ATTR_CODE_LEN));
      l_attr_code_len      := length(l_attr_code);
      l_attr_code_w_quotes := '"' || trunc_name(l_attr_code, l_attr_id, 'T') || '"';
      l_attr_code_source   := substr(p_structure, l_attr_begin + ATTR_SOURCE_OFFSET,
                                     ATTR_SOURCE_LEN);
      l_data_type          := substr(p_structure, l_attr_begin + ATTR_DATATYPE_OFFSET,
                                     ATTR_DATATYPE_LEN);
      l_data_pos           := to_number(substr(p_structure, l_attr_begin + ATTR_DATAPOS_OFFSET,
                                               ATTR_SIZE_LEN));
      l_bind_variable      := ':v' || to_char(l_value_counter);


      -- Calculate size of data.
      IF l_data_type = 'NUM ' THEN
        l_value_len := ATTR_NUMBER_LEN;
      ELSIF l_data_type = 'DATE' THEN
        l_value_len := ATTR_DATE_LEN;
      ELSIF l_data_type = 'CHAR' THEN
        l_value_len := to_number(
                       substr(p_structure, l_attr_begin + ATTR_DATALEN_OFFSET, ATTR_SIZE_LEN));
      END IF;


      -- A value of 'O' is for object and 'R' is for region. This is passed in the structure
      -- from calling program. It determines whether the attribute is to be found on the
      -- object or region record.
      IF l_attr_code_source = 'O' THEN
        l_rec_name_p := l_obj_rec_name || '.';
      ELSE
        l_rec_name_p := l_reg_rec_name || '.';
      END IF;


      -- Build SQL statements that contain references to variables.
      -- First, build SQL statements that assigns values into record before calling API.
      -- Second, build SQL statements that extracts values from record after calling API.
      l_sql_rec_before := l_sql_rec_before                                        ||
                          l_rec_name_p                                            ||
                          l_attr_code_w_quotes || ':='                            ||
                          l_bind_variable || '; ';
      l_sql_rec_after  := l_sql_rec_after                                         ||
                          l_bind_variable || ':='                                 ||
                          l_rec_name_p                                            ||
                          l_attr_code_w_quotes || '; ';


      -- Assign values and datatype into a local table so we will have
      -- a memory structure to 'bind' to, and later know how to build a
      -- set of return parameter strings.
      l_attr_tbl(i).data_type := l_data_type;
      l_attr_tbl(i).attribute_source := l_attr_code_source;
      l_attr_tbl(i).attribute_id := l_attr_id;
      l_attr_tbl(i).attribute_code := l_attr_code;
      l_attr_tbl(i).value := rtrim(substr(p_data, l_data_pos, l_value_len));


      -- Prepare for next attribute.
      l_value_counter := l_value_counter + 1;
      l_attr_begin := l_attr_begin + ATTR_TOTAL_SIZE;

    END LOOP;


    -- Setup SQL string fragments that will be used in following SQL
    -- statement definitions.
    l_status_msg_declaration := 'l_status VARCHAR2(1):=''T''; l_message VARCHAR2(2000); ';
    l_status_msg_return := ':v_status:=l_status; :v_message:=l_message; ';
    l_obj_package_name    := trunc_name('AK$' || p_object_name, 0, 'F');
    l_obj_declaration     := l_obj_rec_name || ' '    || l_obj_package_name || '.REC; ';
    l_obj_call_default_missing := l_obj_package_name || '.DEFAULT_MISSING(' ||
                                  l_obj_rec_name || '); ';
    IF (p_region_validation_api IS NOT NULL) OR (p_region_defaulting_api IS NOT NULL) THEN
      l_reg_package_name    := trunc_name('AK$' || p_region_code, p_region_appl_id, 'T');
      l_reg_declaration     := l_reg_rec_name || ' '    || l_reg_package_name || '.REC; ';
      l_reg_call_default_missing := l_reg_package_name || '.DEFAULT_MISSING(' ||
                                    l_reg_rec_name || '); ';
    END IF;

    -- Build optional attribute parameters. These are used if the
    -- validation and defaulting is called at the attribute or item level.
    IF p_cur_attribute_code IS NOT NULL THEN
      l_attr_params :=  p_cur_attribute_appl_id || ',''' || p_cur_attribute_code || '''';
    ELSE
      l_attr_params := '';
    END IF;


    -- Build call interfaces to API. Either API routine is optional so
    -- we must skip the call if NULL.

    IF p_source_type = 'REGION/OBJECT DEFAULTING' THEN
      IF p_object_defaulting_api IS NOT NULL THEN
        l_sql_call_string1 :=
           p_object_defaulting_api || '(' || l_obj_rec_name || '); ';
      END IF;
      IF p_region_defaulting_api IS NOT NULL THEN
        l_sql_call_string2 :=
           p_region_defaulting_api || '(' || l_obj_rec_name || ', '               ||
                                             l_reg_rec_name || '); ';
      END IF;

    ELSIF p_source_type = 'OBJECT ATTRIBUTE VALIDATION/DEFAULTING' THEN
      IF p_object_validation_api IS NOT NULL THEN
        l_sql_call_string1 :=
           p_object_validation_api || '(' || l_obj_rec_name || ', '               ||
                                             l_attr_params  || ','                ||
                                            'l_status, l_message); ';
      END IF;
      IF p_object_defaulting_api IS NOT NULL THEN
       l_sql_call_string2 :=
          'IF l_status = ''T'' THEN '                                             ||
             p_object_defaulting_api || '(' || l_obj_rec_name || ', '             ||
                                               l_attr_params  || '); '            ||
          'END IF; ';
      END IF;

    ELSIF p_source_type = 'REGION ITEM VALIDATION/DEFAULTING' THEN
      IF p_region_validation_api IS NOT NULL THEN
        l_sql_call_string1 :=
           p_region_validation_api || '(' || l_obj_rec_name || ', '               ||
                                             l_reg_rec_name || ', '               ||
                                             l_attr_params  || ','                ||
                                            'l_status, l_message); ';
      END IF;
      IF p_region_defaulting_api IS NOT NULL THEN
        l_sql_call_string2 :=
          'IF l_status = ''T'' THEN '                                             ||
             p_region_defaulting_api || '(' || l_obj_rec_name || ', '             ||
                                               l_reg_rec_name || ', '             ||
                                               l_attr_params  || '); '            ||
          'END IF; ';
      END IF;

    ELSIF p_source_type = 'REGION/OBJECT VALIDATION' THEN
      IF p_object_validation_api IS NOT NULL THEN
        l_sql_call_string1 :=
           p_object_validation_api || '(' || l_obj_rec_name || ', '               ||
                                            'l_status, l_message); ';
      END IF;
      IF p_region_validation_api IS NOT NULL THEN
        l_sql_call_string2 :=
          'IF l_status = ''T'' THEN '                                             ||
             p_region_validation_api || '(' || l_obj_rec_name || ', '             ||
                                               l_reg_rec_name || ', '             ||
                                              'l_status, l_message); '            ||
          'END IF; ';
      END IF;

    END IF;



    -- Build dynamic sql statement to call the APIs.
    l_sql_string :=
      'DECLARE '                                                                  ||
         l_status_msg_declaration                                                 ||
         l_reg_declaration                                                        ||
         l_obj_declaration                                                        ||
      'BEGIN '                                                                    ||
         l_obj_call_default_missing                                               ||
         l_reg_call_default_missing                                               ||
         l_sql_rec_before                                                         ||
         l_sql_call_string1                                                       ||
         l_sql_call_string2                                                       ||
         l_sql_rec_after                                                          ||
         l_status_msg_return                                                      ||
      'END;';

--update ldh set s=l_sql_string;
--commit;

    l_call_api_csr := dbms_sql.open_cursor;
    dbms_sql.parse(l_call_api_csr, l_sql_string, dbms_sql.v7);

    -- Bind the variables v1..v'99' to sql string.
    FOR i IN 1..p_attr_num LOOP
      IF l_attr_tbl(i).data_type = 'NUM ' THEN
        dbms_sql.bind_variable(l_call_api_csr,
                               'v'||to_char(i),
                               to_number(l_attr_tbl(i).value));
      ELSIF l_attr_tbl(i).data_type = 'CHAR' THEN
        dbms_sql.bind_variable(l_call_api_csr,
                               'v'||to_char(i),
                               l_attr_tbl(i).value,
                               ATTR_VALUE_LEN);
      ELSIF l_attr_tbl(i).data_type = 'DATE' THEN
        dbms_sql.bind_variable(l_call_api_csr,
                               'v'||to_char(i),
                               to_date(l_attr_tbl(i).value, 'YYYYMMDDHH24MISS'));
      END IF;
    END LOOP;

    -- Bind the variables v_status and v_message to sql string.
    dbms_sql.bind_variable(l_call_api_csr, 'v_status', l_status, 1);
    dbms_sql.bind_variable(l_call_api_csr, 'v_message', l_message, 2000);

    -- Call APIs.
    l_rows_processed := dbms_sql.execute(l_call_api_csr);

    -- Return variables v_status and v_message.
    dbms_sql.variable_value(l_call_api_csr, 'v_status', l_status);
    dbms_sql.variable_value(l_call_api_csr, 'v_message', l_message);
    p_status := l_status;
    p_message := l_message;


    -- Build return structure and data parameters.
    IF (l_status = 'T') AND
       (p_source_type <> 'REGION/OBJECT VALIDATION') THEN
      p_structure := '';
      p_data := '';
      l_data_pos := 1;
      FOR i IN 1..p_attr_num LOOP
        l_attr_structure := rpad(to_char(l_attr_tbl(i).attribute_id), ATTR_ID_LEN) ||
                            rpad(l_attr_tbl(i).attribute_code, ATTR_CODE_LEN)      ||
                            l_attr_tbl(i).data_type                                ||
                            l_attr_tbl(i).attribute_source;
        IF l_attr_tbl(i).data_type = 'NUM ' THEN
          dbms_sql.variable_value(l_call_api_csr, 'v'||to_char(i), l_temp_number);
          l_attr_structure := l_attr_structure || '     ';
          l_data_len := ATTR_NUMBER_LEN;
          l_data_value := rpad(nvl(to_char(l_temp_number),' '), ATTR_NUMBER_LEN);
        ELSIF l_attr_tbl(i).data_type = 'CHAR' THEN
          dbms_sql.variable_value(l_call_api_csr, 'v'||to_char(i), l_temp_char);
          l_temp_char := rtrim(ltrim(l_temp_char));
          l_data_len := nvl(length(l_temp_char), 0);
         l_attr_structure := l_attr_structure || lpad(to_char(l_data_len), ATTR_SIZE_LEN);
          l_data_value := l_temp_char;
        ELSIF l_attr_tbl(i).data_type = 'DATE' THEN
          dbms_sql.variable_value(l_call_api_csr, 'v'||to_char(i), l_temp_date);
          l_attr_structure := l_attr_structure || '     ';
          l_data_len := ATTR_DATE_LEN;
          l_data_value := rpad(nvl(to_char(l_temp_date, 'YYYYMMDDHH24MISS'),' '), ATTR_DATE_LEN);
        END IF;
        l_attr_structure := l_attr_structure || lpad(to_char(l_data_pos), ATTR_SIZE_LEN);
        l_data_pos := l_data_pos + l_data_len;
        p_structure := p_structure || l_attr_structure;
        p_data := p_data || l_data_value;
      END LOOP;
    END IF;

  dbms_sql.close_cursor(l_call_api_csr);

  -- Generic exception trap.
  exception
    when others then
      l_message :=
'ERROR

 Error          = ' || sqlerrm                          || '
 Call Type      = ' || p_source_type                    || '
 Attribute Code = ' || p_cur_attribute_code             || '
 Attr Appl Id   = ' || to_char(p_cur_attribute_appl_id) || '
 Object Record  = ' || l_obj_rec_name                   || '
 Region Record  = ' || l_reg_rec_name                   || '
 API Call 1     = ' || l_sql_call_string1               || '
 API Call 2     = ' || l_sql_call_string2;
      p_message := l_message;

      p_status := 'E';
      dbms_sql.close_cursor(l_call_api_csr);

  END api_shell;


--****************************************************************
--TRUNC NAME
--****************************************************************
  FUNCTION trunc_name (
    p_name                      IN VARCHAR2,
    p_id                        IN NUMBER,
    p_include_number            IN VARCHAR2)
  RETURN VARCHAR2 IS
    l_id_char                   VARCHAR2(30);
    l_id_size                   NUMBER;
    l_max_name_size             NUMBER;
    l_result                    VARCHAR2(60);
  BEGIN
    l_id_char := to_char(p_id);
    l_id_size := length(l_id_char);
    IF p_include_number = 'T' THEN
      l_max_name_size := 30 - l_id_size - 1;
      l_result := substr(rtrim(ltrim(p_name)), 1, l_max_name_size) || '$' || l_id_char;
    ELSE
      l_max_name_size := 30;
      l_result := substr(rtrim(ltrim(p_name)), 1, l_max_name_size);
    END IF;
    RETURN l_result;
  END trunc_name;

END ak_default_validate;

/
