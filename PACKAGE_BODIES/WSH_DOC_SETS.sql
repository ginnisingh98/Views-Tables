--------------------------------------------------------
--  DDL for Package Body WSH_DOC_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DOC_SETS" AS
/* $Header: WSHUSDSB.pls 115.4 99/07/16 08:23:54 porting ship $ */

  -- Name
  --   Print_Document_Sets
  -- Purpose
  --   Execute any Delivery-based Document Set by submitting each document
  --   to the transaction mananger and printing each report on the pre-customized
  --   printer
  -- Arguments
  --   many - all required parameters for all the documents in the set must be
  --   supplied on calling the package (hence the long list). Any parameters that are
  --   not supplied will default to the default value as defined in the concurrent
  --   program. HOWEVER: if all mandatory parameters are not supplied (either directly
  --   to this package, or as default values in the Conc Prog Defn) then the report
  --   cannot be submitted.
  -- THIS DOES NOT SUPPORT
  --   parameter default values (ie those defined in the Con Prg Defn) with sql
  --   statements which reference other flex fields or profile values. ie for sql
  --   defined default values, this only supports standard sql. (because it takes
  --   the sql strings and plugs it into dynamic sql).
  --   Likewise, any translation to internal values through table validated value
  --   sets must contain standard sql in the where clause of the value set.
  --   Unsupported sql defaults will be ignored.
  -- IT DOES SUPPORT default values which are constants, profiles or simple sql.
  -- Notes
  -- USER DEFINED REPORTS
  --   if the user defines their own reports they should restrict parameter names
  --   to those used in this package. Additional they may use P_TEXT1 - P_TEXT4.

 -- use the following select to ensure all parameter assigned to reports are
 -- included as a parameter to this package.
 --
 -- we are trying to phase out OEXSHSKI + OEXSHOBR parameters. Do not use these for new
 -- reports. instead convert to the new style of parameter/token names
/*
  select cp.concurrent_program_name, col.column_seq_num seq, col.srw_param token, col.required_flag
  from  fnd_concurrent_programs_vl cp, fnd_descr_flex_column_usages col
  where col.application_id = 300 and cp.application_id = 300
  and   col.descriptive_flexfield_name = '$SRS$.'||cp.Concurrent_program_name
  and   cp.enabled_flag = 'Y'
  and   ( cp.concurrent_program_name ='WSHRDPIK')
  and col.srw_param is not null
  order by cp.concurrent_program_name,col.column_seq_num,col.application_column_name
*/

