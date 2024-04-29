--------------------------------------------------------
--  DDL for Package Body CN_CLASSIFICATION_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CLASSIFICATION_GEN" AS
-- $Header: cnclgenb.pls 120.16 2007/11/26 16:29:43 hanaraya ship $


--
-- Package Body Name
--   cn_classification_gen
-- Purpose
--   This package is used by Oracle Commissions to generate the code for
--   classifying transactions into revenue classes based on certain rules.
-- History
--   12/13/93	Devesh Khatu   Created
--   05-04-95	Amy Erickson   Updated
--   06-06-95	Amy Erickson   Updated
--   06-21-95	Amy Erickson   Updated
--   07-14-95	Peter Cook     Changed classify_batch parameters
--   07-19-95	Amy Erickson   ABS for negative ruleset_id's
--   07-19-95	Amy Erickson   Remove debug_pipe references for PCOOK
--   07-21-95	Amy Erickson   Bug fix. classify BETWEEN statement incorect.
--   07-23-95	Amy Erickson   Bug fix. Classify_batch update code.
--   08-18-95	Amy Erickson   Bug fix. is_descendant_of  routine.
--   09-05-95	Amy Erickson   Bug fix. Output lines were too long.
--   09-18-95	Amy Erickson   Bug fix. Parse value fields for apostrophes.
--   10-31-95	Amy Erickson   Use cn_message_pkg.debug in generated code.
--   01-08-96	Amy Erickson   Updated	cn_mod_obj_depends change
--   01-15-96	Amy Erickson   Updated	changed cn_utils. proc_init.
--   06-27-96	Amy Erickson   Updated	BETWEEN, LTE, GTE all numeric.
--   11-Feb-98       Achung   reference CLIENT_INFO need to use SUBSTRB
--   30-Nov-99  SKhawaja      Commented out classify_line section as it is no longer used.
--                            Changes made to replace periods with Start date and End date.
--   07-Dec-99  SKhawaja      Changes made to procedure attribute_rules and create_attribute_rules_expr
--   20-Dec-99 jpendyal       Made changes to remove references to package CN_COMMISSION_LINES_PKG as it is obsoleted
--   06-Apr-00  SKhawaja      Created procedure Classification_Install
--   09-SEP-00  Kumar	     Added the where clause in the rules_gen cursor
--   09-SEP-00  Kumar	     Modified the rule builder and the expression builder to handle
--			               null in the transaction attribute columns
-- 			               modified the processed_period_id to Processed_date
--			               modified the parameter list of in_descendant_of
--			               column name data type and rollup_value data type
--   29-SEP-00                Modified the Install classification logic to handle more
--						255 characters in the buffer.
--						modified the expr variable from 1900 to 32000
--===========================================================================================================
--   16-AUG-01		      Kumar Sivasankaran , Modified Added the Sequence by Rule_id
--   07-NOV-01 		      Kumar Sivasankaran, Modified Added the GENERATED status at the
--			      end of Classification Install.
--			      Added INSTFAIL at the end of classification Install package.
--   13-FEB-02 		      Kumar Sivasankaran, Modified Added to check the rulesets exists
--   	 		      Delete the cn_objects record before process the classification
--   31-Oct-02		      Introduced clob to accomodate large expression.  To fix the bug# 2579204
--			      methods got updated - attribute_rules,create_attribute_rules_expr,file_header
--						  - package_header,proc_init,rules_recurse_call,rules_recurse_gen
--						  - rules_recurse_assign, revenue_classes
--   07-MAR-2006 SBADAMI      COmmented lines of debug based on the CR / ER# 5019394
--   08-JUN-2006 HANARAYA     Added code under attribute_rules procedure for Date Classification (Bug 5191966)
--===========================================================================================================




