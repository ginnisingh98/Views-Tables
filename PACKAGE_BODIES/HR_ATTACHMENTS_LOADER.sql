--------------------------------------------------------
--  DDL for Package Body HR_ATTACHMENTS_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ATTACHMENTS_LOADER" as
/* $Header: hratload.pkb 115.1 99/10/12 07:04:38 porting ship $ */
--
procedure cre_or_sel_att_form_function(p_function_name       IN     VARCHAR2
                                      ,p_function_type       IN     VARCHAR2
                                      ,p_attachment_function_id OUT NUMBER
                                      ,p_application_id         OUT NUMBER) is
--
cursor function_id is
select form_id func_id
, application_id app_id
from fnd_form_vl
where form_name=p_function_name
and p_function_type='O'
UNION
select function_id func_id
, application_id app_is
from fnd_form_functions_vl
where function_name=p_function_name
and p_function_type='F';
--
cursor att_func_exists(p_function_id NUMBER) is
select attachment_function_id
from fnd_attachment_functions
where function_type=p_function_type
and function_id=p_function_id;
--
l_function_id NUMBER;
l_application_id NUMBER;
l_attachment_function_id NUMBER;
--
begin
-- look to see if the form function exists
open function_id;
fetch function_id into l_function_id,l_application_id;
if(function_id%found) then
  close function_id;
-- if the function exists, look to see if the attachment function exists
  open att_func_exists(l_function_id);
  fetch att_func_exists into l_attachment_function_id;
  if (att_func_exists%NOTFOUND) then
    close att_func_exists;
-- if it doesn't exist then add it
    select fnd_attachment_functions_s.nextval
    into l_attachment_function_id
    from sys.dual;
--
    insert into fnd_attachment_functions (
    attachment_function_id,
    function_type,
    function_id,
    function_name,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    application_id,
    session_context_field,
    enabled_flag) VALUES (
    l_attachment_function_id,
    p_function_type,
    l_function_id,
    p_function_name,
    sysdate,
    1,
    sysdate,
    1,
    1,
    l_application_id,
    '',
    'Y');
    hr_utility.set_location('Added attachmnent for '||p_function_name,10);
  else
    close att_func_exists;
    hr_utility.set_location('Attachmnent exists for '||p_function_name,20);
  end if;
  p_attachment_function_id:=l_attachment_function_id;
  p_application_id:=l_application_id;
else
  close function_id;
  hr_utility.set_location('Couldnt find function '||p_function_name,30);
  p_attachment_function_id:=null;
  p_application_id:=null;
end if;
end cre_or_sel_att_form_function;
--
procedure associate_category(p_attachment_function_id IN NUMBER
                            ,p_category_name          IN VARCHAR2) is
--
cursor att_func_exists is
select 1
from fnd_attachment_functions
where attachment_function_id=p_attachment_function_id;
--
cursor categories is
select category_id
from fnd_doc_categories_active_vl
where name=p_category_name;
--
cursor category_exists(p_category_id NUMBER) is
select doc_category_usage_id
from fnd_doc_category_usages
where attachment_function_id=p_attachment_function_id
and category_id=p_category_id;
--
l_category_id NUMBER;
l_dummy NUMBER;
l_doc_category_usages_id NUMBER;
--
begin
-- look to see if the attachment function exists
  open att_func_exists;
  fetch att_func_exists into l_dummy;
  if(att_func_exists%found) then
  close att_func_exists;
--
-- look to see it the category exists
-- insert the document categories;
  open categories;
  fetch categories into l_category_id;
  if(categories%found) then
    close categories;
-- look to see if the category is associated with the attachment
    open category_exists(l_category_id);
    fetch category_exists into l_doc_category_usages_id;
    if(category_exists%NOTFOUND) then
      close category_exists;
 -- if not associated, then add it
      select fnd_doc_category_usages_s.nextval
      into l_doc_category_usages_id
      from sys.dual;
