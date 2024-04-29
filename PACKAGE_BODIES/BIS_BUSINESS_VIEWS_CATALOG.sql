--------------------------------------------------------
--  DDL for Package Body BIS_BUSINESS_VIEWS_CATALOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUSINESS_VIEWS_CATALOG" AS
/* $Header: BISPBVCB.pls 115.5 2000/08/14 12:12:32 pkm ship        $ */

-- *******************************************************
--   This displays the plug on the Personal Home Page
-- *******************************************************
PROCEDURE  enter_query_page_plug
( p_session_id    IN  pls_integer
, p_plug_id       IN  pls_integer
, p_display_name  IN  VARCHAR2   DEFAULT NULL
, p_delete        IN  VARCHAR2   DEFAULT 'N'
)

IS
l_lang           varchar2(100);
l_submit         varchar2(240);
l_title          varchar2(100);
l_prompts        ICX_UTIL.g_prompts_table;
l_user_id        pls_integer;

BEGIN

  IF  upper( p_delete ) <> 'Y'  --  if p_delete is set to yes, STOP
  AND ICX_SEC.validatePlugSession( p_plug_id, p_session_id )  THEN

    -- Get the Language CODE and USERID from the ICX environment
    l_user_id := ICX_SEC.getID(ICX_SEC.pv_user_id, '', p_session_id);
    l_lang := ICX_SEC.getID(icx_sec.PV_LANGUAGE_CODE);


    -- Begin painting the table structure for the plug
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');

      htp.p('<tr> ');
      htp.p('<td> ');
      ICX_PLUG_UTILITIES.plugbanner
         ( p_text    =>  NVL(p_display_name, c_title)
         , p_icon    =>  'FNDBVCAT.gif'
         );
      htp.p('</td> ');
      htp.p('</tr> ');

      htp.p('<tr> ');
      htp.p('<td> ');
      htp.p('<font size=-2> ');
      htp.p('<br> ');
      htp.p('</font> ');
      htp.p('</td> ');
      htp.p('</tr> ');

      htp.p('<tr> ');
      htp.p('<td colspan=1 align=left>');
        htp.p('<table border=0 cellspacing=0 cellpadding=0 width=10%>');
        htp.p('<tr> ');
        -- ********************** OPEN FORM ************************
        htp.formOpen(icx_plug_utilities.getplsqlagent||'BIS_BUSINESS_VIEWS_CATALOG.query'
                 ,'POST','','','NAME="BVC"');
        htp.formHidden('p_lang',l_lang);

        htp.p('<td align=right> ');
        htp.p('<input type="text" size=40 name="p_keywords"> ');
        htp.p('</td>  ');

        insert_blank_cell;

        htp.p('<td align=left> ');
        icx_plug_utilities.buttonboth (c_submit, 'javascript:document.BVC.submit()');
        htp.p('</td>  ');

        htp.formClose;
        -- ************************ CLOSE FORM ***********************
        htp.p('</tr> ');
        htp.tableClose;

      htp.p('</td> ');
      htp.p('</tr> ');

      htp.p('<tr> ');
      htp.p('<td> ');
      htp.p('<br> ');
      htp.p('</td> ');
      htp.p('</tr> ');

    htp.tableClose;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    htp.p( SQLERRM );

END  enter_query_page_plug;

 -- ************************************************************
 --    Function to get a business area
 --    A folder may belong to many business areas. So, pick the
 --  first Business Area I get.
 -- ***********************************************************
FUNCTION   get_a_business_area
( p_folder_id   IN  PLS_INTEGER
, p_eul         IN  VARCHAR2
)
RETURN  VARCHAR2
IS

l_sql            varchar2(1000);
l_ba_name        varchar2(256);
l_csr            pls_integer;
l_ignore         pls_integer;
l_dummy          pls_integer;

BEGIN

  l_csr := DBMS_SQL.open_cursor;
  BEGIN
    l_sql:= 'select ba_name from ' || p_eul ||'.eul_business_areas ba, ' ||
                                  p_eul ||'.eul_ba_obj_links bol ' ||
        'where ' || p_folder_id || ' = bol.bol_obj_id ' ||
        'and        bol.bol_ba_id    =  ba.ba_id ';
    DBMS_SQL.parse( l_csr, l_sql, dbms_sql.native );
    DBMS_SQL.define_column( l_csr, 1, l_ba_name, 256 );
    l_ignore := DBMS_SQL.execute( l_csr );

    l_dummy := DBMS_SQL.fetch_rows( l_csr );
    IF  l_dummy > 0  THEN
      DBMS_SQL.column_value( l_csr, 1, l_ba_name );
    ELSE
      l_ba_name := ' ';
    END IF;
  EXCEPTION
    WHEN  OTHERS  THEN
      dbms_sql.close_cursor( l_csr );
      RAISE;
  END;
  dbms_sql.close_cursor( l_csr );

  RETURN  l_ba_name;

