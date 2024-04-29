--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_ITEM_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_ITEM_CONTEXTS_PKG" as
/* $Header: hrticlct.pkb 115.4 2002/12/11 07:26:00 raranjan noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEMPLATE_ITEM_CONTEXT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_ITEM_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_ITEM_CONTEXT_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_TEMPLATE_ITEM_CONTEXTS_B
    where TEMPLATE_ITEM_CONTEXT_ID = X_TEMPLATE_ITEM_CONTEXT_ID
    ;
begin
  insert into HR_TEMPLATE_ITEM_CONTEXTS_B (
    TEMPLATE_ITEM_CONTEXT_ID,
    OBJECT_VERSION_NUMBER,
    TEMPLATE_ITEM_ID,
    CONTEXT_TYPE,
    ITEM_CONTEXT_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE
  ) values(
    X_TEMPLATE_ITEM_CONTEXT_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TEMPLATE_ITEM_ID,
    X_CONTEXT_TYPE,
    X_ITEM_CONTEXT_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TEMPLATE_ITEM_CONTEXT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_ITEM_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_ITEM_CONTEXT_ID in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      TEMPLATE_ITEM_ID,
      CONTEXT_TYPE,
      ITEM_CONTEXT_ID
    from HR_TEMPLATE_ITEM_CONTEXTS_B
    where TEMPLATE_ITEM_CONTEXT_ID = X_TEMPLATE_ITEM_CONTEXT_ID
    for update of TEMPLATE_ITEM_CONTEXT_ID nowait;
begin
  for tlinfo in c1 loop
          if (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.TEMPLATE_ITEM_ID = X_TEMPLATE_ITEM_ID)
          AND (tlinfo.CONTEXT_TYPE = X_CONTEXT_TYPE)
          AND (tlinfo.ITEM_CONTEXT_ID = X_ITEM_CONTEXT_ID)
       then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_TEMPLATE_ITEM_CONTEXT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TEMPLATE_ITEM_ID in NUMBER,
  X_CONTEXT_TYPE in VARCHAR2,
  X_ITEM_CONTEXT_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_TEMPLATE_ITEM_CONTEXTS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TEMPLATE_ITEM_ID = X_TEMPLATE_ITEM_ID,
    CONTEXT_TYPE = X_CONTEXT_TYPE,
    ITEM_CONTEXT_ID = X_ITEM_CONTEXT_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEMPLATE_ITEM_CONTEXT_ID = X_TEMPLATE_ITEM_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEMPLATE_ITEM_CONTEXT_ID in NUMBER
) is
begin
  delete from HR_TEMPLATE_ITEM_CONTEXTS_B
  where TEMPLATE_ITEM_CONTEXT_ID = X_TEMPLATE_ITEM_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_TEMPLATE_NAME in VARCHAR2,
  X_TERRITORY_SHORT_NAME in VARCHAR2,
  X_FULL_ITEM_NAME in VARCHAR2,
  X_RADIO_BUTTON_NAME in VARCHAR2,
  X_SEGMENT1 in VARCHAR2,
  X_SEGMENT2 in VARCHAR2,
  X_SEGMENT3 in VARCHAR2,
  X_SEGMENT4 in VARCHAR2,
  X_SEGMENT5 in VARCHAR2,
  X_SEGMENT6 in VARCHAR2,
  X_SEGMENT7 in VARCHAR2,
  X_SEGMENT8 in VARCHAR2,
  X_SEGMENT9 in VARCHAR2,
  X_SEGMENT10 in VARCHAR2,
  X_SEGMENT11 in VARCHAR2,
  X_SEGMENT12 in VARCHAR2,
  X_SEGMENT13 in VARCHAR2,
  X_SEGMENT14 in VARCHAR2,
  X_SEGMENT15 in VARCHAR2,
  X_SEGMENT16 in VARCHAR2,
  X_SEGMENT17 in VARCHAR2,
  X_SEGMENT18 in VARCHAR2,
  X_SEGMENT19 in VARCHAR2,
  X_SEGMENT20 in VARCHAR2,
  X_SEGMENT21 in VARCHAR2,
  X_SEGMENT22 in VARCHAR2,
  X_SEGMENT23 in VARCHAR2,
  X_SEGMENT24 in VARCHAR2,
  X_SEGMENT25 in VARCHAR2,
  X_SEGMENT26 in VARCHAR2,
  X_SEGMENT27 in VARCHAR2,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_ID_FLEX_STRUCTURE_CODE in VARCHAR2,
  X_ID_FLEX_CODE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_CONTEXT_TYPE in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_ITEM_ID NUMBER;
  X_TEMPLATE_ITEM_ID NUMBER;
  X_TEMPLATE_ITEM_CONTEXT_ID NUMBER;
  X_ITEM_PROPERTY_ID NUMBER;
  X_ITEM_CONTEXT_ID NUMBER;
begin
  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select form_item_id
 into x_form_item_id
 from hr_form_items_b
 where full_item_name = x_full_item_name
 and application_id = x_application_id
 and form_id = x_form_id
 and (  radio_button_name = x_radio_button_name
     or (radio_button_name is null and x_radio_button_name is null) );

 select hti.template_item_id
 into x_template_item_id
 from hr_form_templates_b hft
      ,hr_template_items_b hti
 where hti.form_item_id = x_form_item_id
 and hti.form_template_id = hft.form_template_id
 and hft.form_id = x_form_id
 and hft.application_id = x_application_id
 and (  (legislation_code is null and x_territory_short_name is null)
     or (legislation_code = x_territory_short_name) )
 and hft.template_name = x_template_name;

 select item_context_id
 into x_item_context_id
 from hr_item_contexts hic
      ,fnd_id_flex_structures fifs
 where nvl(hic.segment1,hr_api.g_varchar2) = nvl(x_segment1,hr_api.g_varchar2)
 and nvl(hic.segment2,hr_api.g_varchar2) = nvl(x_segment2,hr_api.g_varchar2)
 and nvl(hic.segment3,hr_api.g_varchar2) = nvl(x_segment3,hr_api.g_varchar2)
 and nvl(hic.segment4,hr_api.g_varchar2) = nvl(x_segment4,hr_api.g_varchar2)
 and nvl(hic.segment5,hr_api.g_varchar2) = nvl(x_segment5,hr_api.g_varchar2)
 and nvl(hic.segment6,hr_api.g_varchar2) = nvl(x_segment6,hr_api.g_varchar2)
 and nvl(hic.segment7,hr_api.g_varchar2) = nvl(x_segment7,hr_api.g_varchar2)
 and nvl(hic.segment8,hr_api.g_varchar2) = nvl(x_segment8,hr_api.g_varchar2)
 and nvl(hic.segment9,hr_api.g_varchar2) = nvl(x_segment9,hr_api.g_varchar2)
 and nvl(hic.segment10,hr_api.g_varchar2) = nvl(x_segment10,hr_api.g_varchar2)
 and nvl(hic.segment11,hr_api.g_varchar2) = nvl(x_segment11,hr_api.g_varchar2)
 and nvl(hic.segment12,hr_api.g_varchar2) = nvl(x_segment12,hr_api.g_varchar2)
 and nvl(hic.segment13,hr_api.g_varchar2) = nvl(x_segment13,hr_api.g_varchar2)
 and nvl(hic.segment14,hr_api.g_varchar2) = nvl(x_segment14,hr_api.g_varchar2)
 and nvl(hic.segment15,hr_api.g_varchar2) = nvl(x_segment15,hr_api.g_varchar2)
 and nvl(hic.segment16,hr_api.g_varchar2) = nvl(x_segment16,hr_api.g_varchar2)
 and nvl(hic.segment17,hr_api.g_varchar2) = nvl(x_segment17,hr_api.g_varchar2)
 and nvl(hic.segment18,hr_api.g_varchar2) = nvl(x_segment18,hr_api.g_varchar2)
 and nvl(hic.segment19,hr_api.g_varchar2) = nvl(x_segment19,hr_api.g_varchar2)
 and nvl(hic.segment20,hr_api.g_varchar2) = nvl(x_segment20,hr_api.g_varchar2)
 and nvl(hic.segment21,hr_api.g_varchar2) = nvl(x_segment21,hr_api.g_varchar2)
 and nvl(hic.segment22,hr_api.g_varchar2) = nvl(x_segment22,hr_api.g_varchar2)
 and nvl(hic.segment23,hr_api.g_varchar2) = nvl(x_segment23,hr_api.g_varchar2)
 and nvl(hic.segment24,hr_api.g_varchar2) = nvl(x_segment24,hr_api.g_varchar2)
 and nvl(hic.segment25,hr_api.g_varchar2) = nvl(x_segment25,hr_api.g_varchar2)
 and nvl(hic.segment26,hr_api.g_varchar2) = nvl(x_segment26,hr_api.g_varchar2)
 and nvl(hic.segment27,hr_api.g_varchar2) = nvl(x_segment27,hr_api.g_varchar2)
 and nvl(hic.segment28,hr_api.g_varchar2) = nvl(x_segment28,hr_api.g_varchar2)
 and nvl(hic.segment29,hr_api.g_varchar2) = nvl(x_segment29,hr_api.g_varchar2)
 and nvl(hic.segment30,hr_api.g_varchar2) = nvl(x_segment30,hr_api.g_varchar2)
 and hic.id_flex_num = fifs.id_flex_num
 and fifs.application_id = x_application_id
 and fifs.id_flex_structure_code = x_id_flex_structure_code
 and fifs.id_flex_code = x_id_flex_code;

 begin
  select template_item_context_id
  into x_template_item_context_id
  from hr_template_item_contexts_b ticb
  where ticb.template_item_id = x_template_item_id
  and ticb.item_context_id = x_item_context_id;
 exception
   when no_data_found then
     select hr_template_item_contexts_b_s.nextval
     into x_template_item_context_id
     from dual;
  end;

 begin
   UPDATE_ROW (
     X_TEMPLATE_ITEM_CONTEXT_ID,
     to_number(X_OBJECT_VERSION_NUMBER),
     X_TEMPLATE_ITEM_ID,
     X_CONTEXT_TYPE,
     X_ITEM_CONTEXT_ID,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
   );

 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_TEMPLATE_ITEM_CONTEXT_ID,
       to_number(X_OBJECT_VERSION_NUMBER),
       X_TEMPLATE_ITEM_ID,
       X_CONTEXT_TYPE,
       X_ITEM_CONTEXT_ID,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);
 end;
end LOAD_ROW;
end HR_TEMPLATE_ITEM_CONTEXTS_PKG;

/
