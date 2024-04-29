--------------------------------------------------------
--  DDL for Package Body BIS_BUSINESS_VIEWS_CATALOG_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUSINESS_VIEWS_CATALOG_OA" AS
/* $Header: BISEULQB.pls 120.1 2005/10/21 07:03:57 ppandey noship $ */

gv_user_id		number;

 -- ************************************************************
 --    Function to get a business area
 --    A folder may belong to many business areas. So, pick the
 --  first Business Area I get.
 -- ***********************************************************
FUNCTION   get_a_business_area
( p_folder_id   IN  PLS_INTEGER
, p_eul         IN  VARCHAR2
)
return bis_gnrl_search_engine_pvt_oa.results_tbl_typ
--RETURN  VARCHAR2
IS

l_sql            varchar2(1000);
--l_ba_name        varchar2(256);
l_ba_name	bis_gnrl_search_engine_pvt_oa.results_tbl_typ;

TYPE Recdc_ba IS REF CURSOR;
dc_ba		Recdc_ba;

--l_csr            pls_integer;
--l_ignore         pls_integer;
--l_dummy          pls_integer;
pv_dc_query	varchar2(1000);
pv_cntr		number;
l_disco_table_version   varchar2(10);
BEGIN

  l_disco_table_version := BIS_GNRL_SEARCH_ENGINE_PVT_OA.get_eul_table_version;
  pv_dc_query := 'select distinct ' ||
                 '        ba_name ' ||
                 '       ,ba_id ' ||
                 '  from ' ||
                          p_eul || '.' || l_disco_table_version ||'_bas ba, ' ||
                          p_eul || '.' || l_disco_table_version ||'_ba_obj_links bol ' ||
                 ' where ' ||
                          ' bol.bol_obj_id = :1' ||
                 '   and  bol.bol_ba_id    =  ba.ba_id ';

  pv_cntr := 0;
  open dc_ba for pv_dc_query USING p_folder_id;
    loop
      fetch dc_ba into l_ba_name(pv_cntr + 1).folder_name,
                       l_ba_name(pv_cntr + 1).folder_id;
      exit when dc_ba%NOTFOUND;
      pv_cntr := pv_cntr + 1;
    end loop;
  close dc_ba;

/*
  l_csr := DBMS_SQL.open_cursor;
  BEGIN
    l_sql:= 'select ba_name, ba_id from ' || p_eul ||'.'|| l_disco_table_version || '_bas ba, ' ||
                                  p_eul ||'.' || l_disco_table_version || '_ba_obj_links bol ' ||
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
*/

  RETURN  l_ba_name;

END  get_a_business_area;


-- *************************************************************
--          Paint the results table
-- *************************************************************
PROCEDURE  results_page
( p_results_tbl  IN  BIS_GNRL_SEARCH_ENGINE_PVT_OA.results_tbl_typ
, p_lang         IN  VARCHAR2
)

IS

l_prompts                  ICX_UTIL.g_prompts_table;
l_region_name              varchar2(256);
l_eul                      VARCHAR2(256);
JAIRl_eul				BIS_GNRL_SEARCH_ENGINE_PVT_OA.EUL_results;
i                          PLS_INTEGER;
--l_ba                        varchar2(240);
l_ba			bis_gnrl_search_engine_pvt_oa.results_tbl_typ;

pv_is_accessible		varchar2(10);

