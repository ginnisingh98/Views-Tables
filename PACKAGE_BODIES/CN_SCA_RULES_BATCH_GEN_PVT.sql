--------------------------------------------------------
--  DDL for Package Body CN_SCA_RULES_BATCH_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_RULES_BATCH_GEN_PVT" AS
-- $Header: cnvscabb.pls 120.7 2006/05/08 03:40:41 raramasa noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_SCA_RULES_BATCH_GEN_PVT
-- Purpose
--   This package is a public API for processing Credit Rules and associated
--   allocation percentages.
-- History
--   06/26/03   Rao.Chenna         Created
--
--   Nov 17, 2005   vensrini      Added org_id checks to populate_matches proc





--
-- Global Variables
   g_package_name                cn_obj_packages_v.name%TYPE;
   g_org_id                      cn_sca_credit_rules.org_id%TYPE;
--
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

-- search the next occurence of delimiter '+ - * / ( ) '
-- in sql_select portion and return the position
FUNCTION search_delimiter_select(
   p_input_str 		varchar2,
   p_start 		number)
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



PROCEDURE check_create_object(
	x_name                	cn_objects.name%TYPE,
        x_object_type        	cn_objects.object_type%TYPE,
        x_object_id        	IN OUT NOCOPY cn_objects.object_id%TYPE,
        x_repository_id 	cn_repositories.repository_id%TYPE) IS
   --
   dummy        NUMBER;
   x_rowid 	ROWID;
   --
BEGIN
   -- Check whether this package exists in the cn_objects or not.
   SELECT COUNT(1)
     INTO dummy
     FROM cn_objects
    WHERE name = x_name
      AND object_type = x_object_type;
   --
   IF (dummy = 0) THEN
      --
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
      --
   ELSIF (dummy = 1) THEN
      SELECT object_id
        INTO x_object_id
        FROM cn_objects
       WHERE name = x_name
         AND object_type = x_object_type;
   END IF;
   --
EXCEPTION WHEN OTHERS THEN
   cn_message_pkg.debug('IN check_create_object Exception handler name is '||
                         x_name ||' object_type is '|| x_object_type ||
			' object_id is '|| x_object_id );
   RAISE;
END check_create_object;
--
PROCEDURE pkg_init_boilerplate (
	code		     	IN OUT NOCOPY cn_utils.code_type,
	package_name	 	IN cn_obj_packages_v.name%TYPE,
	description		IN cn_obj_packages_v.description%TYPE,
	object_type		IN VARCHAR2)
IS
	x_userid		VARCHAR2(20);
BEGIN
	SELECT  user
	INTO    x_userid
	FROM    sys.dual;

	cn_utils.appendcr(code, '--+============================================================================+');
	cn_utils.appendcr(code, '--    		       Copyright (c) 1993 Oracle Corporation');
	cn_utils.appendcr(code, '--		             Redwood Shores, California, USA');
	cn_utils.appendcr(code, '--			               All rights reserved.');
	cn_utils.appendcr(code, '--+============================================================================+');
	cn_utils.appendcr(code, '-- Package Name');
	cn_utils.appendcr(code, '--   '||package_name);
	cn_utils.appendcr(code, '-- Purpose');
	cn_utils.appendcr(code, '--   '||description);
	cn_utils.appendcr(code, '-- History');
	cn_utils.appendcr(code, '--   '||SYSDATE||'          '||x_userid ||'            Created');
	cn_utils.appendcr(code, '--+============================================================================+');

	----+
	-- Check For Package type, based on PKS(spec) or PKB(body) generate init section
	-- Of your code accordingly
	----+
	IF (object_type = 'PKS')
	THEN
		cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE ' ||package_name||' AS');
	ELSE
		cn_utils.appendcr(code, 'CREATE OR REPLACE PACKAGE BODY ' ||package_name||' AS');
	END IF;

	cn_utils.appendcr(code);

END pkg_init_boilerplate;
--
PROCEDURE pkg_init (
    module_id		    	       cn_modules.module_id%TYPE,
    package_name		       cn_obj_packages_v.name%TYPE,
    package_spec_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
    package_body_id     IN OUT NOCOPY  cn_obj_packages_v.package_id%TYPE,
    package_spec_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
    package_body_desc   IN OUT NOCOPY  cn_obj_packages_v.description%TYPE,
    spec_code	    	IN OUT NOCOPY  cn_utils.code_type,
    body_code	    	IN OUT NOCOPY  cn_utils.code_type) IS

    x_rowid			ROWID;
    null_id			NUMBER;

