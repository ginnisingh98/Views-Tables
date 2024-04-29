--------------------------------------------------------
--  DDL for Package Body JTF_DIAG_REPORT_FACTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAG_REPORT_FACTORY" AS
/* $Header: jtf_diag_report_factory_b.pls 120.3.12010000.6 2009/08/05 13:33:35 rudas ship $*/


PROCEDURE VALIDATE_REPORT_CONTEXT(report_context JTF_DIAG_REPORT_CONTEXT)
IS
BEGIN
    IF report_context IS NULL THEN
        RAISE_APPLICATION_ERROR(-20100,'ReportContext provided to instantiate the component is null');
    END IF;
END VALIDATE_REPORT_CONTEXT;

FUNCTION CREATE_FOOTER(footer VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_FOOTER
IS
footer_component JTF_DIAG_FOOTER;
exec_id          NUMBER;
ui_node_id       NUMBER;
footer_content   VARCHAR2(2000);
footer_note_id   NUMBER;
note_component JTF_DIAG_NOTE;
link_component JTF_DIAG_LINK;
temp number := 1;
diag_com_url varchar2(2000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF footer IS NOT NULL THEN
		footer_content   := DBMS_XMLGEN.CONVERT(footer,0) || ' If you are experiencing any issues regarding this diagnostic test, please ' ||
'use My Oracle Support to log an iTAR (Service Request) for product "Oracle E-Business' ||
'Suite Diagnostics" (ID=1332). If you have any question related to E-Business Suite Diagnostics (installation, execution, usage or availability), you can ask us using the' ||
'''Diagnosibility'' ? available on My Oracle Support (or classic' ||
'Metalink). We would also appreciate your feedback regarding the usefulness of this ' ||
'test,however, there will be no replies to feedback emails. ';
		exec_id          := report_context.EXEC_ID;
		BEGIN
			diag_com_url := FND_PROFILE.value('OAM_DIAG_COMMUNITY_URL');
		EXCEPTION
			WHEN OTHERS THEN
				diag_com_url := 'https://communities.oracle.com/portal/server.pt/community/Diagnosibility/242';
		END;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		note_component := CREATE_NOTE(footer_content, report_context);
		link_component := CREATE_LINK('Community', diag_com_url, report_context);
		note_component.set_link(temp, link_component);
		footer_component := JTF_DIAG_FOOTER(exec_id,ui_node_id,footer_content,footer_note_id, 0);
		footer_component.set_Note(note_component);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the footer is null');
	END IF;
	RETURN footer_component;
END CREATE_FOOTER;
FUNCTION CREATE_HEADER(header VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_HEADER
IS
header_component JTF_DIAG_HEADER;
exec_id          NUMBER;
ui_node_id       NUMBER;
header_content   VARCHAR2(2000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF header IS NOT NULL THEN
		header_content   := DBMS_XMLGEN.CONVERT(header,0);
		exec_id          := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		header_component := JTF_DIAG_HEADER(exec_id,ui_node_id,header_content,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the header is null');
	END IF;
	RETURN header_component;
END CREATE_HEADER;
FUNCTION CREATE_SECTION(heading VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_SECTION
IS
section_component JTF_DIAG_SECTION;
exec_id          NUMBER;
ui_node_id       NUMBER;
section_heading   VARCHAR2(2000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF heading IS NOT NULL THEN
		section_heading   := DBMS_XMLGEN.CONVERT(heading,0);
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		section_component := JTF_DIAG_SECTION(exec_id,ui_node_id,section_heading,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'Heading of the Section is null');
	END IF;
	RETURN section_component;
END CREATE_SECTION;
FUNCTION CREATE_MESSAGE(message VARCHAR2,message_type VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_MESSAGE
IS
message_component JTF_DIAG_MESSAGE;
exec_id          NUMBER;
ui_node_id       NUMBER;
message_content   VARCHAR2(2000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF message IS NOT NULL THEN
		message_content   := DBMS_XMLGEN.CONVERT(message,0);
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		IF message_type IS NOT NULL AND (message_type = 'info' OR message_type = 'warning' OR message_type = 'error' OR message_type = 'attention') THEN
			message_component := JTF_DIAG_MESSAGE(exec_id,ui_node_id,message_content,message_type,null,0,0,0);
		ELSE
			RAISE_APPLICATION_ERROR(-20100,'The message type '|| message_type||' is wrong: It can only be info, warning or error');
		END IF;
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the message is null');
	END IF;
	RETURN message_component;
END CREATE_MESSAGE;

FUNCTION CREATE_MESSAGE(note in out nocopy JTF_DIAG_NOTE,message_type VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_MESSAGE
IS
message_component JTF_DIAG_MESSAGE;
exec_id          NUMBER;
ui_node_id       NUMBER;
message_note_id  NUMBER;
str             VARCHAR2(4000);
message_content   VARCHAR2(2000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF note IS NOT NULL THEN
		message_note_id   := note.UI_NODE_ID;
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		IF message_type IS NOT NULL AND (message_type = 'info' OR message_type = 'warning' OR message_type = 'error' OR message_type = 'attention') THEN
                    message_component := JTF_DIAG_MESSAGE(exec_id,ui_node_id,message_content,message_type,null,message_note_id,0,0);
                    IF NOTE.ADDED_TO_PARENT <> 1 THEN
                      str := note.CONSTRUCT_NODE;
                      INSERT INTO JTF_DIAGNOSTIC_REPORT
                      (Execution_ID,UI_Node_ID,type,xmldata,parent_node_id)
                      VALUES(exec_id
                      ,note.UI_Node_ID
                      ,'note'
                      ,xmltype(str)
                      ,ui_node_id);
                      NOTE.SET_ADDED_TO_PARENT;
                   ELSE
                    RAISE_APPLICATION_ERROR(-20100,'The Note component cannot be added
                    to the parent component again');
                   END IF;
		ELSE
			RAISE_APPLICATION_ERROR(-20100,'The message type '|| message_type||' is wrong: It can only be info, warning or error');
		END IF;
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The Note component provided for the message is null');
	END IF;
	RETURN message_component;
END CREATE_MESSAGE;

FUNCTION CREATE_HIDE_SHOW(content VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_HIDE_SHOW
IS
hide_show_component JTF_DIAG_HIDE_SHOW;
exec_id          NUMBER;
ui_node_id       NUMBER;
hide_show_content   VARCHAR2(20000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF content IS NOT NULL THEN
		hide_show_content := DBMS_XMLGEN.CONVERT(content,0);
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		hide_show_component := JTF_DIAG_HIDE_SHOW(exec_id,ui_node_id,hide_show_content,'Hide','Show',0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the hide show is null');
	END IF;
	RETURN hide_show_component;
END CREATE_HIDE_SHOW;
FUNCTION CREATE_RAW_TEXT(content VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_RAW_TEXT
IS
raw_text_component JTF_DIAG_RAW_TEXT;
exec_id          NUMBER;
ui_node_id       NUMBER;
raw_text_content   VARCHAR2(20000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF content IS NOT NULL THEN
		raw_text_content := content;
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		raw_text_component := JTF_DIAG_RAW_TEXT(exec_id,ui_node_id,raw_text_content,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the raw text is null');
	END IF;
	RETURN raw_text_component;
END CREATE_RAW_TEXT;
FUNCTION CREATE_LINK(linkText VARCHAR2, linkURL VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_LINK
IS
link_component JTF_DIAG_LINK;
exec_id          NUMBER;
ui_node_id       NUMBER;
link_text_content   VARCHAR2(20000);
link_url_content   VARCHAR2(20000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF linkText IS NOT NULL  AND linkURL IS NOT NULL THEN
		link_text_content := DBMS_XMLGEN.CONVERT(linkText,0);
		link_url_content  := DBMS_XMLGEN.CONVERT(linkURL,0);
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		link_component := JTF_DIAG_LINK(exec_id,ui_node_id,link_text_content,link_url_content,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the link is null');
	END IF;
	RETURN link_component;
END CREATE_LINK;
FUNCTION CREATE_FORM(heading VARCHAR2,form_keys JTF_VARCHAR2_TABLE_4000, form_values JTF_VARCHAR2_TABLE_4000,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_FORM
IS
form_component JTF_DIAG_FORM;
form_data_component JTF_DIAG_FORMDATA;
exec_id          NUMBER;
form_ui_node_id       NUMBER;
form_data_ui_node_id       NUMBER;
form_heading          VARCHAR2(2000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF heading IS NOT NULL THEN
		form_heading      := DBMS_XMLGEN.CONVERT(heading,0);
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into form_ui_node_id from dual;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into form_data_ui_node_id from dual;
		form_data_component :=  JTF_DIAG_FORMDATA(exec_id,form_data_ui_node_id,form_values,0);
		form_component := JTF_DIAG_FORM(exec_id,form_ui_node_id,form_heading,form_keys,form_values,form_data_component,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the form is null');
	END IF;
	RETURN form_component;
END CREATE_FORM;
FUNCTION CREATE_TABLE(heading VARCHAR2, column_headers JTF_VARCHAR2_TABLE_4000,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TABLE
IS
table_component JTF_DIAG_TABLE;
exec_id          NUMBER;
ui_node_id       NUMBER;
no_of_cols       NUMBER :=0;
table_heading     VARCHAR2(4000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF heading IS NULL THEN
		table_heading := ' ';
	ELSE
		table_heading := DBMS_XMLGEN.CONVERT(heading,0);
	END IF;
	IF column_headers IS NOT NULL THEN
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		FOR x IN column_headers.FIRST .. column_headers.LAST
		LOOP
			no_of_cols := no_of_cols + 1;
		END LOOP;
		table_component := JTF_DIAG_TABLE(exec_id,ui_node_id,column_headers,table_heading,null,0,no_of_cols,0,0,null);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the column header in table is null');
	END IF;
	RETURN table_component;
END CREATE_TABLE;

FUNCTION GET_COLUMN_NAMES(sql_query VARCHAR2) RETURN JTF_VARCHAR2_TABLE_4000
IS
cursor_id          number;
columns_describe   dbms_sql.desc_tab;
column_count       number;
loop_counter	   number;
column_headers JTF_VARCHAR2_TABLE_4000;
BEGIN
        column_headers := JTF_VARCHAR2_TABLE_4000();
	cursor_id := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(cursor_id, sql_query, DBMS_SQL.V7);
	DBMS_SQL.DESCRIBE_COLUMNS(cursor_id, column_count, columns_describe);
	FOR loop_counter in 1..column_count
	LOOP
		column_headers.extend(1);
		column_headers(column_headers.count) := columns_describe(loop_counter).col_name;
	END LOOP;
	DBMS_SQL.CLOSE_CURSOR(cursor_id);
	RETURN column_headers;
END GET_COLUMN_NAMES;


FUNCTION CREATE_TABLE(heading VARCHAR2, column_headers JTF_VARCHAR2_TABLE_4000, sql_query VARCHAR2, report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TABLE
IS
table_component JTF_DIAG_TABLE;
exec_id          NUMBER;
ui_node_id       NUMBER;
no_of_cols       NUMBER :=0;
table_heading     VARCHAR2(4000);
table_column_headers JTF_VARCHAR2_TABLE_4000;
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF sql_query IS NULL THEN
		RAISE_APPLICATION_ERROR(-20100,'The sql query provided for the table is null');
	END IF;
	IF heading IS NULL THEN
		table_heading := ' ';
	ELSE
		table_heading := DBMS_XMLGEN.CONVERT(heading,0);
	END IF;
        table_column_headers := GET_COLUMN_NAMES(sql_query);
        --Check if the column_headers provided by the user is consistent with the query
	IF column_headers IS NOT NULL THEN
                IF table_column_headers.last = column_headers.last THEN
                    table_column_headers := column_headers;
                ELSE
                    RAISE_APPLICATION_ERROR(-20100,'The number of columns/header is inconsistent in table' || table_heading);
                END IF;
        ELSE
            RAISE_APPLICATION_ERROR(-20100,'The content provided for the column header in table is null');
	END IF;
	exec_id           := report_context.EXEC_ID;
	select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
	FOR x IN table_column_headers.FIRST .. table_column_headers.LAST
	LOOP
		no_of_cols := no_of_cols + 1;
	END LOOP;
	table_component := JTF_DIAG_TABLE(exec_id,ui_node_id,table_column_headers,table_heading,sql_query,1,no_of_cols,0,0,null);
	RETURN table_component;
END CREATE_TABLE;

FUNCTION CREATE_TABLE(heading VARCHAR2, sql_query VARCHAR2, report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TABLE
IS
table_component JTF_DIAG_TABLE;
exec_id          NUMBER;
ui_node_id       NUMBER;
no_of_cols       NUMBER :=0;
table_heading     VARCHAR2(4000);
table_column_headers JTF_VARCHAR2_TABLE_4000;
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF sql_query IS NULL THEN
		RAISE_APPLICATION_ERROR(-20100,'The sql query provided for the table is null');
	END IF;
	IF heading IS NULL THEN
		table_heading := ' ';
	ELSE
		table_heading := DBMS_XMLGEN.CONVERT(heading,0);
	END IF;
        table_column_headers := GET_COLUMN_NAMES(sql_query);

	exec_id           := report_context.EXEC_ID;
	select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
	FOR x IN table_column_headers.FIRST .. table_column_headers.LAST
	LOOP
		no_of_cols := no_of_cols + 1;
	END LOOP;
	table_component := JTF_DIAG_TABLE(exec_id,ui_node_id,table_column_headers,table_heading,sql_query,1,no_of_cols,0,0,null);
	RETURN table_component;
END CREATE_TABLE;

FUNCTION CREATE_TABLE(column_headers JTF_VARCHAR2_TABLE_4000,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TABLE IS
table_component JTF_DIAG_TABLE;
BEGIN
    table_component := CREATE_TABLE(null,column_headers,report_context);
    RETURN table_component;
END CREATE_TABLE;

FUNCTION CREATE_TABLE(column_headers JTF_VARCHAR2_TABLE_4000, sql_query VARCHAR2, report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TABLE IS
table_component JTF_DIAG_TABLE;
BEGIN
    table_component := CREATE_TABLE(null,column_headers,sql_query,report_context);
    RETURN table_component;
END CREATE_TABLE;

FUNCTION CREATE_TABLE(sql_query VARCHAR2, report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TABLE IS
table_component JTF_DIAG_TABLE;
BEGIN
    table_component := CREATE_TABLE(' ',sql_query,report_context);
    RETURN table_component;
END CREATE_TABLE;

FUNCTION CREATE_ROW(report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_ROW IS
row_component JTF_DIAG_ROW;
exec_id          NUMBER;
ui_node_id       NUMBER;
--cols          JTF_VARCHAR2_TABLE_4000;
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	exec_id       := report_context.EXEC_ID;
	select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
	--cols       := JTF_VARCHAR2_TABLE_4000('');
	row_component := JTF_DIAG_ROW(exec_id,ui_node_id,NULL,0);
	RETURN row_component;
END CREATE_ROW;
FUNCTION CREATE_TREE(heading VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TREE IS
tree_component JTF_DIAG_TREE;
exec_id          NUMBER;
ui_node_id       NUMBER;
tree_heading     VARCHAR2(20000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF heading IS NOT NULL THEN
		tree_heading    := DBMS_XMLGEN.CONVERT(heading,0);
		exec_id         := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		tree_component := JTF_DIAG_TREE(exec_id,ui_node_id,tree_heading,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the tree is null');
	END IF;
	RETURN tree_component;
END CREATE_TREE;
FUNCTION CREATE_TREE_NODE(content VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_TREE_NODE IS
tree_node_component JTF_DIAG_TREE_NODE;
exec_id          NUMBER;
ui_node_id       NUMBER;
tree_content     VARCHAR2(20000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF content IS NOT NULL THEN
		tree_content    := DBMS_XMLGEN.CONVERT(content,0);
		exec_id         := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		tree_node_component := JTF_DIAG_TREE_NODE(exec_id,ui_node_id,tree_content,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the tree node is null');
	END IF;
	RETURN tree_node_component;
END CREATE_TREE_NODE;
FUNCTION CREATE_NOTE(content VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_NOTE IS
note_component JTF_DIAG_NOTE;
exec_id          NUMBER;
ui_node_id       NUMBER;
no_of_links	 NUMBER;
link_ids	 JTF_VARCHAR2_TABLE_4000;
note_content     VARCHAR2(20000);
content_lenght	 NUMBER;
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF content IS NOT NULL THEN
		note_content    := DBMS_XMLGEN.CONVERT(content,0);
		exec_id         := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		no_of_links	:= length(content)-length(replace(content,'?',''));
		IF no_of_links > 0 THEN
		   link_ids	:= JTF_VARCHAR2_TABLE_4000();
		   FOR x IN 1 .. no_of_links
		   LOOP
			link_ids.EXTEND;
			link_ids(x) := '0';
		   END LOOP;
		END IF;

		note_component := JTF_DIAG_NOTE(exec_id,ui_node_id,note_content,no_of_links,link_ids,0,null);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the note is null');
	END IF;
	RETURN note_component;
END CREATE_NOTE;

FUNCTION CREATE_METALINK(linkText VARCHAR2, note_id VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_LINK
IS
link_component JTF_DIAG_LINK;
exec_id          NUMBER;
ui_node_id       NUMBER;
link_text_content   VARCHAR2(20000);
link_url_content   VARCHAR2(20000);
metalink_url        VARCHAR2(20000);
BEGIN
        VALIDATE_REPORT_CONTEXT(report_context);
	IF linkText IS NOT NULL  AND note_id IS NOT NULL THEN
		link_text_content := DBMS_XMLGEN.CONVERT(linkText,0);
                metalink_url      := FND_PROFILE.value('OAM_DIAG_METALINK_URL');
                metalink_url      := metalink_url || note_id;
		link_url_content  := DBMS_XMLGEN.CONVERT(metalink_url,0);
		exec_id           := report_context.EXEC_ID;
		select JTF_DIAGNOSTIC_REPORT_S.nextval into ui_node_id from dual;
		link_component := JTF_DIAG_LINK(exec_id,ui_node_id,link_text_content,link_url_content,0);
	ELSE
		RAISE_APPLICATION_ERROR(-20100,'The content provided for the link is null');
	END IF;
	RETURN link_component;
END CREATE_METALINK;

FUNCTION CREATE_METALINK(note_id VARCHAR2,report_context JTF_DIAG_REPORT_CONTEXT) RETURN JTF_DIAG_LINK
IS
link_component JTF_DIAG_LINK;
BEGIN
    link_component := CREATE_METALINK(note_id,note_id,report_context);
    RETURN link_component;
END CREATE_METALINK;

END JTF_DIAG_REPORT_FACTORY;


/
