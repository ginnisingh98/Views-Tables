--------------------------------------------------------
--  DDL for Package Body BIS_GNRL_SEARCH_ENGINE_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_GNRL_SEARCH_ENGINE_PVT_OA" AS
/* $Header: BISSRCQB.pls 120.1 2006/08/21 12:41:54 akoduri noship $ */


-- **********************************************************
--   Procedure to build the InterMedia query
-- *********************************************************
Procedure build_query (
 p_api_version      in   pls_integer
,p_eul              in   varchar2
,p_keywords_tbl     in   BIS_GNRL_SEARCH_ENGINE_PVT_OA.keywords_tbl_typ
,x_results_tbl      out  NOCOPY BIS_GNRL_SEARCH_ENGINE_PVT_OA.results_tbl_typ
,x_return_status    out  NOCOPY varchar2
,x_error_tbl        out  NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
v_eul                varchar2(256);
l_sql                varchar2(32000);
l_wordlist           varchar2(32000);
l_dummy              pls_integer;
l_count              pls_integer;
l_cursor             pls_integer;
l_score1             pls_integer;
l_score2             pls_integer;
l_score3             pls_integer;
l_folder_id          pls_integer;
l_folder_name        varchar2(400);
l_folder_description varchar2(32000);
l_results_tbl        BIS_GNRL_SEARCH_ENGINE_PVT_OA.results_tbl_typ;


BEGIN



  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF(p_keywords_tbl.COUNT = 0) THEN
    RETURN;
  END IF;
 -- To make sure the Intermedia query does not break becuase of lack of schema name
 IF (p_eul IS NOT NULL) THEN
    v_eul := p_eul ||'.';
 ELSE
    v_eul := p_eul;
 END IF;

 -- Construct the search words list from the plsql
 -- table containing the words and add the appropriate InterMedia OPERATORS
 FOR i in 1 .. p_keywords_tbl.COUNT LOOP
   IF i = p_keywords_tbl.COUNT THEN
    l_wordlist := l_wordlist || c_stem_optr ||'{'|| p_keywords_tbl(i) ||'}';
    EXIT;
   END IF;
   l_wordlist := l_wordlist || c_stem_optr ||'{'||p_keywords_tbl(i)||'}'|| c_accum_optr;
 END LOOP;

 -- Add the appropriate number of ' to the ends of the word list to be embedded in the
 -- Intermedia query
 l_wordlist := concat_string(l_wordlist);


 -- ******************************************************************************
 --              CONSTRUCT THE INTERMEDIA SQL QUERY
 -- The '$' STEM operator creates a linguistic root of the word supplied
 -- and returns all row hits that contain words which could be probably
 -- generated by this root word.
 -- The ',' ACCUM operator accumulates the list of words supplied and returns
 -- the highest score for hits containing all of the words and then corresponding
 -- lower scores for subsequent row hits containing one or more words.
 -- The '{ }' ESCAPE SEQUENCE operators escape a group of reserved characters if exists.
 -- Example 1 : For word1 and word2 supplied, the query 'Contains(colname, 'word1,word2',2)
 -- will give the highest score for row hits containing both the words, and then
 -- a lower score for row hits for occurences of word1 OR word2.
 -- Example 2 : If the word contains 'function-layout', it will be read as {function-layout}
 --   as one word inclusive of the '-', where the '-' is escaped.
 -- QUERY FORMULA
 --   The following query will return rows that got the best hits according to
 --   the following priority order...
 --     1) All of the search words exist in eul_objs.obj_name column (Folder name)
 --     2) One or more search words exist in eul_objs.obj_name column (Folder name)
 --     3) All of the search words exist in eul_objs.obj_description col (Fldr desc.)
 --     4) One or more search words exist in eul_objs.obj_description col (Fldr desc)
 --     5) Now the detail table (eul_expressions.exp_name) is searched. This contains
 --        the cols that make up the above Folder/business view. These cols are searched
 --        for every folder_id (eul_objs.obj_id) as one singe 'document set', so that
 --        only one row is returned for hits on any of the folder columns. This part
 --        is taken care by the appropriate index 'BIS_BV_ITEM_NAMES_||'LANG''
 -- ****************************************************************************

 l_sql := ' select score(10), score(20), ' ||
          ' obj_id, obj_name, obj_description ' ||
          ' from  ' || v_eul || get_eul_table_version ||'_objs ' ||
          ' where contains (obj_name, ' || l_wordlist || ', 10) > 0 ' ||
          '    or contains (obj_description, ' || l_wordlist || ', 20) > 0 ' ||
          ' order by score(10) DESC ,score(20) DESC';

 -- *************************************************
 -- *************   For DEBUGGING    ****************
   /*************************************************
    htp.p('ENTERED BUILD_QUERY ');
    htp.p('l_wordlist '||l_wordlist||'<BR>');
    htp.p('l_sql '||l_sql||'<BR>');
   *************************************************/

  -- Now prepare and run the sql query
  l_cursor  := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(l_cursor, l_sql, DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN(l_cursor,1, l_score1);
  DBMS_SQL.DEFINE_COLUMN(l_cursor,2, l_score2);
  DBMS_SQL.DEFINE_COLUMN(l_cursor,3, l_folder_id);
  DBMS_SQL.DEFINE_COLUMN(l_cursor,4, l_folder_name,400);
  DBMS_SQL.DEFINE_COLUMN(l_cursor,5, l_folder_description,32000);

  l_dummy := DBMS_SQL.EXECUTE(l_cursor);

  -- Collect the results - folder_id, folder_name and folder_description into
  -- the plsql table to send it back to BIS_BUSINESS_VIEWS_CATALOG packkage
  l_count := 1;
  LOOP
   l_dummy := DBMS_SQL.FETCH_ROWS(l_cursor);
     IF (l_dummy = 0)          THEN EXIT; END IF;
     IF (l_count > C_MAX_HITS) THEN EXIT; END IF;

   DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_score1);
   DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_score2);
   DBMS_SQL.COLUMN_VALUE(l_cursor, 3, l_folder_id);
   DBMS_SQL.COLUMN_VALUE(l_cursor, 4, l_folder_name);
   DBMS_SQL.COLUMN_VALUE(l_cursor, 5, l_folder_description);


   -- Transfer the fetched values from the buffer into the plsql table
   l_results_tbl(l_count).folder_id          := l_folder_id;
   l_results_tbl(l_count).folder_name        := l_folder_name;
   l_results_tbl(l_count).folder_description := l_folder_description;
   l_results_tbl(l_count).folder_eul := p_eul;
   l_count := l_count + 1;
  END LOOP;

  -- Close the cursor
  DBMS_SQL.CLOSE_CURSOR(l_cursor);
  COMMIT;

 -- Send this table of results back
 x_results_tbl  := l_results_tbl;



EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => x_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
  --htp.p('Error in BIS_GNRL_SEARCH_ENGINE_PVT.build_query'||SQLERRM);
  RAISE;

END build_query;

-- *************************************************************
--  Get the intermedia domain index owner
-- *************************************************************
Function get_a_index_owner( p_index    in varchar2 )
return eul_results
IS

TYPE Recdc_eul IS REF CURSOR;
dc_eul			Recdc_eul;

dc_query		varchar2(500);
eul			varchar2(30);

pv_cntr			number;
pv_eul_cnt		number;

--l_owner    varchar2(200);
  l_temp		eul_results;
  l_owner		eul_results;

BEGIN

  dc_query := 'select distinct ' ||
              '        b.profile_option_value || ''_'' || c.language ' ||
              '  from ' ||
              '        fnd_profile_options a ' ||
              '       ,fnd_profile_option_values b' ||
              '       ,fnd_profile_options_tl c ' ||
              ' where ' ||
              '       a.profile_option_name = ''ICX_DEFAULT_EUL'' and ' ||
              '       a.profile_option_id = b.profile_option_id and ' ||
              '       a.profile_option_name = c.profile_option_name ';


  pv_cntr := 0;
  open dc_eul for dc_query;
    loop
      fetch dc_eul into l_temp(pv_cntr + 1).eul_schema;
      exit when dc_eul%NOTFOUND;
      pv_cntr := pv_cntr + 1;
    end loop;
  close dc_eul;

  dc_query := 'select distinct count(*) ' ||
              '  from all_objects ' ||
              ' where owner = :e ' ||
              '   and object_name = ''' || get_eul_table_version || '_BAS''' ||
              '   and object_type = ''TABLE''';

  pv_cntr := 1;
  for i in 1..l_temp.count loop
    open dc_eul for dc_query using l_temp(i).eul_schema;
      fetch dc_eul into pv_eul_cnt;
        if pv_eul_cnt > 0 then
          l_owner(pv_cntr).eul_schema := l_temp(i).eul_schema;
          pv_cntr := pv_cntr + 1;
        end if;
    close dc_eul;
  end loop;


  return l_owner;

EXCEPTION
  WHEN OTHERS THEN
  rollback;
  --htp.p('Error in BIS_GNRL_SEARCH_ENGINE_PVT.get_a_index_owner');
  RAISE;
END get_a_index_owner;

-- ****************************************************
--     Function to return a string with attachments on
--               both sides
-- ****************************************************
function concat_string (p_str   in varchar2)
return
   varchar2 is
v_local_str   varchar2(3200);

begin
   v_local_str := ''''||p_str||'''';

   return v_local_str;
end concat_string;

-- *****************************************************

-- *************************************************************
--  Get the Oracle Discover Version
-- *************************************************************
FUNCTION get_disco_release
RETURN VARCHAR2
IS
  l_disco_release      fnd_profile_option_values.profile_option_value%TYPE;
  x_release_name       VARCHAR2(50);
  x_other_release_info VARCHAR2(50);
  l_status             BOOLEAN;
  l_major_version      VARCHAR2(50);
BEGIN
  l_status := fnd_release.get_release(
                release_name       => x_release_name,
                other_release_info => x_other_release_info);
  IF (l_status = TRUE AND x_release_name IS NOT NULL) THEN
    l_major_version := SUBSTR(x_release_name,1,INSTR(x_release_name,'.',1,1)-1);
    IF (l_major_version = '12') THEN
      RETURN '10';-- In R12 the default value is 10
    END IF;
  END IF;
  --The following code will be executed only in 11i
  l_disco_release := fnd_profile.value('ICX_DISCOVERER_RELEASE');
  IF (l_disco_release IS NULL) THEN
    RETURN '4';
  END IF;

  RETURN l_disco_release;
EXCEPTION
  WHEN OTHERS THEN
  RETURN '4';
END get_disco_release;
-- ***************************************************************
--  Get the Oracle EUL TABLE VERSION
-- *************************************************************
FUNCTION get_eul_table_version
RETURN varchar2
IS
 l_eul_file_version varchar2(10);
BEGIN
  IF(TO_NUMBER(get_disco_release) <= 4) THEN
    l_eul_file_version := 'EUL4';
  ELSE
    l_eul_file_version := 'EUL5';
  END IF;
  return l_eul_file_version;
EXCEPTION
  WHEN OTHERS THEN
  RETURN 'EUL4';
END get_eul_table_version;
-- ***************************************************************

END BIS_GNRL_SEARCH_ENGINE_PVT_OA;

/
