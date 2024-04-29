--------------------------------------------------------
--  DDL for Package Body OKC_WORD_DOWNLOAD_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_WORD_DOWNLOAD_UPLOAD" AS
/* $Header: OKCWDUPB.pls 120.0.12010000.31 2012/12/12 10:36:41 skavutha noship $ */
------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_WORD_DOWNLOAD_UPLOAD';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_LEVEL_STATEMENT            CONSTANT   NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=510; -- OKC Application

  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;


--=========================================================================================
--============================DOWNLOAD PROCEDURES BEGINS===================================
--=========================================================================================
FUNCTION variable_custom_replace(p_source CLOB,l_search_string VARCHAR2,l_replacing_string VARCHAR) RETURN VARCHAR2 AS
l_source CLOB;
l_var_occurance NUMBER := 1;
l_var_start_position NUMBER := -1;
l_var_end_position NUMBER := -1;
l_wt_occurance NUMBER := 1;
l_wt_start_position NUMBER := -1;
l_wt_end_position NUMBER := -1;
l_process_string VARCHAR2(4000);
l_process_string_temp VARCHAR2(4000);
l_var_name VARCHAR2(1000);
BEGIN
    l_source := p_source;
    l_var_start_position := InStr(l_source,'agsfddfsga1',1,l_var_occurance);

    WHILE(l_var_start_position <> 0)
    LOOP
        l_var_end_position := InStr(l_source,'agsfddfsga2',1,l_var_occurance);
        l_process_string_temp := SubStr(l_source,l_var_start_position+11,l_var_end_position-l_var_start_position-11); -- Length(agsfddfsga1) = 11
        l_process_string := '<w:t>' || l_process_string_temp || '</w:t>';

        --forming the actual variable name
        -- start
        l_wt_occurance := 1;
        l_var_name := '';
        l_wt_start_position := InStr(l_process_string,'<w:t>',1,l_wt_occurance);

        WHILE(l_wt_start_position <> 0)
        LOOP
            l_wt_end_position := InStr(l_process_string,'</w:t>',1,l_wt_occurance);
            l_var_name := l_var_name || SubStr(l_process_string,l_wt_start_position+5,l_wt_end_position-l_wt_start_position-5); -- Length('<w:t>') = 5
            l_wt_occurance := l_wt_occurance + 1;
            l_wt_start_position := InStr(l_process_string,'<w:t>',1,l_wt_occurance);
        END LOOP;
        l_source := regexp_replace(l_source,l_process_string_temp,l_var_name);
        -- end

        l_var_occurance := l_var_occurance + 1;
        l_var_start_position := InStr(l_source,'agsfddfsga1',1,l_var_occurance);
    END LOOP;
    RETURN regexp_replace(l_source,l_search_string,l_replacing_string);
END variable_custom_replace;

/*PROCEDURE save_data ()
IS
PRAGMA autonomous_transaction

BEGIN
 INSERT INTO  OKC_WORD_SYNC_T(
                             )
                             VALUES ();
END save_data;        */

PROCEDURE DOWNLOAD_PRE_PROCESSOR (
  p_doc_id                                  NUMBER,
  p_doc_type                                VARCHAR2,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_data                     OUT NOCOPY VARCHAR2
) AS
  l_api_name 		VARCHAR2(30) := 'DOWNLOAD_PRE_PROCESSOR';
	p_document_xml           CLOB;
	l_doc_clob               CLOB;
	l_doc_XML                XMLType;
	l_art_XML                XMLType;
	l_xpath_clause_elem      VARCHAR2(1000);
	l_xpath_temp	           VARCHAR2(1000);

	l_i			 NUMBER := 1;

	l_progress VARCHAR2(3) := '000';

	BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'DOWNLOAD_PRE_PROCESSOR');
  END IF;

  -------------------------------------
  -- Get the XML from the table.
  -------------------------------------
  select blob_to_clob(blob_data)
   into p_document_xml
   from OKC_WORD_SYNC_T
   WHERE id = 1
   AND doc_id = p_doc_id
   AND doc_type = p_doc_type;

   l_progress := 010;

  p_document_xml := regexp_replace(p_document_xml,'&','~');
  l_doc_xml  := xmltype(p_document_xml);

  --Initialize the xpaths
	l_xpath_clause_elem := '//SectionsArticlesToPrintVORow['||to_char(l_i)||']';

	 while ((l_doc_xml.existsnode(l_xpath_clause_elem) > 0)) LOOP

		 l_xpath_temp := l_xpath_clause_elem||'/ArticleText[1]//*[name()="var"]';

		 if (l_doc_xml.extract(l_xpath_temp) IS NOT NULL)  then
		     l_art_XML := l_doc_xml.extract(l_xpath_temp);
		     l_xpath_temp := l_xpath_clause_elem||'/ArticleText[1]';
         l_art_xml := xmltype('<ArticleText>'||l_art_xml.getClobVal()||'</ArticleText>');
		     select updateXML(l_doc_xml,l_xpath_temp,l_art_xml) into l_doc_xml FROM dual;
       /*ELSE
         l_xpath_temp := l_xpath_clause_elem||'/ArticleText[1]';
         select updateXML(l_doc_xml,l_xpath_temp,'<ArticleText><p>##ARTICLEWML##</p></ArticleText>') into l_doc_xml FROM dual;
       */
		 end if;
		 l_i := l_i+1;
		 l_xpath_clause_elem := '//SectionsArticlesToPrintVORow['||to_char(l_i)||']';
	  end loop;

      l_progress := 020;

     SELECT updateXML( l_doc_xml
                       ,'//ArticleText[not(.//var)]','<ArticleText><p>##ARTICLEWML##</p></ArticleText>'
                       ).getClobVal()

      INTO l_doc_clob
      FROM dual;

     l_doc_clob := regexp_replace(l_doc_clob,'~','&');

     l_progress := 030;

     UPDATE OKC_WORD_SYNC_T
     SET blob_data = clob_to_blob(l_doc_clob)
     WHERE id = 1
     AND doc_id  = p_doc_id
     AND  doc_type = p_doc_type;


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'DOWNLOAD_PRE_PROCESSOR');
  END IF;
  x_return_status := G_RET_STS_SUCCESS;
  x_msg_data      := NULL;
EXCEPTION WHEN OTHERS THEN
  x_return_status := G_RET_STS_ERROR;
  x_msg_data      := SQLCODE||' -ERROR- '||SQLERRM ;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'DOWNLOAD_PRE_PROCESSOR');

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception - at ' || l_progress );

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception  ' || SQLERRM );
  END IF;
END DOWNLOAD_PRE_PROCESSOR;