BEGIN

    --ICX_UTIL.getPrompts(191, 'BIS_BVC_PROMPTS, l_title, l_prompts);


  IF (p_results_tbl.COUNT = 0) THEN NULL;

  ELSE

    JAIRl_eul := BIS_GNRL_SEARCH_ENGINE_PVT_OA.get_a_index_owner
                     ( 'BIS_BV_FOLDER_NAMES_' || p_lang );

    IF (JAIRl_eul IS NULL) THEN RAISE BIS_GNRL_SEARCH_ENGINE_PVT_OA.e_noIndexDefined;
    END IF;

    -- **************************************************
    -- Begin painting the query results
    -- ***************************************************
    for i in 1 ..p_results_tbl.count loop

      --Get a Business Area that this folder belongs to
      l_ba     := get_a_business_area( p_folder_id => p_results_tbl(i).folder_id
                                      ,p_eul       => p_results_tbl(i).folder_eul );

      --insert values into table.
      for j in 1..l_ba.count loop
        pv_is_accessible := Is_Business_Area_Accessible( l_ba(j).folder_id
                                                        ,gv_user_id
                                                        ,p_results_tbl(i).folder_eul);

        insert into bis_search_results ( eul
                                        ,eul_id
                                        ,folder_name
                                        ,ba_id
                                        ,business_area
                                        ,folder_description
                                        ,eul_access
                                        ,user_id)
                                 values( p_results_tbl(i).folder_eul
                                        ,p_results_tbl(i).folder_id
                                        ,p_results_tbl(i).folder_name
                                        ,l_ba(j).folder_id
                                        ,l_ba(j).folder_name
                                        ,p_results_tbl(i).folder_description
                                        ,pv_is_accessible
                                        ,gv_user_id);

      end loop; -- End of j loop (l_ba)
      commit;

    end loop;  -- End of the p_results_tbl.count loop

  end if;    -- if p_results_tbl.count is zero

EXCEPTION
  WHEN BIS_GNRL_SEARCH_ENGINE_PVT_OA.e_noIndexDefined THEN RAISE;
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
  htp.formOpen(icx_plug_utilities.getplsqlagent||'BIS_BUSINESS_VIEWS_CATALOG.query'
                 ,'POST','','','NAME="BVC"');

  htp.formHidden('p_lang',p_lang);

  htp.p('<tr> ');
  htp.p('<td align=center> ');
  htp.p('<table border=0 cellspacing=0 cellpadding=0 width=10%>');

  htp.p('<tr> ');
  htp.p('<td align=right> ');
  htp.p('<input type="text" size=40 name="p_keywords" value="' || p_keywords ||'" >' );
  htp.p('</td>  ');

--  insert_blank_cell;


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
--        BIS_GENERAL_SEARCH_ENGINE_PVT_OA.build_query procedure.
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
JAIRl_eul		BIS_GNRL_SEARCH_ENGINE_PVT_OA.eul_results;
l_lang               VARCHAR2(100);
l_length             pls_integer;
l_startpoint         pls_integer;
l_separator          pls_integer;
l_keywords_tbl       BIS_GNRL_SEARCH_ENGINE_PVT_OA.keywords_tbl_typ;
l_results_tbl        BIS_GNRL_SEARCH_ENGINE_PVT_OA.results_tbl_typ;
l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
l_prompts            ICX_UTIL.g_prompts_table;
l_current_key_word   varchar2(2000); -- to hold the current key word
v_keywords           varchar2(32000);

p_jair_results_tbl   BIS_GNRL_SEARCH_ENGINE_PVT_OA.results_tbl_typ;
pv_cnt			number := 0;


BEGIN

  -- Delete all the previous results from the table.
  -- Changed from Truncate to Delete as truncate will not work on synonym.
  EXECUTE IMMEDIATE 'DELETE FROM bis_search_results';

  -- Will ensure that the previous results from the search table will be deleted permanatly
  COMMIT;


--  IF  (ICX_SEC.validateSession)  THEN
   l_user_id := ICX_SEC.getID(icx_sec.PV_USER_ID);

--    select USERENV('SESSIONID') into pv_session_id from dual;

    select FND_GLOBAL.user_id into gv_user_id from dual;


    -- ****************************************************************
    --  Transfer the individual words from the input box into
    --  a plsql table after cleaning and validating the entries

    l_length := LENGTH( p_keywords );
      -- ONLY if there are any words entered then do the processing
      -- else  just paint the word entry screen again

    IF (l_length > 0) THEN
        -- replace any commas with a space
       v_keywords := REPLACE(p_keywords, ',', ' ');
       v_keywords := REPLACE(v_keywords, '''', '''''');
       v_keywords := REPLACE(v_keywords, '\', '\\');
       v_keywords := REPLACE(v_keywords, '}', '\}');
      i := 1;
      l_startpoint := 1;
      -- ********* Begin wordlist PARSER  *************
      WHILE (l_startpoint <= l_length) LOOP
        l_separator := INSTR(v_keywords,' ',l_startpoint,1);
        IF (l_separator > 0) THEN  -- If there is atleast one space or comma
	  l_current_key_word := LTRIM(RTRIM(SUBSTR(v_keywords,l_startpoint,l_separator - l_startpoint)));
	  IF(l_current_key_word IS NOT NULL) THEN --Add a keyword to the list only if it is not null
            l_keywords_tbl(i) := l_current_key_word;
            i := i + 1;
	  END IF;
          l_startpoint := l_separator + 1;

          IF (l_startpoint =  INSTR(v_keywords,' ',l_startpoint,1)) THEN
              -- In case the next char is also a space or a comma the startpoint is
              -- incremented once more
              l_startpoint := l_startpoint + 1;
          END IF; -- endif for checking if the next char is the same as this one
        END IF;

        IF ((l_separator = 0) AND (l_startpoint = 1))  THEN
          -- just one word in inputbox so do not loop anymore
	  IF ( LTRIM(RTRIM(v_keywords)) IS NOT NULL) THEN
            l_keywords_tbl(i) := LTRIM(RTRIM(v_keywords));
	  END IF;
          EXIT;
        ELSIF
         ((l_separator = 0) AND (l_startpoint > 1)) THEN
          -- or if this is the last word in the word list
	  IF( SUBSTR(v_keywords,l_startpoint) IS NOT NULL) THEN
            l_keywords_tbl(i) := SUBSTR(v_keywords,l_startpoint);
	  END IF;
          EXIT;
        END IF;  -- end if to see where we are in string parsing

      END LOOP; -- end of while loop
    -- ********************************************************************
    -- *************  End of wordlist PARSER *****************************

      -- Clip the ends of the language code to remove spurious spaces
      l_lang := ltrim(rtrim( p_lang ));


      --  if Business Views InterMedia Indexes have been installed in
      --  several schemas, some schema is chosen, arbitrarily.
      JAIRl_eul := BIS_GNRL_SEARCH_ENGINE_PVT_OA.get_a_index_owner( 'BIS_BV_FOLDER_NAMES_' || l_lang );


     IF (JAIRl_eul IS NULL) THEN RAISE BIS_GNRL_SEARCH_ENGINE_PVT_OA.e_noIndexDefined;
     END IF;

    for i in 1..JAIRl_eul.count loop
      BEGIN
        -- Now call the package to build and run the InterMedia
        --       query and obtain the best row hits
        BIS_GNRL_SEARCH_ENGINE_PVT_OA.build_query
                ( p_api_version    =>  1.0
                 ,p_eul            =>  JAIRl_eul(i).eul_schema
                 ,p_keywords_tbl   =>  l_keywords_tbl
                 ,x_results_tbl    =>  l_results_tbl
                 ,x_return_status  =>  l_return_status
                 ,x_error_tbl      =>  l_error_tbl
                 );

        --update the number of hits, this includes all hits for all EULS.
        for j in 1..l_results_tbl.count loop
          p_jair_results_tbl(pv_cnt + j).folder_id  := l_results_tbl(j).folder_id;
          p_jair_results_tbl(pv_cnt + j).folder_name  := l_results_tbl(j).folder_name;
          p_jair_results_tbl(pv_cnt + j).folder_description  := l_results_tbl(j).folder_description;
          p_jair_results_tbl(pv_cnt + j).folder_eul  := l_results_tbl(j).folder_eul;
        end loop;

        pv_cnt := p_jair_results_tbl.count;

       EXCEPTION
         WHEN OTHERS THEN RAISE;

       END;  -- end of begin-end block of call to procedure which will
             -- build and run the INterMedia query

    end loop;


       for k in 1..p_jair_results_tbl.count loop
         l_results_tbl(k).folder_id := p_jair_results_tbl(k).folder_id;
         l_results_tbl(k).folder_name := p_jair_results_tbl(k).folder_name;
         l_results_tbl(k).folder_description := p_jair_results_tbl(k).folder_description;
         l_results_tbl(k).folder_eul := p_jair_results_tbl(k).folder_eul;
       end loop;


       IF  l_return_status = fnd_api.G_RET_STS_SUCCESS  THEN
          -- First print out the keywords entry box again for future tries
          enter_query_page( p_keywords => p_keywords
                          , p_lang     => p_lang);
          -- Then print out the result set
          results_page( p_results_tbl => p_jair_results_tbl
                      , p_lang        => p_lang);

       END IF;

      -- *********************************************************
   ELSE    -- If no keywords entered in the box<l_length(p_keywords) = 0>
      -- Print out the keywords entry box again for future tries
      enter_query_page( p_keywords, p_lang );
      htp.bodyClose;
      htp.htmlClose;

   END IF;  -- endif for l_length of the keywords entered not equal to zero
   -- *********************************************************


-- END IF;   -- ICX_SEC.validatesession()


EXCEPTION
  WHEN BIS_GNRL_SEARCH_ENGINE_PVT.e_noIndexDefined THEN
    -- The following message need not be translated since this is a propagated error
    -- due to undefined InterMedia domain Index. The Preferences and Indexes must
    -- be created first, for the Business Views Catalog Search region to work !!
    htp.p('<BR><BR>');
    htp.p('ERROR : InterMedia Index Not Created in Language - '||p_lang||'<BR>');
    htp.p('Please run BISPBVI.sql in the Discoverer eul schema with appropriate Language code as parameter.'||'<BR>');
  WHEN OTHERS THEN
    rollback;
    raise;
END  query;


-- **********************************************************
--  Procedure container
--
--
--
--
-- *************************************************************

PROCEDURE Container(
 p_keywords      in  varchar2
,p_lang          in  varchar2
,p_results_tbl  IN  BIS_GNRL_SEARCH_ENGINE_PVT.results_tbl_typ
) is

begin

/*
   -- First print out the keywords entry box again for future tries
   enter_query_page( p_keywords => p_keywords
                   , p_lang     => p_lang);
   -- Then print out the result set
   results_page( p_results_tbl => p_results_tbl
                ,p_lang        => p_lang);
*/

  htp.headopen;
  htp.p('<SCRIPT>');
  icx_admin_sig.help_win_script('ASKORA', null, 'FND');
  htp.p('</SCRIPT>');
  htp.headclose;

  htp.p('<html>');
  htp.p('<head>');
  htp.p('<title>BV Catalog</title>');
  htp.p('</head>');
  htp.p('<body bgcolor="#CCCCCC">');
  htp.p('<FORM TARGET="_top" METHOD=POST>');
--   enter_query_page( p_keywords => p_keywords
--                   , p_lang     => p_lang);
  htp.p('<H3>Hello there</H3>');

  htp.p('</FORM>');
  htp.p('</body>');
  htp.p('</html>');



end Container;

/*************************************************************************************
*************************************************************************************/

function Is_Business_Area_Accessible(
  x_ba_id		number,
  x_apps_user_id		number,
  x_eul			varchar2
) return varchar2 is

pv_ba_total		number;

pv_accessible		varchar2(10);
pv_dc_query 		varchar2(2000);
l_disco_table_version   varchar2(10);
begin

  l_disco_table_version := BIS_GNRL_SEARCH_ENGINE_PVT_OA.get_eul_table_version;
  pv_dc_query := 'select ' ||
                 '       count (distinct ap.gba_ba_id) ' ||
                 '  from ' ||
                   x_eul ||  '.' || l_disco_table_version ||'_bas            ba, ' ||
                   x_eul ||  '.' || l_disco_table_version ||'_access_privs   ap, ' ||
                   x_eul ||  '.' || l_disco_table_version ||'_eul_users      eu, ' ||
                 '           fnd_responsibility_vl  r, ' ||
                 '           fnd_application        a, ' ||
                 '           fnd_user_resp_groups   ur, ' ||
                 '           fnd_user               u, ' ||
                 '           fnd_security_groups_vl s, ' ||
                 '           fnd_data_group_units   dgu, ' ||
                 '           fnd_oracle_userid      ou ' ||
                 ' where ' ||
                 '        ba.ba_id = ap.gba_ba_id and ' ||
                 '        ba.ba_id = :1 and ' ||
                 '        ap.ap_eu_id = eu.eu_id and ' ||
                 '        eu.eu_role_flag = 1 and ' ||
                 '        ap.ap_type = ''GBA'' and ' ||
                 '        ur.responsibility_id = TO_NUMBER(SUBSTR(eu.eu_username,2,(INSTR(eu.eu_username,''#'',2)-2))) and ' ||
                 '        ur.responsibility_application_id = TO_NUMBER(SUBSTR(eu.eu_username,INSTR(eu.eu_username,''#'',2)+1)) and ' ||
                 '        u.user_id = :2 and ' ||
                 '        u.user_id = ur.user_id and ' ||
                 '        (sysdate BETWEEN ur.start_date AND NVL(ur.end_date, sysdate)) and ' ||
                 '        r.application_id    = ur.responsibility_application_id and ' ||
                 '        r.responsibility_id = ur.responsibility_id and ' ||
                 '        (sysdate BETWEEN r.start_date AND NVL(r.end_date, sysdate)) and ' ||
                 '        r.application_id = a.application_id and ' ||
                 '        ur.security_group_id IN (-1, s.security_group_id) and ' ||
                 '        s.security_group_id  >= 0 and ' ||
                 '        r.data_group_id = dgu.data_group_id and ' ||
                 '        r.data_group_application_id = dgu.application_id and ' ||
                 '        dgu.oracle_id = ou.oracle_id';

  EXECUTE IMMEDIATE pv_dc_query INTO pv_ba_total USING x_ba_id, x_apps_user_id;

  if pv_ba_total > 0 then
    pv_accessible := 'Yes';
  else
    pv_accessible := 'No';
  end if;

  return pv_accessible;


EXCEPTION
  WHEN OTHERS then
    return 'No';
    rollback;

end Is_Business_Area_Accessible;

-- ************************************************
-- ************************************************
END  bis_business_views_catalog_oa;





/
