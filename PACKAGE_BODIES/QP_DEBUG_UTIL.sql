--------------------------------------------------------
--  DDL for Package Body QP_DEBUG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEBUG_UTIL" AS
/* $Header: QPXDUTLB.pls 120.0.12010000.4 2009/09/23 08:23:37 dnema noship $ */

g_PkgStack t_CallStack;

g_VersionStack t_CallStack;

g_Level		NUMBER;

g_indent  VARCHAR2(500);
g_curr_parent NUMBER := 0;
g_granularity_level NUMBER := 0;

g_csv_count NUMBER;

TYPE file_id_list_tbl IS TABLE OF number INDEX BY VARCHAR2(500);
g_file_ids_tbl file_id_list_tbl;


PROCEDURE write_output(x_Line IN VARCHAR2)
IS
  l_debug_msg	VARCHAR2(2000);
  v_MesgSize    NUMBER;
  v_Mesg        VARCHAR2(32767);
BEGIN
  v_MesgSize := LENGTHB(x_Line);

  IF v_MesgSize > 500 THEN
    v_Mesg := x_Line;
    WHILE v_MesgSize > 500 loop
      l_debug_msg := SUBSTRB(v_Mesg,1,500);
      IF g_qp_Debug NOT IN ('P','S','M') THEN
      l_debug_msg := TRIM(l_debug_msg);
      ELSE
      v_Mesg := g_indent || SUBSTRB(v_Mesg,501);
      v_MesgSize := LENGTHB(v_Mesg);
      END IF;
      oe_debug_pub.add(l_debug_msg,1);
    END LOOP;
    IF v_MesgSize BETWEEN 1 AND  500 THEN
    IF g_qp_Debug NOT IN ('P','S','M') THEN
      v_Mesg := TRIM(v_Mesg);
    END IF;
      oe_debug_pub.add(v_Mesg,1);
    END IF;
  ELSE

    l_debug_msg := x_line;
    IF g_qp_Debug NOT IN ('P','S','M') THEN
      l_debug_msg := TRIM(l_debug_msg);
    END IF;
    oe_debug_pub.add(l_debug_msg,1);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  write_output('write_output-MSG-'||SQLERRM);
        g_qp_Debug := 'X';
END write_output;

PROCEDURE  tstart(x_Marker IN VARCHAR2,
                  x_Desc IN VARCHAR2 := NULL,
                  x_Accumalation IN BOOLEAN := true,
                  x_PutLine IN BOOLEAN := false)
IS
  v_Position    NUMBER := 0;
BEGIN

  G_qp_debug := FND_PROFILE.VALUE('QP_DEBUG');
  G_DEBUG := OE_DEBUG_PUB.G_DEBUG;
  G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  IF ISQPDebugON AND G_QP_debug = 'M' THEN

   IF x_Accumalation THEN
     FOR v_Count IN 1..g_TimeStack.COUNT LOOP
       IF g_TimeStack(v_Count).Marker = x_Marker
          AND g_TimeStack(v_Count).ParentId = g_curr_parent
       THEN
         v_Position := v_Count;
        EXIT;
       END IF;
     END LOOP;
   END IF;

   IF v_Position = 0
      --OR g_TimeStack(v_Position).ParentId <> g_curr_parent
      OR g_TimeStack(v_Position).Deleted
   THEN
      v_Position := g_TimeStack.COUNT + 1;
      g_TimeStack(v_Position).Marker := x_Marker;
      g_TimeStack(v_Position).Description := x_Desc;
      g_TimeStack(v_Position).TotalTime := 0;
      g_TimeStack(v_Position).CallCount := 0;
      g_TimeStack(v_Position).ParentId := g_curr_parent;
      g_TimeStack(v_Position).Deleted := false;

      g_curr_parent := v_Position;

    END IF;
    g_TimeStack(v_Position).Time := dbms_utility.get_time;
    g_TimeStack(v_Position).CallCount := g_TimeStack(v_Position).CallCount + 1;
    g_TimeStack(v_Position).IsRunning := true;
    g_TimeStack(v_Position).putLine := x_PutLine;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
write_output('tstart-MSG-'||SQLERRM);
        g_qp_Debug := 'X';

END tstart;