END  get_a_business_area;

-- *********************************************************
--    Paint the Heading cell
-- *********************************************************
procedure  insert_heading_cell( p_text  in  varchar2 )
is
begin

  htp.p('<th align=left bgcolor=' || icx_plug_utilities.headingcolor || '>');
  htp.p('  <table border=0 cellspacing=0 cellpadding=1 >');
  htp.p('    <tr> ');
  htp.p('      <th align=left>');
  htp.p('      <font face="Arial" size=2> ');
  htp.p(         p_text );
  htp.p('      </th>');
  htp.p('    </tr> ');
  htp.p('  </table> ');
  htp.p('</th> ');

end  insert_heading_cell;

-- ************************************************************
--   Paint a blank heading cell
-- ***********************************************************
procedure  insert_blank_heading_cell
is
begin

  htp.p('<th bgcolor=' || icx_plug_utilities.headingcolor || '>');
  htp.p('  <table border=0 cellspacing=0 cellpadding=1 >');
  htp.p('    <tr> ');
  htp.p('      <td>');
  htp.p('        <br> ');
  htp.p('      </td>');
  htp.p('    </tr> ');
  htp.p('  </table> ');
  htp.p('</th> ');

end  insert_blank_heading_cell;

-- ************************************************************
--      Paint a blank cell
-- ************************************************************
procedure  insert_blank_cell
is
begin

  htp.p('<TD>'||'&'||'nbsp</TD>');

end  insert_blank_cell;


-- *************************************************************
--          Paint the results table
-- *************************************************************
PROCEDURE  results_page
( p_results_tbl  IN  BIS_GNRL_SEARCH_ENGINE_PVT.results_tbl_typ
, p_lang         IN  VARCHAR2
)

IS

l_prompts                  ICX_UTIL.g_prompts_table;
l_region_name              varchar2(256);
l_eul                      VARCHAR2(256);
i                          PLS_INTEGER;
l_ba                        varchar2(240);

