--------------------------------------------------------
--  DDL for Package Body CN_SCA_RULES_ONLINE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_RULES_ONLINE_GEN_PVT" AS
-- $Header: cnvscagb.pls 120.4 2006/03/31 04:24:58 rrshetty noship $

    g_package_name                cn_obj_packages_v.name%TYPE;
    g_org_id                      cn_sca_credit_rules.org_id%TYPE;

PROCEDURE get_min ( p_min IN OUT NOCOPY number, p_max number) IS
BEGIN
   IF p_min =0 and p_max <> 0 THEN
      p_min := p_max;
    ELSIF p_min <> 0 and p_max <> 0 THEN
      IF p_min > p_max THEN
         p_min := p_max;
      END IF;
   END IF;
END;

-- search the next occurence of delimiter '+ - * / ( ) ' in sql_select portion and return the position
FUNCTION search_delimiter_select ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min         NUMBER ;
     l_position         NUMBER;
BEGIN
   l_position_min := instr( p_input_str, '*', p_start) ;
   l_position := instr(p_input_str, '-', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '+', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '/', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, '(', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, ')', p_start);
   get_min(l_position_min, l_position);

   l_position := instr(p_input_str, ',', p_start);
   get_min(l_position_min, l_position);

   return l_position_min;
END;


-- search the next occurence of delimiter ', ' in sql_from portion and return the position
FUNCTION search_delimiter_from ( p_input_str varchar2, p_start  number) RETURN
  NUMBER IS
     l_position_min        number :=0;
     l_position          NUMBER;
