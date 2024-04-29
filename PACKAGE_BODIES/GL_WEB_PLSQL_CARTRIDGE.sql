--------------------------------------------------------
--  DDL for Package Body GL_WEB_PLSQL_CARTRIDGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_WEB_PLSQL_CARTRIDGE" as
/* $Header: glwplcrb.pls 120.5.12010000.2 2015/12/04 07:03:35 rorobans ship $ */


--
-- PUBLIC PROCEDURES
--

PROCEDURE GCS_CHVHTML(X_Consolidation_Set_Id  IN NUMBER,
                      X_Display_Option IN VARCHAR2 ,
                      X_Appl_Id IN NUMBER ,
                      X_User_Id IN NUMBER ,
                      X_Resp_Id IN NUMBER ,
                      X_Mode IN VARCHAR2 DEFAULT 'R') IS
  pc_delimit  VARCHAR2(2) := '^';  -- delimiter between parent and child nodes
  ss_delimit  VARCHAR2(2) := '|';  -- delimiter between ledger and set/mapping
  se_delimit  VARCHAR2(2) := '!';  -- closing of set/mapping
  mapping_set_name     VARCHAR2(33);
  cons_child_set       VARCHAR2(1500);  -- Buffer for the select statement
  child_set_cursor     INTEGER;         -- Handles the child set cursor
  to_ledger_id         NUMBER;
  from_ledger_id       NUMBER;
  to_ledger_name       VARCHAR2(800);
  from_ledger_name     VARCHAR2(800);
  child_set_id         NUMBER;
  prior_child_set_id   VARCHAR2(10000) := NULL;
  all_parent_ledger_id VARCHAR2(10000) := NULL;
  temp_arg_list        VARCHAR2(1500) := NULL;
  child_set_name       VARCHAR2(33);
  mapping_name         VARCHAR2(33);
  counter              NUMBER := 0;
  node_count           NUMBER := 1;
  argc                 NUMBER := 0;
  row_count            NUMBER := 0;
  instr_value          NUMBER := 0;
  dummy                NUMBER;
  from_ledger_list     VARCHAR2(500);
  Pos                  NUMBER;
  title                VARCHAR2(240);
  gcs_title            VARCHAR2(240);
  gcs_message          VARCHAR2(240);

  to_ledger_coa	       NUMBER;
  from_ledger_coa      NUMBER;
  segment	       VARCHAR2(80);
  delim		       VARCHAR2(1) := '';
  child_seg	       VARCHAR2(500);
  temp_child_seg       VARCHAR2(500);
  seg_cursor	       INTEGER;	-- handles the segment cursor

  CURSOR ledger_cons_set IS
         SELECT distinct to_ledger.ledger_id,
                to_ledger.name ||
			'\nCurrency: ' || to_ledger.currency_code ||
			'\nCalendar: ' || to_ledger.period_set_name ||
			'\nChart of Accounts: ',
		to_ledger.chart_of_accounts_id,
                cs1.name,
		from_ledger.ledger_id,
                from_ledger.name ||
			'\nCurrency: ' || from_ledger.currency_code ||
			'\nCalendar: ' || from_ledger.period_set_name ||
			'\nChart of Accounts: ',
		from_ledger.chart_of_accounts_id,
		cs2.consolidation_set_id, cs2.name
	 FROM
                gl_ledgers to_ledger,
		gl_ledgers from_ledger,
		gl_cons_set_assignments csa,
		gl_consolidation_sets cs1,
		gl_consolidation_sets cs2,
		gl_consolidation c
	 WHERE  cs1.consolidation_set_id = csa.consolidation_set_id
	 AND	csa.consolidation_id =  c.consolidation_id
	 AND 	c.from_ledger_id = from_ledger.ledger_id
	 AND	c.to_ledger_id = to_ledger.ledger_id
	 AND	cs2.consolidation_set_id(+) = csa.child_consolidation_set_id
	 AND	cs1.consolidation_set_id = X_Consolidation_Set_Id ;

  CURSOR both_cons_set IS
         SELECT to_ledger.ledger_id,
                to_ledger.name ||
			'\nCurrency: ' || to_ledger.currency_code ||
			'\nCalendar: ' || to_ledger.period_set_name ||
			'\nChart of Accounts: ',
		to_ledger.chart_of_accounts_id,
                cs1.name,
		from_ledger.ledger_id,
                from_ledger.name ||
			'\nCurrency: ' || from_ledger.currency_code ||
			'\nCalendar: ' || from_ledger.period_set_name ||
			'\nChart of Accounts: ',
		from_ledger.chart_of_accounts_id,
		cs2.consolidation_set_id, cs2.name, c.name
	 FROM
                gl_ledgers to_ledger,
		gl_ledgers from_ledger,
		gl_consolidation c,
		gl_cons_set_assignments csa,
		gl_consolidation_sets cs1,
		gl_consolidation_sets cs2
	 WHERE  cs1.consolidation_set_id = csa.consolidation_set_id
	 AND	csa.consolidation_id =  c.consolidation_id
	 AND 	c.from_ledger_id = from_ledger.ledger_id
	 AND	c.to_ledger_id = to_ledger.ledger_id
	 AND	cs2.consolidation_set_id(+) = csa.child_consolidation_set_id
	 AND	cs1.consolidation_set_id = X_Consolidation_Set_Id ;

  CURSOR seg (coa number) is
	SELECT  form_left_prompt
	FROM	fnd_id_flex_segments_tl
	WHERE	id_flex_num = coa
	AND	application_id = 101
	AND	id_flex_code = 'GL#'
	AND	language = userenv('LANG');