PROCEDURE DOWNLOAD_POST_PROCESSOR(
      p_doc_id                     NUMBER,
      p_doc_type                   VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_data        OUT NOCOPY VARCHAR2) AS

 l_api_name   VARCHAR2(30) := 'DOWNLOAD_POST_PROCESSOR';
 p_document_xml           CLOB;
 l_doc_clob               CLOB;
 l_doc_XML                XMLType;
 l_art_XML                XMLType;
 l_var_XML                XMLType;--Contains all variables in doc xml
 l_xpath_clause_elem      VARCHAR2(1000);
 l_xpath_temp             VARCHAR2(1000);
 l_clob_temp              CLOB;
 l_i    NUMBER := 1;

 l_article_id             NUMBER ;
 l_list_prefix            NUMBER;

 l_list_clob              CLOB; --Added for Download Perf Improvement Fix.

 l_doc_listdef_clob  CLOB ;
 l_doc_list_clob  CLOB ;

 TYPE l_art_body_tbl_type IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
 l_art_body_tbl  l_art_body_tbl_type;

 l_listdefCount number;
 l_listilfocount number;

 l_doc_xml_upd XMLType;

 l_clause_temp CLOB;

 n number;
 l_result clob ;
 l_result2 CLOB;

 -- parameters for fix for insert by reference clauses
 l_insert_by_reference VARCHAR2(1);
 l_reference_text VARCHAR2(2000);
 l_article_text_in_word  BLOB;

 -- Added for Code Hook
 l_return_status                 VARCHAR2(1);
 l_msg_count                     NUMBER;
 l_msg_data                      VARCHAR2(2000);

 l_progress VARCHAR2(3) := '000';

 BEGIN

  l_progress := '010';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'DOWNLOAD_POST_PROCESSOR');
  END IF;

   -- Get the Document XML
  select blob_to_clob(blob_data) into p_document_xml from OKC_WORD_SYNC_T WHERE id = 1 and doc_id = p_doc_id AND doc_type = p_doc_type;

  l_progress := '020';

   -- Replace w:list with wlist
   l_doc_clob := regexp_replace(p_document_xml,'w:list','wlist');

  -- Convert the clob into XML for XML Processing
  l_doc_xml := XMLType(l_doc_clob);

  --Initialize the xpaths
  l_xpath_clause_elem := '//ClauseTag['||to_char(l_i)||']';

   l_progress := '030';
   while ((l_doc_xml.existsnode(l_xpath_clause_elem) > 0))
      LOOP

       -- Get the Cat ID (OKC_K_ARTICLES_B.ID)
       l_article_id := l_doc_xml.extract(l_xpath_clause_elem||'/@CatId').getNumberVal();

       --Get Article sub elements
       l_var_XML := Xmltype('<DUMMYTAG>'||l_doc_xml.extract(l_xpath_clause_elem||'/ArticleText[1]/*').getClobVal()||'</DUMMYTAG>');

       l_progress := '040';
       --Get the clause text from individual clauses Word doc.
       select VER.INSERT_BY_REFERENCE,VER.REFERENCE_TEXT,VER.article_text_in_word
        into l_insert_by_reference,l_reference_text,l_article_text_in_word
        from  okc_article_versions VER,okc_k_articles_b ART
        where ART.id = l_article_id
        and   VER.article_id = ART.sav_sae_id
        and   VER.article_version_id = ART.article_version_id;
        l_clob_temp := okc_word_download_upload.get_article_body(l_article_text_in_word);
      IF l_insert_by_reference = 'Y' then
          l_clob_temp := to_clob('<SOMETAG><wbody><w:p xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"><w:r><w:t>' || l_reference_text || '</w:t></w:r></w:p></wbody></SOMETAG>');
      ELSE
          l_clob_temp := okc_word_download_upload.get_article_body(l_article_text_in_word);
      END IF;

                      --make the list related attributes as unique by appending the position no
                       --w:listDefId="[[:digit:]]{1}" ,w:ilfo="[[:digit:]]{1}",w:ilst w:val="[[:digit:]]{1}" & w:ilfo w:val="[[:digit:]]{1}"
                       if (xmltype(l_clob_temp).existsnode('/SOMETAG/wlists') > 0) then
                          l_list_prefix := l_i+1000;
                          --Remove previously added prefix.
                          /*l_clob_temp := regexp_replace(l_clob_temp,'w:listDefId="([[:digit:]]{4})','w:listDefId="');
                          l_clob_temp := regexp_replace(l_clob_temp,'w:ilfo="([[:digit:]]{4})','w:ilfo="');
                          l_clob_temp := regexp_replace(l_clob_temp,'w:ilst w:val="([[:digit:]]{4})','w:ilst w:val="');
                          l_clob_temp := regexp_replace(l_clob_temp,'w:ilfo w:val="([[:digit:]]{4})','w:ilfo w:val="');*/

                          l_clob_temp := regexp_replace(l_clob_temp,'wlistDefId="([[:digit:]]{1})','wlistDefId="'||to_char(l_list_prefix)||'\1');
                          l_clob_temp := regexp_replace(l_clob_temp,'w:ilfo="([[:digit:]]{1})','w:ilfo="'||to_char(l_list_prefix)||'\1');
                          l_clob_temp := regexp_replace(l_clob_temp,'w:ilst w:val="([[:digit:]]{1})','w:ilst w:val="'||to_char(l_list_prefix)||'\1');
                          l_clob_temp := regexp_replace(l_clob_temp,'w:ilfo w:val="([[:digit:]]{1})','w:ilfo w:val="'||to_char(l_list_prefix)||'\1');
                       end if;

        -- Get the article Body text
        l_art_XML := xmltype(l_clob_temp).extract('/SOMETAG/wbody/*');

        l_progress := '050';
        -- Resolve the Variables
        l_art_XML := OKC_WORD_DOWNLOAD_UPLOAD.resolve_variables_download(l_art_XML,l_var_XML);
        -- Store the resolved clause in a pl/sql table.
        l_art_body_tbl(l_i) := '<ArticleText>'||l_art_XML.getClobVal()||'</ArticleText>';


         if (xmltype(l_clob_temp).existsnode('//wlists') > 0) then

           select deleteXML(XMLType(l_clob_temp),'//wlistDef//wlsid').getClobVal() into l_clob_temp from dual;
           l_doc_listdef_clob := l_doc_listdef_clob || xmltype(l_clob_temp).extract('//wlistDef').getClobVal();
           l_doc_list_clob := l_doc_list_clob || xmltype(l_clob_temp).extract('//wlist').getClobVal();

        end if;

         l_i := l_i+1;
         l_xpath_clause_elem := '//ClauseTag['||to_char(l_i)||']';
     end loop;

      l_progress := '060';
      SELECT deleteXML( l_doc_xml
                       ,'//ClauseTag/*'
                      )
       INTO  l_doc_xml
      FROM dual;


      l_progress := '070';
      -- Clause Processing    --serukull changes
      FOR i IN 1..l_i-1
      LOOP
          l_doc_xml := XMLtype.appendChildXML(l_doc_xml,'//ClauseTag['||to_char(i)||']',XMLTYPe(l_art_body_tbl(i)));
      END LOOP;
          l_doc_clob := l_doc_xml.getClobVal();

      l_progress := '80';

     l_doc_clob := regexp_replace(l_doc_clob,'</w:styles>','<w:style w:type="table" w:styleId="TableGrid"><w:name w:val="Table Grid"/><w:rsid w:val="00DF2472"/><w:rPr><wx:font wx:val="Times"/><w:lang w:val="EN-US" w:fareast="EN-US" w:bidi="AR-SA"/>
     </w:rPr><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/><w:left w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/><w:bottom w:val="single"
     w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/><w:right w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/><w:insideH w:val="single" w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/><w:insideV w:val="single"
     w:sz="4" wx:bdrwidth="10" w:space="0" w:color="auto"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
     </w:styles>');

     l_progress := '090';
     l_listdefCount :=  l_doc_xml.extract('//wlistDef[position()=last()]/@wlistDefId').getNumberVal();
     l_listilfocount := l_doc_xml.extract('//wlist[position()=last()]/@w:ilfo','xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"').getNumberVal();

     l_progress := '100';
      -- List processing start   --serukull changes
     n := dbms_lob.instr( l_doc_clob,'</wlistDef>',1,(l_listdefCount+1));
     n := n+12;

     if ( nvl(n,0) > 12 AND  Nvl(dbms_lob.getlength(l_doc_listdef_clob),0) > 0 )
      THEN
         dbms_lob.createtemporary(l_result, false, dbms_lob.call);
         dbms_lob.copy(l_result, l_doc_clob, n - 1, 1, 1);
         dbms_lob.copy(l_result,
                          l_doc_listdef_clob,
                          dbms_lob.getlength(l_doc_listdef_clob) ,
                          dbms_lob.getlength(l_result) + 1,
                          1 );
         dbms_lob.copy(l_result,
                          l_doc_clob,
                          dbms_lob.getlength(l_doc_clob) - (n + length('</wlistDef>')) + 1 ,
                          dbms_lob.getlength(l_result) + 1,
                          n + length('</wlistDef>') );

      l_doc_clob := l_result;
      DBMS_LOB.FREETEMPORARY(l_result);
      end if;
     -- ListDef added

     l_progress := '110';

     -- Add wlists    --serukull changes Perf Fix
     n := dbms_lob.instr( l_doc_clob,'</wlist>',1,l_listilfoCount);
     n := n+8;
      if ( nvl(n,0) > 8 AND  Nvl(dbms_lob.getlength(l_doc_list_clob),0) > 0 )
      THEN
         dbms_lob.createtemporary(l_result2, false, dbms_lob.call);
         dbms_lob.copy(l_result2, l_doc_clob, n - 1, 1, 1);
         dbms_lob.copy(l_result2,
                          l_doc_list_clob,
                          dbms_lob.getlength(l_doc_list_clob) ,
                          dbms_lob.getlength(l_result2) + 1,
                          1 );
          dbms_lob.copy(l_result2,
                          l_doc_clob,
                          dbms_lob.getlength(l_doc_clob) - (n + length('</wlist>')) + 1 ,
                          dbms_lob.getlength(l_result2) + 1,
                          n + length('</wlist>') );
        l_doc_clob := l_result2;
        DBMS_LOB.FREETEMPORARY(l_result2);
       end if;


      l_doc_clob := regexp_replace(regexp_replace(regexp_replace(regexp_replace(l_doc_clob,'wbody','w:body'),'',
                   ' '),'wlist','w:list'),'<w:t/>','<w:t> </w:t>');

      l_progress := '120';
      -- Encoding Fix
      l_doc_clob := change_encoding(l_doc_clob);

      l_progress := '130';
      -- CALL to Code hook for further processing
      OKC_WORD_SYNC_HOOK.DOWNLOAD_CONTRACT_EXT(
         	p_doc_type                    =>  p_doc_type,
    	  	p_doc_id                      =>  p_doc_id,
          p_init_msg_list               =>  FND_API.G_FALSE,
          x_contract_xml                =>  l_doc_clob,
    		  x_return_status               =>  l_return_status,
    		  x_msg_count                   =>  l_msg_count,
	    	  x_msg_data                    =>  l_msg_data
                                          );
     IF l_return_status <> G_RET_STS_SUCCESS THEN
        raise_application_error(-20101, 'Error in OKC_WORD_SYNC_HOOK.DOWNLOAD_CONTRACT_EXT',TRUE);
     END IF;
    -- code to remove custom tags - start
    select updateXML(xmltype(l_doc_clob),
                      '//SectionTag/@*','',
                      '//ClauseTag/@*','',
                      '//var/@*',''
                      ).getClobVal() into l_doc_clob from dual;
    l_doc_clob :=  regexp_replace(l_doc_clob,'<(/)*((SectionsArticlesToPrintVORow)|(TocTag)|(PageHeading)|(SignatureTag)|(LabelTitleTag)|(ArticleText)|(var)|(ClauseTag)|((SectionTag)))[^>.]*>','');

    -- code to remove custom tags - end


     l_progress := '140';
     UPDATE OKC_WORD_SYNC_T
     SET blob_data = clob_to_blob(l_doc_clob)
     WHERE id = 1
     and doc_id  = p_doc_id
     AND doc_type  = p_doc_type;


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'DOWNLOAD_POST_PROCESSOR');
  END IF;
  x_return_status := G_RET_STS_SUCCESS;
  x_msg_data      := NULL;