-- cached_org_id                integer;
-- cached_org_append            varchar2(100);
g_module_type                cn_rulesets.module_type%type;
--
-- Private Functions and Procedures
--

  --
  -- Procedure Name
  --   attribute_rules
  -- Purpose
  --   This function generates a conditional expression by ANDing all the
  --   attribute rules for the rule X_rule_id
  -- History
  --   12-13-93 	Devesh Khatu		Created
  --   09-19-95 	Amy Erickson		Updated
  --

   PROCEDURE attribute_rules (
	X_rule_id		cn_rules.rule_id%TYPE,
	x_org_id                cn_rules.org_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS

    first_flag		VARCHAR2(1);
    quote		VARCHAR2(1);

    l_dummy             NUMBER := '-1000';
    l_dummy_date VARCHAR2(60):= '01/01/1600';


    x_value		cn_attribute_rules.column_value%TYPE;		--AE 09-18-95
    x_high_value	cn_attribute_rules.high_value%TYPE;	--AE
    x_low_value 	cn_attribute_rules.low_value%TYPE;	--AE
    x_ruleset_id        cn_rulesets.ruleset_id%TYPE;  -- RK

    cached_org_id                integer;
    cached_org_append            varchar2(100);

    CURSOR attribute_rules_cursor IS
       SELECT LOWER(cocv.name) column_name, cocv.column_datatype data_type,cocv.data_type datatype, --RC Chnaged
	 --from data_type to column_datatype as per new functionality in 11i
	 --which will enable to distinguish between numeric and alphanumeric usage
	 --of the attribute columns
	     column_value value, high_value, low_value,
	     not_flag, dimension_hierarchy_id
	FROM cn_attribute_rules car, cn_obj_columns_v cocv
       WHERE rule_id = X_rule_id
         AND car.org_id=cocv.org_id
	 and car.org_id=x_org_id
	 AND cocv.column_id = car.column_id;

  BEGIN

    cn_debug.print_msg('attribute_rules>>', 1);
    first_flag := 'Y';
    x_ruleset_id := g_ruleset_id;

   -- get_cached_org_info (cached_org_id, cached_org_append);
            cached_org_id:= x_org_id;
            cached_org_append:='_'||cached_org_id;
   -- cn_utils.set_org_id(x_org_id);
    FOR arc IN attribute_rules_cursor LOOP
      quote := NULL;

      x_value	   := replace(arc.value, '''', '''''' ) ;       --AE 09-18-95
      x_high_value := replace(arc.high_value, '''', '''''' ) ;  --AE
      x_low_value  := replace(arc.low_value, '''', '''''' ) ;   --AE

      IF (first_flag = 'Y') THEN
	first_flag := 'N';
      ELSE
	cn_utils.appendcr(code);		--AE 09-05-95
	cn_utils.appind(code, ' AND ');         --AE 09-05-95
      END IF;

      IF (arc.not_flag = 'Y') THEN
	cn_utils.append(code, ' NOT ');
      END IF;

      cn_utils.append(code, '(');

      -- RC Replacing the following code with the new 11i feature
      --IF ((arc.data_type = 'VARCHAR2') OR (arc.data_type = 'DATE')) THEN

      IF (arc.data_type = 'ALPN') OR (arc.data_type = 'DATE') THEN
	quote := '''';
      ELSIF (arc.data_type = 'NUMB') THEN
	  quote := ' ';
      ELSE
	 quote := '''';
      END IF;

      IF (arc.value IS NOT NULL) THEN
	IF (arc.dimension_hierarchy_id IS NULL) THEN
	  IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE' ) THEN
--AE	  cn_utils.append(code, 'row.' || arc.column_name || ' = ' || quote || arc.value || quote);
-- Kumar  cn_utils.append(code, 'row.' || arc.column_name || ' = ' || quote || x_value  || quote);

                IF arc.datatype = 'DATE' THEN
                    cn_utils.append(code, 'nvl(row.' || arc.column_name ||   ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' = ' ||' TO_DATE(' || quote || x_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
                ELSE
                    cn_utils.append(code, 'nvl(TO_DATE(row.' || arc.column_name ||  ',' || quote || 'DD/MM/RRRR'||quote ||')'|| ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' = ' ||' TO_DATE(' || quote || x_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
                END IF;


          ELSE

           cn_utils.append(code, 'nvl(row.' || arc.column_name ||' , '
                                      || quote || l_dummy  || quote    || ' ) '
                                      || ' = ' || quote    || x_value  || quote);

          END IF;
	ELSE

-- Kumar Fixed  cn_utils.append(code, 'cn_clsfn_'||ABS(x_ruleset_id)||cached_org_append||'.is_descendant_of(row.' || arc.column_name || ', ' || quote || arc.value || quote || ', ' || arc.dimension_hierarchy_id || ', row.processed_period_id)');

          cn_utils.append(code, 'cn_clsfn_'||ABS(x_ruleset_id)||cached_org_append||'.is_descendant_of(row.' || arc.column_name || ', ' || quote || arc.value || quote || ', ' || arc.dimension_hierarchy_id || ', row.processed_date)');

	END IF;

      ELSIF (arc.high_value IS NOT NULL) THEN
	IF (arc.low_value IS NOT NULL) THEN
	 IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN
--AE	  cn_utils.append(code, 'row.' || arc.column_name || ' BETWEEN ' || quote || arc.low_value || quote || ' AND ' || quote || arc.high_value || quote);
--062796  cn_utils.append(code, 'row.' || arc.column_name || ' BETWEEN ' || quote || x_low_value  || quote || ' AND ' || quote || x_high_value  || quote);
--	  cn_utils.append(code, 'row.' || arc.column_name || ' BETWEEN ' || quote || arc.low_value || quote || ' AND ' || quote || arc.high_value || quote);
-- Kumar fix
            IF arc.datatype = 'DATE' THEN
		          cn_utils.append(code, 'nvl(row.' || arc.column_name ||  ' , '
						||' TO_DATE(' || quote|| l_dummy_date||quote ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')'
						   || ' BETWEEN ' || ' TO_DATE(' || quote || arc.low_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')'
						   || ' AND ' || ' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
			ELSE
                  cn_utils.append(code, 'nvl(TO_DATE(row.' || arc.column_name || ',' || quote || 'DD/MM/RRRR'|| quote ||')'||  ' , '
						||' TO_DATE(' || quote|| l_dummy_date||quote ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')'
						   || ' BETWEEN ' || ' TO_DATE(' || quote || arc.low_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')'
						   || ' AND ' || ' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
			END IF;

          ELSE


	  cn_utils.append(code, 'nvl(row.' || arc.column_name || ' , '
                                           ||  quote || l_dummy || quote || ' )'
                                           || ' BETWEEN ' || quote || arc.low_value || quote
                                           || ' AND ' || quote || arc.high_value || quote);

          END IF;


	ELSE
--AE	  cn_utils.append(code, 'row.' || arc.column_name || ' <= ' || quote || arc.high_value || quote);
--062796  cn_utils.append(code, 'row.' || arc.column_name || ' <= ' || quote || x_high_value  || quote);
--SK	  cn_utils.append(code, 'row.' || arc.column_name || ' <= ' || arc.high_value );

-- Kumar Fix cn_utils.append(code, 'row.' || arc.column_name || ' <= ' || quote || arc.high_value || quote);
	 IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN

                IF arc.datatype = 'DATE' THEN
                    cn_utils.append(code, 'nvl(row.' || arc.column_name ||   ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' <= ' ||' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
                ELSE
                    cn_utils.append(code, 'nvl(TO_DATE(row.' || arc.column_name ||  ',' || quote || 'DD/MM/RRRR'||quote ||')'|| ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' <= ' ||' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
                END IF;
         ELSE


          cn_utils.append(code, 'nvl(row.' || arc.column_name || ' , '
                                           || quote || l_dummy || quote || ' ) '
                                           || ' <= ' || quote || arc.high_value || quote);

         END IF;
	END IF;

      ELSIF (arc.low_value IS NOT NULL) THEN
--AE	 cn_utils.append(code, 'row.' || arc.column_name || ' >= ' || quote || arc.low_value || quote);
--062796 cn_utils.append(code, 'row.' || arc.column_name || ' >= ' || quote || x_low_value  || quote);
--SK	 cn_utils.appen(code, 'row.' || arc.column_name || ' >= ' || arc.low_value );
-- Kumar Fix cn_utils.append(code, 'row.' || arc.column_name || ' >= ' || quote || arc.low_value || quote);

     IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN
                IF arc.datatype = 'DATE' THEN
                    cn_utils.append(code, 'nvl(row.' || arc.column_name ||   ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' >= ' ||' TO_DATE(' || quote || arc.low_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
                ELSE
                    cn_utils.append(code, 'nvl(TO_DATE(row.' || arc.column_name ||  ',' || quote || 'DD/MM/RRRR'||quote ||')'|| ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' >= ' ||' TO_DATE(' || quote || arc.low_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')');
                END IF;
      ELSE


       cn_utils.append(code, 'nvl(row.' || arc.column_name || ' , '
                                              || quote || l_dummy || quote || ' ) '
                                       ||  ' >= ' || quote || arc.low_value || quote);

      END IF;
      END IF;
      cn_utils.append(code, ')');

    END LOOP;
    IF (first_flag = 'Y') THEN
      -- no attribute rules were found for this rule, so always enable it
      cn_utils.append(code, 'TRUE');
    END IF;

    cn_utils.append(code, ')');

    cn_debug.print_msg('attribute_rules<<', 1);
    --cn_utils.unset_org_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('attribute_rules: in exception handler for NO_DATA_FOUND', 1);
      RETURN;
  END attribute_rules;

  --
  -- Procedure Name
  --   create_attribute_rules_expr
  -- Purpose
  --   This function generates a conditional expression by ANDing all the
  --   attribute rules for the rule X_rule_id as default and by creating
  --   a complex expression using the cn_rule_attr_expression table when
  --   such data is available
  -- History
  --   06/22/98          Ramkarthik Kalyanasundaram          Created
  --

  PROCEDURE create_attribute_rules_expr (X_rule_id cn_rules.rule_id%TYPE,
                                         x_org_id cn_rules.org_id%TYPE,
					 code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS
      l_dummy             NUMBER := '-1000';
      first_flag		VARCHAR2(1);
      quote		VARCHAR2(1);
      default_flag        VARCHAR2(1);
      x_ruleset_id        cn_rulesets.ruleset_id%TYPE;
      buffer VARCHAR2(32000);
      cached_org_id                integer;
	  cached_org_append            varchar2(100);
     l_dummy_date VARCHAR2(60):= '01/01/1600';


      TYPE intermediate_expr_type IS RECORD ( id cn_rule_attr_expression.rule_attr_expression_id%TYPE,
                                              expr_id cn_rule_attr_expression.operand_expression_id%TYPE,
  					    expr CLOB);
      TYPE expr_type IS TABLE OF intermediate_expr_type INDEX BY BINARY_INTEGER;
     expr_table expr_type;
     table_index NUMBER := 0;

      CURSOR attribute_rules_cursor IS
        SELECT attribute_rule_id, LOWER(cocv.name) column_name,
               cocv.column_datatype data_type,cocv.data_type datatype,column_value value,
               high_value, low_value, not_flag, dimension_hierarchy_id
  	FROM cn_attribute_rules car, cn_obj_columns_v cocv
         WHERE rule_id = X_rule_id
	 and car.org_id= cocv.org_id
  	 AND cocv.column_id = car.column_id;
      CURSOR rule_attr_expr_cursor IS
        SELECT *
          FROM cn_rule_attr_expression
         WHERE rule_id = X_rule_id
      ORDER BY rule_attr_expression_id;
    BEGIN
      cn_debug.print_msg('attribute_rules>>', 1);
      first_flag := 'Y';
      default_flag := 'Y';

	--  get_cached_org_info (cached_org_id, cached_org_append);
	    cached_org_id:= x_org_id;
            cached_org_append:='_'||cached_org_id;

      SELECT ruleset_id
        INTO x_ruleset_id
        FROM cn_rules
       WHERE rule_id = X_rule_id
         AND org_id=x_org_id
         AND ruleset_id = g_ruleset_id;


      FOR arc IN attribute_rules_cursor LOOP
        quote := NULL;
        first_flag := 'N';
        table_index := table_index + 1;
        expr_table(table_index).id := arc.attribute_rule_id;
  	if (DBMS_LOB.ISTEMPORARY(expr_table(table_index).expr) IS NULL) THEN
  	 DBMS_LOB.CREATETEMPORARY(expr_table(table_index).expr,FALSE,DBMS_LOB.CALL);
        END IF;
        IF (arc.not_flag = 'Y') THEN
          buffer := ' NOT';
  	DBMS_LOB.WRITE(expr_table(table_index).expr,length(buffer),1,buffer);
        END IF;
        --expr_table(table_index).expr := expr_table(table_index).expr || '(';
          buffer:='(';
  	DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
        IF ((arc.data_type = 'VARCHAR2') OR (arc.data_type = 'DATE')) THEN
  	quote := '''';
        ELSIF (arc.data_type = 'NUMB') THEN
          quote := ' ';
        ELSE
          quote := '''';
        END IF;
        IF (arc.value IS NOT NULL) THEN
  	IF (arc.dimension_hierarchy_id IS NULL) THEN
  	  IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN
  	        IF arc.datatype = 'DATE' THEN
            buffer :=     'nvl(row.' || arc.column_name ||   ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' = ' ||' TO_DATE(' || quote || arc.value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')';
            ELSE
            buffer := 'nvl(TO_DATE(row.' || arc.column_name ||  ',' || quote || 'DD/MM/RRRR'||quote ||')'|| ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' = ' ||' TO_DATE(' || quote || arc.value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')';
            END IF;
          ELSE
            buffer :=    'nvl(row.' || arc.column_name ||
                                         ' , ' || quote || l_dummy  || quote || ' ) ' ||
                                         ' = ' || quote || arc.value  || quote;


          END IF  ;
  	 DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
  	ELSE
            buffer := 'cn_clsfn_'||ABS(x_ruleset_id)||cached_org_append
                   ||'.is_descendant_of(row.' || arc.column_name
                   || ', ' || quote || arc.value || quote || ', '
                   || arc.dimension_hierarchy_id || ', row.processed_date)';
   	 DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
  	END IF;
        ELSIF (arc.high_value IS NOT NULL) THEN
  	IF (arc.low_value IS NOT NULL) THEN
  	 IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN
               IF arc.datatype = 'DATE' THEN
                buffer :=    'nvl(row.' || arc.column_name ||  ' , '
						||' TO_DATE(' || quote|| l_dummy_date||quote ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')'
						   || ' BETWEEN ' || ' TO_DATE(' || quote || arc.low_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')'
						   || ' AND ' || ' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')';
                ELSE
                buffer := 'nvl(TO_DATE(row.' || arc.column_name || ',' || quote || 'DD/MM/RRRR'|| quote ||')'||  ' , '
				         ||' TO_DATE(' || quote|| l_dummy_date||quote ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')'
						   || ' BETWEEN ' || ' TO_DATE(' || quote || arc.low_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')'
						   || ' AND ' || ' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')';
                END IF;

         ELSE
                buffer :=     ' nvl(row.' || arc.column_name
                                              || ' , '|| quote || l_dummy || quote || ' ) '
                                              || ' BETWEEN ' || quote || arc.low_value || quote || ' AND '
                                              || quote || arc.high_value || quote;

         END IF;
  	     DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
          ELSE
           IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN
             IF arc.datatype = 'DATE' THEN
              buffer :=    'nvl(row.' || arc.column_name ||   ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' <= ' ||' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')';
             ELSE
              buffer :=    'nvl(TO_DATE(row.' || arc.column_name ||  ',' || quote || 'DD/MM/RRRR'||quote ||')'|| ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')' ||
                                       ' <= ' ||' TO_DATE(' || quote || arc.high_value  || quote ||',' ||quote ||'DD/MM/RRRR'||quote||')';
             END IF;
           ELSE
               buffer :=  'nvl(row.' || arc.column_name || ' , ' || quote || l_dummy || quote || ' ) ' || ' <= ' || quote || arc.high_value || quote;
           END IF;
  	     DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
         END IF;
        ELSIF (arc.low_value IS NOT NULL) THEN
             IF (arc.data_type = 'DATE' OR arc.datatype = 'DATE') THEN
              buffer :=  'nvl(TO_DATE(row.' || arc.column_name || ',' || quote || 'DD/MM/RRRR'||quote ||')'||   ' , '
                                         ||' TO_DATE(' || quote || l_dummy_date || quote   ||',' ||quote ||'DD/MM/RRRR'||quote ||')'|| ')'
                                           || ' >= ' || quote || arc.low_value || quote;
             ELSE
              buffer := 'nvl(row.' || arc.column_name
	       			|| ' ,'   || quote || l_dummy || quote || ' ) '
                          || ' >= ' || quote || arc.low_value || quote;
             END IF;
  	     DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
        END IF;
	  buffer :=   ')';
          DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
      END LOOP;


      FOR rae IN rule_attr_expr_cursor LOOP
        default_flag := 'N';
        table_index := table_index + 1;
        expr_table(table_index).id := rae.rule_attr_expression_id;
        expr_table(table_index).expr_id := rae.operand_expression_id;
        buffer := '(';
  	if (DBMS_LOB.ISTEMPORARY(expr_table(table_index).expr) IS NULL) THEN
  	 DBMS_LOB.CREATETEMPORARY(expr_table(table_index).expr,FALSE,DBMS_LOB.CALL);
          END IF;
  	DBMS_LOB.WRITE(expr_table(table_index).expr,length(buffer),1,buffer);
        FOR v_counter IN 1 .. table_index LOOP
          IF rae.operand1_ra_rae_flag = 'RA' THEN
            IF expr_table(v_counter).id = rae.operand1 THEN
    	      DBMS_LOB.APPEND(expr_table(table_index).expr,expr_table(v_counter).expr);
            END IF;
          ELSIF rae.operand1_ra_rae_flag = 'RAE' THEN
            IF expr_table(v_counter).expr_id = rae.operand1 THEN
    	      DBMS_LOB.APPEND(expr_table(table_index).expr,expr_table(v_counter).expr);
            END IF;
          END IF;
        END LOOP;
        IF rae.operator = 0 THEN
                buffer:= 'AND';
        ELSE
                buffer:= 'OR';
        END IF;
    	   DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
        FOR v_counter IN 1 .. table_index LOOP
          IF rae.operand2_ra_rae_flag = 'RA' THEN
            IF expr_table(v_counter).id = rae.operand2 THEN
  	     DBMS_LOB.APPEND(expr_table(table_index).expr,expr_table(v_counter).expr);
            END IF;
          ELSIF rae.operand2_ra_rae_flag = 'RAE' THEN
            IF expr_table(v_counter).expr_id = rae.operand2 THEN
  	     DBMS_LOB.APPEND(expr_table(table_index).expr,expr_table(v_counter).expr);
            END IF;
          END IF;
        END LOOP;
                buffer:= ')';
    	      DBMS_LOB.WRITEAPPEND(expr_table(table_index).expr,length(buffer),buffer);
      END LOOP;
      IF (first_flag = 'Y') THEN
        -- no attribute rules were found for this rule, so always enable it
        cn_utils.append(code, 'TRUE)');
      END IF;
      IF(first_flag = 'N' AND default_flag = 'Y') THEN
        attribute_rules(X_rule_id,x_org_id,code);
      ELSE
        cn_utils.append(code, expr_table(table_index).expr, ')');
      END IF;
      FOR clob_counter IN 1 .. expr_table.count LOOP
      	DBMS_LOB.FREETEMPORARY(expr_table(clob_counter).expr);
      END LOOP;
      cn_debug.print_msg('attribute_rules<<', 1);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        cn_debug.print_msg('create_attribute_rules_expr: in exception handler for NO_DATA_FOUND', 1);        RETURN;
    END create_attribute_rules_expr;


  PROCEDURE pkg_init_boilerplate (
	code		IN OUT NOCOPY cn_utils.code_type,
	package_name		cn_obj_packages_v.name%TYPE,
	description		cn_obj_packages_v.description%TYPE,
	object_type		VARCHAR2) IS

    X_userid		VARCHAR2(20);

  BEGIN
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code, '-- |                Copyright (c) 1998 Oracle Corporation                 | --');
    cn_utils.appendcr(code, '-- |                   Redwood Shores, California, USA                    | --');
    cn_utils.appendcr(code, '-- |                        All rights reserved.                          | --');
    cn_utils.appendcr(code, '-- +======================================================================+ --');
    cn_utils.appendcr(code);

    SELECT user INTO X_userid FROM sys.dual;

    cn_utils.appendcr(code, 'SET VERIFY OFF');
    cn_utils.appendcr(code, 'WHENEVER SQLERROR EXIT FAILURE ROLLBACK;');

  END pkg_init_boilerplate;

  PROCEDURE create_object( module_id		cn_modules.module_id%TYPE,
			   name			cn_objects.name%TYPE,
			   object_type		cn_objects.object_type%TYPE,
			   object_id IN OUT NOCOPY cn_objects.object_id%TYPE,
			   description IN OUT NOCOPY cn_objects.description%TYPE,
			   x_org_id             cn_rulesets.org_id%TYPE) IS
    next_id NUMBER;
  BEGIN

    next_id := cn_utils.get_repository(module_id,x_org_id);
    SELECT cn_objects_s.NEXTVAL
      INTO object_id
      FROM dual;
    insert into CN_OBJECTS (
    OBJECT_ID, DEPENDENCY_MAP_COMPLETE, NAME, OBJECT_TYPE, REPOSITORY_ID,
    OBJECT_STATUS, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
    LAST_UPDATE_LOGIN, DESCRIPTION, NEXT_SYNCHRONIZATION_DATE,
    SYNCHRONIZATION_FREQUENCY, DATA_LENGTH, DATA_TYPE, NULLABLE, PRIMARY_KEY,
    POSITION, DIMENSION_ID, DATA_SCALE, COLUMN_TYPE, TABLE_ID, UNIQUE_FLAG,
    PACKAGE_TYPE, PACKAGE_SPECIFICATION_ID, PARAMETER_LIST, RETURN_TYPE,
    PROCEDURE_TYPE, PACKAGE_ID, START_VALUE, INCREMENT_VALUE, STATEMENT_TEXT,
    ALIAS, TABLE_LEVEL, TABLE_TYPE, WHEN_CLAUSE, TRIGGERING_EVENT, EVENT_ID,
    PUBLIC_FLAG, CHILD_FLAG, FOR_EACH_ROW, TRIGGER_TYPE, USER_COLUMN_NAME,
    SEED_OBJECT_ID, PRIMARY_KEY_COLUMN_ID, USER_NAME_COLUMN_ID,
    CONNECT_TO_USERNAME, CONNECT_TO_PASSWORD, CONNECT_TO_HOST, USER_NAME,
    SCHEMA, FOREIGN_KEY, CLASSIFICATION_COLUMN,OBJECT_VERSION_NUMBER,ORG_ID)
    values(
    object_id, 'N', name,object_type, next_id,
    'A', NULL, NULL, NULL, NULL,
    NULL, description, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL,
    'CLS', NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,
    'CN', NULL, NULL,1,x_org_id);
  END create_object;

  PROCEDURE file_header (
	module_id		    cn_modules.module_id%TYPE,
	package_name		    cn_obj_packages_v.name%TYPE,
	package_type		    cn_obj_packages_v.package_type%TYPE,

	package_spec_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_body_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
	package_spec_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
	package_body_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,

	spec_code	    IN OUT NOCOPY  cn_utils.clob_code_type,
	body_code	    IN OUT NOCOPY  cn_utils.clob_code_type,
	x_org_id                    cn_rulesets.org_id%TYPE) IS

    x_rowid			ROWID;
    null_id			NUMBER;
    delete_flag			VARCHAR2(1) := 'Y';
    l_count			NUMBER;

  BEGIN
        --cn_utils.set_org_id(x_org_id);
	delete from cn_objects where name = package_name and object_type = 'PKS';
        delete from cn_objects where name = package_name and object_type = 'PKB';

    -- Find the package objects    AE 01-08-96
    cn_utils.find_object(package_name,'PKS',package_spec_id, package_spec_desc,x_org_id);
    cn_utils.find_object(package_name,'PKB',package_body_id, package_body_desc,x_org_id);

    IF (package_spec_id IS NULL AND package_body_id IS NULL) THEN
      create_object(module_id, package_name, 'PKS',package_spec_id, package_spec_desc,x_org_id);
      create_object(module_id, package_name, 'PKB',package_body_id, package_body_desc,x_org_id);
      delete_flag := 'N';
    END IF;

    -- Delete module source code from cn_source
    -- Delete module object dependencies for this module
    IF (delete_flag = 'Y') THEN
       cn_utils.delete_module(module_id, package_spec_id, package_body_id,x_org_id);
    END IF;

    cn_utils.init_code (package_spec_id, spec_code);	   -- AE 05-02-95
    cn_utils.init_code (package_body_id, body_code);	   -- AE 05-02-95

--    pkg_init_boilerplate(spec_code, package_name, package_spec_desc, 'PKS');
--    pkg_init_boilerplate(body_code, package_name, package_body_desc, 'PKB');


    cn_utils.indent(spec_code, 1);
    cn_utils.indent(body_code, 1);
   -- cn_utils.unset_org_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
     create_object(module_id, package_name, 'PKS',package_spec_id, package_spec_desc,x_org_id);

     create_object(module_id, package_name, 'PKB',package_body_id, package_body_desc,x_org_id);
     cn_utils.init_code (package_spec_id, spec_code);	   -- AE 05-02-95
    cn_utils.init_code (package_body_id, body_code);	   -- AE 05-02-95

--    pkg_init_boilerplate(spec_code, package_name, package_spec_desc, 'PKS');
--    pkg_init_boilerplate(body_code, package_name, package_body_desc, 'PKB');


--    cn_utils.indent(spec_code, 1);
--    cn_utils.indent(body_code, 1);
  END file_header;

  PROCEDURE package_header (
	code		IN OUT NOCOPY cn_utils.clob_code_type,
	package_name		cn_obj_packages_v.name%TYPE,
	description		cn_obj_packages_v.description%TYPE,
	object_type		VARCHAR2,
	x_org_id                cn_rules.org_id%TYPE) IS

    X_userid		VARCHAR2(20);
    x_package_name      varchar2(100);
	cached_org_id                integer;
	cached_org_append            varchar2(100);
  BEGIN

	--get_cached_org_info (cached_org_id, cached_org_append);
	cached_org_id:=x_org_id;
        cached_org_append:='_'||cached_org_id;


    SELECT user INTO X_userid FROM sys.dual;

    X_package_name := Lower(package_name) || cached_org_append;

    cn_utils.appendcr(code, 'DEFINE PACKAGE_NAME="' || LOWER(x_package_name) || '"');

    IF (object_type = 'PKS') THEN
     --RC 26-SEP-99  Commenting out the following line and replacing it with a
     --the actual package name

     --cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE &' || 'PACKAGE_NAME AS');
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE '||x_package_name|| ' AS --START-OF-PKS');
    ELSE
     --cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY &' || 'PACKAGE_NAME AS');
      cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY '||x_package_name|| ' AS --START-OF-PKB');
    END IF;

    cn_utils.appendcr(code);
    cn_utils.indent(code, 1);

  END package_header;

  PROCEDURE proc_init (
	procedure_name		cn_obj_procedures_v.name%TYPE,
	description		cn_obj_procedures_v.description%TYPE,
	parameter_list		cn_obj_procedures_v.parameter_list%TYPE,
	procedure_type		cn_obj_procedures_v.procedure_type%TYPE,
	return_type		cn_obj_procedures_v.return_type%TYPE,
	code		IN OUT NOCOPY cn_utils.clob_code_type,
	object_type		varchar2) IS

    X_rowid			ROWID;

  BEGIN

    -- Generate procedure header and parameters in both spec and body
    IF (procedure_type = 'P') THEN
      cn_utils.appind(code, 'PROCEDURE ' || procedure_name);
    ELSIF (procedure_type = 'F') THEN
      cn_utils.appind(code, 'FUNCTION ' || procedure_name);
    END IF;

    IF (parameter_list IS NOT NULL) THEN
      cn_utils.append(code, ' (' || parameter_list || ')');
    END IF;

    IF (procedure_type = 'F') THEN
      cn_utils.append(code, ' RETURN ' || return_type);
    END IF;

    IF (object_type = 'PKS') THEN
      cn_utils.appendcr(code, ';');
      cn_utils.appendcr(code);
    ELSE
      cn_utils.appendcr(code, ' IS');
    END IF;

  END proc_init;

  PROCEDURE rules_recurse_call (
        X_ruleset_id		cn_rules.ruleset_id%TYPE,
        x_org_id                cn_rules.org_id%TYPE,
	X_rule_id		cn_rules_hierarchy.rule_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type,
	X_package_count		cn_rules.package_id%TYPE) IS

    X_revenue_class	NUMBER;
    X_expense_ccid number;
    X_liability_ccid number;
    dummy               NUMBER(7);
    cached_org_id       INTEGER;
    cached_org_append   VARCHAR2(100);

  BEGIN
   -- get_cached_org_info (cached_org_id, cached_org_append);

    cached_org_id:=x_org_id;
    cached_org_append:='_'||cached_org_id;
--    cn_utils.set_org_id(x_org_id);
    create_attribute_rules_expr(X_rule_id,x_org_id,code);
    cn_utils.appendcr(code, ' THEN');
    cn_utils.indent(code, 1);

      SELECT count(*)
	INTO dummy
	FROM cn_rules_hierarchy crh
       WHERE parent_rule_id = X_rule_id
         AND org_id=x_org_id
         AND ruleset_id = x_ruleset_id;

     IF (dummy>0) THEN
       IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS')
       THEN
        	cn_utils.appindcr(code,
	       'revenue_class := cn_clsfn_'||ABS(X_ruleset_id)||'_'||x_package_count||cached_org_append||'.classify_rule_'||ABS(x_rule_id)||' (row);');
       ELSE
         	cn_utils.appindcr(code,
	       'cn_clsfn_'||ABS(X_ruleset_id)||'_'||x_package_count||cached_org_append||'.classify_rule_'||ABS(x_rule_id)||' (row, expense_ccid, liability_ccid);');
       end if;
     ELSE
       IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS')
        THEN
          SELECT revenue_class_id
            INTO X_revenue_class
            FROM cn_rules
           WHERE rule_id = X_rule_id
             AND ruleset_id = X_ruleset_id;

           IF (X_revenue_class IS NOT NULL) THEN
             cn_utils.appindcr(code, 'revenue_class := ' || X_revenue_class || ';');
           ELSE
             cn_utils.appindcr(code, 'NULL;');
           END IF;
         ELSE
          SELECT expense_ccid
            INTO X_expense_ccid
            FROM cn_rules
           WHERE rule_id = X_rule_id
	     AND org_id=x_org_id
             AND ruleset_id = X_ruleset_id;
          SELECT liability_ccid
            INTO X_liability_ccid
            FROM cn_rules
           WHERE rule_id = X_rule_id
	     AND org_id=x_org_id
             AND ruleset_id = X_ruleset_id;

           IF (X_expense_ccid IS NOT NULL) THEN
             cn_utils.appindcr(code, 'expense_ccid := ' || X_expense_ccid || ';');
           ELSE
             cn_utils.appindcr(code, 'NULL;');
           END IF;
           IF (X_liability_ccid IS NOT NULL) THEN
             cn_utils.appindcr(code, 'liability_ccid := ' || X_liability_ccid || ';');
           ELSE
             cn_utils.appindcr(code, 'NULL;');
           END IF;
          END IF;

     END IF;
  --cn_utils.unset_org_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('rules_recurse: in exception handler for NO_DATA_FOUND', 1);
      RETURN;
  END rules_recurse_call;

  --Cisco API
--Add the Classify function spec in the Ruleset package
PROCEDURE add_classify_spec (
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS

    procedure_name      cn_obj_procedures_v.name%TYPE;
    procedure_desc      cn_obj_procedures_v.description%TYPE;
    parameter_list      varchar2(10000);


  BEGIN

    procedure_name := 'CLASSIFY';
    procedure_desc := 'classify transactions outside OIC for Cisco';
    cn_utils.appind(code, 'FUNCTION ' || procedure_name);

cn_utils.appendcr(code,' (' ||'p_source_doc_type VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute50 VARCHAR2, ');
cn_utils.appendcr(code,'p_invoice_number VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute73 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute87 VARCHAR2, ');
cn_utils.appendcr(code,'p_forecast_id NUMBER, ');
cn_utils.appendcr(code,'p_upside_quantity NUMBER, ');
cn_utils.appendcr(code,'p_upside_amount NUMBER, ');
cn_utils.appendcr(code,'p_uom_code VARCHAR2, ');
cn_utils.appendcr(code,'p_source_trx_id NUMBER, ');
cn_utils.appendcr(code,'p_source_trx_line_id NUMBER, ');
cn_utils.appendcr(code,'p_source_trx_sales_line_id NUMBER, ');
cn_utils.appendcr(code,'p_negated_flag VARCHAR2, ');
cn_utils.appendcr(code,'p_customer_id NUMBER, ');
cn_utils.appendcr(code,'p_inventory_item_id NUMBER, ');
cn_utils.appendcr(code,'p_order_number NUMBER, ');
cn_utils.appendcr(code,'p_booked_date DATE, ');
cn_utils.appendcr(code,'p_invoice_date DATE, ');
cn_utils.appendcr(code,'p_bill_to_address_id NUMBER, ');
cn_utils.appendcr(code,'p_ship_to_address_id NUMBER, ');
cn_utils.appendcr(code,'p_bill_to_contact_id NUMBER, ');
cn_utils.appendcr(code,'p_ship_to_contact_id NUMBER, ');
cn_utils.appendcr(code,'p_adj_comm_lines_api_id NUMBER, ');
cn_utils.appendcr(code,'p_adjust_date DATE, ');
cn_utils.appendcr(code,'p_adjusted_by VARCHAR2, ');
cn_utils.appendcr(code,'p_revenue_type VARCHAR2, ');
cn_utils.appendcr(code,'p_adjust_rollup_flag VARCHAR2, ');
cn_utils.appendcr(code,'p_adjust_comments VARCHAR2, ');
cn_utils.appendcr(code,'p_adjust_status VARCHAR2, ');
cn_utils.appendcr(code,'p_line_number NUMBER, ');
cn_utils.appendcr(code,'p_request_id NUMBER, ');
cn_utils.appendcr(code,'p_program_id NUMBER, ');
cn_utils.appendcr(code,'p_program_application_id NUMBER, ');
cn_utils.appendcr(code,'p_program_update_date DATE, ');
cn_utils.appendcr(code,'p_type VARCHAR2, ');
cn_utils.appendcr(code,'p_sales_channel VARCHAR2, ');
cn_utils.appendcr(code,'p_object_version_number NUMBER, ');
cn_utils.appendcr(code,'p_split_pct NUMBER, ');
cn_utils.appendcr(code,'p_split_status VARCHAR2, ');
cn_utils.appendcr(code,'p_security_group_id NUMBER, ');
cn_utils.appendcr(code,'p_parent_header_id NUMBER, ');
cn_utils.appendcr(code,'p_trx_type VARCHAR2, ');
cn_utils.appendcr(code,'p_status VARCHAR2, ');
cn_utils.appendcr(code,'p_pre_processed_code VARCHAR2, ');
cn_utils.appendcr(code,'p_comm_lines_api_id NUMBER, ');
cn_utils.appendcr(code,'p_source_trx_number VARCHAR2, ');
cn_utils.appendcr(code,'p_quota_id NUMBER, ');
cn_utils.appendcr(code,'p_srp_plan_assign_id NUMBER, ');
cn_utils.appendcr(code,'p_revenue_class_id NUMBER, ');
cn_utils.appendcr(code,'p_role_id NUMBER, ');
cn_utils.appendcr(code,'p_comp_group_id NUMBER, ');
cn_utils.appendcr(code,'p_commission_amount NUMBER, ');
cn_utils.appendcr(code,'p_trx_batch_id NUMBER, ');
cn_utils.appendcr(code,'p_reversal_flag VARCHAR2, ');
cn_utils.appendcr(code,'p_reversal_header_id NUMBER, ');
cn_utils.appendcr(code,'p_reason_code VARCHAR2, ');
cn_utils.appendcr(code,'p_comments VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute_category VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute1 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute2 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute3 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute4 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute5 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute6 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute7 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute8 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute9 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute10 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute11 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute12 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute13 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute14 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute15 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute16 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute17 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute18 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute19 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute20 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute21 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute22 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute23 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute24 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute25 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute26 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute27 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute28 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute29 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute30 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute31 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute32 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute33 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute34 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute35 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute36 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute37 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute38 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute39 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute40 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute41 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute42 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute43 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute44 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute45 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute46 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute47 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute48 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute49 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute51 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute52 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute53 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute54 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute55 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute56 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute57 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute58 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute59 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute60 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute61 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute62 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute63 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute64 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute65 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute66 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute67 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute68 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute69 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute70 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute71 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute72 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute74 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute75 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute76 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute77 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute78 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute79 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute80 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute81 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute82 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute83 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute84 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute85 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute86 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute88 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute89 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute90 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute91 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute92 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute93 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute94 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute95 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute96 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute97 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute98 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute99 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute100 VARCHAR2, ');
cn_utils.appendcr(code,'p_last_update_date DATE, ');
cn_utils.appendcr(code,'p_last_updated_by NUMBER, ');
cn_utils.appendcr(code,'p_last_update_login NUMBER, ');
cn_utils.appendcr(code,'p_creation_date DATE, ');
cn_utils.appendcr(code,'p_created_by NUMBER, ');
cn_utils.appendcr(code,'p_org_id NUMBER, ');
cn_utils.appendcr(code,'p_exchange_rate NUMBER, ');
cn_utils.appendcr(code,'p_commission_header_id NUMBER, ');
cn_utils.appendcr(code,'p_direct_salesrep_id NUMBER, ');
cn_utils.appendcr(code,'p_processed_date DATE, ');
cn_utils.appendcr(code,'p_processed_period_id NUMBER, ');
cn_utils.appendcr(code,'p_rollup_date DATE, ');
cn_utils.appendcr(code,'p_transaction_amount NUMBER, ');
cn_utils.appendcr(code,'p_quantity NUMBER, ');
cn_utils.appendcr(code,'p_discount_percentage NUMBER, ');
cn_utils.appendcr(code,'p_margin_percentage NUMBER, ');
cn_utils.appendcr(code,'p_orig_currency_code VARCHAR2, ');
cn_utils.appendcr(code,'p_transaction_amount_orig NUMBER' || ')');

cn_utils.append(code, ' RETURN ' || 'NUMBER');
cn_utils.appendcr(code, ';');
cn_utils.appendcr(code);


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('add_classify_spec: in exception handler for NO_DATA_FOUND', 1);
      RETURN;
  END add_classify_spec;
--Cisco API

--Cisco API
--Add the Classify function body in the Ruleset package
PROCEDURE add_classify_body (
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS

    procedure_name      cn_obj_procedures_v.name%TYPE;
    procedure_desc      cn_obj_procedures_v.description%TYPE;


  BEGIN

        procedure_name := 'CLASSIFY';
    procedure_desc := 'classify transactions outside OIC for Cisco';
    cn_utils.appind(code, 'FUNCTION ' || procedure_name);

cn_utils.appendcr(code,' (' ||'p_source_doc_type VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute50 VARCHAR2, ');
cn_utils.appendcr(code,'p_invoice_number VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute73 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute87 VARCHAR2, ');
cn_utils.appendcr(code,'p_forecast_id NUMBER, ');
cn_utils.appendcr(code,'p_upside_quantity NUMBER, ');
cn_utils.appendcr(code,'p_upside_amount NUMBER, ');
cn_utils.appendcr(code,'p_uom_code VARCHAR2, ');
cn_utils.appendcr(code,'p_source_trx_id NUMBER, ');
cn_utils.appendcr(code,'p_source_trx_line_id NUMBER, ');
cn_utils.appendcr(code,'p_source_trx_sales_line_id NUMBER, ');
cn_utils.appendcr(code,'p_negated_flag VARCHAR2, ');
cn_utils.appendcr(code,'p_customer_id NUMBER, ');
cn_utils.appendcr(code,'p_inventory_item_id NUMBER, ');
cn_utils.appendcr(code,'p_order_number NUMBER, ');
cn_utils.appendcr(code,'p_booked_date DATE, ');
cn_utils.appendcr(code,'p_invoice_date DATE, ');
cn_utils.appendcr(code,'p_bill_to_address_id NUMBER, ');
cn_utils.appendcr(code,'p_ship_to_address_id NUMBER, ');
cn_utils.appendcr(code,'p_bill_to_contact_id NUMBER, ');
cn_utils.appendcr(code,'p_ship_to_contact_id NUMBER, ');
cn_utils.appendcr(code,'p_adj_comm_lines_api_id NUMBER, ');
cn_utils.appendcr(code,'p_adjust_date DATE, ');
cn_utils.appendcr(code,'p_adjusted_by VARCHAR2, ');
cn_utils.appendcr(code,'p_revenue_type VARCHAR2, ');
cn_utils.appendcr(code,'p_adjust_rollup_flag VARCHAR2, ');
cn_utils.appendcr(code,'p_adjust_comments VARCHAR2, ');
cn_utils.appendcr(code,'p_adjust_status VARCHAR2, ');
cn_utils.appendcr(code,'p_line_number NUMBER, ');
cn_utils.appendcr(code,'p_request_id NUMBER, ');
cn_utils.appendcr(code,'p_program_id NUMBER, ');
cn_utils.appendcr(code,'p_program_application_id NUMBER, ');
cn_utils.appendcr(code,'p_program_update_date DATE, ');
cn_utils.appendcr(code,'p_type VARCHAR2, ');
cn_utils.appendcr(code,'p_sales_channel VARCHAR2, ');
cn_utils.appendcr(code,'p_object_version_number NUMBER, ');
cn_utils.appendcr(code,'p_split_pct NUMBER, ');
cn_utils.appendcr(code,'p_split_status VARCHAR2, ');
cn_utils.appendcr(code,'p_security_group_id NUMBER, ');
cn_utils.appendcr(code,'p_parent_header_id NUMBER, ');
cn_utils.appendcr(code,'p_trx_type VARCHAR2, ');
cn_utils.appendcr(code,'p_status VARCHAR2, ');
cn_utils.appendcr(code,'p_pre_processed_code VARCHAR2, ');
cn_utils.appendcr(code,'p_comm_lines_api_id NUMBER, ');
cn_utils.appendcr(code,'p_source_trx_number VARCHAR2, ');
cn_utils.appendcr(code,'p_quota_id NUMBER, ');
cn_utils.appendcr(code,'p_srp_plan_assign_id NUMBER, ');
cn_utils.appendcr(code,'p_revenue_class_id NUMBER, ');
cn_utils.appendcr(code,'p_role_id NUMBER, ');
cn_utils.appendcr(code,'p_comp_group_id NUMBER, ');
cn_utils.appendcr(code,'p_commission_amount NUMBER, ');
cn_utils.appendcr(code,'p_trx_batch_id NUMBER, ');
cn_utils.appendcr(code,'p_reversal_flag VARCHAR2, ');
cn_utils.appendcr(code,'p_reversal_header_id NUMBER, ');
cn_utils.appendcr(code,'p_reason_code VARCHAR2, ');
cn_utils.appendcr(code,'p_comments VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute_category VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute1 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute2 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute3 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute4 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute5 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute6 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute7 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute8 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute9 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute10 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute11 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute12 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute13 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute14 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute15 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute16 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute17 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute18 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute19 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute20 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute21 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute22 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute23 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute24 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute25 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute26 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute27 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute28 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute29 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute30 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute31 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute32 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute33 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute34 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute35 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute36 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute37 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute38 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute39 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute40 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute41 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute42 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute43 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute44 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute45 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute46 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute47 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute48 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute49 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute51 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute52 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute53 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute54 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute55 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute56 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute57 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute58 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute59 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute60 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute61 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute62 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute63 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute64 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute65 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute66 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute67 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute68 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute69 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute70 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute71 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute72 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute74 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute75 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute76 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute77 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute78 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute79 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute80 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute81 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute82 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute83 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute84 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute85 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute86 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute88 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute89 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute90 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute91 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute92 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute93 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute94 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute95 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute96 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute97 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute98 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute99 VARCHAR2, ');
cn_utils.appendcr(code,'p_attribute100 VARCHAR2, ');
cn_utils.appendcr(code,'p_last_update_date DATE, ');
cn_utils.appendcr(code,'p_last_updated_by NUMBER, ');
cn_utils.appendcr(code,'p_last_update_login NUMBER, ');
cn_utils.appendcr(code,'p_creation_date DATE, ');
cn_utils.appendcr(code,'p_created_by NUMBER, ');
cn_utils.appendcr(code,'p_org_id NUMBER, ');
cn_utils.appendcr(code,'p_exchange_rate NUMBER, ');
cn_utils.appendcr(code,'p_commission_header_id NUMBER, ');
cn_utils.appendcr(code,'p_direct_salesrep_id NUMBER, ');
cn_utils.appendcr(code,'p_processed_date DATE, ');
cn_utils.appendcr(code,'p_processed_period_id NUMBER, ');
cn_utils.appendcr(code,'p_rollup_date DATE, ');
cn_utils.appendcr(code,'p_transaction_amount NUMBER, ');
cn_utils.appendcr(code,'p_quantity NUMBER, ');
cn_utils.appendcr(code,'p_discount_percentage NUMBER, ');
cn_utils.appendcr(code,'p_margin_percentage NUMBER, ');
cn_utils.appendcr(code,'p_orig_currency_code VARCHAR2, ');
cn_utils.appendcr(code,'p_transaction_amount_orig NUMBER' || ')');

cn_utils.append(code, ' RETURN ' || 'NUMBER');
cn_utils.appendcr(code, ' IS');


    cn_utils.appindcr(code, '  l_rec cn_commission_headers_all%rowtype;');
    cn_utils.appindcr(code, 'BEGIN');
    cn_utils.indent(code, 1);
cn_utils.appindcr(code,'l_rec.source_doc_type := p_source_doc_type;');
cn_utils.appindcr(code,'l_rec.attribute50 := p_attribute50;');
cn_utils.appindcr(code,'l_rec.invoice_number := p_invoice_number;');
cn_utils.appindcr(code,'l_rec.attribute73 := p_attribute73;');
cn_utils.appindcr(code,'l_rec.attribute87 := p_attribute87;');
cn_utils.appindcr(code,'l_rec.forecast_id := p_forecast_id;');
cn_utils.appindcr(code,'l_rec.upside_quantity := p_upside_quantity;');
cn_utils.appindcr(code,'l_rec.upside_amount := p_upside_amount;');
cn_utils.appindcr(code,'l_rec.uom_code := p_uom_code;');
cn_utils.appindcr(code,'l_rec.source_trx_id := p_source_trx_id;');
cn_utils.appindcr(code,'l_rec.source_trx_line_id := p_source_trx_line_id;');
cn_utils.appindcr(code,'l_rec.source_trx_sales_line_id := p_source_trx_sales_line_id;');
cn_utils.appindcr(code,'l_rec.negated_flag := p_negated_flag;');
cn_utils.appindcr(code,'l_rec.customer_id := p_customer_id;');
cn_utils.appindcr(code,'l_rec.inventory_item_id := p_inventory_item_id;');
cn_utils.appindcr(code,'l_rec.order_number := p_order_number;');
cn_utils.appindcr(code,'l_rec.booked_date := p_booked_date;');
cn_utils.appindcr(code,'l_rec.invoice_date := p_invoice_date;');
cn_utils.appindcr(code,'l_rec.bill_to_address_id := p_bill_to_address_id;');
cn_utils.appindcr(code,'l_rec.ship_to_address_id := p_ship_to_address_id;');
cn_utils.appindcr(code,'l_rec.bill_to_contact_id := p_bill_to_contact_id;');
cn_utils.appindcr(code,'l_rec.ship_to_contact_id := p_ship_to_contact_id;');
cn_utils.appindcr(code,'l_rec.adj_comm_lines_api_id := p_adj_comm_lines_api_id;');
cn_utils.appindcr(code,'l_rec.adjust_date := p_adjust_date;');
cn_utils.appindcr(code,'l_rec.adjusted_by := p_adjusted_by;');
cn_utils.appindcr(code,'l_rec.revenue_type := p_revenue_type;');
cn_utils.appindcr(code,'l_rec.adjust_rollup_flag := p_adjust_rollup_flag;');
cn_utils.appindcr(code,'l_rec.adjust_comments := p_adjust_comments;');
cn_utils.appindcr(code,'l_rec.adjust_status := p_adjust_status;');
cn_utils.appindcr(code,'l_rec.line_number := p_line_number;');
cn_utils.appindcr(code,'l_rec.request_id := p_request_id;');
cn_utils.appindcr(code,'l_rec.program_id := p_program_id;');
cn_utils.appindcr(code,'l_rec.program_application_id := p_program_application_id;');
cn_utils.appindcr(code,'l_rec.program_update_date := p_program_update_date;');
cn_utils.appindcr(code,'l_rec.type := p_type;');
cn_utils.appindcr(code,'l_rec.sales_channel := p_sales_channel;');
cn_utils.appindcr(code,'l_rec.object_version_number := p_object_version_number;');
cn_utils.appindcr(code,'l_rec.split_pct := p_split_pct;');
cn_utils.appindcr(code,'l_rec.split_status := p_split_status;');
cn_utils.appindcr(code,'l_rec.security_group_id := p_security_group_id;');
cn_utils.appindcr(code,'l_rec.parent_header_id := p_parent_header_id;');
cn_utils.appindcr(code,'l_rec.trx_type := p_trx_type;');
cn_utils.appindcr(code,'l_rec.status := p_status;');
cn_utils.appindcr(code,'l_rec.pre_processed_code := p_pre_processed_code;');
cn_utils.appindcr(code,'l_rec.comm_lines_api_id := p_comm_lines_api_id;');
cn_utils.appindcr(code,'l_rec.source_trx_number := p_source_trx_number;');
cn_utils.appindcr(code,'l_rec.quota_id := p_quota_id;');
cn_utils.appindcr(code,'l_rec.srp_plan_assign_id := p_srp_plan_assign_id;');
cn_utils.appindcr(code,'l_rec.revenue_class_id := p_revenue_class_id;');
cn_utils.appindcr(code,'l_rec.role_id := p_role_id;');
cn_utils.appindcr(code,'l_rec.comp_group_id := p_comp_group_id;');
cn_utils.appindcr(code,'l_rec.commission_amount := p_commission_amount;');
cn_utils.appindcr(code,'l_rec.trx_batch_id := p_trx_batch_id;');
cn_utils.appindcr(code,'l_rec.reversal_flag := p_reversal_flag;');
cn_utils.appindcr(code,'l_rec.reversal_header_id := p_reversal_header_id;');
cn_utils.appindcr(code,'l_rec.reason_code := p_reason_code;');
cn_utils.appindcr(code,'l_rec.comments := p_comments;');
cn_utils.appindcr(code,'l_rec.attribute_category := p_attribute_category;');
cn_utils.appindcr(code,'l_rec.attribute1 := p_attribute1;');
cn_utils.appindcr(code,'l_rec.attribute2 := p_attribute2;');
cn_utils.appindcr(code,'l_rec.attribute3 := p_attribute3;');
cn_utils.appindcr(code,'l_rec.attribute4 := p_attribute4;');
cn_utils.appindcr(code,'l_rec.attribute5 := p_attribute5;');
cn_utils.appindcr(code,'l_rec.attribute6 := p_attribute6;');
cn_utils.appindcr(code,'l_rec.attribute7 := p_attribute7;');
cn_utils.appindcr(code,'l_rec.attribute8 := p_attribute8;');
cn_utils.appindcr(code,'l_rec.attribute9 := p_attribute9;');
cn_utils.appindcr(code,'l_rec.attribute10 := p_attribute10;');
cn_utils.appindcr(code,'l_rec.attribute11 := p_attribute11;');
cn_utils.appindcr(code,'l_rec.attribute12 := p_attribute12;');
cn_utils.appindcr(code,'l_rec.attribute13 := p_attribute13;');
cn_utils.appindcr(code,'l_rec.attribute14 := p_attribute14;');
cn_utils.appindcr(code,'l_rec.attribute15 := p_attribute15;');
cn_utils.appindcr(code,'l_rec.attribute16 := p_attribute16;');
cn_utils.appindcr(code,'l_rec.attribute17 := p_attribute17;');
cn_utils.appindcr(code,'l_rec.attribute18 := p_attribute18;');
cn_utils.appindcr(code,'l_rec.attribute19 := p_attribute19;');
cn_utils.appindcr(code,'l_rec.attribute20 := p_attribute20;');
cn_utils.appindcr(code,'l_rec.attribute21 := p_attribute21;');
cn_utils.appindcr(code,'l_rec.attribute22 := p_attribute22;');
cn_utils.appindcr(code,'l_rec.attribute23 := p_attribute23;');
cn_utils.appindcr(code,'l_rec.attribute24 := p_attribute24;');
cn_utils.appindcr(code,'l_rec.attribute25 := p_attribute25;');
cn_utils.appindcr(code,'l_rec.attribute26 := p_attribute26;');
cn_utils.appindcr(code,'l_rec.attribute27 := p_attribute27;');
cn_utils.appindcr(code,'l_rec.attribute28 := p_attribute28;');
cn_utils.appindcr(code,'l_rec.attribute29 := p_attribute29;');
cn_utils.appindcr(code,'l_rec.attribute30 := p_attribute30;');
cn_utils.appindcr(code,'l_rec.attribute31 := p_attribute31;');
cn_utils.appindcr(code,'l_rec.attribute32 := p_attribute32;');
cn_utils.appindcr(code,'l_rec.attribute33 := p_attribute33;');
cn_utils.appindcr(code,'l_rec.attribute34 := p_attribute34;');
cn_utils.appindcr(code,'l_rec.attribute35 := p_attribute35;');
cn_utils.appindcr(code,'l_rec.attribute36 := p_attribute36;');
cn_utils.appindcr(code,'l_rec.attribute37 := p_attribute37;');
cn_utils.appindcr(code,'l_rec.attribute38 := p_attribute38;');
cn_utils.appindcr(code,'l_rec.attribute39 := p_attribute39;');
cn_utils.appindcr(code,'l_rec.attribute40 := p_attribute40;');
cn_utils.appindcr(code,'l_rec.attribute41 := p_attribute41;');
cn_utils.appindcr(code,'l_rec.attribute42 := p_attribute42;');
cn_utils.appindcr(code,'l_rec.attribute43 := p_attribute43;');
cn_utils.appindcr(code,'l_rec.attribute44 := p_attribute44;');
cn_utils.appindcr(code,'l_rec.attribute45 := p_attribute45;');
cn_utils.appindcr(code,'l_rec.attribute46 := p_attribute46;');
cn_utils.appindcr(code,'l_rec.attribute47 := p_attribute47;');
cn_utils.appindcr(code,'l_rec.attribute48 := p_attribute48;');
cn_utils.appindcr(code,'l_rec.attribute49 := p_attribute49;');
cn_utils.appindcr(code,'l_rec.attribute51 := p_attribute51;');
cn_utils.appindcr(code,'l_rec.attribute52 := p_attribute52;');
cn_utils.appindcr(code,'l_rec.attribute53 := p_attribute53;');
cn_utils.appindcr(code,'l_rec.attribute54 := p_attribute54;');
cn_utils.appindcr(code,'l_rec.attribute55 := p_attribute55;');
cn_utils.appindcr(code,'l_rec.attribute56 := p_attribute56;');
cn_utils.appindcr(code,'l_rec.attribute57 := p_attribute57;');
cn_utils.appindcr(code,'l_rec.attribute58 := p_attribute58;');
cn_utils.appindcr(code,'l_rec.attribute59 := p_attribute59;');
cn_utils.appindcr(code,'l_rec.attribute60 := p_attribute60;');
cn_utils.appindcr(code,'l_rec.attribute61 := p_attribute61;');
cn_utils.appindcr(code,'l_rec.attribute62 := p_attribute62;');
cn_utils.appindcr(code,'l_rec.attribute63 := p_attribute63;');
cn_utils.appindcr(code,'l_rec.attribute64 := p_attribute64;');
cn_utils.appindcr(code,'l_rec.attribute65 := p_attribute65;');
cn_utils.appindcr(code,'l_rec.attribute66 := p_attribute66;');
cn_utils.appindcr(code,'l_rec.attribute67 := p_attribute67;');
cn_utils.appindcr(code,'l_rec.attribute68 := p_attribute68;');
cn_utils.appindcr(code,'l_rec.attribute69 := p_attribute69;');
cn_utils.appindcr(code,'l_rec.attribute70 := p_attribute70;');
cn_utils.appindcr(code,'l_rec.attribute71 := p_attribute71;');
cn_utils.appindcr(code,'l_rec.attribute72 := p_attribute72;');
cn_utils.appindcr(code,'l_rec.attribute74 := p_attribute74;');
cn_utils.appindcr(code,'l_rec.attribute75 := p_attribute75;');
cn_utils.appindcr(code,'l_rec.attribute76 := p_attribute76;');
cn_utils.appindcr(code,'l_rec.attribute77 := p_attribute77;');
cn_utils.appindcr(code,'l_rec.attribute78 := p_attribute78;');
cn_utils.appindcr(code,'l_rec.attribute79 := p_attribute79;');
cn_utils.appindcr(code,'l_rec.attribute80 := p_attribute80;');
cn_utils.appindcr(code,'l_rec.attribute81 := p_attribute81;');
cn_utils.appindcr(code,'l_rec.attribute82 := p_attribute82;');
cn_utils.appindcr(code,'l_rec.attribute83 := p_attribute83;');
cn_utils.appindcr(code,'l_rec.attribute84 := p_attribute84;');
cn_utils.appindcr(code,'l_rec.attribute85 := p_attribute85;');
cn_utils.appindcr(code,'l_rec.attribute86 := p_attribute86;');
cn_utils.appindcr(code,'l_rec.attribute88 := p_attribute88;');
cn_utils.appindcr(code,'l_rec.attribute89 := p_attribute89;');
cn_utils.appindcr(code,'l_rec.attribute90 := p_attribute90;');
cn_utils.appindcr(code,'l_rec.attribute91 := p_attribute91;');
cn_utils.appindcr(code,'l_rec.attribute92 := p_attribute92;');
cn_utils.appindcr(code,'l_rec.attribute93 := p_attribute93;');
cn_utils.appindcr(code,'l_rec.attribute94 := p_attribute94;');
cn_utils.appindcr(code,'l_rec.attribute95 := p_attribute95;');
cn_utils.appindcr(code,'l_rec.attribute96 := p_attribute96;');
cn_utils.appindcr(code,'l_rec.attribute97 := p_attribute97;');
cn_utils.appindcr(code,'l_rec.attribute98 := p_attribute98;');
cn_utils.appindcr(code,'l_rec.attribute99 := p_attribute99;');
cn_utils.appindcr(code,'l_rec.attribute100 := p_attribute100;');
cn_utils.appindcr(code,'l_rec.last_update_date := p_last_update_date;');
cn_utils.appindcr(code,'l_rec.last_updated_by := p_last_updated_by;');
cn_utils.appindcr(code,'l_rec.last_update_login := p_last_update_login;');
cn_utils.appindcr(code,'l_rec.creation_date := p_creation_date;');
cn_utils.appindcr(code,'l_rec.created_by := p_created_by;');
cn_utils.appindcr(code,'l_rec.org_id := p_org_id;');
cn_utils.appindcr(code,'l_rec.exchange_rate := p_exchange_rate;');
cn_utils.appindcr(code,'l_rec.commission_header_id := p_commission_header_id;');
cn_utils.appindcr(code,'l_rec.direct_salesrep_id := p_direct_salesrep_id;');
cn_utils.appindcr(code,'l_rec.processed_date := p_processed_date;');
cn_utils.appindcr(code,'l_rec.processed_period_id := p_processed_period_id;');
cn_utils.appindcr(code,'l_rec.rollup_date := p_rollup_date;');
cn_utils.appindcr(code,'l_rec.transaction_amount := p_transaction_amount;');
cn_utils.appindcr(code,'l_rec.quantity := p_quantity;');
cn_utils.appindcr(code,'l_rec.discount_percentage := p_discount_percentage;');
cn_utils.appindcr(code,'l_rec.margin_percentage := p_margin_percentage;');
cn_utils.appindcr(code,'l_rec.orig_currency_code := p_orig_currency_code;');
cn_utils.appindcr(code,'l_rec.transaction_amount_orig := p_transaction_amount_orig;');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'RETURN classify_rule_1002(l_rec);');
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'END ' || procedure_name || ';');
    cn_utils.appendcr(code);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('add_classify_spec: in exception handler for NO_DATA_FOUND', 1);
      RETURN;
  END add_classify_body;
--Cisco API




  PROCEDURE rules_recurse_gen (
        x_ruleset_id            cn_rulesets.ruleset_id%TYPE,
        x_org_id            cn_rulesets.org_id%TYPE,
	X_rule_id		cn_rules_hierarchy.rule_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type) IS
    first_flag		VARCHAR2(1);
    X_revenue_class	NUMBER;
    X_expense_ccid number;
    x_liability_ccid number;

    procedure_name      cn_obj_procedures_v.name%TYPE;
    procedure_desc      cn_obj_procedures_v.description%TYPE;
    parameter_list      cn_obj_procedures_v.parameter_list%TYPE;

    dummy               NUMBER(7);

    CURSOR rules IS
      SELECT crh.rule_id rule_id,cr.org_id,cr.package_id package_id, cr.ruleset_id ruleset_id
	FROM cn_rules_hierarchy crh,cn_rules cr
       WHERE parent_rule_id = X_rule_id
	 AND crh.rule_id = cr.rule_id
	 AND crh.org_id=cr.org_id
	 AND crh.org_id=x_org_id
	 AND cr.ruleset_id = x_ruleset_id
       --ORDER BY sequence_number;
       ORDER BY crh.rule_id;

  BEGIN


    procedure_name := 'CLASSIFY_RULE_'||ABS(x_rule_id);
    procedure_desc := 'classify transactions using rule '||x_rule_id;

    IF g_module_type = 'REVCLS' OR  g_module_type = 'ACCGEN' THEN
      parameter_list := 'row cn_commission_headers%ROWTYPE';
    ELSIF g_module_type = 'PECLS' THEN
      parameter_list := 'row cn_proj_compensation_gtt%ROWTYPE';
    END IF;

    IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS')
    then
      proc_init (procedure_name, procedure_desc,parameter_list,
			 'F', 'NUMBER', code,'PKB');
    else

      parameter_list := parameter_list || ', expense_ccid out nocopy number, liability_ccid out nocopy number';
      proc_init (procedure_name, procedure_desc,parameter_list,
			 'P', 'NUMBER', code,'PKB');
    end if;
    cn_utils.appindcr(code, '  revenue_class   NUMBER   := NULL ;');
    cn_utils.appindcr(code, 'BEGIN');
    cn_utils.indent(code, 1);
    -- cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || '>>'');');
    if g_module_type = 'REVCLS' OR g_module_type = 'PECLS'
    then
      SELECT revenue_class_id
        INTO X_revenue_class
        FROM cn_rules
       WHERE rule_id = X_rule_id
         AND ruleset_id = x_ruleset_id
	 AND org_id=x_org_id;
    else
      SELECT expense_ccid
        INTO X_expense_ccid
        FROM cn_rules
       WHERE rule_id = X_rule_id
         AND org_id=x_org_id
         AND ruleset_id = x_ruleset_id;
      SELECT liability_ccid
        INTO X_liability_ccid
        FROM cn_rules
       WHERE rule_id = X_rule_id
         AND org_id=x_org_id
         AND ruleset_id = x_ruleset_id;
    end if;
    IF (X_revenue_class IS NOT NULL) THEN
      cn_utils.appindcr(code, 'revenue_class := ' || X_revenue_class || ';');
    END IF;
    IF (X_expense_ccid IS NOT NULL) THEN
      cn_utils.appindcr(code, 'expense_ccid := ' || X_expense_ccid || ';');
    END IF;
    IF (X_liability_ccid IS NOT NULL) THEN
      cn_utils.appindcr(code, 'liability_ccid := ' || X_liability_ccid || ';');
    END IF;
    first_flag := 'Y';
    FOR r IN rules LOOP
      IF (first_flag = 'Y') THEN
	first_flag := 'N';
	cn_utils.appind(code, 'IF (');
      ELSE
	cn_utils.unindent(code, 1);
	cn_utils.appind(code, 'ELSIF (');
      END IF;
      rules_recurse_call(r.ruleset_id,r.org_id,r.rule_id, code, r.package_id);
    END LOOP;
    IF (first_flag = 'N') THEN
      cn_utils.unindent(code, 1);
      cn_utils.appindcr(code, 'END IF;');
    END IF;
    -- cn_utils.appindcr(code, 'cn_message_pkg.debug(''' || procedure_name || '<<'');');
    cn_utils.appendcr(code);
    IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS')
    then
      cn_utils.appindcr(code, 'RETURN revenue_class;');
    else
      cn_utils.appindcr(code, 'RETURN;');
    end if;
    cn_utils.appendcr(code);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'END ' || procedure_name || ';');
    cn_utils.appendcr(code);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('rules_recurse_gen: in exception handler for NO_DATA_FOUND', 1);
      RETURN;
  END rules_recurse_gen;

  PROCEDURE rules_recurse_assign (
        X_ruleset_id		cn_rules.ruleset_id%TYPE,
	x_org_id                cn_rules.org_id %TYPE,
	X_rule_id		cn_rules_hierarchy.rule_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.clob_code_type,
	x_rule_count IN OUT NOCOPY     NUMBER,
	x_package_count IN OUT NOCOPY  NUMBER) IS

    first_flag		VARCHAR2(1);
    X_revenue_class	NUMBER;

    procedure_name      cn_obj_procedures_v.name%TYPE;
    procedure_desc      cn_obj_procedures_v.description%TYPE;
    parameter_list      cn_obj_procedures_v.parameter_list%TYPE;

    dummy               NUMBER(7);

    CURSOR rules IS
      SELECT rule_id,org_id
	FROM cn_rules_hierarchy crh
       WHERE parent_rule_id = X_rule_id
         AND org_id = x_org_id
         AND ruleset_id = X_ruleset_id --RC added condition for multiple classification rulesets
       ORDER BY sequence_number;

  BEGIN
      IF ( x_rule_count=0 ) THEN

	package_header ( code,'CN_CLSFN_'||ABS(X_ruleset_id)||'_'||x_package_count,
			 'CN_CLSFN_'||ABS(X_ruleset_id)||'_'||x_package_count,'PKS',x_org_id);

    END IF;

    procedure_name := 'CLASSIFY_RULE_'||ABS(x_rule_id);
    procedure_desc := 'classify transactions using rule '||x_rule_id;

    IF g_module_type = 'REVCLS' OR g_module_type = 'ACCGEN' THEN
      parameter_list := 'row cn_commission_headers%ROWTYPE';
    ELSIF g_module_type = 'PECLS' THEN
      parameter_list := 'row cn_proj_compensation_gtt%ROWTYPE';
    END IF;

    IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS')
    then
      proc_init (procedure_name, procedure_desc,parameter_list,
			 'F', 'NUMBER', code,'PKS');
    else
      parameter_list := parameter_list || ', expense_ccid out nocopy number, liability_ccid out nocopy number';
      proc_init (procedure_name, procedure_desc,parameter_list,
			 'P', 'NUMBER', code,'PKS');
    end if;

    UPDATE cn_rules_all_b
       SET package_id = x_package_count
     WHERE rule_id = x_rule_id
	AND org_id = x_org_id
       AND ruleset_id = X_ruleset_id;


    x_rule_count := x_rule_count + 1;