/* Included P_PROG_REQUEST_ID as a fix for bug 859003 */

  PROCEDURE Print_Document_Sets (X_report_set_id IN number,
	      P_BATCH_NAME              in varchar2 DEFAULT NULL,
	      P_BATCH_ID                in varchar2 DEFAULT NULL,
	      P_PROG_REQUEST_ID         in varchar2 DEFAULT NULL,
	      P_CATEGORY_HIGH           in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_CATEGORY_LOW            in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_CUSTOMER_ITEMS          in varchar2 DEFAULT NULL,
	      P_DELIVERY_ID             in varchar2 DEFAULT NULL,
	      P_DEPARTURE_DATE_HI       in varchar2 DEFAULT NULL,
	      P_DEPARTURE_DATE_LO       in varchar2 DEFAULT NULL,
	      P_DEPARTURE_ID            in varchar2 DEFAULT NULL,
	      P_FREIGHT_CARRIER         in varchar2 DEFAULT NULL,
	      P_ITEM                    in varchar2 DEFAULT NULL,
	      P_ITEM_DISPLAY            in varchar2 DEFAULT NULL,
	      P_ITEM_FLEX_CODE          in varchar2 DEFAULT NULL,
	      P_LINE_FLAG               in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_LOCATOR_FLEX_CODE       in varchar2 DEFAULT NULL,
	      P_ORDER_CATEGORY          in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_ORDER_TYPE_HIGH         in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_ORDER_TYPE_LOW          in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_ORGANIZATION_ID         in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_PICK_SLIP_NUMBER_HIGH   in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_PICK_SLIP_NUMBER_LOW    in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_PRINT_DESCRIPTION       in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_RELEASE_DATE_HIGH       in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_RELEASE_DATE_LOW        in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_RESERVATIONS            in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_SHIP_DATE_HIGH          in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_SHIP_DATE_LOW           in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_SOB_ID                  in varchar2 DEFAULT NULL,
	      P_USE_FUNCTIONAL_CURRENCY in varchar2 DEFAULT NULL,
	      P_WAREHOUSE               in varchar2 DEFAULT NULL,  /* oexshobr only */
	      P_WAREHOUSE_HIGH          in varchar2 DEFAULT NULL,  /* oexshski only */
	      P_WAREHOUSE_ID            in varchar2 DEFAULT NULL,
	      P_WAREHOUSE_LOW           in varchar2 DEFAULT NULL,  /* oexshski only */
              P_TEXT1                   in varchar2 default null,
	      P_TEXT2                   in varchar2 default null,
	      P_TEXT3                   in varchar2 default null,
	      P_TEXT4                   in varchar2 default null,
              message_string            in out varchar2,
              status                    in out boolean) is


  BEGIN
   declare
    shipping_style 		VARCHAR2(15);
    release_name   		VARCHAR2(15);
    prod_version		VARCHAR2(15);
    x_application_id            NUMBER;
    x_concurrent_program_name 	VARCHAR(40);
    x_concurrent_program_id 	NUMBER;
    x_execution_method_code	VARCHAR2(10);

    arg_cnt			NUMBER;
    x_request_id 		NUMBER;
    total_docs                  number:=0;
    submitted_docs              number:=0;

    valid_params	   	BOOLEAN := TRUE;
    error_in_a_doc		BOOLEAN := FALSE;

    X_Cursor 		NUMBER;
    X_Rows 		NUMBER;
    sql_value           Varchar2(100);
    X_Stmt_Num		NUMBER;

    arg_value                   varchar2(240);
    arg_name                    varchar2(30);
    arg_required_flag           varchar2(1);
    arg_default_value           varchar2(2000);
    arg_default_type            varchar2(1);
    arg_value_set_id            number;

    TYPE arg_table     	IS TABLE OF VARCHAR(80) INDEX BY BINARY_INTEGER;
    argument                    arg_table;

    cursor DOCUMENT_SET is
	 select a.application_id,
                a.application_short_name,
                f.concurrent_program_id,
	        f.concurrent_program_name,
                f.user_concurrent_program_name,
                f.printer_name default_printer_name,
                f.output_print_style,
                f.save_output_flag,
                f.print_flag,
		f.execution_method_code
	 from fnd_concurrent_programs_vl  f,
              so_report_set_lines rs, fnd_application a
	 where rs.report_set_id = X_report_set_id
	 and   rs.report_id = f.concurrent_program_id
	 and   rs.application_id = f.application_id
         and   a.application_id = f.application_id
	 and   f.enabled_flag = 'Y'
         order by rs.report_sequence;

    Cursor DOCUMENT_PARAMS is
       select	decode (upper(decode(x_execution_method_code,'P',srw_param,end_user_column_name)),
			'P_BATCH_NAME',P_BATCH_NAME,
			'P_BATCH_ID',P_BATCH_ID,
			'P_PROG_REQUEST_ID',P_PROG_REQUEST_ID,
			'P_CATEGORY_HIGH',P_CATEGORY_HIGH,
			'P_CATEGORY_LOW',P_CATEGORY_LOW,
			'P_CUSTOMER_ITEMS',P_CUSTOMER_ITEMS,
			'P_DELIVERY_ID',P_DELIVERY_ID,
			'P_DEPARTURE_DATE_HI',P_DEPARTURE_DATE_HI,
			'P_DEPARTURE_DATE_LO',P_DEPARTURE_DATE_LO,
			'P_DEPARTURE_ID',P_DEPARTURE_ID,
			'P_FREIGHT_CARRIER',P_FREIGHT_CARRIER,
			'P_ITEM',P_ITEM,
			'P_ITEM_DISPLAY',P_ITEM_DISPLAY,
			'P_ITEM_FLEX_CODE',P_ITEM_FLEX_CODE,
			'P_LINE_FLAG',P_LINE_FLAG,
			'P_LOCATOR_FLEX_CODE',P_LOCATOR_FLEX_CODE,
			'P_ORDER_CATEGORY',P_ORDER_CATEGORY,
			'P_ORDER_TYPE_HIGH',P_ORDER_TYPE_HIGH,
			'P_ORDER_TYPE_LOW',P_ORDER_TYPE_LOW,
			'P_ORGANIZATION_ID',P_ORGANIZATION_ID,
			'P_PICK_SLIP_NUMBER_HIGH',P_PICK_SLIP_NUMBER_HIGH,
			'P_PICK_SLIP_NUMBER_LOW',P_PICK_SLIP_NUMBER_LOW,
			'P_PRINT_DESCRIPTION',P_PRINT_DESCRIPTION,
			'P_RELEASE_DATE_HIGH',P_RELEASE_DATE_HIGH,
			'P_RELEASE_DATE_LOW',P_RELEASE_DATE_LOW,
			'P_RESERVATIONS',P_RESERVATIONS,
			'P_SHIP_DATE_HIGH',P_SHIP_DATE_HIGH,
			'P_SHIP_DATE_LOW',P_SHIP_DATE_LOW,
			'P_SOB_ID',P_SOB_ID,
			'P_USE_FUNCTIONAL_CURRENCY',P_USE_FUNCTIONAL_CURRENCY,
			'P_WAREHOUSE',P_WAREHOUSE,
			'P_WAREHOUSE_HIGH',P_WAREHOUSE_HIGH,
			'P_WAREHOUSE_ID',P_WAREHOUSE_ID,
			'P_WAREHOUSE_LOW',P_WAREHOUSE_LOW,
			'P_TEXT1',P_TEXT1,
			'P_TEXT2',P_TEXT2,
			'P_TEXT3',P_TEXT3,
			'P_TEXT4',P_TEXT4,
			'UNSUPPORTED') arg_value,
		end_user_column_name,
		required_flag,
		default_value,
		default_type,
		flex_value_set_id
		from fnd_descr_flex_column_usages
       where	application_id = x_application_id
       and  	descriptive_flexfield_name = '$SRS$.'||x_concurrent_program_name
       and	enabled_flag = 'Y'
       order by column_seq_num;

    Cursor value_set_cursor (X_value_set_id in number)  is
    select
        'select '||ID_COLUMN_NAME||
        ' from '||APPLICATION_TABLE_NAME,
        ADDITIONAL_WHERE_CLAUSE,
        ' and '|| VALUE_COLUMN_NAME||'=:value'||
        ' and '|| ENABLED_COLUMN_NAME||'=''Y'''||
        ' and nvl('|| START_DATE_COLUMN_NAME||',sysdate)<=sysdate'||
	' and nvl('|| END_DATE_COLUMN_NAME||',sysdate)>=sysdate'
	from fnd_flex_validation_tables
	where flex_value_set_id = X_value_set_id
        and id_column_name is not null;

    select_clause varchar2(250);
    where_clause  varchar2(2000);
    additional_clause varchar2(250);
    value_set_lookup varchar2(2000);