BEGIN
   l_position := instr(p_input_str, ',', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END;

-- search the next occurence of delimiter 'and ' in sql_where portion and return the position
FUNCTION search_delimiter_where ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min        number :=0;
     l_position         NUMBER;
BEGIN
   l_position := instr(p_input_str, 'and', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END;

-- search the next occurence of delimiter empty space in COMMENT and return the position
FUNCTION search_delimiter_comment ( p_input_str varchar2, p_start number)
  RETURN  number IS
     l_position_min        number :=0;
     l_position         NUMBER;
BEGIN
   l_position := instr(p_input_str, ' ', p_start);
   get_min(l_position_min, l_position);
   return l_position_min;
END search_delimiter_comment ;


-- split the long sql statement into pieces less than 80 characters and return the position
PROCEDURE split_long_sql ( body_code        IN OUT NOCOPY cn_utils.code_type,
                           p_input_str      VARCHAR2  ,
                           sql_type   VARCHAR2        )
  IS
     l_length NUMBER;    /* total length of input string */
     l_start  NUMBER;    /* the start position of current split */
     l_next   NUMBER;    /* position of next delimiter */
     l_next_prev NUMBER; /* position of previous delimiter */
     l_limit  NUMBER;    /* the upper boundary of current split */

     l_sql_segment_length NUMBER := 80;
BEGIN

   DBMS_APPLICATION_INFO.SET_ACTION('inside SPLIT LONG ' );
   l_start := 1;
   l_limit := l_start + l_sql_segment_length;

   l_length := Length(p_input_str);
   l_next := l_start;
   l_next_prev := l_start;

   WHILE l_limit < l_length LOOP
      WHILE l_next < l_limit LOOP

       /* the postion of l_next delimiter is not beyong the upper boudaryyet  */
         l_next_prev := l_next;

         IF sql_type = 'SELECT' THEN
            l_next := search_delimiter_select(p_input_str, l_next_prev+1 );
          ELSIF sql_type = 'FROM' THEN
            l_next := NVL(search_delimiter_from(p_input_str, l_next_prev+1 ),0);
          ELSIF sql_type = 'WHERE' THEN
            l_next := search_delimiter_where(p_input_str, l_next_prev+1 );
          ELSIF sql_type = 'COMMENT' THEN
            l_next := search_delimiter_comment(p_input_str, l_next_prev+1 );
         END IF;

         IF l_next = 0 THEN  /* no more delimiter */
            EXIT;
         END IF;

         IF l_next >= l_limit THEN
           l_next_prev := l_next;
         END IF;


      END LOOP;

      IF sql_type = 'COMMENT' THEN
         cn_utils.appindcr(body_code, '-- ' || substr(p_input_str, l_start,
                           l_next_prev -  l_start) );
       ELSE
         cn_utils.appindcr(body_code, substr(p_input_str, l_start,
                                             l_next_prev - l_start));
      END IF;

      l_start := l_next_prev ;
      l_limit := l_start + l_sql_segment_length;

      IF l_next = 0 THEN  /* no more delimiter */
         EXIT;
      END IF;
   END LOOP;

   IF sql_type = 'COMMENT' THEN
      cn_utils.appindcr(body_code, '--' || substr(p_input_str, l_start,
                        l_length -  l_start  + 1));
    ELSE
      cn_utils.appindcr(body_code, substr(p_input_str, l_start,
                                          l_length - l_start  + 1));
   END IF;
END split_long_sql;



--   Get the object_id in cn_objects for formula, if not exist, create it.
PROCEDURE check_create_object(x_name                cn_objects.name%TYPE,
                              x_object_type        cn_objects.object_type%TYPE,
                              x_object_id        IN OUT NOCOPY cn_objects.object_id%TYPE,
                              x_repository_id cn_repositories.repository_id%TYPE)
  IS
     dummy        NUMBER;
     x_rowid        ROWID;
BEGIN
   -- check whether formula package exist in cn_objects
   SELECT  COUNT(*)
     INTO  dummy
     FROM cn_objects
     WHERE name = x_name
     AND object_type = x_object_type
     AND org_id = g_org_id;

   IF dummy = 0 THEN
      x_object_id := cn_utils.get_object_id;

      cn_objects_pkg.insert_row( x_rowid                   => x_rowid,
                                 x_object_id               => x_object_id,
                                 x_org_id                  => g_org_id,
                                 x_dependency_map_complete => 'N',
                                 x_name                    => x_name,
                                 x_description             => null,
                                 x_object_type             => x_object_type,
                                 x_repository_id           => X_repository_id,
                                 x_next_synchronization_date => null,
                                 x_synchronization_frequency => null,
                                 x_object_status           => 'A',
                                 x_object_value            => NULL );

    ELSIF dummy = 1 THEN
      SELECT  object_id INTO  x_object_id
        FROM  cn_objects
        WHERE  name = x_name
        AND  object_type = x_object_type
	AND org_id = g_org_id;
   END IF;
EXCEPTION WHEN OTHERS THEN
   cn_message_pkg.debug('IN check_create_object Exception handler name is ' || x_name ||
                        ' object_type is '  || x_object_type || ' object_id is ' || x_object_id );
   RAISE;
END check_create_object;

-- initialize the procedure boilerplate
PROCEDURE proc_init_boilerplate (code                IN OUT NOCOPY cn_utils.code_type,
                                 procedure_name                cn_obj_procedures_v.name%TYPE,
                                 description                cn_obj_procedures_v.description%TYPE)
  IS
     X_userid        VARCHAR2(20);
BEGIN
   SELECT user INTO X_userid FROM sys.dual;

   cn_utils.appendcr(code, '--');
   cn_utils.appendcr(code, '-- Procedure Name');
   cn_utils.appendcr(code, '--   ' || procedure_name);
   cn_utils.appendcr(code, '-- Purpose');
   split_long_sql(code, description, 'COMMENT');
   cn_utils.appendcr(code, '-- History');
   cn_utils.appendcr(code, '--   ' || SYSDATE || '          ' || X_userid || '     Created');
   cn_utils.appendcr(code, '--');
END proc_init_boilerplate;

-- initialize the procedure
PROCEDURE proc_init(procedure_name                cn_obj_procedures_v.name%TYPE,
                    description                cn_obj_procedures_v.description%TYPE,
                    parameter_list                cn_obj_procedures_v.parameter_list%TYPE,
                    procedure_type                cn_obj_procedures_v.procedure_type%TYPE,
                    return_type                cn_obj_procedures_v.return_type%TYPE,
                    package_id                cn_obj_procedures_v.package_id%TYPE,
                    repository_id                cn_obj_procedures_v.repository_id%TYPE,
                    spec_code        IN OUT NOCOPY cn_utils.code_type,
                    body_code        IN OUT NOCOPY cn_utils.code_type) IS
BEGIN
    -- Generate boilerplate comments
    proc_init_boilerplate(spec_code, procedure_name, description);
    proc_init_boilerplate(body_code, procedure_name, description);

    -- Generate procedure header and parameters in both spec and body
    IF (procedure_type = 'P') THEN
      IF (parameter_list IS NOT NULL) THEN
         split_long_sql(spec_code, 'PROCEDURE ' || procedure_name ||
                        ' (' || parameter_list || ')', 'FROM');
         split_long_sql(body_code, 'PROCEDURE ' || procedure_name ||
                        ' (' || parameter_list || ')', 'FROM');
      ELSE
         cn_utils.appendcr(spec_code, 'PROCEDURE ' || procedure_name);
         cn_utils.appendcr(body_code, 'PROCEDURE ' || procedure_name);
      END IF;
     ELSIF (procedure_type = 'F') THEN
       IF (parameter_list IS NOT NULL) THEN
          split_long_sql(spec_code, 'FUNCTION ' || procedure_name ||
                         ' (' || parameter_list || ')', 'FROM');
          split_long_sql(body_code, 'FUNCTION ' || procedure_name ||
                         ' (' || parameter_list || ')', 'FROM');
        ELSE
          cn_utils.appendcr(spec_code, 'FUNCTION ' || procedure_name);
          cn_utils.appendcr(body_code, 'FUNCTION ' || procedure_name);
       END IF;
    END IF;

    IF (procedure_type = 'F') THEN
      cn_utils.appendcr(spec_code, ' RETURN ' || return_type);
      cn_utils.appendcr(body_code, ' RETURN ' || return_type);
    END IF;

    cn_utils.appendcr(spec_code, ';');
    cn_utils.appendcr(spec_code);
    cn_utils.appendcr(body_code, ' IS');
END proc_init;


-- create the code of the procedure get_winning rule
PROCEDURE get_winning_rule (spec_code              IN OUT NOCOPY cn_utils.code_type,
                            body_code              IN OUT NOCOPY cn_utils.code_type ,
                            x_transaction_source   IN            cn_sca_rule_attributes.transaction_source%TYPE)
IS
    procedure_name        cn_obj_procedures_v.name%TYPE;
    procedure_desc        cn_obj_procedures_v.description%TYPE;
    parameter_list        cn_obj_procedures_v.parameter_list%TYPE;
    package_spec_id        cn_obj_packages_v.package_id%TYPE;
    x_repository_id        cn_repositories.repository_id%TYPE;
    l_attrib_counter       NUMBER := 1;
    l_rule_counter         NUMBER := 1;

  --    ganesh uncomment out enabled flag .
  CURSOR  cn_sca_rule_attributes IS
    SELECT *
    FROM   cn_sca_rule_attributes csra
    WHERE  transaction_source = x_transaction_source
    -- codeCheck: This condition is not required when inner has it.
    AND    org_id = g_org_id
--    AND    enabled_flag = 'Y'
    AND EXISTS (SELECT 'S'
                  FROM cn_sca_conditions csc
                 WHERE csc.sca_rule_attribute_id = csra.sca_rule_attribute_id
		   AND csc.org_id = g_org_id)  ;

  CURSOR cn_operators (a_sca_rule_attribute_id NUMBER) IS
      SELECT lookup_code,meaning
      FROM   cn_lookups cl
      WHERE  lookup_type = 'SCA_OPERATORS'
      AND EXISTS (SELECT 'x'
		  FROM  cn_sca_conditions csc ,
                        cn_sca_cond_details cscd
		  WHERE csc.sca_condition_id = cscd.sca_condition_id
		  AND   csc.sca_rule_attribute_id = a_sca_rule_attribute_id
		  AND   csc.org_id = g_org_id
                  AND   cscd.OPERATOR_ID     =  cl.lookup_code);


BEGIN
     procedure_name := 'get_winning_rule';
     procedure_desc := 'This procedure is to get matching rules.';
     parameter_list := 'x_sca_batch_id       IN           NUMBER,'  ||
	               'p_org_id             IN           NUMBER,'||
                       'x_return_status      OUT NOCOPY   VARCHAR2,'||
                       'x_msg_count          OUT NOCOPY   NUMBER,'  ||
                       'x_msg_data           OUT NOCOPY   VARCHAR2';

     proc_init(procedure_name, procedure_desc, parameter_list,'P', 'NUMBER' ,
               package_spec_id, x_repository_id,spec_code, body_code);


     cn_utils.appendcr(body_code, ' l_stmt		VARCHAR2(32000); ');
     cn_utils.appendcr(body_code, ' BEGIN ');
     cn_utils.appendcr(body_code, ' x_return_status := FND_API.G_RET_STS_SUCCESS;');
     cn_utils.appendcr(body_code, ' l_stmt  := ');
     cn_utils.appendcr(body_code, '''INSERT INTO cn_sca_winning_rules_gtt (sca_batch_id ,       ''||');
     cn_utils.appendcr(body_code, '''    sca_credit_rule_id,                           ''|| ');
     cn_utils.appendcr(body_code, '''    sca_headers_interface_id,                      ''|| ');
     cn_utils.appendcr(body_code, '''    calculated_rank)                               ''|| ');
/*
     cn_utils.appendcr(body_code, 'SELECT  sca_batch_id,                             ');
     cn_utils.appendcr(body_code, '    matching_rules.sca_credit_rule_id,                   ');
     cn_utils.appendcr(body_code, '    sca_headers_interface_id,                       ');
     cn_utils.appendcr(body_code, '    rule.calculated_rank        ');
     cn_utils.appendcr(body_code, ' FROM  cn_sca_denorm_rules_all rule, (                         ');
*/
     cn_utils.appendcr(body_code, '''            SELECT     sca_batch_id    ,     ''||');
     cn_utils.appendcr(body_code, '''                       sca_credit_rule_id ,                      ''||');
     cn_utils.appendcr(body_code, '''                       sca_headers_interface_id,                 ''||');
     cn_utils.appendcr(body_code, '''                       calculated_rank                           ''||');
     cn_utils.appendcr(body_code, '''       FROM (                                                    ''||');
     cn_utils.appendcr(body_code, '''                SELECT ''||x_sca_batch_id||'' sca_batch_id,            ''||');
     cn_utils.appendcr(body_code, '''                       result.sca_credit_rule_id ,             ''||');
     cn_utils.appendcr(body_code, '''                       result.sca_headers_interface_id,        ''||');
     cn_utils.appendcr(body_code, '''                       result.calculated_rank    ,              ''||');
     cn_utils.appendcr(body_code, '''                            rank() over (partition by result.sca_headers_interface_id ''||');
     cn_utils.appendcr(body_code, '''                        order by result.calculated_rank desc,result.sca_credit_rule_id asc) as rule_rank ''||');
     cn_utils.appendcr(body_code, '''                 FROM (                                        ''||');
     cn_utils.appendcr(body_code, '''                         SELECT cshi.sca_headers_interface_id, ''||');
     cn_utils.appendcr(body_code, '''                                b.sca_credit_rule_id,          ''||');
     cn_utils.appendcr(body_code, '''                                b.calculated_rank              ''||');
     cn_utils.appendcr(body_code, '''                         FROM                                  ''||');
     cn_utils.appendcr(body_code, '''                               (SELECT sca_credit_rule_id,     ''||');
     cn_utils.appendcr(body_code, '''                                       start_date,end_date     ''||');
     cn_utils.appendcr(body_code, '''                                FROM cn_sca_denorm_rules_all   ''||');
     cn_utils.appendcr(body_code, '''                                WHERE sca_credit_rule_id = ancestor_rule_id       ''||');
     cn_utils.appendcr(body_code, '''                                AND org_id = ''||p_org_id||''       ''||');
     cn_utils.appendcr(body_code, '''                                AND transaction_source = '''''||x_transaction_source||''''') a, ''||');
     cn_utils.appendcr(body_code, '''                                cn_sca_rule_cond_vals_mv b,              ''||');
     cn_utils.appendcr(body_code, '''                                cn_sca_headers_interface_gtt cshi        ''|| ');
     cn_utils.appendcr(body_code, '''                         WHERE a.sca_credit_rule_id =                    ''||');
     cn_utils.appendcr(body_code, '''                               b.sca_credit_rule_id                      ''||');
     cn_utils.appendcr(body_code, '''                         AND   cshi.sca_batch_id = ''||x_sca_batch_id ||''                  ''||');
     cn_utils.appendcr(body_code, '''                         AND   cshi.TRANSACTION_SOURCE =  '''''||x_transaction_source||'''''                      ''||');
     cn_utils.appendcr(body_code, '''                                AND cshi.processed_date         ''||');
     cn_utils.appendcr(body_code, '''                                BETWEEN a.start_date AND NVL(a.end_date,cshi.processed_date)       ''||');
     cn_utils.appendcr(body_code, '''                         AND (                                           ''||');

     -- loop for all attributes and generate the necessary or condition.
     FOR attributes in cn_sca_rule_attributes LOOP
             IF l_attrib_counter > 1 THEN
                     cn_utils.appendcr(body_code, '''                         OR ''||');
             END IF;

             cn_utils.appendcr(body_code, ' ''                        ( b.sca_rule_attribute_id ='||attributes.SCA_RULE_ATTRIBUTE_ID||'''||');
             cn_utils.appendcr(body_code,' ''                         AND ( ''||');
             l_rule_counter := 1;
             -- For each attribute loop thru the operators and build the
             -- the operator or conditions.
             FOR operator in cn_operators(attributes.SCA_RULE_ATTRIBUTE_ID) LOOP
                IF l_rule_counter > 1 THEN
                        cn_utils.appendcr(body_code, '''                            OR ''||');
                     END IF;
                IF operator.lookup_code = 'EQUAL' THEN
                   cn_utils.appendcr(body_code, ' ''                           (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, ' ''                             = b.VALUE_CHAR_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                        cn_utils.appendcr(body_code, '  ''                                = b.VALUE_NUM_MIN AND  ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                        cn_utils.appendcr(body_code, ' ''                                 = b.VALUE_DATE_MIN AND ''||');
                   END IF;
                   cn_utils.appendcr(body_code, '''                                     b.operator_id = ''''EQUAL'''') ''||');
                ELSIF operator.lookup_code = 'LIKE' THEN
                   cn_utils.appendcr(body_code, '  ''                            (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, ' ''                            LIKE b.VALUE_CHAR_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                        cn_utils.appendcr(body_code, ' ''                                LIKE b.VALUE_NUM_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                        cn_utils.appendcr(body_code, ' ''                                LIKE b.VALUE_DATE_MIN AND ''||');
                   END IF;
                   cn_utils.appendcr(body_code, '    ''                           b.operator_id = ''''LIKE'''') ''||');
                ELSIF operator.lookup_code = 'BETWEEN' THEN
                   cn_utils.appendcr(body_code, ' ''                            (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, '  ''                            BETWEEN b.VALUE_CHAR_MIN AND b.VALUE_CHAR_MAX AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                           cn_utils.appendcr(body_code, ' ''                             BETWEEN b.VALUE_NUM_MIN AND b.VALUE_NUM_MAX  AND ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                           cn_utils.appendcr(body_code, ' ''                             BETWEEN b.VALUE_DATE_MIN AND b.VALUE_DATE_MAX AND ''||');
                    END IF;
                    cn_utils.appendcr(body_code, ' ''                           b.operator_id = ''''BETWEEN'''') ''||');
                ELSIF operator.lookup_code = 'GRE' THEN
                   cn_utils.appendcr(body_code, ' ''                            (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, ' ''                     >= b.VALUE_CHAR_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                        cn_utils.appendcr(body_code, ' ''                        >= b.VALUE_NUM_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                        cn_utils.appendcr(body_code, '  ''                       >= b.VALUE_DATE_MIN AND ''||');
                   END IF;
                   cn_utils.appendcr(body_code, ' ''                             b.operator_id = ''''GRE'''') ''||');
                ELSIF operator.lookup_code = 'GT' THEN
                   cn_utils.appendcr(body_code, '  ''                           (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, '  ''                   > b.VALUE_CHAR_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                        cn_utils.appendcr(body_code, '  ''                      > b.VALUE_NUM_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                        cn_utils.appendcr(body_code, '  ''                      > b.VALUE_DATE_MIN AND ''||');
                   END IF;
                   cn_utils.appendcr(body_code, '  ''                           b.operator_id = ''''GT'''') ''||');
                ELSIF operator.lookup_code = 'LT' THEN
                   cn_utils.appendcr(body_code, '  ''                          (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, '  ''                    < b.VALUE_CHAR_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                        cn_utils.appendcr(body_code, '  ''                        < b.VALUE_NUM_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                        cn_utils.appendcr(body_code, '  ''                       < b.VALUE_DATE_MIN AND ''||');
                   END IF;
                   cn_utils.appendcr(body_code, ' ''                            b.operator_id = ''''LT'''') ''||');
                ELSIF operator.lookup_code = 'LTE' THEN
                   cn_utils.appendcr(body_code, '    ''                       (cshi.'||attributes.SRC_COLUMN_NAME||'''||');
                   IF attributes.DATATYPE = 'ALPHANUMERIC' THEN
                           cn_utils.appendcr(body_code, ' ''                     <= b.VALUE_CHAR_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'NUMERIC' THEN
                        cn_utils.appendcr(body_code, ' ''                         <=  b.VALUE_NUM_MIN AND ''||');
                   ELSIF attributes.DATATYPE = 'DATE' THEN
                        cn_utils.appendcr(body_code, '  ''                       <=  b.VALUE_DATE_MIN AND ''||');
                   END IF;
                   cn_utils.appendcr(body_code, '  ''                           b.operator_id = ''''LTE'''') ''||');
                END IF;
                l_rule_counter := l_rule_counter +1;
             END LOOP;

             cn_utils.appendcr(body_code, '  ''                                  )''||');
             cn_utils.appendcr(body_code, '  ''                                )''||');
             l_attrib_counter := l_attrib_counter+1;
     END LOOP;

     IF l_attrib_counter = 1 THEN
            cn_utils.appendcr(body_code, '''      (1 = 1)''||');
     END IF;

     cn_utils.appendcr(body_code, ''' )) result''||');
     cn_utils.appendcr(body_code, ''' GROUP BY result.sca_headers_interface_id,result.sca_credit_rule_id, ''||');
     cn_utils.appendcr(body_code, ''' result.calculated_rank                                              ''||');
     cn_utils.appendcr(body_code, ''' HAVING (count(1)) >= (                     ''||');
     cn_utils.appendcr(body_code, '''          SELECT r.num_rule_attributes          ''||');
     cn_utils.appendcr(body_code, '''          FROM cn_sca_denorm_rules r                                 ''||');
     cn_utils.appendcr(body_code, '''          WHERE r.sca_credit_rule_id = result.sca_credit_rule_id     ''||');
     cn_utils.appendcr(body_code, '''          AND r.ancestor_rule_id = result.sca_credit_rule_id         ''||');
     cn_utils.appendcr(body_code, '''          AND r.transaction_source = '''''||x_transaction_source||''''') ''||');
     cn_utils.appendcr(body_code, ''') result1 where rule_rank = 1'';');


      cn_utils.appendcr(body_code, ' EXECUTE IMMEDIATE l_stmt;');

     cn_utils.appindcr(body_code, ' EXCEPTION WHEN OTHERS THEN                                          ');
     cn_utils.appindcr(body_code, '      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;             ');
     cn_utils.appindcr(body_code, '      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)');
     cn_utils.appindcr(body_code, '        THEN                                                         ');
     cn_utils.appindcr(body_code, '         FND_MSG_PUB.Add_Exc_Msg( '''||g_package_name||''' ,''get_winning_rule'');');
     cn_utils.appindcr(body_code, '      END IF;                                                        ');
     cn_utils.appindcr(body_code, '      FND_MSG_PUB.Count_And_Get                                      ');
     cn_utils.appindcr(body_code, '        (p_count   =>  x_msg_count ,                                 ');
     cn_utils.appindcr(body_code, '         p_data    =>  x_msg_data  ,                                 ');
     cn_utils.appindcr(body_code, '         p_encoded => FND_API.G_FALSE                                ');
     cn_utils.appindcr(body_code, '     );                                                              ');
     cn_utils.appindcr(body_code, 'cn_message_pkg.debug(''EXCEPTION IN get_winning_rule, '' || sqlerrm);');
     cn_utils.proc_end( procedure_name, 'N', body_code );

EXCEPTION when others then
     cn_message_pkg.debug('IN get_perf exception handler, error is '||sqlcode||' '||sqlerrm);
     RAISE;

END get_winning_rule;



FUNCTION create_sca_rules_online_dyn
   (x_transaction_source   IN   cn_sca_rule_attributes.transaction_source%TYPE)
    RETURN BOOLEAN IS
    package_name              cn_obj_packages_v.name%TYPE;
    package_type              cn_obj_packages_v.package_type%TYPE := 'FML';
    package_spec_id           cn_obj_packages_v.package_id%TYPE;
    package_body_id           cn_obj_packages_v.package_id%TYPE;
    package_spec_desc         cn_obj_packages_v.description%TYPE;
    package_body_desc         cn_obj_packages_v.description%TYPE;
    spec_code                 cn_utils.code_type;
    body_code                 cn_utils.code_type;
    dummy                     NUMBER(7);
    l_module_id               number(15);
    l_repository_id           cn_repositories.repository_id%TYPE;
    l_org_id                  NUMBER;
BEGIN

    --SELECT repository_id, org_id
    --INTO l_repository_id, l_org_id FROM cn_repositories;

    cn_utils.set_org_id(g_org_id);

    SELECT repository_id INTO l_repository_id FROM cn_repositories;

    package_name := 'cn_sca_rodyn_'|| substr(lower(x_transaction_source),1,8) || '_' || abs(g_org_id) || '_pkg';
    g_package_name := package_name;


    check_create_object(package_name, 'PKS', package_spec_id, l_repository_id);
    check_create_object(package_name, 'PKB', package_body_id, l_repository_id);


    cn_utils.pkg_init(l_module_id, package_name, null, package_type, 'FORMULA',
                   package_spec_id, package_body_id, package_spec_desc,
                   package_body_desc, spec_code, body_code);
    get_winning_rule(spec_code, body_code,x_transaction_source);
    cn_utils.pkg_end(package_name, spec_code, body_code);

    cn_utils.unset_org_id;

    RETURN TRUE;
END;

PROCEDURE gen_sca_rules_onln_dyn
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      p_org_id	              IN  NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      x_transaction_source    IN  cn_sca_rule_attributes.transaction_source%TYPE
      ) IS

    l_api_name                     CONSTANT VARCHAR2(30) := 'gen_sca_rules_onln_dyn';
    l_api_version                  CONSTANT NUMBER :=1.0;
    l_creation_status              BOOLEAN;
    l_request_id                   NUMBER;
    l_file_name                    VARCHAR2(200);
    l_call_status                  BOOLEAN;
    l_dummy                        VARCHAR2(500);
    l_dev_phase                    VARCHAR2(80);
    l_dev_status                   VARCHAR2(80) := 'INCOMPLETE';
    l_status                       BOOLEAN;
    sqlstring                      dbms_sql.varchar2s;
    empty_sqlstring                dbms_sql.varchar2s;
    cursor1                        INTEGER;
    i                              INTEGER;
    j                              INTEGER;
    new_line_flag                  BOOLEAN:=TRUE;
    retval                         NUMBER;
    l_pkg_object_id                NUMBER(15);
    l_error_count                  NUMBER;
    l_pkg_name                     VARCHAR2(100);
    l_org_id                       NUMBER;

BEGIN
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                          p_api_version ,
                                          l_api_name    ,
                                          G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Codes start here

     g_org_id := p_org_id;

     -- SELECT org_id INTO l_org_id FROM cn_repositories;

     l_pkg_name := 'cn_sca_rodyn_'|| substr(lower(x_transaction_source),1,8) || '_' || abs(g_org_id) || '_pkg';

     l_status := create_sca_rules_online_dyn(x_transaction_source);


     IF l_status THEN   /*  created successfully. Continue to install it. */
         SELECT co.object_id
           INTO l_pkg_object_id
           FROM cn_objects co
           WHERE co.name =  l_pkg_name
           AND co.object_type = 'PKS'
           AND co.org_id = g_org_id;

         SELECT cs.text bulk collect INTO sqlstring
           FROM cn_source cs
           WHERE cs.object_id = l_pkg_object_id
           AND cs.org_id = g_org_id
           ORDER BY cs.line_no ;



         i:=1;
         j:= sqlstring.count;

         cursor1:=DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(cursor1,sqlstring,i,j,new_line_flag,DBMS_SQL.V7);
         retval:=DBMS_SQL.EXECUTE(cursor1);
         DBMS_SQL.CLOSE_CURSOR(cursor1);

         sqlstring := empty_sqlstring;

         SELECT co.object_id
           INTO l_pkg_object_id
           FROM cn_objects co
           WHERE co.name =  l_pkg_name --'cn_formula_'|| p_formula_id || '_pkg'
           AND co.object_type = 'PKB'
	   AND co.org_id = g_org_id;



         SELECT cs.text bulk collect INTO sqlstring
           FROM cn_source cs
           WHERE cs.object_id = l_pkg_object_id
           AND cs.org_id = g_org_id
           ORDER BY cs.line_no ;

         i:= 1;
         j:= sqlstring.count;

         cursor1:=DBMS_SQL.OPEN_CURSOR;
         DBMS_SQL.PARSE(cursor1,sqlstring,i,j,new_line_flag,DBMS_SQL.V7);
         retval:=DBMS_SQL.EXECUTE(cursor1);
         DBMS_SQL.CLOSE_CURSOR(cursor1);

         cn_message_pkg.debug('The rule dynamic package is created successfully. Continue to intall the package. ');
         fnd_file.put_line(fnd_file.Log, 'The rule dynamic package is created successfully. Continue to intall the package.');

         -- check whether package is installed successfully
         SELECT  COUNT(*)
           INTO  l_error_count
           FROM user_errors
           WHERE name = upper(l_pkg_name)
           AND  TYPE IN ('PACKAGE', 'PACKAGE BODY');

         IF l_error_count = 0 THEN
            NULL;
         ELSE
            x_return_status := FND_API.g_ret_sts_error;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
               fnd_message.set_name('CN', 'CN_DYN_PKG_COMPILE_ERR');
               FND_MSG_PUB.ADD;
               FND_MSG_PUB.Count_And_Get
	                 (p_count   =>  x_msg_count ,
	                  p_data    =>  x_msg_data  ,
	                  p_encoded => FND_API.G_FALSE
                          );

            END IF;
         END IF;
      ELSE
         x_return_status := FND_API.g_ret_sts_error;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            fnd_message.set_name('CN', 'CN_DYN_PKG_COMPILE_ERR');
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.Count_And_Get
	                 (p_count   =>  x_msg_count ,
	                  p_data    =>  x_msg_data  ,
	                  p_encoded => FND_API.G_FALSE
                          );
         END IF;
      END IF;

      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
        END IF;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
          );

END gen_sca_rules_onln_dyn;
END cn_sca_rules_online_gen_pvt;

/
