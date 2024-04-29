--------------------------------------------------------
--  DDL for Package Body AMV_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_SEARCH_PVT" AS
/* $Header: amvvserb.pls 120.2 2005/07/28 11:55:02 appldev ship $ */

--
-- NAME
--   AMV_SEARCH_PVT
--
-- HISTORY
--   10/06/1999        SLKRISHN        CREATED
--   06/15/2000        svatsa          UPDATED
--                                     Added the procedure Parse_IMT_String to handle the 256 character limitation
--                                     Added a record type and a table type for this purpose: parsed_rec_type and
--                                     parsed_tbl_type
--                                     The following API have been modified due to this change :
--                                     1. Build_Chan_Name_Sql
--                                     2. Build_Items_Name_Sql
--                                     3. Build_Items_File_Sql
--                                     4. Build_Items_Text_Sql
--                                     5. Build_Items_URL_Sql
--
-- 10/23/00 	jjwu	Removed 'UNION ALL' statements

--			insert into 'amv_temp_ids' table right after each

--			substatement construction

--

--

-- 6/07/04 	Sharma	Fixed bug 2719461
--			SQL in procedure Build_Items_File_Sql, Build_Items_Text_Sql
--			Build_Items_URL_Sql modified to get correct score
--
-- 27-Jul-2005 MKETTLE Removed Schema prefix for trunc of AMV_TEMP_NUMBERS
--




G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMV_SEARCH_PVT';

G_FILE_NAME     CONSTANT VARCHAR2(12) := 'amvvserb.pls';

--

TYPE CursorType IS REF CURSOR;

G_AMV_SEARCH		CONSTANT	VARCHAR2(30) := 'AMV_SEARCH';

G_CONTENT_AREA 	CONSTANT  VARCHAR2(30) := 'CONTENT_AREA';

G_SEARCH_AREA 		CONSTANT  VARCHAR2(30) := 'SEARCH_AREA';

G_CONDITION_CONS 	CONSTANT  VARCHAR2(30) := 'CONDITION_CONS';

G_WORD_CONS 		CONSTANT  VARCHAR2(30) := 'WORD_CONS';



G_PUBLIC			CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_PUBLIC;

G_PRIVATE			CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_PRIVATE;

G_GROUP			CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_GROUP;

G_CONTENT			CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_CONTENT;



G_APPROVED		CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_APPROVED;

G_CHANNEL			CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_CHANNEL;

G_CATEGORY		CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_CATEGORY;

G_ITEM			CONSTANT	VARCHAR2(30) := AMV_UTILITY_PVT.G_ITEM;

G_AUTHOR 			CONSTANT  VARCHAR2(30) := 'AUTHOR';

G_KEYWORD 		CONSTANT  VARCHAR2(30) := 'KEYWORD';

G_TITLE_DESC 		CONSTANT  VARCHAR2(30) := 'TITLE_DESC';

G_CAN_CONTAIN		CONSTANT	VARCHAR2(30) := 'CAN_CONTAIN';

G_MUST_CONTAIN		CONSTANT	VARCHAR2(30) := 'MUST_CONTAIN';

G_MUST_NOT_CONTAIN	CONSTANT	VARCHAR2(30) := 'MUST_NOT_CONTAIN';



-- Record and Table Type for Parse_IMT_String

TYPE parsed_rec_type IS RECORD

(

 imt_string VARCHAR2(250)

);



TYPE parsed_tbl_type IS TABLE OF parsed_rec_type INDEX BY BINARY_INTEGER;



--------------------------------------------------------------------------------

FUNCTION Default_AreaArray return AMV_CHAR_VARRAY_TYPE

IS

l_array	amv_char_varray_type;

BEGIN

	l_array := amv_char_varray_type();

	l_array.extend;

	l_array(1) := G_ITEM;



	return l_array;

END Default_AreaArray;

--------------------------------------------------------------------------------

FUNCTION Default_ContentArray return AMV_CHAR_VARRAY_TYPE

IS

l_array	amv_char_varray_type;

BEGIN

	l_array := amv_char_varray_type();

	l_array.extend;

	l_array(1) := G_AUTHOR;

	l_array.extend;

	l_array(2) := G_KEYWORD;

	l_array.extend;

	l_array(3) := G_TITLE_DESC;



	return l_array;

END Default_ContentArray;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

-- Procedure for parsing the IMT String

PROCEDURE Parse_IMT_String

  (

   p_imt_string IN  VARCHAR2

  ,x_parsed_tbl OUT NOCOPY parsed_tbl_type

  );

--------------------------------------------------------------------------------

-- build an array of optional, required and excluded parameters

PROCEDURE parse_parameter_array(

			 p_param_array		IN   AMV_SEARCHPAR_VARRAY_TYPE,

			 x_optional_array OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,

			 x_required_array OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,

			 x_excluded_array OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,

			 x_keywords_search  OUT NOCOPY  VARCHAR2);

--------------------------------------------------------------------------------

PROCEDURE get_chan_attr_stmt(

	p_table_name		IN  VARCHAR2,

   	p_where_column		IN  VARCHAR2,

	p_application_id	IN  NUMBER,

	p_days			IN  NUMBER,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

   	p_optional_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_required_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_excluded_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S);

--------------------------------------------------------------------------------

PROCEDURE get_item_attr_stmt(

	p_table_name		IN  VARCHAR2,

   	p_where_column		IN  VARCHAR2,

	p_application_id	IN  NUMBER   := FND_API.G_MISS_NUM,

	p_days			IN  NUMBER,

	p_external_contents	IN  VARCHAR2 := FND_API.G_FALSE,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_search_level		IN  VARCHAR2,

   	p_optional_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_required_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_excluded_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S);

--------------------------------------------------------------------------------

PROCEDURE get_user_accessable_channels(

			p_user_id IN NUMBER,

			p_application_id IN NUMBER,

			x_channel_array OUT NOCOPY AMV_NUMBER_VARRAY_TYPE);

--------------------------------------------------------------------------------

PROCEDURE get_app_categories(

			p_application_id IN NUMBER,

			x_category_array OUT NOCOPY AMV_NUMBER_VARRAY_TYPE);

--------------------------------------------------------------------------------

PROCEDURE	get_category_channel (

			p_category_id      IN  AMV_NUMBER_VARRAY_TYPE,

			p_application_id   IN  NUMBER,

			p_include_subcats  IN  VARCHAR2,

			x_category_array   OUT NOCOPY AMV_NUMBER_VARRAY_TYPE,

			x_channel_array    OUT NOCOPY AMV_NUMBER_VARRAY_TYPE);

--------------------------------------------------------------------------------

PROCEDURE build_chan_name_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER,

	p_excluded_flag	IN  VARCHAR2,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

);

--------------------------------------------------------------------------------

PROCEDURE build_items_name_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

);

--------------------------------------------------------------------------------

PROCEDURE build_items_file_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

);

--------------------------------------------------------------------------------

PROCEDURE build_items_text_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

);

--------------------------------------------------------------------------------

PROCEDURE build_items_url_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

);

--------------------------------------------------------------------------------

