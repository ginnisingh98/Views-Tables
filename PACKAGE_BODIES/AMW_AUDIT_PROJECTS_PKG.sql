--------------------------------------------------------
--  DDL for Package Body AMW_AUDIT_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_AUDIT_PROJECTS_PKG" as
/* $Header: amwtapjb.pls 120.0 2005/10/26 07:06:47 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from AMW_AUDIT_PROJECTS_TL T
  where not exists
    (select NULL
    from AMW_AUDIT_PROJECTS B
    where B.AUDIT_PROJECT_ID = T.AUDIT_PROJECT_ID
    );

  update AMW_AUDIT_PROJECTS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMW_AUDIT_PROJECTS_TL B
    where B.AUDIT_PROJECT_ID = T.AUDIT_PROJECT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.AUDIT_PROJECT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.AUDIT_PROJECT_ID,
      SUBT.LANGUAGE
    from AMW_AUDIT_PROJECTS_TL SUBB, AMW_AUDIT_PROJECTS_TL SUBT
    where SUBB.AUDIT_PROJECT_ID = SUBT.AUDIT_PROJECT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_AUDIT_PROJECTS_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    DESCRIPTION,
    SOURCE_LANG,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    AUDIT_PROJECT_ID,
    NAME,
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
    B.AUDIT_PROJECT_ID,
    B.NAME,
    L.LANGUAGE_CODE
  from AMW_AUDIT_PROJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_AUDIT_PROJECTS_TL T
    where T.AUDIT_PROJECT_ID = B.AUDIT_PROJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_AUDIT_PROJECTS_PKG;

/
