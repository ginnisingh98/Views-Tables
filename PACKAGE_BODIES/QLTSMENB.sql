--------------------------------------------------------
--  DDL for Package Body QLTSMENB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTSMENB" as
/* $Header: qltsmenb.plb 115.7 2002/11/27 19:30:12 jezheng ship $ */

-- 8/2/95 - CREATED
-- Kevin Wiggen

--  This package does the join to other tables for qa results
--  It needs the char_id and value from results, and it will perform the lookup
--  It is not necessary to check if there is a lookup first, but its suggested

  FUNCTION LOOKUP(x_char_id IN NUMBER,
	          x_value   IN VARCHAR2)
     RETURN VARCHAR2	IS

   return_value_char  VARCHAR2(1500);
   return_value_num   NUMBER;
   return_value_date  DATE;

   used_where BOOLEAN := FALSE;
   V_DATATYPE NUMBER;
   V_FK_LOOKUP_TYPE NUMBER;
   V_FK_TABLE_NAME VARCHAR2(30);
   V_FK_TABLE_SHORT_NAME VARCHAR2(5);
   V_PK_ID VARCHAR2(30);
   V_PK_ID2 VARCHAR2(30);
   V_PK_ID3 VARCHAR2(30);
   V_FK_ID VARCHAR2(30);
   V_FK_ID2 VARCHAR2(30);
   V_FK_ID3 VARCHAR2(30);
   V_FK_MEANING VARCHAR2(30);
   V_FK_ADD_WHERE VARCHAR2(2000);

   source_cursor integer;
   ignore integer;

   V_CATEGORY_SET_ID VARCHAR2(1000);

   v_sql_statement VARCHAR2(20000) := null;

   cursor info is
	select DATATYPE, FK_LOOKUP_TYPE, FK_TABLE_NAME, FK_TABLE_SHORT_NAME,
               PK_ID, PK_ID2, PK_ID3, FK_ID, FK_ID2, FK_ID3, FK_MEANING,
	       FK_ADD_WHERE
        from   qa_chars
        where  char_id = x_char_id;

  BEGIN
    IF x_value IS NULL THEN
      RETURN(x_value);
    END IF;

    open info;
    fetch info into V_DATATYPE, V_FK_LOOKUP_TYPE, V_FK_TABLE_NAME,
		    V_FK_TABLE_SHORT_NAME, V_PK_ID, V_PK_ID2, V_PK_ID3,
		    V_FK_ID, V_FK_ID2, V_FK_ID3, V_FK_MEANING, V_FK_ADD_WHERE;

    close info;

    if (V_FK_LOOKUP_TYPE is null) or (V_FK_LOOKUP_TYPE = 2) then
	-- no lookup return original value
   	RETURN(x_value);
/*
    elsif x_char_id = 33 then			-- sales order number
        --
	-- Need special processing for sales order number for now because
	-- its data reside on two tables instead of one.  Will try to fix
	-- this in the future.
	-- bso Mon May 31 19:42:28 PDT 1999
	--
	v_sql_statement :=
        'select order_number from (' ||
	   'select to_number(segment1) order_number from mtl_sales_orders ' ||
	   'where sales_order_id=' || x_value || ' union all '||
	   'select order_number from oe_order_headers '||
	   'where header_id=' || x_value || ')' ||
        'where rownum = 1';
*/
    else
	v_sql_statement := 'SELECT ' || V_FK_TABLE_SHORT_NAME || '.' ||
                            V_FK_MEANING || ' FROM  ' ||
			    V_FK_TABLE_NAME || ' ' || V_FK_TABLE_SHORT_NAME ||
			    ' WHERE ' || x_value || ' = ' ||
			    V_FK_TABLE_SHORT_NAME || '.' || V_PK_ID;

        if V_PK_ID2 is not null then
	   v_sql_statement := v_sql_statement || ' and ' || QLTNINRB.NAME_IN(V_FK_ID2) ||
 			      ' = ' || V_FK_TABLE_SHORT_NAME || '.' || V_PK_ID2;
           if V_PK_ID3 is not null then
           v_sql_statement := v_sql_statement || ' and ' || QLTNINRB.NAME_IN(V_FK_ID3) ||
                              ' = ' || V_FK_TABLE_SHORT_NAME || '.' || V_PK_ID3;
           end if;
        end if;
        if V_FK_ADD_WHERE is not null then
	   v_sql_statement := v_sql_statement || ' and ' || V_FK_ADD_WHERE;
        end if;

        -- check for type 3s
	if (V_FK_LOOKUP_TYPE = 3) then
        -- This must be a Item Category, its our only three right now
        -- simply need to add a where clause that includes the cat_set_id profile
           V_CATEGORY_SET_ID := FND_PROFILE.VALUE('QA_CATEGORY_SET');
            -- check to see if the profile is set
           if V_CATEGORY_SET_ID is null then
	      FND_MESSAGE.SET_NAME('QA','QA_PROFILE_NOT_SET');
	      QLTSTORB.KILL_REC_GROUP;
	      APP_EXCEPTION.RAISE_EXCEPTION;
           end if;
           -- add the category Set
           v_sql_statement := v_sql_statement || ' CATEGORY_SET_ID = ' ||
			      V_CATEGORY_SET_ID || ' AND ';
        end if;
    end if;

    -- run the statement
    source_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(source_cursor, v_sql_statement, dbms_sql.v7);
    if V_DATATYPE = 1 then
       dbms_sql.define_column(source_cursor, 1, return_value_char, 1500);
    elsif V_DATATYPE = 2 then
       dbms_sql.define_column(source_cursor, 1, return_value_num);
    else
       dbms_sql.define_column(source_cursor, 1, return_value_date);
    end if;
    ignore := dbms_sql.execute(source_cursor);

    -- now get the value and return it

    -- For Bug2243760. Added Close_cursor statement in
    -- below three cases.

    if dbms_sql.fetch_rows(source_cursor)>0 then
       if V_DATATYPE = 1 then
	  dbms_sql.column_value(source_cursor,1, return_value_char);
	  dbms_sql.close_cursor(source_cursor);
	  RETURN(return_value_char);
       elsif V_DATATYPE = 2 then
	  dbms_sql.column_value(source_cursor,1, return_value_num);
	  dbms_sql.close_cursor(source_cursor);
	  RETURN(to_char(return_value_num));
       else
	  dbms_sql.column_value(source_cursor,1, return_value_date);
	  dbms_sql.close_cursor(source_cursor);
	  RETURN(to_char(return_value_date));
       end if;
    end if;

END LOOKUP;

END QLTSMENB;


/