EXCEPTION WHEN OTHERS THEN

  x_return_status := G_RET_STS_ERROR;
  x_msg_data      := SQLCODE||' -ERROR- '||SQLERRM ;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'DOWNLOAD_POST_PROCESSOR');

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                     G_MODULE||l_api_name,
                    ' Exception - at' || l_progress);

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                     G_MODULE||l_api_name,
                    ' Exception - ' || SQLERRM);
  END IF;
END DOWNLOAD_POST_PROCESSOR;



FUNCTION get_article_body(p_text_in_word IN BLOB) RETURN CLOB IS
  l_api_name 		VARCHAR2(30) := 'get_article_body';
  v_clob    CLOB; --Terms
  v_varchar VARCHAR2(32767);
  v_start	 PLS_INTEGER := 1;
  v_buffer  PLS_INTEGER := 32767;
  l_xpath VARCHAR2(1000);

BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'get_article_body');
  END IF;

     DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

     FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(p_text_in_word) / v_buffer) LOOP
	   v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(p_text_in_word, v_buffer, v_start));
	   DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
	   v_start := v_start + v_buffer;
     END LOOP;


	v_clob := regexp_replace(regexp_replace(regexp_replace(v_clob,'w:body','wbody'),'w:list','wlist'),'w:lvlPicBulletId','wlvlPicBulletId');
	v_clob := '<SOMETAG>'||xmltype(v_clob).extract('//wbody|//wlists').getClobVal()||'</SOMETAG>';
	select deleteXML(XMLType(v_clob),'//wlvlPicBulletId').getClobVal() into v_clob from dual;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'get_article_body');
  END IF;

	RETURN v_clob;

EXCEPTION WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'get_article_body');
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception - ' || SQLERRM);
  END IF;

END get_article_body;



--=========================================================================================
--==============================UPLOAD PROCEDURES BEGINS===================================
--=========================================================================================


 PROCEDURE  UPLOAD_PRE_PROCESSOR(p_doc_id NUMBER,p_doc_type VARCHAR2, p_cust_tag_exists IN VARCHAR2 DEFAULT 'Y',
   x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_data                     OUT NOCOPY VARCHAR2

 ) IS
l_api_name 		VARCHAR2(30) := 'UPLOAD_PRE_PROCESSOR';
l_doc_clob CLOB;
l_doc_clob1 CLOB;
l_doc_blob BLOB;
l_doc_xml XMLType;
l_doc_xml_temp  XMLType;
l_doc_placeholder_xml XMLType;
l_dummy_article_text XMLType;

TYPE id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
cat_id_tbl  id_tbl_type;
cat_id1_tbl  id_tbl_type;
id_tbl  id_tbl_type;

TYPE CLOB_TBL_TYPE IS TABLE OF CLOB INDEX BY BINARY_INTEGER;
ART_CLOB_TBL CLOB_TBL_TYPE;

l_art_CLOB CLOB;

l_temp_clob CLOB;
l_start_string NUMBER;
l_end_string NUMBER;
l_encoding VARCHAR2(100);

CURSOR c_mod_encoding IS
SELECT id,blob_data
FROM okc_word_sync_t
WHERE doc_id = p_doc_id
AND   doc_type = p_doc_type
AND   cat_id IS NOT NULL;

l_i NUMBER := 1;

l_progress VARCHAR2(3) := '000';

BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'UPLOAD_PRE_PROCESSOR');
  END IF;

-- Get the document data from okc_word_sync_t
l_progress := '010';
select blob_data into l_doc_blob from okc_word_sync_t where id = 1 and doc_id = p_doc_id and doc_type = p_doc_type;

-- convert the document to clob
l_progress := '020';
l_doc_clob := okc_word_download_upload.blob_to_clob(l_doc_blob);

-- change_encoding
l_progress := '030';
l_doc_clob := change_encoding(l_doc_clob);

-- convert the document to XMLType
l_progress := '040';
l_doc_xml := xmltype(regexp_replace(l_doc_clob,'w:body','wbody'));

