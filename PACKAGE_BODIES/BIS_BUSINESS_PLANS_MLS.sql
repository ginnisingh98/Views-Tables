--------------------------------------------------------
--  DDL for Package Body BIS_BUSINESS_PLANS_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUSINESS_PLANS_MLS" AS
/* $Header: BISBMLSB.pls 115.1 99/07/17 16:07:31 porting ship $ */

procedure ADD_LANGUAGE
is
begin
  delete from BIS_BUSINESS_PLANS_TL T
  where not exists
    (select NULL
    from BIS_BUSINESS_PLANS B
    where B.PLAN_ID = T.PLAN_ID
    );

  update BIS_BUSINESS_PLANS_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from BIS_BUSINESS_PLANS_TL B
    where B.PLAN_ID = T.PLAN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PLAN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PLAN_ID,
      SUBT.LANGUAGE
    from BIS_BUSINESS_PLANS_TL SUBB, BIS_BUSINESS_PLANS_TL SUBT
    where SUBB.PLAN_ID = SUBT.PLAN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into BIS_BUSINESS_PLANS_TL (
    PLAN_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PLAN_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BIS_BUSINESS_PLANS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BIS_BUSINESS_PLANS_TL T
    where T.PLAN_ID = B.PLAN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BIS_BUSINESS_PLANS_MLS;

/
