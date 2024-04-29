--------------------------------------------------------
--  DDL for Package Body AST_NOTE_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_NOTE_PACKAGE" AS
/* $Header: astnoteb.pls 120.1 2005/06/01 03:35:27 appldev  $ */
-- Start of Comments
-- Package name     : ast_note_package
-- Purpose          : Function to provide object details in AST_NOTE_CONTEXTS_V view
-- History          :
-- NOTE             :
-- End of Comments

procedure note_context_info (
	p_sql_statement IN varchar2,
	p_object_info IN OUT NOCOPY /* file.sql.39 change */ varchar2,
	p_object_id IN number) is
BEGIN
	EXECUTE IMMEDIATE p_sql_statement INTO p_object_info USING p_object_id;
END note_context_info;

function read_clob (
	p_clob CLOB)
return VARCHAR2 is
  amount BINARY_INTEGER := 32000;
  clob_size INTEGER;
  buffer VARCHAR2(32000);
BEGIN
  if p_clob is null then
	return null;
  else
	clob_size := dbms_lob.getlength(p_clob);
	if clob_size < amount then
		amount := clob_size;
	end if;
	if clob_size = 0 then
		return null;
	end if;
	dbms_lob.read(p_clob, amount, 1, buffer);
	if amount > 0 then
		return buffer;
	else
		return null;
	end if;
  end if;
END read_clob;

function read_clob (
	p_note_id NUMBER)
return VARCHAR2 is
  amount BINARY_INTEGER := 32000;
  clob_size INTEGER;
  buffer VARCHAR2(32000);

  p_clob CLOB;
  cursor c_clob (p_note_id NUMBER) is
	select notes_detail
     from jtf_notes_tl
     where jtf_note_id = p_note_id
     and language = userenv('LANG');

BEGIN
  open c_clob(p_note_id);
  fetch c_clob into p_clob;
  close c_clob;

  if p_clob is null then
	return null;
  else
	clob_size := dbms_lob.getlength(p_clob);
	if clob_size < amount then
		amount := clob_size;
	end if;
	if clob_size = 0 then
		return null;
	end if;
	dbms_lob.read(p_clob, amount, 1, buffer);
	if amount > 0 then
		return buffer;
	else
		return null;
	end if;
  end if;
END read_clob;

function party_type_info (
	p_object_id NUMBER)
return VARCHAR2 is
  l_party_type_name VARCHAR2(2000);
  cursor C_party_type_name (p_object_id NUMBER) is
  select a.meaning
  from ar_lookups a, hz_parties p
  where p.party_id = p_object_id
  and a.lookup_code = p.party_type
  and a.lookup_type = 'PARTY_TYPE';

BEGIN
  l_party_type_name := 'Party';

  if p_object_id is not null then
	open C_party_type_name (p_object_id);
	fetch C_party_type_name into l_party_type_name;
	close C_party_type_name;
  end if;

  return l_party_type_name;

END party_type_info;

function note_context_info (
	p_select_id VARCHAR2,
	p_select_name VARCHAR2,
	p_select_details VARCHAR2,
	p_from_table VARCHAR2,
	p_where_clause VARCHAR2,
	p_object_id NUMBER)
return VARCHAR2 is
  l_sql_statement VARCHAR2(2000);
  l_object_info VARCHAR2(2000);
BEGIN
  l_sql_statement := null;
  l_object_info := null;

  if p_from_table is not null and p_select_id is not null and p_object_id is not null then
     if p_select_name is not null then
          l_sql_statement := 'SELECT ' || p_select_name || ' ';
     end if;
     if p_select_details is not null then
          if l_sql_statement is not null then
               l_sql_statement := l_sql_statement || ' || '' - '' || ';
          else
               l_sql_statement := 'SELECT ';
          end if;
          l_sql_statement := l_sql_statement || p_select_details || ' ';
     end if;
     if l_sql_statement is not null then
          l_sql_statement := l_sql_statement || 'FROM ' || p_from_table || ' ';
          l_sql_statement := l_sql_statement || 'WHERE ' || p_select_id || ' = :p_object_id ';
	          if p_where_clause is not null then
               l_sql_statement := l_sql_statement || 'AND ' || p_where_clause;
          end if;
     end if;
  end if;

  if l_sql_statement is not null then
   begin
	EXECUTE IMMEDIATE l_sql_statement INTO l_object_info USING p_object_id;
   exception
	when others then l_object_info := null;
   end;
  end if;

  return l_object_info;

END note_context_info;
END ast_note_package;

/
