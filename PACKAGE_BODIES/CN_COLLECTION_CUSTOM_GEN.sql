--------------------------------------------------------
--  DDL for Package Body CN_COLLECTION_CUSTOM_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTION_CUSTOM_GEN" AS
-- $Header: cncusgenb.pls 120.16.12010000.3 2009/06/05 13:11:02 rajukum ship $


---------------- Private Procedures -------------------+

--+
-- Changed to fix  Bug 6203234 to include PDML
--
--+


PROCEDURE create_parallel_hint(
            x_source_string IN VARCHAR2,
            x_parallel_hint IN OUT NOCOPY VARCHAR2
            ) IS
    l_notification_tables varchar2(1000);
    l_notification_aliases varchar2(1000);
    l_comma_at number;
    l_last_comma_at number;
    l_space_at number;

BEGIN
    l_notification_tables := x_source_string;
    loop

        l_last_comma_at := instr(l_notification_tables, ',',-1,1);

        if(l_last_comma_at=0)
        then
            l_space_at := instr(l_notification_tables, ' ',1,1);
            l_notification_aliases := substr(l_notification_tables,l_space_at+1, length(l_notification_tables)-l_space_at);
            x_parallel_hint := x_parallel_hint || ' PARALLEL('||l_notification_aliases||')';
            exit;
        end if;
        l_notification_aliases := substr(l_notification_tables,l_last_comma_at+1, length(l_notification_tables)-l_last_comma_at);
        l_space_at := instr(l_notification_aliases, ' ',1,1);
        l_notification_aliases := substr(l_notification_aliases,l_space_at+1, length(l_notification_aliases)-l_space_at);

        x_parallel_hint := x_parallel_hint || ' ' || 'PARALLEL('||l_notification_aliases||')';

        l_notification_tables := substr(l_notification_tables,1, l_last_comma_at-1);

    end loop;
    x_parallel_hint := x_parallel_hint || ' *'||'/';
END create_parallel_hint;
---------------- Public Procedures -------------------+



