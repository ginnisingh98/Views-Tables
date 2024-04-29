--------------------------------------------------------
--  DDL for Package Body ZPB_TRANSFORM_IO_TABLES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_TRANSFORM_IO_TABLES" AS
/* $Header: zpblevels.plb 115.22 2004/07/01 23:46:54 memayer ship $ */
PROCEDURE AddRow(p_dimensions  curr_dims_table,
             p_dimtable IN DimTabTyp,
             p_temp_table IN VARCHAR2,
             p_member IN zpb_solve_input_levels.member%TYPE,
             p_leveltype IN VARCHAR2,
             p_userid  IN NUMBER,
             p_memberorder IN zpb_solve_input_levels.MEMBER_ORDER%TYPE)

IS
  dimcount     INTEGER;
  counter      INTEGER;
  tableinsert  VARCHAR2(5000);
  tablevalues  VARCHAR2(5000);
  CALCULATED_SOURCE INTEGER := 1200;

  BEGIN
    counter := 1;
    dimcount := p_dimensions.count;
    tableinsert := 'INSERT INTO ' || p_temp_table || '(MEMBER, ';
    tableinsert := tableinsert || ' LEVEL_TYPE,  MEMBER_ORDER,  USER_ID, ';
    tablevalues := ' VALUES(' || '''' || p_member || '''' || ', ';
    tablevalues := tablevalues || '''' || p_leveltype || '''' || ', ';
    tablevalues := tablevalues || p_memberorder || ', ';
    tablevalues := tablevalues || p_userid || ', ';
   WHILE counter <= dimcount
    LOOP
      --tableinsert := tableinsert || p_dimtable(counter).dimension;
      tableinsert := tableinsert || p_dimensions(counter);
      IF p_dimtable(1).loaded = CALCULATED_SOURCE THEN
        tablevalues := tablevalues || '''' || ' ' || '''';
      ELSIF p_dimtable.count < counter THEN
        tablevalues := tablevalues || '''' || ' ' || '''';
      ELSE
        tablevalues := tablevalues || '''' || p_dimtable(counter).io_level || '''';
      END IF;
      IF counter = dimcount THEN
        tableinsert := tableinsert || ')';
        tablevalues := tablevalues || ')';
      ELSE
        tableinsert := tableinsert || ',  ';
        tablevalues := tablevalues || ', ';
      END IF;
      counter := counter + 1;
    END LOOP;

    EXECUTE IMMEDIATE tableinsert || tablevalues;

  END AddRow;

  PROCEDURE ZPB_TRANSFORM_INPUT_TABLE (p_ac_id IN NUMBER,
                                      p_line_dim IN VARCHAR2,
                                      p_temp_table IN VARCHAR2,
                                      p_userid  IN NUMBER,
                                      p_view_dim_name IN VARCHAR2,
                                      p_view_member_column IN VARCHAR2,
                                      p_view_long_lbl_column IN VARCHAR2,
                                      labelCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor,
                                      dataCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor)

  IS

    Dimtable     DimTabTyp;
    dimcount     INTEGER;
    counter      INTEGER;
    member       zpb_solve_input_levels.member%TYPE;
    memberorder  zpb_solve_input_levels.MEMBER_ORDER%TYPE;
    rowcount     BINARY_INTEGER;
    bStart       BOOLEAN;
    tableSelect  VARCHAR2(5000);
    c4           ZPB_TRANSFORM_IO_TABLES.ref_cursor;
    dimensions  curr_dims_table;
    TYPE  level_rec IS RECORD (
          member       zpb_solve_input_levels.member%TYPE,
          memberorder  zpb_solve_input_levels.MEMBER_ORDER%TYPE,
          dimension    zpb_solve_input_levels.dimension%TYPE,
          input_level  VARCHAR2(2000),
          SOURCE_TYPE  zpb_solve_member_defs.SOURCE_TYPE%TYPE);

    input_rec   level_rec;


    BEGIN