printer_setup  boolean;
printer_name   varchar2(30);
save_output    boolean;
printer_level  number;
cursor report_level (X_concurrent_program_id NUMBER, X_application_id NUMBER)  is
SELECT MAX(LEVEL_TYPE_ID)
  FROM SO_REPORT_PRINTERS
 WHERE REPORT_ID = X_concurrent_program_id
   AND APPLICATION_id = x_application_id
   AND LEVEL_VALUE_ID = DECODE(LEVEL_TYPE_ID,
                        10001,0,                  10002, FND_GLOBAL.RESP_APPL_ID,
                        10003,FND_GLOBAL.RESP_ID, 10004, FND_GLOBAL.USER_ID)
   AND ENABLE_FLAG = 'Y';


cursor report_printer (X_concurrent_program_id NUMBER,
                       X_application_id NUMBER, X_printer_level NUMBER) is
SELECT NVL(PRINTER_NAME, 'No Printer')
 FROM  SO_REPORT_PRINTERS
 WHERE REPORT_ID = X_concurrent_program_id
   AND APPLICATION_id = X_application_id
   AND LEVEL_TYPE_ID = X_printer_level
   AND LEVEL_VALUE_ID = DECODE(X_printer_level,
                        10001,0,                  10002, FND_GLOBAL.RESP_APPL_ID,
                        10003,FND_GLOBAL.RESP_ID, 10004, FND_GLOBAL.USER_ID)
   AND ENABLE_FLAG = 'Y';

   no_reportset_to_process EXCEPTION;




    begin

     if x_report_set_id is null then
        raise no_reportset_to_process;
     end if;

     -- for each document in the document set, select its parameters
     -- and then launch it.
     FOR DOCUMENT IN DOCUMENT_SET LOOP

         total_docs := total_docs +1;

	 x_concurrent_program_name := document.concurrent_program_name;
         x_application_id          := document.application_id;
	 x_execution_method_code   := document.execution_method_code;

	 WSH_UTIL.WRITE_LOG('Processing document ' || x_concurrent_program_name, 3);

         arg_cnt := 0;
         valid_params := TRUE;

         OPEN DOCUMENT_PARAMS;

         -- fetch each parameter for the document
         -- both the arg name, the value passed in to this package and any dflt value
         LOOP
           FETCH DOCUMENT_PARAMS
           INTO  arg_value,
                 arg_name,
                 arg_required_flag,
                 arg_default_value,
                 arg_default_type,
                 arg_value_set_id;

           EXIT WHEN (document_params%notfound) or (NOT valid_params);

           arg_cnt := arg_cnt + 1;

	   WSH_UTIL.WRITE_LOG('Argument Name ' || arg_name, 3);
	   WSH_UTIL.WRITE_LOG('Argument Value ' || arg_value, 3);
	   WSH_UTIL.WRITE_LOG('Argument Required ' || arg_required_flag, 3);

           if arg_value <> 'UNSUPPORTED' then
              argument(arg_cnt) := arg_value;
           else
              argument(arg_cnt) := null;
           end if;

           -- if the argument does not have a value, then check its default
           -- as defined in the concurrent program definition
           if argument(arg_cnt) is null then
               -- only check for Constants or Profile values
               if arg_default_type = 'C' then    -- Constant
                  argument(arg_cnt) := arg_default_value;
               elsif arg_default_type = 'P' then  -- Profile
                  argument(arg_cnt) := fnd_profile.value(arg_default_value);
               elsif arg_default_type = 'S' then   -- Sql
                  -- use dynamic sql to get the default value.
                  -- NOTE not all values will be defined if this references another
                  -- flex field, this will cause an error in which case continue
		  begin
		    begin

		     X_Cursor := dbms_sql.open_cursor;
		     dbms_sql.parse(X_Cursor,arg_default_value,dbms_sql.v7);
		     DBMS_SQL.Define_Column(X_cursor, 1, sql_value, 100 );
		     X_Rows := dbms_sql.execute(X_Cursor);
		     X_Rows := dbms_sql.fetch_rows(X_Cursor);
		     DBMS_SQL.Column_Value(X_cursor, 1, sql_value);
		     IF dbms_sql.is_open(X_Cursor) THEN
			dbms_sql.close_cursor(X_Cursor);
		     END IF;