-- Procedure Name
--   insert_cn_not_trx
-- Purpose
--   This procedure generates the Notification code
-- History
--   03-17-00   Dave Maskell    Created for Release 11i2.

  PROCEDURE insert_cn_not_trx (
     x_table_map_id         cn_table_maps.table_map_id%TYPE,
	x_event_id             cn_events.event_id%TYPE,
			code			IN OUT NOCOPY cn_utils.code_type,
			x_org_id 		IN NUMBER)
	 IS

    l_return_status        VARCHAR2(4000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(4000);
    l_notify_from          VARCHAR2(4000);
    l_notify_where         VARCHAR2(4000);
    l_collect_from         VARCHAR2(4000);
    l_collect_where        VARCHAR2(4000);
    l_table_map_rec        cn_table_maps_v%ROWTYPE;
    l_header_key VARCHAR2(100);
    l_line_key   VARCHAR2(100);
    l_org_id     NUMBER;
	l_parallel_hint VARCHAR2(4000) := '/'||'*'||'+';

    CURSOR c_param IS
      SELECT tmov.object_id, LOWER(OBJ.name) object_name
      FROM cn_table_map_objects tmov, cn_objects obj
      WHERE tmov.table_map_id = x_table_map_id
            AND tmov.tm_object_type = 'PARAM'
            and obj.object_id =  tmov.object_id
            and tmov.org_id = obj.org_id
			AND tmov.org_id = x_org_id;
				-- Added For R12 MOAC Change
  BEGIN

  	l_org_id := x_org_id;


   	-- Added For R12 MOAC Change

    --+
    -- Get the Table Map details for this data source
    --+

    SELECT *
    INTO   l_table_map_rec
    FROM   cn_table_maps_v
    WHERE  table_map_id = x_table_map_id
	AND	   org_id = l_org_id; -- Added For R12 MOAC Change
    --+
    -- Get the name of the Line Table primary key
    -- using the form 'alias.column_name'
    --+
    l_line_key := LOWER(
          NVL(l_table_map_rec.source_table_alias,l_table_map_rec.source_table_name)||
          '.'||l_table_map_rec.linepk_name);
    --+
    -- Get the name of the Header Table primary key. There may be no value for
    -- this, in which case we need to use the string 'NULL' for the purposes of
    -- of our generated INSERT statement.
    --+
    IF l_table_map_rec.hdrpk_name IS NULL THEN
        l_header_key := 'NULL';
    ELSE
        l_header_key := LOWER(
          NVL(l_table_map_rec.header_table_alias,l_table_map_rec.header_table_name)||
          '.'||l_table_map_rec.hdrpk_name);
    END IF;

    cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** NOTIFICATION PROCESSING *********-- ');
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''Inserting new transactions into CN_NOT_TRX.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''Inserting new transactions into CN_NOT_TRX.'');');
    cn_utils.appendcr(code);
    --+
    -- Most local variables for the collect procedure are part of a static set, which is generated
    -- for all pacakges (inclding OC and AR) at the start of the procedure by the cn_collection_gen
    -- package. However, for the notification query of Custom data sources, we need local variables
    -- which have the names of the any parameters which have been specified by the user on the Queries
    -- tab of the Collections form. To allow use to do this, we need to enclose the notification query
    -- in its own block.
    --+
    cn_utils.appindcr(code, 'DECLARE -- Notification Insert Block');
    --+
    -- Generate Declarations of parameter variables
    --+
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, '--*** Declaring user-defined Notification Parameters');
    FOR rec IN c_param
    LOOP
      cn_utils.appindcr(code, rec.object_name||'  cn_objects.object_value%TYPE;');
    END LOOP;
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'BEGIN');
    --+
    -- Generate code to initialise parameter variables
    --+
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, '--*** Initializing user-defined Notification Parameters');
    FOR rec IN c_param
    LOOP
      cn_utils.appindcr(code, 'SELECT object_value');
      cn_utils.appindcr(code, 'INTO  '||rec.object_name);
      cn_utils.appindcr(code, 'FROM   cn_objects');
      cn_utils.appindcr(code, 'WHERE  object_id = '||rec.object_id||'  --*** Object_Id for '||rec.object_name);
      cn_utils.appindcr(code, 'AND    org_id = '||l_org_id||';');
      cn_utils.appendcr(code);
    END LOOP;

      	-- Added For R12 MOAC Change
      cn_utils.appendcr(code);
    --+
    -- Insert any User Code specified for the 'Pre-Notification' location
    --+
    Generate_User_Code(
                 p_table_map_id   => x_table_map_id,
                 p_location_name => 'Pre-Notification',
                 code            => code,
				 x_org_id        => l_org_id);

    --+
    -- Generate the FROM and WHERE clauses. Changed position fo fix Bug 6203234
    --+
    cn_table_maps_pvt.get_sql_clauses(
        p_api_version       => 1.0,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
        p_table_map_id      => x_table_map_id,
        x_notify_from       => l_notify_from,
        x_notify_where      => l_notify_where,
        x_collect_from      => l_collect_from,
        x_collect_where     => l_collect_where,
	p_org_id            => l_org_id);


    --+
    -- Changed to fix Bug 6203234 to include PDML in Notification Query
    --
    --+
    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    create_parallel_hint(x_source_string => l_notify_from,
                         x_parallel_hint => l_parallel_hint
                         );
    END IF;

    --+
    -- Generate the INSERT INTO API .. SELECT portion of
    -- the statement
    --+
    cn_utils.set_org_id(l_org_id);
    cn_utils.appindcr(code, '--');
    cn_utils.appindcr(code, '-- Insert new lines into cn_not_trx');
	cn_utils.appindcr(code, '--');
    cn_utils.appindcr(code, '--CN_DB_PARALLEL_ENABLE :'||fnd_profile.value('CN_DB_PARALLEL_ENABLE'));
    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    cn_utils.appindcr(code, 'INSERT /'||'*+ PARALLEL(cn_not_trx) */ INTO  cn_not_trx (');
    ELSE
    cn_utils.appindcr(code, 'INSERT INTO  cn_not_trx (');
    END IF;
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, 'not_trx_id,');
    cn_utils.appindcr(code, 'batch_id,');
    cn_utils.appindcr(code, 'notified_date,');
    cn_utils.appindcr(code, 'notification_run_id,');
    cn_utils.appindcr(code, 'collected_flag,');
    cn_utils.appindcr(code, 'event_id,');
    cn_utils.appindcr(code, 'source_trx_id,');
    cn_utils.appindcr(code, 'source_trx_line_id,');
    cn_utils.appindcr(code, 'source_doc_type,');
    cn_utils.appindcr(code, 'org_id)'); 	-- Added For R12 MOAC Change
    cn_utils.unindent(code, 1);
    --+
    -- Generate the SELECT clause for the insert statement
    --+
    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    cn_utils.appindcr(code, 'SELECT '||l_parallel_hint);
    ELSE
    cn_utils.appindcr(code, 'SELECT ');
    END IF;
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, 'cn_not_trx_s.NEXTVAL,');

    -- Changed for Bug 6203234
    --cn_utils.appindcr(code, 'FLOOR(cn_not_trx_s.CURRVAL/cn_global_var.g_system_batch_size),');
    cn_utils.appindcr(code, 'x_proc_audit_id,');

    cn_utils.appindcr(code, 'SYSDATE,');
    cn_utils.appindcr(code, 'x_proc_audit_id,');
    cn_utils.appindcr(code, '''N'',');
    cn_utils.appindcr(code, x_event_id||',');
    cn_utils.appindcr(code, l_header_key||',     --*** Header Table Key Column');
    cn_utils.appindcr(code, l_line_key||',     --*** Line Table Key Column');
    cn_utils.appindcr(code, ''''||l_table_map_rec.mapping_type||''',     --*** Source Type');
    cn_utils.appindcr(code, l_org_id); 	-- Added For R12 MOAC Change
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'FROM     --*** Line and  (optional) Header Table');
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, l_notify_from);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'WHERE     --*** Header.Primary_Key = Line.Foreign_Key');
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, l_notify_where);
    --+
    -- The generated WHERE clause does not include the supplementary
    -- WHERE clause information that the user may specified, so this
    -- needs to be added on.
    -- Before doing so, strip off trailing ';' on the clause, if one
    -- is present
    --+
    cn_utils.appindcr(code, '--*** Any extra user-defined WHERE statement lines');
    IF l_table_map_rec.notify_where IS NOT NULL THEN
      cn_utils.appindcr(code, 'AND '||RTRIM(l_table_map_rec.notify_where,';'));
    END IF;
    cn_utils.appindcr(code, '--*** End of user-defined WHERE statement lines');

    --+
    -- Finish off the statement
    --+

    cn_utils.appindcr(code, '  AND NOT EXISTS (');
    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    cn_utils.appindcr(code, '    SELECT /'||'*'||'+ PARALLEL(cn_not_trx) '||'*/ 1');
    ELSE
    cn_utils.appindcr(code, '    SELECT 1');
    END IF;
    cn_utils.appindcr(code, '    FROM  cn_not_trx');
    cn_utils.appindcr(code, '    WHERE source_trx_line_id = ' || l_line_key ||'     --*** Line.Primary_Key');
    cn_utils.appindcr(code, '    AND   event_id = ' || x_event_id );
    cn_utils.appindcr(code, '    AND   org_id = ' || l_org_id || ');');
    cn_utils.unindent(code, 1);

    cn_utils.appindcr(code, 'END; -- Notification Insert Block');

    cn_utils.appendcr(code);
    cn_utils.appindcr(code, '-- Commit the notification inserts - they are permanent even if collection fails');
    cn_utils.appindcr(code, 'COMMIT;');
	cn_utils.unset_org_id();

    cn_message_pkg.debug('*** Finished notification run ');
    fnd_file.put_line(fnd_file.Log,'*** Finished notification run ');

    cn_utils.set_org_id(p_org_id => l_org_id);
    cn_utils.appendcr(code);

    cn_utils.appendcr(code, '--******** COLLECT AJUSTMENTS (NEGATE IN API) ********-- ');
    cn_utils.appindcr(code, '-- This will negate those adjusted trx in the API table');
    cn_utils.appindcr(code, 'cn_not_trx_grp.col_adjustments(p_api_version => 1.0,');
    cn_utils.appindcr(code, '                               x_return_status => x_return_status,');
    cn_utils.appindcr(code, '                               x_msg_count => x_msg_count,');
    cn_utils.appindcr(code, '                               x_msg_data => x_msg_data,');

    cn_utils.appindcr(code, '                               p_org_id => '|| l_org_id ||');');
                        -- Added For R12 MOAC Changes
    cn_utils.appendcr(code);

    cn_utils.unset_org_id();
  END insert_cn_not_trx;

