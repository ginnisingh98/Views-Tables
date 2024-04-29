--------------------------------------------------------
--  DDL for Package Body CS_KB_R_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_R_CTX_PKG" as
/* $Header: cskrctxb.pls 120.0 2005/06/01 09:57:28 appldev noship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | FILENAME: cskrctxb.pls                                               |
 |                                                                      |
 | PURPOSE                                                              |
 |   Datastore procedure for cs_forum_messages_tl_n4 intermedia index.  |
 | ARGUMENTS                                                            |
 |                                                                      |
 | NOTES                                                                |
 |   Usage: start  cskrctxb.pls apps                                    |
 |  Arguments:                                                          |
 |     1 - un_apps = apps user name                                     |
 |     2 - CTXSYS = ctxsys user name                                    |
 | HISTORY                                                              |
 |   05-Mar-2003 klou Created.  Copy from ctxsys.cs_kb_f_ctx_pkg (115.5)|
 |   06-Mar-2003 klou                                                   |
 |               1. Grant execute of this package to CTXSYS.            |
 |               2. Add APPS qualifier in front of schema.               |
 |   15-Mar-2004 hmei Bug 3499204 - remove tags for indexing            |
 +======================================================================*/
procedure Get_Forum_Composite_Cols(
  p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB
) is
    l_desc_clob CLOB := null;
    l_message_id number := null;
	l_lang      VARCHAR2(256) := null;
	l_name	  VARCHAR2(200) := null;
	l_data varchar2(2000);
	l_mesg_number Number := null;
    l_temp_clob CLOB; -- used in Remove_Tags_Clob


    cursor get_data_csr(p_rowid in ROWID) is
        Select cfmt.message_id, cfmt.language, cfmt.name, cfmt.description, cfmb.message_number
        from cs_forum_messages_tl cfmt, cs_forum_messages_b cfmb
        where cfmt.rowid = p_rowid
        and cfmt.message_id = cfmb.message_id;


begin

    -- temp clob lives for at most the duration of call.
    dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);

    open get_data_csr(p_rowid);
    fetch get_data_csr into l_message_id, l_lang, l_name, l_desc_clob, l_mesg_number;
    close get_data_csr;

    l_data := '<SUBJECT>'||l_name||'</SUBJECT>';
    l_data := l_data ||'<NUMBER>'||to_char(l_mesg_number)||'</NUMBER>';

    l_data := l_data||'<BODY>';

    l_data := CS_KB_CTX_PKG.Remove_Tags(l_data);

    dbms_lob.trim(p_clob, 0);
    dbms_lob.writeappend(p_clob, length(l_data), l_data);

    dbms_lob.open(p_clob, DBMS_LOB.LOB_READWRITE);
    dbms_lob.open (l_desc_clob, DBMS_LOB.LOB_READONLY);
    dbms_lob.append(p_clob, CS_KB_CTX_PKG.Remove_Tags_Clob(l_desc_clob,l_temp_clob));

    dbms_lob.close(p_clob);
    dbms_lob.close(l_desc_clob);
    dbms_lob.writeappend(p_clob, length('</BODY>'), '</BODY>');

   l_data := '<LANG>'||l_lang||'</LANG>';
    dbms_lob.writeappend(p_clob, length(l_data), l_data);

   -- explicitly free the clob
   dbms_lob.freetemporary(l_temp_clob);

End Get_Forum_Composite_Cols;
end cs_kb_r_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."CS_KB_R_CTX_PKG" TO "CTXSYS";