--    cn_utils.appindcr(code,'-- count:'||x_rule_count||' max:'||cn_global_var.g_cls_package_size);

    IF ( x_rule_count = cn_global_var.g_cls_package_size ) THEN

	--Call the Procedure to add Classify Function spec code
	  IF g_module_type = 'REVCLS' and x_package_count = 1 THEN
	  add_classify_spec(code);
	  END IF;

	cn_utils.unindent (code,1);
	cn_utils.pkg_end_boilerplate(code,'PKS');

	x_rule_count :=0;
	x_package_count := x_package_count +1;

    END IF;

    FOR r in rules LOOP

	SELECT count(*)
	  INTO dummy
	  FROM cn_rules_hierarchy
         WHERE parent_rule_id = r.rule_id
	 AND org_id=r.org_id  ;

        IF (dummy>0) THEN
	  rules_recurse_assign(x_ruleset_id,x_org_id,r.rule_id,code,x_rule_count,x_package_count);
	END IF;

    END LOOP;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('rules_recurse_assign: in exception handler for NO_DATA_FOUND', 1);
      RETURN;
  END rules_recurse_assign;


--
-- Public Procedures
--

  FUNCTION revenue_classes (
	debug_pipe	VARCHAR2,
	debug_level	NUMBER := 1,
	x_module_id	cn_modules.module_id%TYPE,
	x_ruleset_id_in	cn_rulesets.ruleset_id%TYPE,
	x_org_id_in cn_rulesets.org_id%	TYPE)  RETURN BOOLEAN IS

    -- Declare and initialize procedure variables	AE 01-10-96
    package_name	cn_obj_packages_v.name%TYPE
	:= 'cn_clsfn' || '_' || ABS(x_ruleset_id_in);
    package_type	cn_obj_packages_v.package_type%TYPE := 'CLS';

    package_spec_id	cn_obj_packages_v.package_id%TYPE;
    package_body_id	cn_obj_packages_v.package_id%TYPE;
    package_spec_desc	cn_obj_packages_v.description%TYPE;
    package_body_desc	cn_obj_packages_v.description%TYPE;

    x_repository_id	cn_repositories.repository_id%TYPE
	:= cn_utils.get_repository(x_module_id,x_org_id_in);
    x_event_id		cn_events.event_id%TYPE
	:= cn_utils.get_event(x_module_id,x_org_id_in);
    x_ruleset_id	cn_rulesets.ruleset_id%TYPE;
    x_org_id            cn_rulesets.org_id%TYPE;
    x_package_count     cn_rules.package_id%TYPE;
    x_rule_count        NUMBER(7);

    package_max         NUMBER(7);

