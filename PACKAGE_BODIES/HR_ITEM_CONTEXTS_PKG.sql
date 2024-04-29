--------------------------------------------------------
--  DDL for Package Body HR_ITEM_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITEM_CONTEXTS_PKG" as
/* $Header: hricxlct.pkb 115.1 2002/12/10 12:29:00 hjonnala noship $ */
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
  X_ITEM_CONTEXT_ID in NUMBER,
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
  X_SUMMARY_FLAG in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_ITEM_CONTEXTS
    where ITEM_CONTEXT_ID = X_ITEM_CONTEXT_ID
    ;
begin
  insert into HR_ITEM_CONTEXTS (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    SEGMENT1,
    SEGMENT2,
    SEGMENT3,
    SEGMENT4,
    SEGMENT5,
    SEGMENT6,
    SEGMENT7,
    SEGMENT8,
    SEGMENT9,
    SEGMENT10,
    SEGMENT11,
    SEGMENT12,
    SEGMENT13,
    SEGMENT14,
    SEGMENT15,
    SEGMENT16,
    SEGMENT17,
    SEGMENT18,
    SEGMENT19,
    SEGMENT20,
    SEGMENT21,
    SEGMENT22,
    SEGMENT23,
    SEGMENT24,
    SEGMENT25,
    SEGMENT26,
    SEGMENT27,
    SUMMARY_FLAG,
    ITEM_CONTEXT_ID,
    ID_FLEX_NUM,
    END_DATE_ACTIVE,
    SEGMENT28,
    SEGMENT29,
    SEGMENT30,
    LAST_UPDATE_DATE,
    START_DATE_ACTIVE,
    ENABLED_FLAG
  ) values(
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_SEGMENT1,
    X_SEGMENT2,
    X_SEGMENT3,
    X_SEGMENT4,
    X_SEGMENT5,
    X_SEGMENT6,
    X_SEGMENT7,
    X_SEGMENT8,
    X_SEGMENT9,
    X_SEGMENT10,
    X_SEGMENT11,
    X_SEGMENT12,
    X_SEGMENT13,
    X_SEGMENT14,
    X_SEGMENT15,
    X_SEGMENT16,
    X_SEGMENT17,
    X_SEGMENT18,
    X_SEGMENT19,
    X_SEGMENT20,
    X_SEGMENT21,
    X_SEGMENT22,
    X_SEGMENT23,
    X_SEGMENT24,
    X_SEGMENT25,
    X_SEGMENT26,
    X_SEGMENT27,
    X_SUMMARY_FLAG,
    X_ITEM_CONTEXT_ID,
    X_ID_FLEX_NUM,
    X_END_DATE_ACTIVE,
    X_SEGMENT28,
    X_SEGMENT29,
    X_SEGMENT30,
    X_LAST_UPDATE_DATE,
    X_START_DATE_ACTIVE,
    X_ENABLED_FLAG);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ITEM_CONTEXT_ID in NUMBER,
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
  X_SUMMARY_FLAG in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2
) is
  cursor c1 is select
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      SEGMENT21,
      SEGMENT22,
      SEGMENT23,
      SEGMENT24,
      SEGMENT25,
      SEGMENT26,
      SEGMENT27,
      SUMMARY_FLAG,
      ID_FLEX_NUM,
      END_DATE_ACTIVE,
      SEGMENT28,
      SEGMENT29,
      SEGMENT30,
      START_DATE_ACTIVE,
      ENABLED_FLAG
    from HR_ITEM_CONTEXTS
    where ITEM_CONTEXT_ID = X_ITEM_CONTEXT_ID
    for update of ITEM_CONTEXT_ID nowait;