-- Get the place holder xml which is used for adding clause text
l_progress := '050';
INSERT INTO okc_word_sync_t (id,doc_id,doc_type,CLOB_data)
select 10,p_doc_id,p_doc_type, deleteXML(l_doc_xml,'//wbody/*').getclobVal()
from dual;


l_doc_xml_temp :=  XmlType('<wbody>'||l_doc_xml.extract('//wbody[1]/*').getClobVal()||'</wbody>');


-- Build Article CLOBs From the Uploaded Document
l_progress := '060';
WHILE l_doc_xml.Existsnode('//ClauseTag['||To_Char(l_i)||']') > 0
 LOOP
  ID_TBL(l_i) := l_i+100;
  CAT_ID_TBL(l_i) := l_doc_xml_temp.Extract('//ClauseTag['||To_Char(l_i)||']/@CatId').getNumberVal();
  ART_CLOB_TBL(l_i) := '<wbody>'||l_doc_xml_temp.Extract('//ClauseTag['||To_Char(l_i)||']/ArticleText[1]/*').getClobVal()||'</wbody>';
  --ART_CLOB_TBL(l_i) :=  XMLType.appendChildXML(l_doc_placeholder_xml,'//wbody', l_doc_xml.Extract('//ClauseTag['||To_Char(l_i)||']/ArticleText[1]/*')).GetClobVal();

  IF (XMLType(ART_CLOB_TBL(l_i)).existsnode('//var')>0) THEN
   l_progress := '070';
   ART_CLOB_TBL(l_i)      := OKC_WORD_DOWNLOAD_UPLOAD.resolve_variables_upload(ART_CLOB_TBL(l_i));
  END IF;
       ART_CLOB_TBL(l_i) := regexp_replace(regexp_replace(ART_CLOB_TBL(l_i),'wbody','w:body'),'<w:t/>','<w:t> </w:t>');
  l_i := l_i+1;
 END LOOP;


-- Insert the Articles into okc_word_sync_t
l_progress := '080';
FORALL i IN  CAT_ID_TBL.first..CAT_ID_TBL.last
INSERT INTO okc_word_sync_t (id,doc_id,doc_type,cat_id,action,CLOB_data)
VALUES (id_TBL(i),p_doc_id,p_doc_type,CAT_ID_TBL(i),'NONE',ART_CLOB_TBL(i));

--Mark new clauses...
l_progress := '090';
UPDATE OKC_WORD_SYNC_T t0
SET    ACTION = 'ADDED'
       --cat_id = NULL
WHERE  t0.doc_id  = p_doc_id
AND    t0.doc_type  = p_doc_type
AND ( cat_id = 0 OR
          EXISTS (select 1 from OKC_WORD_SYNC_T t1
               where  t1.doc_id  = p_doc_id
               and    t1.doc_type  = p_doc_type
               and    t0.cat_id = t1.cat_id
               and    t1.id < t0.id)
               );

-- Compare clauses..
l_progress := '100';

SELECT art.id
BULK COLLECT INTO  cat_id1_tbl
From  okc_article_versions VER,okc_k_articles_b ART,okc_word_sync_t   st
WHERE  st.doc_id    = p_doc_id
 AND   st.doc_type =  p_doc_type
 AND   st.action <> 'ADDED'
 AND   ART.id =  st.cat_id
 and   VER.article_id = ART.sav_sae_id
 and   VER.article_version_id = ART.article_version_id
 AND   Dbms_Lob.compare(okc_word_download_upload.get_articleWML_Text(VER.article_text_in_word),okc_word_download_upload.get_articleWML_Text(st.CLOB_data)) <> 0;

-- Mark the Clauses as 'UPDATED'
l_progress := '110';
IF cat_id1_tbl.Count>0 THEN
FORALL i IN cat_id1_tbl.first..cat_id1_tbl.last
UPDATE okc_word_sync_t
SET  action = 'UPDATED'
WHERE  doc_id    = p_doc_id
AND    doc_type =  p_doc_type
AND    action <> 'ADDED'
AND    cat_id=cat_id1_tbl(i);
END IF;
-- Replace the Article Text with Dummy ARTWML so that the Java Layer Processing becomes lighter.
l_progress := '120';
l_dummy_article_text := XMLType('<ArticleText><agsfddfsgap><agsfddfsgar><agsfddfsgat>##ARTICLEWML##</agsfddfsgat></agsfddfsgar></agsfddfsgap></ArticleText>');
SELECT UpdateXML(l_doc_xml,
                 '//ArticleText', l_dummy_article_text
                 )INTO l_doc_xml FROM dual;
l_doc_clob:= regexp_replace(regexp_replace(l_doc_xml.getClobVal(),'agsfddfsga','w:'),'wbody','w:body');

-- Insert the document into okc_word_sync_t
l_progress := '130';
insert into okc_word_sync_t(id,doc_id,doc_type,blob_data) values(2,p_doc_id,p_doc_type,okc_word_download_upload.clob_to_blob(l_doc_clob));
 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'UPLOAD_PRE_PROCESSOR');
 END IF;

x_return_status := G_RET_STS_SUCCESS;
x_msg_data      := NULL;

 EXCEPTION WHEN OTHERS THEN

  x_return_status := G_RET_STS_ERROR;
  x_msg_data      := SQLCODE||' -ERROR- '||SQLERRM ;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'UPLOAD_PRE_PROCESSOR');

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception at - '||l_progress);
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception   '|| SQLERRM);

  END IF;
END UPLOAD_PRE_PROCESSOR;

/****
 * THIS FUNCTION IS NOT BEING CALLED FROM ANY WHERE
 */
