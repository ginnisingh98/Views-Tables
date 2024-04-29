--------------------------------------------------------
--  DDL for Package Body AMW_AUDIT_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_AUDIT_TASKS_PKG" as
/* $Header: amwtatkb.pls 120.0 2005/10/26 07:07:02 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from AMW_AUDIT_TASKS_TL T
  where not exists
    (select NULL
    from AMW_AUDIT_TASKS_B B
    where B.TASK_ID = T.TASK_ID
    );

  update AMW_AUDIT_TASKS_TL T set (
      TASK_NAME,
      DESCRIPTION
    ) = (select
      B.TASK_NAME,
      B.DESCRIPTION
    from AMW_AUDIT_TASKS_TL B
    where B.TASK_ID = T.TASK_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TASK_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TASK_ID,
      SUBT.LANGUAGE
    from AMW_AUDIT_TASKS_TL SUBB, AMW_AUDIT_TASKS_TL SUBT
    where SUBB.TASK_ID = SUBT.TASK_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TASK_NAME <> SUBT.TASK_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_AUDIT_TASKS_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    DESCRIPTION,
    SOURCE_LANG,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    TASK_ID,
    TASK_NAME,
    LANGUAGE
 ) select /*+ ORDERED */
    B.OBJECT_VERSION_NUMBER,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATED_BY,
    B.DESCRIPTION,
    B.SOURCE_LANG,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TASK_ID,
    B.TASK_NAME,
    L.LANGUAGE_CODE
  from AMW_AUDIT_TASKS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_AUDIT_TASKS_TL T
    where T.TASK_ID = B.TASK_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_AUDIT_TASKS_PKG;

/
