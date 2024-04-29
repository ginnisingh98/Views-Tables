--------------------------------------------------------
--  DDL for Package Body PAY_DBITL_UPDATE_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DBITL_UPDATE_ERRORS_PKG" as
/* $Header: pydbtlue.pkb 120.1 2006/11/10 17:26:54 arashid noship $ */
------------------------------- insert_row -------------------------------
procedure insert_row
(p_user_name       in varchar2
,p_user_entity_id  in number
,p_translated_name in varchar2
,p_message_text    in varchar2
) is
l_rowid varchar2(2000);
begin
  insert_row
  (p_user_name       => p_user_name
  ,p_user_entity_id  => p_user_entity_id
  ,p_translated_name => p_translated_name
  ,p_message_text    => p_message_text
  ,p_rowid           => l_rowid
  );
end insert_row;

procedure insert_row
(p_user_name       in varchar2
,p_user_entity_id  in number
,p_translated_name in varchar2
,p_message_text    in varchar2
,p_rowid              out nocopy varchar2
) is
begin
  insert into pay_dbitl_update_errors
  (user_name
  ,user_entity_id
  ,translated_name
  ,message_text
  )
  values
  (p_user_name
  ,p_user_entity_id
  ,p_translated_name
  ,p_message_text
  )
  returning rowid into p_rowid;
end insert_row;


------------------------------ delete_rows -------------------------------
procedure delete_rows
(p_user_name       in varchar2
,p_user_entity_id  in number
,p_translated_name in varchar2
) is
begin
  delete pay_dbitl_update_errors
  where  user_name = p_user_name
  and    user_entity_id = p_user_entity_id
  and    translated_name = p_translated_name
  ;
end delete_rows;


procedure delete_rows
(p_rowids in dbms_sql.varchar2s
) is
begin
  if p_rowids.count = 0 then
    return;
  end if;

  forall i in 1 .. p_rowids.count
    delete pay_dbitl_update_errors
    where  rowid = p_rowids(i);
end delete_rows;

------------------------------- delete_row -------------------------------
procedure delete_row
(p_rowid in varchar2
) is
begin
  delete pay_dbitl_update_errors
  where rowid = p_rowid
  ;
end delete_row;

----------------------------- fetch_all_rows -----------------------------
procedure fetch_all_rows
(p_rowids   out nocopy dbms_sql.varchar2s
,p_messages out nocopy dbms_sql.varchar2_table
) is
begin
  select rowid
  ,      message_text bulk collect
  into   p_rowids
  ,      p_messages
  from   pay_dbitl_update_errors
  ;
end fetch_all_rows;

end pay_dbitl_update_errors_pkg;

/