--
-- Procedure Name
--   insert_comm_lines_api_select
-- Purpose
--   This procedure uses the Direct Column Mappings to
--   generate the 'INSERT INTO cn_comm_lines_api VALUES (...) SELECT ...'
--   portion of the SQL statement wich populates the api table
--
-- History
--   03-17-00   Dave Maskell    Created for Release 11i2.
--
--
PROCEDURE insert_comm_lines_api_select(
           x_table_map_id   IN     cn_table_maps_v.table_map_id%TYPE,
	       code             IN OUT NOCOPY cn_utils.code_type,
		  x_org_id IN NUMBER,
		  x_parallel_hint  IN VARCHAR2)
IS          -- Added For R12 MOAC Changes


    CURSOR api_direct_maps IS
        SELECT column_map_id, expression, cno.NAME dest_column FROM cn_column_maps ccmv, cn_objects cno
      WHERE ccmv.table_map_id = x_table_map_id
	       AND ccmv.expression IS NOT NULL
	       AND ccmv.calc_ext_table_id IS NULL
		  AND ccmv.update_clause IS NULL
        AND     ccmv.org_id = x_org_id
        AND     ccmv.destination_column_id = cno.object_id
        AND     ccmv.org_id = cno.org_id
        -- Added For R12 MOAC Changes
        ORDER BY dest_column;

