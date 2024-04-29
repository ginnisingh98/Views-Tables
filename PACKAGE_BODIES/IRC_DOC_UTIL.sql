--------------------------------------------------------
--  DDL for Package Body IRC_DOC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_DOC_UTIL" AS
/* $Header: iridoutl.pkb 120.0.12010000.2 2008/08/05 10:48:46 ubhat ship $ */
--
g_index_name varchar2(80);
 g_StartConcatenator  CONSTANT    VARCHAR2(3) := '...';
 g_EndConcatenator    CONSTANT    VARCHAR2(4) := '... ';
--
  -- **************************************************************************
  -- getContentTeaser : Defaulted Index Version (full comments in Package spec
  -- **************************************************************************
  --
  FUNCTION getContentTeaser(p_document_id        INTEGER,
                            p_search_string VARCHAR2)
    RETURN VARCHAR2 IS
    --
    -- Cursor to retrieve the schema name
    --
    cursor csr_user is
    select oracle_username
      from fnd_oracle_userid
     where oracle_id = 800;
    --
    l_hr_username fnd_oracle_userid.oracle_username%TYPE :=null ;
  BEGIN
    --
    if (g_index_name is null) then
      open csr_user;
      fetch csr_user into l_hr_username;
      close csr_user;
      g_index_name:=l_hr_username||'.'||IRC_DOC_UTIL.IRC_DEFAULT_INDEX;
    end if;
    --
    RETURN IRC_DOC_UTIL.getContentTeaser(p_document_id
                                        ,p_search_string
                                        ,g_index_name );
  END getContentTeaser;

--
  -- **************************************************************************
  -- getContentTeaser : Specific Index Version (full comments in Package spec)
  -- **************************************************************************
  --
  FUNCTION getContentTeaser(p_document_id          INTEGER,

                            p_search_string  VARCHAR2,
                            p_ctx_index VARCHAR2)
    RETURN VARCHAR2 IS
    --
    -- Cursor to get rowid value for the document_id
    --
    CURSOR csr_get_rowid(p_document_id INTEGER) IS
    SELECT rowid,character_doc
    FROM irc_documents
    where document_id = p_document_id;
    --
    vOffsetTable            CTX_DOC.HIGHLIGHT_TAB;
    vTeaserLine             VARCHAR2(1000);
    l_procedure_name constant varchar2(80):='irc_doc_util.getcontentteaser';
    l_rowid                 ROWID;
    l_doc clob;
    l_pos_start1 number;
    l_pos_end1 number;
    l_pos_start2 number;
    l_pos_end2 number;
    l_doc_length number;
    l_text varchar2(2000);
    vCounter number;
  BEGIN
    --
    --
    -- Run the Intermedia Text procedure to generate a PL/SQL table
    -- holding the offsets of found terms based on the supplied query
    -- criteria
    --
    --
    if(fnd_log.g_current_runtime_level <= fnd_log.level_procedure) then
      fnd_log.string(fnd_log.level_procedure,'per.plsql.'||l_procedure_name,'10');
    end if;
    --
    OPEN csr_get_rowid(p_document_id);
    FETCH csr_get_rowid into l_rowid,l_doc;
    CLOSE csr_get_rowid;
    ctx_doc.highlight(index_name => p_ctx_index,
                      textkey    => l_rowid,
                      text_query => p_search_string,
                      restab     => vOffsetTable,
                      plaintext  => TRUE);
    --
    -- we are going to return 2 preview chunks of about 150 characters.
    --
    if vOffsetTable(1).offset<75 then
      l_pos_start1:=1;
    else
      --find the next space after 75 characters before the hit
      l_pos_start1:=vOffsetTable(1).offset-75;
      vTeaserLine:=g_StartConcatenator;
    end if;
    --
    -- find the end position
    --
    l_doc_length:=dbms_lob.getlength(l_doc);
    if vOffsetTable(1).offset+75>l_doc_length then
      l_pos_end1:=l_doc_length;
    else
      -- find the space after 75 characters after the hit
      l_pos_end1:=vOffsetTable(1).offset+75;
    end if;
    --
    l_text:=dbms_lob.substr(l_doc,(l_pos_end1-l_pos_start1),l_pos_start1);
    --
    vTeaserLine:=vTeaserLine||substr(l_text,1,(vOffsetTable(1).offset-l_pos_start1))||IRC_DOC_UTIL.MARKUP_START_TAG
    ||substr(l_text,(vOffsetTable(1).offset-l_pos_start1+1),vOffsetTable(1).length)||IRC_DOC_UTIL.MARKUP_END_TAG;
    --
    -- look to see if the second tag is in the same chunk
    --
    vCounter:=2;
    if vOffsetTable.COUNT>1 AND vOffsetTable(2).offset<l_pos_end1 then
    --loop through the text highlighting it
      WHILE vCounter<=vOffsetTable.COUNT LOOP
        if(vOffsetTable(vCounter).offset>=l_pos_end1) then
          exit;
        end if;
        vTeaserLine:=vTeaserLine||substr(l_text,(vOffsetTable(vCounter-1).offset+vOffsetTable(vCounter-1).length-l_pos_start1+1)
        ,vOffsetTable(vCounter).offset-vOffsetTable(vCounter-1).offset-vOffsetTable(vCounter-1).length)||IRC_DOC_UTIL.MARKUP_START_TAG
        ||substr(l_text,(vOffsetTable(vCounter).offset-l_pos_start1+1),vOffsetTable(vCounter).length)||IRC_DOC_UTIL.MARKUP_END_TAG;
      vCounter:=vCounter+1;
      END LOOP;
     end if;
      vTeaserLine:=vTeaserLine||substr(l_text,(vOffsetTable(vCounter-1).offset+vOffsetTable(vCounter-1).length-l_pos_start1+1))||g_EndConcatenator;
     -- now look for the second teaser chunk
     --
     if (vOffsetTable.COUNT>=vCounter) then
       --
       if vOffsetTable(vCounter).offset-vOffsetTable(1).offset<=150 then
         l_pos_start2:=vOffsetTable(1).offset+75;
          vTeaserLine:=substr(vTeaserLine,1,length(vTeaserLine)-4);
      else
         --find the next space after 75 characters before the hit
         l_pos_start2:=vOffsetTable(vCounter).offset-75;
         vTeaserLine:=vTeaserLine||g_StartConcatenator;
       end if;
      --
      -- find the end position
      --
      if vOffsetTable(vCounter).offset+75>l_doc_length then
        l_pos_end2:=l_doc_length;
      else
        -- find the space after 75 characters after the hit
        l_pos_end2:=vOffsetTable(vCounter).offset+75;
      end if;
    l_text:=dbms_lob.substr(l_doc,(l_pos_end2-l_pos_start2),l_pos_start2);
    --
    vTeaserLine:=vTeaserLine||substr(l_text,1,(vOffsetTable(vCounter).offset-l_pos_start2))||IRC_DOC_UTIL.MARKUP_START_TAG
    ||substr(l_text,(vOffsetTable(vCounter).offset-l_pos_start2+1),vOffsetTable(vCounter).length)||IRC_DOC_UTIL.MARKUP_END_TAG;
    --
    -- look to see if there are more tags in the same chunk
    --
    vCounter:=vCounter+1;
    if vOffsetTable.COUNT>=vCounter AND vOffsetTable(vCounter).offset<l_pos_end2 then
    --loop through the text highlighting it
      WHILE vCounter<=vOffsetTable.COUNT LOOP
        if(vOffsetTable(vCounter).offset>=l_pos_end2) then
          exit;
        end if;
        vTeaserLine:=vTeaserLine||substr(l_text,(vOffsetTable(vCounter-1).offset+vOffsetTable(vCounter-1).length-l_pos_start2+1)
        ,vOffsetTable(vCounter).offset-vOffsetTable(vCounter-1).offset-vOffsetTable(vCounter-1).length)||IRC_DOC_UTIL.MARKUP_START_TAG
        ||substr(l_text,(vOffsetTable(vCounter).offset-l_pos_start2+1),vOffsetTable(vCounter).length)||IRC_DOC_UTIL.MARKUP_END_TAG;
      vCounter:=vCounter+1;
      END LOOP;
     end if;
      vTeaserLine:=vTeaserLine||substr(l_text,(vOffsetTable(vCounter-1).offset+vOffsetTable(vCounter-1).length-l_pos_start2+1))||g_EndConcatenator;
    end if;
    --
    -- Strip out tab characters and carriage returns
    --
    RETURN REPLACE(REPLACE(vTeaserLine,fnd_global.local_chr(13),' '),fnd_global.local_chr(10),' ');
    --
  END getContentTeaser;
END IRC_DOC_UTIL;

/