FUNCTION UPLOAD_POST_PROCESSOR(p_doc_id NUMBER,p_doc_type VARCHAR2,p_cat_id NUMBER) return BLOB AS
 l_api_name 		VARCHAR2(30) := 'UPLOAD_POST_PROCESSOR';
 l_doc_clob    CLOB;
 l_art_clob    CLOB;
 l_clob_temp   CLOB;
 l_art_XML     XMLType;
 l_art_blob    BLOB;
 l_i               NUMBER := 1;
 l_i_var           NUMBER := 1;
 l_xpath       VARCHAR2(100);
 l_xpath1      VARCHAR2(100);
 l_xpath2      VARCHAR2(100);

 l_clause_id   NUMBER;
 l_wml_to_html XMLType;
 t_xml         XMLType;


 CURSOR get_doc_data is
 SELECT OKC_WORD_DOWNLOAD_UPLOAD.blob_to_clob(FILE_DATA)
 FROM OKC_REVIEW_UPLD_HEADER
 WHERE (DOCUMENT_TYPE,DOCUMENT_ID) IN (SELECT DOCUMENT_TYPE,DOCUMENT_ID
                                       FROM OKC_K_ARTICLES_B
                                       WHERE ID  = p_cat_id);


 BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'UPLOAD_POST_PROCESSOR');
  END IF;


 l_art_clob := '##ARTICLEWML##';

   DBMS_LOB.CREATETEMPORARY(l_doc_clob, TRUE);

   BEGIN

   OPEN get_doc_data;
   FETCH get_doc_data INTO l_doc_clob;
   IF get_doc_data%NOTFOUND THEN
       SELECT OKC_WORD_DOWNLOAD_UPLOAD.blob_to_clob(blob_data) INTO l_doc_clob FROM OKC_WORD_SYNC_T WHERE id = 1 AND doc_id = p_doc_id AND doc_type = p_doc_type;
   END IF;
   CLOSE get_doc_data;

    l_doc_clob := regexp_replace(l_doc_clob,'w:body','wbody');
    l_xpath  := '//ClauseTag['||to_char(l_i)||']';
    l_xpath1 := '//ClauseTag['||to_char(l_i)||']/ArticleText[1]/*';
    l_xpath2 := '//ClauseTag['||to_char(l_i)||']/@CatId';

    select deleteXML(xmltype(l_doc_clob),'//wbody/*').getClobVal() into l_clob_temp from dual;

    while ((xmltype(l_doc_clob).existsnode(l_xpath) > 0)) LOOP

        IF (xmltype(l_doc_clob).extract(l_xpath2).getNumberVal() = p_cat_id) THEN
            l_art_XML := xmltype(l_doc_clob).extract(l_xpath1);
            l_art_CLOB := xmltype.appendChildXML(xmltype(l_clob_temp),'//wbody',l_art_XML).getClobVal();
           EXIT;
       END IF;

    l_i := l_i+1;
    l_xpath := '//ClauseTag['||to_char(l_i)||']';
    l_xpath1 := '//ClauseTag['||to_char(l_i)||']/ArticleText[1]/*';
    l_xpath2 := '//ClauseTag['||to_char(l_i)||']/@CatId';

    END LOOP;

    --Replace Variable Tags..
   --while ((xmltype(l_art_CLOB).existsnode('//var[1]') > 0)) LOOP
      --l_clob_temp :='<DUMMY>[@'||xmltype(l_art_CLOB).extract('//var[1]/@meaning').getClobVal()||'@]</DUMMY>';
     --select updateXML(xmltype(l_art_CLOB),'//var[1]',xmltype(l_clob_temp).extract('/DUMMY/*')).getClobVal() into l_art_CLOB from dual;
    -- select updateXML(xmltype(l_art_CLOB),'//var','<w#r><w#t>[@State of Jurisdiction@]</w#t></w#r>').getClobVal() into l_art_CLOB from dual;
    --l_art_clob :=  regexp_replace(l_art_clob,'w#','w:');
    --END LOOP;
    --l_art_CLOB := regexp_replace(regexp_replace(l_art_CLOB,'<var name="[0-9,a-z,A-Z,_,$]*" type="[A-Z]*" meaning="','[@'),'"/>','@]');


    l_art_CLOB := resolve_variables_upload(l_art_CLOB);


    l_art_CLOB := regexp_replace(regexp_replace(l_art_CLOB,'wbody','w:body'),'<w:t/>','<w:t> </w:t>');


  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'UPLOAD_POST_PROCESSOR');
  END IF;

    return OKC_WORD_DOWNLOAD_UPLOAD.clob_to_blob(l_art_clob);

   END;

  EXCEPTION WHEN OTHERS THEN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'UPLOAD_POST_PROCESSOR');
  END IF;

 return OKC_WORD_DOWNLOAD_UPLOAD.clob_to_blob(l_art_clob);

 END UPLOAD_POST_PROCESSOR;


--=========================================================================================
--==============================UTILITY PROCEDURES BEGINS===================================
--=========================================================================================


FUNCTION BLOB_TO_CLOB(p_text_in_word IN BLOB) RETURN CLOB
IS

  l_api_name 		VARCHAR2(30) := 'BLOB_TO_CLOB';
  v_clob    CLOB; --Terms
  v_varchar VARCHAR2(32767);
  v_start	 PLS_INTEGER := 1;
  v_buffer  PLS_INTEGER := 32767;
  l_xpath VARCHAR2(1000);

BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'BLOB_TO_CLOB');
  END IF;

     DBMS_LOB.CREATETEMPORARY(v_clob, TRUE);

  FOR i IN 1..CEIL(DBMS_LOB.GETLENGTH(p_text_in_word) / v_buffer) LOOP
	v_varchar := UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(p_text_in_word, v_buffer, v_start));
	DBMS_LOB.WRITEAPPEND(v_clob, LENGTH(v_varchar), v_varchar);
	v_start := v_start + v_buffer;
  END LOOP;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'BLOB_TO_CLOB');
  END IF;


  RETURN v_clob;
EXCEPTION WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'BLOB_TO_CLOB');
  END IF;
END BLOB_TO_CLOB;





FUNCTION Clob_to_blob(p_clob IN CLOB) return BLOB AS
  l_api_name 		VARCHAR2(30) := 'Clob_to_blob';
 l_art_blob BLOB;
 v_in Pls_Integer := 1;
 v_out Pls_Integer := 1;
 v_lang Pls_Integer := 0;
 v_warning Pls_Integer := 0;
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||'Clob_to_blob');
  END IF;

  DBMS_LOB.CREATETEMPORARY(l_art_blob, FALSE);

  DBMS_LOB.convertToBlob(l_art_blob,p_clob,DBMS_lob.getlength(p_clob),
                           v_in,v_out,DBMS_LOB.default_csid,v_lang,v_warning);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Leaving '||G_PKG_NAME ||'.'||'Clob_to_blob');
  END IF;

  return l_art_blob;
  EXCEPTION WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||l_api_name,
                    '100: Exception in '||G_PKG_NAME ||'.'||'Clob_to_blob');
  END IF;

END Clob_to_blob;


FUNCTION GET_WORD_SYNC_PROFILE RETURN VARCHAR2 IS
PROF_VALUE VARCHAR2(1);
BEGIN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||'GET_WORD_SYNC_PROFILE',
                    '100: Entered '||G_PKG_NAME ||'.'||'GET_WORD_SYNC_PROFILE');
  END IF;
SELECT FND_PROFILE.VALUE('OKC_WORD_SYNC_ART_EDIT') INTO PROF_VALUE FROM DUAL;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||'GET_WORD_SYNC_PROFILE',
                    '100: Leaving '||G_PKG_NAME ||'.'||'GET_WORD_SYNC_PROFILE');
  END IF;
RETURN PROF_VALUE;
END GET_WORD_SYNC_PROFILE;



PROCEDURE INSERT_WML_TEXT(p_article_version_id NUMBER, p_article_text_in_word BLOB) IS
BEGIN
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||'INSERT_WML_TEXT',
                    '100: Entered '||G_PKG_NAME ||'.'||'INSERT_WML_TEXT');
  END IF;
UPDATE okc_article_versions
SET article_text_in_word = p_article_text_in_word,
    edited_in_word       = 'Y'
WHERE article_version_id = p_article_version_id;
  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||'INSERT_WML_TEXT',
                    '100: Leaving '||G_PKG_NAME ||'.'||'INSERT_WML_TEXT');
  END IF;
END INSERT_WML_TEXT;



FUNCTION resolve_variables_download(p_art_XML XMLType,p_var_XML XMLType) RETURN XMLType IS
l_art_XML XMLType;
l_art_clob CLOB;
l_xpath VARCHAR2(1000);
l_repl_str VARCHAR2(2000);
l_var_str VARCHAR2(2000);
l_var_clob clob;
l_i NUMBER := 1;

l_xpath1 VARCHAR2(1000);
l_var_type VARCHAR2(1);
BEGIN
    l_art_CLOB := p_art_XML.getClobVal();
    l_art_CLOB := regexp_replace(l_art_CLOB,'[[]','agsfddfsga1');
    l_art_CLOB := regexp_replace(l_art_CLOB,'[]]','agsfddfsga2');
    --l_art_CLOB := regexp_replace(regexp_replace(l_art_CLOB,'agsfddfsga1@','</w:t></w:r><var name="'),'@agsfddfsga2','" /><w:r><w:t>');

    l_xpath := '//var['||to_char(l_i)||']';

    while (p_var_XML.existsnode(l_xpath) > 0) LOOP

      l_xpath :=  '//var['||to_char(l_i)||']/@meaning';
      l_repl_str := 'agsfddfsga1@'||p_var_XML.extract(l_xpath).getStringVal()||'@agsfddfsga2';
      l_xpath :=  '//var['||to_char(l_i)||']';
      l_xpath1 :=  '//var['||to_char(l_i)||']/@type';
      l_var_type := p_var_XML.extract(l_xpath1).getStringVal();
      IF l_var_type = 'D' THEN