--  procedure_id	cn_obj_procedures_v.procedure_id%TYPE;	--AE 01-15-96

    procedure_name	cn_obj_procedures_v.name%TYPE;
    procedure_desc	cn_obj_procedures_v.description%TYPE;
    parameter_list	cn_obj_procedures_v.parameter_list%TYPE;

    spec_code		cn_utils.clob_code_type;
    body_code		cn_utils.clob_code_type;
    first_flag		VARCHAR2(1);

    dummy               NUMBER(7);

    -- selects the top level rule in a ruleset.
    -- Note: this assumes that there is exactly one top-level rule for each
    -- ruleset. (This assumption is shared by Tony too)
    CURSOR rules IS
      SELECT DISTINCT cr.rule_id rule_id,cr.org_id org_id,cr.package_id package_id
	FROM cn_rules_hierarchy crh, cn_rules cr
       WHERE NOT EXISTS (SELECT rule_id
                           FROM cn_rules_hierarchy where rule_id = crh.parent_rule_id and org_id=crh.org_id)
	 AND cr.rule_id = crh.parent_rule_id
	 AND crh.org_id=cr.org_id
	 and cr.org_id=x_org_id
	 AND cr.ruleset_id = X_ruleset_id;

-- Added Where clause by Kumar.S

    CURSOR rules_gen IS
      SELECT DISTINCT cr.rule_id rule_id,cr.org_id org_id
	FROM cn_rules cr
       WHERE cr.package_id = x_package_count
           and org_id = x_org_id
	   and  ruleset_id =    x_ruleset_id;

    CURSOR rulesets IS
      SELECT LOWER(cocv.name) dest_column, cr.ruleset_id,cr.org_id,module_type
	FROM cn_rulesets cr, cn_obj_columns_v cocv
       WHERE cr.destination_column_id = cocv.column_id
	 AND cr.repository_id = x_repository_id
	 AND cr.org_id = cocv.org_id
	 AND cr.org_id=x_org_id_in
	 AND ruleset_id = x_ruleset_id_in;

  BEGIN
    cn_utils.set_org_id(x_org_id_in);
    DBMS_LOB.CREATETEMPORARY(spec_code.text,FALSE,DBMS_LOB.CALL);
    DBMS_LOB.CREATETEMPORARY(body_code.text,FALSE,DBMS_LOB.CALL);
    g_ruleset_id := X_ruleset_id_in;
    IF (debug_pipe IS NOT NULL) THEN
      cn_debug.init_pipe(debug_pipe, debug_level);
    END IF;
    cn_debug.print_msg('revenue_classes>>', 1);

    -- AE 01-10-96
    file_header(x_module_id, package_name||'_'||x_org_id_in, package_type,
	package_spec_id, package_body_id, package_spec_desc,
	package_body_desc, spec_code, body_code,x_org_id_in);

    x_package_count :=1;

    cn_global_var.initialize_instance_info(x_org_id_in);

    FOR rs IN rulesets LOOP
    g_module_type := rs.module_type;

	x_rule_count := 0;
	x_ruleset_id := rs.ruleset_id;
	x_org_id := rs.org_id;

	FOR r IN rules LOOP

	  SELECT count(*)
	    INTO dummy
	    FROM cn_rules_hierarchy
           WHERE parent_rule_id = r.rule_id
	   and org_id=r.org_id;

          IF (dummy>0) THEN
	    rules_recurse_assign(x_ruleset_id,x_org_id,r.rule_id,spec_code,x_rule_count,x_package_count);
	  END IF;

        END LOOP;

        IF ( x_rule_count = 0 ) THEN

	  package_max := x_package_count - 1;

	ELSE

	  package_max := x_package_count;

	  --Call the Procedure to add Classify Function spec code
	  IF g_module_type = 'REVCLS' and x_package_count = 1 THEN
	  add_classify_spec(spec_code);
	  END IF;

	  cn_utils.unindent (spec_code,1);
	  cn_utils.pkg_end_boilerplate(spec_code,'PKS');

	END IF;

	x_package_count := 1;

	WHILE ( x_package_count <= package_max) LOOP

	  package_header( body_code, 'CN_CLSFN_'||ABS(x_ruleset_id)||'_'||x_package_count,
			'CN_CLSFN_'||ABS(x_ruleset_id)||'_'||x_package_count,  'PKB',x_org_id);

	  FOR rgen IN rules_gen LOOP

	    SELECT count(*)
	      INTO dummy
	      FROM cn_rules_hierarchy
             WHERE parent_rule_id = rgen.rule_id and
	     org_id=rgen.org_id;

            IF (dummy>0) THEN
	      rules_recurse_gen(x_ruleset_id,x_org_id,rgen.rule_id,body_code);
	    END IF;

          END LOOP;

          --Call the Procedure to add Classify Function body code
          IF g_module_type = 'REVCLS' and x_package_count = 1 THEN
          add_classify_body(body_code);
          END IF;

	  cn_utils.unindent (body_code,1);
	  cn_utils.pkg_end_boilerplate(Body_code,'PKB');
	  x_package_count := x_package_count + 1;

	END LOOP;

    END LOOP;
    package_header( spec_code,package_name,package_body_desc,  'PKS',x_org_id);
    package_header( body_code,package_name,package_body_desc,  'PKB',x_org_id);
