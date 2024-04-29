--------------------------------------------------------
--  DDL for Package Body GL_SUMMARY_ACCOUNT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SUMMARY_ACCOUNT_TYPES_PKG" as
/* $Header: gluacsmb.pls 120.7 2006/08/09 22:01:33 cma ship $ */

  ---
  --- PUBLIC FUNCTIONS
  ---

  PROCEDURE update_account_types(coa_id			NUMBER,
				 min_ccid_processed	NUMBER) IS



    acct_segcol	  VARCHAR2(30);
    acct_vsetid   NUMBER;
    acct_tname    VARCHAR2(240);
    acct_vcolname VARCHAR2(240);
    acct_attrib   VARCHAR2(240);
    acct_psegcol  VARCHAR2(30);
    acct_pvsetid  NUMBER;

    ccid_update   VARCHAR2(3000);
    ccid_cursor   INTEGER;

    rows_processed  INTEGER;

    position_qualifier INTEGER;

    -- The below cursor evaluates the position of natural account qualifier
    -- Bug Fix : 2814746
    -- Bug Fix : 2950238, Modified the  logic of the below cursor.

    CURSOR pos_qualifier_curr(par_flex_value_set_id number) IS
           SELECT rownum, value_attribute_type
	   FROM ( SELECT value_attribute_type
           FROM fnd_flex_validation_qualifiers
           WHERE id_flex_code = 'GL#'
           AND  id_flex_application_id = 101
           AND  flex_value_set_id = par_flex_value_set_id
           ORDER by assignment_date, value_attribute_type ) ;


  BEGIN

    -- dbms_output.enable(10000);

    SELECT seg.application_column_name, vs.flex_value_set_id,
	   vs.parent_flex_value_set_id,
           vt.application_table_name, vt.value_column_name,
           decode(vt.compiled_attribute_column_name,
                  'NULL', null,
                  vt.compiled_attribute_column_name)
    INTO  acct_segcol, acct_vsetid, acct_pvsetid,
          acct_tname, acct_vcolname, acct_attrib
    FROM  fnd_flex_validation_tables vt,
	  fnd_flex_value_sets  vs,
	  fnd_id_flex_segments seg,
          fnd_segment_attribute_values qual
    WHERE qual.application_id         = 101
    AND   qual.id_flex_code           = 'GL#'
    AND   qual.id_flex_num            = coa_id
    AND   qual.segment_attribute_type = 'GL_ACCOUNT'
    AND   qual.attribute_value        = 'Y'
    AND   seg.application_id          = qual.application_id
    AND   seg.id_flex_code            = qual.id_flex_code
    AND   seg.id_flex_num             = qual.id_flex_num
    AND   seg.application_column_name = qual.application_column_name
    AND   vs.flex_value_set_id        = seg.flex_value_set_id
    AND   vt.flex_value_set_id(+)     = vs.flex_value_set_id;

    IF (acct_pvsetid IS NOT NULL) THEN
      SELECT application_column_name
      INTO   acct_psegcol
      FROM   fnd_id_flex_segments pseg
      WHERE  application_id      = 101
      AND    id_flex_code        = 'GL#'
      AND    id_flex_num         = coa_id
      AND    flex_value_set_id+0 = acct_pvsetid
      AND    segment_num = (SELECT min(segment_num)
	  		    FROM   fnd_id_flex_segments pseg2
			    WHERE  application_id      = 101
                            AND    id_flex_code        = 'GL#'
		            AND    id_flex_num         = coa_id
		            AND    flex_value_set_id+0 = acct_pvsetid);
    ELSE
      acct_psegcol := NULL;
    END IF;

    -- fetching the value of natual account type qualifier position
    -- into  position_qualifier ( Bug Fix: 2814746)

     FOR pos_qual_rec in  pos_qualifier_curr(acct_vsetid) loop
        if pos_qual_rec.value_attribute_type = 'GL_ACCOUNT_TYPE'
    	  THEN
		 position_qualifier := pos_qual_rec.rownum;
	         exit ;
       end if;
    end loop;



    ccid_update :=
      'UPDATE gl_code_combinations cc ' ||
      'SET    account_type ';

     -- Bug Fix: 2814746 Replaced the hard coded positions from substr stmt
     -- compiled_value_attributes column.

    IF (acct_tname IS NULL) THEN
      ccid_update := ccid_update ||
        '= (SELECT decode(vs.flex_value, ''T'', ''O'', ' ||
                   'substrb( fnd_global.newline||vs.compiled_value_attributes||fnd_global.newline,
		             instrb( fnd_global.newline||vs.compiled_value_attributes||fnd_global.newline,
			             fnd_global.newline,1,:1
				    )+1, 1
		             )) ' ||
           'FROM   fnd_flex_values vs ' ||
           'WHERE  vs.flex_value_set_id = ' || to_char(acct_vsetid) || ' ' ||
           'AND    vs.flex_value = cc.' || acct_segcol || ' ';

      IF (acct_psegcol IS NOT NULL) THEN
        ccid_update := ccid_update ||
           'AND    vs.parent_flex_value_low = cc.' || acct_psegcol || ' ),';
      ELSE
        ccid_update := ccid_update || '),';
      END IF;

    ELSE
      ccid_update := ccid_update ||
        '= (SELECT decode(cc2.' || acct_segcol || ', ''T'', ''O'', ' ||
                     'decode(vs.rowid, NULL, ';

      IF (acct_attrib IS NULL) THEN
        ccid_update := ccid_update || '''O'', ';
      ELSIF (substr(acct_attrib, 1, 1) = '''') THEN
        ccid_update := ccid_update ||
	               'substrb(fnd_global.newline||' || acct_attrib || '||fnd_global.newline,
		                instrb(fnd_global.newline||' ||acct_attrib || '||fnd_global.newline,
				       fnd_global.newline,1,:2
				       ) +1,
			       1), ';
      ELSE
        ccid_update := ccid_update ||
	               'substrb(fnd_global.newline||vt.' || acct_attrib || '||fnd_global.newline,
		                instrb(fnd_global.newline||vt.' || acct_attrib || '||fnd_global.newline,
				       fnd_global.newline,1,:3
				       ) +1,
			        1), ';
      END IF;

     -- Bug Fix: 2814746 Replaced the hard coded positions from substr stmt
     -- compiled_value_attributes column.

      ccid_update := ccid_update ||
                         'substrb( fnd_global.newline||vs.compiled_value_attributes||fnd_global.newline,
			           instrb( fnd_global.newline||vs.compiled_value_attributes||fnd_global.newline,
				           fnd_global.newline,1,:4
					  )+1, 1
				  ) )) ' ||
           'FROM   fnd_flex_values vs, gl_code_combinations cc2, ' ||
                   acct_tname || ' vt ' ||
           'WHERE  cc2.rowid = cc.rowid ' ||
           'AND    vs.flex_value_set_id(+)= :5 '||
           'AND    vs.flex_value(+) = cc2.' || acct_segcol || ' ' ||
           'AND    vs.summary_flag(+) = ''Y'' ' ||
           'AND    vt.'||acct_vcolname||'(+) = cc2.'||acct_segcol||'), ';
    END IF;

    ccid_update := ccid_update ||
             'last_update_date  = sysdate, ' ||
             'last_updated_by   = 1 ' ||
      'WHERE chart_of_accounts_id = :6 ' ;

    ccid_update := ccid_update ||
      'AND   code_combination_id >= :7 ' ||
      'AND   template_id IS NOT NULL ';

    ccid_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(ccid_cursor, ccid_update, dbms_sql.v7);
    IF (acct_tname IS NULL) THEN
	dbms_sql.bind_variable(ccid_cursor, ':1', position_qualifier);
    ELSE
	IF(acct_attrib IS NOT NULL AND substr(acct_attrib, 1, 1) = '''') THEN
	    dbms_sql.bind_variable(ccid_cursor, ':2', position_qualifier);
	ELSIF(acct_attrib IS NOT NULL) THEN
	    dbms_sql.bind_variable(ccid_cursor, ':3', position_qualifier);
	END IF;
	dbms_sql.bind_variable(ccid_cursor, ':4', position_qualifier);
	dbms_sql.bind_variable(ccid_cursor, ':5', acct_vsetid);
    END IF;
    dbms_sql.bind_variable(ccid_cursor, ':6', coa_id);
    dbms_sql.bind_variable(ccid_cursor, ':7', min_ccid_processed);
    rows_processed := dbms_sql.execute(ccid_cursor);
    dbms_sql.close_cursor(ccid_cursor);

  EXCEPTION
    WHEN OTHERS THEN
      dbms_sql.close_cursor(ccid_cursor);
      IF (sqlcode = -1407) THEN
	RAISE INVALID_COMBINATION;
      ELSE
	RAISE;
      END IF;
  END update_account_types;

END GL_SUMMARY_ACCOUNT_TYPES_PKG;

/