PROCEDURE insert_temp_numbers(p_id_array IN  AMV_NUMBER_VARRAY_TYPE,

			      x_status 	 OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------

PROCEDURE insert_temp_ids(p_stmt IN OUT NOCOPY  DBMS_SQL.VARCHAR2S,

			 p_start_index 	IN  PLS_INTEGER,

			 p_end_index	IN  PLS_INTEGER,

			 x_status    OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------

PROCEDURE populate_channel_results (

	p_results_requested IN NUMBER,

	x_start_with 		IN OUT NOCOPY NUMBER,

	x_results_array  	IN OUT NOCOPY AMV_SEARCHRES_VARRAY_TYPE,

	x_results_populated IN OUT NOCOPY NUMBER,

	x_total_results	IN OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------

PROCEDURE populate_item_results (

	p_search_level		IN VARCHAR2,

	p_results_requested IN NUMBER,

	x_start_with 		IN OUT NOCOPY NUMBER,

	x_results_array  	IN OUT NOCOPY AMV_SEARCHRES_VARRAY_TYPE,

	x_results_populated IN OUT NOCOPY NUMBER,

	x_total_results	IN OUT NOCOPY NUMBER);

--------------------------------------------------------------------------------

PROCEDURE  build_channel_stmt (

	p_content_array	IN AMV_CHAR_VARRAY_TYPE,

	p_imt_string		IN VARCHAR2,

	p_optional_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_required_array  	IN AMV_CHAR_VARRAY_TYPE,

	p_excluded_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_keywords_search	IN VARCHAR2 := FND_API.G_TRUE,

	p_excluded_flag	IN VARCHAR2 := FND_API.G_FALSE,

	p_application_id 	IN NUMBER,

	p_days		 	IN NUMBER,

	p_include_chns  	IN VARCHAR2 := FND_API.G_TRUE,

	p_search_level  	IN VARCHAR2 := G_CHANNEL,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	p_index		  	IN OUT NOCOPY PLS_INTEGER,

	x_chan_sql_stmt   OUT NOCOPY DBMS_SQL.VARCHAR2S,

	x_chan_sql_status OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------

PROCEDURE  build_item_stmt (

	p_content_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_optional_array 	IN  AMV_CHAR_VARRAY_TYPE,

	p_required_array  	IN  AMV_CHAR_VARRAY_TYPE,

	p_excluded_array 	IN  AMV_CHAR_VARRAY_TYPE,

	p_keywords_search	IN  VARCHAR2 := FND_API.G_TRUE,

	p_excluded_flag	IN  VARCHAR2 := FND_API.G_FALSE,

	p_imt_string		IN  VARCHAR2,

	p_application_id 	IN  NUMBER := FND_API.G_MISS_NUM,

	p_days		 	IN  NUMBER,

	p_include_chns  	IN  VARCHAR2 := FND_API.G_TRUE,

	p_search_level  	IN  VARCHAR2,

	p_external_contents IN  VARCHAR2,

	p_index		  	IN  OUT NOCOPY PLS_INTEGER,

	x_item_sql_stmt   OUT NOCOPY DBMS_SQL.VARCHAR2S,

	x_item_sql_status   OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------------

PROCEDURE search_items(

	p_area_array	 	IN AMV_CHAR_VARRAY_TYPE,

	p_content_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_imt_string	 	IN VARCHAR2,

	p_optional_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_required_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_excluded_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_keywords_search 	IN VARCHAR2,

	p_excluded_flag 	IN VARCHAR2,

	p_application_id 	IN NUMBER,

	p_days		 	IN NUMBER,

	p_include_chns		IN VARCHAR2,

	p_search_level  	IN VARCHAR2,

	p_external_contents IN VARCHAR2,

	p_records_requested IN NUMBER,

	x_start_with		IN OUT NOCOPY NUMBER,

	x_results_populated	IN OUT NOCOPY NUMBER,

	x_total_count		IN OUT NOCOPY NUMBER,

	x_searchres_array	IN OUT NOCOPY AMV_SEARCHRES_VARRAY_TYPE);

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

-- Procedure for parsing the IMT String

PROCEDURE Parse_IMT_String

  (

   p_imt_string IN  VARCHAR2

  ,x_parsed_tbl OUT NOCOPY parsed_tbl_type

  )

IS

l_imt_string    VARCHAR2(32000) := p_imt_string; -- Initialize with p_imt_string

l_string_length NUMBER;        -- Total string length of the IMT string

l_search_length NUMBER := 200; -- Search every 200 characters of the IMT string

l_split_at      NUMBER;        -- Place in the string at which the split is supposed to occur

l_counter       NUMBER;        -- Loop counter

l_rec_count     NUMBER;        -- Table record count for the table, x_parsed_tbl



BEGIN



-- Get the total string length of l_imt_string

l_string_length := LENGTH(l_imt_string);

--DBMS_OUTPUT.PUT_LINE('Complete String Length = '||l_string_length );



-- Get the number of times the string will be parsed into l_counter

-- Function CEIL gives the highest integer for the argument passed

l_counter := CEIL(l_string_length/l_search_length);



--DBMS_OUTPUT.PUT_LINE('Loop Counts = '||to_char( l_counter ) );



-- Populate the x_parsed_tbl

-- Initialize the l_rec_count

l_rec_count := 1;

FOR i in 1 .. l_counter LOOP

  -- Search the first occurence of the word , (comma) in l_imt_string after every 200(l_search_length) characters

  l_split_at := INSTR(UPPER(l_imt_string),',',l_search_length,1);



  --DBMS_OUTPUT.PUT_LINE('Search About = '||to_char(l_split_at ) );



  -- If the occurence of comma is found then populate the table record with the searched place less one

  -- else populate the table record with the reminder of the l_imt_string and exit the loop



  IF l_split_at <> 0 THEN

    x_parsed_tbl(l_rec_count).imt_string := SUBSTR(l_imt_string,1,l_split_at -1);

/*    --DBMS_OUTPUT.PUT_LINE('x_parsed_tbl('||to_char(l_rec_count)||').imt_string = '

                                        || x_parsed_tbl(l_rec_count).imt_string );*/

  ELSE

    x_parsed_tbl(l_rec_count).imt_string := l_imt_string;

/*    --DBMS_OUTPUT.PUT_LINE('x_parsed_tbl('||to_char(l_rec_count)||').imt_string = '

                                        || l_imt_string );*/

    EXIT;

  END IF;



  -- Modify l_imt_string for next iteration of the FOR loop. This will begin from the place where the

  -- occurence of comma is found

  l_imt_string := substr(l_imt_string,l_split_at);



  -- Increment the table record count

  l_rec_count := l_rec_count + 1;

END LOOP;

EXCEPTION

  WHEN OTHERS THEN

    RAISE;

/*    FND_MESSAGE.SET_NAME('AMV','AMV_API_ERROR');

    FND_MESSAGE.Set_Token('API', 'Parse_IMT_String');

    FND_MSG_PUB.ADD;*/

END Parse_IMT_String;



--------------------------------------------------------------------------------

-- build an array of optional, required and excluded parameters

PROCEDURE parse_parameter_array(

			 p_param_array		IN   AMV_SEARCHPAR_VARRAY_TYPE,

			 x_optional_array OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,

			 x_required_array OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,

			 x_excluded_array OUT NOCOPY  AMV_CHAR_VARRAY_TYPE,

			 x_keywords_search  OUT NOCOPY  VARCHAR2)

IS

l_opt_num		number := 1;

l_req_num		number := 1;

l_exc_num		number := 1;

BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : parse_parameter_array ');

	x_optional_array := amv_char_varray_type();

	x_required_array := amv_char_varray_type();

	x_excluded_array := amv_char_varray_type();

	IF p_param_array.count > 0 THEN

	  FOR i in 1..p_param_array.count LOOP

		IF p_param_array(i).operator = G_CAN_CONTAIN THEN

			x_optional_array.extend;

			x_optional_array(l_opt_num) := p_param_array(i).search_string;

			l_opt_num := l_opt_num + 1;

		ELSIF p_param_array(i).operator = G_MUST_CONTAIN THEN

			x_required_array.extend;

			x_required_array(l_req_num) := p_param_array(i).search_string;

			l_req_num := l_req_num + 1;

		ELSIF p_param_array(i).operator = G_MUST_NOT_CONTAIN THEN

			x_excluded_array.extend;

			x_excluded_array(l_exc_num) := p_param_array(i).search_string;

			l_exc_num := l_exc_num + 1;

		END IF;

	  END LOOP;

	  x_keywords_search := FND_API.G_TRUE;

	ELSE

		x_keywords_search := FND_API.G_FALSE;

	END IF;

--DBMS_OUTPUT.PUT_LINE('Exit : parse_parameter_array');

EXCEPTION

  WHEN OTHERS THEN

--DBMS_OUTPUT.PUT_LINE('Others : parse_parameter_array' );

    RAISE;

END parse_parameter_array;

--------------------------------------------------------------------------------

-- build imt search string

PROCEDURE build_imt_string(

			p_optional_array	IN  AMV_CHAR_VARRAY_TYPE,

	 		p_required_array	IN  AMV_CHAR_VARRAY_TYPE,

			p_excluded_array	IN  AMV_CHAR_VARRAY_TYPE,

			x_exc_flag	 OUT NOCOPY VARCHAR2,

			x_imt_string	 OUT NOCOPY VARCHAR2)

IS

l_req_string	varchar2(4000);

l_opt_string	varchar2(4000);

BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : build_imt_string' );

	-- build string for AND operator

	if p_required_array.count > 0 then

	 l_req_string := l_req_string || '(' ;

	 for i in 1..p_required_array.count loop

	   	if i = 1 then

		 l_req_string := l_req_string ||'{'||p_required_array(i)||'}';

		else

		 l_req_string := l_req_string ||'&'||'{'||p_required_array(i)||'}';

		end if;

      end loop;

	 l_req_string := l_req_string || ')' ;

	end if;



	-- build string for ACCUM operator

	if p_optional_array.count > 0 then

	 l_opt_string := l_opt_string || '(' ;

	 for i in 1..p_optional_array.count loop

	   	if i = 1 then

		 l_opt_string := l_opt_string ||'{'|| p_optional_array(i)||'}';

	  	else

		 l_opt_string := l_opt_string ||','||'{'||p_optional_array(i)||'}';

		end if;

      end loop;

	 l_opt_string := l_opt_string || ')' ;

	end if;



	if l_req_string is not null then

		if l_opt_string is not null then

	 	 	x_imt_string := x_imt_string||

		   		l_req_string||'|('||l_req_string||'&'||l_opt_string||')';

		else

	 	 	x_imt_string := x_imt_string|| l_req_string;

		end if;

		x_exc_flag := FND_API.G_FALSE;

	else

		if l_opt_string is not null then

	 	 	x_imt_string := x_imt_string|| l_opt_string;

			x_exc_flag := FND_API.G_FALSE;

		end if;

	end if;



	-- build string for NOT operator

	if p_excluded_array.count > 0 then

	 if x_imt_string is null then

	 	x_imt_string := x_imt_string || '(' ;

		x_exc_flag := FND_API.G_TRUE;

	 else

	 	x_imt_string := x_imt_string || ' ~ (' ;

		x_exc_flag := FND_API.G_FALSE;

	 end if;



	 for i in 1..p_excluded_array.count loop

	   	if i = 1 then

		 x_imt_string := x_imt_string ||'{'||p_excluded_array(i)||'}';

		else

		 x_imt_string := x_imt_string ||','||'{'||p_excluded_array(i)||'}';

		end if;

      end loop;

	 x_imt_string := x_imt_string || ')' ;

	end if;

--DBMS_OUTPUT.PUT_LINE('Exit : build_imt_string' );

EXCEPTION

  WHEN OTHERS THEN

--DBMS_OUTPUT.PUT_LINE('Others : build_imt_string' );

    RAISE;



END build_imt_string;

--------------------------------------------------------------------------------

PROCEDURE get_chan_attr_stmt(

	p_table_name		IN  VARCHAR2,

   	p_where_column		IN  VARCHAR2,

	p_application_id	IN  NUMBER,

	p_days			IN  NUMBER,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

   	p_optional_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_required_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_excluded_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S)

IS

l_where_clause varchar2(10);

l_select		varchar2(100);

l_from		varchar2(400);

l_where 		varchar2(2000);

l_optional	varchar2(1000);

l_required	varchar2(1000);

l_excluded	varchar2(1000);

l_join_col   	varchar2(100);

--l_where_column varchar2(100) := 'INITCAP('||p_where_column||')';

l_where_column varchar2(100) := p_where_column;

l_op_br		varchar2(10);

l_cl_br		varchar2(10);



--l_union 		varchar2(10) := ' UNION ';

l_minus		varchar2(10) := ' MINUS ';



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : get_chan_attr_stmt' );

	-- build sql statement for channels

	-- select construct

	l_select := ' SELECT a.channel_id, a.channel_id, 50 ';

	l_from   := ' FROM	'|| p_table_name ||' a ';

	l_from   := l_from || ' ,   amv_c_channels_vl  b ';

	IF p_include_chns = FND_API.G_TRUE THEN

	 l_from   := l_from || ' ,	amv_temp_numbers id ';

	END IF;

     l_where  := ' WHERE	a.channel_id = b.channel_id';

	l_where  := l_where || ' AND b.application_id = ' || p_application_id;

	l_where  := l_where || ' AND b.effective_start_date <= sysdate';

	l_where  := l_where || ' and nvl(b.expiration_date, sysdate) >= sysdate';

	IF p_days >= 0 THEN

	 l_where  := l_where || ' and a.last_update_date >= (sysdate - ' || p_days || ' )';

	END IF;

	IF p_include_chns = FND_API.G_TRUE THEN

	 l_where  := l_where || ' AND b.channel_id = id.number_value ';

	END IF;



	if p_optional_array.count > 0  or p_required_array.count > 0 then

	  x_sql_statement(p_index) := l_select;

	  p_index := p_index + 1;

	  x_sql_statement(p_index) := l_from;

	  p_index := p_index + 1;

	  x_sql_statement(p_index) := l_where;

	  p_index := p_index + 1;

	end if;



	l_where_clause := ' AND ';



	-- where clause for required words

	if p_required_array.count > 0 then

	  for i in 1..p_required_array.count LOOP

		l_required := l_where_clause || l_where_column ||

					' LIKE INITCAP('''||p_required_array(i)||'%'||''')';



		x_sql_statement(p_index) := l_required;

		p_index := p_index + 1;



	  end loop;

	end if;



	-- where clause for optional words

	if p_optional_array.count > 0 then

	  for i in 1..p_optional_array.count LOOP

		 if i=1 then

			l_op_br := '(';

		 end if;

		 if i=p_optional_array.count then

			l_cl_br := ')';

		 end if;



		l_optional :=  l_where_clause  || l_op_br || l_where_column ||

			' LIKE INITCAP('''||p_optional_array(i)||'%'||''')'|| l_cl_br;



		l_where_clause := ' OR ';

		l_op_br := null;

		l_cl_br := null;



		x_sql_statement(p_index) := l_optional;

		p_index := p_index + 1;

	  end loop;

	end if;



	if p_optional_array.count > 0  or p_required_array.count > 0 then

	  	if p_excluded_array.count > 0 then

			x_sql_statement(p_index) := l_minus;

	  		p_index := p_index + 1;

	  	end if;

     else

		if p_excluded_array.count > 0 then

	  		x_sql_statement(p_index) := l_select;

	  		p_index := p_index + 1;

	  		x_sql_statement(p_index) := l_from;

	  		p_index := p_index + 1;

	  		x_sql_statement(p_index) := l_where;

	  		p_index := p_index + 1;



			x_sql_statement(p_index) := l_minus;

	  		p_index := p_index + 1;

		end if;

	end if;



	-- where clause for excluded words

	if p_excluded_array.count > 0 then

	  x_sql_statement(p_index) := l_select;

	  p_index := p_index + 1;

	  x_sql_statement(p_index) := l_from;

	  p_index := p_index + 1;

	  x_sql_statement(p_index) := l_where;

	  p_index := p_index + 1;



	  l_where_clause := ' AND ';

	  for i in 1..p_excluded_array.count LOOP

		if i=1 then

			l_op_br := '(';

		end if;

		if i=p_excluded_array.count then

			l_cl_br := ')';

		end if;



		l_excluded := l_where_clause || l_op_br || l_where_column ||

				' LIKE INITCAP('''||p_excluded_array(i)||'%'||''')'|| l_cl_br;

		l_where_clause := ' OR ';

		l_op_br := null;

		l_cl_br := null;



		x_sql_statement(p_index) := l_excluded;

		p_index := p_index + 1;



	  end loop;

	end if;

--DBMS_OUTPUT.PUT_LINE('Exit : get_chan_attr_stmt' );

EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

--DBMS_OUTPUT.PUT_LINE('Others : get_chan_attr_stmt' );

        --RAISE;

END get_chan_attr_stmt;

--------------------------------------------------------------------------------

PROCEDURE get_item_attr_stmt(

	p_table_name		IN  VARCHAR2,

   	p_where_column		IN  VARCHAR2,

	p_application_id	IN  NUMBER   := FND_API.G_MISS_NUM,

	p_days			IN  NUMBER,

	p_external_contents	IN  VARCHAR2 := FND_API.G_FALSE,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_search_level		IN  VARCHAR2,

   	p_optional_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_required_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_excluded_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S)

IS

l_where_clause varchar2(10);

l_select		varchar2(100);

l_from		varchar2(400);

l_where 		varchar2(1000);

l_where1 		varchar2(1000);

l_optional	varchar2(1000);

l_required	varchar2(1000);

l_excluded	varchar2(1000);

l_join_col   	varchar2(100);

--l_where_column varchar2(100) := 'INITCAP('||p_where_column||')';

l_where_column varchar2(100) := p_where_column;

l_op_br		varchar2(10);

l_cl_br		varchar2(10);



--l_union 		varchar2(10) := ' UNION ';

l_minus		varchar2(10) := ' MINUS ';

--Following are variable declaration used by new code
l_mainSelect		varchar2(100);
l_mainFrom		varchar2(400);
l_mainWhere 		varchar2(1000);

l_subSelect		varchar2(100);
l_subFrom		varchar2(400);
l_subWhere 		varchar2(1000);

x_sqlSubSql	DBMS_SQL.VARCHAR2S;
sqlSubSql_index		PLS_INTEGER := 0;

-- End Following are variable declaration used by new code

BEGIN



--DBMS_OUTPUT.PUT_LINE('Enter : get_item_attr_stmt' );

	-- build attribute tables sql statement for items

	-- select construct

	--l_select := ' SELECT a.item_id ';

	l_subSelect := ' SELECT b.item_id ';


	--ss
	l_mainSelect := ' SELECT cim.item_id ';

	--ss


	IF p_search_level = G_CHANNEL THEN

	 --l_select := l_select || ', cim.channel_id';

		--ss
		l_mainSelect := l_mainSelect||' , cim.channel_id ';

		--ss
	ELSIF p_search_level = G_CATEGORY THEN

	 --l_select := l_select || ', cim.channel_category_id';

		--ss
		l_mainSelect := l_mainSelect||', cim.channel_category_id';

		--ss
	ELSE

	 --l_select := l_select || ', a.item_id';

		--ss
		l_mainSelect := l_mainSelect||', cim.item_id';

		--ss
	END IF;





		--l_select := l_select || ', 50 ';

		--ss
		l_mainSelect := l_mainSelect||', 50 ';
		--ss

		--Commented for new SQL
--	l_from   := ' FROM	'|| p_table_name ||' a ' ||

--			  ' ,     jtf_amv_items_vl b ';


	--ss

	l_subFrom   := ' FROM	'|| p_table_name ||' a ' ||

			  ' ,     jtf_amv_items_b b ';

	--ss
	IF p_include_chns = FND_API.G_TRUE THEN

	 --Commented for new SQL
	 --l_from   := l_from || ' ,	amv_c_chl_item_match cim ';

	 --l_from   := l_from || ' ,	amv_temp_numbers id ';


		--ss

		l_mainFrom   := ' FROM	amv_c_chl_item_match cim ';

		l_mainFrom   := l_mainFrom || ' ,	amv_temp_numbers id ';
		--ss

	END IF;


	 --Commented for new SQL
       --l_where  := ' WHERE	a.item_id = b.item_id' ||

	   	--' AND nvl(b.effective_start_date,sysdate)<=sysdate+1' ||

		--' AND nvl(b.expiration_date, sysdate) >= sysdate';

	 --End Commented for new SQL


		--ss

       l_subWhere  := ' WHERE	a.item_id = b.item_id' ||

	   	' AND nvl(b.effective_start_date,sysdate)<=sysdate+1' ||

		' AND nvl(b.expiration_date, sysdate) >= sysdate';

		--ss
	IF p_days >= 0 THEN

		--commented for new sql
	 --l_where  := l_where || ' AND a.last_update_date >= (sysdate - ' || p_days || ' )';


	 --ss
	 	 l_subWhere  := l_subWhere || ' AND a.last_update_date >= (sysdate - ' || p_days || ' )';

	 --ss
 	END IF;




	IF p_application_id <> FND_API.G_MISS_NUM THEN

		--commented for new sql code
		--l_where  := l_where || ' AND b.application_id = ' || p_application_id;


	 --ss
	 	 l_subWhere  := l_subWhere || ' AND b.application_id = ' || p_application_id;

	 --ss
	END IF;



	IF p_external_contents <> FND_API.G_FALSE THEN

	 ----commented for new sql code
	 --l_where  := l_where || ' AND b.external_access_flag = ''' ||

		--							p_external_contents ||'''';

	 --ss

	 l_subWhere  := l_subWhere || ' AND b.external_access_flag = ''' ||

									p_external_contents ||'''';

	 --ss
	END IF;



	IF p_include_chns = FND_API.G_TRUE THEN

		--commented for new sql code
	  --l_where1  := l_where1 || ' AND b.item_id = cim.item_id ';

	 --ss
	 l_subWhere  := l_subWhere || ' AND b.item_id = cim.item_id ';

	 --ss
	 IF p_search_level = G_CHANNEL THEN

		--commented for new sql code
	  --l_where1 := l_where1 || ' AND cim.channel_id = id.number_value ';


		--ss
		l_mainWhere := l_mainWhere || ' where cim.channel_id = id.number_value ';

		--ss
	 ELSIF p_search_level = G_CATEGORY THEN

		--commented for new sql code
	  --l_where1 := l_where1|| ' AND cim.channel_category_id = id.number_value ';

	  --l_where1 := l_where1|| ' AND cim.channel_id is null ';


		--ss
		l_mainWhere := l_mainWhere || ' where cim.channel_category_id = id.number_value ';

	  l_mainWhere := l_mainWhere || ' AND cim.channel_id is null ';

		--ss
	 END IF;



	 --commented for new sql code
	 --l_where1 := l_where1	|| ' AND cim.approval_status_type = '''||

		--G_APPROVED ||'''' || ' AND cim.table_name_code = '''||

		--AMV_UTILITY_PVT.G_TABLE_NAME_CODE ||'''' ||

		--' AND cim.available_for_channel_date <= sysdate ';


	--ss

	 l_mainWhere := l_mainWhere	|| ' AND cim.approval_status_type = '''||

		G_APPROVED ||'''' || ' AND cim.table_name_code = '''||

		AMV_UTILITY_PVT.G_TABLE_NAME_CODE ||'''' ||

		' AND cim.available_for_channel_date <= sysdate ';

	--ss
	END IF;



	if p_optional_array.count > 0  or p_required_array.count > 0 then

		--commented for new sql code
	  --x_sql_statement(p_index) := l_select;		-- 2

	  --p_index := p_index + 1;

	  --x_sql_statement(p_index) := l_from;		-- 3

	  --p_index := p_index + 1;

	  --x_sql_statement(p_index) := l_where;		-- 4

	  --p_index := p_index + 1;


		--ss
	  x_sqlSubSql(sqlSubSql_index) := l_subSelect;		-- 2

	  sqlSubSql_index := sqlSubSql_index + 1;

	  x_sqlSubSql(sqlSubSql_index) := l_subFrom;		-- 3

	  sqlSubSql_index := sqlSubSql_index + 1;

	  x_sqlSubSql(sqlSubSql_index) := l_subWhere;		-- 4

	  sqlSubSql_index := sqlSubSql_index + 1;

		--ss


	--DBMS_OUTPUT.PUT_LINE('l_select: ' || l_select);

	--DBMS_OUTPUT.PUT_LINE('l_from: ' || l_from);

	--DBMS_OUTPUT.PUT_LINE('l_where: ' || l_where);



	--DBMS_OUTPUT.PUT_LINE('p_index A is: ' || p_index); -- 5



		--commented for new sql code

	  --IF p_include_chns = FND_API.G_TRUE THEN

	  --x_sql_statement(p_index) := l_where1;

	  --p_index := p_index + 1;

	  --END IF;



	--DBMS_OUTPUT.PUT_LINE('p_index B is: ' || p_index);

	end if;



	l_where_clause := ' AND ';



	-- where clause for required words

	if p_required_array.count > 0 then

	  for i in 1..p_required_array.count LOOP

			l_required := l_where_clause || l_where_column ||

				' LIKE INITCAP('''||p_required_array(i)||'%'||''')';

			l_where_clause := ' AND ';



			--commented for new sql code
			--x_sql_statement(p_index) := l_required;

			--p_index := p_index + 1;


			--ss
			x_sqlSubSql(sqlSubSql_index) := l_required;
			sqlSubSql_index := sqlSubSql_index + 1;

			--ss


	  end loop;


	end if;



	--DBMS_OUTPUT.PUT_LINE('p_index C is: ' || p_index);



	-- where clause for optional words

	if p_optional_array.count > 0 then

	  for i in 1..p_optional_array.count LOOP

		if i=1 then

			 l_op_br := '(';

		end if;

		if i=p_optional_array.count then

			 l_cl_br := ')';

		end if;



		l_optional :=  l_where_clause  || l_op_br || l_where_column ||

		    ' LIKE INITCAP('''||p_optional_array(i)||'%'||''')'|| l_cl_br;



		l_where_clause := ' OR ';

		l_op_br := null;

		l_cl_br := null;



		--commented for new sql code
		--x_sql_statement(p_index) := l_optional;

	--DBMS_OUTPUT.PUT_LINE('l_optional: ' || l_optional);

		--p_index := p_index + 1;


		--ss
		x_sqlSubSql(sqlSubSql_index) := l_optional;
		sqlSubSql_index := sqlSubSql_index + 1;

		--ss

	  end loop;

	end if;





	--DBMS_OUTPUT.PUT_LINE('p_index D is: ' || p_index);



	if p_optional_array.count > 0  or p_required_array.count > 0 then

	  	if p_excluded_array.count > 0 then

				--commented for new sql code
				--x_sql_statement(p_index) := l_minus;

	  		--p_index := p_index + 1;


				--ss
				x_sqlSubSql(sqlSubSql_index) := l_minus;
				sqlSubSql_index := sqlSubSql_index + 1;

				--ss

	  	end if;



	else

		if p_excluded_array.count > 0 then

				--commented for new sql code
	  		--x_sql_statement(p_index) := l_select;

	  		--p_index := p_index + 1;

	  		--x_sql_statement(p_index) := l_from;

	  		--p_index := p_index + 1;

	  		--x_sql_statement(p_index) := l_where;

	  		--p_index := p_index + 1;


	  		--IF p_include_chns = FND_API.G_TRUE THEN

	   			--x_sql_statement(p_index) := l_where1;

	   			--p_index := p_index + 1;

	  		--END IF;



				--x_sql_statement(p_index) := l_minus;

	  		--p_index := p_index + 1;


				--ss
				x_sqlSubSql(sqlSubSql_index) := l_minus;
				sqlSubSql_index := sqlSubSql_index + 1;

				--ss
		end if;

	end if;





	--DBMS_OUTPUT.PUT_LINE('p_index E is: ' || p_index);



	-- where clause for excluded words

	if p_excluded_array.count > 0 then

		--commented for new sql code
	  --x_sql_statement(p_index) := l_select;

	  --p_index := p_index + 1;

	  --x_sql_statement(p_index) := l_from;

	  --p_index := p_index + 1;

	  --x_sql_statement(p_index) := l_where;

	  --p_index := p_index + 1;



	  l_where_clause := ' AND ';

	  for i in 1..p_excluded_array.count LOOP

		if i=1 then

			l_op_br := '(';

		end if;

		if i=p_excluded_array.count then

			l_cl_br := ')';

		end if;



		l_excluded := l_where_clause || l_op_br || l_where_column ||

				' LIKE INITCAP('''||p_excluded_array(i)||'%'||''')'|| l_cl_br;

		l_where_clause := ' OR ';

		l_op_br := null;

		l_cl_br := null;



		--commented for new sql code
		--x_sql_statement(p_index) := l_excluded;

		--p_index := p_index + 1;



		--ss
		x_sqlSubSql(sqlSubSql_index) := l_excluded;
		sqlSubSql_index := sqlSubSql_index + 1;

		--ss

		end loop;

	end if;



--DBMS_OUTPUT.PUT_LINE('get_item_attr_stmt : p_index F is: ' || p_index);

--DBMS_OUTPUT.PUT_LINE('get_item_attr_stmt : x_sql_statement.count is: ' || x_sql_statement.count);


	--new sql code, Join the main and sub sql to get the final sql

	x_sql_statement(p_index) := l_mainSelect;

	p_index := p_index + 1;

	x_sql_statement(p_index) := l_mainFrom;

	p_index := p_index + 1;

	x_sql_statement(p_index) := l_mainWhere;

	p_index := p_index + 1;


	x_sql_statement(p_index) := ' AND EXISTS (';

	p_index := p_index + 1;


	FOR pti in 0..x_sqlSubSql.count-1 LOOP
		--DBMS_OUTPUT.PUT_LINE('SUB SQL Line '||pti||'='||x_sqlSubSql(pti));
		x_sql_statement(p_index) := x_sqlSubSql(pti);

		p_index := p_index + 1;

	END LOOP;
	x_sql_statement(p_index) := ' )';

	p_index := p_index + 1;




--DBMS_OUTPUT.PUT_LINE('Exit : get_item_attr_stmt' );

EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

	--DBMS_OUTPUT.PUT_LINE('Others : get_item_attr_stmt' );

        RAISE;

END get_item_attr_stmt;


--------------------------------------------------------------------------------

PROCEDURE build_chan_name_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER,

	p_excluded_flag	IN  VARCHAR2,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

)

IS

-- Declare local variables to be used in the parsing logic

l_parsed_tbl parsed_tbl_type;

l_rec_count NUMBER;

BEGIN

    IF p_imt_string IS NOT NULL THEN

--DBMS_OUTPUT.PUT_LINE('Enter : build_chan_name_sql ');

    -- Call the Parse_IMT_String

      Parse_IMT_String

        (p_imt_string => p_imt_string

        ,x_parsed_tbl => l_parsed_tbl

        );

    END IF;



	-- content index

	x_sql_statement(p_index) := ' select b.channel_id';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ', b.channel_id, (score(1) + score(2))/2 ';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' from  amv_c_channels_vl b ';

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' ,	amv_temp_numbers id ';

	 p_index := p_index + 1;

	END IF;



	IF p_excluded_flag = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' where  ( contains( b.channel_name,';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) = 0';

	 p_index := p_index + 1;



	 x_sql_statement(p_index) := ' or  contains( b.description, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends



	 x_sql_statement(p_index) := ', 2) = 0)';

	 p_index := p_index + 1;



	ELSE

	 x_sql_statement(p_index) := ' where  ( contains( b.channel_name,';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) > 0';

	 p_index := p_index + 1;



	 x_sql_statement(p_index) := ' or  contains( b.description, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 2) > 0)';

	 p_index := p_index + 1;



	END IF;

	x_sql_statement(p_index) := ' and b.application_id = ' || p_application_id;

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' and	b.channel_id = id.number_value';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) :=

		' and b.effective_start_date <= sysdate';

	p_index := p_index + 1;

	x_sql_statement(p_index) :=

		' and nvl(b.expiration_date, sysdate) >= sysdate';

	p_index := p_index + 1;

	IF p_days >= 0 THEN

	 x_sql_statement(p_index) :=

		' and b.last_update_date >= (sysdate - ' || p_days || ' )';

	 p_index := p_index + 1;

	END IF;



--DBMS_OUTPUT.PUT_LINE('Exit : build_chan_name_sql ');



EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

        --DBMS_OUTPUT.PUT_LINE('OTHERS : build_chan_name_sql ');

        --RAISE;

END build_chan_name_sql;

--------------------------------------------------------------------------------

PROCEDURE build_items_name_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

)

IS

-- Declare local variables to be used in the parsing logic

l_parsed_tbl parsed_tbl_type;

l_rec_count NUMBER;

--Added as part of code  to fix 2719461

--start of code

CURSOR category_id_list IS

select number_value

from amv_temp_numbers;



l_category_counter number :=1;

l_category_id number;

l_category_id_list VARCHAR2(32000);

--end of code
BEGIN


	--Added as part of code  to fix 2719461

	--start of code

	OPEN category_id_list;

	LOOP

		FETCH category_id_list INTO l_category_id;



		EXIT WHEN category_id_list%NOTFOUND;



		IF l_category_counter = 1 THEN

			l_category_id_list := l_category_id;

		ELSE

			l_category_id_list := l_category_id_list ||','||l_category_id;

		END IF;



		l_category_counter := l_category_counter +1;



	END LOOP;

	CLOSE category_id_list;

	--DBMS_OUTPUT.PUT_LINE('l_category_id_list ='||l_category_id_list );

	--end of code


		IF p_imt_string IS NOT NULL THEN

--DBMS_OUTPUT.PUT_LINE('Enter : build_items_name_sql ');

    -- Call the Parse_IMT_String

      Parse_IMT_String

        (p_imt_string => p_imt_string

        ,x_parsed_tbl => l_parsed_tbl

        );

    END IF;

	-- content search

	x_sql_statement(p_index) := ' select b.item_id';

	p_index := p_index + 1;

	IF p_search_level = G_CHANNEL THEN

	 x_sql_statement(p_index) := ', cim.channel_id';

	 p_index := p_index + 1;

	ELSIF p_search_level = G_CATEGORY THEN

	 x_sql_statement(p_index) := ', cim.channel_category_id';

	 p_index := p_index + 1;

	ELSE

	 x_sql_statement(p_index) := ', b.item_id';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) := ', (score(1) + score(2))/2';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' from	jtf_amv_items_vl b ';

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' ,	amv_c_chl_item_match cim ';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) := ' ,	amv_temp_numbers id ';

	 p_index := p_index + 1;

	END IF;

	IF p_excluded_flag = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' where (contains( b.item_name, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) = 0';

     p_index := p_index + 1;



	 x_sql_statement(p_index) := ' or contains( b.description, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 2) = 0 ) ';

     p_index := p_index + 1;



	ELSE

	 x_sql_statement(p_index) := ' where (contains( b.item_name, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) > 0';

     p_index := p_index + 1;





	 x_sql_statement(p_index) := ' or contains( b.description, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 2) > 0 ) ';

     p_index := p_index + 1;



	END IF;

	IF p_application_id <> FND_API.G_MISS_NUM THEN

	 x_sql_statement(p_index) :=

		' and b.application_id = ' || p_application_id;

	 p_index := p_index + 1;

	END IF;

	IF p_external_contents <> FND_API.G_FALSE THEN

	 x_sql_statement(p_index) :=

		' and b.external_access_flag = '''|| p_external_contents ||'''';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) :=

		' and nvl(b.effective_start_date, sysdate) <= sysdate+1';

	p_index := p_index + 1;

	x_sql_statement(p_index) :=

		' and nvl(b.expiration_date, sysdate) >= sysdate';

	p_index := p_index + 1;

	IF p_days >= 0 THEN

	 x_sql_statement(p_index) :=

		' and b.last_update_date >= (sysdate - ' || p_days || ' )';

	 p_index := p_index + 1;

	END IF;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' and	b.item_id = cim.item_id';

	 p_index := p_index + 1;

	 IF p_search_level = G_CHANNEL THEN

	  --commented for bug fix 2719461

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_id = id.number_value';

	  x_sql_statement(p_index) :=

		' and	cim.channel_id in ('||l_category_id_list||') ';

	  p_index := p_index + 1;

	 ELSIF p_search_level = G_CATEGORY THEN

	  --commented for bug fix 2719461

		--x_sql_statement(p_index) :=

		--' and	cim.channel_category_id = id.number_value';

	  x_sql_statement(p_index) :=

		 ' and	cim.channel_category_id in ('||l_category_id_list||') ';

	  p_index := p_index + 1;

	  x_sql_statement(p_index) :=

		' and	cim.channel_id is null ';

	  p_index := p_index + 1;

	 END IF;

	 x_sql_statement(p_index) :=

		' and	cim.approval_status_type = '''|| G_APPROVED ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

	  	' AND cim.table_name_code = '''||

								AMV_UTILITY_PVT.G_TABLE_NAME_CODE ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

		' and	cim.available_for_channel_date <= sysdate';

	 p_index := p_index + 1;

	END IF;

--DBMS_OUTPUT.PUT_LINE('Exit : build_items_name_sql ');

EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

        --DBMS_OUTPUT.PUT_LINE('OTHERS IN : build_items_name_sql ');

        --RAISE;

END build_items_name_sql;

--------------------------------------------------------------------------------

PROCEDURE build_items_file_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

)

IS

-- Declare local variables to be used in the parsing logic

l_parsed_tbl parsed_tbl_type;

l_rec_count NUMBER;



--Added as part of code  to fix 2719461

--start of code

CURSOR category_id_list IS

select number_value

from amv_temp_numbers;



l_category_counter number :=1;

l_category_id number;

l_category_id_list VARCHAR2(32000);

--end of code

BEGIN

	--Added as part of code  to fix 2719461

	--start of code

	OPEN category_id_list;

	LOOP

		FETCH category_id_list INTO l_category_id;



		EXIT WHEN category_id_list%NOTFOUND;



		IF l_category_counter = 1 THEN

			l_category_id_list := l_category_id;

		ELSE

			l_category_id_list := l_category_id_list ||','||l_category_id;

		END IF;



		l_category_counter := l_category_counter +1;



	END LOOP;

	CLOSE category_id_list;

	--DBMS_OUTPUT.PUT_LINE('l_category_id_list ='||l_category_id_list );

	--end of code

    IF p_imt_string IS NOT NULL THEN

--DBMS_OUTPUT.PUT_LINE('Enter : build_items_file_sql ');

--DBMS_OUTPUT.PUT_LINE('p_excluded_flag : '||p_excluded_flag);

    -- Call the Parse_IMT_String

      Parse_IMT_String

        (p_imt_string => p_imt_string

        ,x_parsed_tbl => l_parsed_tbl

        );

    END IF;

	-- file items

	x_sql_statement(p_index) := ' select b.item_id';

	p_index := p_index + 1;

	IF p_search_level = G_CHANNEL THEN

	  x_sql_statement(p_index) := ', cim.channel_id';

	  p_index := p_index + 1;

	ELSIF p_search_level = G_CATEGORY THEN

	  x_sql_statement(p_index) := ', cim.channel_category_id';

	  p_index := p_index + 1;

	ELSE

	  x_sql_statement(p_index) := ', b.item_id';

	  p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) := ', score(1)';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' from	jtf_amv_items_vl b ';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' ,	jtf_amv_attachments a ';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' , 	fnd_lobs fl ';

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' ,	amv_c_chl_item_match cim ';

	 p_index := p_index + 1;



	 --commented to fix bug 2719461, this clause is added in where condition as sub query

	 --x_sql_statement(p_index) := ' ,	amv_temp_numbers id ';

	 --p_index := p_index + 1;

	END IF;

	IF p_excluded_flag = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' where contains(fl.file_data, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) = 0 ';

     p_index := p_index + 1;



	ELSE

	 x_sql_statement(p_index) := ' where contains(fl.file_data, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) > 0 ';

     p_index := p_index + 1;



	END IF;

	IF p_application_id <> FND_API.G_MISS_NUM THEN

	 x_sql_statement(p_index) :=

		' and b.application_id = ' || p_application_id;

	 p_index := p_index + 1;

	END IF;

	IF p_external_contents <> FND_API.G_FALSE THEN

	 x_sql_statement(p_index) :=

		' and b.external_access_flag = '''|| p_external_contents ||'''';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) :=

		' and nvl(b.effective_start_date, sysdate) <= sysdate+1';

	p_index := p_index + 1;

	x_sql_statement(p_index) :=

		' and nvl(b.expiration_date, sysdate) >= sysdate';

	p_index := p_index + 1;

	IF p_days >= 0 THEN

	 x_sql_statement(p_index) :=

		' and b.last_update_date >= (sysdate - ' || p_days || ' )';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) :=

		' and b.item_id = a.attachment_used_by_id ';

	p_index := p_index + 1;

	x_sql_statement(p_index) :=

		' and a.attachment_used_by = '''||'ITEM'||'''';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' and a.file_id = fl.file_id ';

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' and	b.item_id = cim.item_id';

	 p_index := p_index + 1;

	 IF p_search_level = G_CHANNEL THEN

	  --commented to fix bug 2719461, this clause is added in where condition as sub query just below

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_id = id.number_value';

		x_sql_statement(p_index) := ' and	cim.channel_id in ('||l_category_id_list||') ';

	  p_index := p_index + 1;

	 ELSIF p_search_level = G_CATEGORY THEN

	  --commented to fix bug 2719461, this clause is added in where condition as sub query just below

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_category_id = id.number_value';

		x_sql_statement(p_index) := ' and	cim.channel_category_id in ('||l_category_id_list||') ';

	  p_index := p_index + 1;

	  x_sql_statement(p_index) :=

		' and	cim.channel_id is null ';

	  p_index := p_index + 1;

	 END IF;

	 x_sql_statement(p_index) :=

		' and	cim.approval_status_type = '''|| G_APPROVED ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

	  	' AND cim.table_name_code = '''||

								AMV_UTILITY_PVT.G_TABLE_NAME_CODE ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

		' and	cim.available_for_channel_date <= sysdate';

	 p_index := p_index + 1;

	END IF;

--DBMS_OUTPUT.PUT_LINE('Exit : build_items_file_sql ');

EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

        --DBMS_OUTPUT.PUT_LINE('OTHERS IN : build_items_file_sql ');

        --RAISE;

END build_items_file_sql;

--------------------------------------------------------------------------------

PROCEDURE build_items_text_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

)

IS

-- Declare local variables to be used in the parsing logic

l_parsed_tbl parsed_tbl_type;

l_rec_count NUMBER;



--Added as part of code  to fix 2719461

--start of code

CURSOR category_id_list IS

select number_value

from amv_temp_numbers;



l_category_counter number :=1;

l_category_id number;

l_category_id_list VARCHAR2(32000);

--end of code



BEGIN

	--Added as part of code  to fix 2719461

	--start of code

	OPEN category_id_list;

	LOOP

		FETCH category_id_list INTO l_category_id;



		EXIT WHEN category_id_list%NOTFOUND;



		IF l_category_counter = 1 THEN

			l_category_id_list := l_category_id;

		ELSE

			l_category_id_list := l_category_id_list ||','||l_category_id;

		END IF;



		l_category_counter := l_category_counter +1;



	END LOOP;

	CLOSE category_id_list;

	--DBMS_OUTPUT.PUT_LINE('l_category_id_list ='||l_category_id_list );

	--end of code



		IF p_imt_string IS NOT NULL THEN

--DBMS_OUTPUT.PUT_LINE('Enter : build_items_text_sql ');

    -- Call the Parse_IMT_String

      Parse_IMT_String

        (p_imt_string => p_imt_string

        ,x_parsed_tbl => l_parsed_tbl

        );

    END IF;

	-- text items

	x_sql_statement(p_index) := ' select b.item_id';

	p_index := p_index + 1;

	IF p_search_level = G_CHANNEL THEN

	 x_sql_statement(p_index) := ', cim.channel_id';

	 p_index := p_index + 1;

	ELSIF p_search_level = G_CATEGORY THEN

	 x_sql_statement(p_index) := ', cim.channel_category_id';

	 p_index := p_index + 1;

	ELSE

	 x_sql_statement(p_index) := ', b.item_id';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) := ', score(1)';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' from	jtf_amv_items_vl b ';

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' ,	amv_c_chl_item_match cim ';

	 p_index := p_index + 1;

	 --commented 2 lines to fix 2719461, the lines are added as subquery in join condition in where clause

	 --x_sql_statement(p_index) := ' ,	amv_temp_numbers id ';

	 --p_index := p_index + 1;

	END IF;

	IF p_excluded_flag = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' where 	contains(b.text_string, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) = 0';

     p_index := p_index + 1;



	ELSE

	 x_sql_statement(p_index) := ' where 	contains(b.text_string, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) > 0';

     p_index := p_index + 1;



	END IF;

	IF p_application_id <> FND_API.G_MISS_NUM THEN

	 x_sql_statement(p_index) :=

		' and b.application_id = ' || p_application_id;

	 p_index := p_index + 1;

	END IF;

	IF p_external_contents <> FND_API.G_FALSE THEN

	 x_sql_statement(p_index) :=

		' and b.external_access_flag = '''|| p_external_contents ||'''';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) :=

		' and nvl(b.effective_start_date, sysdate) <= sysdate+1';

	p_index := p_index + 1;

	x_sql_statement(p_index) :=

		' and nvl(b.expiration_date, sysdate) >= sysdate';

	p_index := p_index + 1;

	IF p_days >= 0 THEN

	 x_sql_statement(p_index) :=

		' and b.last_update_date >= (sysdate - ' || p_days || ' )';

	 p_index := p_index + 1;

	END IF;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' and	b.item_id = cim.item_id';

	 p_index := p_index + 1;

	 IF p_search_level = G_CHANNEL THEN

		--commented to fix bug 2719461

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_id = id.number_value';

		x_sql_statement(p_index) := ' and	cim.channel_id in ( '||l_category_id_list ||') ';

	  p_index := p_index + 1;

	 ELSIF p_search_level = G_CATEGORY THEN

	  --commented to fix bug 2719461

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_category_id = id.number_value';

	  x_sql_statement(p_index) := ' and	cim.channel_category_id in ( '||l_category_id_list ||') ';

	  p_index := p_index + 1;

	  x_sql_statement(p_index) :=

		' and	cim.channel_id is null ';

	  p_index := p_index + 1;

	 END IF;

	 x_sql_statement(p_index) :=

		' and	cim.approval_status_type = '''|| G_APPROVED ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

	  	' AND cim.table_name_code = '''||

								AMV_UTILITY_PVT.G_TABLE_NAME_CODE ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

		' and	cim.available_for_channel_date <= sysdate';

	 p_index := p_index + 1;

	END IF;

--DBMS_OUTPUT.PUT_LINE('Exit : build_items_text_sql ');

EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

        --DBMS_OUTPUT.PUT_LINE('OTHERS IN : build_items_text_sql ');

        --RAISE;

END build_items_text_sql;

--------------------------------------------------------------------------------

PROCEDURE build_items_url_sql (

	p_index			IN OUT NOCOPY  PLS_INTEGER,

	p_imt_string		IN VARCHAR2,

	p_application_id	IN  NUMBER := FND_API.G_MISS_NUM,

	p_include_chns		IN  VARCHAR2 := FND_API.G_TRUE,

	p_days			IN  NUMBER,

	p_search_level		IN  VARCHAR2,

	p_excluded_flag	IN  VARCHAR2,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	x_sql_statement	IN OUT NOCOPY DBMS_SQL.VARCHAR2S

)

IS

-- Declare local variables to be used in the parsing logic

l_parsed_tbl parsed_tbl_type;

l_rec_count NUMBER;



--Added as part of code  to fix 2719461

--start of code

CURSOR category_id_list IS

select number_value

from amv_temp_numbers;



l_category_counter number :=1;

l_category_id number;

l_category_id_list VARCHAR2(32000);

--end of code



BEGIN

	--Added as part of code  to fix 2719461

	--start of code

	OPEN category_id_list;

	LOOP

		FETCH category_id_list INTO l_category_id;



		EXIT WHEN category_id_list%NOTFOUND;



		IF l_category_counter = 1 THEN

			l_category_id_list := l_category_id;

		ELSE

			l_category_id_list := l_category_id_list ||','||l_category_id;

		END IF;



		l_category_counter := l_category_counter +1;



	END LOOP;

	CLOSE category_id_list;

	--DBMS_OUTPUT.PUT_LINE('l_category_id_list ='||l_category_id_list );

	--end of code



    IF p_imt_string IS NOT NULL THEN

--DBMS_OUTPUT.PUT_LINE('Enter : build_items_url_sql ');

    -- Call the Parse_IMT_String

      Parse_IMT_String

        (p_imt_string => p_imt_string

        ,x_parsed_tbl => l_parsed_tbl

        );

    END IF;

	-- url items

	x_sql_statement(p_index) := ' select b.item_id';

	p_index := p_index + 1;

	IF p_search_level = G_CHANNEL THEN

	 x_sql_statement(p_index) := ', cim.channel_id';

	 p_index := p_index + 1;

	ELSIF p_search_level = G_CATEGORY THEN

	 x_sql_statement(p_index) := ', cim.channel_category_id';

	 p_index := p_index + 1;

	ELSE

	 x_sql_statement(p_index) := ', b.item_id';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) := ', score(1)';

	p_index := p_index + 1;

	x_sql_statement(p_index) := ' from	jtf_amv_items_vl b ';

	p_index := p_index + 1;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' ,	amv_c_chl_item_match cim ';

	 p_index := p_index + 1;

	 --commented to fix bug 2719461, this is added as subquery to where clase in the join

	 --x_sql_statement(p_index) := ' ,	amv_temp_numbers id ';

	 --p_index := p_index + 1;

	END IF;

	IF p_excluded_flag = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' where   contains(b.url_string, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) = 0 ';

     p_index := p_index + 1;



	ELSE

	 x_sql_statement(p_index) := ' where   contains(b.url_string, ';

	 p_index := p_index + 1;

     -- IMT String Parsing Logic used

     l_rec_count := 1;

     LOOP

       x_sql_statement(p_index) := ''''||l_parsed_tbl(l_rec_count).imt_string||''''||'||';

       EXIT WHEN l_rec_count = l_parsed_tbl.COUNT;

       l_rec_count := l_rec_count + 1;

       p_index := p_index + 1;

     END LOOP;



     -- Remove the concatenation operator from the last element

     x_sql_statement(p_index) := SUBSTR(x_sql_statement(p_index),1,LENGTH(x_sql_statement(p_index))-2);

     -- Increment the array index count

     p_index := p_index + 1;

     -- IMT logic ends

	 x_sql_statement(p_index) := ', 1) > 0 ';

     p_index := p_index + 1;



	END IF;

	IF p_application_id <> FND_API.G_MISS_NUM THEN

	 x_sql_statement(p_index) :=

		' and b.application_id = ' || p_application_id;

	 p_index := p_index + 1;

	END IF;

	IF p_external_contents <> FND_API.G_FALSE THEN

	 x_sql_statement(p_index) :=

		' and b.external_access_flag = '''|| p_external_contents ||'''';

	 p_index := p_index + 1;

	END IF;

	x_sql_statement(p_index) :=

		' and nvl(b.effective_start_date, sysdate) <= sysdate+1';

	p_index := p_index + 1;

	x_sql_statement(p_index) :=

		' and nvl(b.expiration_date, sysdate) >= sysdate';

	p_index := p_index + 1;

	IF p_days >= 0 THEN

	 x_sql_statement(p_index) :=

		' and b.last_update_date >= (sysdate - ' || p_days || ' )';

	 p_index := p_index + 1;

	END IF;

	IF p_include_chns = FND_API.G_TRUE THEN

	 x_sql_statement(p_index) := ' and	b.item_id = cim.item_id';

	 p_index := p_index + 1;

	 IF p_search_level = G_CHANNEL THEN

	  --commented to fix bug 2719461

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_id = id.number_value';

	  x_sql_statement(p_index) := ' and	cim.channel_id in ( '||l_category_id_list ||') ';

	  p_index := p_index + 1;

	 ELSIF p_search_level = G_CATEGORY THEN

		--commented to fix bug 2719461

	  --x_sql_statement(p_index) :=

		--' and	cim.channel_category_id = id.number_value';

		x_sql_statement(p_index) := ' and	cim.channel_category_id in ( '||l_category_id_list ||') ';

	  p_index := p_index + 1;

	  x_sql_statement(p_index) :=

		' and	cim.channel_id is null ';

	  p_index := p_index + 1;

	 END IF;

	 x_sql_statement(p_index) :=

		' and	cim.approval_status_type = '''|| G_APPROVED ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

	  	' AND cim.table_name_code = '''||

								AMV_UTILITY_PVT.G_TABLE_NAME_CODE ||'''';

	 p_index := p_index + 1;

	 x_sql_statement(p_index) :=

		' and	cim.available_for_channel_date <= sysdate';

	 p_index := p_index + 1;

	END IF;

        --DBMS_OUTPUT.PUT_LINE('Exit : build_items_url_sql ');

--DBMS_OUTPUT.PUT_LINE('Exit : build_items_url_sql ');

EXCEPTION

	WHEN OTHERS THEN

		x_sql_statement(p_index) := 'ERROR';

        --DBMS_OUTPUT.PUT_LINE('OTHERS IN : build_items_url_sql ');

        --RAISE;

END build_items_url_sql;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

PROCEDURE get_user_accessable_channels(

			p_user_id IN NUMBER,

			p_application_id IN NUMBER,

			x_channel_array OUT NOCOPY AMV_NUMBER_VARRAY_TYPE)

IS



l_record_count number := 1;

l_channel_id number;



-- get the list of public channels user has access to

CURSOR get_pub_channels IS

select b.channel_id

from   amv_c_channels_vl b

where  b.channel_type = G_CONTENT

and	  b.access_level_type = G_PUBLIC

and	  b.application_id = p_application_id

UNION ALL

select b.channel_id

from   amv_c_channels_vl b

where  b.channel_type = G_PRIVATE

and    b.owner_user_id = p_user_id

UNION ALL

select b.channel_id

from   amv_c_channels_vl b

,      amv_u_access au

,      jtf_rs_group_members_vl jgm

where  b.channel_type = G_GROUP

and    b.channel_id = au.access_to_table_record_id

and    au.access_to_table_code = G_CHANNEL

and    au.user_or_group_type = G_GROUP

and    au.user_or_group_id = jgm.group_id

and    jgm.resource_id = p_user_id;



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : get_user_accessable_channels' );

	-- return all public channels owned by application

	-- and all channels owner by user

	-- and all group channels user belongs to

	x_channel_array := amv_number_varray_type();



	OPEN get_pub_channels;

	 LOOP

		FETCH get_pub_channels INTO l_channel_id;

		EXIT WHEN get_pub_channels%NOTFOUND;

		x_channel_array.extend;

		x_channel_array(l_record_count) := l_channel_id;

		l_record_count := l_record_count + 1;

	 END LOOP;

	CLOSE get_pub_channels;

--DBMS_OUTPUT.PUT_LINE('Exit : get_user_accessable_channels' );

EXCEPTION

	WHEN OTHERS THEN

		l_record_count := 0;

--DBMS_OUTPUT.PUT_LINE('Others : get_user_accessable_channels' );

        --RAISE;

END get_user_accessable_channels;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

PROCEDURE get_app_categories(

			p_application_id IN NUMBER,

			x_category_array OUT NOCOPY AMV_NUMBER_VARRAY_TYPE)

IS

l_record_count number := 0;

l_category_id number;

l_category_name varchar2(100);



CURSOR channel_category_csr IS

select channel_category_id

,	  channel_category_name

from   amv_c_categories_vl

where	  application_id = p_application_id;

--where  channel_category_name not in ('AMV_GROUP','AMV_PRIVATE')



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : get_app_categories' );

 x_category_array := amv_number_varray_type();

 OPEN channel_category_csr;

   LOOP

 	FETCH channel_category_csr INTO l_category_id, l_category_name;

	EXIT WHEN channel_category_csr%NOTFOUND;

	 IF l_category_name not in ('AMV_GROUP', 'AMV_PRIVATE') THEN

		l_record_count := l_record_count + 1;

		x_category_array.extend;

		x_category_array(l_record_count) := l_category_id;

	 END IF;

   END LOOP;

 CLOSE channel_category_csr;

--DBMS_OUTPUT.PUT_LINE('Exit : get_app_categories' );

EXCEPTION

	WHEN OTHERS THEN

		l_record_count := 0;

--DBMS_OUTPUT.PUT_LINE('Others : get_app_categories' );

        --RAISE;

END get_app_categories;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

PROCEDURE	get_category_channel (

			p_category_id 	    IN  AMV_NUMBER_VARRAY_TYPE,

			p_application_id   IN  NUMBER,

			p_include_subcats  IN  VARCHAR2,

			x_category_array   OUT NOCOPY AMV_NUMBER_VARRAY_TYPE,

			x_channel_array    OUT NOCOPY AMV_NUMBER_VARRAY_TYPE)

IS

l_api_version      	CONSTANT NUMBER := 1.0;

l_validation_level	number := 0;

l_return_status	varchar2(1);

l_msg_count		number;

l_msg_data		varchar2(400);

l_cat_count		number := 0;

l_chn_count		number := 0;

l_categoryhr_array	amv_category_pvt.amv_cat_hierarchy_varray_type;

l_channelhr_array	amv_category_pvt.amv_cat_hierarchy_varray_type;

l_temp_id			number := 100;

l_category_id		amv_number_varray_type;

BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : get_category_channel' );

	l_category_id := amv_number_varray_type();

	x_category_array := amv_number_varray_type();

	x_channel_array := amv_number_varray_type();



	IF p_category_id.count = 0 THEN

		get_app_categories( p_application_id => p_application_id,

						x_category_array => l_category_id);

	ELSE

		l_category_id := p_category_id;

	END IF;



	FOR i in 1..l_category_id.count LOOP

	  IF AMV_UTILITY_PVT.Is_CategoryIdValid(l_category_id(i)) THEN

		IF p_include_subcats = FND_API.G_FALSE THEN

			l_cat_count := l_cat_count + 1;

			x_category_array.extend;

			x_category_array(l_cat_count) := l_category_id(i);

		ELSE

			AMV_CATEGORY_PVT.Get_CatChildrenHierarchy(

				P_API_VERSION => l_api_version,

				P_INIT_MSG_LIST => FND_API.G_FALSE,

				P_VALIDATION_LEVEL => l_validation_level,

				X_RETURN_STATUS => l_return_status,

				X_MSG_COUNT => l_msg_count,

				X_MSG_DATA => l_msg_data,

				P_CHECK_LOGIN_USER => FND_API.G_FALSE,

				P_CATEGORY_ID => l_category_id(i),

				X_CATEGORY_HIERARCHY => l_categoryhr_array );



			FOR i in 1..l_categoryhr_array.count LOOP

				l_cat_count := l_cat_count + 1;

				x_category_array.extend;

				x_category_array(l_cat_count) := l_categoryhr_array(i).id;

			END LOOP;

		END IF;



		AMV_CATEGORY_PVT.Get_ChannelsPerCategory(

				P_API_VERSION => l_api_version,

				P_INIT_MSG_LIST => FND_API.G_FALSE,

				P_VALIDATION_LEVEL => l_validation_level,

				X_RETURN_STATUS => l_return_status,

				X_MSG_COUNT => l_msg_count,

				X_MSG_DATA => l_msg_data,

				P_CHECK_LOGIN_USER => FND_API.G_FALSE,

				P_CATEGORY_ID => l_category_id(i),

				P_INCLUDE_SUBCATS => p_include_subcats,

				X_CONTENT_CHAN_ARRAY => l_channelhr_array );

		IF l_channelhr_array.count > 0 THEN

			FOR i in 1..l_channelhr_array.count LOOP

				l_chn_count := l_chn_count + 1;

				x_channel_array.extend;

				x_channel_array(l_chn_count) := l_channelhr_array(i).id;

			END LOOP;

		END IF;

	  END IF;

	END LOOP;

--DBMS_OUTPUT.PUT_LINE('Exit : get_category_channel' );

EXCEPTION

 WHEN OTHERS THEN

	l_temp_id := 0;

--DBMS_OUTPUT.PUT_LINE('Others : get_category_channel' );

    --RAISE;

END;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

PROCEDURE insert_temp_numbers(p_id_array IN  AMV_NUMBER_VARRAY_TYPE,

						x_status 	 OUT NOCOPY VARCHAR2)

IS

l_stmt varchar2(200) :='INSERT INTO amv_temp_numbers (number_value) VALUES (:id)';

-- Added for Schmema swap changes
 l_status           varchar2(30);
 l_schema           varchar2(30);
 l_industry         varchar2(30);
 l_return_status    boolean;

BEGIN

	l_return_status := FND_INSTALLATION.get_app_info('AMV',l_status,l_industry,l_schema);
	--DBMS_OUTPUT.PUT_LINE('Enter : insert_temp_numbers' );

   	-- delete channels from temp table

	--TRUNCATE also empties the session entries into amv_temp_ids

	--Since temp tables are empty at beginning of session, then

	-- amv_temp_ids must also be empty after TRUNCATE

		l_return_status := FND_INSTALLATION.get_app_info('AMV',l_status,l_industry,l_schema);
   	--EXECUTE IMMEDIATE 'TRUNCATE TABLE amv.amv_temp_numbers';

   	EXECUTE IMMEDIATE 'TRUNCATE TABLE amv_temp_numbers';



  	-- build ids insert statement

 	FOR i in 1..p_id_array.count LOOP

--DBMS_OUTPUT.PUT_LINE('insert into amv_temp_numbers (number_value) values (' || p_id_array(i) ||');');

	  EXECUTE IMMEDIATE l_stmt USING p_id_array(i);

	END LOOP;



	x_status := FND_API.G_TRUE;

	--

--DBMS_OUTPUT.PUT_LINE('Exit : insert_temp_numbers' );

EXCEPTION

  WHEN OTHERS THEN

	x_status := FND_API.G_FALSE;

--DBMS_OUTPUT.PUT_LINE('Others : insert_temp_numbers' );

    --RAISE;

END insert_temp_numbers;

--

--------------------------------------------------------------------------------

PROCEDURE insert_temp_ids(p_stmt	  	IN OUT NOCOPY  DBMS_SQL.VARCHAR2S,

					 p_start_index IN  PLS_INTEGER,

					 p_end_index	IN  PLS_INTEGER,

					 x_status    OUT NOCOPY VARCHAR2)

IS

l_ins_stmt varchar2(100) := 'INSERT INTO amv_temp_ids (id,number_value,score) ';

l_rows_processed 	PLS_INTEGER;

l_cursor_id     	PLS_INTEGER;



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : insert_temp_ids' );





--DBMS_OUTPUT.PUT_LINE('start index:' || p_start_index || 'end index: ' ||

--			p_end_index);

/*

FOR i IN p_start_index..(p_end_index-1) LOOP

  DBMS_OUTPUT.PUT_LINE(p_stmt(i));

END LOOP;

DBMS_OUTPUT.PUT_LINE('-------------------------');

*/







     -- clear the temporary global table

     --This is commented OUT NOCOPY because truncation empties all

     -- temporary table for session, including amv_temp_numbers

     -- which causes search result to be empty.

     --EXECUTE IMMEDIATE 'TRUNCATE TABLE amv.amv_temp_ids';



	p_stmt(p_start_index - 1) := l_ins_stmt;



    	-- prepare a cursor for getting the results

     	l_cursor_id := DBMS_SQL.OPEN_CURSOR;



	-- parse dbms sql

	DBMS_SQL.PARSE(	l_cursor_id,      -- Cursor identifier

		 	p_stmt,           -- SQL statement in VARCHAR2S table

		   	p_start_index-1,  -- Index to first row of statement

			p_end_index-1,    -- Index to last row of statement

		  	TRUE,             -- Insert linefeed for each row

	    		DBMS_SQL.NATIVE);



	-- execute dbms_sql

	l_rows_processed := DBMS_SQL.EXECUTE(l_cursor_id);

	--DBMS_OUTPUT.PUT_LINE('# Rows Executed:' || l_rows_processed);



	-- close cursor

	DBMS_SQL.CLOSE_CURSOR(l_cursor_id);



	x_status := FND_API.G_TRUE;

--DBMS_OUTPUT.PUT_LINE('Exit : insert_temp_ids' );

EXCEPTION



  WHEN OTHERS THEN

	x_status := FND_API.G_FALSE;

	--DBMS_OUTPUT.PUT_LINE('Others : insert_temp_ids' );

	--DBMS_OUTPUT.PUT_LINE('Exception : insert_temp_ids' );

	--DBMS_OUTPUT.PUT_LINE('ERROR IN Here - '||SQLCODE||':'||SQLERRM );

    RAISE;

END insert_temp_ids;

--

--------------------------------------------------------------------------------

PROCEDURE populate_channel_results (

	p_results_requested IN  NUMBER,

	x_start_with 		IN OUT NOCOPY NUMBER,

	x_results_array  	IN OUT NOCOPY AMV_SEARCHRES_VARRAY_TYPE,

	x_results_populated IN OUT NOCOPY NUMBER,

	x_total_results	IN OUT NOCOPY NUMBER)

IS

l_total_count		number := 1;

l_channel_id		number;

l_last_update_date	date;

l_channel_name 	varchar2(80);

l_description		varchar2(2000);

l_score			number;

l_null			varchar2(1) := null;

l_temp_total		number := 0;

l_start_with		number;



l_id				number;

l_name			varchar2(80);



CURSOR channels_csr IS

select 	chn.channel_id

,		chn.last_update_date

,		chn.channel_name

,		chn.description

,		tmp.number_value

,		max(tmp.score)

from		amv_c_channels_vl chn

,		amv_temp_ids tmp

where	chn.channel_id = tmp.id

group by chn.channel_id, chn.last_update_date, chn.channel_name, chn.description, tmp.number_value

order by max(tmp.score) desc;



CURSOR channel_count_csr IS

select sum(count(distinct id))

from	  amv_temp_ids

group by number_value;



CURSOR category_chn_csr IS

select channel_category_id

,	  channel_name

from	  amv_c_channels_vl

where  channel_id = l_id;



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : populate_channel_results' );

   OPEN channel_count_csr;

	  	FETCH channel_count_csr INTO l_temp_total;

		x_total_results := x_total_results + nvl(l_temp_total,0);

   CLOSE channel_count_csr;



   l_start_with := x_start_with;

   IF x_start_with <= x_total_results THEN

	  OPEN channels_csr;

	   LOOP

	  	FETCH channels_csr INTO 	l_channel_id,

							l_last_update_date,

							l_channel_name,

							l_description,

							l_id,

							l_score;

	     EXIT WHEN channels_csr%NOTFOUND;

		IF (	x_start_with <= l_total_count AND

		 	x_results_populated < p_results_requested)

		THEN

			OPEN category_chn_csr;

				FETCH category_chn_csr INTO l_id, l_name;

			CLOSE category_chn_csr;

			x_results_populated := x_results_populated + 1;

			x_results_array.extend;

			x_results_array(x_results_populated).title := l_channel_name;

			x_results_array(x_results_populated).url_string :=

			                    'amvnvctd.jsp?chnid='||l_channel_id;

			x_results_array(x_results_populated).description :=

			                    l_description;

			x_results_array(x_results_populated).score :=l_score;

			x_results_array(x_results_populated).area_id := l_channel_id;

			x_results_array(x_results_populated).area_code := G_CHANNEL;

			x_results_array(x_results_populated).user1 :=

			                    to_char(l_last_update_date, 'DD-MON-YYYY');

			x_results_array(x_results_populated).user2 := l_id;

			x_results_array(x_results_populated).user3 := G_CATEGORY;

			/*

			x_results_array(x_results_populated) :=

					amv_searchres_obj_type(

						l_channel_name,

						'amvnvctd.jsp?chnid='||l_channel_id,

						l_description,

						l_score,

						l_channel_id,

						G_CHANNEL,

						to_char(l_last_update_date, 'DD-MON-YYYY'),

						l_id,

						G_CATEGORY);

			*/

		END IF;

		IF (x_results_populated >= p_results_requested) THEN

			exit;

		END IF;

		l_total_count := l_total_count + 1;

	   END LOOP;

	  CLOSE channels_csr;

	  -- reset the start index to 1 for next loops

	  x_start_with := 1;

   ELSE

	-- decrement the start index with the number of results skipped

	x_start_with := l_start_with - x_total_results;

   END IF;

--DBMS_OUTPUT.PUT_LINE('Exit : populate_channel_results' );

EXCEPTION

 WHEN OTHERS THEN

	 l_temp_total := 0;

--DBMS_OUTPUT.PUT_LINE('Others : populate_channel_results' );

     --RAISE;

END populate_channel_results;

--------------------------------------------------------------------------------

PROCEDURE populate_item_results (

	p_search_level		IN VARCHAR2,

	p_results_requested IN NUMBER,

	x_start_with 		IN OUT NOCOPY NUMBER,

	x_results_array  	IN OUT NOCOPY AMV_SEARCHRES_VARRAY_TYPE,

	x_results_populated IN OUT NOCOPY NUMBER,

	x_total_results	IN OUT NOCOPY NUMBER)

IS

l_total_count		number := 1;

l_item_id			number;

l_last_update_date	date;

l_item_name 		varchar2(240);

l_description		varchar2(2000);

l_score			number;

l_temp_total		number := 0;

l_null			varchar2(1) := null;

l_start_with		number;



l_id			number;

l_name		varchar2(80);



--select 	itm.item_id



CURSOR items_csr IS

select itm.item_id,	 itm.last_update_date,	 itm.item_name,

	itm.description,	 max(tmp.score)

from	 jtf_amv_items_vl itm,	 amv_temp_ids tmp

where itm.item_id = tmp.id

group by itm.item_id, itm.last_update_date, itm.item_name, itm.description

order by max(tmp.score) desc;



CURSOR item_count_csr IS

select sum(count(distinct id))

from	  amv_temp_ids

group by id;



CURSOR item_cat_csr IS

select number_value

,	  max(score)

from	  amv_temp_ids tmp

where id = l_item_id

group by number_value;



CURSOR category_cat_csr IS

select channel_category_id

,	  channel_category_name

from	  amv_c_categories_vl

where  channel_category_id = l_id;



CURSOR category_chn_csr IS

select channel_id

,	  channel_name

from	  amv_c_channels_vl

where  channel_id = l_id;





l_count number;



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : populate_item_results' );



select count(*) into l_count from amv_temp_ids;

--DBMS_OUTPUT.PUT_LINE('count is: ' || l_count);



   OPEN item_count_csr;

	  	FETCH item_count_csr INTO l_temp_total;

		x_total_results := x_total_results + nvl(l_temp_total,0);

   CLOSE item_count_csr;



--DBMS_OUTPUT.PUT_LINE('position A');



   l_start_with := x_start_with;

   IF x_start_with <= x_total_results THEN

	--DBMS_OUTPUT.PUT_LINE('position B');

	  OPEN items_csr;

	   LOOP

	  	FETCH items_csr INTO 	l_item_id,

							l_last_update_date,

							l_item_name,

							l_description,

							l_score;

		OPEN item_cat_csr;

			FETCH item_cat_csr INTO l_id, l_score;

		CLOSE item_cat_csr;



	     EXIT WHEN items_csr%NOTFOUND;

	--DBMS_OUTPUT.PUT_LINE('position C');

		IF (	x_start_with <= l_total_count AND

		 	x_results_populated < p_results_requested)

		THEN

			IF p_search_level = G_CHANNEL THEN

			  OPEN category_chn_csr;

			  	FETCH category_chn_csr INTO l_id, l_name;

			  CLOSE category_chn_csr;

			ELSIF p_search_level = G_CATEGORY THEN

			  OPEN category_cat_csr;

			  	FETCH category_cat_csr INTO l_id, l_name;

			  CLOSE category_cat_csr;

			END IF;

			x_results_populated := x_results_populated + 1;

			x_results_array.extend;

			x_results_array(x_results_populated).title := l_item_name;

			x_results_array(x_results_populated).url_string :=

			                    'amvnvitm.jsp?itemid='||l_item_id;

			x_results_array(x_results_populated).description :=

			                    l_description;

			x_results_array(x_results_populated).score :=l_score;

			x_results_array(x_results_populated).area_id := l_item_id;

			x_results_array(x_results_populated).area_code := G_ITEM;

			x_results_array(x_results_populated).user1 :=

			                    to_char(l_last_update_date, 'DD-MON-YYYY');

			x_results_array(x_results_populated).user2 := l_id;

			x_results_array(x_results_populated).user3 := p_search_level;

			/*

			x_results_array(x_results_populated) :=

					amv_searchres_obj_type(

							l_item_name,

							'amvnvitm.jsp?itemid='||l_item_id,

							l_description,

							l_score,

							l_item_id,

							G_ITEM,

							to_char(l_last_update_date,'DD-MON-YYYY'),

							l_id,

							p_search_level);

			*/

		END IF;

		IF (x_results_populated >= p_results_requested) THEN

			exit;

		END IF;

		l_total_count := l_total_count + 1;

	   END LOOP;

	  CLOSE items_csr;

	  -- reset the start index to 1 for next loops

	  x_start_with := 1;

   ELSE

	-- decrement the start index with the number of results skipped

	x_start_with := l_start_with - x_total_results;

   END IF;

--DBMS_OUTPUT.PUT_LINE('Exit : populate_item_results' );

EXCEPTION

  WHEN OTHERS THEN

--DBMS_OUTPUT.PUT_LINE('Others : populate_item_results' );

    RAISE;



END populate_item_results;

--------------------------------------------------------------------------------

PROCEDURE  build_channel_stmt (

	p_content_array	IN AMV_CHAR_VARRAY_TYPE,

	p_imt_string		IN VARCHAR2,

	p_optional_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_required_array  	IN AMV_CHAR_VARRAY_TYPE,

	p_excluded_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_keywords_search	IN VARCHAR2 := FND_API.G_TRUE,

	p_excluded_flag	IN VARCHAR2 := FND_API.G_FALSE,

	p_application_id 	IN NUMBER,

	p_days		 	IN NUMBER,

	p_include_chns  	IN VARCHAR2 := FND_API.G_TRUE,

	p_search_level  	IN VARCHAR2 := G_CHANNEL,

	p_external_contents IN VARCHAR2 := FND_API.G_FALSE,

	p_index		  	IN OUT NOCOPY PLS_INTEGER,

	x_chan_sql_stmt   OUT NOCOPY DBMS_SQL.VARCHAR2S,

	x_chan_sql_status OUT NOCOPY VARCHAR2)

IS



--l_index	pls_integer;

l_search_level varchar2(30);

l_chan_insert_status varchar2(1);





l_start_index		PLS_INTEGER := 2;



BEGIN



--DBMS_OUTPUT.PUT_LINE('Enter : build_channel_stmt' );

     IF p_include_chns = FND_API.G_FALSE THEN

		l_search_level := FND_API.G_MISS_CHAR;

	ELSE

		l_search_level := p_search_level;

	END IF;



	--DBMS_OUTPUT.PUT_LINE('p_index is: ' || p_index);



	--******LOOP starts here

	FOR i in 1..p_content_array.count LOOP





		-- reset p_index since we are inserting right after each

		-- sub-statement construction

		-- initial input 'p_index' should be '2' as well

		p_index := l_start_index;



		IF p_content_array(i) = G_AUTHOR THEN

		  IF p_keywords_search = FND_API.G_TRUE THEN

			--l_index := p_index;

			get_chan_attr_stmt(

				p_table_name => 'amv_c_authors',

				p_where_column => 'author',

				p_application_id	=>  p_application_id,

				p_days 		  => p_days,

				p_include_chns	  => p_include_chns,

				p_optional_array => p_optional_array,

				p_required_array => p_required_array,

				p_excluded_array => p_excluded_array,

				p_index => p_index,

				x_sql_statement => x_chan_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Channel A -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_chan_sql_stmt.count);



			IF l_start_index <> p_index then

				insert_temp_ids(p_stmt 	=> x_chan_sql_stmt,

			 		p_start_index 	=> l_start_index,

					p_end_index	=> p_index,

					x_status   	=> l_chan_insert_status);

				x_chan_sql_stmt.delete;

				p_index := l_start_index;



			END IF;

	         END IF;

		ELSIF p_content_array(i) = G_KEYWORD THEN

		  -- build sql statement for keywords

		  IF p_keywords_search = FND_API.G_TRUE THEN

			--l_index := p_index;

			get_chan_attr_stmt(

				p_table_name => 'amv_c_keywords',

				p_where_column => 'keyword',

				p_application_id	=>  p_application_id,

				p_days 		  => p_days,

				p_include_chns	  => p_include_chns,

				p_optional_array => p_optional_array,

				p_required_array => p_required_array,

				p_excluded_array => p_excluded_array,

				p_index => p_index,

				x_sql_statement => x_chan_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Channel B -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_chan_sql_stmt.count);



			IF l_start_index <> p_index then

				insert_temp_ids(p_stmt 	=> x_chan_sql_stmt,

			 		p_start_index 	=> l_start_index,

					p_end_index	=> p_index,

					x_status   	=> l_chan_insert_status);

				x_chan_sql_stmt.delete;

				p_index := l_start_index;

			END IF;

	          END IF;

		ELSIF p_content_array(i) = G_TITLE_DESC THEN

			-- title search

			build_chan_name_sql(

				p_index => p_index,

				p_imt_string => p_imt_string,

				p_application_id => p_application_id,

				p_excluded_flag => p_excluded_flag,

				p_include_chns => p_include_chns,

				p_days => p_days,

				x_sql_statement => x_chan_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Channel C -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_chan_sql_stmt.count);

			insert_temp_ids(p_stmt 	=> x_chan_sql_stmt,

			 		p_start_index 	=> l_start_index,

					p_end_index	=> p_index,

					x_status   	=> l_chan_insert_status);

				x_chan_sql_stmt.delete;

				p_index := l_start_index;



		END IF;



	END LOOP;





	x_chan_sql_status := FND_API.G_TRUE;

--DBMS_OUTPUT.PUT_LINE('Exit : build_channel_stmt' );

EXCEPTION

  WHEN OTHERS THEN

	x_chan_sql_status := FND_API.G_FALSE;

--DBMS_OUTPUT.PUT_LINE('Others : build_channel_stmt' );

    --RAISE;

END build_channel_stmt;

--------------------------------------------------------------------------------

PROCEDURE  build_item_stmt (

	p_content_array	IN  AMV_CHAR_VARRAY_TYPE,

	p_optional_array 	IN  AMV_CHAR_VARRAY_TYPE,

	p_required_array  	IN  AMV_CHAR_VARRAY_TYPE,

	p_excluded_array 	IN  AMV_CHAR_VARRAY_TYPE,

	p_keywords_search	IN  VARCHAR2 := FND_API.G_TRUE,

	p_excluded_flag	IN VARCHAR2 := FND_API.G_FALSE,

	p_imt_string		IN  VARCHAR2,

	p_application_id 	IN  NUMBER := FND_API.G_MISS_NUM,

	p_days		 	IN  NUMBER,

	p_include_chns  	IN  VARCHAR2 := FND_API.G_TRUE,

	p_search_level  	IN  VARCHAR2,

	p_external_contents IN  VARCHAR2,

	p_index		  	IN  OUT NOCOPY PLS_INTEGER,

	x_item_sql_stmt   OUT NOCOPY DBMS_SQL.VARCHAR2S,

	x_item_sql_status   OUT NOCOPY VARCHAR2)

IS



--l_index	pls_integer;

l_search_level varchar2(30);



l_start_index pls_integer := 2;



l_item_insert_status varchar2(1);





BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : build_item_stmt' );

	IF p_include_chns = FND_API.G_FALSE THEN

		l_search_level := FND_API.G_MISS_CHAR;

	ELSE

		l_search_level := p_search_level;

	END IF;





	FOR i in 1..p_content_array.count LOOP





		--DBMS_OUTPUT.PUT_LINE('Reset p_index');

		x_item_sql_stmt.delete;

		p_index := l_start_index;



		IF p_content_array(i) = G_AUTHOR THEN

		  IF p_keywords_search = FND_API.G_TRUE THEN

			-- build sql statement for authors in items

			--l_index := p_index;



			get_item_attr_stmt(

				p_table_name => 'jtf_amv_item_authors',

				p_where_column => 'author',

				p_application_id	=>  p_application_id,

				p_days 		  => p_days,

				p_external_contents => FND_API.G_FALSE,

				p_include_chns	=> p_include_chns,

				p_search_level	=> l_search_level,

			  	p_optional_array => p_optional_array,

				p_required_array => p_required_array,

				p_excluded_array => p_excluded_array,

				p_index => p_index,

				x_sql_statement => x_item_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Item A -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);



			IF l_start_index <> p_index THEN

				insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 		p_start_index 	=> l_start_index,

					p_end_index	=> p_index,

					x_status   	=> l_item_insert_status);

				x_item_sql_stmt.delete;

				p_index := l_start_index;

			END IF;



			IF p_external_contents = FND_API.G_TRUE THEN

			 --l_index := p_index;

			 get_item_attr_stmt(

				p_table_name => 'jtf_amv_item_authors',

				p_where_column => 'author',

				p_application_id	=>  FND_API.G_MISS_NUM,

				p_days 		  => p_days,

				p_external_contents => p_external_contents,

				p_include_chns	=> p_include_chns,

				p_search_level	=> l_search_level,

			  	p_optional_array => p_optional_array,

				p_required_array => p_required_array,

				p_excluded_array => p_excluded_array,

				p_index => p_index,

				x_sql_statement => x_item_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Item B -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

			 IF l_start_index <> p_index THEN

				insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 		p_start_index 	=> l_start_index,

					p_end_index	=> p_index,

					x_status   	=> l_item_insert_status);

				x_item_sql_stmt.delete;

				p_index := l_start_index;

			 END IF;

			END IF;

		  END IF;

		ELSIF p_content_array(i) = G_KEYWORD THEN

		  -- build sql statement for keywords in items

		  IF p_keywords_search = FND_API.G_TRUE THEN

			--l_index := p_index;

			get_item_attr_stmt(

				p_table_name => 'jtf_amv_item_keywords',

				p_where_column => 'keyword',

				p_application_id	=>  p_application_id,

				p_days 		  => p_days,

				p_external_contents => FND_API.G_FALSE,

				p_include_chns	=> p_include_chns,

				p_search_level	=> l_search_level,

				p_optional_array => p_optional_array,

				p_required_array => p_required_array,

				p_excluded_array => p_excluded_array,

				p_index => p_index,

				x_sql_statement => x_item_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Item C -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);



			IF l_start_index <> p_index THEN

			  insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			   x_item_sql_stmt.delete;

			   p_index := l_start_index;

			END IF;



			IF p_external_contents = FND_API.G_TRUE THEN

			 --l_index := p_index;

			 get_item_attr_stmt(

				p_table_name => 'jtf_amv_item_keywords',

				p_where_column => 'keyword',

				p_application_id	=>  FND_API.G_MISS_NUM,

				p_days 		  => p_days,

				p_external_contents => p_external_contents,

				p_include_chns	=> p_include_chns,

				p_search_level	=> l_search_level,

				p_optional_array => p_optional_array,

				p_required_array => p_required_array,

				p_excluded_array => p_excluded_array,

				p_index => p_index,

				x_sql_statement => x_item_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Item D -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);



			 IF l_start_index <> p_index THEN

			  insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			   x_item_sql_stmt.delete;

			   p_index := l_start_index;

			 END IF;

			END IF;

		  END IF;

		ELSIF p_content_array(i) = G_TITLE_DESC THEN

			-- title search

			build_items_name_sql(p_index => p_index,

					p_imt_string => p_imt_string,

					p_application_id => p_application_id,

					p_include_chns	=> p_include_chns,

					p_days => p_days,

					p_search_level	=> l_search_level,

					p_excluded_flag => p_excluded_flag,

					p_external_contents => FND_API.G_FALSE,

					x_sql_statement => x_item_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Item E -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

			--sql union

   			insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			 x_item_sql_stmt.delete;

			 p_index := l_start_index;







			IF p_external_contents = FND_API.G_TRUE THEN

			 build_items_name_sql(p_index => p_index,

					p_imt_string => p_imt_string,

					p_application_id => FND_API.G_MISS_NUM,

					p_include_chns	=> p_include_chns,

					p_days => p_days,

					p_search_level	=> l_search_level,

					p_excluded_flag => p_excluded_flag,

					p_external_contents => p_external_contents,

					x_sql_statement =>x_item_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Item F -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

   			insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			 x_item_sql_stmt.delete;

			 p_index := l_start_index;

			END IF;

		ELSIF p_content_array(i) = G_CONTENT THEN

			-- file items

			IF p_imt_string <> '({%})' THEN



			 build_items_file_sql(p_index => p_index,

					  p_imt_string => p_imt_string,

					  p_application_id => p_application_id,

					  p_include_chns	=> p_include_chns,

					  p_days => p_days,

					  p_search_level	=> l_search_level,

					  p_excluded_flag => p_excluded_flag,

					  p_external_contents => FND_API.G_FALSE,

					  x_sql_statement => x_item_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Item G -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);



			 -- sql union

		         insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			 x_item_sql_stmt.delete;

			 p_index := l_start_index;





			 IF p_external_contents = FND_API.G_TRUE THEN

	 			build_items_file_sql(p_index => p_index,

					  p_imt_string => p_imt_string,

					  p_application_id => FND_API.G_MISS_NUM,

					  p_include_chns	=> p_include_chns,

					  p_days => p_days,

					  p_search_level	=> l_search_level,

					  p_excluded_flag => p_excluded_flag,

					  p_external_contents => p_external_contents,

					  x_sql_statement => x_item_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Item H -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

	  		-- sql union

	 		insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			x_item_sql_stmt.delete;

			p_index := l_start_index;





			 END IF;

			END IF;



			-- text items

			build_items_text_sql(p_index => p_index,

					  p_imt_string => p_imt_string,

					  p_application_id => p_application_id,

					  p_include_chns	=> p_include_chns,

					  p_days => p_days,

					  p_search_level	=> l_search_level,

					  p_excluded_flag => p_excluded_flag,

					  p_external_contents => FND_API.G_FALSE,

					  x_sql_statement => x_item_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Item H -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);



			-- sql union

	 		insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			x_item_sql_stmt.delete;

			p_index := l_start_index;



			IF p_external_contents = FND_API.G_TRUE THEN

	 			build_items_text_sql(p_index => p_index,

					  p_imt_string => p_imt_string,

					  p_application_id => FND_API.G_MISS_NUM,

					  p_include_chns	=> p_include_chns,

					  p_days => p_days,

					  p_search_level	=> l_search_level,

					  p_excluded_flag => p_excluded_flag,

					  p_external_contents => p_external_contents,

					  x_sql_statement => x_item_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Item I -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

	 		-- sql union

			insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			x_item_sql_stmt.delete;

			p_index := l_start_index;



			END IF;



			-- url items

			build_items_url_sql(p_index => p_index,

					 p_imt_string => p_imt_string,

					 p_application_id => p_application_id,

					 p_include_chns	=> p_include_chns,

					 p_days => p_days,

					 p_search_level	=> l_search_level,

					 p_excluded_flag => p_excluded_flag,

					 p_external_contents => FND_API.G_FALSE,

					 x_sql_statement => x_item_sql_stmt);



			--DBMS_OUTPUT.PUT_LINE('Item J -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

			-- sql union

	 		insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			x_item_sql_stmt.delete;

			p_index := l_start_index;



			IF p_external_contents = FND_API.G_TRUE THEN

	 			build_items_url_sql(p_index => p_index,

					 p_imt_string => p_imt_string,

					 p_application_id => FND_API.G_MISS_NUM,

					 p_include_chns	=> p_include_chns,

					 p_days => p_days,

					 p_search_level	=> l_search_level,

					 p_excluded_flag => p_excluded_flag,

					 p_external_contents => p_external_contents,

					 x_sql_statement => x_item_sql_stmt);





			--DBMS_OUTPUT.PUT_LINE('Item K -- p_index is: '

						--|| p_index);

			--DBMS_OUTPUT.PUT_LINE('count is : ' || x_item_sql_stmt.count);

			-- sql union

	 		insert_temp_ids(p_stmt 	=> x_item_sql_stmt,

			 	p_start_index 	=> l_start_index,

				p_end_index	=> p_index,

				x_status   	=> l_item_insert_status);

			x_item_sql_stmt.delete;

			p_index := l_start_index;





			END IF;

		END IF;



	END LOOP;





	x_item_sql_status := FND_API.G_TRUE;

--DBMS_OUTPUT.PUT_LINE('Exit : build_item_stmt' );

EXCEPTION

  WHEN OTHERS THEN

	x_item_sql_status := FND_API.G_FALSE;

--DBMS_OUTPUT.PUT_LINE('Others : build_item_stmt' );

    --RAISE;

END build_item_stmt;

--------------------------------------------------------------------------------

PROCEDURE search_items(

	p_area_array	 	IN AMV_CHAR_VARRAY_TYPE,

	p_content_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_imt_string	 	IN VARCHAR2,

	p_optional_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_required_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_excluded_array 	IN AMV_CHAR_VARRAY_TYPE,

	p_keywords_search 	IN VARCHAR2,

	p_excluded_flag 	IN VARCHAR2,

	p_application_id 	IN NUMBER,

	p_days		 	IN NUMBER,

	p_include_chns		IN VARCHAR2,

	p_search_level  	IN VARCHAR2,

	p_external_contents IN VARCHAR2,

	p_records_requested IN NUMBER,

	x_start_with		IN OUT NOCOPY NUMBER,

	x_results_populated	IN OUT NOCOPY NUMBER,

	x_total_count		IN OUT NOCOPY NUMBER,

	x_searchres_array	IN OUT NOCOPY AMV_SEARCHRES_VARRAY_TYPE )

IS

l_flag	varchar2(1);



l_chan_sql_status	varchar2(1);

l_item_sql_status	varchar2(1);

l_chan_insert_status varchar2(1);

l_item_insert_status varchar2(1);



l_chan_sql_stmt	DBMS_SQL.VARCHAR2S;

l_item_sql_stmt	DBMS_SQL.VARCHAR2S;

l_start_index		PLS_INTEGER := 2;

l_index			PLS_INTEGER := 2;



l_category_flag	varchar2(1) := FND_API.G_FALSE;

l_item_flag		varchar2(1) := FND_API.G_FALSE;

l_content_flag		varchar2(1) := FND_API.G_FALSE;



BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : search_items' );





    	FOR j in 1..p_area_array.count LOOP

     	  IF p_area_array(j) = G_CATEGORY THEN

			l_category_flag := FND_API.G_TRUE;

  	  ELSIF p_area_array(j) = G_ITEM THEN

			l_item_flag := FND_API.G_TRUE;

	  END IF;

    	END LOOP;



	-- channels/categories search

	IF l_category_flag = FND_API.G_TRUE THEN

	   -- no search on channel done at category level

	   IF p_search_level <> G_CATEGORY THEN





	  	-- build sql statement for searching categories

	  	l_index := l_start_index;

   	 	build_channel_stmt (

			p_content_array => p_content_array,

			p_imt_string	 => p_imt_string,

			p_optional_array =>p_optional_array,

			p_required_array => p_required_array,

			p_excluded_array => p_excluded_array,

			p_keywords_search => p_keywords_search,

			p_excluded_flag => p_excluded_flag,

			p_application_id => p_application_id,

			p_days		 => p_days,

			p_include_chns  => p_include_chns,

			p_search_level  => p_search_level,

			p_external_contents => p_external_contents,

			p_index		  => l_index,

			x_chan_sql_stmt  => l_chan_sql_stmt,

			x_chan_sql_status => l_chan_sql_status);



		--IF l_chan_sql_stmt.count > 0 THEN

	  	-- execute sql statement and insert into temp table

	  	--insert_temp_ids(p_stmt 	=> l_chan_sql_stmt,

			-- 	p_start_index 	=> l_start_index,

			--	p_end_index	=> l_index - 1, -- 1 for union

			--	x_status   	=> l_chan_insert_status);



	  	-- populate results cursor

	  	populate_channel_results (

					p_results_requested => p_records_requested,

					x_start_with 	=> x_start_with,

					x_results_array => x_searchres_array,

					x_results_populated => x_results_populated,

					x_total_results	=> x_total_count);

		--END IF;

	   END IF;

	END IF;



	-- Items search

	IF l_item_flag = FND_API.G_TRUE THEN

		-- build sql statement for searching items

	  	l_index := l_start_index;

   	  	build_item_stmt (

			p_content_array => p_content_array,

			p_optional_array => p_optional_array,

			p_required_array => p_required_array,

			p_excluded_array => p_excluded_array,

			p_keywords_search => p_keywords_search,

			p_excluded_flag => p_excluded_flag,

			p_imt_string	 => p_imt_string,

			p_application_id => p_application_id,

			p_days		 => p_days,

			p_include_chns  => p_include_chns,

			p_search_level  => p_search_level,

			p_external_contents => p_external_contents,

			p_index		  => l_index,

			x_item_sql_stmt  => l_item_sql_stmt,

			x_item_sql_status => l_item_sql_status);



		--IF l_item_sql_stmt.count > 0 THEN

	  	-- execute sql statement and insert into temp table

		--insert_temp_ids(p_stmt	  	=> l_item_sql_stmt,

		--	 	p_start_index 	=> l_start_index,

		--		p_end_index	=> l_index -1, -- 1 for union

		--		x_status   	=> l_item_insert_status);



	  	-- populate results cursor with items

	  	populate_item_results (

					p_search_level => p_search_level,

					p_results_requested => p_records_requested,

					x_start_with 	=> x_start_with,

					x_results_array => x_searchres_array,

					x_results_populated => x_results_populated,

					x_total_results	=> x_total_count);

		--END IF;

	END IF;

	--

--DBMS_OUTPUT.PUT_LINE('Exit : search_items' );

EXCEPTION

  WHEN OTHERS THEN

--DBMS_OUTPUT.PUT_LINE('Others : search_items' );

	l_flag := FND_API.G_TRUE;

    --RAISE;

END search_items;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

-- Start of comments

--    API name   : find_repositories

--    Type       : Group or Public

--    Pre-reqs   : Total number of repository names retrieved at a time will

--                 not need to exceed amv_utility_pub.g_max_array_size.  By

--                 not needing to exceed this limit, the parameters to

--                 control a "sliding window" of retrieved values is not

--                 needed, thus simplifying this API's signature.

--    Function   : Retrieves all repository names participating with

--                 MES Search that match the input parameters specified.

--                 Typically, only the status parameter will be set to

--                 retrieve only active Repositories.

--

--                 Marketing Encyclopedia (MES) will employ this procedure

--                 within its Search API and screens to retrieve

--                 repositories participating with MES search.

--

--

--    Parameters (Standard parameters not mentioned):

--    IN         : p_repository_id         IN NUMBER                  Optional

--                    Repository ID of the Repository to retrieve

--                    information for.  Corresponds to the column

--                    amv_d_entities_b.entity_id

--                    where amv_d_entities_b.usage_indicator = 'AMV_SEARCH'

--

--               : p_repository_code       IN VARCHAR2(255)           Optional

--                    Repository Code of the Repository to retrieve

--                    information for.  Corresponds to the column

--                    amv_d_entities_b.table_name

--                    where amv_d_entities_b.usage_indicator='AMV_SEARCH'

--

--               : p_repository_name       IN VARCHAR2(80)            Optional

--                    Description of the Repository that should appear

--                    on the Advanced Repository Area Search page.

--                    Corresponds to the column

--                    amv_d_entities_tl.entity_name.

--

--               : p_status                           IN  VARCHAR2    Optional

--                    Status condition to be queried.

--                    (ACTIVE= active, INACTIVE=inactive).

--

--               : p_object_version_number            IN  NUMBER      Optional

--                    Used as a means of detecting updates to a row.

--

--    OUT        : x_searchrep_array        OUT ARRAY_TYPE

--                    Varying Array of Object amv_searchrep_obj_type that

--                    holds the resulting search matches.

--

--                       repository_id               OUT NUMBER

--                          Repository ID that met the search criteria

--                          provided.

--

--                       repository_code             OUT VARCHAR2(255)

--                          Repository code that met the search criteria

--                          provided.

--

--                       repository_name             OUT VARCHAR2(80)

--                          Name of the Repository that met the

--                          search criteria provided.  Value will be

--                          what is displayed on the Advanced Repository Area

--                          Search page.

--

--                       status                      OUT VARCHAR2(30)

--                          Status of the record.

--

--                       object_version_number       OUT NUMBER

--                          Version number stamp of the record.

--

--    Version    : Current version     1.0

--                    {add comments here}

--                 Previous version    1.0

--                 Initial version     1.0

-- End of comments

--

PROCEDURE find_repositories

   (p_api_version             IN   NUMBER,

    p_init_msg_list           IN   VARCHAR2 := fnd_api.g_false,

    p_validation_level    	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status           OUT NOCOPY  VARCHAR2,

    x_msg_count               OUT NOCOPY  NUMBER,

    x_msg_data                OUT NOCOPY  VARCHAR2,

    p_check_login_user        IN   VARCHAR2 := FND_API.G_TRUE,

    p_object_version_number   IN   NUMBER   := FND_API.G_MISS_NUM,

    p_repository_id           IN   NUMBER   := FND_API.G_MISS_NUM,

    p_repository_code         IN   VARCHAR2 := FND_API.G_MISS_CHAR,

    p_repository_name         IN   VARCHAR2 := FND_API.G_MISS_CHAR,

    p_status                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,

    x_searchrep_array         OUT NOCOPY  amv_searchrep_varray_type)

IS

l_api_name              CONSTANT VARCHAR2(30) := 'find_repositories';

l_api_version           CONSTANT NUMBER := 1.0;

l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

--

l_resource_id           number;

l_user_id               number;

l_login_user_id         number;

l_login_user_status     varchar2(30);

l_Error_Msg             varchar2(2000);

l_Error_Token           varchar2(80);

l_application_id        number := 520;

--

l_cursor           	    CursorType;

l_sql_statement 	    varchar2(2000);

l_where_clause 	    varchar2(2000);

l_fetch_count      	    number := 0;

l_repository_id	    number;

l_repository_code 	    varchar2(30);

l_repository_name	    varchar2(80);

l_status			    varchar2(30);

l_object_version_number number;

--

BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : find_repositories' );

    -- Standard begin of API savepoint

    SAVEPOINT  Find_Repositories;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call (

       l_api_version,

       p_api_version,

       l_api_name,

       G_PKG_NAME)

    THEN

       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Debug Message

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');

       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');

       FND_MSG_PUB.Add;

    END IF;

    --Initialize message list if p_init_msg_list is TRUE.

    IF FND_API.To_Boolean (p_init_msg_list) THEN

       FND_MSG_PUB.initialize;

    END IF;

    -- Get the current (login) user id.

    AMV_UTILITY_PVT.Get_UserInfo(

			 x_resource_id => l_resource_id,

                x_user_id     => l_user_id,

                x_login_id    => l_login_user_id,

                x_user_status => l_login_user_status

                );

    -- check login user

    IF (p_check_login_user = FND_API.G_TRUE) THEN

       -- Check if user is login and has the required privilege.

       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN

          -- User is not login.

          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');

              FND_MSG_PUB.Add;

          END IF;

          RAISE  FND_API.G_EXC_ERROR;

       END IF;

    END IF;

    -- Initialize API return status to sucess

    x_return_status := FND_API.G_RET_STS_SUCCESS;



    --

    -- construct synamic sql statement based on the parameters

    l_sql_statement := 	'SELECT 	b.entity_id, ' ||

					'		b.table_name, ' ||

					'		tl.entity_name, ' ||

					'		b.status, ' ||

					'		b.object_version_number ' ||

					'FROM	amv_d_entities_b b ' ||

					',		amv_d_entities_tl tl ' ||

					'WHERE	b.usage_indicator = '''||

								G_AMV_SEARCH||'''';



    --Construct the WHERE clause

    IF (p_repository_id <> FND_API.G_MISS_NUM) THEN

     l_where_clause :=l_where_clause ||' AND b.application_id = ' || p_repository_id;

    END IF;



    IF (p_repository_code <> FND_API.G_MISS_CHAR) THEN

     l_where_clause:=l_where_clause||' AND b.table_name = ''' ||

					p_repository_code||'''';

    END IF;



    IF (p_status <> FND_API.G_MISS_CHAR) THEN

     l_where_clause := l_where_clause || ' AND b.status = ''' ||

					p_status||'''';

    END IF;



    IF (p_repository_name <> FND_API.G_MISS_CHAR) THEN

     l_where_clause:=l_where_clause||' AND tl.entity_name=''' ||

					p_repository_name||'''';

    END IF;

     l_where_clause := l_where_clause ||

					' AND tl.language = userenv(' || '''lang''' || ') ' ||

					' AND b.entity_id = tl.entity_id ';

    --

    l_sql_statement  := l_sql_statement  || l_where_clause;

    --Now execute the SQL statement:

    OPEN l_cursor FOR l_sql_statement;

		x_searchrep_array := AMV_SEARCHREP_VARRAY_TYPE();

		-- NOTE change to fetch into obj

		LOOP

		     l_fetch_count := l_fetch_count + 1;

		     x_searchrep_array.extend;

		     FETCH l_cursor INTO  x_searchrep_array(l_fetch_count);

		     EXIT WHEN l_cursor%NOTFOUND;

			/*

			FETCH l_cursor INTO

	  				l_repository_id,

					l_repository_code,

					l_repository_name,

					l_status,

					l_object_version_number;

			EXIT WHEN l_cursor%NOTFOUND;

			l_fetch_count := l_fetch_count + 1;

			x_searchrep_array.extend;

			x_searchrep_array(l_fetch_count) :=

				amv_searchrep_obj_type(

	  				l_repository_id,

					l_repository_code,

					l_repository_name,

					l_status,

					l_object_version_number);

			*/

		END LOOP;

    CLOSE l_cursor;



    /*

    -- Success message

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)

    THEN

       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');

       FND_MESSAGE.Set_Token('ROW', l_full_name);

       FND_MSG_PUB.Add;

    END IF;

    */

    -- Debug Message

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');

       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');

       FND_MSG_PUB.Add;

    END IF;

    --Standard call to get message count and if count=1, get the message

    FND_MSG_PUB.Count_And_Get (

       p_encoded => FND_API.G_FALSE,

       p_count => x_msg_count,

       p_data  => x_msg_data

       );

--DBMS_OUTPUT.PUT_LINE('Exit : find_repositories' );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO  Find_Repositories;

       x_return_status := FND_API.G_RET_STS_ERROR;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO  Find_Repositories;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

   WHEN OTHERS THEN

       ROLLBACK TO  Find_Repositories;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

        THEN

                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);

        END IF;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

--

END find_repositories;

--

--------------------------------------------------------------------------------

-- Start of comments

--    API name   : find_repository_areas

--    Type       : Group or Public

--    Pre-reqs   : Total number of repository areas retrieved at a time will

--                 not need to exceed amv_utility_pub.g_max_array_size.  By

--                 not needing to exceed this limit, the parameters to

--                 control a "sliding window" of retrieved values is not

--                 needed, thus simplifying this API's signature.

--    Function   : Retrieves all repository areas for a given repository

--                 that is participating with MES Search which matches the

--                 input parameters specified.

--                 Typically, the repository code will be provided to

--                 restrict the return to include only areas for that

--                 repository; The status parameter will usually be set to

--                 retrieve only active Repository Areas.

--

--                 Marketing Encyclopedia (MES) will employ this procedure

--                 within its Search API and screens to retrieve Repository

--                 Areas valid for an MES search with the specified Repository.

--

--    Parameters (Standard parameters not mentioned):

--    IN         : p_repository_id         IN NUMBER                  Optional

--                    Repository identifier of the Repository Code to

--                    retrieve information for.  Corresponds to the column

--                    amv_d_entities_b.entity_id

--                    where amv_d_entities_b.usage_indicator = 'AMV_SEARCH'

--

--               : p_repository_code       IN VARCHAR2(255)           Optional

--                    Repository Code of the Repository to retrieve

--                    information for.  Corresponds to the column

--                    amv_d_entities_b.table_name

--                    where amv_d_entities_b.usage_indicator = 'AMV_SEARCH'

--

--               : p_area_id               IN NUMBER                  Optional

--                    Repository Area identifier of the Repository Area to

--                    retrieve information for.  Corresponds to the column

--                    amv_d_ent_attributes_b.attribute_id

--                  where amv_d_ent_attributes_b.usage_indicator=

--					'CONTENT_AREA'

--					'SEARCH_AREA'

--					'CONDITION_CONS'

--					'WORD_CONS'

--

--               : p_area_code             IN VARCHAR2(255)           Optional

--                    Area Repository Code of the Repository to retrieve

--                    information for.  Corresponds to the column

--                    amv_d_ent_attributes_b.column_name

--

--               : p_area_name              IN VARCHAR2(80)            Optional

--                    Description of the Repository that should appear

--                    on the Advanced Repository Area Search page.

--                    Corresponds to the column

--                    amv_d_ent_attributes_tl.attribute_name.

--

--               : p_status                           IN  VARCHAR2    Optional

--                    Status condition to be queried.

--                    (ACTIVE= active, INACTIVE=inactive).

--

--               : p_object_version_number            IN  NUMBER      Optional

--                    Used as a means of detecting updates to a row.

--

--    OUT        : x_searcharea_array        OUT ARRAY_TYPE

--                    Varying Array of Object amv_searchrep_obj_type that

--                    holds the resulting search matches.

--

--                       repository_id               OUT NUMBER

--                          Repository ID that met the search criteria

--                          provided.

--

--                       repository_code             OUT VARCHAR2(255)

--                          Repository code that met the search criteria

--                          provided.

--

--                       area_id                     OUT NUMBER

--                          Area ID that met the search criteria

--                          provided.

--

--                       area_code                   OUT VARCHAR2(80)

--                          Area code that met the search criteria

--                          provided.

--

--                       area_name                   OUT VARCHAR2(80)

--                          Name of the Repository Area that met the

--                          search criteria provided.  Value will be

--                          what is displayed on the Advanced Repository Area

--                          Search page.

--

--                       status                      OUT VARCHAR2(30)

--                          Status of the record.

--

--                       object_version_number       OUT NUMBER

--                          Version number stamp of the record.

--

--    Version    : Current version     1.0

--                    {add comments here}

--                 Previous version    1.0

--                 Initial version     1.0

-- End of comments

--

PROCEDURE find_repository_areas

   (p_api_version             IN   NUMBER,

    p_init_msg_list           IN   VARCHAR2 := fnd_api.g_false,

    p_validation_level    	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status           OUT NOCOPY  VARCHAR2,

    x_msg_count               OUT NOCOPY  NUMBER,

    x_msg_data                OUT NOCOPY  VARCHAR2,

    p_check_login_user        IN   VARCHAR2 := FND_API.G_TRUE,

    p_searcharea_obj		IN 	amv_searchara_obj_type,

    x_searcharea_array        OUT NOCOPY  amv_searchara_varray_type)

IS

l_api_name              CONSTANT VARCHAR2(30) := 'find_repository_areas';

l_api_version           CONSTANT NUMBER := 1.0;

l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

--

l_resource_id           number;

l_user_id               number;

l_login_user_id         number;

l_login_user_status     varchar2(30);

l_Error_Msg             varchar2(2000);

l_Error_Token           varchar2(80);

l_application_id        number := 520;

--

l_cursor           	    CursorType;

l_sql_statement 	    varchar2(2000);

l_where_clause 	    varchar2(2000);

l_fetch_count      	    number := 0;

l_repository_id	    number;

l_repository_code 	    varchar2(30);

l_area_id	    	         number;

l_area_code	    	    varchar2(30);

l_area_name	    	    varchar2(80);

l_area_indicator	    varchar2(30);

l_status			    varchar2(30);

l_object_version_number number;



--

BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : find_repository_areas' );

    -- Standard begin of API savepoint

    SAVEPOINT  Find_RepositoryAreas;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call (

       l_api_version,

       p_api_version,

       l_api_name,

       G_PKG_NAME)

    THEN

       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Debug Message

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');

       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');

       FND_MSG_PUB.Add;

    END IF;

    --Initialize message list if p_init_msg_list is TRUE.

    IF FND_API.To_Boolean (p_init_msg_list) THEN

       FND_MSG_PUB.initialize;

    END IF;

    -- Get the current (login) user id.

    AMV_UTILITY_PVT.Get_UserInfo(

			 x_resource_id => l_resource_id,

                x_user_id     => l_user_id,

                x_login_id    => l_login_user_id,

                x_user_status => l_login_user_status

                );

    -- check login user

    IF (p_check_login_user = FND_API.G_TRUE) THEN

       -- Check if user is login and has the required privilege.

       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN

          -- User is not login.

          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');

              FND_MSG_PUB.Add;

          END IF;

          RAISE  FND_API.G_EXC_ERROR;

       END IF;

    END IF;

    -- Initialize API return status to sucess

    x_return_status := FND_API.G_RET_STS_SUCCESS;



    --

    -- construct synamic sql statement based on the parameters

    l_sql_statement := 	'SELECT eb.entity_id, ' ||

				'		eb.table_name, ' ||

				'		ab.data_type, ' ||

				'		ab.attribute_id, ' ||

				'		ab.column_name, ' ||

				'		atl.attribute_name, ' ||

				'		ab.status, ' ||

				'		ab.object_version_number ' ||

				'FROM	amv_d_entities_b eb ' ||

                   	',        amv_d_entities_tl etl ' ||

				',        amv_d_ent_attributes_b ab ' ||

				',        amv_d_ent_attributes_tl atl ' ||

				'WHERE	ab.usage_indicator = '''|| G_AMV_SEARCH ||'''';



    --Construct the WHERE clause

    IF (p_searcharea_obj.repository_id <> FND_API.G_MISS_NUM) THEN

     l_where_clause :=l_where_clause ||' AND eb.application_id = '||

						p_searcharea_obj.repository_id;

    END IF;



    IF (p_searcharea_obj.repository_code <> FND_API.G_MISS_CHAR) THEN

     l_where_clause:=l_where_clause||' AND eb.table_name = '''||

					 	p_searcharea_obj.repository_code||'''';

    END IF;



    IF (p_searcharea_obj.area_id <> FND_API.G_MISS_NUM) THEN

     l_where_clause :=l_where_clause ||' AND ab.attribute_id = '||

						p_searcharea_obj.area_id;

    END IF;



    IF (p_searcharea_obj.area_code <> FND_API.G_MISS_CHAR) THEN

     l_where_clause:=l_where_clause||' AND ab.column_name = '''||

						p_searcharea_obj.area_code||'''';

    END IF;



    IF (p_searcharea_obj.area_indicator <> FND_API.G_MISS_CHAR) THEN

     l_where_clause:=l_where_clause||' AND ab.data_type = '''||

						p_searcharea_obj.area_indicator||'''';

    END IF;



    IF (p_searcharea_obj.status <> FND_API.G_MISS_CHAR) THEN

     l_where_clause := l_where_clause || ' AND ab.status = '''||

						p_searcharea_obj.status||'''';

    END IF;



    IF (p_searcharea_obj.area_name <> FND_API.G_MISS_CHAR) THEN

     l_where_clause:=l_where_clause||' AND atl.attribute_name='''||

						p_searcharea_obj.area_name||'''';

    END IF;

     l_where_clause := l_where_clause ||

		' AND eb.entity_id = etl.entity_id ' ||

          ' AND etl.language = '''|| userenv('lang') ||''''||

		' AND eb.entity_id = ab.entity_id ' ||

		' AND ab.attribute_id = atl.attribute_id ' ||

		' AND atl.language = '''|| userenv('lang') ||''''||

		' ORDER BY ab.column_name ';

    --

    l_sql_statement  := l_sql_statement  || l_where_clause;

    --Now execute the SQL statement:

    OPEN l_cursor FOR l_sql_statement;

		x_searcharea_array := AMV_SEARCHARA_VARRAY_TYPE();

		LOOP

		     l_fetch_count := l_fetch_count + 1;

		     x_searcharea_array.extend;

		     FETCH l_cursor INTO x_searcharea_array(l_fetch_count);

		     EXIT WHEN l_cursor%NOTFOUND;

			/*

			FETCH l_cursor INTO

	  				l_repository_id,

					l_repository_code,

	  				l_area_indicator,

	  				l_area_id,

					l_area_code,

					l_area_name,

					l_status,

					l_object_version_number;

			EXIT WHEN l_cursor%NOTFOUND;

			l_fetch_count := l_fetch_count + 1;

			x_searcharea_array.extend;

			x_searcharea_array(l_fetch_count) :=

				amv_searchara_obj_type(

	  				l_repository_id,

					l_repository_code,

	  				l_area_indicator,

	  				l_area_id,

					l_area_code,

					l_area_name,

					l_status,

					l_object_version_number);

			*/

		END LOOP;

    CLOSE l_cursor;

    --



    -- Success message

    /*

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)

    THEN

       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');

       FND_MESSAGE.Set_Token('ROW', l_full_name);

       FND_MSG_PUB.Add;

    END IF;

    */

    -- Debug Message

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');

       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');

       FND_MSG_PUB.Add;

    END IF;

    --Standard call to get message count and if count=1, get the message

    FND_MSG_PUB.Count_And_Get (

       p_encoded => FND_API.G_FALSE,

       p_count => x_msg_count,

       p_data  => x_msg_data

       );

--DBMS_OUTPUT.PUT_LINE('Exit : find_repository_areas' );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO  Find_RepositoryAreas;

       x_return_status := FND_API.G_RET_STS_ERROR;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO  Find_RepositoryAreas;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

   WHEN OTHERS THEN

       ROLLBACK TO  Find_RepositoryAreas;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

        THEN

                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);

        END IF;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

--

END find_repository_areas;

--

--------------------------------------------------------------------------------

-- Start of comments

--    API name   : Content_Search

--    Type       : Group or Public

--    Pre-reqs   : None

--    Function   : Accept a search string of a standardized syntax for the

--                 searching of one or more repositories for which

--                 this repository API supports.  The API name will be

--                 registered within the tables amv_d_entities_%,

--                 amv_d_ent_attributes_tl, and amv_d_ent_attributes_b

--                 with the later table\022s column, FUNCTION_CALL set to

--                 {user-defined name of [package.]procedure} (i.e. the

--                 name of this API).

--                 As the value stored within the column FUNCTION_CALL will be

--                 concatenated along with a pre-determined procedure

--                 specification for participation in a dynamic PL/SQL call,

--                 it is imperative that this value conforms to a valid

--                 Oracle PL/SQL [package.]procedure name.

--

--                 Marketing Encyclopedia (MES) will employ this procedure

--                 within its Search API and screens to retrieve and filter

--                 another repository's data that meets the specified

--                 search criteria passed in.

--

--    Parameters (Standard parameters not mentioned):

--    IN         : p_imt_search_string    IN VARCHAR2(400)           Required

--                    Search string defining what to search in interMedia

--                    Text syntax.  The intent is for this API to accept

--                    the string as-is, and drop the string into a

--                    Dynamic SQL statement containing the iMT CONTAINS()

--                    clause for immediate execution.

--

--                    Note, this string will NOT include the iMT keyword

--                    CONTAINS along with it's parentheses, just a valid

--                    string that can be dropped as-is into the CONTAINS

--                    clause.

--

--               : p_search_param_array  IN amv_searchpar_array_type Required

--                    Array of object amv_searchpar_obj_type listing values

--                    to search against database columns that are not

--                    interMedia Text enabled.

--

--                    The attributes of the object follow:

--

--                       : operator       IN VARCHAR2(30)            Required

--

--                            Oracle operators consisting values in

--                      {=,<>IN,NOT IN,LIKE,NOT LIKE}.

--

--                       : string_value   IN VARCHAR2(400)           Required

--

--                            Value portion of the search in string form.

--

--                    The format of the two columns of this object type

--                    is such that the API will be able to concatenate

--                    these values with appropriate white space and the

--                    search source column name; This would form a

--                    syntactically valid SQL predicate for construction

--                    of a Dynamic SQL Statement.

--

--                    Example:

--

--                      col_name||\022 \021||operator||\022 \021||string_value

--

--                    The string_value will conform to the proper SQL

--                    syntax for it\022s corresponding operator. (e.g. the

--                    string_value will be enclosed in parentheses for

--                    the IN operator).  As there could be multiple

--                    string_values, this API must be able to build a

--                    Dynamic SQL statement using all cells of this array.

--

--               : p_area_array           IN amv_area_array_type Optional

--                    Array structure that lists a subset of all areas

--                    of the repository for which this API is based.  If the

--                    array is NULL (by default), then all areas are to be

--                    searched.  Areas listed within this array must, for

--                    validation purposes, be registered under the MES tables

--                    amv_d_entities_%, amv_d_ent_attributes_% and

--                    amv_d_ attrib_operators.  Valid areas will be

--                    identified in the column

--                    amv_d_ent_attributes_b.column_name.

--

--                    The main AMV Search API will only recognize areas

--                    defined within this table.  The API will also refer to

--                    the status column of this table to ignore areas

--                    where this column's value is set to "disabled".

--

--               : p_user_id              IN NUMBER                  Required

--                    Identifier from FND that declares the end-user.  This

--                    API may required the ID to filter privileged items.

--

--               : p_request_array        IN  amv_request_array_type Required

--                    Object structure that specifies and controls a sliding

--                    window to the retrieved LOV results set (i.e. restricts

--                    the subset of rows returned, and controls its starting

--                    and ending record position of the complete set of rows

--                    that could potentially be retrieved).  See package

--                    amv_utility_pub for further specifications to the

--                    object's structure.  The attributes of the object and

--                    their description follow:

--

--                       records_requested            IN NUMBER

--                         Specifies the maximum number of records to return

--                         in the varray results subset  (Defaults to

--                         (amv_utility_pub.g_amv_max_varray_size).

--

--                       start_record_position        IN NUMBER

--                         Specifies a subscript into the varray results

--                         set for the first record to be returned in the

--                         retrieval subset.  Usually used in conjunction

--                         with p_request_obj.next_record_position

--                         (Default 1 ).

--

--                       return_total_count_flag      IN VARCHAR2

--                         Flag consisting of the values {fnd_api.g_true,

--                         fnd_api.g_false} to specify whether

--                         p_request_obj.total_record_count is

--                         derived, albeit at a possible cost to resources

--                         (Default fnd_api.g_false).

--

--    OUT        : x_return_obj            OUT OBJ_TYPE

--                    Object structure that reports information about the

--                    retrieved results set defined by p_request_obj.

--                    See package amv_utility_pub for further

--                    specifications to the object's structure.

--                    Object structure of:

--

--                       returned_record_count        OUT NUMBER

--                          Indicates the total number of records returned

--                          for the retrieved subset.  This value will not

--                          exceed p_request_obj.records_requested.

--

--                       next_record_position         OUT NUMBER

--                          Indicates the subscript to the varray that is the

--                          starting point to the next subset of records in

--                          the set (base 1; that is, the first record of the

--                          set is one, NOT zero).  Will return 0 if there are

--                          no more rows.

--

--                       total_record_count           OUT NUMBER

--                          Indicates the total record count in the complete

--                          varray retrieval set only if

--                          p_request_obj.return_total_count is set

--                          to fnd_api.g_true; Otherwise undefined.

--

--               : x_searchres_array       OUT ARRAY_TYPE

--                    Varying Array of Object amv_searchres_obj_type that

--                    holds the resulting search matches.

--

--                       title                       IN VARCHAR2(80)

--                          Title of the item that met the search criteria

--                          provided.

--

--                       url_string                  IN VARCHAR2(2000)

--                          URL of the item that met the search.  If this item

--                          is a file, then it will conform to MIME types.

--                          If the item has it's body of a table column, then

--                          the URL will point to an appropriate viewer with

--                          the table column provided as a parameter into the

--                          viewer call.

--

--                       description                 IN VARCHAR2(200)

--                          Abbreviated description of the item that met the

--                          search criteria provided.

--

--                       score                       IN NUMBER

--                          Weighted score of the item that met the search.

--                          The determination of the score is derived by

--                          interMedia Text ranged 0 to 100 with 100 being

--                          the best score.  Exact matches against table

--                          columns which are not interMedia Text enabled will

--                          automatically score 100.

--

--                       area_id                     IN VARCHAR2(30)

--                          The area identifier of the area code.

--                          Corresponds to the column

--                          amv_d_ent_attributes_b.column_name where

--                          amv_d_ent_attributes_b.usage_indicator = 'ASRA'

--

--                       area_code                   IN VARCHAR2(30)

--                          The area code of the repository for which this API

--                          supports.  Valid values will be found within the

--                          column amv_d_ent_attributes_b.column_name where

--                          amv_d_ent_attributes_b.usage_indicator = 'ASRA'

--

--                       user1 - user3               IN VARCHAR2(255)

--                          Unused columns that exist for customized needs.

--

--

--    Version    : Current version     1.0

--                    {add comments here}

--                 Previous version    1.0

--                 Initial version     1.0

-- End of comments

--

PROCEDURE Content_Search

   (p_api_version         IN   NUMBER,

    p_init_msg_list       IN   VARCHAR2 := fnd_api.g_false,

    p_validation_level  	 IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY  VARCHAR2,

    x_msg_count           OUT NOCOPY  NUMBER,

    x_msg_data            OUT NOCOPY  VARCHAR2,

    p_check_login_user    IN   VARCHAR2 := FND_API.G_TRUE,

    p_application_id      IN   NUMBER,

    p_area_array          IN   amv_char_varray_type,

    p_content_array       IN   amv_char_varray_type,

    p_param_array         IN   amv_searchpar_varray_type,

    p_imt_string		 IN	 VARCHAR2 := FND_API.G_MISS_CHAR,

    p_days                IN   NUMBER := FND_API.G_MISS_NUM,

    p_user_id             IN   NUMBER := FND_API.G_MISS_NUM,

    p_category_id		 IN	 amv_number_varray_type,

    p_include_subcats	 IN	 VARCHAR2 := FND_API.G_FALSE,

    p_external_contents	 IN	 VARCHAR2 := FND_API.G_FALSE,

    p_request_obj         IN   amv_request_obj_type,

    x_return_obj          OUT NOCOPY  amv_return_obj_type,

    x_searchres_array     OUT NOCOPY  amv_searchres_varray_type)

IS

l_api_name              CONSTANT VARCHAR2(30) := 'Content_Search';

l_api_version           CONSTANT NUMBER := 1.0;

l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

--

l_resource_id           number;

l_user_id               number;

l_login_user_id         number;

l_login_user_status     varchar2(30);

l_Error_Msg             varchar2(2000);

l_Error_Token           varchar2(80);

l_object_version_number number := 1;

l_application_id        number := 520;



l_optional_array	amv_char_varray_type;

l_required_array	amv_char_varray_type;

l_excluded_array	amv_char_varray_type;

l_imt_string		varchar2(4000);

l_days			NUMBER;



l_channel_array	amv_number_varray_type;

l_category_array	amv_number_varray_type;

l_null			varchar2(1) := null;

l_rec_count		number := 0;



l_id_insert_status	 varchar2(1);

l_user_status		varchar2(1);

l_channel_search	varchar2(1) := FND_API.G_FALSE;

l_category_search	varchar2(1) := FND_API.G_FALSE;

l_search_level		varchar2(20);

l_keywords_search	varchar2(1);

l_include_chns		varchar2(1) := FND_API.G_TRUE;

l_excluded_flag	varchar2(1);

l_start_with		number := 1;

l_total_count		number := 0;



l_id				number;

cursor id_csr is select id from amv_temp_ids;

--

BEGIN

--DBMS_OUTPUT.PUT_LINE('Enter : Content_Search' );

    -- Standard begin of API savepoint

    SAVEPOINT  Content_Search;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call (

       l_api_version,

       p_api_version,

       l_api_name,

       G_PKG_NAME)

    THEN

       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- Debug Message

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');

       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');

       FND_MSG_PUB.Add;

    END IF;

    --Initialize message list if p_init_msg_list is TRUE.

    IF FND_API.To_Boolean (p_init_msg_list) THEN

       FND_MSG_PUB.initialize;

    END IF;

    -- Get the current (login) user id.

    AMV_UTILITY_PVT.Get_UserInfo(

			 x_resource_id => l_resource_id,

                x_user_id     => l_user_id,

                x_login_id    => l_login_user_id,

                x_user_status => l_login_user_status

                );

    -- check login user

    IF (p_check_login_user = FND_API.G_TRUE) THEN

       -- Check if user is login and has the required privilege.

       IF (l_login_user_id = FND_API.G_MISS_NUM) THEN

          -- User is not login.

          IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

              FND_MESSAGE.Set_name('AMV','AMV_USER_NOT_LOGIN');

              FND_MSG_PUB.Add;

          END IF;

          RAISE  FND_API.G_EXC_ERROR;

       END IF;

    END IF;

    -- Initialize API return status to sucess

    x_return_status := FND_API.G_RET_STS_SUCCESS;



    -- set days for last update days

    IF p_days = FND_API.G_MISS_NUM OR

	  p_days is null

    THEN

	  l_days := -1;

    ELSE

	  l_days := p_days;

    END IF;



    -- build an array of optional, required and excluded parameters

    parse_parameter_array(p_param_array,

			 		 l_optional_array,

			 		 l_required_array,

			 		 l_excluded_array,

					 l_keywords_search);



    IF p_imt_string = FND_API.G_MISS_CHAR OR p_imt_string is null THEN

     -- build imt search string

     build_imt_string(l_optional_array,

		 		  l_required_array,

				  l_excluded_array,

				  l_excluded_flag,

				  l_imt_string);

	IF l_imt_string is null THEN

		-- Must pass query string

     	IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

     		FND_MESSAGE.Set_name('AMV','AMV_SRCH_QRY_STR_NULL');

         	 	FND_MSG_PUB.Add;

    		END IF;

     	RAISE  FND_API.G_EXC_ERROR;

	END IF;

    ELSE

		l_imt_string := p_imt_string;

    END IF;



    l_category_array := amv_number_varray_type();

    l_channel_array := amv_number_varray_type();



    -- determine for search level

    IF p_user_id = FND_API.G_MISS_NUM OR

	  p_user_id is null

    THEN

	-- does not include item channel match if categories are null

	-- uncomment to search for items not associated to categories

	IF p_category_id.count = 0 THEN

		l_include_chns := FND_API.G_FALSE;

		l_category_search := FND_API.G_TRUE;

	ELSE

		-- search under the category passed

		get_category_channel ( p_category_id	=> p_category_id,

					   p_application_id => p_application_id,

					   p_include_subcats => p_include_subcats,

					   x_category_array => l_category_array,

					   x_channel_array => l_channel_array );

		IF l_category_array.count > 0 THEN

			-- set flag for category level search

			l_category_search := FND_API.G_TRUE;

		END IF;



		IF l_channel_array.count > 0 THEN

			-- set flag for channel level search

			l_channel_search := FND_API.G_TRUE;

		END IF;

	END IF;

    ELSE

     	-- search based on user privilege

		-- get the list of categories accessable by the user

    		get_app_categories( p_application_id => p_application_id,

						x_category_array => l_category_array);



		IF l_category_array.count > 0 THEN

			-- set flag for category level search

			l_category_search := FND_API.G_TRUE;

		END IF;



    		-- get the list of channels which is accessable by the user

    		get_user_accessable_channels( p_user_id => p_user_id,

							p_application_id => p_application_id,

							x_channel_array => l_channel_array);



		IF l_channel_array.count > 0 THEN

			-- set flag for channel level search

			l_channel_search := FND_API.G_TRUE;

		END IF;



		IF l_channel_array.count = 0 AND l_category_array.count = 0 THEN

	  		-- user does not have access to any channels or categories

    	  		IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)

			THEN

    				FND_MESSAGE.Set_name('AMV','AMV_CAT_USR_NOACCS');

    				FND_MESSAGE.Set_Token('TKN',p_user_id);

         			FND_MSG_PUB.Add;

    	  		END IF;

    	  		RAISE  FND_API.G_EXC_ERROR;

		END IF;

    END IF;

    --

    -- initialize search array

    x_searchres_array := amv_searchres_varray_type();



    -- set start index

    l_start_with := p_request_obj.start_record_position;



    -- check if search area and content exists



    --  perform search

    -- insert the list of categories to be search and perform search

    IF l_category_search = FND_API.G_TRUE THEN

 		insert_temp_numbers(p_id_array => l_category_array,

						x_status 	 => l_id_insert_status);



    		l_search_level := G_CATEGORY;

 		search_items(

				p_area_array	 => p_area_array,

				p_content_array => p_content_array,

				p_imt_string	 => l_imt_string,

				p_optional_array => l_optional_array,

				p_required_array => l_required_array,

				p_excluded_array => l_excluded_array,

				p_keywords_search => l_keywords_search,

				p_excluded_flag => l_excluded_flag,

				p_application_id => p_application_id,

				p_days		 => l_days,

				p_include_chns	 => l_include_chns,

				p_search_level  => l_search_level,

				p_external_contents => p_external_contents,

				p_records_requested => p_request_obj.records_requested,

				x_start_with => l_start_with,

				x_results_populated	=> l_rec_count,

				x_total_count  => l_total_count,

				x_searchres_array	=> x_searchres_array);

    END IF;



    -- insert the list of channels to be search and perform search

    IF l_channel_search = FND_API.G_TRUE THEN

  		insert_temp_numbers(p_id_array => l_channel_array,

						x_status 	 => l_id_insert_status);

    		l_search_level := G_CHANNEL;

 		search_items(

				p_area_array	 => p_area_array,

				p_content_array => p_content_array,

				p_imt_string	 => l_imt_string,

				p_optional_array => l_optional_array,

				p_required_array => l_required_array,

				p_excluded_array => l_excluded_array,

				p_keywords_search => l_keywords_search,

				p_excluded_flag => l_excluded_flag,

				p_application_id => p_application_id,

				p_days		 => l_days,

				p_include_chns	 => l_include_chns,

				p_search_level  => l_search_level,

				p_external_contents => p_external_contents,

				p_records_requested => p_request_obj.records_requested,

				x_start_with => l_start_with,

				x_results_populated	=> l_rec_count,

				x_total_count  => l_total_count,

				x_searchres_array	=> x_searchres_array);

    END IF;

    --

    --

    x_return_obj.returned_record_count :=  l_rec_count;

    x_return_obj.next_record_position :=

                  p_request_obj.start_record_position + l_rec_count;

    x_return_obj.total_record_count :=  l_total_count;



    /*

    x_return_obj := amv_return_obj_type(

					l_rec_count,

					p_request_obj.start_record_position + l_rec_count,

					l_total_count);

    */



    /*

    -- Success message

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)

    THEN

       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');

       FND_MESSAGE.Set_Token('ROW', l_full_name);

       FND_MSG_PUB.Add;

    END IF;

    */

    -- Debug Message

    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN

       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');

       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');

       FND_MSG_PUB.Add;

    END IF;

    --Standard call to get message count and if count=1, get the message

    FND_MSG_PUB.Count_And_Get (

       p_encoded => FND_API.G_FALSE,

       p_count => x_msg_count,

       p_data  => x_msg_data

       );

--DBMS_OUTPUT.PUT_LINE('Exit : Content_Search' );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

       ROLLBACK TO  Content_Search;

       x_return_status := FND_API.G_RET_STS_ERROR;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       ROLLBACK TO  Content_Search;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

   WHEN OTHERS THEN

       ROLLBACK TO  Content_Search;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

        THEN

                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);

        END IF;

       -- Standard call to get message count and if count=1, get the message

       FND_MSG_PUB.Count_And_Get (

          p_encoded => FND_API.G_FALSE,

          p_count => x_msg_count,

          p_data  => x_msg_data

          );

--

END content_search;

--

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

END amv_search_pvt;


/