--  procedure_id := cn_utils.get_object_id;	-- AE 01-15-96
    procedure_name := 'is_descendant_of';
    procedure_desc := 'This function returns TRUE if value is a descendant of value according to the dimension hierarchy hierarchy_id';
 -- parameter_list := 'X_column_value NUMBER, X_rollup_value NUMBER, X_hierarchy_id NUMBER, X_period    NUMBER';

    -- 30-NOV-99 SK  Changes made to replace periods with Start and End dates.
-- Kumar Fixed    parameter_list := 'X_column_value NUMBER, X_rollup_value NUMBER, X_hierarchy_id NUMBER, X_processed_date DATE';
   parameter_list := 'X_column_value VARCHAR2, X_rollup_value VARCHAR2, X_hierarchy_id NUMBER, X_processed_date DATE';


    -- AE 01-15-96
    cn_utils.proc_init(procedure_name, procedure_desc, parameter_list,
	'F', 'BOOLEAN', package_spec_id, x_repository_id,
	spec_code, body_code);

    cn_utils.appindcr(body_code, '  dummy      NUMBER;');
    cn_utils.appindcr(body_code, '  x_name1    VARCHAR2(30);');  --AE 08-98-95
    cn_utils.appindcr(body_code, '  x_name2    VARCHAR2(30);');  --AE
    cn_utils.appendcr(body_code);