BEGIN

  cn_utils.set_org_id(p_org_id => x_org_id);
  IF CN_COLLECTION_GEN.isParallelEnabled THEN
      IF x_table_map_id > 0
      THEN
      cn_utils.appindcr(code, 'INSERT /'||'*+ PARALLEL(cn_comm_lines_api) */ INTO  cn_comm_lines_api (');
      ELSE
      cn_utils.appindcr(code, 'INSERT INTO  cn_comm_lines_api (');
      END IF;
  ELSE
  cn_utils.appindcr(code, 'INSERT INTO  cn_comm_lines_api (');
  END IF;
  cn_utils.indent(code, 1);

  cn_utils.appindcr(code, 'comm_lines_api_id,');
  cn_utils.appindcr(code, 'conc_batch_id,');
  cn_utils.appindcr(code, 'process_batch_id,');
  cn_utils.appindcr(code, 'org_id,');

  -- Insert custom columns using  api_direct_maps  cursor
  cn_utils.appindcr(code, '--*** Direct Mapping Destination Columns');
  FOR l IN api_direct_maps LOOP
    cn_utils.appindcr(code, l.dest_column || ',');
  END LOOP;

    --Changing the number of places to shift to 2 cos of introduction of new char
  cn_utils.strip_prev(code, 1);    --  remove trailing comma
  cn_utils.appindcr(code, ')');
  cn_utils.unindent(code, 1);


  -- Generate the SELECT clause for the insert statement
  IF CN_COLLECTION_GEN.isParallelEnabled THEN
    cn_utils.appindcr(code, 'SELECT '||x_parallel_hint);
  ELSE
    cn_utils.appindcr(code, 'SELECT ');
  END IF;

  cn_utils.indent(code, 1);

  cn_utils.appindcr(code, 'cn_comm_lines_api_s.NEXTVAL,');
  cn_utils.appindcr(code, 'x_conc_program_id,');
  cn_utils.appindcr(code, 'x_batch_id,');
  cn_utils.appindcr(code, x_org_id||',');

  -- Select other columns using the api_direct_maps cursors. Note that
  -- we fetch the records in the cursor in the same order as before due to
  -- the order by column_id in the cursor where clause.

  cn_utils.appindcr(code, '--*** Direct Mapping Source Expressions');

  FOR l IN api_direct_maps LOOP
    -- R12 Related Changes
	IF (l.column_map_id = -1083) THEN
    	l.expression :=  RTRIM(l.expression,')},')||'),'||x_org_id||')';
    END IF;
    IF (l.column_map_id = -1092 OR l.column_map_id = -1093) THEN
    	l.expression :=  RTRIM(l.expression,')},')||','||x_org_id||')';
    END IF;
    cn_utils.appindcr(code, l.expression || ',');
  END LOOP;

  cn_utils.strip_prev(code, 1);	-- remove trailing comma
  cn_utils.appendcr(code);
  cn_utils.unindent(code, 1);
  cn_utils.unset_org_id();

END insert_comm_lines_api_select;