--make sure we have data
       SELECT DISTINCT(Dimension) bulk collect into dimensions
          FROM zpb_solve_output_levels
          WHERE ANALYSIS_CYCLE_ID = p_ac_id
          ORDER BY Dimension;

       dimcount := dimensions.count;
       IF dimcount = 0 THEN
         raise NO_DATA_FOUND;
       END IF;

--delete rows from previous run
       tableSelect := 'DELETE FROM ' || p_temp_table || ' WHERE USER_ID = ' ;
       tableSelect := tableSelect || p_userid || ' AND LEVEL_TYPE = ''' || INPUT_TYPE || '''';
       EXECUTE IMMEDIATE tableSelect;
       rowcount := 1;
       bStart := true;

       tableSelect := 'SELECT DISTINCT def.member, def.member_order, ';
       tableSelect := tableSelect || ' nvl(input.dimension, ';
       tableSelect := tableSelect || '''' || '-'|| '''';
       tableSelect := tableSelect || ') AS dimension,';
       tableSelect := tableSelect || ' levellookup.OBJECT_LONG_LABEL
                                       AS input_level, def.SOURCE_TYPE ';
       tableSelect := tableSelect || ' FROM  ((zpb_solve_member_defs def ';
       tableSelect := tableSelect || ' LEFT OUTER JOIN zpb_solve_input_levels input
        ON def.member = input.member
        AND def.ANALYSIS_CYCLE_ID = input.ANALYSIS_CYCLE_ID)
        LEFT OUTER JOIN ZPB_SESSION_METADATA_LABELS levellookup ';
        tableSelect := tableSelect ||
          'ON levellookup.dimension = input.dimension
          AND levellookup.OBJECT_AW_NAME = input.input_level ';
          tableSelect := tableSelect  || ' AND levellookup.USER_ID = ' ||  p_userid   ;
          tableSelect := tableSelect  || ' AND levellookup.OBJECT_TYPE = ';
          tableSelect := tableSelect  || '''' || 'LEVEL' || '''' || ')';
        tableSelect := tableSelect || ' WHERE def.ANALYSIS_CYCLE_ID = ';
        tableSelect := tableSelect || p_ac_id;

        tableSelect := tableSelect  || ' ORDER BY 1, 3';

       OPEN c4 FOR tableSelect;
  LOOP
      FETCH c4 into input_rec;
      EXIT WHEN c4%NOTFOUND;
      IF bStart THEN
        member := input_rec.member;
        memberorder := input_rec.memberorder;
        Dimtable(rowcount).dimension := input_rec.dimension;
        Dimtable(rowcount).io_level  := input_rec.input_level;
        Dimtable(rowcount).loaded  := input_rec.SOURCE_TYPE;
        bStart := false;
      ELSIF member <> input_rec.member THEN
        AddRow(dimensions, Dimtable, p_temp_table, member, INPUT_TYPE, p_userid, memberorder);
        rowcount := 1;
        member := input_rec.member;
        memberorder := input_rec.memberorder;
        Dimtable(rowcount).dimension := input_rec.dimension;
        Dimtable(rowcount).io_level  := input_rec.input_level;
        Dimtable(rowcount).loaded  := input_rec.SOURCE_TYPE;
      ELSIF Dimtable(rowcount).dimension <> input_rec.dimension THEN
        rowcount := rowcount + 1;
        Dimtable(rowcount).dimension := input_rec.dimension;
        Dimtable(rowcount).io_level  := input_rec.input_level;
        Dimtable(rowcount).loaded  := input_rec.SOURCE_TYPE;
      ELSE
        Dimtable(rowcount).io_level  := Dimtable(rowcount).io_level || ', ' ||
           input_rec.input_level;
      END IF;
  END LOOP;

   AddRow(dimensions, Dimtable, p_temp_table, member, INPUT_TYPE, p_userid, memberorder);

   tableSelect := 'SELECT OBJECT_LONG_LABEL' ||
     ' FROM ZPB_SESSION_METADATA_LABELS' ||
     ' WHERE USER_ID = ' || p_userid ||
     ' AND OBJECT_TYPE =  ''' || 'DIMENSION' || '''' ||
     ' AND OBJECT_AW_NAME IN' ||
     ' (SELECT Dimension FROM ZPB_SOLVE_OUTPUT_LEVELS' ||
     ' WHERE ANALYSIS_CYCLE_ID = ' || p_ac_id || ')' ||
     ' ORDER BY Dimension';

   OPEN labelCursor FOR tableSelect;

   tableSelect := 'SELECT solvetemp.MEMBER as member, memberlookup.';
   tableSelect := tableSelect || p_view_long_lbl_column || ' as MemberName, ';
   counter := 1;
   for indx IN dimensions.FIRST .. dimensions.LAST
     LOOP
     tableselect := tableselect || 'solvetemp.' || dimensions(indx);
     IF counter < dimcount THEN
       tableselect := tableselect || ',  ';
     END IF;
     counter := counter + 1;
    END LOOP;
   tableselect := tableselect || ' FROM ' ||  p_temp_table || ' solvetemp, ';
   tableselect := tableselect || p_view_dim_name || ' memberlookup ';
   tableselect := tableselect || ' WHERE solvetemp.LEVEL_TYPE = ''' || INPUT_TYPE || '''';
   tableselect := tableselect || ' AND solvetemp.MEMBER = memberlookup.';
   tableselect := tableselect || p_view_member_column;
   tableselect := tableselect || ' ORDER BY solvetemp.MEMBER_ORDER';

   OPEN dataCursor FOR tableSelect;


  END ZPB_TRANSFORM_INPUT_TABLE;

  PROCEDURE ZPB_TRANSFORM_OUTPUT_TABLE (p_ac_id IN NUMBER,
                                       p_line_dim IN VARCHAR2,
                                       p_temp_table IN VARCHAR2,
                                       p_userid  IN NUMBER,
                                       p_view_dim_name IN VARCHAR2,
                                       p_view_member_column IN VARCHAR2,
                                       p_view_long_lbl_column IN VARCHAR2,
                                       labelCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor,
                                       dataCursor OUT NOCOPY ZPB_TRANSFORM_IO_TABLES.ref_cursor)

    IS

    Dimtable     DimTabTyp;
    dimcount     INTEGER;
    counter      INTEGER;
    member       zpb_solve_output_levels.member%TYPE;
    memberorder  zpb_solve_output_levels.MEMBER_ORDER%TYPE;
    rowcount     BINARY_INTEGER;
    bStart       BOOLEAN;
    tableSelect  VARCHAR2(5000);
    c4           ZPB_TRANSFORM_IO_TABLES.ref_cursor;
    dimensions  curr_dims_table;
    TYPE  level_rec IS RECORD (
          member       zpb_solve_output_levels.member%TYPE,
          memberorder  zpb_solve_output_levels.MEMBER_ORDER%TYPE,
          dimension    zpb_solve_output_levels.dimension%TYPE,
          hierarchy    zpb_solve_output_levels.hierarchy%TYPE,
          output_level    VARCHAR2(2000));



    output_rec   level_rec;

    BEGIN

      SELECT DISTINCT(Dimension) bulk collect into dimensions
          FROM zpb_solve_output_levels
          WHERE ANALYSIS_CYCLE_ID = p_ac_id
          ORDER BY Dimension;

      dimcount := dimensions.count;
      IF dimcount = 0 THEN
         raise NO_DATA_FOUND;
       END IF;

      --delete rows from previous run
       tableSelect := 'DELETE FROM ' || p_temp_table || ' WHERE USER_ID = ' ;
       tableSelect := tableSelect || p_userid || ' AND LEVEL_TYPE = ''' || OUTPUT_TYPE || '''';
       EXECUTE IMMEDIATE tableSelect;
      rowcount := 1;
      bStart := true;

    tableSelect := 'SELECT distinct output.member, output.member_order, ';
    tableSelect := tableSelect || ' output.dimension AS dimension,
       output.hierarchy AS hierarchy,
       levellookup.OBJECT_LONG_LABEL AS output_level
     FROM  zpb_solve_output_levels output ';
     tableSelect := tableSelect || ' INNER JOIN ZPB_SESSION_METADATA_LABELS levellookup
      ON levellookup.dimension = output.dimension
      AND levellookup.OBJECT_AW_NAME = output.output_level
     WHERE output.ANALYSIS_CYCLE_ID = ';
     tableSelect := tableSelect  || p_ac_id;
     tableSelect := tableSelect  || ' AND levellookup.USER_ID = ' ||  p_userid   ;
     tableSelect := tableSelect  || ' AND levellookup.OBJECT_TYPE = ';
     tableSelect := tableSelect  || '''' || 'LEVEL' || '''';
     tableSelect := tableSelect  || ' ORDER BY output.member, output.dimension';

      OPEN c4 FOR tableSelect;


    LOOP
      FETCH c4 into output_rec;
      EXIT WHEN c4%NOTFOUND;
      IF bStart THEN
        member := output_rec.member;
        memberorder := output_rec.memberorder;
        Dimtable(rowcount).dimension := output_rec.dimension;
        Dimtable(rowcount).io_level  := output_rec.output_level;
        bStart := false;
      ELSIF member <> output_rec.member THEN
        AddRow(dimensions, Dimtable, p_temp_table, member, OUTPUT_TYPE, p_userid, memberorder);
        rowcount := 1;
        member := output_rec.member;
        memberorder := output_rec.memberorder;
        Dimtable(rowcount).dimension := output_rec.dimension;
        Dimtable(rowcount).io_level  := output_rec.output_level;
      ELSIF Dimtable(rowcount).dimension <> output_rec.dimension THEN
        rowcount := rowcount + 1;
        Dimtable(rowcount).dimension := output_rec.dimension;
        Dimtable(rowcount).io_level  := output_rec.output_level;
      ELSE
        Dimtable(rowcount).io_level  := Dimtable(rowcount).io_level || ', ' ||
           output_rec.output_level;
      END IF;
  END LOOP;

   AddRow(dimensions, Dimtable, p_temp_table, member, OUTPUT_TYPE, p_userid, memberorder);

   tableSelect := 'SELECT OBJECT_LONG_LABEL' ||
     ' FROM ZPB_SESSION_METADATA_LABELS' ||
     ' WHERE USER_ID = ' || p_userid ||
     ' AND OBJECT_TYPE =  ''' || 'DIMENSION' || '''' ||
     ' AND OBJECT_AW_NAME IN' ||
     ' (SELECT Dimension FROM ZPB_SOLVE_OUTPUT_LEVELS' ||
     ' WHERE ANALYSIS_CYCLE_ID = ' || p_ac_id || ')' ||
     ' ORDER BY Dimension';

   OPEN labelCursor FOR tableSelect;

   tableSelect := 'SELECT solvetemp.MEMBER as member, memberlookup.';
   tableSelect := tableSelect || p_view_long_lbl_column || ' as MemberName, ';
   counter := 1;
   for indx IN dimensions.FIRST .. dimensions.LAST
     LOOP
     tableselect := tableselect || 'solvetemp.' || dimensions(indx);
     IF counter < dimcount THEN
       tableselect := tableselect || ',  ';
     END IF;
     counter := counter + 1;
    END LOOP;
   tableselect := tableselect || ' FROM ' ||  p_temp_table || ' solvetemp, ';
   tableselect := tableselect || p_view_dim_name || ' memberlookup ';
   tableselect := tableselect || ' WHERE solvetemp.LEVEL_TYPE = ''' || OUTPUT_TYPE || '''';
   tableselect := tableselect || ' AND solvetemp.MEMBER = memberlookup.';
   tableselect := tableselect || p_view_member_column;
   tableselect := tableselect || ' ORDER BY solvetemp.MEMBER_ORDER';

   OPEN dataCursor FOR tableSelect;

  END ZPB_TRANSFORM_OUTPUT_TABLE;

END ZPB_TRANSFORM_IO_TABLES;

/