--  replaced by inline code for Peter's debug messages.   11-02-95
--  cn_utils.proc_begin(procedure_name, 'N', body_code);
    cn_utils.appindcr(body_code, 'BEGIN');
    cn_utils.indent(body_code, 1);
   -- cn_utils.appindcr(body_code, 'cn_message_pkg.debug(''' || procedure_name || '>>'');');
--  end of inline code	11-02-95


    -- 30-NOV-99 SK  Changes made to replace periods with Start and End dates.

    cn_utils.appindcr(body_code, 'SELECT ancestor_external_id');
    cn_utils.appindcr(body_code, '  INTO dummy');
    cn_utils.appindcr(body_code, '  FROM cn_dim_explosion');
    cn_utils.appindcr(body_code, ' WHERE value_external_id = X_column_value');
    cn_utils.appindcr(body_code, '   AND ancestor_id = X_rollup_value');
    cn_utils.appindcr(body_code, '   AND dim_hierarchy_id = (');
    cn_utils.appindcr(body_code, '      SELECT cdh.dim_hierarchy_id');
    cn_utils.appindcr(body_code, '        FROM cn_dim_hierarchies cdh');
    cn_utils.appindcr(body_code, '        WHERE cdh.header_dim_hierarchy_id = X_hierarchy_id');
    cn_utils.appindcr(body_code, '          AND X_processed_date BETWEEN cdh.start_date and cdh.end_date);');
    cn_utils.appindcr(body_code, 'RETURN TRUE;');
    cn_utils.appendcr(body_code);
    cn_utils.appindcr(body_code, 'EXCEPTION');
    cn_utils.appindcr(body_code, '  WHEN NO_DATA_FOUND THEN');
    cn_utils.appindcr(body_code, '    RETURN FALSE;');