--
-- Procedure Name
--   insert_comm_lines_api
-- Purpose
--   This procedure generates the code to insert into the CN_COMM_LINES_API table
--   This includes the generation of the the code for the Notification Process
-- History
--   03-17-00   Dave Maskell    Created for Release 11i2.
--
--
  PROCEDURE insert_comm_lines_api (
	x_table_map_id		cn_table_maps.table_map_id%TYPE,
	x_event_id             cn_events.event_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type,
	x_org_id IN NUMBER)
	IS

    l_return_status        VARCHAR2(4000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(4000);
    l_notify_from          VARCHAR2(4000);
    l_notify_where         VARCHAR2(4000);
    l_collect_from         VARCHAR2(4000);
    l_collect_where        VARCHAR2(4000);
    l_table_map_rec        cn_table_maps_v%ROWTYPE;
    l_parallel_hint VARCHAR2(4000) := '/'||'*'||'+';
	l_org_id               NUMBER;

  BEGIN

  l_org_id := x_org_id;



    --+
    -- Get the Table Map details for this data source
    --+
    SELECT *
    INTO   l_table_map_rec
    FROM   cn_table_maps_v
    WHERE  table_map_id = x_table_map_id
	AND    org_id = l_org_id;

    --+
    -- Generate the FROM and WHERE clause code. Moved here to fix Bug 6203234
    --+
    cn_table_maps_pvt.get_sql_clauses(
        p_api_version       => 1.0,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
        p_table_map_id      => x_table_map_id,
        x_notify_from       => l_notify_from,
        x_notify_where      => l_notify_where,
        x_collect_from      => l_collect_from,
        x_collect_where     => l_collect_where,
	p_org_id            => l_org_id);

    --+
    -- Changed to fix Bug 6203234 to include PDML in Collection Query
    --
    --+
    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    create_parallel_hint(x_source_string => l_collect_from,
                         x_parallel_hint => l_parallel_hint
                         );
    END IF;
    --+
    -- Generate the Collection Process code
    --+
    cn_utils.set_org_id(p_org_id => X_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** INSERT CN_COMM_LINES_API *********-- ');
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''Inserting into CN_COMM_LINES_API.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''Inserting into CN_COMM_LINES_API.'');');
    cn_utils.appendcr(code);
    --+
    -- Generate the INSERT INTO API .. SELECT portion of
    -- the statement
    --+
    cn_utils.appindcr(code, '--');
    cn_utils.appindcr(code, '-- Insert new lines into CN_COMM_LINES_API');
    cn_utils.appindcr(code, '--');

    cn_utils.unset_org_id();
    -- Change for Bug 6203234
    insert_comm_lines_api_select(x_table_map_id, code, X_org_id, l_parallel_hint);
    cn_utils.set_org_id(p_org_id => l_org_id);

    cn_utils.appindcr(code, 'FROM     --*** Line, (optional) Header, and any Extra Collection Tables');
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, l_collect_from);
    cn_utils.unindent(code, 1);
    cn_utils.appindcr(code, 'WHERE');
    cn_utils.appindcr(code, '--*** Line.Primary_Key = cnt.source_trx_line_id AND (optional) Header.Primary_Key = cnt.source_trx_id');
    cn_utils.indent(code, 1);
    cn_utils.appindcr(code, l_collect_where);

    --+
    -- The generated WHERE clause does not include the supplementary
    -- WHERE clause information that the user may specified, so this
    -- needs to be added on.
    -- Before doing so, strip off trailing ';' on the clause, if one
    -- is present
    --+

    cn_utils.appindcr(code, '--*** Any extra user-defined WHERE statement lines');

    IF l_table_map_rec.collect_where IS NOT NULL THEN
      cn_utils.appindcr(code, 'AND '||RTRIM(l_table_map_rec.collect_where,';'));
    END IF;

    cn_utils.appindcr(code, '--*** End of user-defined WHERE statement lines');

    --+
    -- Finish off the statement
    --+

    cn_utils.appindcr(code, '  AND cnt.event_id = ' || x_event_id);
    cn_utils.appindcr(code, '  AND cnt.collected_flag = ''N''');
    cn_utils.appindcr(code, '  AND cnt.batch_id = x_batch_id');
    cn_utils.appindcr(code, '  AND cnt.org_id = '||l_org_id ||' ;');
    cn_utils.unindent(code, 1);

    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'comm_lines_api_count := SQL%ROWCOUNT;');
    cn_utils.appendcr(code);

    cn_utils.appindcr(code, 'cn_message_pkg.debug(''Inserted '' || comm_lines_api_count || '' line records into CN_COMM_LINES_API.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''Inserted '' || comm_lines_api_count || '' line records into CN_COMM_LINES_API.'');');

    cn_utils.appendcr(code);
    cn_utils.appendcr(code);

    -- Update the collected_flag in CN_NOT_TRX
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''Updating collected_flag in CN_NOT_TRX .'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log,''Updating collected_flag in CN_NOT_TRX .'');');

    cn_utils.appendcr(code);

    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    cn_utils.appindcr(code, 'UPDATE /'||'*+ PARALLEL(cnt) */ cn_not_trx cnt');
    ELSE
    cn_utils.appindcr(code, 'UPDATE cn_not_trx cnt');
    END IF;

    cn_utils.appindcr(code, '   SET collected_flag = ''Y''');
    cn_utils.appindcr(code, ' WHERE cnt.event_id = '|| x_event_id);
    cn_utils.appindcr(code, '   AND cnt.collected_flag = ''N''');
    cn_utils.appindcr(code, '   AND cnt.batch_id = x_batch_id');
    cn_utils.appindcr(code, '   AND cnt.org_id = '||l_org_id||' ;');
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''Updated collected_flag in cn_not_trx.'');');

    IF CN_COLLECTION_GEN.isParallelEnabled THEN
    cn_utils.appindcr(code, 'COMMIT;');
    END IF;

    cn_utils.appendcr(code);
    cn_utils.unset_org_id();

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('insert_lines: in exception handler for NO_DATA_FOUND',1);
      fnd_file.put_line(fnd_file.Log, 'insert_lines: in exception handler for NO_DATA_FOUND');

      RETURN;
  END insert_comm_lines_api;