BEGIN
	-- Find the package objects
	cn_utils.find_object(package_name,'PKS',package_spec_id, package_spec_desc, g_org_id);
	cn_utils.find_object(package_name,'PKB',package_body_id, package_body_desc, g_org_id);

	-- Delete module source code from cn_source
	-- Delete module object dependencies for this module
	cn_utils.delete_module(module_id, package_spec_id, package_body_id, g_org_id);

	cn_utils.init_code (package_spec_id, spec_code);
	cn_utils.init_code (package_body_id, body_code);

	pkg_init_boilerplate(spec_code, package_name, package_spec_desc, 'PKS');
	pkg_init_boilerplate(body_code, package_name, package_body_desc, 'PKB');

	cn_utils.indent(spec_code, 1);
	cn_utils.indent(body_code, 1);

END pkg_init;
--
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
PROCEDURE populate_matches (
   spec_code              IN OUT NOCOPY cn_utils.code_type,
   body_code              IN OUT NOCOPY cn_utils.code_type ,
   x_transaction_source   IN cn_sca_rule_attributes.transaction_source%TYPE) IS
   --
   procedure_name	cn_obj_procedures_v.name%TYPE;
   procedure_desc       cn_obj_procedures_v.description%TYPE;
   parameter_list       cn_obj_procedures_v.parameter_list%TYPE;
   package_spec_id      cn_obj_packages_v.package_id%TYPE;
   x_repository_id      cn_repositories.repository_id%TYPE;
   l_attr_counter       NUMBER := 1;
   l_rule_counter       NUMBER := 1;
   l_operator_counter	NUMBER := 1;
   l_comb_counter 	NUMBER := 1;
   l_if_counter		NUMBER := 1;
   l_row_num		NUMBER := 0;
   --
-- Cursors Section
CURSOR comb_cur IS
   SELECT distinct rule_attr_comb_value
     FROM cn_sca_combinations sc
     WHERE transaction_source = x_transaction_source
     AND   org_id = g_org_id; -- vensrini
--
CURSOR rule_attr_cur(l_comb_value NUMBER) IS
   SELECT ra.sca_rule_attribute_id,
          ra.src_column_name,
	  ra.datatype
     FROM cn_sca_combinations sc,
          cn_sca_rule_attributes ra
     WHERE sc.sca_rule_attribute_id = ra.sca_rule_attribute_id
     AND sc.org_id = ra.org_id --vensrini
     AND sc.org_id = g_org_id -- vensrini
      AND rule_attr_comb_value = l_comb_value
      AND sc.transaction_source = x_transaction_source
	order by sc.sca_rule_attribute_id;
--
CURSOR operator_cur(l_attribute_id NUMBER) IS
   SELECT lookup_code,meaning
     FROM cn_lookups cl
    WHERE lookup_type = 'SCA_OPERATORS'
      AND EXISTS (
          SELECT 'S'
            FROM cn_sca_conditions csc,
	         cn_sca_cond_details cscd
           WHERE csc.sca_condition_id = cscd.sca_condition_id
             AND csc.org_id = cscd.org_id -- vensrini
             AND csc.org_id = g_org_id   -- vensrini
	     AND cscd.OPERATOR_ID =  cl.lookup_code
	     AND csc.sca_rule_attribute_id = l_attribute_id);