--  replaced by inline code for Peter's debug messages.   11-02-95
--  cn_utils.proc_end(procedure_name, 'N', body_code);
    cn_utils.appendcr(body_code);
   -- cn_utils.appindcr(body_code, 'cn_message_pkg.debug(''' || procedure_name || '<<'');');
    cn_utils.appendcr(body_code);
    cn_utils.unindent(body_code, 1);
    cn_utils.appindcr(body_code, 'END ' || procedure_name || ';');
    cn_utils.appendcr(body_code);
--  end of inline code	11-02-95
    FOR rs IN rulesets LOOP

      X_ruleset_id := rs.ruleset_id;


--AE  procedure_id := cn_utils.get_object_id;		--AE 01-15-96
    procedure_name := 'classify_' || ABS(rs.ruleset_id);
    procedure_desc := 'This function classifies transactions into a revenue class according to the rules in the ruleset ' || rs.ruleset_id;
      --RC changing the parameters for 11i for as per the requirements
      --for the calculation process
      --parameter_list := 'row    cn_commission_lines%ROWTYPE';
    parameter_list := 'p_commission_header_id NUMBER';

    IF g_module_type = 'REVCLS' OR g_module_type = 'ACCGEN' THEN
      parameter_list := 'p_commission_header_id NUMBER';
    ELSIF g_module_type = 'PECLS' THEN
      parameter_list := 'p_line_id NUMBER';
    END IF;

      --AE 01-15-96
    IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS')
    then
      cn_utils.proc_init(procedure_name, procedure_desc, parameter_list,
	'F', 'NUMBER', package_spec_id, x_repository_id,
	spec_code, body_code);
    else

     parameter_list := parameter_list || ', expense_ccid out nocopy number, liability_ccid out nocopy number';
      cn_utils.proc_init(procedure_name, procedure_desc, parameter_list,
	'P', 'NUMBER', package_spec_id, x_repository_id,
	spec_code, body_code);
    end if;


      cn_utils.appindcr(body_code, '  revenue_class   NUMBER   := NULL ;');
      --RC Adding the following code in 11i for calculation
      --RK Added the 'PECLS' condition for projected commission code enhancement

      IF g_module_type = 'REVCLS' OR g_module_type = 'ACCGEN'  THEN
        cn_utils.appindcr(body_code, '  row           cn_commission_headers%ROWTYPE ;');
      ELSIF g_module_type = 'PECLS' THEN
        cn_utils.appindcr(body_code, '  row           cn_proj_compensation_gtt%ROWTYPE ;');
      END IF;

--    replaced by inline code for Peter's debug messages.   11-02-95
--    cn_utils.proc_begin(procedure_name, 'N', body_code);
      cn_utils.appindcr(body_code, 'BEGIN');
      cn_utils.indent(body_code, 1);
    --  cn_utils.appindcr(body_code, 'cn_message_pkg.debug(''' || procedure_name || '>>'');');
--    end of inline code  11-02-95


      --RC  Adding code for 11i changes as needed by calculation
      --RK Added the 'PECLS' condition for projected commission code enhancement

      IF g_module_type = 'REVCLS' OR g_module_type = 'ACCGEN' THEN
        cn_utils.appindcr(body_code, 'SELECT * INTO row FROM cn_commission_headers WHERE commission_header_id = p_commission_header_id;');
      ELSIF g_module_type = 'PECLS' THEN
        cn_utils.appindcr(body_code, 'SELECT * INTO row FROM cn_proj_compensation_gtt WHERE line_id = p_line_id;');
      END IF;


      -- for each rule at the top level of the hierarchy do
      --   generate the if(elsif) rule for that rule then .. endif;
      first_flag := 'Y';

      FOR r IN rules LOOP
	IF (first_flag = 'Y') THEN
	  first_flag := 'N';
	  cn_utils.appind(body_code, 'IF (');
	ELSE
	  cn_utils.unindent(body_code, 1);
	  cn_utils.appind(body_code, 'ELSIF (');
	END IF;
	rules_recurse_call(X_ruleset_id,x_org_id,r.rule_id, body_code,r.package_id);
      END LOOP;

      IF (first_flag = 'N') THEN
	cn_utils.unindent(body_code, 1);
	cn_utils.appindcr(body_code, 'END IF;');
      END IF;
 --     cn_utils.appindcr(body_code, 'cn_message_pkg.debug(''' || procedure_name || '<<'');');
      cn_utils.appendcr(body_code);
      IF (g_module_type = 'REVCLS' OR g_module_type = 'PECLS') THEN
        cn_utils.appindcr(body_code, 'RETURN revenue_class;');
      else
        cn_utils.appindcr(body_code, 'RETURN;');
      end if;

--    replaced by inline code for Peter's debug messages.   11-02-95
--    cn_utils.proc_end(procedure_name, 'N', body_code);
      cn_utils.appendcr(body_code);
      cn_utils.unindent(body_code, 1);
      cn_utils.appindcr(body_code, 'END ' || procedure_name || ';');
      cn_utils.appendcr(body_code);
--    end of inline code  11-02-95

    END LOOP;