---------------------------------------------------------- +
-- Procedure Name
--   update_comm_lines_api
--
-- Purpose
--   Generates code to update the CN_COMM_LINES_API table
--   using Indirect Mappings
-- History
-- 16-Mar-00       Dave Maskell          Created
--
  PROCEDURE update_comm_lines_api (
	x_table_map_id		cn_table_maps.table_map_id%TYPE,
	code	IN OUT NOCOPY 	cn_utils.code_type,
	x_org_id IN NUMBER)
	IS

    x_dest_table_name	cn_obj_tables_v.name%TYPE;
    x_dest_alias		cn_obj_tables_v.alias%TYPE;
    x_row_count 		NUMBER;
    x_count			NUMBER;
    CURSOR indmap IS
        SELECT
            cm.expression,
            cm.calc_ext_table_id,
            cm.update_clause,
		  ext.name relationship_name,
            LOWER(obj.NAME) external_table_name,
            LOWER(NVL(ext.alias,obj.NAME)) external_table_alias,
            LOWER(destcol.name) dest_column
        FROM
            cn_column_maps cm,
            cn_obj_columns_v destcol,
            cn_calc_ext_tables ext,
            cn_objects obj
        WHERE
            cm.table_map_id = x_table_map_id
            AND cm.expression IS NOT NULL
            AND (cm.calc_ext_table_id IS NOT NULL
                 OR cm.update_clause IS NOT NULL)
            AND ext.calc_ext_table_id(+) = cm.calc_ext_table_id
        AND obj.object_id(+) = ext.external_table_id
            AND destcol.column_id = cm.destination_column_id
		  -- make sure no old pre 11iv2 mappings to CN_TRX etc. can slip in
		  AND destcol.table_id = -1008  --CN_COMM_LINES_API
        AND cm.org_id = x_org_id
        AND destcol.org_id = cm.org_id
        AND ext.org_id(+) = cm.org_id
        AND obj.org_id(+) = ext.org_id
        ORDER BY destcol.name;

  BEGIN
   -- MO_GLOBAL.INIT('CN');
    cn_utils.set_org_id(x_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** UPDATE CN_COMM_LINES_API ********-- ');
      cn_utils.appindcr(code, '--*** Update columns populated by all INDIRECT mappings');
    --+
    -- Get name and alias of destination table (should be 'cn_comm_lines_api' and 'api')
    --+

 --    SELECT
 --     LOWER(ctmv.destination_table_name),
 --      LOWER(NVL(ctmv.destination_table_alias,ctmv.destination_table_name))

--    INTO
--     x_dest_table_name,
--     x_dest_alias

--	FROM cn_table_maps_v ctmv
--   WHERE ctmv.table_map_id = x_table_map_id
--    AND org_id =x_org_id;

-- Code Change added by pradeep
    SELECT
      LOWER(cB.name),
       LOWER(NVL(cB.alias , cB.name))

    INTO
         x_dest_table_name,
         x_dest_alias
FROM cn_table_maps ctm, CN_OBJECTS CB
WHERE
  ctm.table_map_id = x_table_map_id
and CB.object_id = CTM.destination_table_id
and cb.org_id = ctm.org_id
AND cb.org_id =x_org_id;
-- End of Code Change

    --+
    -- Generate the UPDATE statement
    --+
    -- Check for empty cursor before adding UPDATE command.
    --+
    x_row_count := 0;
    FOR rec IN indmap LOOP
      x_row_count := SQL%ROWCOUNT ;
	 IF (x_row_count > 0) THEN EXIT;
	 END IF;
    END LOOP;
    IF x_row_count >0 THEN
      --+
      -- There are some mappings so generate the statement.
      --+
      cn_utils.appindcr(code, 'UPDATE ' || x_dest_table_name || ' ' || x_dest_alias);
      cn_utils.appindcr(code, '  SET');
      cn_utils.indent(code, 1);

      FOR indmap_rec IN indmap LOOP
	    cn_utils.appindcr(code, indmap_rec.dest_column || ' = (     --*** Indirect Mapping Destination Column');
	    cn_utils.appindcr(code, '  SELECT ');
	    cn_utils.appindcr(code, '    ' || indmap_rec.expression ||'     --*** Indirect Mapping Source Expression');
         IF indmap_rec.external_table_alias IS NOT NULL THEN
           --+
           -- This mapping is based on a defined foreign key relationship
           --+
           cn_utils.appindcr(code, '  --*** FROM/WHERE derived from Relationship: '||indmap_rec.relationship_name);
           cn_utils.appindcr(code, '  FROM   '||indmap_rec.external_table_name||' '||indmap_rec.external_table_alias);
           cn_utils.appindcr(code, '  WHERE');
           x_count := 0;
           --+
           -- Build where clause based on all join columns in the relationship
           --+
           FOR indmap_fk IN
             (SELECT LOWER(pkcol.name) pkcolumn_name,
                     LOWER(fkcol.name) fkcolumn_name
              FROM cn_calc_ext_tbl_dtls dtls,
                   cn_obj_columns_v pkcol,
                   cn_obj_columns_v fkcol
              WHERE dtls.calc_ext_table_id = indmap_rec.calc_ext_table_id
                    AND pkcol.column_id = dtls.external_column_id
                    AND fkcol.column_id = dtls.internal_column_id
                    AND dtls.org_id = x_org_id
                    AND pkcol.org_id = dtls.org_id
                    AND fkcol.org_id = pkcol.org_id)
           LOOP
             IF x_count = 0 THEN
               x_count := 1;
             ELSE
               cn_utils.appindcr(code, '    AND ');
             END IF;
             cn_utils.appindcr(code, '    '||indmap_rec.external_table_alias||'.'||indmap_fk.pkcolumn_name||' = api.'||indmap_fk.fkcolumn_name);
           END LOOP;
           --Added by Ashley for MOAC
           cn_utils.appindcr(code, ' AND api.org_id = '||x_org_id);
	      cn_utils.appindcr(code, '),');
         ELSE
           --+
           -- This mapping is based on a free-form update clause
           --+
           cn_utils.appindcr(code, '  --*** FROM/WHERE taken from Update Clause');
           cn_utils.appindcr(code, '    '||indmap_rec.update_clause||'),');
         END IF;
       END LOOP;
       cn_utils.strip_prev(code, 1);	-- remove trailing comma
       cn_utils.appendcr(code);
       cn_utils.unindent(code, 1);
       cn_utils.appindcr(code, 'WHERE ' || x_dest_alias || '.process_batch_id = x_proc_audit_id');
       --Added by Ashley for MOAC
       cn_utils.appindcr(code, 'AND ' || x_dest_alias || '.org_id = ' || x_org_id || ';');
       cn_utils.appendcr(code);
     END IF;
     --+
     -- Generate code to update the comm_lines_api_update_count variable
     --+
     cn_utils.appendcr(code);
     cn_utils.appindcr(code, 'cn_message_pkg.debug(''For all INDIRECT mappings updated '' || SQL%ROWCOUNT || '' rows in cn_comm_lines_api.'');');
     cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''For all INDIRECT mappings updated '' || SQL%ROWCOUNT || '' rows in cn_comm_lines_api.'');');
     cn_utils.appendcr(code);
     cn_utils.unset_org_id();

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      cn_debug.print_msg('update_lines: in exception handler for NO_DATA_FOUND', 1);
      fnd_file.put_line(fnd_file.Log, 'update_lines: in exception handler for NO_DATA_FOUND');
      RETURN;
  END update_comm_lines_api;