--	             dbms_output.put_line('Value for dynamic sql select is '||sql_value);
		     argument(arg_cnt) := sql_value;
		    end;
		    exception when others then null;
		  end;
               end if;

               -- we now have the default value. If this is validated against a table value set
               -- which select an id_column, then we must convert the user-friendly default
               -- value to its internal value using the value set.
               if argument(arg_cnt) is not null then

		open value_set_cursor(arg_value_set_id);
                fetch value_set_cursor into  select_clause, where_clause, additional_clause;
                if  (value_set_cursor%found)  then
                  if substr(upper(where_clause),1,5) = 'WHERE' then
                     where_clause :=  ' and '||substr(where_clause,6);
                  end if;

                  -- always put where clause at end as it may include an ORDER_BY clause
                  value_set_lookup := select_clause||' where 1=1 ' || additional_clause ||' '|| where_clause;

--		  dbms_output.put_line('Value for dynamic sql is: '||value_set_lookup);
--		  dbms_output.put_line('Where value =  '||sql_value);
                  begin
   	            X_Cursor := dbms_sql.open_cursor;
		    dbms_sql.parse(X_Cursor,value_set_lookup,dbms_sql.v7);
                    DBMS_SQL.Bind_Variable(X_cursor,':value',argument(arg_cnt));
		    DBMS_SQL.Define_Column(X_cursor, 1, sql_value, 255 );
		    X_Rows := dbms_sql.execute(X_Cursor);
		    X_Rows := dbms_sql.fetch_rows(X_Cursor);
		    DBMS_SQL.Column_Value(X_cursor, 1, sql_value);
                   exception when others then