--      l_var_clob := p_var_XML.extract(l_xpath).getClobVal();
      --l_var_clob := '</w:t></w:r></w:p>'||p_var_XML.extract(l_xpath).getClobVal()||'<w:p><w:r><w:t>';
--      l_art_CLOB := regexp_replace(l_art_CLOB,l_repl_str,l_var_clob);
        l_art_clob := p_var_XML.extract(l_xpath).getClobVal();
      ELSE
      l_var_str := '</w:t></w:r>'||p_var_XML.extract(l_xpath).getStringVal()||'<w:r><w:t>';
      l_art_CLOB := variable_custom_replace(l_art_CLOB,l_repl_str,l_var_str);
      END IF;

      l_i := l_i +1;
     l_xpath := '//var['||to_char(l_i)||']';
    end loop;
      l_art_clob := '<DUMMY>'||l_art_CLOB||'</DUMMY>';
	  l_art_clob := regexp_replace(l_art_clob,'agsfddfsga1','[');
	  l_art_clob := regexp_replace(l_art_clob,'agsfddfsga2',']');
    l_art_XML := XMLType(l_art_clob).extract('/DUMMY/*');
    return l_art_XML;

END resolve_variables_download;


FUNCTION resolve_variables_upload(p_art_CLOB CLOB) RETURN CLOB IS
l_art_XML XMLType;
l_var_XML XMLType;
l_art_clob CLOB := p_art_CLOB;
l_xpath VARCHAR2(1000);
l_repl_str VARCHAR2(2000);
l_var_str VARCHAR2(2000);
l_i NUMBER := 1;

l_xpath1 VARCHAR2(1000);
l_var_type VARCHAR2(1);
BEGIN

    IF (XMLType(l_art_clob).existsnode('//var')>0) THEN
    l_art_XML := XMLType(l_art_clob);
    l_art_clob := '<DUMMY>'||l_art_XML.extract('//var').getClobVal()||'</DUMMY>';
    l_var_XML := XMLType(l_art_clob);

    l_xpath := '//var['||to_char(l_i)||']';
    l_xpath1 :=  '//var['||to_char(l_i)||']/@type';

    while (l_var_XML.existsnode(l_xpath) > 0) LOOP
      l_xpath := '//var['||to_char(l_i)||']/@meaning';
      l_var_str := l_var_XML.extract(l_xpath).getStringVal();
      l_xpath :=  '//var[@meaning="'||l_var_str||'"]';
      l_var_type := l_var_XML.extract(l_xpath1).getStringVal();
      IF l_var_type = 'D' THEN
       l_var_str := '<DUMMY><agsfddfsgap><agsfddfsgar><agsfddfsgat>[@'||l_var_str||'@]</agsfddfsgat></agsfddfsgar></agsfddfsgap></DUMMY>';
      ELSE
      l_var_str := '<DUMMY><agsfddfsgar><agsfddfsgat>[@'||l_var_str||'@]</agsfddfsgat></agsfddfsgar></DUMMY>';
      END IF;
      SELECT updateXML( l_art_XML,l_xpath,xmltype(l_var_str).extract('/DUMMY/*')) INTO l_art_XML FROM dual;
      l_i := l_i +1;
      l_xpath := '//var['||to_char(l_i)||']';
    end loop;
     l_art_clob:= regexp_replace(l_art_XML.getClobVal(),'agsfddfsga','w:');
    END IF;
    return l_art_clob;
END resolve_variables_upload;



procedure strip_tags (p_doc_id number, p_doc_type varchar2)  is
pos1 number;
pos2 number;
len number;
html_clob clob;
stripped_html clob;

begin

select blob_to_clob(blob_data) into html_clob from okc_word_sync_t where id = 3 and doc_id = p_doc_id and doc_type = p_doc_type;

pos1 :=  regexp_instr(html_clob,'<ClauseText>');
pos2 :=  regexp_instr(html_clob,'</ClauseText>');

pos1 := pos1+12; --length of the clausetext tag is 12
pos2 := pos2;
len := pos2-pos1;

stripped_html := substr(html_clob,pos1,len);
/*stripped_html := regexp_replace(stripped_html,'''','"');  -- After the Import XSL is applied miscellaneous and <br forWord tags have ' instead of "
stripped_html := regexp_replace(stripped_html,' >','>');
stripped_html := regexp_replace(stripped_html,' />','/>');*/

update  okc_word_sync_t
set blob_data = clob_to_blob(stripped_html)
where id = 3
and   doc_id = p_doc_id
and doc_type = p_doc_type;

end strip_tags;

-------------------------------------------
-- This procedure is not required
-------------------------------------------
FUNCTION GET_ARTICLE_WML(p_art_clob XMLtype,p_doc_clob CLOB) return BLOB AS
 l_api_name    VARCHAR2(30) := 'GET_ARTICLE_WML';
 l_art_XML     XMLType;
 l_art_clob    CLOB;


 BEGIN
    SELECT deleteXML(xmltype(p_doc_clob),'//wbody/*').getClobVal() INTO l_art_clob FROM dual;
    l_art_XML := p_art_clob.extract('//ArticleText[1]/*');
    select appendChildXML(XMLTYPE(l_art_clob),'//wbody',l_art_XML).getClobVal()
    into l_art_CLOB from dual;
    l_art_CLOB := OKC_WORD_DOWNLOAD_UPLOAD.resolve_variables_upload(l_art_CLOB);
    l_art_CLOB := regexp_replace(regexp_replace(l_art_CLOB,'wbody','w:body'),'<w:t/>','<w:t> </w:t>');

    return OKC_WORD_DOWNLOAD_UPLOAD.clob_to_blob(l_art_clob);

END GET_ARTICLE_WML;


FUNCTION get_articleWML_Text(p_art_blob BLOB) return CLOB AS
 l_api_name    VARCHAR2(30) := 'get_articleWML_Text';
 l_art_clob CLOB;


 BEGIN
  l_art_clob := blob_to_clob(p_art_blob);
  l_art_clob := regexp_replace(regexp_replace(l_art_clob,'w:body','wbody'),'w:t','wt');
  l_art_clob := xmltype(l_art_clob).extract('//wt/text()').getClobVal();
  l_art_clob := regexp_replace(l_art_clob,' ','');

  return l_art_clob;

END get_articleWML_Text;

FUNCTION get_articleWML_Text(p_art_blob CLOB) return CLOB AS
 l_api_name    VARCHAR2(30) := 'get_articleWML_Text';
 l_art_clob CLOB:=p_art_blob;
 BEGIN
  --l_art_clob := blob_to_clob(p_art_blob);
  l_art_clob := regexp_replace(regexp_replace(l_art_clob,'w:body','wbody'),'w:t','wt');
  l_art_clob := xmltype(l_art_clob).extract('//wt/text()').getClobVal();
  l_art_clob := regexp_replace(l_art_clob,' ','');
  return l_art_clob;
END get_articleWML_Text;



PROCEDURE get_latest_wml (
    p_doc_id IN NUMBER,
    p_doc_type IN VARCHAR2,
    p_cat_id IN NUMBER DEFAULT NULL,
    x_action OUT NOCOPY VARCHAR2,
    x_wml_blob OUT NOCOPY BLOB,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_data OUT NOCOPY VARCHAR2) AS
t_action VARCHAR2(30);
t_blob_data BLOB;
t_clob_data CLOB;
t_id NUMBER;

CURSOR get_updated_csr IS
SELECT action,clob_data
FROM okc_word_sync_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND cat_id = p_cat_id
AND action = 'UPDATED';