BEGIN

    --ICX_UTIL.getPrompts(191, 'BIS_BVC_PROMPTS, l_title, l_prompts);

  htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');

  IF (p_results_tbl.COUNT = 0) THEN NULL;

  ELSE
    -- htp.p('Total Hits  = '||p_results_tbl.COUNT );

    -- Begin painting the table containing the results
    -- ********* Paint the Headers first **************
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100% >');
    htp.p('  <tr> ');
    insert_blank_heading_cell;
    insert_heading_cell(c_folder);

    insert_blank_heading_cell;

    htp.p('<th align=left nowrap bgcolor='||icx_plug_utilities.headingcolor||'>');
    htp.p('<font face="Arial" size=2> ');
    htp.p(c_busarea);
    htp.p('</th> ');

    insert_blank_heading_cell;

    htp.p('<th align=left nowrap bgcolor='||icx_plug_utilities.headingcolor||'>');
    htp.p('<font face="Arial" size=2> ');
    htp.p(c_desc);
    htp.p('</th> ');
    htp.p('</tr> ');
    -- ******************** Headers end   **********************

    l_eul := BIS_GNRL_SEARCH_ENGINE_PVT.get_a_index_owner
                     ( 'BIS_BV_FOLDER_NAMES_' || p_lang );

    IF (l_eul IS NULL) THEN RAISE BIS_GNRL_SEARCH_ENGINE_PVT.e_noIndexDefined;
    END IF;

    -- **************************************************
    -- Begin painting the query results
    -- ***************************************************
    FOR i in 1 ..p_results_tbl.COUNT LOOP

      --Get a Business Area that this folder belongs to
      l_ba     := get_a_business_area( p_folder_id => p_results_tbl(i).folder_id
                                      ,p_eul       => l_eul );

      -- Start the table rows
      htp.p('<tr>');
      htp.p('<td nowrap>');
      htp.p('<br>');
      htp.p('</td>');
      htp.p('<td nowrap>');
      htp.p(p_results_tbl(i).folder_name);
      htp.p('</td>');
      htp.p('<td nowrap>');
      htp.p('<br>');
      htp.p('</td>');
      htp.p('<td nowrap>');
      htp.p( l_ba );
      htp.p('</td> ');
      htp.p('<td nowrap> ');
      htp.p('<br>');
      htp.p('</td>');
      htp.p('<td>');
      htp.p( p_results_tbl(i).folder_description );
      htp.p('</td>');
      htp.p('</tr>');

    END LOOP;  -- End of the p_results_tbl.COUNT loop
  htp.p('</table> ');

  END IF;    -- if p_results_tbl.COUNT is ZERO

  htp.bodyClose;
  htp.htmlClose;
EXCEPTION
  WHEN BIS_GNRL_SEARCH_ENGINE_PVT.e_noIndexDefined THEN RAISE;
  WHEN OTHERS THEN htp.p(SQLERRM);

END  results_page;

-- *********************************************************
--  Procedure for the second page to enter keywords
-- ********************************************************

PROCEDURE  enter_query_page
( p_keywords      in  varchar2
, p_lang          in  varchar2
)

IS
l_ba                      varchar2(240);
l_folder_description      varchar2(240);
l_prompts                 ICX_UTIL.g_prompts_table;

BEGIN

    --ICX_UTIL.getPrompts(191, 'BIS_BVC_PROMPTS, l_title, l_prompts);
    --l_submit := l_prompts(5);

  htp.htmlopen;
  htp.headopen;
  htp.title( c_title );
  htp.headclose;
  htp.p('<body bgcolor="'||icx_plug_utilities.bgcolor||'">');

  htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');
  htp.p('  <tr> ');
    ICX_PLUG_UTILITIES.toolbar (
             p_text => c_title
           , p_disp_mainmenu  => 'Y'
           , p_disp_menu      => 'N'
           );
  htp.p('</tr>');
  htp.p('</table> ');

  htp.p('<tr> ');
  htp.p('<td> ');
  htp.p('<br> ');
  htp.p('</td> ');
  htp.p('</tr> ');

  htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');

  -- ************** OPEN FORM *******************************
  htp.formOpen('BIS_BUSINESS_VIEWS_CATALOG.query'
                 ,'POST','','','NAME="BVC"');

  htp.formHidden('p_lang',p_lang);

  htp.p('<tr> ');
  htp.p('<td align=center> ');
  htp.p('<table border=0 cellspacing=0 cellpadding=0 width=10%>');

  htp.p('<tr> ');
  htp.p('<td align=right> ');
  htp.p('<input type="text" size=40 name="p_keywords" value="' || p_keywords ||'" >' );
  htp.p('</td>  ');

  insert_blank_cell;

  htp.p('<td align=left> ');
  icx_plug_utilities.buttonboth ( c_submit , 'javascript:document.BVC.submit()' );
  htp.p('</td>  ');
  htp.p('</tr> ');
  htp.p('</table> ');

  htp.p('</td> ');
  htp.p('</tr> ');

  htp.formClose;
  -- ****************** CLOSE FORM ******************************

  htp.p('<tr> ');
  htp.p('<td> ');
  htp.p('<br> ');
  htp.p('</td> ');
  htp.p('</tr> ');

  htp.p('<tr> ');
  htp.p('<td> ');
  htp.p('<br> ');
  htp.p('</td> ');
  htp.p('</tr> ');

  htp.p('</table> ');


EXCEPTION
  WHEN OTHERS THEN
    htp.p( SQLERRM );

END  enter_query_page;

-- **********************************************************
--  Procedure query is called from the html form as set up by
--  the procedures 'enter_query_page_plug' and 'enter_query_page' .
--  It validates the search words and then transfers them into
--  a plsql table to be sent to the
--        BIS_GENERAL_SEARCH_ENGINE_PVT.build_query procedure.
-- *************************************************************
PROCEDURE  query
( p_keywords         IN  varchar2
, p_lang             IN  varchar2
)
IS
i                    pls_integer;
l_plug_id            pls_integer;
l_user_id            pls_integer;
l_return_status      VARCHAR2(100);
l_eul                VARCHAR2(256);
l_lang               VARCHAR2(100);
l_length             pls_integer;
l_startpoint         pls_integer;
l_separator          pls_integer;
l_keywords_tbl       BIS_GNRL_SEARCH_ENGINE_PVT.keywords_tbl_typ;
l_results_tbl        BIS_GNRL_SEARCH_ENGINE_PVT.results_tbl_typ;
l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
l_prompts            ICX_UTIL.g_prompts_table;
v_keywords           varchar2(32000);


BEGIN
  IF  (ICX_SEC.validateSession)  THEN
   l_user_id := ICX_SEC.getID(icx_sec.PV_USER_ID);

    -- ****************************************************************
    --  Transfer the individual words from the input box into
    --  a plsql table after cleaning and validating the entries
    l_length := LENGTH( p_keywords );
      -- ONLY if there are any words entered then do the processing
      -- else  just paint the word entry screen again
    IF (l_length > 0) THEN
        -- replace any commas with a space
       v_keywords := REPLACE(p_keywords, ',', ' ');
      i := 1;
      l_startpoint := 1;

      -- ********* Begin wordlist PARSER  *************
      WHILE (l_startpoint < l_length) LOOP
        l_separator := INSTR(v_keywords,' ',l_startpoint,1);

        IF (l_separator > 0) THEN  -- If there is atleast one space or comma
          l_keywords_tbl(i) := LTRIM(RTRIM(SUBSTR(v_keywords,l_startpoint,l_separator - l_startpoint)));
          l_startpoint := l_separator + 1;
          i := i + 1;

          IF (l_startpoint =  INSTR(v_keywords,' ',l_startpoint,1)) THEN
              -- In case the next char is also a space or a comma the startpoint is
              -- incremented once more
              l_startpoint := l_startpoint + 1;
          END IF; -- endif for checking if the next char is the same as this one
        END IF;

        IF ((l_separator = 0) AND (l_startpoint = 1))  THEN
          -- just one word in inputbox so do not loop anymore
          l_keywords_tbl(i) := LTRIM(RTRIM(v_keywords));
          EXIT;
        ELSIF
         ((l_separator = 0) AND (l_startpoint > 1)) THEN
          -- or if this is the last word in the word list
          l_keywords_tbl(i) := SUBSTR(v_keywords,l_startpoint);
          EXIT;
        END IF;  -- end if to see where we are in string parsing

      END LOOP; -- end of while loop
    -- ********************************************************************
    -- *************  End of wordlist PARSER *****************************

      -- Clip the ends of the language code to remove spurious spaces
      l_lang := ltrim(rtrim( p_lang ));


      --  if Business Views InterMedia Indexes have been installed in
      --  several schemas, some schema is chosen, arbitrarily.

      l_eul := BIS_GNRL_SEARCH_ENGINE_PVT.get_a_index_owner( 'BIS_BV_FOLDER_NAMES_' || l_lang );

     IF (l_eul IS NULL) THEN RAISE BIS_GNRL_SEARCH_ENGINE_PVT.e_noIndexDefined;
     END IF;

     /************* FOR DEBUGGING  *************************
      htp.p('11111111111111111111111111111111111111111'||'<BR>');
      htp.p('p_lang     :'||p_lang||'<BR>');
      htp.p('p_keywords :'||p_keywords||'<BR>');
      htp.p('v_keywords :'||v_keywords||'<BR>');
      htp.p('l_length   :'||l_length||'<BR>');
      htp.p('l_eul      :'||l_eul||'<BR>');
      htp.p('22222222222222222222222222222222222222222222'||'<BR>');
      htp.p('l_keywords_tbl COUNT :'||l_keywords_tbl.COUNT||'<BR>');
      for i in 1 .. l_keywords_tbl.COUNT loop
         htp.p('l_keywords_tbl_'||i||' :'||l_keywords_tbl(i)||'<BR>');
      end loop;
      htp.p('33333333333333333333333333333333333333333'||'<BR>');
     ************* FOR DEBUGGING  *************************/

      BEGIN
        -- Now call the package to build and run the InterMedia
        --       query and obtain the best row hits
        BIS_GNRL_SEARCH_ENGINE_PVT.build_query
                ( p_api_version    =>  1.0
                 ,p_eul            =>  l_eul
                 ,p_keywords_tbl   =>  l_keywords_tbl
                 ,x_results_tbl    =>  l_results_tbl
                 ,x_return_status  =>  l_return_status
                 ,x_error_tbl      =>  l_error_tbl
                 );

       EXCEPTION
         WHEN OTHERS THEN RAISE;

       END;  -- end of begin-end block of call to procedure which will
             -- build and run the INterMedia query

       IF  l_return_status = fnd_api.G_RET_STS_SUCCESS  THEN
          -- First print out the keywords entry box again for future tries
          enter_query_page( p_keywords => p_keywords
                          , p_lang     => p_lang );
          -- Then print out the result set
          results_page( p_results_tbl => l_results_tbl
                      , p_lang        => p_lang );
       END IF;

      -- *********************************************************
   ELSE    -- If no keywords entered in the box<l_length(p_keywords) = 0>
      -- Print out the keywords entry box again for future tries
      enter_query_page( p_keywords, p_lang );
      htp.bodyClose;
      htp.htmlClose;

   END IF;  -- endif for l_length of the keywords entered not equal to zero
   -- *********************************************************


 END IF;   -- ICX_SEC.validatesession()

EXCEPTION
  WHEN BIS_GNRL_SEARCH_ENGINE_PVT.e_noIndexDefined THEN
    -- The following message need not be translated since this is a propagated error
    -- due to undefined InterMedia domain Index. The Preferences and Indexes must
    -- be created first, for the Business Views Catalog Search region to work !!
    htp.p('<BR><BR>');
    htp.p('ERROR : InterMedia Index Not Created in Language - '||p_lang||'<BR>');
    htp.p('Please run BISPBVI.sql in the Discoverer eul schema with appropriate Language code as parameter.'||'<BR>');
  WHEN OTHERS THEN
    htp.p( SQLERRM );
END  query;

-- ************************************************
-- ************************************************
END  bis_business_views_catalog;

/
