--------------------------------------------------------
--  DDL for Package Body INV_SQL_BINDING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SQL_BINDING_PVT" AS
/* $Header: INVVSQBB.pls 120.1 2005/06/11 07:33:32 appldev  $ */
--
-- File        : INVVSQBB.pls
-- Content     : INV_SQL_BINDING_PVT package body
-- Description : Procedures and functions used for sql binding.
--               This package gives you a way to manage your bind
--               variables by registering them with the package
--               and get a indentifier which you can use in
--               your dynamic sql, and call the procedure bindvars
--               to bind all variables to the cursor passed in.
--
-- Notes       :
-- Modified    : 10/22/1999 bitang created
--
g_pkg_name CONSTANT VARCHAR2(30) := 'INV_SQL_BINDING_PVT';
--
g_line_feed VARCHAR2(1) := '
';
-- Necessary variables for dynamically bound input parameters
TYPE num_rec_type IS RECORD
  ( identifier    VARCHAR2(10)
   ,value         NUMBER
    );
TYPE char_rec_type IS RECORD
  ( identifier     VARCHAR2(10)
   ,value          VARCHAR2(240)
    );
TYPE date_rec_type IS RECORD
  ( identifier     VARCHAR2(10)
   ,value          DATE
    );
TYPE num_tbl_type  IS TABLE OF num_rec_type  INDEX BY BINARY_INTEGER;
TYPE char_tbl_type IS TABLE OF char_rec_type INDEX BY BINARY_INTEGER;
TYPE date_tbl_type IS TABLE OF date_rec_type INDEX BY BINARY_INTEGER;
--
g_num_tbl        num_tbl_type;   -- bind varible table for numbers
g_char_tbl       char_tbl_type;  -- bind varible table for varchar2s
g_date_tbl       date_tbl_type;  -- bind varible table for dates
g_num_counter    INTEGER;        -- size of g_num_tbl
g_char_counter   INTEGER;        -- size of g_char_tbl
g_date_counter   INTEGER;        -- size of g_date_tbl
g_num_pointer    INTEGER;        -- pointer to a record in g_num_tbl
g_char_pointer   INTEGER;        -- pointer to a record in g_char_tbl
g_date_pointer   INTEGER;        -- pointer to a record in g_date_tbl
--
-- API name    : InitBindTables
-- Type        : Private
-- Function    : Initializes internal tables of bind variable names and their
--               values. Needed for dynamic SQL.
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
PROCEDURE InitBindTables IS
BEGIN
  g_num_tbl.DELETE;
  g_char_tbl.DELETE;
  g_date_tbl.DELETE;
  g_num_counter  := 0;
  g_char_counter := 0;
  g_date_counter := 0;
  g_num_pointer  := 0;
  g_char_pointer := 0;
  g_date_pointer := 0;
END InitBindTables;
--
-- API name    : SaveBindPointers
-- Type        : Private
-- Function    : Saves pointers to current bind variable tables rows.
--               Needed to distinguish between 'static' and 'dynamic'
--               entry sections according to implemented algorithm??
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
--
PROCEDURE SaveBindPointers IS
BEGIN
  g_num_pointer  := g_num_counter;
  g_char_pointer := g_char_counter;
  g_date_pointer := g_date_counter;
END SaveBindPointers;
--
-- API name    : RestoreBindPointers
-- Type        : Private
-- Function    : Restores pointers to specific bind variable tables rows.
--               Needed to reuse 'static' and overwrite 'dynamic'
--               entry sections according to implemented algorithm.
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
--
PROCEDURE RestoreBindPointers IS
BEGIN
  g_num_counter  := g_num_pointer;
  g_char_counter := g_char_pointer;
  g_date_counter := g_date_pointer;
