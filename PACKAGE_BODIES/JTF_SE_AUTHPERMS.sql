--------------------------------------------------------
--  DDL for Package Body JTF_SE_AUTHPERMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_SE_AUTHPERMS" AS
/* $Header: JTFSEAPB.pls 115.0 2000/04/07 19:31:54 pkm ship      $ */

procedure ADD_LANGUAGE
is
begin
  delete from JTF_AUTH_PERMISSIONS_TL T
  where not exists
    (select NULL
    from JTF_AUTH_PERMISSIONS_B B
    where B.PERMISSION_DESC_ID = T.PERMISSION_DESC_ID
    );

  update JTF_AUTH_PERMISSIONS_TL T set (
      PERMISSION_DESC,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    ) = (select
      B.PERMISSION_DESC,
     FND_GLOBAL.user_id,
     sysdate,
     FND_GLOBAL.user_id
    from JTF_AUTH_PERMISSIONS_TL B
    where B.PERMISSION_DESC_ID = T.PERMISSION_DESC_ID
    and B.LANGUAGE = T.SOURCE_LANG
     )
  where (
      T.PERMISSION_DESC_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PERMISSION_DESC_ID,
      SUBT.LANGUAGE
    from JTF_AUTH_PERMISSIONS_TL SUBB, JTF_AUTH_PERMISSIONS_TL SUBT
    where SUBB.PERMISSION_DESC_ID = SUBT.PERMISSION_DESC_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG );

  insert into JTF_AUTH_PERMISSIONS_TL (
    PERMISSION_DESC_ID,
    PERMISSION_DESC,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PERMISSION_DESC_ID,
    B.PERMISSION_DESC,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_AUTH_PERMISSIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_AUTH_PERMISSIONS_TL T
    where T.PERMISSION_DESC_ID = B.PERMISSION_DESC_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

END JTF_SE_AUTHPERMS;


/