--------------------------------------------------------
--  DDL for Package Body JTF_EV_EVTTYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_EV_EVTTYPES" AS
/* $Header: JTFEVETB.pls 120.1 2005/07/02 02:01:14 appldev ship $ */

procedure ADD_LANGUAGE
is
begin
  delete from JTF_EVT_TYPES_TL T
  where not exists
    (select NULL
    from JTF_EVT_TYPES_B B
    where B.JTF_EVT_TYPES_ID = T.JTF_EVT_TYPES_ID
    );

  update JTF_EVT_TYPES_TL T set (
      JTF_EVT_TYPES_DESC
    ) = (select
      B.JTF_EVT_TYPES_DESC
    from JTF_EVT_TYPES_TL B
    where B.JTF_EVT_TYPES_ID = T.JTF_EVT_TYPES_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.JTF_EVT_TYPES_ID,
      T.LANGUAGE
  ) in (select
      SUBT.JTF_EVT_TYPES_ID,
      SUBT.LANGUAGE
    from JTF_EVT_TYPES_TL SUBB, JTF_EVT_TYPES_TL SUBT
    where SUBB.JTF_EVT_TYPES_ID = SUBT.JTF_EVT_TYPES_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.JTF_EVT_TYPES_DESC <> SUBT.JTF_EVT_TYPES_DESC
      or (SUBB.JTF_EVT_TYPES_DESC is null and SUBT.JTF_EVT_TYPES_DESC is not null) or (SUBB.JTF_EVT_TYPES_DESC is not null and SUBT.JTF_EVT_TYPES_DESC is null)));

  insert into JTF_EVT_TYPES_TL (
    JTF_EVT_TYPES_ID,
    JTF_EVT_TYPES_DESC,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.JTF_EVT_TYPES_ID,
    B.JTF_EVT_TYPES_DESC,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_EVT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_EVT_TYPES_TL T
    where T.JTF_EVT_TYPES_ID = B.JTF_EVT_TYPES_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



END JTF_EV_EVTTYPES;


/
