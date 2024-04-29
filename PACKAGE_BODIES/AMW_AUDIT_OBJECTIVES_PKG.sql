--------------------------------------------------------
--  DDL for Package Body AMW_AUDIT_OBJECTIVES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_AUDIT_OBJECTIVES_PKG" as
/* $Header: amwtaobb.pls 120.0 2005/10/26 07:06:48 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from AMW_AUDIT_OBJECTIVES_TL T
  where not exists
    (select NULL
    from AMW_AUDIT_OBJECTIVES_B B
    where B.OBJECTIVE_ID = T.OBJECTIVE_ID
    );

  update AMW_AUDIT_OBJECTIVES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMW_AUDIT_OBJECTIVES_TL B
    where B.OBJECTIVE_ID = T.OBJECTIVE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECTIVE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECTIVE_ID,
      SUBT.LANGUAGE
    from AMW_AUDIT_OBJECTIVES_TL SUBB, AMW_AUDIT_OBJECTIVES_TL SUBT
    where SUBB.OBJECTIVE_ID = SUBT.OBJECTIVE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMW_AUDIT_OBJECTIVES_TL (
    OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    CREATED_BY,
    DESCRIPTION,
    SOURCE_LANG,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    OBJECTIVE_ID,
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
    B.OBJECTIVE_ID,
    B.NAME,
    L.LANGUAGE_CODE
  from AMW_AUDIT_OBJECTIVES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMW_AUDIT_OBJECTIVES_TL T
    where T.OBJECTIVE_ID = B.OBJECTIVE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end AMW_AUDIT_OBJECTIVES_PKG;

/