--- generate classify_batch routine.
    --  procedure_id := cn_utils.get_object_id;	--AE 01-15-96

    -- AE 01-10-96
    cn_utils.pkg_end(package_name, package_spec_id, package_body_id,
	spec_code, body_code);

    cn_debug.print_msg('revenue_classes<<', 1);

    DBMS_LOB.FREETEMPORARY(spec_code.text);
    DBMS_LOB.FREETEMPORARY(body_code.text);
    cn_utils.unset_org_id;
    RETURN TRUE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_LOB.FREETEMPORARY(spec_code.text);
      DBMS_LOB.FREETEMPORARY(body_code.text);
      cn_debug.print_msg('revenue_classes: in exception handler for NO_DATA_FOUND', 1);
      RETURN FALSE;
  END revenue_classes;


  PROCEDURE Classification_Install(
                 x_errbuf OUT NOCOPY VARCHAR2,
                 x_retcode OUT NOCOPY NUMBER,
                 x_ruleset_id IN NUMBER,
		 x_org_id IN NUMBER) IS

  l_applsys_schema         VARCHAR2(20) ;
  l_pks_start              NUMBER;
  l_pks_end                NUMBER;
  l_pkb_start              NUMBER;
  l_pkb_end                NUMBER;
  l_count                  NUMBER;
  l_comp_error             VARCHAR2(10);
  l_errors                 BOOLEAN := FALSE;
  l_max_len                NUMBER := 1800;
  l_remainder               NUMBER;
  l_pks_object_id          NUMBER;
  l_pkb_object_id          NUMBER;
  l_pkg_name               VARCHAR2(3000);
  k                        NUMBER;
  l_min_line_no            NUMBER;

   -- rchenna, bug 3960877
   l_text1 VARCHAR2(300);
   l_next_occurance_count NUMBER;
   l_paired_quotes BOOLEAN;

  CURSOR pkg_spec_start (p_object_id NUMBER) IS
  SELECT cs.line_no
    FROM cn_source cs
   WHERE cs.object_id = p_object_id
     AND substr(cs.text, 1, 25) = 'CREATE OR REPLACE PACKAGE'
     AND instr(cs.text, '--START-OF-PKS') <> 0
   ORDER BY line_no;

  CURSOR pkg_spec_end (p_object_id NUMBER) IS
  SELECT cs.line_no
    FROM cn_source cs
   WHERE cs.object_id = p_object_id
     AND cs.text like 'END%'
   ORDER BY line_no;

  CURSOR pkg_body_start (p_object_id NUMBER) IS
  SELECT cs.line_no
    FROM cn_source cs
   WHERE cs.object_id = p_object_id
     AND substr(cs.text, 1, 30) = 'CREATE OR REPLACE PACKAGE BODY'
     AND instr(cs.text, '--START-OF-PKB') <> 0
   ORDER BY line_no;

  CURSOR pkg_body_end (p_object_id NUMBER) IS
  SELECT cs.line_no
    FROM cn_source cs
   WHERE cs.object_id = p_object_id
     AND cs.text like 'END%'
   ORDER BY line_no;

  CURSOR fetch_code (p_pks_start NUMBER,
                     p_pks_end   NUMBER,
                     p_pks_object_id NUMBER) IS
  SELECT cs.text
    FROM cn_source cs
   WHERE cs.object_id = p_pks_object_id
     AND cs.line_no between p_pks_start and (p_pks_end - 1)
   ORDER BY cs.line_no;

  CURSOR get_ruleset_data ( p_ruleset_id in NUMBER,p_org_id in NUMBER )  IS
    SELECT *
      FROM cn_rulesets
     WHERE ruleset_id = p_ruleset_id and
     org_id=p_org_id;

  l_get_ruleset_data_rec  get_ruleset_data%ROWTYPE;

   l_ruleset_id  NUMBER;
   l_org_id NUMBER;
   l_text        VARCHAR2(32000);
   l_pos         NUMBER;

BEGIN
 cn_utils.set_org_id(x_org_id);
 SELECT co.object_id
    INTO l_pks_object_id
    FROM cn_objects co
   WHERE co.name = 'cn_clsfn_'||x_ruleset_id||'_'||x_org_id
    AND co.org_id=x_org_id
    AND co.object_type = 'PKS';

  SELECT co.object_id
    INTO l_pkb_object_id
    FROM cn_objects co
   WHERE co.name = 'cn_clsfn_'||x_ruleset_id||'_'||x_org_id
    AND co.org_id=x_org_id
    AND co.object_type = 'PKB';

  FOR i in pkg_spec_start(l_pks_object_id)
  LOOP
     l_pks_start := i.line_no;
     SELECT substr(text, instr(text, 'cn_clsfn'),
                         instr(substr(text, instr(text, 'cn_clsfn'), length(text)),
                              ' AS --START-OF'))
       INTO l_pkg_name
       FROM cn_source
      WHERE line_no = l_pks_start
        AND object_id = l_pks_object_id;

     l_pkg_name := RTRIM(UPPER(l_pkg_name));

     IF NOT pkg_spec_end%ISOPEN
     THEN
       OPEN pkg_spec_end(l_pks_object_id);
     END IF;
     FETCH pkg_spec_end INTO l_pks_end;

     k := 1;
     --Create package spec
     FOR j IN fetch_code(l_pks_start, l_pks_end - 1, l_pks_object_id)
     LOOP
       ad_ddl.build_package(j.text, k);
       k := k + 1;
     END LOOP;
     ad_ddl.build_package('END;', k);
   -----+
    -- Added Select..Into.. From. Statement
    --pramadas/24-Dec-2003/Bug Fix : 3322008
    -----+

         SELECT user
         INTO   l_applsys_schema
         FROM   dual;

     ad_ddl.create_plsql_object(
		    applsys_schema         => l_applsys_schema,
		    application_short_name => 'CN',
		    object_name            => l_pkg_name,
		    lb                     => 1,
		    ub                     => k,
		    insert_newlines        => 'FALSE',
		    comp_error             => l_comp_error);

      IF l_comp_error = 'TRUE' THEN
	   l_errors := TRUE;
      END IF;
  END LOOP;

  FOR i in pkg_body_start(l_pkb_object_id)
  LOOP
     l_pkb_start := i.line_no;
     SELECT substr(text,  instr(text, 'cn_clsfn_'),
                         instr(substr(text, instr(text, 'cn_clsfn_'), length(text)),
                              ' AS --START-OF'))
       INTO l_pkg_name
       FROM cn_source
      WHERE line_no = l_pkb_start
        AND object_id = l_pkb_object_id;

     l_pkg_name := RTRIM(UPPER(l_pkg_name));

     IF NOT pkg_body_end%ISOPEN
     THEN
       OPEN pkg_body_end(l_pkb_object_id);
     END IF;
     FETCH pkg_body_end INTO l_pkb_end;

     k := 1;
     --Create package body
     FOR j IN fetch_code(l_pkb_start, l_pkb_end - 1, l_pkb_object_id)
     LOOP

     -- Modified By Kumar.S
     -- Dated on 09/29/00
     -- Bug No 1406969
     -- Truncation Error pl/sql numeric value error
     -- our program looks OK, only the do ad_ddl build package
     -- using an variable which has a limitation of 255 Characters
     --

         IF length(j.text ) <= 254 then
           ad_ddl.build_package(j.text, k);
        ELSE

           l_text := j.text;
           LOOP
             -- rchenna, bug 3960877, initialize local variables
              l_next_occurance_count := 1;
              l_paired_quotes := FALSE;

             -- rchenna, bug 3960877, keep finding the next occurance
             -- of close parathesis until single quotes in the substr
             -- match up
             WHILE  NOT l_paired_quotes LOOP
               -- rchenna, bug 3960877
               l_pos := instr(l_text, ')', 1,  l_next_occurance_count );

               -- rchenna, bug 3960877
               -- check whether the substr(l_text,1,l_pos) has paried
               -- single quotes

               l_text1 := substr(l_text,1,l_pos);
               l_paired_quotes := TRUE;

            IF length(l_text1) > 0 THEN

              check_text_paired_quotes(substr(l_text,1,l_pos), l_paired_quotes);

            END IF;

              l_next_occurance_count := l_next_occurance_count + 1;

           END LOOP;


             ad_ddl.build_package(substr(l_text,1,l_pos), k);
             l_text :=  substr(l_text, l_pos +1 );

             IF nvl(l_pos,0) = 0 then
                ad_ddl.build_package(substr(l_text,l_pos), k);
                EXIT;
             END IF;
             k := k +1;

           END LOOP;

         END IF;
       k := k + 1;
     END LOOP;
     ad_ddl.build_package('END;', k);
     ad_ddl.create_plsql_object(
		    applsys_schema         => l_applsys_schema,
		    application_short_name => 'CN',
		    object_name            => l_pkg_name,
		    lb                     => 1,
		    ub                     => k,
		    insert_newlines        => 'TRUE',
		    comp_error             => l_comp_error);

      IF l_comp_error = 'TRUE' THEN
	   l_errors := TRUE;
      END IF;

  END LOOP;

    ------------------------------------------------------------------------------
    -- The rest of the procedure is concerned with providing log messages if the
    -- creation of any of the packages failed
    ------------------------------------------------------------------------------
    IF l_errors THEN						-- some specs/bodies were in error
      x_retcode := 1;						-- set failure return code

      -- Search the User_Errors table, for errors belonging to any of the Classification
      -- packages for this Org.
      --
      FOR rec IN
        (SELECT
           '*** '||type||' '||LOWER(name)||' LINE: '||line||'/'||position||fnd_global.local_CHR(10)||text||fnd_global.local_CHR(10) outstr
         FROM user_errors WHERE name = l_pkg_name)
      LOOP
        -- If there is enough space, append this error to the end of the
	   -- Errbuf, otherwise aappend as mauch as possible and then quit
	   -- the loop.
	   IF LENGTHB(x_errbuf) + LENGTHB(rec.outstr) <= l_max_len THEN
	     x_errbuf := x_errbuf || rec.outstr;
        ELSE
	     l_remainder := l_max_len - LENGTHB(x_errbuf);
	     x_errbuf := x_errbuf || SUBSTRB(rec.outstr,1,l_remainder);
	     EXIT;
        END IF;
      END LOOP;
    END IF;

    --
    --  Added change status to 'GENERATED' if the install is completed successfully
    --  Kumar Sivasankaran Date: 11/07/2001
    --
    OPEN get_ruleset_data (x_ruleset_id,x_org_id);
    FETCH get_ruleset_data INTO l_get_ruleset_data_rec;
    CLOSE get_ruleset_data;

    if l_get_ruleset_data_rec.ruleset_id is null THEN
     l_ruleset_id := -x_ruleset_id;
     l_org_id :=x_org_id;
     OPEN get_ruleset_data ( l_ruleset_id,l_org_id);
     FETCH get_ruleset_data INTO l_get_ruleset_data_rec;
     CLOSE get_ruleset_data;
    end if;

    if l_errors  THEN
       l_get_ruleset_data_rec.ruleset_status := 'INSTFAIL';
    else
       l_get_ruleset_data_rec.ruleset_status := 'GENERATED';
    end if;

    cn_syin_rulesets_pkg.update_row(l_get_ruleset_data_rec.ruleset_id,
                                   l_get_ruleset_data_rec.object_version_number,
                                   l_get_ruleset_data_rec.ruleset_status,
                                   l_get_ruleset_data_rec.destination_column_id,
                                   l_get_ruleset_data_rec.repository_id,
                                   l_get_ruleset_data_rec.start_date,
                                   l_get_ruleset_data_rec.end_date,
                                   l_get_ruleset_data_rec.name,
                                   l_get_ruleset_data_rec.module_type,
                                   null,
                                   null,
                                   null,
				   l_get_ruleset_data_rec.org_id);


  END Classification_Install;


-- Called by the methods to get the current org_id  and the org_id string rep
PROCEDURE get_cached_org_info (x_cached_org_id OUT NOCOPY integer, x_cached_org_append OUT NOCOPY VARCHAR2) IS
  BEGIN
     SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
     NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99) INTO x_cached_org_id
     FROM DUAL;

    if x_cached_org_id = -99 then
	 x_cached_org_append := '_MINUS99';
    else
	 x_cached_org_append := '_' || x_cached_org_id;
    end if;
END get_cached_org_info;

-- clku
-- procedure to check if a string has paired single quotes
PROCEDURE check_text_paired_quotes (l_in_text IN VARCHAR2,
                                   l_out_paired_quotes OUT NOCOPY BOOLEAN )
  IS
      -- clku
    l_char_count NUMBER;
    a NUMBER;
    l_next_occurance_count NUMBER;


   BEGIN

   l_char_count := 0;
              a := 1;



            IF length(l_in_text) > 0 THEN
              FOR a IN 1..(length(l_in_text) - 1)LOOP



                  IF substr(l_in_text,a,1) = '''' THEN



                      l_char_count := l_char_count + 1;

                   END IF;

               END LOOP;
            END IF;

    IF mod(l_char_count,2) = 1 THEN
          l_out_paired_quotes := FALSE;
    ELSE
          l_out_paired_quotes := TRUE;
    END IF;

    cn_utils.unset_org_id;
    EXCEPTION
  WHEN NO_DATA_FOUND THEN
  return;

END check_text_paired_quotes;
END cn_classification_gen;

/