BEGIN

  FND_GLOBAL.APPS_INITIALIZE(X_user_id, X_resp_id, X_appl_id);

    --Check function security for access
  IF (NOT FND_FUNCTION.TEST('GLXCOMST')) THEN
    htp.p('<HTML>');
    htp.p('<HEAD>');
    htp.p('<TITLE>no access </TITLE>');
    htp.p('</HEAD>');
    htp.p('</HTML>');

  ELSE

    SELECT name
    INTO   mapping_set_name
    FROM   GL_CONSOLIDATION_SETS
    WHERE  consolidation_set_id = X_Consolidation_Set_Id;


    IF (X_Mode = 'R') THEN

        -- Select the titles and messages from gl_lookups
        SELECT description
        INTO   title
        FROM   GL_LOOKUPS
        WHERE  lookup_type = 'CONSOLIDATION_VIEWER'
        AND    lookup_code = 'CHV_TITLE';

        SELECT description
        INTO   gcs_title
        FROM   GL_LOOKUPS
        WHERE  lookup_type = 'CONSOLIDATION_VIEWER'
    AND    lookup_code = 'FEATURE_NAME';

    SELECT description
    INTO   gcs_message
    FROM   GL_LOOKUPS
    WHERE  lookup_type = 'CONSOLIDATION_VIEWER'
    AND    lookup_code = 'FEATURE_MESSAGE';

    -- Print html to the browser if the procedure is called in 'Run' mode.
    htp.p('<HTML>');
    htp.p('<HEAD>');
    htp.p('<TITLE>Oracle Consolidation Hierarchy Viewer</TITLE>');
    htp.p('</HEAD>');
    htp.p('<BODY BACKGROUND="/OA_JAVA/oracle/apps/media/glBG.gif">');
    htp.p('<table border=0 cellspacing=0 cellpadding=0>');
    htp.p('<tr><td colspan=2>');
    htp.p('<IMG SRC="/OA_JAVA/oracle/apps/media/glchv.gif" ');
    htp.p('ALIGN=TOP  HEIGHT="22" WIDTH="700" BORDER="0"><br>');
    htp.p('<IMG SRC="/OA_JAVA/oracle/apps/media/glspace.gif" ');
    htp.p('ALIGN=TOP  WIDTH="1" HEIGHT="15" BORDER="0"><BR>');
    htp.p('<IMG SRC="/OA_JAVA/oracle/apps/media/glspace.gif" ');
    htp.p('ALIGN=TOP WIDTH="15" HEIGHT="1" BORDER="0">');
    htp.p('<FONT face=Helvetica color=white size=+2>' || mapping_set_name || '</FONT><br>');
    htp.p('<IMG SRC="/OA_JAVA/oracle/apps/media/glspace.gif" ');
    htp.p('ALIGN=TOP  WIDTH="1" HEIGHT="7" BORDER="0"><BR>');
    htp.p('</td></tr>');
    htp.p('<tr>');
    htp.p('	<td width = 390 >');
    htp.p('		<center><img src="/OA_JAVA/oracle/apps/media/GCS.jpg"></center>');
    htp.p('		<img src="/OA_JAVA/oracle/apps/media/GL.gif">');
    htp.p('		</td>');
    htp.p('	<td>');
    htp.p('	<IMG SRC="/OA_JAVA/oracle/apps/media/glspace.gif" ');
    htp.p('	ALIGN=TOP  WIDTH="1" HEIGHT="7" BORDER="0"><BR>');
    htp.p('<applet codebase="/OA_JAVA/" code="oracle.apps.gl.gcs.glcoview.class" height=480 width=580');