--
      INSERT INTO fnd_doc_category_usages(
      doc_category_usage_id,
      category_id,
      attachment_function_id,
      enabled_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login) VALUES (
      l_doc_category_usages_id,
      l_category_id,
      p_attachment_function_id,
      'Y',
      sysdate,
      1,
      sysdate,
      1,
      1);
      hr_utility.set_location('Attached category '||P_category_name,10);
    else
      close category_exists;
      hr_utility.set_location('Had category '||P_category_name,20);
    end if;
  else
    close categories;
    hr_utility.set_location('Couldnt find category '||P_category_name,30);
  end if;
  else
  close att_func_exists;
  hr_utility.set_location('Couldnt find function ',40);
  end if;
end associate_category;

procedure create_or_update_block
          (p_attachment_function_id  IN     NUMBER
          ,p_block_name              IN     VARCHAR2
          ,p_query_flag              IN     VARCHAR2 default 'N'
          ,p_security_type           IN     NUMBER   default 4
          ,p_org_context_field       IN     VARCHAR2 default null
          ,p_set_of_books_context_field  IN VARCHAR2 default null
          ,p_business_unit_context_field IN VARCHAR2 default null
          ,p_context1_field          IN     VARCHAR2 default null
          ,p_context2_field          IN     VARCHAR2 default null
          ,p_context3_field          IN     VARCHAR2 default null
          ,p_attachment_blk_id          OUT NUMBER) is
--
cursor att_func_exists is
select 1
from fnd_attachment_functions
where attachment_function_id=p_attachment_function_id;
--
cursor block_exists is
select attachment_blk_id
from fnd_attachment_blocks
where block_name=p_block_name
and attachment_function_id=p_attachment_function_id;
--
l_attachment_blk_id NUMBER;
l_dummy NUMBER;
--
begin
-- check to see if the attachment function exists
  open att_func_exists;
  fetch att_func_exists into l_dummy;
  if(att_func_exists%found) then
  close att_func_exists;
--
-- look to see of the block already exists
  open block_exists;
  fetch block_exists into l_attachment_blk_id;
  if(block_exists%NOTFOUND) then
    close block_exists;
--  if it doesn't then add it
    select fnd_attachment_blocks_s.nextval
    into l_attachment_blk_id
    from sys.dual;
--
    INSERT INTO fnd_attachment_blocks (
    attachment_blk_id,
    attachment_function_id,
    block_name,
    query_flag,
    security_type,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    org_context_field,
    set_of_books_context_field,
    business_unit_context_field,
    context1_field,
    context2_field,
    context3_field) VALUES (
    l_attachment_blk_id,
    p_attachment_function_id,
    p_block_name,
    p_query_flag,
    p_security_type,
    sysdate,
    1,
    sysdate,
    1,
    1,
    p_org_context_field,
    p_set_of_books_context_field,
    p_business_unit_context_field,
    p_context1_field,
    p_context2_field,
    p_context3_field);
    p_attachment_blk_id:=l_attachment_blk_id;
    hr_utility.set_location('Added block '||p_block_name,10);
  else
    close block_exists;
-- if it does exist then update it
    update fnd_attachment_blocks
    set
    query_flag=p_query_flag,
    security_type=p_security_type,
    creation_date=sysdate,
    created_by=1,
    last_update_date=sysdate,
    last_updated_by=1,
    last_update_login=1,
    org_context_field=p_org_context_field,
    set_of_books_context_field=p_set_of_books_context_field,
    business_unit_context_field=p_business_unit_context_field,
    context1_field=p_context1_field,
    context2_field=p_context2_field,
    context3_field=p_context3_field
    where attachment_blk_id=l_attachment_blk_id;
    p_attachment_blk_id:=l_attachment_blk_id;
    hr_utility.set_location('Updated block '||p_block_name,20);
  end if;
  else
  close att_func_exists;
  hr_utility.set_location('Couldnt find function ',30);
  p_attachment_blk_id:=null;
  end if;