/* p_cat_id will be null for the clauses added via 2010 and they will be sent as null
and in okc_word_sync_t they will be loaded as 0. so the nvl check is added
*/
CURSOR get_added_csr IS
SELECT id,action,clob_data
FROM okc_word_sync_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND cat_id = Nvl(p_cat_id,0)
AND action = 'ADDED'
AND id = (SELECT Min(id) FROM okc_word_sync_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND cat_id = Nvl(p_cat_id,0) AND action = 'ADDED');

CURSOR get_none_csr IS
SELECT action
FROM okc_word_sync_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND cat_id = p_cat_id
AND action = 'NONE';

CURSOR get_placeholder_xml
IS
SELECT clob_data
FROM okc_word_sync_t
WHERE doc_id = p_doc_id
AND doc_type = p_doc_type
AND  id=10;

l_placeholder_xml CLOB;

l_progress VARCHAR2(3);

BEGIN

l_progress := '010';

OPEN get_updated_csr;
FETCH get_updated_csr INTO t_action,t_clob_data;
IF get_updated_csr%FOUND THEN

  OPEN get_placeholder_xml;
  FETCH get_placeholder_xml INTO  l_placeholder_xml;
  CLOSE  get_placeholder_xml;

  l_progress := '020';
  t_clob_data := regexp_replace(t_clob_data,'w:body', 'wbody');

  l_progress := '030';
  l_placeholder_xml := XmlType.appendchildXML(XmlType(l_placeholder_xml),'//wbody',xmltype(t_clob_data).extract('wbody/*')).getClobVal();
  l_placeholder_xml := regexp_replace(l_placeholder_xml,'wbody','w:body');


  x_action := t_action;
  x_wml_blob := clob_to_blob(l_placeholder_xml);

  UPDATE okc_word_sync_t
  SET action = 'UPDATEDASSIGNED' , clob_data =  l_placeholder_xml
  WHERE doc_id = p_doc_id
  AND doc_type = p_doc_type
  AND cat_id = Nvl(p_cat_id,0)
  AND action = 'UPDATED';

  CLOSE get_updated_csr;

ELSE
    l_progress := '040';
    OPEN get_none_csr;
    FETCH get_none_csr INTO t_action;

    IF get_none_csr%FOUND THEN

    SELECT article_text INTO t_clob_data FROM okc_article_versions WHERE article_version_id = (SELECT article_version_id FROM okc_k_articles_b  WHERE id = p_cat_id);
    t_blob_data := clob_to_blob(t_clob_data);

    x_action := t_action;
    x_wml_blob := t_blob_data;

    UPDATE okc_word_sync_t
    SET action = 'NONEASSIGNED'
    WHERE doc_id = p_doc_id
    AND doc_type = p_doc_type
    AND cat_id = p_cat_id
    AND action = 'NONE';

    CLOSE get_none_csr;

    ELSE
     l_progress := '040';
      OPEN get_added_csr;
      FETCH get_added_csr INTO t_id,t_action,t_clob_data;
      IF get_added_csr%FOUND THEN

       OPEN get_placeholder_xml;
       FETCH get_placeholder_xml INTO  l_placeholder_xml;
       CLOSE  get_placeholder_xml;

        t_clob_data := regexp_replace(t_clob_data,'w:body', 'wbody');
        l_placeholder_xml := XmlType.appendchildXML(XmlType(l_placeholder_xml),'//wbody',xmltype(t_clob_data).extract('wbody/*')).GetClobVal();
        l_placeholder_xml := regexp_replace(l_placeholder_xml,'wbody','w:body');
        x_action := t_action;
        x_wml_blob := clob_to_blob(l_placeholder_xml);


      UPDATE okc_word_sync_t
      SET action = 'ADDEDASSIGNED' , clob_data =  l_placeholder_xml
      WHERE doc_id = p_doc_id
      AND doc_type = p_doc_type
      AND cat_id = Nvl(p_cat_id,0)
      AND action = 'ADDED'
      AND id = t_id;

      CLOSE get_added_csr;

      END IF;
    END IF;
END IF;

x_return_status := G_RET_STS_SUCCESS;
x_msg_data      := NULL;

EXCEPTION
 WHEN OTHERS THEN

  x_return_status := G_RET_STS_ERROR;
  x_msg_data      := SQLCODE||' -ERROR- '||SQLERRM ;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||'GET_LATEST_WML',
                    '100: Exception '||G_PKG_NAME ||'.'||'GET_LATEST_WML');
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT ,
                    G_MODULE||'GET_LATEST_WML',
                    '100: Exception - '|| SQLERRM );
  END IF;
  RAISE;
END get_latest_wml;


FUNCTION get_latest_wmlblob (p_doc_id IN NUMBER, p_doc_type IN VARCHAR2, p_cat_id IN NUMBER DEFAULT NULL) RETURN BLOB AS
t_action VARCHAR2(30);
t_blob_data BLOB;
l_id NUMBER;
BEGIN
IF p_cat_id IS NOT NULL THEN
  BEGIN
      SELECT action,clob_to_blob(clob_data) INTO t_action,t_blob_data FROM okc_word_sync_t
      WHERE doc_id = p_doc_id
      AND doc_type = p_doc_type
      AND cat_id = p_cat_id;

      IF t_action = 'NONEASSIGNED' THEN
        SELECT article_text_in_word INTO t_blob_data FROM okc_article_versions WHERE article_version_id = (SELECT article_version_id FROM okc_k_articles_b  WHERE id = p_cat_id);
      END IF;
  EXCEPTION
      WHEN No_Data_Found THEN
        RETURN NULL;
  END;


ELSE


  BEGIN
      SELECT clob_to_blob(clob_data),id INTO t_blob_data,l_id FROM okc_word_sync_t
      WHERE doc_id = p_doc_id
      AND doc_type = p_doc_type
      AND action = 'ADDEDASSIGNED'
      AND id = (SELECT Min(id) FROM okc_word_sync_t WHERE doc_id = p_doc_id AND doc_type = p_doc_type AND action = 'ADDEDASSIGNED');

      UPDATE okc_word_sync_t
        SET action = 'ADDEDDONE'
        WHERE id = l_id;
  EXCEPTION
      WHEN No_Data_Found THEN
          RETURN NULL;
  END;

END IF;

RETURN t_blob_data;

END get_latest_wmlblob;


procedure get_article_html_for_comp(p_art_ver_id IN NUMBER,p_review_upld_terms_id IN NUMBER,x_art_html OUT NOCOPY BLOB,x_success  OUT NOCOPY VARCHAR2) AS
x_art_wml CLOB;

BEGIN

IF p_review_upld_terms_id IS NOT NULL THEN
  select wt.clob_data into x_art_wml
  from   okc_review_upld_terms UPLD,OKC_WORD_SYNC_T WT
  where  UPLD.REVIEW_UPLD_TERMS_ID = p_review_upld_terms_id
  and    WT.doc_id = UPLD.document_id
  and    WT.doc_type = UPLD.DOCUMENT_TYPE
  and    WT.cat_id = UPLD.object_id
  AND    wt.action = 'UPDATEDASSIGNED';

ELSE
  select okc_word_download_upload.blob_to_clob(article_text_in_word) into x_art_wml
  from   okc_article_versions VER
  where  VER.article_version_id = p_art_ver_id
  and    ver.edited_in_word = 'Y';

END IF;

 x_art_wml := convert_wml_to_html_1(x_art_wml);
 --x_art_wml := regexp_replace(x_art_wml,'<td/>','<td></td>');
 x_art_wml := regexp_replace(x_art_wml,'&nbsp;','');
 x_art_html := okc_word_download_upload.Clob_to_blob(x_art_wml);
 x_success := FND_API.G_TRUE;
 EXCEPTION
   when others then x_success := FND_API.G_FALSE;

