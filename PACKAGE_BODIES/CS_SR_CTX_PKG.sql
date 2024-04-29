--------------------------------------------------------
--  DDL for Package Body CS_SR_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_CTX_PKG" as
/* $Header: csctxsrb.pls 120.0 2005/06/01 10:01:55 appldev noship $ */


  -- ********************************
  -- Public Procedure Implementations
  -- ********************************

  Procedure Build_SR_Text
  (p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB)
  is
    l_incident_id NUMBER;
    l_lang varchar2(5);
    l_inventory_item_id NUMBER;
    l_summary varchar2(241);

    l_type_id NUMBER;

    l_temp_clob CLOB;
    l_newline varchar2(4);

    CURSOR GET_SR_CONTENT(c_rowid rowid) IS
     select tl.incident_id, tl.language, b.incident_type_id,
            b.inventory_item_id, tl.summary
     from cs_incidents_all_tl tl, cs_incidents_all_b b
     where tl.rowid = c_rowid
     and tl.incident_id = b.incident_id;

    CURSOR GET_SR_NOTS (c_obj_id NUMBER, c_lang VARCHAR2) IS
     select tl.notes, b.note_status, b.created_by
           ,tl.notes_detail
      from jtf_notes_tl tl, jtf_notes_b b
      where tl.jtf_note_id = b.jtf_note_id
      and b.source_object_code  = 'SR'
      and b.source_object_id = c_obj_id
      and b.note_status in ('E', 'I')
      and tl.language = c_lang;

    l_data  VARCHAR2(32000);
    l_amt   NUMBER;
    l_note  VARCHAR2(2000);

    l_clob_len NUMBER;
    p_clob_len NUMBER;
    l_notes_detail CLOB;
  Begin
    -- Initialize parameters
    l_amt := 0;
    l_data := '';
    l_note := null;
    l_newline := fnd_global.newline;
    l_temp_clob := null;
    l_notes_detail := null;


   -- Clear out the output CLOB buffer
    dbms_lob.trim(p_clob, 0);

    Open GET_SR_CONTENT(p_rowid);
    Fetch GET_SR_CONTENT Into l_incident_id,
                              l_lang,
                              l_type_id,
                              l_inventory_item_id,
                              l_summary;
    Close GET_SR_CONTENT;

   -- Synthesize the text content
    l_data := '<SUMMARY>'||Remove_Tags(l_summary)||'</SUMMARY>'||l_newline;

   -- Add sections
   -- 1. Add SRTYPE
    l_data := l_data || l_newline ||'<SRTYPE>'||to_char(l_type_id)
             ||'</SRTYPE>';

   -- 2. Add LANG
    l_data := l_data||l_newline||'<LANG>a'||l_lang||'a</LANG>';

   -- 3. Add ITEM
    l_data := l_data||l_newline||'<ITEM>'||to_char(l_inventory_item_id)
             ||'</ITEM>';

    l_amt := length(l_data);

    dbms_lob.writeappend(p_clob, l_amt, l_data);

   -- 4. Append all SR notes to the NOTES section
    l_data := l_newline||'<NOTES>';
    For srnote in GET_SR_NOTS(l_incident_id, l_lang) Loop

      l_data := l_data ||' '||Remove_Tags(srnote.notes)||l_newline;
      l_amt := length(l_data);
      /*
        If l_amt > 29990 Then
           dbms_lob.writeappend(p_clob, l_amt, l_data);
           l_data := '';
        End If;
       */
      dbms_lob.writeappend(p_clob, l_amt, l_data);
      l_data := '';

      If (srnote.notes_detail is not null
         and dbms_lob.getlength(srnote.notes_detail) > 0)
      Then
         dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);

         l_notes_detail := Remove_Tags_Clob(srnote.notes_detail, l_temp_clob);
         l_clob_len := dbms_lob.getlength(l_notes_detail);
         p_clob_len := dbms_lob.getlength(p_clob);
         dbms_lob.copy(p_clob,
                       l_notes_detail,
                       l_clob_len,
                       p_clob_len+1, 1);

         dbms_lob.freetemporary(l_temp_clob);
      End if;
    End Loop;

    l_data := l_data||'</NOTES>';

    l_amt := length(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  End Build_SR_Text;

  /*
    Remove_Tags:
    - replaces all occurrences of '<' with '!'
       p_text: the original varchar
       returns: the modified varchar
  */
  function Remove_Tags
  ( p_text IN VARCHAR2)
  return VARCHAR2
  is
  begin
    return replace(p_text, '<', '!');
  end Remove_Tags;

/*
 *      Remove_Tags_Clob: replaces all occurrences of '<' with '!'
 *      p_clob: the original data
 *      p_temp_clob: if necessary, modified data is stored here
 *      returns: pointer to either p_clob or p_temp_clob
 */
  function Remove_Tags_Clob
  ( p_clob        IN CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB
  )
  RETURN CLOB
  is
  l_len number;
  l_idx number;
  begin
    --can't use, 8.1.7 does not support CLOB replace
    --p_clob := replace(p_clob, '<', '!');

    l_idx := dbms_lob.instr(p_clob, '<', 1);
    if(l_idx is not null and l_idx > 0) then
        -- '<' found, so need to copy original into temp clob
        -- Clear out the temp clob buffer
        dbms_lob.trim(p_temp_clob, 0);
        -- Copy original data into temporary clob
        l_len := dbms_lob.getlength(p_clob);
        dbms_lob.copy(p_temp_clob, p_clob, l_len, 1, 1);
    else
        -- no '<' found, so just return the original
        return p_clob;
    end if;

    --assert: there is at least one '<' in p_clob,
    --assert: l_idx contains the position of the first '<'
    --assert: p_temp_clob is a copy of p_clob.

    --Now replace all '<' with '!' in p_temp_clob
    --and return p_temp_clob

    while(l_idx is not null and l_idx > 0) loop
      dbms_lob.write(p_temp_clob, 1, l_idx, '!');
      l_idx := dbms_lob.instr(p_temp_clob, '<', l_idx);
    end loop;

    return p_temp_clob;

 end Remove_Tags_Clob;


end cs_sr_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."CS_SR_CTX_PKG" TO "CTXSYS";
  GRANT EXECUTE ON "APPS"."CS_SR_CTX_PKG" TO "CS";