--
-- Procedure Name
--   filter_comm_lines_api
-- Purpose
--   This procedure generates the code to filter out unwanted
--   lines from cn_comm_lines_api
-- History
--   03-29-00   Dave Maskell    Created for Release 11i2.
--
--
  PROCEDURE filter_comm_lines_api(
     x_table_map_id         cn_table_maps.table_map_id%TYPE,
	code	IN OUT NOCOPY            cn_utils.code_type,
	x_org_id IN NUMBER)
	IS

    l_delete_flag VARCHAR2(1);
    l_statement   VARCHAR2(100);
    CURSOR c_filter IS
      SELECT OBJ.object_value
      FROM cn_table_map_objects tmov, cn_objects obj
      WHERE tmov.table_map_id = x_table_map_id
            AND tmov.tm_object_type = 'FILTER'
            and tmov.object_id = obj.object_id
            and tmov.org_id = obj.org_id
            AND tmov.org_id = x_org_id;
  BEGIN
    --+
    -- Decide whether to DELETE lines or just set them to 'FILTERED'
    --+
    SELECT delete_flag
    INTO   l_delete_flag
    FROM   cn_table_maps
    WHERE  table_map_id = x_table_map_id
    AND    org_id = x_org_id;

    IF l_delete_flag = 'Y' THEN
        l_statement := 'DELETE FROM cn_comm_lines_api api';
    ELSE
      l_statement := 'UPDATE cn_comm_lines_api api SET load_status = ''FILTERED''';
    END IF;
    cn_utils.set_org_id(x_org_id);
    cn_utils.appendcr(code);
    cn_utils.appendcr(code, '--******** FILTER PROCESSING *********-- ');
    cn_utils.appindcr(code, 'cn_message_pkg.debug(''Filtering unwanted transactions from cn_comm_lines_api.'');');
    cn_utils.appindcr(code, 'fnd_file.put_line(fnd_file.Log, ''Filtering unwanted transactions from cn_comm_lines_api.'');');
    cn_utils.appendcr(code);
    --+
    -- Generate deletion code
    --+
    cn_utils.appindcr(code, '--*** User-defined filter statements');
    FOR rec IN c_filter
    LOOP
	 --+
      -- Before doing so, strip off trailing ';' on the clause, if one
      -- is present
      --+
      IF SUBSTR(rec.object_value,LENGTH(rec.object_value),1) = ';' THEN
        rec.object_value := SUBSTR(rec.object_value,1,LENGTH(rec.object_value)-1);
      END IF;
      cn_utils.appindcr(code, l_statement);
      cn_utils.appindcr(code, 'WHERE');
      cn_utils.appindcr(code, '  '||rec.object_value);
      cn_utils.appindcr(code, '  AND api.process_batch_id = x_proc_audit_id;');
      cn_utils.appendcr(code);
    END LOOP;
    cn_utils.appindcr(code, '--*** End of User-defined filter statements');
	cn_utils.unset_org_id();
  END filter_comm_lines_api;