END get_article_html_for_comp;

function convert_wml_to_html_1(p_art_wml CLOB) return CLOB as
l_art_html CLOB;
l_tbl      CLOB;
begin
 l_art_html := regexp_replace(regexp_replace(regexp_replace(regexp_replace(p_art_wml,'w:body','wbody'),'w:p','wp'),'w:t','wt'),'wx:s','wxs');

 --Get body
 l_art_html := xmltype(l_art_html).extract('//wbody').getClobVal();
 --remove section tags seen in docs created using MS Word 2003
  while (xmltype(l_art_html).existsnode('//wxsect')>0) loop

  l_tbl := '<div>'||xmltype(l_art_html).extract('//wxsect[1]/*').getClobVal()||'</div>';

  select updateXML(xmltype(l_art_html),'//wxsect[1]',XMLType(l_tbl).extract('/div/*')).getClobVal() into l_art_html from dual;
 end loop;
 --Remove subsections
 while (xmltype(l_art_html).existsnode('//wxsub-section')>0) loop

  l_tbl := '<div>'||xmltype(l_art_html).extract('//wxsub-section[1]/*').getClobVal()||'</div>';

  select updateXML(xmltype(l_art_html),'//wxsub-section[1]',XMLType(l_tbl).extract('/div/*')).getClobVal() into l_art_html from dual;
 end loop;
 --Replace wml tables with html tables
 while (xmltype(l_art_html).existsnode('//wtbl')>0) loop
  l_tbl := '<TABLE border="2" cellSpacing="0">'||xmltype(l_art_html).extract('//wtbl[1]//wtr').getClobVal()||'</TABLE>';
  l_tbl := convert_rows_to_html(l_tbl);
  select updateXML(xmltype(l_art_html),'//wtbl[1]',XMLType(l_tbl)).getClobVal() into l_art_html from dual;
 end loop;
 --Replace paras in subsections
 /*while (xmltype(l_art_html).existsnode('//wxsub-section/wp')>0) loop

  begin
  l_tbl := '<div>'||xmltype(l_art_html).extract('//wxsub-section[1]//wp').getClobVal()||'</div>';
  l_tbl := convert_para_to_html(l_tbl);
  exception
   when others then
    l_tbl := '<div><p/></div>';
  end;
  select updateXML(xmltype(l_art_html),'//wxsub-section[1]',XMLType(l_tbl).extract('/div/*')).getClobVal() into l_art_html from dual;
 end loop;
 */


 --Replace paras

 while (xmltype(l_art_html).existsnode('//wp')>0) loop
  begin
  l_tbl := '<p>'||xmltype(l_art_html).extract('//wp[1]//wt/text()').getClobVal()||'</p>';
  exception
   when others then
    l_tbl := '<p/>';
  end;
  select updateXML(xmltype(l_art_html),'//wp[1]',XMLType(l_tbl)).getClobVal() into l_art_html from dual;
 end loop;

 l_art_html := xmltype(l_art_html).extract('//p|//TABLE').getClobVal();
-- l_art_html := regexp_replace(l_art_html,'tr>','p>');
-- l_art_html := regexp_replace(regexp_replace(l_art_html,'<td>','  '),'</td>','   ');
 return l_art_html;
end convert_wml_to_html_1;

function convert_rows_to_html(p_table CLOB) return CLOB as
 l_table CLOB;
 l_row   CLOB;
begin
 l_table := p_table;
 while (xmltype(l_table).existsnode('//wtr')>0) loop
 l_row := '<tr>'||xmltype(l_table).extract('//wtr[1]//wtc').getClobVal()||'</tr>';
 l_row := convert_cells_to_html(l_row);
 select updateXML(xmltype(l_table),'//wtr[1]',XMLType(l_row)).getClobVal() into l_table from dual;
end loop;
return l_table;
end convert_rows_to_html;


function convert_cells_to_html(p_row CLOB) return CLOB as
 l_cell CLOB;
 l_row   CLOB;
begin
 l_row := p_row;
 while (xmltype(l_row).existsnode('//wtc')>0) loop
 begin
 l_cell := '<td>'||xmltype(l_row).extract('//wtc[1]//text()').getClobVal()||'</td>';
 exception
  when others then
    l_cell:='<td/>';
 end;
 select updateXML(xmltype(l_row),'//wtc[1]',XMLType(l_cell)).getClobVal() into l_row from dual;
end loop;
return l_row;
end convert_cells_to_html;

FUNCTION clean_html_diff(p_html_diff CLOB) RETURN CLOB AS
l_html_diff CLOB;
l_tr  CLOB;
l_i  NUMBER := 1;
l_xpath VARCHAR2(100);
BEGIN
--Ignore span tags around table element..
l_html_diff := p_html_diff;

--l_html_diff := '<DUMMY>'||l_html_diff||'</DUMMY>';
--if (xmltype(l_html_diff).existsnode('//TABLE')>0) THEN
l_html_diff := regexp_replace(regexp_replace(regexp_replace(l_html_diff,'<TABLE border="2" cellSpacing="0">','<TABLESTART/>'),'<TR>','<TRSTART/>'),'</TR>','<TREND/>');
l_html_diff := regexp_replace(l_html_diff,'</TABLE>','<TABLEEND/>');
l_html_diff := '<DUMMY>'||l_html_diff||'</DUMMY>';
l_html_diff := XMLType(l_html_diff).extract('//P|//TABLESTART|//TABLEEND|//TRSTART|//TREND|//TD').getClobVal();
--l_html_diff := '<DUMMY1>'||l_html_diff||'</DUMMY1>';
--l_html_diff := XMLType(l_html_diff).extract('//P|//TABLE').getClobVal();
l_html_diff := '<DUMMY2>'||l_html_diff||'</DUMMY2>';
select deleteXML(XMLType(l_html_diff),'//br').getClobVal() into l_html_diff from dual;
l_html_diff := regexp_replace(regexp_replace(regexp_replace(l_html_diff,'<TABLESTART/>','<TABLE border="1" cellSpacing="0" width="650">'),'<TRSTART/>','<TR>'),'<TREND/>','</TR>');
l_html_diff := regexp_replace(l_html_diff,'<TABLEEND/>','</TABLE>');
l_html_diff := XMLType(l_html_diff).extract('/DUMMY2/*').getClobVal();
l_html_diff := regexp_replace(l_html_diff,'<span style="text-decoration:underline"/>','');
l_html_diff := regexp_replace(l_html_diff,'<span style="text-decoration:line-through"/>','');
/*else
 l_html_diff := p_html_diff;
end if;
l_html_diff := '<DUMMY2>'||l_html_diff||'</DUMMY2>';
select deleteXML(XMLType(l_html_diff),'//br').getClobVal() into l_html_diff from dual;
l_html_diff := XMLType(l_html_diff).extract('/DUMMY2/*').getClobVal();*/
return l_html_diff;
END clean_html_diff;

FUNCTION change_encoding (p_clob CLOB) RETURN CLOB is
l_encoding_st NUMBER;
l_encoding_end NUMBER;
l_encoding VARCHAR2(100);
l_clob CLOB;
BEGIN
l_clob := p_clob;
l_encoding_st:=Dbms_Lob.InStr(l_clob,'encoding="',1)+length('encoding="');
l_encoding_end:=Dbms_Lob.InStr(l_clob,'"',l_encoding_st);
l_encoding:=Dbms_Lob.SubStr(l_clob,l_encoding_end-l_encoding_st,l_encoding_st);
IF l_encoding <> 'UTF-8' THEN
l_clob:=REGEXP_REPLACE(l_clob, l_encoding, 'UTF-8',1,1);
END IF;
RETURN l_clob;
END;

END OKC_WORD_DOWNLOAD_UPLOAD;

/