--		      dbms_output.put_line('Error in dynamic sql; arg_value_set_id:'||to_char(arg_value_set_id));
--		      dbms_output.put_line('Error in dynamic sql:'||value_set_lookup);
--		      dbms_output.put_line('Where value =  '||sql_value);
		      --  dont interupt: set this param to null. If its required, then user
                      --  will be informed there is a missing required flag.
		      sql_value := NULL;
                  end;

		  IF dbms_sql.is_open(X_Cursor) THEN
		     dbms_sql.close_cursor(X_Cursor);
		  END IF;
		  if sql_value is not null then
		     argument(arg_cnt) := sql_value;
                  end if;

                end if;
                close value_set_cursor;
               end if;

           end if;

           -- if still null and its required then raise appropriate error
           if (argument(arg_cnt) is null) and arg_required_flag = 'Y' then
              if arg_value = 'UNSUPPORTED' then
  	        FND_MESSAGE.Set_Name('OE','WSH_UNSUPPORTED_ARG');
	        FND_MESSAGE.Set_Token('ARGUMENT',arg_name);
	        FND_MESSAGE.Set_Token('DOCUMENT',
                                       document.user_concurrent_program_name);
		WSH_UTIL.Write_Log('WSH_UNSUPPORTED_ARG IN DOC '||
				   arg_name||' '||
				   document.user_concurrent_program_name);
              else
  	        FND_MESSAGE.Set_Name('OE','WSH_NULL_ARG_IN_DOC');
	        FND_MESSAGE.Set_Token('ARGUMENT',arg_name);
	        FND_MESSAGE.Set_Token('DOCUMENT',
                                       document.user_concurrent_program_name);
		WSH_UTIL.Write_Log('WSH_NULL_ARG IN DOC '||arg_name||' '||
				   x_concurrent_program_name);
              end if;
              -- set error_flags to stop processing this document
              valid_params := FALSE;
              error_in_a_doc := TRUE;
           end if;

         END LOOP;
         CLOSE DOCUMENT_PARAMS;

         if VALID_PARAMS then
            -- loop through the rest of the arguments (upto 30) setting any
            -- remaining ones to null for unassigned.
            WHILE arg_cnt < 30 LOOP
               arg_cnt := arg_cnt +1;
               argument(arg_cnt) := '';
            END LOOP;

            -- set up the printer

           if document.print_flag = 'Y' then