--
-- Procedure Name
--   Generate_user_code
-- Purpose
--   Gets user-specificed code for a particular location and generates that code
-- History
--   04-03-00	     Dave Maskell     Created
--
  PROCEDURE Generate_User_Code(
                 p_table_map_id  IN NUMBER,
			  p_location_name IN VARCHAR2,
				code            IN OUT NOCOPY cn_utils.code_type,
				x_org_id 		IN NUMBER)
	IS
  BEGIN
	cn_utils.set_org_id(x_org_id);
    cn_utils.appendcr(code);
    cn_utils.appindcr(code, '--*** User Code, Location: '||p_location_name);
    --+
    -- For every line of User Code registered for this location
    --+
    FOR rec IN
	 (SELECT OBJ.object_value
	  FROM   cn_table_map_objects tmov, cn_objects obj
	  WHERE  tmov.table_map_id = p_table_map_id
	       and obj.object_id = tmov.object_id
	       and tmov.org_id = obj.org_id
		    AND tmov.tm_object_type = 'USERCODE'
		    AND UPPER(OBJ.name) = UPPER(p_location_name)
		    AND tmov.org_id = x_org_id
       ORDER BY table_map_object_id)
    LOOP
      --+
      -- Add a terminal ';' if none was registered
      --+
      IF rec.object_value LIKE '%;' THEN
        cn_utils.appindcr(code, rec.object_value);
      ELSE
        cn_utils.appindcr(code, rec.object_value||';');
      END IF;
    END LOOP;
    cn_utils.appindcr(code, '--*** End of User Code, Location: '||p_location_name);
    cn_utils.appendcr(code);
  cn_utils.unset_org_id();
  END Generate_User_Code;


END cn_collection_custom_gen;

/