--    htp.p('<applet codebase="/OA_JAVA/" code="oracle.apps.gl.gcs.glcoview.class" height=450 width=550');
--    htp.p('<applet codebase="/OA_JAVA/" code="oracle.apps.gl.gcs.glcoview.class"');
    htp.p(' archive="oracle/apps/gl/jar/glgcs.jar">');
--    htp.p('>');
    htp.p('<param name=title value="' || title || ' (' || mapping_set_name || ')">');
    htp.p('<param name=display value="' || FND_CSS_PKG.ENCODE(X_Display_Option) || '">');
    htp.p('<param name=pc_delimit value="' || pc_delimit || '">');
    htp.p('<param name=ss_delimit value="' || ss_delimit || '">');
    htp.p('<param name=se_delimit value="' || se_delimit || '">');
    htp.p('<param name=background_color value="0xFFFFFF">');
  END IF;

  IF (X_Display_Option = 'LEDGER') THEN
  	OPEN ledger_cons_set;
  ELSE
  	OPEN both_cons_set;
  END IF;

  LOOP
    IF (X_Display_Option = 'LEDGER') THEN
      FETCH ledger_cons_set INTO to_ledger_id, to_ledger_name, to_ledger_coa,
			mapping_set_name,
                        from_ledger_id, from_ledger_name, from_ledger_coa,
                        child_set_id, child_set_name ;
      mapping_name := '';
      EXIT WHEN ledger_cons_set%NOTFOUND;
    ELSE
      FETCH both_cons_set INTO to_ledger_id, to_ledger_name, to_ledger_coa,
			mapping_set_name,
                        from_ledger_id, from_ledger_name, from_ledger_coa,
                        child_set_id, child_set_name, mapping_name ;
      EXIT WHEN both_cons_set%NOTFOUND;
    END IF;

    counter := counter + 1;
    node_count := node_count + 1;
    argc := argc + 1;

    IF (child_set_name IS NULL) THEN
      temp_arg_list := ss_delimit || mapping_name || se_delimit ;
    ELSE
      temp_arg_list := ss_delimit || child_set_name || se_delimit ;
    END IF;

    IF (X_Mode = 'R') THEN
      -- get the delimiter
      delim := fnd_flex_apis.get_segment_delimiter(
                 x_application_id       => 101,
                 x_id_flex_code         => 'GL#',
                 x_id_flex_num          => to_ledger_coa);

      -- build the parent chart of account structure
      OPEN seg(to_ledger_coa);
      FETCH seg INTO segment;
      to_ledger_name := to_ledger_name || segment;
      FETCH seg INTO segment;
      WHILE (seg%FOUND) LOOP
      	to_ledger_name := to_ledger_name || delim || segment;
	FETCH seg INTO segment;
      END LOOP;

      CLOSE seg;

      -- get the delimiter
      delim := fnd_flex_apis.get_segment_delimiter(
                 x_application_id       => 101,
                 x_id_flex_code         => 'GL#',
                 x_id_flex_num          => from_ledger_coa);

      -- build the subsidary chart of account structure
      OPEN seg(from_ledger_coa);
      FETCH seg INTO segment;
      from_ledger_name := from_ledger_name || segment;
      FETCH seg INTO segment;
      WHILE (seg%FOUND) LOOP
      	from_ledger_name := from_ledger_name || delim || segment;
	FETCH seg INTO segment;
      END LOOP;

      CLOSE seg;

      -- build the argument list
      htp.p('<param name=args' || to_char(argc) || ' value="' || to_ledger_name || ' ' ||
             ss_delimit || mapping_set_name || se_delimit || pc_delimit ||
             from_ledger_name || ' ' || temp_arg_list || '">');
    END IF;

    -- concatenate additional comma to the list
    IF ((counter > 1) AND (prior_child_set_id IS NOT NULL) AND
        (child_set_id IS NOT NULL)) THEN
      prior_child_set_id := prior_child_set_id || ', ';
    END IF;

    -- concatenate the child set id to the list
    IF (to_char(child_set_id) IS NOT NULL) THEN
      prior_child_set_id := prior_child_set_id || to_char(child_set_id);
    END IF;

    IF (counter = 1) THEN
      all_parent_ledger_id := ',' || to_char(from_ledger_id) || ',';
    ELSE
      all_parent_ledger_id := all_parent_ledger_id || to_char(from_ledger_id) || ',';
    END IF;

  END LOOP;

  all_parent_ledger_id := all_parent_ledger_id || to_char(to_ledger_id) || ',';

  IF (X_Display_Option = 'LEDGER') THEN
    CLOSE ledger_cons_set;
  ELSE
    CLOSE both_cons_set;
  END IF;

  IF (counter = 0) THEN
    fnd_message.set_name('SQLGL', 'GL_CONS_NO_CHILD');
    app_exception.raise_exception;
  END IF;


  IF (prior_child_set_id IS NOT NULL) THEN


    LOOP
      -- Build the select statement for child sets.
      IF (X_Display_Option = 'LEDGER') THEN
          cons_child_set := 'SELECT distinct to_ledger.ledger_id,to_ledger.name || ' ||
                                '''\nCurrency: ''' || ' || to_ledger.currency_code || ' ||
                                '''\nCalendar: ''' || '|| to_ledger.period_set_name || ' ||
                                '''\nChart of Accounts: ''' || ', ' ||
				'to_ledger.chart_of_accounts_id, ' ||
                                'cs1.name, ' ||
                                'from_ledger.ledger_id, from_ledger.name || ' ||
                                '''\nCurrency: ''' || ' || from_ledger.currency_code || ' ||
                                '''\nCalendar: ''' || '|| from_ledger.period_set_name || ' ||
                                '''\nChart of Accounts: ''' || ', ' ||
				'from_ledger.chart_of_accounts_id, ' ||
                                'cs2.consolidation_set_id, cs2.name ' ||
	                'FROM   gl_ledgers to_ledger, ' ||
		               'gl_ledgers from_ledger, ' ||
		               'gl_consolidation c, ' ||
		               'gl_cons_set_assignments csa, ' ||
		               'gl_consolidation_sets cs1, ' ||
		               'gl_consolidation_sets cs2 ' ||
	                'WHERE  cs1.consolidation_set_id = ' ||
			        'csa.consolidation_set_id ' ||
	                'AND    csa.consolidation_id = ' ||
			        'c.consolidation_id ' ||
	                'AND    c.from_ledger_id = ' ||
			        'from_ledger.ledger_id ' ||
	                'AND    c.to_ledger_id = ' ||
			        'to_ledger.ledger_id ' ||
	                'AND    cs2.consolidation_set_id(+) = csa.child_consolidation_set_id ' ||
	                'AND    cs1.consolidation_set_id IN ( ' || prior_child_set_id || ')' ;
     ELSE
          cons_child_set := 'SELECT distinct to_ledger.ledger_id,to_ledger.name || ' ||
                                '''\nCurrency: ''' || ' || to_ledger.currency_code || ' ||
                                '''\nCalendar: ''' || '|| to_ledger.period_set_name || ' ||
                                '''\nChart of Accounts: ''' || ', ' ||
				'to_ledger.chart_of_accounts_id, ' ||
                                'cs1.name, ' ||
                                'from_ledger.ledger_id, from_ledger.name || ' ||
                                '''\nCurrency: ''' || ' || from_ledger.currency_code || ' ||
                                '''\nCalendar: ''' || '|| from_ledger.period_set_name || ' ||
                                '''\nChart of Accounts: ''' || ', ' ||
				'from_ledger.chart_of_accounts_id, ' ||
                                'cs2.consolidation_set_id, cs2.name, c.name ' ||
	                'FROM   gl_ledgers to_ledger, ' ||
		               'gl_ledgers from_ledger, ' ||
		               'gl_consolidation c, ' ||
		               'gl_cons_set_assignments csa, ' ||
		               'gl_consolidation_sets cs1, ' ||
		               'gl_consolidation_sets cs2 ' ||
	                'WHERE  cs1.consolidation_set_id = ' ||
			        'csa.consolidation_set_id ' ||
	                'AND    csa.consolidation_id = ' ||
			        'c.consolidation_id ' ||
	                'AND    c.from_ledger_id = ' ||
			        'from_ledger.ledger_id ' ||
	                'AND    c.to_ledger_id = ' ||
			        'to_ledger.ledger_id ' ||
	                'AND    cs2.consolidation_set_id(+) = csa.child_consolidation_set_id ' ||
	                'AND    cs1.consolidation_set_id IN ( ' || prior_child_set_id || ')' ;
      END IF;

      -- declare the cursor and work with it
      child_set_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(child_set_cursor, cons_child_set, dbms_sql.v7);
      dbms_sql.define_column(child_set_cursor, 1, to_ledger_id);
      dbms_sql.define_column(child_set_cursor, 2, to_ledger_name, 200);
      dbms_sql.define_column(child_set_cursor, 3, to_ledger_coa);
      dbms_sql.define_column(child_set_cursor, 4, mapping_set_name, 33);
      dbms_sql.define_column(child_set_cursor, 5, from_ledger_id);
      dbms_sql.define_column(child_set_cursor, 6, from_ledger_name, 200);
      dbms_sql.define_column(child_set_cursor, 7, from_ledger_coa);
      dbms_sql.define_column(child_set_cursor, 8, child_set_id);
      dbms_sql.define_column(child_set_cursor, 9, child_set_name, 33);
      IF (X_Display_Option = 'BOTH' or X_Display_Option = 'SET') THEN
      	dbms_sql.define_column(child_set_cursor, 10, mapping_name, 33);
      END IF;

      dummy := dbms_sql.execute(child_set_cursor);

      -- build the select statement for the chart of account cursor
      temp_child_seg := 'SELECT  form_left_prompt ' ||
			'FROM	fnd_id_flex_segments_tl ' ||
			'WHERE	application_id = 101 '||
			'AND	id_flex_code = ''GL#'' ' ||
			'AND	language = userenv(''LANG'') ';

      prior_child_set_id := NULL;
      counter := 0;

      LOOP
        row_count := dbms_sql.fetch_rows(child_set_cursor);
        IF (row_count = 0) THEN
          EXIT;
        END IF;

        dbms_sql.column_value(child_set_cursor, 1, to_ledger_id);
        dbms_sql.column_value(child_set_cursor, 2, to_ledger_name);
        dbms_sql.column_value(child_set_cursor, 3, to_ledger_coa);
        dbms_sql.column_value(child_set_cursor, 4, mapping_set_name);
        dbms_sql.column_value(child_set_cursor, 5, from_ledger_id);
        dbms_sql.column_value(child_set_cursor, 6, from_ledger_name);
        dbms_sql.column_value(child_set_cursor, 7, from_ledger_coa);
        dbms_sql.column_value(child_set_cursor, 8, child_set_id);
        dbms_sql.column_value(child_set_cursor, 9, child_set_name);
        IF (X_Display_Option = 'BOTH' or X_Display_Option = 'SET') THEN
          dbms_sql.column_value(child_set_cursor, 10, mapping_name);
	ELSE
	  mapping_name := '';
        END IF;

        node_count := node_count + 1;
        argc := argc + 1;
        counter := counter + 1;

        IF (child_set_name IS NULL) THEN
      	  temp_arg_list := ss_delimit || mapping_name || se_delimit ;
        ELSE
          temp_arg_list := ss_delimit || child_set_name || se_delimit ;
        END IF;

        IF (X_Mode = 'R') THEN
     	  -- get the delimiter
      	  delim := fnd_flex_apis.get_segment_delimiter(
                 	x_application_id       => 101,
                 	x_id_flex_code         => 'GL#',
                 	x_id_flex_num          => to_ledger_coa);

	  -- get parent chart of accounts information
	  child_seg := temp_child_seg ||
				'AND	id_flex_num = ' || to_ledger_coa ;

	  seg_cursor := dbms_sql.open_cursor;
      	  dbms_sql.parse(seg_cursor, child_seg, dbms_sql.v7);
      	  dbms_sql.define_column(seg_cursor, 1, segment,80);
	  dummy := dbms_sql.execute(seg_cursor);

          row_count := dbms_sql.fetch_rows(seg_cursor);
          IF (row_count = 0) THEN
            EXIT;
          END IF;

          dbms_sql.column_value(seg_cursor, 1, segment);
	  to_ledger_name := to_ledger_name || segment;

          row_count := dbms_sql.fetch_rows(seg_cursor);
	  WHILE (row_count <> 0) LOOP
            dbms_sql.column_value(seg_cursor, 1, segment);
	    to_ledger_name := to_ledger_name || delim || segment;
            row_count := dbms_sql.fetch_rows(seg_cursor);
	  END LOOP;

	  dbms_sql.close_cursor(seg_cursor);

     	  -- get the delimiter
      	  delim := fnd_flex_apis.get_segment_delimiter(
                 	x_application_id       => 101,
                 	x_id_flex_code         => 'GL#',
                 	x_id_flex_num          => from_ledger_coa);

	  -- get subsidary chart of accounts information
	  child_seg := temp_child_seg ||
				'AND	id_flex_num = ' || from_ledger_coa ;

	  seg_cursor := dbms_sql.open_cursor;
      	  dbms_sql.parse(seg_cursor, child_seg, dbms_sql.v7);
      	  dbms_sql.define_column(seg_cursor, 1, segment,80);
	  dummy := dbms_sql.execute(seg_cursor);

          row_count := dbms_sql.fetch_rows(seg_cursor);
          IF (row_count = 0) THEN
            EXIT;
          END IF;

          dbms_sql.column_value(seg_cursor, 1, segment);
	  from_ledger_name := from_ledger_name || segment;

          row_count := dbms_sql.fetch_rows(seg_cursor);
	  WHILE (row_count <> 0) LOOP
            dbms_sql.column_value(seg_cursor, 1, segment);
	    from_ledger_name := from_ledger_name || delim || segment;
            row_count := dbms_sql.fetch_rows(seg_cursor);
	  END LOOP;

	  dbms_sql.close_cursor(seg_cursor);

          -- build the argument list
          htp.p('<param name=args' || to_char(argc) || ' value="' || to_ledger_name || ' ' ||
                ss_delimit || mapping_set_name || se_delimit || pc_delimit ||
                from_ledger_name || ' ' || temp_arg_list || '">');
        END IF;

        from_ledger_list := ',' || from_ledger_id || ',' ;

        instr_value := INSTR(all_parent_ledger_id, from_ledger_list);
        IF (instr_value <> 0) THEN
          fnd_message.set_name('SQLGL', 'GL_CONS_LOOP_FOUND');
          app_exception.raise_exception;
        END IF;

        -- concatenate additional comma to the list
        IF ((counter > 1) AND (prior_child_set_id IS NOT NULL) AND
            (child_set_id IS NOT NULL)) THEN
           prior_child_set_id := prior_child_set_id || ', ';
        END IF;

        -- concatenate the child set id to the list
        IF (to_char(child_set_id) IS NOT NULL) THEN
          prior_child_set_id := prior_child_set_id || to_char(child_set_id);
        END IF;

        all_parent_ledger_id := all_parent_ledger_id || to_char(to_ledger_id) || ',';

      END LOOP;

      IF (prior_child_set_id IS NULL) THEN
        EXIT;
      END IF;

      -- Close the cursor
      dbms_sql.close_cursor(child_set_cursor);

    END LOOP;

  END IF;

    IF (X_Mode = 'R') THEN
      htp.p('<param name=nodes value="' || to_char(node_count) || '">');
      htp.p('<param name=argc  value="' || to_char(argc) || '">');
      htp.p('</applet>');
      htp.p('	</td>');
      htp.p('</tr>');
      htp.p('</TABLE>');
      htp.p('</BODY>');
      htp.p('</HTML>');
    END IF;
  END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'GL_WEB_PLSQL_CARTRIDGE.gcs_chvhtml');
      RAISE;

END GCS_CHVHTML ;


END GL_WEB_PLSQL_CARTRIDGE ;

/
