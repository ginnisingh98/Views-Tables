--------------------------------------------------------
--  DDL for Package Body ITA_SETUP_RPT_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITA_SETUP_RPT_GROUPS_PKG" as
/* $Header: itatregb.pls 120.0 2005/05/31 16:40:06 appldev noship $ */


procedure ADD_LANGUAGE
is
begin
  delete from ITA_SETUP_RPT_GROUPS_TL tl
  where not exists (
    select null
    from ITA_SETUP_RPT_GROUPS_B b
    where
	b.INSTANCE_CODE = tl.INSTANCE_CODE and
	b.REPORTING_GROUP_ID = tl.REPORTING_GROUP_ID
    );

  update ITA_SETUP_RPT_GROUPS_TL tl set (
      REPORTING_GROUP_NAME
    ) = (select
      b.REPORTING_GROUP_NAME
    from ITA_SETUP_RPT_GROUPS_TL b
    where
	b.INSTANCE_CODE = tl.INSTANCE_CODE and
	b.REPORTING_GROUP_ID = tl.REPORTING_GROUP_ID and
      b.LANGUAGE = tl.SOURCE_LANG)
  where (
      tl.INSTANCE_CODE,
	tl.REPORTING_GROUP_ID,
      tl.LANGUAGE
  ) in (select
      subtl.INSTANCE_CODE,
	subtl.REPORTING_GROUP_ID,
      subtl.LANGUAGE
    from ITA_SETUP_RPT_GROUPS_TL subb, ITA_SETUP_RPT_GROUPS_TL subtl
    where
      subb.INSTANCE_CODE = subtl.INSTANCE_CODE and
      subb.REPORTING_GROUP_ID = subtl.REPORTING_GROUP_ID and
      subb.LANGUAGE = subtl.SOURCE_LANG and
    	(subb.REPORTING_GROUP_NAME <> subtl.REPORTING_GROUP_NAME or
        (subb.REPORTING_GROUP_NAME is null and subtl.REPORTING_GROUP_NAME is not null) or
        (subb.REPORTING_GROUP_NAME is not null and subtl.REPORTING_GROUP_NAME is null)));

  insert into ITA_SETUP_RPT_GROUPS_TL (
    INSTANCE_CODE,
    REPORTING_GROUP_ID,
    REPORTING_GROUP_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    b.INSTANCE_CODE,
    b.REPORTING_GROUP_ID,
    b.REPORTING_GROUP_NAME,
    b.CREATED_BY,
    b.CREATION_DATE,
    b.LAST_UPDATED_BY,
    b.LAST_UPDATE_DATE,
    b.LAST_UPDATE_LOGIN,
    b.SECURITY_GROUP_ID,
    b.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    b.SOURCE_LANG
  from ITA_SETUP_RPT_GROUPS_TL b, FND_LANGUAGES L
  where
    L.INSTALLED_FLAG in ('I', 'B') and
    b.LANGUAGE = userenv('LANG') and
    not exists (
     select null
     from ITA_SETUP_RPT_GROUPS_TL tl
     where
       tl.INSTANCE_CODE = b.INSTANCE_CODE and
       tl.REPORTING_GROUP_ID = b.REPORTING_GROUP_ID and
       tl.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


end ITA_SETUP_RPT_GROUPS_PKG;

/