--	      dbms_output.put_line(' applid='||to_char(FND_GLOBAL.RESP_APPL_ID)||
--	      ' resp_id='||to_char(FND_GLOBAL.RESP_ID) ||
--	      ' user_id='||to_char(FND_GLOBAL.USER_ID));

--	      dbms_output.put_line(' prog_id='||(document.concurrent_program_id)||
--	      ' app='|| to_char(document.application_id));

              open  report_level(document.concurrent_program_id, document.application_id);
              fetch report_level into printer_level;
              close report_level;

              printer_name := null;
              open  report_printer(document.concurrent_program_id,
                                  document.application_id, printer_level);
              fetch report_printer into printer_name;
              close report_printer;

              if printer_name is null or printer_name = 'No Printer'  then
                printer_name := document.default_printer_name;
              end if;

              if document.save_output_flag = 'Y' then
                save_output := TRUE;
              else
                save_output := FALSE;
              end if;

              if printer_name is not null then
                printer_setup := FND_REQUEST.Set_print_options(
                  printer_name,
	          document.output_print_style,
                  1, save_output,  'N');
              end if;
            end if;
            -- go ahead and submit this document as a request
            x_request_id := FND_REQUEST.Submit_Request(
              document.application_short_name,
	      document.concurrent_program_name,'','',FALSE,
              argument(1), argument(2), argument(3), argument(4), argument(5),
              argument(6), argument(7), argument(8), argument(9), argument(10),
              argument(11),argument(12),argument(13),argument(14),argument(15),
              argument(16),argument(17),argument(18),argument(19),argument(20),
              argument(21),argument(22),argument(23),argument(24),argument(25),
              argument(26),argument(27),argument(28),argument(29),argument(30),
	      '','','','','','','','','','',
	      '','','','','','','','','','',
	      '','','','','','','','','','',
	      '','','','','','','','','','',
	      '','','','','','','','','','',
	      '','','','','','','','','','',
	      '','','','','','','','','','');

            -- increase the counter if successful
            if x_request_id > 0 then
              submitted_docs := submitted_docs +1;
	      WSH_UTIL.WRITE_LOG('Request ID ' || to_char(x_request_id), 3);
            end if;

         end if;
     END LOOP;

     if error_in_a_doc then
        -- an error occured in at least one document submission
        -- because of a missing required argument or an unsupported argument

        status := FALSE;

     elsif (total_docs = 0 ) then
       -- successfully looped through all documents but didnt submit any
       -- probably because there werent any in the set (but may have had problems
       -- in fnd_request function

        WSH_UTIL.Write_Log('no documents in document set');
        FND_MESSAGE.Set_Name('OE','WSH_NO_DOCS');
        status := FALSE;

     else
       -- everthing worked: any documents not submitted resulted
       -- from problem in fnd_request
        status := TRUE;
	WSH_UTIL.Write_Log('Submitted '||to_char(submitted_docs)||
			     ' out of '||to_char(total_docs));

	FND_MESSAGE.Set_Name('OE','WSH_DOCS_SUBMITTED');
	FND_MESSAGE.Set_Token('SUBMITTED_DOCS',submitted_docs);
	FND_MESSAGE.Set_Token('TOTAL_DOCS',total_docs);
     end if;

     message_string := FND_MESSAGE.get;


  EXCEPTION
    WHEN NO_REPORTSET_TO_PROCESS THEN
	WSH_UTIL.Write_Log('No Reports to process');
        null;
    WHEN OTHERS THEN
	FND_MESSAGE.Set_Name('OE','OE_QUERY_ERROR');
	FND_MESSAGE.Set_Token('PACKAGE','WSH_DOC_SETS.Print_document_sets');
	FND_MESSAGE.Set_Token('ORA_ERROR',to_char(sqlcode));
        FND_MESSAGE.Set_Token('ORA_TEXT','Unexpected exception');
	message_string := FND_MESSAGE.get;
   end;
  END Print_Document_sets;

END WSH_DOC_SETS;

/
