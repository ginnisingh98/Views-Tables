--------------------------------------------------------
--  DDL for Package Body QLTSTORB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTSTORB" as
/* $Header: qltstorb.plb 115.2 2002/11/27 19:34:44 jezheng ship $ */

-- 3/8/95 - CREATED
-- Kevin Wiggen

--  This is a storage unit used for creating the FK Lookups in the
--  Selection Criteria Engine, and in the Dynamic View Creation
--
  -- Well actually this is the server and we don't have record groups,
  -- so I'm am going to fake it with PLSQL tables
  -- In this way the procedures can be the same for the client and server

  TYPE numtable IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
  TYPE char30table IS TABLE OF VARCHAR2(30)
        INDEX BY BINARY_INTEGER;
  TYPE char15table IS TABLE OF VARCHAR2(15)
        INDEX BY BINARY_INTEGER;
  TYPE char80table IS TABLE OF VARCHAR2(80)
        INDEX BY BINARY_INTEGER;
  TYPE char5table IS TABLE OF VARCHAR2(5)
        INDEX BY BINARY_INTEGER;
  TYPE char2000table IS TABLE OF VARCHAR2(2000)
        INDEX BY BINARY_INTEGER;

 -- The following are used to reset the tables

  empty_numtable numtable;
  empty_char30table char30table;
  empty_char15table char15table;
  empty_char80table char80table;
  empty_char5table char5table;
  empty_char2000table char2000table;

 -- The following mimic the kevin record group on the client

  char_num numtable;
  hardcoded_column char30table;
  result_column_name char30table;
  datatype numtable;
  op char15table;
  low char80table;
  high char80table;
  sel numtable;
  disp_len numtable;
  promptt char80table;
  orderr numtable;
  totall numtable;
  functionn numtable;
  fxn_promptt char30table;
  precisionn numtable;
  fk_lookup_typee numtable;
  fk_table_namee char30table;
  fk_table_short_namee char5table;
  pk_idd char30table;
  pk_idd2 char30table;
  pk_idd3 char30table;
  fk_idd char30table;
  fk_idd2 char30table;
  fk_idd3 char30table;
  fk_meaningg char30table;
  fk_descc char30table;
  fk_add_wheree char2000table;
  table_namee char80table;
  parent_block_namee char30table;
  list_idd numtable;
  TOTAL_ROWS BINARY_INTEGER := 0;

 -- The following mimic the daedsiluap record group on the client

  from_partial char2000table;
  ROWS_FROM BINARY_INTEGER := 0;

 -- The following mimic the maggard record group on the client

  where_partial char2000table;
  ROWS_WHERE BINARY_INTEGER := 0;


   PROCEDURE MAKE_REC_GROUP IS


  BEGIN
    char_num := empty_numtable;
    hardcoded_column := empty_char30table;
    result_column_name := empty_char30table;
    datatype := empty_numtable;
    op := empty_char15table;
    low := empty_char80table;
    high := empty_char80table;
    sel := empty_numtable;
    disp_len := empty_numtable;
    promptt := empty_char80table;
    orderr := empty_numtable;
    totall := empty_numtable;
    functionn := empty_numtable;
    fxn_promptt := empty_char30table;
    precisionn := empty_numtable;
    fk_table_namee := empty_char30table;
    fk_table_short_namee := empty_char5table;
    pk_idd := empty_char30table;
    pk_idd2 := empty_char30table;
    pk_idd3 := empty_char30table;
    fk_idd := empty_char30table;
    fk_idd2 := empty_char30table;
    fk_idd3 := empty_char30table;
    fk_meaningg := empty_char30table;
    fk_descc := empty_char30table;
    fk_add_wheree := empty_char2000table;
    table_namee := empty_char80table;
    parent_block_namee := empty_char30table;
    list_idd := empty_numtable;
    TOTAL_ROWS := 0;
  END MAKE_REC_GROUP;


   PROCEDURE ADD_ROW_TO_REC_GROUP (NUM NUMBER,
				   HARD_COLUMN VARCHAR2,
				   RES_COL_NAME VARCHAR2,
 			  	   DATA NUMBER,
				   OPER VARCHAR2,
				   LOW_VAL VARCHAR2,
				   HIGH_VAL VARCHAR2,
                                   SELE NUMBER,
				   DISP_LENGTH NUMBER,
				   PROMPT VARCHAR2,
				   ORDER_SEQ NUMBER,
				   TOTAL NUMBER,
				   FUNCTION NUMBER,
				   FXN_PROMPT VARCHAR2,
				   PRECISION NUMBER,
				   FK_LOOK_TYPE NUMBER,
				   FK_TABL_NAME VARCHAR2,
				   FK_TABL_SH_NAME VARCHAR2,
				   PK_ID VARCHAR2,
			           PK_ID2 VARCHAR2,
  				   PK_ID3 VARCHAR2,
				   FK_ID VARCHAR2,
				   FK_ID2 VARCHAR2,
				   FK_ID3 VARCHAR2,
				   FK_MEANING VARCHAR2,
				   FK_DESC VARCHAR2,
				   FK_ADD_WHERE VARCHAR2,
				   TABLE_NAME VARCHAR2,
				   PARENT_BLOCK_NAME VARCHAR2,
				   LIST_ID NUMBER) IS

  BEGIN

    TOTAL_ROWS := TOTAL_ROWS + 1;
    char_num(TOTAL_ROWS) := NUM;
    hardcoded_column(TOTAL_ROWS) := HARD_COLUMN;
    result_column_name(TOTAL_ROWS) := RES_COL_NAME;
    datatype(TOTAL_ROWS) := DATA;
    op(TOTAL_ROWS) := OPER;
    low(TOTAL_ROWS) := LOW_VAL;
    high(TOTAL_ROWS) := HIGH_VAL;
    sel(TOTAL_ROWS) := SELE;
    disp_len(TOTAL_ROWS) := DISP_LENGTH;
    promptt(TOTAL_ROWS) := PROMPT;
    orderr(TOTAL_ROWS) := ORDER_SEQ;
    totall(TOTAL_ROWS) := TOTAL;
    functionn(TOTAL_ROWS) := FUNCTION;
    fxn_promptt(TOTAL_ROWS) := FXN_PROMPT;
    precisionn(TOTAL_ROWS) := PRECISION;
    fk_lookup_typee(TOTAL_ROWS) := FK_LOOK_TYPE;
    fk_table_namee(TOTAL_ROWS) := FK_TABL_NAME;
    fk_table_short_namee(TOTAL_ROWS) := FK_TABL_SH_NAME;
    pk_idd(TOTAL_ROWS) := PK_ID;
    pk_idd2(TOTAL_ROWS) := PK_ID2;
    pk_idd3(TOTAL_ROWS) := PK_ID3;
    fk_idd(TOTAL_ROWS) := FK_ID;
    fk_idd2(TOTAL_ROWS) := FK_ID2;
    fk_idd3(TOTAL_ROWS) := FK_ID3;
    fk_meaningg(TOTAL_ROWS) := FK_MEANING;
    fk_descc(TOTAL_ROWS) := FK_DESC;
    fk_add_wheree(TOTAL_ROWS) := FK_ADD_WHERE;
    table_namee(TOTAL_ROWS) := TABLE_NAME;
    parent_block_namee(TOTAL_ROWS) := PARENT_BLOCK_NAME;
    list_idd(TOTAL_ROWS) := LIST_ID;
 END ADD_ROW_TO_REC_GROUP;


  FUNCTION ROWS_IN_REC_GROUP
	RETURN NUMBER IS

  BEGIN
    RETURN(TOTAL_ROWS);
  END ROWS_IN_REC_GROUP;

  FUNCTION GET_NUMBER(X_COLUMN VARCHAR2, X_ROW NUMBER)
	RETURN NUMBER  IS

  i BINARY_INTEGER;  -- Just to be safe

  BEGIN
    i := X_ROW;

    -- Yes this method is not the best but its the best we can do

    if X_COLUMN = 'char_num' then
	RETURN(char_num(i));
    elsif X_COLUMN = 'datatype' then
	RETURN(datatype(i));
    elsif X_COLUMN = 'sel' then
      	RETURN(sel(i));
    elsif X_COLUMN = 'disp_length' then
	RETURN(disp_len(i));
    end if;

    if X_COLUMN = 'order' then
	RETURN(orderr(i));
    elsif X_COLUMN = 'total' then
 	RETURN(totall(i));
    elsif X_COLUMN = 'function' then
  	RETURN(functionn(i));
    elsif X_COLUMN = 'fk_lookup_type' then
 	RETURN(fk_lookup_typee(i));
    elsif X_COLUMN = 'precision' then
	RETURN(precisionn(i));
    elsif X_COLUMN = 'list_id' then
        RETURN(list_idd(i));
    end if;

  END GET_NUMBER;


  FUNCTION GET_CHAR(X_COLUMN VARCHAR2, X_ROW NUMBER)
	RETURN VARCHAR2 IS

   i BINARY_INTEGER;

  BEGIN
   i := X_ROW;

   if X_COLUMN = 'hardcoded_column' then
	RETURN(hardcoded_column(i));
   elsif X_COLUMN = 'result_column_name' then
	RETURN(result_column_name(i));
   elsif X_COLUMN = 'op' then
	RETURN(op(i));
   elsif X_COLUMN = 'low' then
	RETURN(low(i));
   elsif X_COLUMN = 'high' then
 	RETURN(high(i));
   elsif X_COLUMN = 'prompt' then
 	RETURN(promptt(i));
   end if;

   if X_COLUMN = 'fxn_prompt' then
	RETURN(fxn_promptt(i));
   elsif X_COLUMN = 'fk_table_name' then
 	RETURN(fk_table_namee(i));
   elsif X_COLUMN = 'fk_table_short_name' then
	RETURN(fk_table_short_namee(i));
   elsif X_COLUMN = 'pk_id' then
	RETURN(pk_idd(i));
   elsif X_COLUMN = 'pk_id2' then
	RETURN(pk_idd2(i));
   elsif X_COLUMN = 'pk_id3' then
	RETURN(pk_idd3(i));
   end if;

   if X_COLUMN = 'fk_id' then
	RETURN(fk_idd(i));
   elsif X_COLUMN = 'fk_id2' then
	RETURN(fk_idd2(i));
   elsif X_COLUMN = 'fk_id3' then
	RETURN(fk_idd3(i));
   elsif X_COLUMN = 'fk_meaning' then
	RETURN(fk_meaningg(i));
   elsif X_COLUMN = 'fk_desc' then
 	RETURN(fk_descc(i));
   elsif X_COLUMN = 'fk_add_where' then
 	RETURN(fk_add_wheree(i));
   end if;

   if X_COLUMN = 'table_name' then
        RETURN(table_namee(i));
   elsif X_COLUMN = 'parent_block_name' then
        RETURN(parent_block_namee(i));
   end if;

  end GET_CHAR;

  PROCEDURE KILL_REC_GROUP IS

  BEGIN
    char_num := empty_numtable;
    hardcoded_column := empty_char30table;
    result_column_name := empty_char30table;
    datatype := empty_numtable;
    op := empty_char15table;
    low := empty_char80table;
    high := empty_char80table;
    sel := empty_numtable;
    disp_len := empty_numtable;
    promptt := empty_char80table;
    orderr := empty_numtable;
    totall := empty_numtable;
    functionn := empty_numtable;
    fxn_promptt := empty_char30table;
    precisionn := empty_numtable;
    fk_table_namee := empty_char30table;
    fk_table_short_namee := empty_char5table;
    pk_idd := empty_char30table;
    pk_idd2 := empty_char30table;
    pk_idd3 := empty_char30table;
    fk_idd := empty_char30table;
    fk_idd2 := empty_char30table;
    fk_idd3 := empty_char30table;
    fk_meaningg := empty_char30table;
    fk_descc := empty_char30table;
    fk_add_wheree := empty_char2000table;
    table_namee := empty_char80table;
    parent_block_namee := empty_char30table;
    list_idd := empty_numtable;
    TOTAL_ROWS := 0;
  END KILL_REC_GROUP;


  PROCEDURE Make_FROM_Rec_grp IS

  BEGIN
    from_partial := empty_char2000table;
    ROWS_FROM := 0;
  END Make_FROM_Rec_grp;

  PROCEDURE Kill_FROM_Rec_grp IS

  BEGIN
    from_partial := empty_char2000table;
    ROWS_FROM := 0;
  END Kill_FROM_Rec_grp;


  Procedure ADD_ROW_TO_FROM_REC_GROUP(table_name VARCHAR2) IS
    i BINARY_INTEGER := 1;
    PRESENT  BOOLEAN := FALSE;

  BEGIN
    WHILE (i <= ROWS_FROM) and (not PRESENT) LOOP
          if table_name = from_partial(i) then
	     PRESENT := TRUE;
          else
 	     i := i + 1;
	  end if;
    end LOOP;
    if (not PRESENT) then
        ROWS_FROM := ROWS_FROM + 1;
        from_partial(ROWS_FROM) := table_name;
    end if;
  END ADD_ROW_TO_FROM_REC_GROUP;


  Function Create_From_Clause
 	Return VARCHAR2 IS

    i BINARY_INTEGER := 1;
    V_FROM VARCHAR2(32767) := null;

  BEGIN
    while i <= ROWS_FROM LOOP
	V_FROM := ', ' || from_partial(i) || V_FROM;
        i := i + 1;
    end LOOP;
    V_FROM := 'FROM ' || SUBSTR(V_FROM,3);
    from_partial := empty_char2000table;
    ROWS_FROM := 0;
    RETURN(V_FROM);
  END Create_From_Clause;

  PROCEDURE Make_WHERE_Rec_grp IS

  BEGIN
    where_partial := empty_char2000table;
    ROWS_WHERE := 0;
  END Make_WHERE_Rec_grp;

  PROCEDURE Kill_WHERE_Rec_grp IS

  BEGIN
    where_partial := empty_char2000table;
    ROWS_WHERE := 0;
  END Kill_WHERE_Rec_grp;

  Procedure ADD_ROW_TO_WHERE_REC_GROUP (X_WHERE_PORTION VARCHAR2) IS
    i BINARY_INTEGER := 1;
    PRESENT  BOOLEAN := FALSE;

  BEGIN
    WHILE (i <= ROWS_WHERE) and (not PRESENT) LOOP
          if X_WHERE_PORTION = where_partial(i) then
	     PRESENT := TRUE;
          else
 	     i := i + 1;
	  end if;
    end LOOP;
    if (not PRESENT) then
        ROWS_WHERE := ROWS_WHERE + 1;
        where_partial(ROWS_WHERE) := X_WHERE_PORTION;
    end if;
  END ADD_ROW_TO_WHERE_REC_GROUP;


  Function Create_WHERE_Clause
 	Return VARCHAR2 IS

   i BINARY_INTEGER := 1;
   V_WHERE VARCHAR2(32767) := null;

  BEGIN
   while i <= ROWS_WHERE LOOP
         V_WHERE := V_WHERE || ' AND ' || where_partial(i);
 	 i := i + 1;
   end LOOP;
   if V_WHERE IS NOT NULL THEN
      V_WHERE := 'WHERE ' || SUBSTR(V_WHERE,5);
   end if;
   where_partial := empty_char2000table;
   ROWS_WHERE := 0;
   RETURN(V_WHERE);
  END Create_WHERE_Clause;

END QLTSTORB;


/
