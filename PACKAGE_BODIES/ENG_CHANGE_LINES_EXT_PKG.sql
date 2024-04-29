--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_LINES_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_LINES_EXT_PKG" as
/* $Header: ENGUCLEB.pls 115.1 2003/05/30 10:58:32 akumar noship $ */

procedure ADD_LANGUAGE
is
begin

delete from ENG_CHANGE_LINES_EXT_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_LINES_EXT_TL B
    where
        B.EXTENSION_ID = T.EXTENSION_ID
    and B.CHANGE_LINE_ID = T.CHANGE_LINE_ID
    and B.CHANGE_TYPE_ID = T.CHANGE_TYPE_ID
    and B.ATTR_GROUP_ID = T.ATTR_GROUP_ID

    );

  update ENG_CHANGE_LINES_EXT_TL T set (
      TL_EXT_ATTR1,
      TL_EXT_ATTR2,
      TL_EXT_ATTR3,
      TL_EXT_ATTR4,
      TL_EXT_ATTR5,
      TL_EXT_ATTR6,
      TL_EXT_ATTR7,
      TL_EXT_ATTR8,
      TL_EXT_ATTR9,
      TL_EXT_ATTR10,
      TL_EXT_ATTR11,
      TL_EXT_ATTR12,
      TL_EXT_ATTR13,
      TL_EXT_ATTR14,
      TL_EXT_ATTR15,
      TL_EXT_ATTR16,
      TL_EXT_ATTR17,
      TL_EXT_ATTR18,
      TL_EXT_ATTR19,
      TL_EXT_ATTR20,
      TL_EXT_ATTR21,
      TL_EXT_ATTR22,
      TL_EXT_ATTR23,
      TL_EXT_ATTR24,
      TL_EXT_ATTR26,
      TL_EXT_ATTR25,
      TL_EXT_ATTR27,
      TL_EXT_ATTR28,
      TL_EXT_ATTR29,
      TL_EXT_ATTR30,
      TL_EXT_ATTR31,
      TL_EXT_ATTR32,
      TL_EXT_ATTR33,
      TL_EXT_ATTR34,
      TL_EXT_ATTR35,
      TL_EXT_ATTR36,
      TL_EXT_ATTR37,
      TL_EXT_ATTR38,
      TL_EXT_ATTR39,
      TL_EXT_ATTR40
    ) = (select
      B.TL_EXT_ATTR1,
      B.TL_EXT_ATTR2,
      B.TL_EXT_ATTR3,
      B.TL_EXT_ATTR4,
      B.TL_EXT_ATTR5,
      B.TL_EXT_ATTR6,
      B.TL_EXT_ATTR7,
      B.TL_EXT_ATTR8,
      B.TL_EXT_ATTR9,
      B.TL_EXT_ATTR10,
      B.TL_EXT_ATTR11,
      B.TL_EXT_ATTR12,
      B.TL_EXT_ATTR13,
      B.TL_EXT_ATTR14,
      B.TL_EXT_ATTR15,
      B.TL_EXT_ATTR16,
      B.TL_EXT_ATTR17,
      B.TL_EXT_ATTR18,
      B.TL_EXT_ATTR19,
      B.TL_EXT_ATTR20,
      B.TL_EXT_ATTR21,
      B.TL_EXT_ATTR22,
      B.TL_EXT_ATTR23,
      B.TL_EXT_ATTR24,
      B.TL_EXT_ATTR26,
      B.TL_EXT_ATTR25,
      B.TL_EXT_ATTR27,
      B.TL_EXT_ATTR28,
      B.TL_EXT_ATTR29,
      B.TL_EXT_ATTR30,
      B.TL_EXT_ATTR31,
      B.TL_EXT_ATTR32,
      B.TL_EXT_ATTR33,
      B.TL_EXT_ATTR34,
      B.TL_EXT_ATTR35,
      B.TL_EXT_ATTR36,
      B.TL_EXT_ATTR37,
      B.TL_EXT_ATTR38,
      B.TL_EXT_ATTR39,
      B.TL_EXT_ATTR40
    from ENG_CHANGE_LINES_EXT_TL B
    where B.EXTENSION_ID = T.EXTENSION_ID
    and B.CHANGE_LINE_ID = T.CHANGE_LINE_ID
    and B.CHANGE_TYPE_ID = T.CHANGE_TYPE_ID
    and B.ATTR_GROUP_ID = T.ATTR_GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXTENSION_ID,
      T.CHANGE_LINE_ID,
      T.CHANGE_TYPE_ID,
      T.ATTR_GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXTENSION_ID,
      SUBT.CHANGE_LINE_ID,
      SUBT.CHANGE_TYPE_ID,
      SUBT.ATTR_GROUP_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_LINES_EXT_TL SUBB, ENG_CHANGE_LINES_EXT_TL SUBT
    where SUBB.EXTENSION_ID = SUBT.EXTENSION_ID
    and SUBB.CHANGE_LINE_ID = SUBT.CHANGE_LINE_ID
    and SUBB.CHANGE_TYPE_ID = SUBT.CHANGE_TYPE_ID
    and SUBB.ATTR_GROUP_ID = SUBT.ATTR_GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TL_EXT_ATTR1 <> SUBT.TL_EXT_ATTR1
      or (SUBB.TL_EXT_ATTR1 is null and SUBT.TL_EXT_ATTR1 is not null)
      or (SUBB.TL_EXT_ATTR1 is not null and SUBT.TL_EXT_ATTR1 is null)
      or SUBB.TL_EXT_ATTR2 <> SUBT.TL_EXT_ATTR2
      or (SUBB.TL_EXT_ATTR2 is null and SUBT.TL_EXT_ATTR2 is not null)
      or (SUBB.TL_EXT_ATTR2 is not null and SUBT.TL_EXT_ATTR2 is null)
      or SUBB.TL_EXT_ATTR3 <> SUBT.TL_EXT_ATTR3
      or (SUBB.TL_EXT_ATTR3 is null and SUBT.TL_EXT_ATTR3 is not null)
      or (SUBB.TL_EXT_ATTR3 is not null and SUBT.TL_EXT_ATTR3 is null)
      or SUBB.TL_EXT_ATTR4 <> SUBT.TL_EXT_ATTR4
      or (SUBB.TL_EXT_ATTR4 is null and SUBT.TL_EXT_ATTR4 is not null)
      or (SUBB.TL_EXT_ATTR4 is not null and SUBT.TL_EXT_ATTR4 is null)
      or SUBB.TL_EXT_ATTR5 <> SUBT.TL_EXT_ATTR5
      or (SUBB.TL_EXT_ATTR5 is null and SUBT.TL_EXT_ATTR5 is not null)
      or (SUBB.TL_EXT_ATTR5 is not null and SUBT.TL_EXT_ATTR5 is null)
      or SUBB.TL_EXT_ATTR6 <> SUBT.TL_EXT_ATTR6
      or (SUBB.TL_EXT_ATTR6 is null and SUBT.TL_EXT_ATTR6 is not null)
      or (SUBB.TL_EXT_ATTR6 is not null and SUBT.TL_EXT_ATTR6 is null)
      or SUBB.TL_EXT_ATTR7 <> SUBT.TL_EXT_ATTR7
      or (SUBB.TL_EXT_ATTR7 is null and SUBT.TL_EXT_ATTR7 is not null)
      or (SUBB.TL_EXT_ATTR7 is not null and SUBT.TL_EXT_ATTR7 is null)
      or SUBB.TL_EXT_ATTR8 <> SUBT.TL_EXT_ATTR8
      or (SUBB.TL_EXT_ATTR8 is null and SUBT.TL_EXT_ATTR8 is not null)
      or (SUBB.TL_EXT_ATTR8 is not null and SUBT.TL_EXT_ATTR8 is null)
      or SUBB.TL_EXT_ATTR9 <> SUBT.TL_EXT_ATTR9
      or (SUBB.TL_EXT_ATTR9 is null and SUBT.TL_EXT_ATTR9 is not null)
      or (SUBB.TL_EXT_ATTR9 is not null and SUBT.TL_EXT_ATTR9 is null)
      or SUBB.TL_EXT_ATTR10 <> SUBT.TL_EXT_ATTR10
      or (SUBB.TL_EXT_ATTR10 is null and SUBT.TL_EXT_ATTR10 is not null)
      or (SUBB.TL_EXT_ATTR10 is not null and SUBT.TL_EXT_ATTR10 is null)
      or SUBB.TL_EXT_ATTR11 <> SUBT.TL_EXT_ATTR11
      or (SUBB.TL_EXT_ATTR11 is null and SUBT.TL_EXT_ATTR11 is not null)
      or (SUBB.TL_EXT_ATTR11 is not null and SUBT.TL_EXT_ATTR11 is null)
      or SUBB.TL_EXT_ATTR12 <> SUBT.TL_EXT_ATTR12
      or (SUBB.TL_EXT_ATTR12 is null and SUBT.TL_EXT_ATTR12 is not null)
      or (SUBB.TL_EXT_ATTR12 is not null and SUBT.TL_EXT_ATTR12 is null)
      or SUBB.TL_EXT_ATTR13 <> SUBT.TL_EXT_ATTR13
      or (SUBB.TL_EXT_ATTR13 is null and SUBT.TL_EXT_ATTR13 is not null)
      or (SUBB.TL_EXT_ATTR13 is not null and SUBT.TL_EXT_ATTR13 is null)
      or SUBB.TL_EXT_ATTR14 <> SUBT.TL_EXT_ATTR14
      or (SUBB.TL_EXT_ATTR14 is null and SUBT.TL_EXT_ATTR14 is not null)
      or (SUBB.TL_EXT_ATTR14 is not null and SUBT.TL_EXT_ATTR14 is null)
      or SUBB.TL_EXT_ATTR15 <> SUBT.TL_EXT_ATTR15
      or (SUBB.TL_EXT_ATTR15 is null and SUBT.TL_EXT_ATTR15 is not null)
      or (SUBB.TL_EXT_ATTR15 is not null and SUBT.TL_EXT_ATTR15 is null)
      or SUBB.TL_EXT_ATTR16 <> SUBT.TL_EXT_ATTR16
      or (SUBB.TL_EXT_ATTR16 is null and SUBT.TL_EXT_ATTR16 is not null)
      or (SUBB.TL_EXT_ATTR16 is not null and SUBT.TL_EXT_ATTR16 is null)
      or SUBB.TL_EXT_ATTR17 <> SUBT.TL_EXT_ATTR17
      or (SUBB.TL_EXT_ATTR17 is null and SUBT.TL_EXT_ATTR17 is not null)
      or (SUBB.TL_EXT_ATTR17 is not null and SUBT.TL_EXT_ATTR17 is null)
      or SUBB.TL_EXT_ATTR18 <> SUBT.TL_EXT_ATTR18
      or (SUBB.TL_EXT_ATTR18 is null and SUBT.TL_EXT_ATTR18 is not null)
      or (SUBB.TL_EXT_ATTR18 is not null and SUBT.TL_EXT_ATTR18 is null)
      or SUBB.TL_EXT_ATTR19 <> SUBT.TL_EXT_ATTR19
      or (SUBB.TL_EXT_ATTR19 is null and SUBT.TL_EXT_ATTR19 is not null)
      or (SUBB.TL_EXT_ATTR19 is not null and SUBT.TL_EXT_ATTR19 is null)
      or SUBB.TL_EXT_ATTR20 <> SUBT.TL_EXT_ATTR20
      or (SUBB.TL_EXT_ATTR20 is null and SUBT.TL_EXT_ATTR20 is not null)
      or (SUBB.TL_EXT_ATTR20 is not null and SUBT.TL_EXT_ATTR20 is null)
      or SUBB.TL_EXT_ATTR21 <> SUBT.TL_EXT_ATTR21
      or (SUBB.TL_EXT_ATTR21 is null and SUBT.TL_EXT_ATTR21 is not null)
      or (SUBB.TL_EXT_ATTR21 is not null and SUBT.TL_EXT_ATTR21 is null)
      or SUBB.TL_EXT_ATTR22 <> SUBT.TL_EXT_ATTR22
      or (SUBB.TL_EXT_ATTR22 is null and SUBT.TL_EXT_ATTR22 is not null)
      or (SUBB.TL_EXT_ATTR22 is not null and SUBT.TL_EXT_ATTR22 is null)
      or SUBB.TL_EXT_ATTR23 <> SUBT.TL_EXT_ATTR23
      or (SUBB.TL_EXT_ATTR23 is null and SUBT.TL_EXT_ATTR23 is not null)
      or (SUBB.TL_EXT_ATTR23 is not null and SUBT.TL_EXT_ATTR23 is null)
      or SUBB.TL_EXT_ATTR24 <> SUBT.TL_EXT_ATTR24
      or (SUBB.TL_EXT_ATTR24 is null and SUBT.TL_EXT_ATTR24 is not null)
      or (SUBB.TL_EXT_ATTR24 is not null and SUBT.TL_EXT_ATTR24 is null)
      or SUBB.TL_EXT_ATTR26 <> SUBT.TL_EXT_ATTR26
      or (SUBB.TL_EXT_ATTR26 is null and SUBT.TL_EXT_ATTR26 is not null)
      or (SUBB.TL_EXT_ATTR26 is not null and SUBT.TL_EXT_ATTR26 is null)
      or SUBB.TL_EXT_ATTR25 <> SUBT.TL_EXT_ATTR25
      or (SUBB.TL_EXT_ATTR25 is null and SUBT.TL_EXT_ATTR25 is not null)
      or (SUBB.TL_EXT_ATTR25 is not null and SUBT.TL_EXT_ATTR25 is null)
      or SUBB.TL_EXT_ATTR27 <> SUBT.TL_EXT_ATTR27
      or (SUBB.TL_EXT_ATTR27 is null and SUBT.TL_EXT_ATTR27 is not null)
      or (SUBB.TL_EXT_ATTR27 is not null and SUBT.TL_EXT_ATTR27 is null)
      or SUBB.TL_EXT_ATTR28 <> SUBT.TL_EXT_ATTR28
      or (SUBB.TL_EXT_ATTR28 is null and SUBT.TL_EXT_ATTR28 is not null)
      or (SUBB.TL_EXT_ATTR28 is not null and SUBT.TL_EXT_ATTR28 is null)
      or SUBB.TL_EXT_ATTR29 <> SUBT.TL_EXT_ATTR29
      or (SUBB.TL_EXT_ATTR29 is null and SUBT.TL_EXT_ATTR29 is not null)
      or (SUBB.TL_EXT_ATTR29 is not null and SUBT.TL_EXT_ATTR29 is null)
      or SUBB.TL_EXT_ATTR30 <> SUBT.TL_EXT_ATTR30
      or (SUBB.TL_EXT_ATTR30 is null and SUBT.TL_EXT_ATTR30 is not null)
      or (SUBB.TL_EXT_ATTR30 is not null and SUBT.TL_EXT_ATTR30 is null)
      or SUBB.TL_EXT_ATTR31 <> SUBT.TL_EXT_ATTR31
      or (SUBB.TL_EXT_ATTR31 is null and SUBT.TL_EXT_ATTR31 is not null)
      or (SUBB.TL_EXT_ATTR31 is not null and SUBT.TL_EXT_ATTR31 is null)
      or SUBB.TL_EXT_ATTR32 <> SUBT.TL_EXT_ATTR32
      or (SUBB.TL_EXT_ATTR32 is null and SUBT.TL_EXT_ATTR32 is not null)
      or (SUBB.TL_EXT_ATTR32 is not null and SUBT.TL_EXT_ATTR32 is null)
      or SUBB.TL_EXT_ATTR33 <> SUBT.TL_EXT_ATTR33
      or (SUBB.TL_EXT_ATTR33 is null and SUBT.TL_EXT_ATTR33 is not null)
      or (SUBB.TL_EXT_ATTR33 is not null and SUBT.TL_EXT_ATTR33 is null)
      or SUBB.TL_EXT_ATTR34 <> SUBT.TL_EXT_ATTR34
      or (SUBB.TL_EXT_ATTR34 is null and SUBT.TL_EXT_ATTR34 is not null)
      or (SUBB.TL_EXT_ATTR34 is not null and SUBT.TL_EXT_ATTR34 is null)
      or SUBB.TL_EXT_ATTR35 <> SUBT.TL_EXT_ATTR35
      or (SUBB.TL_EXT_ATTR35 is null and SUBT.TL_EXT_ATTR35 is not null)
      or (SUBB.TL_EXT_ATTR35 is not null and SUBT.TL_EXT_ATTR35 is null)
      or SUBB.TL_EXT_ATTR36 <> SUBT.TL_EXT_ATTR36
      or (SUBB.TL_EXT_ATTR36 is null and SUBT.TL_EXT_ATTR36 is not null)
      or (SUBB.TL_EXT_ATTR36 is not null and SUBT.TL_EXT_ATTR36 is null)
      or SUBB.TL_EXT_ATTR37 <> SUBT.TL_EXT_ATTR37
      or (SUBB.TL_EXT_ATTR37 is null and SUBT.TL_EXT_ATTR37 is not null)
      or (SUBB.TL_EXT_ATTR37 is not null and SUBT.TL_EXT_ATTR37 is null)
      or SUBB.TL_EXT_ATTR38 <> SUBT.TL_EXT_ATTR38
      or (SUBB.TL_EXT_ATTR38 is null and SUBT.TL_EXT_ATTR38 is not null)
      or (SUBB.TL_EXT_ATTR38 is not null and SUBT.TL_EXT_ATTR38 is null)
      or SUBB.TL_EXT_ATTR39 <> SUBT.TL_EXT_ATTR39
      or (SUBB.TL_EXT_ATTR39 is null and SUBT.TL_EXT_ATTR39 is not null)
      or (SUBB.TL_EXT_ATTR39 is not null and SUBT.TL_EXT_ATTR39 is null)
      or SUBB.TL_EXT_ATTR40 <> SUBT.TL_EXT_ATTR40
      or (SUBB.TL_EXT_ATTR40 is null and SUBT.TL_EXT_ATTR40 is not null)
      or (SUBB.TL_EXT_ATTR40 is not null and SUBT.TL_EXT_ATTR40 is null)
  ));

  insert into ENG_CHANGE_LINES_EXT_TL (
    TL_EXT_ATTR6,
    TL_EXT_ATTR7,
    TL_EXT_ATTR8,
    TL_EXT_ATTR9,
    TL_EXT_ATTR10,
    TL_EXT_ATTR11,
    TL_EXT_ATTR12,
    TL_EXT_ATTR13,
    TL_EXT_ATTR14,
    TL_EXT_ATTR15,
    TL_EXT_ATTR16,
    TL_EXT_ATTR17,
    TL_EXT_ATTR18,
    TL_EXT_ATTR19,
    TL_EXT_ATTR20,
    TL_EXT_ATTR21,
    TL_EXT_ATTR22,
    TL_EXT_ATTR23,
    TL_EXT_ATTR24,
    TL_EXT_ATTR25,
    TL_EXT_ATTR26,
    TL_EXT_ATTR27,
    TL_EXT_ATTR28,
    TL_EXT_ATTR29,
    TL_EXT_ATTR30,
    TL_EXT_ATTR31,
    TL_EXT_ATTR32,
    TL_EXT_ATTR33,
    TL_EXT_ATTR34,
    TL_EXT_ATTR35,
    TL_EXT_ATTR36,
    TL_EXT_ATTR37,
    TL_EXT_ATTR38,
    TL_EXT_ATTR39,
    TL_EXT_ATTR40,
    EXTENSION_ID,
    CHANGE_LINE_ID,
    CHANGE_TYPE_ID,
    ATTR_GROUP_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    TL_EXT_ATTR1,
    TL_EXT_ATTR2,
    TL_EXT_ATTR3,
    TL_EXT_ATTR4,
    TL_EXT_ATTR5,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TL_EXT_ATTR6,
    B.TL_EXT_ATTR7,
    B.TL_EXT_ATTR8,
    B.TL_EXT_ATTR9,
    B.TL_EXT_ATTR10,
    B.TL_EXT_ATTR11,
    B.TL_EXT_ATTR12,
    B.TL_EXT_ATTR13,
    B.TL_EXT_ATTR14,
    B.TL_EXT_ATTR15,
    B.TL_EXT_ATTR16,
    B.TL_EXT_ATTR17,
    B.TL_EXT_ATTR18,
    B.TL_EXT_ATTR19,
    B.TL_EXT_ATTR20,
    B.TL_EXT_ATTR21,
    B.TL_EXT_ATTR22,
    B.TL_EXT_ATTR23,
    B.TL_EXT_ATTR24,
    B.TL_EXT_ATTR25,
    B.TL_EXT_ATTR26,
    B.TL_EXT_ATTR27,
    B.TL_EXT_ATTR28,
    B.TL_EXT_ATTR29,
    B.TL_EXT_ATTR30,
    B.TL_EXT_ATTR31,
    B.TL_EXT_ATTR32,
    B.TL_EXT_ATTR33,
    B.TL_EXT_ATTR34,
    B.TL_EXT_ATTR35,
    B.TL_EXT_ATTR36,
    B.TL_EXT_ATTR37,
    B.TL_EXT_ATTR38,
    B.TL_EXT_ATTR39,
    B.TL_EXT_ATTR40,
    B.EXTENSION_ID,
    B.CHANGE_LINE_ID,
    B.CHANGE_TYPE_ID,
    B.ATTR_GROUP_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.TL_EXT_ATTR1,
    B.TL_EXT_ATTR2,
    B.TL_EXT_ATTR3,
    B.TL_EXT_ATTR4,
    B.TL_EXT_ATTR5,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_LINES_EXT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_LINES_EXT_TL T
    where T.EXTENSION_ID = B.EXTENSION_ID
    and T.CHANGE_LINE_ID = B.CHANGE_LINE_ID
    and T.CHANGE_TYPE_ID = B.CHANGE_TYPE_ID
    and T.ATTR_GROUP_ID = B.ATTR_GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_LINES_EXT_PKG;

/