END RestoreBindPointers;
--
-- API name    : InitBindVar
-- Type        : Private
-- Function    : Adds an entry to the corresponding bind variable table
--               and stores created name as well as value, returns name.
-- Pre-reqs    : none
-- Parameters  :
--  p_value                in  number   required
--                  OR
--  p_value                in  varchar2 required
--                  OR
--  p_value                in  date     required
--  return value           OUT NOCOPY /* file.sql.39 change */ varchar2(10)
-- Version     : not tracked
-- Notes       : Overlayed functions for each supported data type
--
FUNCTION InitBindVar ( p_value IN NUMBER ) RETURN VARCHAR2 IS
BEGIN
  g_num_counter                         := g_num_counter + 1;
  g_num_tbl(g_num_counter).identifier   := ':n'||to_char(g_num_counter);
  g_num_tbl(g_num_counter).value        := p_value;
  RETURN g_num_tbl(g_num_counter).identifier;
END InitBindVar;
--
FUNCTION InitBindVar ( p_value IN VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  g_char_counter                        := g_char_counter + 1;
  g_char_tbl(g_char_counter).identifier := ':c'||to_char(g_char_counter);
  g_char_tbl(g_char_counter).value      := p_value;
  RETURN g_char_tbl(g_char_counter).identifier;
END InitBindVar;
--
FUNCTION InitBindVar ( p_value IN DATE ) RETURN VARCHAR2 IS
BEGIN
  g_date_counter                        := g_date_counter + 1;
  g_date_tbl(g_date_counter).identifier := ':d'||to_char(g_date_counter);
  g_date_tbl(g_date_counter).value      := p_value;
  RETURN g_date_tbl(g_date_counter).identifier;
END InitBindVar;
--
-- API name    : BindVars
-- Type        : Private
-- Function    : Binds all variables stored in the internal bind variable
--               tables to the given dynamic SQL cursor.
-- Pre-reqs    : refer to dbms_sql package spec
-- Parameters  :
--  p_cursor               in  integer  required
-- Version     : not tracked
-- Notes       :
PROCEDURE BindVars ( p_cursor IN INTEGER ) IS
  n_i INTEGER;
BEGIN
  -- Bind all numeric variables
  IF g_num_counter > 0 THEN
    FOR n_i IN 1..g_num_counter LOOP
      dbms_sql.bind_variable( p_cursor
                             ,g_num_tbl(n_i).identifier
                             ,g_num_tbl(n_i).value );
    END LOOP;
  END IF;
  -- Bind all character variables
  IF g_char_counter > 0 THEN
    FOR n_i IN 1..g_char_counter LOOP
      dbms_sql.bind_variable( p_cursor
                             ,g_char_tbl(n_i).identifier
                             ,g_char_tbl(n_i).value );
    END LOOP;
  END IF;
  -- Bind all date variables
  IF g_date_counter > 0 THEN
    FOR n_i IN 1..g_date_counter LOOP
      dbms_sql.bind_variable( p_cursor
                             ,g_date_tbl(n_i).identifier
                             ,g_date_tbl(n_i).value );
    END LOOP;
  END IF;
END BindVars;
--
-- API name    : GetConversionString
-- Type        : Private
-- Function    : Returns SQL conversion function syntax corresponding to the
--               given data types to convert.
-- Pre-reqs    : none
-- Parameters  :
--  p_data_type_code        in  number   required
--  p_parent_data_type_code in  number   required
--  x_left_part_conv_fct    OUT NOCOPY /* file.sql.39 change */ varchar2(20)
--  x_right_part_conv_fct   OUT NOCOPY /* file.sql.39 change */ varchar2(20)
-- Version     : not tracked
-- Notes       : needed to be verified
PROCEDURE GetConversionString
  ( p_data_type_code               IN   NUMBER
   ,p_parent_data_type_code        IN   NUMBER
   ,x_left_part_conv_fct           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ,x_right_part_conv_fct          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   ) IS
BEGIN
  IF p_data_type_code <> p_parent_data_type_code THEN
    IF p_data_type_code = 1 THEN
      IF p_parent_data_type_code = 2 THEN  -- char   -> number
        x_left_part_conv_fct  := 'fnd_number.canonical_to_number(';
        x_right_part_conv_fct := ')';
      ELSIF p_parent_data_type_code = 3 THEN  -- date   -> number
        -- Julian date assumed
        x_left_part_conv_fct  := 'to_number(to_char(';
        x_right_part_conv_fct := ',''J''))';
      END IF;
    ELSIF p_data_type_code = 2 THEN
      IF p_parent_data_type_code = 1 THEN -- number -> char
        x_left_part_conv_fct  := 'fnd_number.number_to_canonical(';
        x_right_part_conv_fct := ')';
      ELSIF p_parent_data_type_code = 3 THEN  -- date   -> char
        -- standard Apps date format assumed
        x_left_part_conv_fct  := 'fnd_date.date_to_canonical(';
        x_right_part_conv_fct := ')';
      END IF;
    ELSIF p_data_type_code = 3 THEN
      IF p_parent_data_type_code = 1 THEN  -- number -> date
        -- Julian date assumed
        x_left_part_conv_fct  := 'to_date(to_char(';
        x_right_part_conv_fct := '),''J'')';
      ELSIF p_parent_data_type_code = 2 THEN  -- char   -> date
        -- standard Apps date format assumed
        x_left_part_conv_fct  := 'fnd_date.canonical_to_date(';
        x_right_part_conv_fct := ')';
      END IF;
    END IF;
  ELSE
    x_left_part_conv_fct  := NULL;
    x_right_part_conv_fct := NULL;
  END IF;
END GetConversionString;
--
-- API name    : ShowSQL
-- Type        : Private
-- Function    : Shows the text of the dynamically built SQL statement using
--               dbms_output. Needed for debugging.
-- Pre-reqs    : none
-- Parameters  :
--  p_sql_text             in  long     required
-- Version     : not tracked
-- Notes       :
PROCEDURE showsql
  ( p_sql_text IN long) IS
     p_n NUMBER;
     p_v VARCHAR2(1);
     l_line_size NUMBER;
BEGIN
   NULL;
/*   dbms_output.enable(5000000);
   l_line_size := 0;
   for p_n in 1..length(p_sql_text) loop
      p_v := substr(p_sql_text,p_n,1);
      if p_v = g_line_feed THEN
	 dbms_output.new_line; l_line_size := 0;
       ELSIF l_line_size IN (70,120) AND p_v = ' ' THEN
	  dbms_output.new_line; l_line_size := 0;
       ELSIF l_line_size > 120 THEN
	 dbms_output.new_line; l_line_size := 0;
       ELSE
	 dbms_output.put(p_v); l_line_size := l_line_size +1;
      END IF;
   END LOOP;
   dbms_output.new_line;*/
EXCEPTION WHEN OTHERS THEN
   NULL;
END showsql;
--
-- API name    : ShowBindVars
-- Type        : Private
-- Function    : Shows all entries of the internal bind variable tables using
--               dbms_output. Needed for debugging.
-- Pre-reqs    : none
-- Parameters  : none
-- Version     : not tracked
-- Notes       :
PROCEDURE ShowBindVars IS
   n_i INTEGER;
BEGIN
   /*
   -- Show all numeric variables
   if g_num_counter > 0 then
     for n_i in 1..g_num_counter loop
     dbms_output.put_line(g_num_tbl(n_i).identifier||' = '||
     fnd_number.number_to_canonical(g_num_tbl(n_i).value));
     end loop;
     end if;
     -- Show all character variables
     if g_char_counter > 0 then
     for n_i in 1..g_char_counter loop
     dbms_output.put_line(g_char_tbl(n_i).identifier||' = '||
     g_char_tbl(n_i).value);
     end loop;
     end if;
     -- Show all date variables
     if g_date_counter > 0 then
     for n_i in 1..g_date_counter loop
     dbms_output.put_line(g_date_tbl(n_i).identifier||' = '||
     fnd_date.date_to_canonical(g_date_tbl(n_i).value));
     end loop;
     end if; */
     NULL;
END showbindvars;
END inv_sql_binding_pvt;

/