--Summary Time Log changes (Bug# 8933551).
PROCEDURE tstop(x_Marker IN VARCHAR2, x_Total_Time OUT NOCOPY NUMBER)
IS
v_position NUMBER := 0;
retValue NUMBER := 0;
running BOOLEAN;
BEGIN

  IF ISQPDebugON AND G_QP_debug = 'M' THEN
    FOR v_Count IN 1..g_TimeStack.COUNT LOOP
      IF g_TimeStack(v_Count).Marker = x_Marker THEN
       IF g_TimeStack(v_Count).IsRunning THEN
          v_position := v_Count;
          g_TimeStack(v_Count).TotalTime := g_TimeStack(v_Count).TotalTime +
                                          ((( dbms_utility.get_time -
                                          g_TimeStack(v_Count).Time)*10));
          g_TimeStack(v_Count).IsRunning := false;
          g_curr_parent := g_TimeStack(v_Count).ParentId;

	  retValue := g_TimeStack(v_Count).TotalTime;

          IF g_curr_parent <> 0
             AND NOT g_TimeStack(g_curr_parent).IsRunning
          THEN
              write_output('ERROR ** Wrongly stopped marker '||x_Marker
                 || '. Its parent marker '|| g_TimeStack(g_curr_parent).Marker
                 ||' is already stopped.');
          END IF;

          running := true;
          EXIT;
         ELSE
           running := false;
	   --write_output('ERROR ** Failed to stop marker '||g_TimeStack(v_Count).Marker || '. Not in running status.');
         END IF;
         --EXIT;
      END IF;
    END LOOP;

    IF NOT running THEN
       write_output('ERROR ** Failed to stop marker '||x_Marker || '. Not in running status.');
    END IF;

  END IF;

  x_Total_Time := retValue;

EXCEPTION
  WHEN OTHERS THEN
  write_output('tstop-MSG-'||SQLERRM);
  g_qp_Debug := 'X';
  x_Total_Time := 0;
END tstop;

PROCEDURE  tstop(x_Marker IN VARCHAR2)
IS
v_position NUMBER := 0;
running BOOLEAN;
BEGIN

  IF ISQPDebugON AND G_QP_debug = 'M' THEN
    FOR v_Count IN 1..g_TimeStack.COUNT LOOP
      IF g_TimeStack(v_Count).Marker = x_Marker THEN
       IF g_TimeStack(v_Count).IsRunning THEN
          v_position := v_Count;
          g_TimeStack(v_Count).TotalTime := g_TimeStack(v_Count).TotalTime +
                                          ((( dbms_utility.get_time -
                                          g_TimeStack(v_Count).Time)*10));
          g_TimeStack(v_Count).IsRunning := false;
          g_curr_parent := g_TimeStack(v_Count).ParentId;

          IF g_curr_parent <> 0
             AND NOT g_TimeStack(g_curr_parent).IsRunning
          THEN
              write_output('ERROR ** Wrongly stopped marker '||x_Marker
                 || '. Its parent marker '|| g_TimeStack(g_curr_parent).Marker
                 ||' is already stopped.');
          END IF;

          running := true;
          EXIT;
         ELSE
           running := false;
	   --write_output('ERROR ** Failed to stop marker '||g_TimeStack(v_Count).Marker || '. Not in running status.');
         END IF;
         --EXIT;
      END IF;
    END LOOP;

    IF NOT running THEN
       write_output('ERROR ** Failed to stop marker '||x_Marker || '. Not in running status.');
    END IF;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
  write_output('tstop-MSG-'||SQLERRM);
        g_qp_Debug := 'X';
END tstop;


PROCEDURE  tdump
IS
tempParentId NUMBER := 0;
msg VARCHAR2(2000);
BEGIN


   IF ISQPDebugON AND G_QP_debug = 'M' THEN

    IF g_curr_parent <> 0 and g_TimeStack(g_curr_parent).IsRunning THEN
       write_output(' **** Error : Forcefully stopping marker '
          ||g_TimeStack(g_curr_parent).Marker
          ||' : It may have wrong values.');
       tstop(g_TimeStack(g_curr_parent).Marker);
    END IF;

    IF g_granularity_level = 0 THEN
       write_output(' ');
       write_output(' **** Dumping Time Log Information Started  ****');
       write_output(' ');
    END IF;

    --FOR v_Count IN 1..g_TimeStack.COUNT LOOP
      IF g_curr_parent <> 0 THEN
        IF NOT g_TimeStack(g_curr_parent).Deleted THEN

        IF g_TimeStack(g_curr_parent).Description IS NULL
        THEN
           msg := g_TimeStack(g_curr_parent).Marker;
        ELSE
           msg := g_TimeStack(g_curr_parent).Description;
        END IF;

          IF g_TimeStack(g_curr_parent).putLine THEN
            write_output(' ');
          END IF;

          msg := msg || ' : ' ||
                   g_TimeStack(g_curr_parent).CallCount||' calls : '||
                   g_TimeStack(g_curr_parent).TotalTime||' ms';

          write_output(LPAD(msg,LENGTH(msg)+2*g_granularity_level,' '));
        END IF;
      END IF;
   --END LOOP;

     IF g_curr_parent = 0 OR NOT g_TimeStack(g_curr_parent).Deleted THEN
      FOR v_Count IN 1..g_TimeStack.COUNT LOOP

        IF  g_TimeStack(v_count).ParentId = g_curr_parent
          AND NOT g_TimeStack(v_count).Deleted
        THEN
          tempParentId := g_curr_parent;
          g_curr_parent := v_count;
          g_granularity_level := g_granularity_level + 1;
          tdump;
          g_granularity_level := g_granularity_level - 1;
          g_curr_parent := tempParentId;
        END IF;
      END LOOP;
     END IF;

     IF g_curr_parent <> 0 THEN
      tempParentId := g_TimeStack(g_curr_parent).ParentId;
      g_TimeStack(g_curr_parent).Deleted := true;
      g_curr_parent := tempParentId;
     END IF;

     IF g_granularity_level = 0 THEN
       write_output(' ');
       write_output(' **** Dumping Time Log Information Ended  ****');
       write_output(' ');
     END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  write_output('tdump-MSG-'||SQLERRM);
        g_qp_Debug := 'X';
END tdump;


PROCEDURE tflush
IS
BEGIN
    g_TimeStack.DELETE;
END tflush;


Function ISQPDebugOn
Return Boolean IS
BEGIN

  if G_DEBUG = FND_API.G_TRUE AND G_DEBUG_LEVEL = 1 AND G_qp_debug IN ('P','S','M') then
     RETURN(TRUE);
  else
     RETURN(FALSE);
  end if;
End ISQPDebugOn;

Function IsTimeLogDebugOn
Return Boolean IS
BEGIN

  if G_DEBUG = FND_API.G_TRUE AND G_DEBUG_LEVEL = 1 AND G_QP_debug = 'M' then
     RETURN(TRUE);
  else
     RETURN(FALSE);
  end if;
End IsTimeLogDebugOn;


/*
   Description :
      This procedure will print the data returned by cursor p_cursor in a CSV file.
   Input Parameters :
      p_output_file - file handle of the csv file.
      p_cursor - Cursor id whose data is to be printed.
   Output Parameters :
      None
*/

PROCEDURE print_cursor_data_csv_pvt(
   p_output_file IN utl_file.file_type,
   p_cursor in INTEGER
 )
 IS
   l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_CURSOR_DATA_CSV_PVT';
   l_cols_desc dbms_sql.desc_tab;
   l_col_cnt number;
   l_status number;
   l_col_val  varchar2(32767);
   l_hdr_string VARCHAR2(32767);
   l_row_string VARCHAR2(32767);

   l_output_file utl_file.file_type;
   filePath varchar2(1000);
   fileName varchar2(1000);

 BEGIN

    l_output_file := p_output_file;

     --getting column details in l_cols_desc
    dbms_sql.describe_columns( p_cursor, l_col_cnt, l_cols_desc);

    --defining holding variables for columns
    l_hdr_string := '';

    for i in 1 .. l_cols_desc.count LOOP

      dbms_sql.define_column( p_cursor, i, l_col_val, 32765);

      l_hdr_string := l_hdr_string || l_cols_desc(i).col_name;

      IF i <> l_cols_desc.COUNT THEN
         l_hdr_string := l_hdr_string || ',';
      END IF;

    end loop;

    utl_file.put_line(l_output_file,l_hdr_string);

    --printing rows

    l_status := dbms_sql.execute(p_cursor);

    LOOP

      EXIT WHEN (dbms_sql.fetch_rows(p_cursor) <= 0);

      l_row_string := '';

      for i in 1 .. l_cols_desc.count LOOP

         dbms_sql.column_value(p_cursor, i, l_col_val );

         l_row_string := l_row_string || l_col_val;

         IF i <> l_cols_desc.COUNT THEN
           l_row_string := l_row_string || ',';
         END IF;

      end loop;

      utl_file.put_line(l_output_file,l_row_string);

    END LOOP;

 EXCEPTION
  WHEN OTHERS THEN

    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;

 END print_cursor_data_csv_pvt;

/*
   Description :
      This procedure will print the data returned by cursor p_cursor in a CSV file.
      Naming convention for csv file is -
      <unique sequence number (g_csv_count) for a session>_<event>_<p_file_id>_<OE Debug file name>.csv
   Input Parameters :
      p_file_id - CSV file will contain this id in it's name
      p_cursor - Cursor id whose data is to be printed.
   Output Parameters :
      None
*/

PROCEDURE print_cursor_data_csv_pvt(
   p_file_id IN VARCHAR2,
   p_cursor        in INTEGER,
   p_append IN BOOLEAN := FALSE,
   p_prefix_event IN BOOLEAN := TRUE
 )
 IS
   l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_CURSOR_DATA_CSV_PVT';
   l_cols_desc dbms_sql.desc_tab;
   l_col_cnt number;
   l_status number;
   l_col_val  varchar2(32767);
   l_hdr_string VARCHAR2(32767);
   l_row_string VARCHAR2(32767);
   l_init_row_string VARCHAR2(50);
   l_first_time BOOLEAN := TRUE;

   --l_prcng_event VARCHAR2(30);

   l_output_file utl_file.file_type;
   filePath varchar2(1000);
   fileName varchar2(1000);

   l_file_ids_tbl file_id_list_tbl;

   l_csv_count NUMBER := 0;

   l_mode VARCHAR2(1);

 BEGIN

    select fnd_profile.value('OE_DEBUG_LOG_DIRECTORY')
    into filePath
    from dual;
    --8932016
    IF INSTR(G_CURR_PRICE_EVENT,',') = LENGTH(G_CURR_PRICE_EVENT)
    THEN
       l_init_row_string := REPLACE(G_CURR_PRICE_EVENT,',','-');
    ELSE
       l_init_row_string := REPLACE(G_CURR_PRICE_EVENT,',','-') ||',';
    END IF;
    --8932016
    IF p_append THEN

	  IF g_file_ids_tbl.EXISTS(p_file_id) THEN
	    qp_preq_grp.engine_debug('file id'||p_file_id||' exist');
	    l_first_time := FALSE;
            l_csv_count := g_file_ids_tbl(p_file_id);
          ELSE
  	    qp_preq_grp.engine_debug('file id '||p_file_id||' does not exist');
 	    g_csv_count := g_csv_count+1;
	    l_csv_count := g_csv_count;
            g_file_ids_tbl(p_file_id) := l_csv_count;
          END IF;

      l_mode := 'a';

    ELSE

       g_csv_count := g_csv_count+1;
       l_csv_count := g_csv_count;

       l_mode := 'w';

    END IF;

       qp_preq_grp.engine_debug('l_csv_count-'||l_csv_count);
       qp_preq_grp.engine_debug('l_mode-'||l_mode);

       fileName := l_csv_count;

       IF p_append = FALSE
           AND G_CURR_PRICE_EVENT IS NOT NULL THEN --8932016
          fileName := fileName || '_' || G_CURR_PRICE_EVENT;
       END IF;

       fileName := fileName|| '_' || p_file_id || '_' ||
                  SUBSTR(OE_DEBUG_PUB.G_FILE,1,INSTR(OE_DEBUG_PUB.G_FILE,'.dbg')-1);

       l_output_file := utl_file.fopen( filePath, fileName||'.csv', l_mode ,32000 );

    qp_preq_grp.engine_debug('Dumping data in file - ' || filePath || '/' ||fileName||'.csv');



    --getting column details in l_cols_desc
    dbms_sql.describe_columns( p_cursor, l_col_cnt, l_cols_desc);

    --defining holding variables for columns

    IF G_CURR_PRICE_EVENT IS NOT NULL --8932016
          AND p_prefix_event THEN
      l_hdr_string := 'PRICING_EVENT,';
    ELSE
      l_hdr_string :=  '';
    END IF;

    for i in 1 .. l_cols_desc.count LOOP

      dbms_sql.define_column( p_cursor, i, l_col_val, 32765);

      l_hdr_string := l_hdr_string || l_cols_desc(i).col_name;

      IF i <> l_cols_desc.COUNT THEN
         l_hdr_string := l_hdr_string || ',';
      END IF;

    end loop;

    IF l_first_time THEN
       utl_file.put_line(l_output_file,l_hdr_string);
    END IF;

    --printing rows


    l_status := dbms_sql.execute(p_cursor);

    LOOP

      EXIT WHEN (dbms_sql.fetch_rows(p_cursor) <= 0);

      IF G_CURR_PRICE_EVENT IS NOT NULL --8932016
         AND p_prefix_event THEN
          l_row_string := l_init_row_string;
      ELSE
          l_row_string := '';
      END IF;

      for i in 1 .. l_cols_desc.count LOOP

         dbms_sql.column_value(p_cursor, i, l_col_val );

         l_row_string := l_row_string || l_col_val;

         IF i <> l_cols_desc.COUNT THEN
           l_row_string := l_row_string || ',';
         END IF;

      end loop;

      utl_file.put_line(l_output_file,l_row_string);

    END LOOP;

    utl_file.fclose( l_output_file );

 EXCEPTION
  WHEN OTHERS THEN

    IF utl_file.is_open(l_output_file) THEN
       utl_file.fclose( l_output_file );
    END IF;

    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;

 END print_cursor_data_csv_pvt;

/*
   Description :
     This procedure will print data of table p_table_name in a csv file.
   Input Parameters :
      p_table_name - Name of table to be printed.
      p_file_id - CSV file will contain this id in it's name
   Output Parameters :
      None
*/

Procedure print_table_data_csv (
    p_table_name IN VARCHAR2,
    p_file_id IN VARCHAR2,
    p_where_clause IN VARCHAR2 := NULL,
    p_append IN BOOLEAN := FALSE,
    p_prefix_event IN BOOLEAN := TRUE
)
IS
   l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_TABLE_DATA_CSV';
   l_cursor number := dbms_sql.open_cursor;
   l_query VARCHAR2(15000) := '';

BEGIN

  G_DEBUG := OE_DEBUG_PUB.G_DEBUG;
  G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  IF G_DEBUG = FND_API.G_TRUE AND G_DEBUG_LEVEL = 5 THEN

    l_query := 'select * from ' || p_table_name;

    IF p_where_clause IS NOT NULL
    THEN
      l_query := l_query || ' where ' || p_where_clause;
    END IF;

    qp_preq_grp.engine_debug(' p_file_id - ' || p_file_id);
    qp_preq_grp.engine_debug(' l_query - ' || l_query);


    dbms_sql.parse( l_cursor,
        l_query
        ,dbms_sql.native );

    print_cursor_data_csv_pvt(
        p_file_id => p_file_id ,
        p_cursor => l_cursor,
        p_append => p_append,
	p_prefix_event => p_prefix_event);

 end if;
     dbms_sql.close_cursor( l_cursor );

EXCEPTION

  WHEN OTHERS THEN

    IF DBMS_SQL.IS_OPEN (l_cursor) THEN
       dbms_sql.close_cursor( l_cursor );
    END IF;

    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;
END print_table_data_csv;

Procedure print_query_data_csv (
    p_query IN VARCHAR2,
    p_file_id IN VARCHAR2,
    p_append IN BOOLEAN := FALSE,
    p_prefix_event IN BOOLEAN := TRUE
)
IS
   l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_QUERY_DATA_CSV';
   l_cursor number := dbms_sql.open_cursor;

BEGIN

  G_DEBUG := OE_DEBUG_PUB.G_DEBUG;
  G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  IF G_DEBUG = FND_API.G_TRUE AND G_DEBUG_LEVEL = 5 THEN

    dbms_sql.parse( l_cursor,
        p_query,
        dbms_sql.native );

    print_cursor_data_csv_pvt(
        p_file_id => p_file_id ,
        p_cursor => l_cursor,
        p_append => p_append,
	p_prefix_event => p_prefix_event);

  END IF;

    dbms_sql.close_cursor( l_cursor );


EXCEPTION
  WHEN OTHERS THEN

    IF DBMS_SQL.IS_OPEN (l_cursor) THEN
      dbms_sql.close_cursor( l_cursor );
    END IF;

    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;

END print_query_data_csv;

/*
   Description :
     This procedure will print data of cursor p_cursor_id in a csv file.
   Input Parameters :
      p_cursor_id - cursor whose data is to be printed.
      p_file_id - CSV file will contain this id in it's name
   Output Parameters :
      None
*/

Procedure print_cursor_data_csv (
    p_cursor_id IN number,
    p_file_id IN VARCHAR2
)
IS
   l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_CURSOR_DATA_CSV';

BEGIN

  G_DEBUG := OE_DEBUG_PUB.G_DEBUG;
  G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  IF G_DEBUG = FND_API.G_TRUE AND G_DEBUG_LEVEL = 5 THEN

    print_cursor_data_csv_pvt(
        p_file_id => p_file_id ,
        p_cursor => p_cursor_id);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;

END print_cursor_data_csv;

/*
   Description :
     This procedure will print blank rows in the specified csv file.
   Input Parameters :
      p_outputfile_id - file id in which blank rows are required.
      p_row_count - number of blank rows to be printed
   Output Parameters :
      None
*/

PROCEDURE print_blank_rows_csv (
 p_outputfile_id  utl_file.file_type,
 p_row_count number
)
IS
 l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_BLANK_ROWS_CSV';
BEGIN
  FOR i IN 1..p_row_count
  LOOP
     utl_file.put_line(p_outputfile_id,' ');
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN

    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;

END print_blank_rows_csv;

/*
   Description :
     This procedure will print results of queries listed in p_query_list
     in a csv file.  Naming convention for csv file is -
     <unique sequence number (g_csv_count) for a session>_<event>_<p_file_id>_<OE Debug file name>.csv
   Input Parameters :
      p_query_list - list of queries.
      p_file_id - CSV file will contain this id in it's name.
   Output Parameters :
      None
*/

PROCEDURE print_querylist_data_csv (
   p_query_list IN query_list,
   p_file_id IN VARCHAR2 )
IS
   l_output_file utl_file.file_type;
   filePath varchar2(1000);
   fileName varchar2(1000);

   l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.PRINT_QUERYLIST_DATA_CSV';

   l_cursor number;

BEGIN

  G_DEBUG := OE_DEBUG_PUB.G_DEBUG;
  G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

  IF G_DEBUG = FND_API.G_TRUE AND G_DEBUG_LEVEL = 5 THEN
    g_csv_count := g_csv_count+1;

    fileName := g_csv_count;

    IF G_CURR_PRICE_EVENT IS NOT NULL THEN --8932016
         fileName := fileName||'_' || G_CURR_PRICE_EVENT;
    END IF;

    fileName := fileName|| '_' || p_file_id || '_' ||
                  SUBSTR(OE_DEBUG_PUB.G_FILE,1,INSTR(OE_DEBUG_PUB.G_FILE,'.dbg')-1);

    SELECT fnd_profile.value('OE_DEBUG_LOG_DIRECTORY')
    INTO filePath
    FROM dual;

    l_output_file := utl_file.fopen( filePath, fileName||'.csv', 'w',32000 );

    qp_preq_grp.engine_debug('Dumping data in file - ' || filePath || '/' ||fileName||'.csv');

    FOR i IN p_query_list.first..p_query_list.last
    LOOP

       l_cursor := dbms_sql.open_cursor;

       dbms_sql.parse( l_cursor,
           p_query_list(i),
           dbms_sql.native );

       print_cursor_data_csv_pvt(
          p_output_file => l_output_file ,
          p_cursor => l_cursor);

       print_blank_rows_csv(l_output_file,5);

       dbms_sql.close_cursor( l_cursor );

    END LOOP;

    utl_file.fclose( l_output_file );

  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF utl_file.is_open(l_output_file) THEN
       utl_file.fclose( l_output_file );
    END IF;

    IF DBMS_SQL.IS_OPEN (l_cursor) THEN
      dbms_sql.close_cursor( l_cursor );
    END IF;

    IF qp_preq_grp.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
    END IF;


END print_querylist_data_csv;

/*
   Description :
     This procedure will print development log in csv files.
     It will dump data from table qp_npreq_line_patrns_tmp,
     QP_PREQ_PATRN_QUAL_TMP and qp_npreq_line_attrs_tmp. Total three
     csv files will be generated (for the session) one for each table.
     Data from different requestes within that session and of multiple
     phases within that request will be dumped in the same file.
   Input Parameters :
      None
   Output Parameters :
      None
*/

PROCEDURE print_development_csv AS

  l_sql_stmt VARCHAR2(10000);
  l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.print_development_csv';
BEGIN
    G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
    IF G_DEBUG_LEVEL = 5 THEN
     -- Printing table qp_npreq_line_patrns_tmp
     l_sql_stmt := 'SELECT REQUEST_ID,'''
                    || REPLACE(G_CURR_PRICE_EVENT,',','-')
		    || ''' PRICING_EVENT, PATTERN_ID,  LINE_INDEX,  HASH_KEY'
		    || ' FROM qp_npreq_line_patrns_tmp';

     qp_debug_util.print_query_data_csv (p_query => l_sql_stmt,
                                p_file_id => 'LINE_PATRNS_TMP',
                                p_append  => TRUE,
				p_prefix_event => FALSE
				);

     -- Printing table QP_PREQ_PATRN_QUAL_TMP --8932016
     l_sql_stmt := ''
	||'SELECT request_id              , '
	|| '''' || REPLACE(G_CURR_PRICE_EVENT,',','-') || ''' PRICING_EVENT,'
	||'       line_index              , '
	||'       pricing_phase_id        , '
	||'       list_header_id          , '
	||'       list_line_id            , '
	||'       stage                   , '
	||'       pricing_status_code     , '
	||'       matched_pattrn_id       , '
	||'       matched_hash_key        , '
	||'       grouping_no             , '
	||'       source_system_code      , '
	||'       header_quals_exist_flag , '
	||'       eq_flag                 , '
	||'       other_oprt_count        , '
	||'       null_other_oprt_count   , '
	||'       list_type_code          , '
	||'       pricing_effective_date  , '
	||'       modifier_level_code     , '
	||'       currency_detail_id      , '
	||'       currency_header_id      , '
	||'       qualifier_precedence    , '
	||'       validated_flag          , '
	||'       ask_for_flag            , '
	||'       header_limit_exists     , '
	||'       line_limit_exists       , '
	||'       selling_rounding_factor , '
	||'       order_currency          , '
	||'       base_currency_code      , '
	||'       break_uom_code          , '
	||'       break_uom_context       , '
	||'       break_uom_attribute     , '
	||'       pricing_status_text      '
	||'FROM   QP_PREQ_PATRN_QUAL_TMP';

     qp_debug_util.print_query_data_csv (p_query => l_sql_stmt,
                                p_file_id => 'PATRN_QUAL_TMP',
                                p_append  => TRUE,
				p_prefix_event => FALSE);

     -- Printing table qp_npreq_line_attrs_tmp
     l_sql_stmt := ''
	||'  SELECT request_id                   , '
	|| '''' || REPLACE(G_CURR_PRICE_EVENT,',','-') || ''' PRICING_EVENT,'
	||'         pricing_phase_id             , '
	||'         line_index                   , '
	||'         line_detail_index            , '
	||'         line_detail_type_code        , '
	||'         list_header_id               , '
	||'         list_line_id                 , '
	||'         attribute_level              , '
	||'         attribute_type               , '
	||'         context                      , '
	||'         attribute                    , '
	||'         value_from                   , '
	||'         setup_value_from             , '
	||'         value_to                     , '
	||'         setup_value_to               , '
	||'         grouping_number              , '
	||'         comparison_operator_type_code, '
	||'         datatype                     , '
	||'         product_uom_code             , '
	||'         group_quantity               , '
	||'         group_amount                 , '
	||'         incompatability_grp_code     , '
	||'         modifier_level_code          , '
	||'         primary_uom_flag             , '
	||'         no_qualifiers_in_grp         , '
	||'         validated_flag               , '
	||'         applied_flag                 , '
	||'         pricing_status_code          , '
	||'         pricing_status_text          , '
	||'         qualifier_precedence         , '
	||'         pricing_attr_flag            , '
	||'         qualifier_type               , '
	||'         processed_code               , '
	||'         excluder_flag                , '
	||'         distinct_qualifier_flag      , '
	||'         segment_id '
	||'  FROM   qp_npreq_line_attrs_tmp ';
	/*||'  WHERE ( '
	||'                LINE_DETAIL_INDEX IS NULL AND '
	|| 'COMPARISON_OPERATOR_TYPE_CODE IN ('''
	||QP_PREQ_GRP.G_OPERATOR_BETWEEN ||''','''
	||G_OPERATOR_NOT_EQL ||''')) ';*/

     qp_debug_util.print_query_data_csv (p_query => l_sql_stmt,
                                p_file_id => 'LINE_ATTRS_TMP',
                                p_append  => TRUE,
				p_prefix_event => FALSE
				);
   ELSE
      qp_preq_grp.engine_debug('Profile OM:debug level should be set to 5 to print csv files');
   END IF;
EXCEPTION
  WHEN OTHERS THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
END print_development_csv;

/*
   Description :
     This procedure will print support log in csv files.
     Data from different requestes within that session and of multiple
     phases within that request will be dumped in the same file.
   Input Parameters :
      None
   Output Parameters :
      None
*/

procedure print_support_csv(pos varchar2) as

--strings used for support log
l_lines_stmt VARCHAR2(20000);
l_ldets_stmt VARCHAR2(20000);
l_attrs_stmt VARCHAR2(20000);

 l_routine VARCHAR2(240):='Routine : QP_DEBUG_UTIL.print_support_csv';

begin
   G_Debug_Level :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
    IF G_DEBUG_LEVEL = 5 THEN --8932016
      l_lines_stmt := 'select ' ||
	' nlines.REQUEST_ID                       , ' ||
	'''' || REPLACE(G_CURR_PRICE_EVENT,',','-')          || ''' PRICING_EVENT, ' ||
	' nlines.LINE_INDEX                       , ' ||
	' nlines.REQUEST_TYPE_CODE                , ' ||
	' nlines.LINE_ID                          , ' ||
	' nlines.LINE_TYPE_CODE                   , ' ||
	' nlines.PRICING_EFFECTIVE_DATE           , ' ||
	' nlines.LINE_QUANTITY                    , ' ||
	' nlines.LINE_UOM_CODE                    , ' ||
	' nlines.LINE_UNIT_PRICE                  , ' ||
	' nlines.ORDER_UOM_SELLING_PRICE          , ' ||
	' nlines.PRICED_QUANTITY                  , ' ||
	' nlines.PRICED_UOM_CODE                  , ' ||
	' nlines.UNIT_PRICE                       , ' ||
	' nlines.ADJUSTED_UNIT_PRICE              , ' ||
	' nlines.PRICE_LIST_HEADER_ID             , ' ||
	' list.NAME PRICE_LIST_NAME               , ' ||
	' nlines.UOM_QUANTITY                     , ' ||
	' nlines.CURRENCY_CODE                    , ' ||
	' nlines.PERCENT_PRICE                    , ' ||
	' nlines.PARENT_PRICE                     , ' ||
	' nlines.PARENT_QUANTITY                  , ' ||
	' nlines.PARENT_UOM_CODE                  , ' ||
	' nlines.PROCESSING_ORDER                 , ' ||
	' nlines.PROCESSED_FLAG                   , ' ||
	' nlines.PROCESSED_CODE                   , ' ||
	' nlines.PRICE_FLAG                       , ' ||
	' nlines.PRICING_STATUS_CODE              , ' ||
	' nlines.PRICING_STATUS_TEXT              , ' ||
	' nlines.START_DATE_ACTIVE_FIRST          , ' ||
	' nlines.ACTIVE_DATE_FIRST_TYPE           , ' ||
	' nlines.START_DATE_ACTIVE_SECOND         , ' ||
	' nlines.ACTIVE_DATE_SECOND_TYPE          , ' ||
	' nlines.GROUP_QUANTITY                   , ' ||
	' nlines.GROUP_AMOUNT                     , ' ||
	' nlines.LINE_AMOUNT                      , ' ||
	' nlines.ROUNDING_FLAG                    , ' ||
	' nlines.ROUNDING_FACTOR                  , ' ||
	' nlines.UPDATED_ADJUSTED_UNIT_PRICE      , ' ||
	' nlines.PRICE_REQUEST_CODE               , ' ||
	' nlines.HOLD_CODE                        , ' ||
	' nlines.HOLD_TEXT                        , ' ||
	' nlines.VALIDATED_FLAG                   , ' ||
	' nlines.QUALIFIERS_EXIST_FLAG            , ' ||
	' nlines.PRICING_ATTRS_EXIST_FLAG         , ' ||
	' nlines.PRIMARY_QUALIFIERS_MATCH_FLAG    , ' ||
	' nlines.USAGE_PRICING_TYPE               , ' ||
	' nlines.LINE_CATEGORY                    , ' ||
	' nlines.CONTRACT_START_DATE              , ' ||
	' nlines.CONTRACT_END_DATE                , ' ||
	' nlines.PROCESS_STATUS                   , ' ||
	' nlines.EXTENDED_PRICE                   , ' ||
	' nlines.CATCHWEIGHT_QTY                  , ' ||
	' nlines.ACTUAL_ORDER_QUANTITY            , ' ||
	' nlines.HEADER_ID                        , ' ||
	' nlines.LIST_PRICE_OVERRIDE_FLAG           ' ||
	' FROM QP_NPREQ_LINES_TMP nlines, qp_list_headers_vl list  ' ||
	' where list.list_header_id (+) = nlines.PRICE_LIST_HEADER_ID  ' ||
	' order by nlines.line_index';

     l_ldets_stmt := 'select ' ||
	' nldets.REQUEST_ID                     , ' ||
	'''' || REPLACE(G_CURR_PRICE_EVENT,',','-')          || ''' PRICING_EVENT, ' ||
	' nldets.LINE_INDEX                     , ' ||
	' nldets.LINE_DETAIL_INDEX              , ' ||
	' nldets.CREATED_FROM_LIST_HEADER_ID    , ' ||
	' list.NAME LIST_NAME                   , ' ||
	' nldets.CREATED_FROM_LIST_LINE_ID      , ' ||
	' nldets.CREATED_FROM_LIST_TYPE_CODE    , ' ||
	' nldets.CREATED_FROM_LIST_LINE_TYPE    , ' ||
	' nldets.MODIFIER_LEVEL_CODE            , ' ||
	' nldets.PRICING_PHASE_ID               , ' ||
	' nldets.APPLIED_FLAG                   , ' ||
	' nldets.AUTOMATIC_FLAG                 , ' ||
	' nldets.OPERAND_CALCULATION_CODE       , ' ||
	' nldets.OPERAND_VALUE                  , ' ||
	' nldets.ADJUSTMENT_AMOUNT              , ' ||
	' nldets.LINE_DETAIL_TYPE_CODE          , ' ||
	' nldets.LINE_DETAIL_PBH_TYPE           , ' ||
	' nldets.PRICE_BREAK_TYPE_CODE          , ' ||
	' nldets.CREATED_FROM_SQL               , ' ||
	' nldets.PRICING_GROUP_SEQUENCE         , ' ||
	' nldets.LINE_QUANTITY                  , ' ||
	' nldets.SUBSTITUTION_TYPE_CODE         , ' ||
	' nldets.SUBSTITUTION_VALUE_FROM        , ' ||
	' nldets.SUBSTITUTION_VALUE_TO          , ' ||
	' nldets.ASK_FOR_FLAG                   , ' ||
	' nldets.PRICE_FORMULA_ID               , ' ||
	' nldets.PROCESSED_FLAG                 , ' ||
	' nldets.PRICING_STATUS_CODE            , ' ||
	' nldets.PRICING_STATUS_TEXT            , ' ||
	' nldets.PRODUCT_PRECEDENCE             , ' ||
	' nldets.INCOMPATABILITY_GRP_CODE       , ' ||
	' nldets.BEST_PERCENT                   , ' ||
	' nldets.OVERRIDE_FLAG                  , ' ||
	' nldets.PRINT_ON_INVOICE_FLAG          , ' ||
	' nldets.PRIMARY_UOM_FLAG               , ' ||
	' nldets.BENEFIT_QTY                    , ' ||
	' nldets.BENEFIT_UOM_CODE               , ' ||
	' nldets.LIST_LINE_NO                   , ' ||
	' nldets.ACCRUAL_FLAG                   , ' ||
	' nldets.ACCRUAL_CONVERSION_RATE        , ' ||
	' nldets.ESTIM_ACCRUAL_RATE             , ' ||
	' nldets.RECURRING_FLAG                 , ' ||
	' nldets.SELECTED_VOLUME_ATTR           , ' ||
	' nldets.ROUNDING_FACTOR                , ' ||
	' nldets.SECONDARY_PRICELIST_IND        , ' ||
	' nldets.GROUP_QUANTITY                 , ' ||
	' nldets.GROUP_AMOUNT                   , ' ||
	' nldets.PROCESS_CODE                   , ' ||
	' nldets.UPDATED_FLAG                   , ' ||
	' nldets.CHARGE_TYPE_CODE               , ' ||
	' nldets.CHARGE_SUBTYPE_CODE            , ' ||
	' nldets.LIMIT_CODE                     , ' ||
	' nldets.LIMIT_TEXT                     , ' ||
	' nldets.HEADER_LIMIT_EXISTS            , ' ||
	' nldets.LINE_LIMIT_EXISTS              , ' ||
	' nldets.CALCULATION_CODE               , ' ||
	' nldets.CURRENCY_HEADER_ID             , ' ||
	' nldets.PRICING_EFFECTIVE_DATE         , ' ||
	' nldets.BASE_CURRENCY_CODE             , ' ||
	' nldets.ORDER_CURRENCY                 , ' ||
	' nldets.CURRENCY_DETAIL_ID             , ' ||
	' nldets.SELLING_ROUNDING_FACTOR        , ' ||
	' nldets.CHANGE_REASON_CODE             , ' ||
	' nldets.CHANGE_REASON_TEXT             , ' ||
	' nldets.REQUEST_ID                     , ' ||
	' nldets.PRICE_ADJUSTMENT_ID            , ' ||
	' nldets.RECURRING_VALUE                , ' ||
	' nldets.NET_AMOUNT_FLAG                , ' ||
	' nldets.ORDER_QTY_OPERAND              , ' ||
	' nldets.ORDER_QTY_ADJ_AMT              , ' ||
	' nldets.ACCUM_CONTEXT                  , ' ||
	' nldets.ACCUM_ATTRIBUTE                , ' ||
	' nldets.ACCUM_ATTR_RUN_SRC_FLAG        , ' ||
	' nldets.BREAK_UOM_CODE                 , ' ||
	' nldets.BREAK_UOM_CONTEXT              , ' ||
	' nldets.BREAK_UOM_ATTRIBUTE              ' ||
	' FROM QP_NPREQ_LDETS_TMP nldets, qp_list_headers_vl list  ' ||
	' where list.list_header_id = nldets.CREATED_FROM_LIST_HEADER_ID  ' ||
	' order by nldets.line_index,nldets.LINE_DETAIL_INDEX';

      l_attrs_stmt := 'select ' ||
	' lattrs.REQUEST_ID                        , ' ||
	'''' || REPLACE(G_CURR_PRICE_EVENT,',','-')          || ''' PRICING_EVENT, ' ||
	' lattrs.LINE_INDEX                        , ' ||
	' lattrs.LINE_DETAIL_INDEX                 , ' ||
	' lattrs.ATTRIBUTE_LEVEL                   , ' ||
	' lattrs.ATTRIBUTE_TYPE                    , ' ||
	' lattrs.CONTEXT                           , ' ||
        ' qpc.USER_PRC_CONTEXT_NAME                , ' ||
	' lattrs.ATTRIBUTE                         , ' ||
        ' qps.USER_SEGMENT_NAME                    , ' ||
	' lattrs.COMPARISON_OPERATOR_TYPE_CODE     , ' ||
	' lattrs.VALUE_FROM                        , ' ||
	' lattrs.SETUP_VALUE_FROM                  , ' ||
	' lattrs.VALUE_TO                          , ' ||
	' lattrs.SETUP_VALUE_TO                    , ' ||
	' lattrs.LIST_HEADER_ID                    , ' ||
	' lattrs.LIST_LINE_ID                      , ' ||
	' lattrs.GROUPING_NUMBER                   , ' ||
	' lattrs.NO_QUALIFIERS_IN_GRP              , ' ||
	' lattrs.VALIDATED_FLAG                    , ' ||
	' lattrs.APPLIED_FLAG                      , ' ||
	' lattrs.PRICING_STATUS_CODE               , ' ||
	' lattrs.PRICING_STATUS_TEXT               , ' ||
	' lattrs.QUALIFIER_PRECEDENCE              , ' ||
	' lattrs.PRICING_ATTR_FLAG                 , ' ||
	' lattrs.QUALIFIER_TYPE                    , ' ||
	' lattrs.DATATYPE                          , ' ||
	' lattrs.PRODUCT_UOM_CODE                  , ' ||
	' lattrs.PROCESSED_CODE                    , ' ||
	' lattrs.EXCLUDER_FLAG                     , ' ||
	' lattrs.GROUP_QUANTITY                    , ' ||
	' lattrs.GROUP_AMOUNT                      , ' ||
	' lattrs.DISTINCT_QUALIFIER_FLAG           , ' ||
	' lattrs.PRICING_PHASE_ID                  , ' ||
	' lattrs.INCOMPATABILITY_GRP_CODE          , ' ||
	' lattrs.LINE_DETAIL_TYPE_CODE             , ' ||
	' lattrs.MODIFIER_LEVEL_CODE               , ' ||
	' lattrs.PRIMARY_UOM_FLAG                    ' ||
	' FROM QP_NPREQ_LINE_ATTRS_TMP lattrs, qp_prc_contexts_v qpc, qp_segments_v qps ' ||
	' WHERE qpc.prc_context_code = lattrs.CONTEXT ' ||
	' AND decode(QPC.prc_context_type,''PRICING_ATTRIBUTE'',''PRICING'',QPC.prc_context_type) = lattrs.ATTRIBUTE_TYPE ' ||
	' AND qps.prc_context_id = qpc.prc_context_id' ||
	' AND qps.segment_mapping_column = lattrs.ATTRIBUTE ';

     if pos = 'START' then
      print_query_data_csv(l_lines_stmt,'PUB_QP_LINES_START',TRUE,FALSE);
      print_query_data_csv(l_ldets_stmt,'PUB_QP_LDETS_START',TRUE,FALSE);
      print_query_data_csv(l_attrs_stmt,'PUB_QP_ATTRS_START',TRUE,FALSE);
     else
      print_query_data_csv(l_lines_stmt,'PUB_QP_LINES_END',TRUE,FALSE);
      print_query_data_csv(l_ldets_stmt,'PUB_QP_LDETS_END',TRUE,FALSE);
     end if;

  ELSE
     qp_preq_grp.engine_debug('Profile OM:debug level should be set to 5 to print csv files');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      qp_preq_grp.engine_debug('Exception occured - '||l_routine);
      qp_preq_grp.engine_debug('Error Message - '||SQLERRM);
END print_support_csv;

/*
   Description :
     Set current pricing event in G_CURR_PRICE_EVENT.
   Input Parameters :
      currEvent : Current Pricing Event
   Output Parameters :
      None
*/
--8932016
PROCEDURE setCurrentEvent(currEvent varchar2)
AS
BEGIN
   G_CURR_PRICE_EVENT := currEvent;
END setCurrentEvent;

-- Summary Time Log Changes (Bug# 8933551)
/*
   Description :
     Add given log message to the summary log.
   Input Parameters :
      logMessage : Log Message
      paddingTop : Number of blank lines to be inserted before the message
      paddingLeft : Left indentation (number of tabs)
      paddingBottom : Number of blank lines to be inserted after the message
   Output Parameters :
      None
*/

PROCEDURE addSummaryTimeLog(logMessage varchar2,
                            paddingTop NUMBER := 0,
			    paddingLeft NUMBER := 0,
			    paddingBottom NUMBER := 0)
AS
v_posi NUMBER := 0;
BEGIN
   IF IsTimeLogDebugOn THEN
      v_posi := g_summaryLog.COUNT + 1;
      g_summaryLog(v_posi).logMesg := logMessage;
      g_summaryLog(v_posi).paddingTop := paddingTop;
      g_summaryLog(v_posi).paddingLeft := paddingLeft;
      g_summaryLog(v_posi).paddingBottom := paddingBottom;
   END IF;
END addSummaryTimeLog;

/*
   Description :
     Dump summary log in the debug file.
   Input Parameters :
      None.
   Output Parameters :
      None
*/

PROCEDURE dumpSummaryTimeLog
AS
BEGIN

 IF IsTimeLogDebugOn THEN

  write_output(' ');
  write_output(' **** Dumping Time Log (Summary) Information Started  ****');
  write_output(' ');

  FOR i IN 1..g_summaryLog.COUNT LOOP

      --Number of blank line at top
      FOR j IN 1..g_summaryLog(i).paddingTop LOOP
         write_output(' ');
      END LOOP;

      --final message
      write_output(LPAD(g_summaryLog(i).logMesg,LENGTH(g_summaryLog(i).logMesg)+8*g_summaryLog(i).paddingLeft,' '));

      --Number of blank line at bottom
      FOR j IN 1..g_summaryLog(i).paddingBottom LOOP
         write_output(' ');
      END LOOP;

  END LOOP;

 write_output(' ');
 write_output(' **** Dumping Time Log (Summary) Information Ended  ****');
 write_output(' ');

 g_summaryLog.DELETE;

 END IF;

EXCEPTION
WHEN OTHERS THEN
     write_output('tdump-MSG-'||SQLERRM);
     g_qp_Debug := 'X';
     g_summaryLog.DELETE;
END dumpSummaryTimeLog;

/*
   Description :
     Set attribute which can be accessed anywhere within the same session with the given key.
   Input Parameters :
      pKey : Key
      pValue : Value
   Output Parameters :
      None
*/

PROCEDURE setAttribute(pKey varchar2, pValue varchar2)
AS
BEGIN
  g_comm_attribs(pKey) := pValue;
  EXCEPTION
WHEN OTHERS THEN
     write_output('setAttribute-MSG-'||SQLERRM);
END setAttribute;

/*
   Description :
     Return value of the attribute for given key.
   Input Parameters :
      pKey : Key
   Output Parameters :
      Value
*/

FUNCTION getAttribute(pKey varchar2)
RETURN VARCHAR2
AS
BEGIN
  IF g_comm_attribs.exists(pKey) THEN
     RETURN g_comm_attribs(pKey);
  ELSE
     RETURN null;
  END IF;
EXCEPTION
WHEN OTHERS THEN
     write_output('getAttribute-MSG-'||SQLERRM);
     RETURN null;
END getAttribute;

begin
  g_csv_count := 0;

END QP_DEBUG_UTIL;

/