--
end create_or_update_block;
--
procedure create_or_select_entity
          (p_data_object_code IN     VARCHAR2
          ,p_entity_user_name IN     VARCHAR2 default null
          ,p_language_code    IN     VARCHAR2 default null
          ,p_application_id   IN     NUMBER   default null
          ,p_table_name       IN     VARCHAR2 default null
          ,p_entity_name      IN     VARCHAR2 default null
          ,p_pk1_column       IN     VARCHAR2 default null
          ,p_pk2_column       IN     VARCHAR2 default null
          ,p_pk3_column       IN     VARCHAR2 default null
          ,p_pk4_column       IN     VARCHAR2 default null
          ,p_pk5_column       IN     VARCHAR2 default null
          ,p_document_entity_id  OUT NUMBER) is

--
cursor entity_exists is
select document_entity_id
from fnd_document_entities
where data_object_code =p_data_object_code;
--
l_document_entity_id NUMBER;
--
begin
-- look to see if the entity is already defined
  open entity_exists;
  fetch entity_exists into l_document_entity_id;
  if(entity_exists%NOTFOUND) then
    close entity_exists;
--  if not then add it
    select fnd_document_entities_s.nextval
    into l_document_entity_id
    from sys.dual;
--
    insert into fnd_document_entities (
    DOCUMENT_ENTITY_ID,
    DATA_OBJECT_CODE,
    APPLICATION_ID,
    TABLE_NAME,
    ENTITY_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PK1_COLUMN,
    PK2_COLUMN,
    PK3_COLUMN,
    PK4_COLUMN,
    PK5_COLUMN ) VALUES (
    l_document_entity_id,
    p_data_object_code,
    p_application_id,
    p_table_name,
    p_entity_name,
    sysdate,
    1,
    sysdate,
    1,
    1,
    p_pk1_column,
    p_pk2_column,
    p_pk3_column,
    p_pk4_column,
    p_pk5_column);
-- and add the translation part
    insert into fnd_document_entities_tl (
    DOCUMENT_ENTITY_ID,
    DATA_OBJECT_CODE,
    LANGUAGE,
    USER_ENTITY_NAME,
    USER_ENTITY_PROMPT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE_LANG) VALUES (
    l_document_entity_id,
    p_data_object_code,
    p_language_code,
    p_entity_user_name,
    p_entity_user_name,
    sysdate,
    1,
    sysdate,
    1,
    1,
    p_language_code);
    hr_utility.set_location('Added entity '||p_data_object_code,10);
    p_document_entity_id:=l_document_entity_id;
  else
    close entity_exists;
    hr_utility.set_location('Found entity '||p_data_object_code,20);
    p_document_entity_id:=l_document_entity_id;
  end if;
end create_or_select_entity;
--
procedure attach_entity
          (p_attachment_blk_id      IN     NUMBER
          ,p_data_object_code       IN     VARCHAR2
          ,p_display_method         IN     VARCHAR2 default 'M'
          ,p_include_in_indicator_flag IN  VARCHAR2 default 'Y'
          ,p_indicator_in_view_flag IN     VARCHAR2 default 'N'
          ,p_pk1_field              IN     VARCHAR2 default null
          ,p_pk2_field              IN     VARCHAR2 default null
          ,p_pk3_field              IN     VARCHAR2 default null
          ,p_pk4_field              IN     VARCHAR2 default null
          ,p_pk5_field              IN     VARCHAR2 default null
          ,p_sql_statement          IN     VARCHAR2 default null
          ,p_query_permission_type  IN     VARCHAR2 default 'Y'
          ,p_insert_permission_type IN     VARCHAR2 default 'Y'
          ,p_update_permission_type IN     VARCHAR2 default 'Y'
          ,p_delete_permission_type IN     VARCHAR2 default 'Y'
          ,p_condition_field        IN     VARCHAR2 default null
          ,p_condition_operator     IN     VARCHAR2 default null
          ,p_condition_value1       IN     VARCHAR2 default null
          ,p_condition_value2       IN     VARCHAR2 default null
          ,p_attachment_blk_entity_id  OUT NUMBER) is