--
BEGIN
   procedure_name := 'populate_matches';
   procedure_desc := 'This procedure is to get matching rules.';
   parameter_list := 'p_start_date              IN      DATE,'||
                     'p_end_date                IN      DATE,'||
		     'p_start_id                IN      NUMBER,'||
		     'p_end_id                  IN      NUMBER,'||
		     'p_physical_batch_id       IN      NUMBER,'||
		     'p_transaction_source      IN      VARCHAR2,'||
		     'p_org_id                  IN      VARCHAR2,'||
                     'x_return_status           OUT NOCOPY   VARCHAR2,'||
                     'x_msg_count          	OUT NOCOPY   NUMBER,'  ||
                     'x_msg_data           	OUT NOCOPY   VARCHAR2';
   --
   proc_init(procedure_name, procedure_desc, parameter_list,'P', 'NUMBER' ,
             package_spec_id, x_repository_id,spec_code, body_code);
   --
   cn_utils.appendcr(body_code, '--+');
   cn_utils.appendcr(body_code, '-- Variables Section');
   cn_utils.appendcr(body_code, '--+');
   cn_utils.appendcr(body_code, '   l_comb_counter      NUMBER := 0;');
   cn_utils.appendcr(body_code, '   l_comb_value_id     NUMBER := 0;');
   --cn_utils.appendcr(body_code, '   l_row_num           NUMBER := 0;');
   --cn_utils.appendcr(body_code, '   l_rule_attribute_id NUMBER := 0;');
   cn_utils.appendcr(body_code, '--+');
   cn_utils.appendcr(body_code, '-- PL/SQL Tables/Records Section');
   cn_utils.appendcr(body_code, '--+');
   cn_utils.appendcr(body_code, '   TYPE comb_value_tbl_type IS ');
   cn_utils.appendcr(body_code, '   TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER; ');
   cn_utils.appendcr(body_code, '   l_comb_value        comb_value_tbl_type; ');

   cn_utils.appendcr(body_code, '--+');
   cn_utils.appendcr(body_code, '-- Cursor to get Rule Attribute Combinations');
   cn_utils.appendcr(body_code, '--+');
   cn_utils.appendcr(body_code, '   CURSOR comb_cur IS ');
   cn_utils.appendcr(body_code, '      SELECT DISTINCT rule_attr_comb_value ');
   cn_utils.appendcr(body_code, '        FROM cn_sca_combinations sc ');
   cn_utils.appendcr(body_code, '       WHERE transaction_source = p_transaction_source');
   cn_utils.appendcr(body_code, '         AND org_id = p_org_id;'); -- vensrini
   --
   cn_utils.appendcr(body_code, 'BEGIN ');
   --
   cn_utils.appendcr(body_code, '   --+');
   cn_utils.appendcr(body_code, '   -- Populate Combinations into a PL/SQL Table');
   cn_utils.appendcr(body_code, '   --+');
   cn_utils.appendcr(body_code, '   FOR rec IN comb_cur ');
   cn_utils.appendcr(body_code, '   LOOP ');
   cn_utils.appendcr(body_code, '      l_comb_counter := l_comb_counter + 1; ');
   cn_utils.appendcr(body_code, '      l_comb_value(l_comb_counter) := rec.rule_attr_comb_value; ');
   cn_utils.appendcr(body_code, '   END LOOP; ');
   cn_utils.appendcr(body_code, '   --+');
   cn_utils.appendcr(body_code, '   -- For Each Rule Attribute Combination, execute the appropriate SQL');
   cn_utils.appendcr(body_code, '   --+');
   cn_utils.appendcr(body_code, '   FOR i IN 1..l_comb_value.COUNT ');
   cn_utils.appendcr(body_code, '   LOOP');

   FOR comb_rec IN comb_cur
   LOOP
      l_row_num := 0;
      --
      IF (l_if_counter = 1) THEN
         cn_utils.appendcr(body_code, '      IF (l_comb_value(i)='||
                                    comb_rec.rule_attr_comb_value||') THEN');
      ELSE
         cn_utils.appendcr(body_code, '      ELSIF (l_comb_value(i)='||
                                    comb_rec.rule_attr_comb_value||') THEN');
      END IF;
      --
      cn_utils.appendcr(body_code, 'l_comb_value_id := l_comb_value(i);');
      cn_utils.appendcr(body_code, 'INSERT /*+ APPEND */ INTO cn_sca_matches(');
      cn_utils.appendcr(body_code, '       sca_credit_rule_id,');
      cn_utils.appendcr(body_code, '       sca_headers_interface_id,');
      cn_utils.appendcr(body_code, '       process_date,');
      cn_utils.appendcr(body_code, '       rank,');
      cn_utils.appendcr(body_code, '       calculated_rank,');
      cn_utils.appendcr(body_code, '       org_id,');
      cn_utils.appendcr(body_code, '       created_by,');
      cn_utils.appendcr(body_code, '       creation_date,');
      cn_utils.appendcr(body_code, '       last_updated_by,');
      cn_utils.appendcr(body_code, '       last_update_date,');
      cn_utils.appendcr(body_code, '       last_update_login)');
      cn_utils.appendcr(body_code, 'SELECT result.sca_credit_rule_id,');
      cn_utils.appendcr(body_code, '       result.sca_headers_interface_id,');
      cn_utils.appendcr(body_code, '       result.processed_date,');
      cn_utils.appendcr(body_code, '       result.rank,');
      cn_utils.appendcr(body_code, '       result.calculated_rank,');
      cn_utils.appendcr(body_code, '       result.org_id,');
      cn_utils.appendcr(body_code, '       fnd_global.user_id,');
      cn_utils.appendcr(body_code, '       SYSDATE,');
      cn_utils.appendcr(body_code, '       fnd_global.user_id,');
      cn_utils.appendcr(body_code, '       SYSDATE,');
      cn_utils.appendcr(body_code, '       fnd_global.login_id');
      cn_utils.appendcr(body_code, '  FROM (');
      --
      FOR rule_attr_rec IN rule_attr_cur(comb_rec.rule_attr_comb_value)
      LOOP
         --
         IF (l_attr_counter > 1) THEN
	    cn_utils.appendcr(body_code, '       UNION ALL');
	 END IF;
	 l_row_num := l_row_num + 1;
	 --
         cn_utils.appendcr(body_code, '       SELECT b.sca_credit_rule_id, ');
         cn_utils.appendcr(body_code, '              c.sca_headers_interface_id, ');
	 cn_utils.appendcr(body_code, '              c.processed_date, ');
         cn_utils.appendcr(body_code, '              b.calculated_rank, ');
	 cn_utils.appendcr(body_code, '              a.rank, ');
	 cn_utils.appendcr(body_code, '              a.org_id ');
	 cn_utils.appendcr(body_code, '         FROM ');
         cn_utils.appendcr(body_code, '              cn_sca_denorm_rules a, ');
         cn_utils.appendcr(body_code, '              cn_sca_rule_cond_vals_mv b, ');
         cn_utils.appendcr(body_code, '              cn_sca_headers_interface c ');
	 cn_utils.appendcr(body_code, '        WHERE a.sca_credit_rule_id = b.sca_credit_rule_id ');
	 cn_utils.appendcr(body_code, '          AND a.sca_credit_rule_id = a.ancestor_rule_id ');
	 cn_utils.appendcr(body_code, '          AND a.rule_attr_comb_value = l_comb_value_id');
	 cn_utils.appendcr(body_code, '          AND a.transaction_source = p_transaction_source ');
	 cn_utils.appendcr(body_code, '          AND a.org_id = p_org_id ');
	 cn_utils.appendcr(body_code, '          AND a.org_id = c.org_id ');
	 cn_utils.appendcr(body_code, '          AND c.process_status = ''SCA_UNPROCESSED'' ');
	 cn_utils.appendcr(body_code, '          AND c.processed_date BETWEEN p_start_date AND p_end_date ');
	 cn_utils.appendcr(body_code, '          AND c.processed_date BETWEEN a.start_date AND NVL(a.end_date,c.processed_date) ');
	 cn_utils.appendcr(body_code, '          AND c.sca_headers_interface_id BETWEEN p_start_id AND p_end_id ');
         cn_utils.appendcr(body_code, '          AND b.sca_rule_attribute_id = (');
         cn_utils.appendcr(body_code, '              SELECT DISTINCT sca_rule_attribute_id ');
	 cn_utils.appendcr(body_code, '                FROM ( SELECT a.*, rownum rnum ');
	 cn_utils.appendcr(body_code, '                         FROM ( SELECT sca_rule_attribute_id ');
	 cn_utils.appendcr(body_code, '                                  FROM cn_sca_combinations sc ');
	 cn_utils.appendcr(body_code, '                                 WHERE sc.rule_attr_comb_value = l_comb_value_id ');
	 cn_utils.appendcr(body_code, '                                   AND sc.org_id = p_org_id ');
         cn_utils.appendcr(body_code, '                                 ORDER BY sc.sca_rule_attribute_id) a ');
         cn_utils.appendcr(body_code, '                        WHERE rownum <= '||l_row_num||') ');
         cn_utils.appendcr(body_code, '               WHERE rnum >= '||l_row_num||') ');
         FOR operator_rec IN operator_cur(rule_attr_rec.sca_rule_attribute_id)
         LOOP
            --
            IF (l_operator_counter = 1) THEN
               cn_utils.appendcr(body_code, '          AND (');
	    END IF;
            --
            IF (l_operator_counter > 1) THEN
               cn_utils.appendcr(body_code, '                OR ');
	    END IF;
            --
            IF (operator_rec.lookup_code = 'EQUAL') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 = b.value_char_min AND ');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 = b.value_num_min AND ');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 = b.value_date_min AND ');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''EQUAL'')');
            ELSIF (operator_rec.lookup_code = 'LIKE') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 LIKE b.value_char_min AND ');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 LIKE b.value_num_min AND ');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 LIKE b.value_date_min AND ');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''LIKE'')');
            ELSIF (operator_rec.lookup_code = 'BETWEEN') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 BETWEEN b.VALUE_CHAR_MIN AND b.VALUE_CHAR_MAX AND');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 BETWEEN b.VALUE_NUM_MIN AND b.VALUE_NUM_MAX  AND');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 BETWEEN b.VALUE_DATE_MIN AND b.VALUE_DATE_MAX AND');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''BETWEEN'')');
            ELSIF (operator_rec.lookup_code = 'GRE') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 >= b.VALUE_CHAR_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 >= b.VALUE_NUM_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 >= b.VALUE_DATE_MIN AND ');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''GRE'')');
            ELSIF (operator_rec.lookup_code = 'GT') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 > b.VALUE_CHAR_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 > b.VALUE_NUM_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 > b.VALUE_DATE_MIN AND ');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''GT'')');
            ELSIF (operator_rec.lookup_code = 'LTE') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 <= b.VALUE_CHAR_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 <= b.VALUE_NUM_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 <= b.VALUE_DATE_MIN AND ');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''LTE'')');
            ELSIF (operator_rec.lookup_code = 'LT') THEN
               cn_utils.appendcr(body_code, '                   (c.'||rule_attr_rec.src_column_name);
               IF (rule_attr_rec.datatype = 'ALPHANUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 < b.VALUE_CHAR_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'NUMERIC') THEN
	          cn_utils.appendcr(body_code, '                 < b.VALUE_NUM_MIN AND ');
               ELSIF (rule_attr_rec.datatype = 'DATE') THEN
	          cn_utils.appendcr(body_code, '                 < b.VALUE_DATE_MIN AND ');
	       END IF;
	       cn_utils.appendcr(body_code, '                 b.operator_id = ''LT'') ');
	    END IF;
	    --
	    l_operator_counter := l_operator_counter + 1;
	    --
         END LOOP;
	 --
	 IF (l_operator_counter > 1) THEN
            cn_utils.appendcr(body_code, '               )');
	 END IF;
	 --
         cn_utils.appendcr(body_code, '        GROUP BY b.sca_credit_rule_id, c.sca_headers_interface_id, ');
         cn_utils.appendcr(body_code, '              c.processed_date, b.calculated_rank, a.rank, a.org_id ');
	 --
	 l_operator_counter := 1;
	 l_attr_counter := l_attr_counter + 1;
	 --
      END LOOP;
      l_if_counter := l_if_counter + 1;
      l_attr_counter := 1;
      cn_utils.appendcr(body_code, ') result ');
      cn_utils.appendcr(body_code, 'GROUP BY result.sca_credit_rule_id, ');
      cn_utils.appendcr(body_code, '         result.sca_headers_interface_id, ');
      cn_utils.appendcr(body_code, '         result.processed_date, ');
      cn_utils.appendcr(body_code, '         result.calculated_rank, ');
      cn_utils.appendcr(body_code, '         result.rank, ');
      cn_utils.appendcr(body_code, '         result.org_id ');
      cn_utils.appendcr(body_code, 'HAVING (result.sca_credit_rule_id,count(1)) = ( ');
      cn_utils.appendcr(body_code, '	SELECT r.sca_credit_rule_id,r.num_rule_attributes ');
      cn_utils.appendcr(body_code, '         FROM cn_sca_denorm_rules r ');
      cn_utils.appendcr(body_code, '        WHERE r.sca_credit_rule_id = result.sca_credit_rule_id ');
      cn_utils.appendcr(body_code, '          AND r.org_id = p_org_id ');
      cn_utils.appendcr(body_code, '          AND r.ancestor_rule_id = result.sca_credit_rule_id ');
      cn_utils.appendcr(body_code, '          AND r.transaction_source = p_transaction_source);');
      cn_utils.appendcr(body_code, 'COMMIT work;');
   END LOOP;

   cn_utils.appendcr(body_code, '      END IF;');
   cn_utils.appendcr(body_code, '   END LOOP;');

   cn_utils.appindcr(body_code, 'EXCEPTION ');
   cn_utils.appindcr(body_code, '   WHEN OTHERS THEN ');
   cn_utils.appindcr(body_code, '      cn_message_pkg.debug(''EXCEPTION IN populate_matches, '' || sqlerrm); ');
   cn_utils.appindcr(body_code, '      raise; ');

   cn_utils.appendcr(body_code, 'END;');

EXCEPTION when others then
     cn_message_pkg.debug('IN get_perf exception handler, error is '||sqlcode||' '||sqlerrm);
     RAISE;
END populate_matches;

FUNCTION create_sca_rules_batch_dyn (
   x_transaction_source   IN   cn_sca_rule_attributes.transaction_source%TYPE)
   RETURN BOOLEAN IS
   -- Variables Section
   package_name              cn_obj_packages_v.name%TYPE;
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
   --
BEGIN

	cn_utils.set_org_id(g_org_id);

	select repository_id into l_repository_id
	from cn_repositories where org_id = g_org_id;


   package_name := 'cn_sca_batch_'||lower(x_transaction_source)||'_'||
                    abs(g_org_id)||'_pkg';
   g_package_name := package_name;

   --dbms_output.put_line('package_name  '||package_name);
   check_create_object(package_name, 'PKS', package_spec_id, l_repository_id);
   check_create_object(package_name, 'PKB', package_body_id, l_repository_id);

   --dbms_output.put_line('package_spec_id  '||package_spec_id);
   --dbms_output.put_line('package_body_id  '||package_body_id);
   --
   pkg_init(
		module_id	    =>  l_module_id,
		package_name	    =>  package_name,
		package_spec_id     =>  package_spec_id,
		package_body_id     =>  package_body_id,
		package_spec_desc   =>  package_spec_desc,
		package_body_desc   =>  package_body_desc,
		spec_code	    =>  spec_code,
		body_code           =>  body_code);
   --DBMS_OUTPUT.PUT_LINE('pkg init called');
   --
   populate_matches(spec_code, body_code,x_transaction_source);
   --
   cn_utils.pkg_end(package_name, spec_code, body_code);
   --
   cn_utils.unset_org_id;
   --
   RETURN TRUE;
END;
--
PROCEDURE gen_sca_rules_batch_dyn(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   p_org_id	           IN  NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_transaction_source    IN  cn_sca_rule_attributes.transaction_source%TYPE)IS

    l_api_name                     CONSTANT VARCHAR2(30) := 'gen_sca_rules_batch_dyn';
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
     --codeCheck: For a concurrent program this kind of code is not required.
     --codeCheck: I may need to change this one.

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
     -- SELECT org_id INTO l_org_id FROM cn_repositories;
     g_org_id := p_org_id;

     l_pkg_name := 'cn_sca_batch_'||lower(x_transaction_source)||'_'||
                    abs(g_org_id)||'_pkg';

     l_status := create_sca_rules_batch_dyn(x_transaction_source);

     --dbms_output.put_line('l_pkg_name :'||l_pkg_name);

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

         --dbms_output.put_line('pkg id is  '|| l_pkg_object_id );

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
           WHERE co.name =  l_pkg_name
           AND co.object_type = 'PKB'
	   AND co.org_id = g_org_id;

         --dbms_output.put_line('pkb id is  '|| l_pkg_object_id );

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
         --dbms_output.put_line('The rule dynamic package is created successfully. ' );

         -- check whether package is installed successfully
         SELECT  COUNT(*)
           INTO  l_error_count
           FROM user_errors
           WHERE name = upper(l_pkg_name)
           AND  TYPE IN ('PACKAGE', 'PACKAGE BODY');

         IF l_error_count = 0 THEN
            NULL;
            --dbms_output.put_line('sucess compilation');
         ELSE
            x_return_status := FND_API.g_ret_sts_error;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
               fnd_message.set_name('CN', 'CN_DYN_PKG_COMPILE_ERR');
               FND_MSG_PUB.ADD;
            END IF;
         END IF;
      ELSE
         x_return_status := FND_API.g_ret_sts_error;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
            fnd_message.set_name('CN', 'CN_DYN_PKG_COMPILE_ERR');
            FND_MSG_PUB.ADD;
         END IF;
      END IF;

      IF FND_API.To_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        -- codeCheck: This needs to be changed
        --ROLLBACK TO generate_formula;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO generate_formula;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE
           );
     WHEN OTHERS THEN
        --ROLLBACK TO generate_formula;
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
END gen_sca_rules_batch_dyn;
--
END cn_sca_rules_batch_gen_pvt;

/