begin
  for tlinfo in c1 loop
          if ((tlinfo.SEGMENT1 = X_SEGMENT1)
               OR ((tlinfo.SEGMENT1 is null) AND (X_SEGMENT1 is null)))
          AND ((tlinfo.SEGMENT2 = X_SEGMENT2)
               OR ((tlinfo.SEGMENT2 is null) AND (X_SEGMENT2 is null)))
          AND ((tlinfo.SEGMENT3 = X_SEGMENT3)
               OR ((tlinfo.SEGMENT3 is null) AND (X_SEGMENT3 is null)))
          AND ((tlinfo.SEGMENT4 = X_SEGMENT4)
               OR ((tlinfo.SEGMENT4 is null) AND (X_SEGMENT4 is null)))
          AND ((tlinfo.SEGMENT5 = X_SEGMENT5)
               OR ((tlinfo.SEGMENT5 is null) AND (X_SEGMENT5 is null)))
          AND ((tlinfo.SEGMENT6 = X_SEGMENT6)
               OR ((tlinfo.SEGMENT6 is null) AND (X_SEGMENT6 is null)))
          AND ((tlinfo.SEGMENT7 = X_SEGMENT7)
               OR ((tlinfo.SEGMENT7 is null) AND (X_SEGMENT7 is null)))
          AND ((tlinfo.SEGMENT8 = X_SEGMENT8)
               OR ((tlinfo.SEGMENT8 is null) AND (X_SEGMENT8 is null)))
          AND ((tlinfo.SEGMENT9 = X_SEGMENT9)
               OR ((tlinfo.SEGMENT9 is null) AND (X_SEGMENT9 is null)))
          AND ((tlinfo.SEGMENT10 = X_SEGMENT10)
               OR ((tlinfo.SEGMENT10 is null) AND (X_SEGMENT10 is null)))
          AND ((tlinfo.SEGMENT11 = X_SEGMENT11)
               OR ((tlinfo.SEGMENT11 is null) AND (X_SEGMENT11 is null)))
          AND ((tlinfo.SEGMENT12 = X_SEGMENT12)
               OR ((tlinfo.SEGMENT12 is null) AND (X_SEGMENT12 is null)))
          AND ((tlinfo.SEGMENT13 = X_SEGMENT13)
               OR ((tlinfo.SEGMENT13 is null) AND (X_SEGMENT13 is null)))
          AND ((tlinfo.SEGMENT14 = X_SEGMENT14)
               OR ((tlinfo.SEGMENT14 is null) AND (X_SEGMENT14 is null)))
          AND ((tlinfo.SEGMENT15 = X_SEGMENT15)
               OR ((tlinfo.SEGMENT15 is null) AND (X_SEGMENT15 is null)))
          AND ((tlinfo.SEGMENT16 = X_SEGMENT16)
               OR ((tlinfo.SEGMENT16 is null) AND (X_SEGMENT16 is null)))
          AND ((tlinfo.SEGMENT17 = X_SEGMENT17)
               OR ((tlinfo.SEGMENT17 is null) AND (X_SEGMENT17 is null)))
          AND ((tlinfo.SEGMENT18 = X_SEGMENT18)
               OR ((tlinfo.SEGMENT18 is null) AND (X_SEGMENT18 is null)))
          AND ((tlinfo.SEGMENT19 = X_SEGMENT19)
               OR ((tlinfo.SEGMENT19 is null) AND (X_SEGMENT19 is null)))
          AND ((tlinfo.SEGMENT20 = X_SEGMENT20)
               OR ((tlinfo.SEGMENT20 is null) AND (X_SEGMENT20 is null)))
          AND ((tlinfo.SEGMENT21 = X_SEGMENT21)
               OR ((tlinfo.SEGMENT21 is null) AND (X_SEGMENT21 is null)))
          AND ((tlinfo.SEGMENT22 = X_SEGMENT22)
               OR ((tlinfo.SEGMENT22 is null) AND (X_SEGMENT22 is null)))
          AND ((tlinfo.SEGMENT23 = X_SEGMENT23)
               OR ((tlinfo.SEGMENT23 is null) AND (X_SEGMENT23 is null)))
          AND ((tlinfo.SEGMENT24 = X_SEGMENT24)
               OR ((tlinfo.SEGMENT24 is null) AND (X_SEGMENT24 is null)))
          AND ((tlinfo.SEGMENT25 = X_SEGMENT25)
               OR ((tlinfo.SEGMENT25 is null) AND (X_SEGMENT25 is null)))
          AND ((tlinfo.SEGMENT26 = X_SEGMENT26)
               OR ((tlinfo.SEGMENT26 is null) AND (X_SEGMENT26 is null)))
          AND ((tlinfo.SEGMENT27 = X_SEGMENT27)
               OR ((tlinfo.SEGMENT27 is null) AND (X_SEGMENT27 is null)))
          AND (tlinfo.SUMMARY_FLAG = X_SUMMARY_FLAG)
          AND (tlinfo.ID_FLEX_NUM = X_ID_FLEX_NUM)
          AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
               OR ((tlinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
          AND ((tlinfo.SEGMENT28 = X_SEGMENT28)
               OR ((tlinfo.SEGMENT28 is null) AND (X_SEGMENT28 is null)))
          AND ((tlinfo.SEGMENT29 = X_SEGMENT29)
               OR ((tlinfo.SEGMENT29 is null) AND (X_SEGMENT29 is null)))
          AND ((tlinfo.SEGMENT30 = X_SEGMENT30)
               OR ((tlinfo.SEGMENT30 is null) AND (X_SEGMENT30 is null)))
          AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
               OR ((tlinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
          AND (tlinfo.ENABLED_FLAG = X_ENABLED_FLAG)
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
  X_ITEM_CONTEXT_ID in NUMBER,
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
  X_SUMMARY_FLAG in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_END_DATE_ACTIVE in DATE,
  X_SEGMENT28 in VARCHAR2,
  X_SEGMENT29 in VARCHAR2,
  X_SEGMENT30 in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_ENABLED_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_ITEM_CONTEXTS set
    SEGMENT1 = X_SEGMENT1,
    SEGMENT2 = X_SEGMENT2,
    SEGMENT3 = X_SEGMENT3,
    SEGMENT4 = X_SEGMENT4,
    SEGMENT5 = X_SEGMENT5,
    SEGMENT6 = X_SEGMENT6,
    SEGMENT7 = X_SEGMENT7,
    SEGMENT8 = X_SEGMENT8,
    SEGMENT9 = X_SEGMENT9,
    SEGMENT10 = X_SEGMENT10,
    SEGMENT11 = X_SEGMENT11,
    SEGMENT12 = X_SEGMENT12,
    SEGMENT13 = X_SEGMENT13,
    SEGMENT14 = X_SEGMENT14,
    SEGMENT15 = X_SEGMENT15,
    SEGMENT16 = X_SEGMENT16,
    SEGMENT17 = X_SEGMENT17,
    SEGMENT18 = X_SEGMENT18,
    SEGMENT19 = X_SEGMENT19,
    SEGMENT20 = X_SEGMENT20,
    SEGMENT21 = X_SEGMENT21,
    SEGMENT22 = X_SEGMENT22,
    SEGMENT23 = X_SEGMENT23,
    SEGMENT24 = X_SEGMENT24,
    SEGMENT25 = X_SEGMENT25,
    SEGMENT26 = X_SEGMENT26,
    SEGMENT27 = X_SEGMENT27,
    SUMMARY_FLAG = X_SUMMARY_FLAG,
    ID_FLEX_NUM = X_ID_FLEX_NUM,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SEGMENT28 = X_SEGMENT28,
    SEGMENT29 = X_SEGMENT29,
    SEGMENT30 = X_SEGMENT30,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ITEM_CONTEXT_ID = X_ITEM_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ITEM_CONTEXT_ID in NUMBER
) is
begin
  delete from HR_ITEM_CONTEXTS
  where ITEM_CONTEXT_ID = X_ITEM_CONTEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
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
  X_SUMMARY_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in VARCHAR2,
  X_END_DATE_ACTIVE in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_ID_FLEX_NUM NUMBER;
  X_APPLICATION_ID NUMBER;
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

 select id_flex_num
 into x_id_flex_num
 from fnd_id_flex_structures fifs
 where fifs.application_id = x_application_id
 and fifs.id_flex_structure_code = x_id_flex_structure_code
 and fifs.id_flex_code = x_id_flex_code;

 begin

 select item_context_id
 into x_item_context_id
 from hr_item_contexts hic
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
 and hic.id_flex_num = x_id_flex_num;

 exception
   when no_data_found then
     select hr_item_contexts_s.nextval
     into x_item_context_id
     from dual;
  end;

 begin
   UPDATE_ROW (
     X_ITEM_CONTEXT_ID,
     X_SEGMENT1,
     X_SEGMENT2,
     X_SEGMENT3,
     X_SEGMENT4,
     X_SEGMENT5,
     X_SEGMENT6,
     X_SEGMENT7,
     X_SEGMENT8,
     X_SEGMENT9,
     X_SEGMENT10,
     X_SEGMENT11,
     X_SEGMENT12,
     X_SEGMENT13,
     X_SEGMENT14,
     X_SEGMENT15,
     X_SEGMENT16,
     X_SEGMENT17,
     X_SEGMENT18,
     X_SEGMENT19,
     X_SEGMENT20,
     X_SEGMENT21,
     X_SEGMENT22,
     X_SEGMENT23,
     X_SEGMENT24,
     X_SEGMENT25,
     X_SEGMENT26,
     X_SEGMENT27,
     X_SUMMARY_FLAG,
     X_ID_FLEX_NUM,
     to_date(X_END_DATE_ACTIVE,'DD/MM/YYYY'),
     X_SEGMENT28,
     X_SEGMENT29,
     X_SEGMENT30,
     to_date(X_START_DATE_ACTIVE,'DD/MM/YYYY'),
     X_ENABLED_FLAG,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
   );

 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_ITEM_CONTEXT_ID,
       X_SEGMENT1,
       X_SEGMENT2,
       X_SEGMENT3,
       X_SEGMENT4,
       X_SEGMENT5,
       X_SEGMENT6,
       X_SEGMENT7,
       X_SEGMENT8,
       X_SEGMENT9,
       X_SEGMENT10,
       X_SEGMENT11,
       X_SEGMENT12,
       X_SEGMENT13,
       X_SEGMENT14,
       X_SEGMENT15,
       X_SEGMENT16,
       X_SEGMENT17,
       X_SEGMENT18,
       X_SEGMENT19,
       X_SEGMENT20,
       X_SEGMENT21,
       X_SEGMENT22,
       X_SEGMENT23,
       X_SEGMENT24,
       X_SEGMENT25,
       X_SEGMENT26,
       X_SEGMENT27,
       X_SUMMARY_FLAG,
       X_ID_FLEX_NUM,
       to_date(X_END_DATE_ACTIVE,'DD/MM/YYYY'),
       X_SEGMENT28,
       X_SEGMENT29,
       X_SEGMENT30,
       to_date(X_START_DATE_ACTIVE,'DD/MM/YYYY'),
       X_ENABLED_FLAG,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);
 end;
end LOAD_ROW;
end HR_ITEM_CONTEXTS_PKG;

/