--
cursor block_exists is
select 1
from fnd_attachment_blocks
where attachment_blk_id=p_attachment_blk_id;
--
cursor block_entity_exists is
select attachment_blk_entity_id
from fnd_attachment_blk_entities
where data_object_code=p_data_object_code
and attachment_blk_id=p_attachment_blk_id;
--
l_attachment_blk_entity_id NUMBER;
l_dummy NUMBER;
--
begin
-- check that the block exists
  open block_exists;
  fetch block_exists into l_dummy;
  if(block_exists%found) then
  close block_exists;
-- look to see if the entity is already associcated with the block
  open block_entity_exists;
  fetch block_entity_exists into l_attachment_blk_entity_id;
  if(block_entity_exists%NOTFOUND) then
    close block_entity_exists;
-- if it is not then add it
    select fnd_attachment_blk_entities_s.nextval
    into l_attachment_blk_entity_id
    from sys.dual;
--
    INSERT INTO fnd_attachment_blk_entities (
    attachment_blk_entity_id,
    attachment_blk_id,
    data_object_code,
    display_method,
    include_in_indicator_flag,
    indicator_in_view_flag,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    pk1_field,
    pk2_field,
    pk3_field,
    pk4_field,
    pk5_field,
    sql_statement,
    query_permission_type,
    insert_permission_type,
    update_permission_type,
    delete_permission_type,
    condition_field,
    condition_operator,
    condition_value1,
    condition_value2)  VALUES (
    l_attachment_blk_entity_id,
    p_attachment_blk_id,
    p_data_object_code,
    p_display_method,
    p_include_in_indicator_flag,
    p_indicator_in_view_flag,
    sysdate,
    1,
    sysdate,
    1,
    1,
    p_pk1_field,
    p_pk2_field,
    p_pk3_field,
    p_pk4_field,
    p_pk5_field,
    p_sql_statement,
    p_query_permission_type,
    p_insert_permission_type,
    p_update_permission_type,
    p_delete_permission_type,
    p_condition_field,
    p_condition_operator,
    p_condition_value1,
    p_condition_value2);
    hr_utility.set_location('Added block entity '||p_data_object_code,10);
    p_attachment_blk_entity_id:=l_attachment_blk_entity_id;
  else
    close block_entity_exists;
-- if already exists then update it
    update fnd_attachment_blk_entities
    set
    display_method=p_display_method,
    include_in_indicator_flag=p_include_in_indicator_flag,
    indicator_in_view_flag=p_indicator_in_view_flag,
    creation_date=sysdate,
    created_by=1,
    last_update_date=sysdate,
    last_updated_by=1,
    last_update_login=1,
    pk1_field=p_pk1_field,
    pk2_field=p_pk2_field,
    pk3_field=p_pk3_field,
    pk4_field=p_pk4_field,
    pk5_field=p_pk5_field,
    sql_statement=p_sql_statement,
    query_permission_type=p_query_permission_type,
    insert_permission_type=p_insert_permission_type,
    update_permission_type=p_update_permission_type,
    delete_permission_type=p_delete_permission_type,
    condition_field=p_condition_field,
    condition_operator=p_condition_operator,
    condition_value1=p_condition_value1,
    condition_value2=p_condition_value2
    where attachment_blk_entity_id=l_attachment_blk_entity_id;
    hr_utility.set_location('Updated block entity '||p_data_object_code,20);
    p_attachment_blk_entity_id:=l_attachment_blk_entity_id;
  end if;
  else
    close block_exists;
    hr_utility.set_location('Couldnt find block ',30);
  end if;
end attach_entity;
--
end HR_ATTACHMENTS_LOADER;

/
