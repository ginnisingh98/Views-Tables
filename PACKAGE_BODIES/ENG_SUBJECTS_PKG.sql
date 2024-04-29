--------------------------------------------------------
--  DDL for Package Body ENG_SUBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_SUBJECTS_PKG" as
/* $Header: ENGSUBJB.pls 115.0 2004/03/16 22:59:08 sshrikha noship $ */

procedure ADD_LANGUAGE
is
begin
  delete from ENG_SUBJECTS_TL T
  where not exists
    (select NULL
    from ENG_SUBJECTS_B B
    where B.SUBJECT_ID = T.SUBJECT_ID
    );

  update ENG_SUBJECTS_TL T set (
      SUBJECT_NAME
    ) = (select
      B.SUBJECT_NAME
    from ENG_SUBJECTS_TL B
    where B.SUBJECT_ID = T.SUBJECT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SUBJECT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SUBJECT_ID,
      SUBT.LANGUAGE
    from ENG_SUBJECTS_TL SUBB, ENG_SUBJECTS_TL SUBT
    where SUBB.SUBJECT_ID = SUBT.SUBJECT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SUBJECT_NAME <> SUBT.SUBJECT_NAME
  ));

  insert into ENG_SUBJECTS_TL (
    SUBJECT_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SUBJECT_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SUBJECT_NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SUBJECT_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_SUBJECTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_SUBJECTS_TL T
    where T.SUBJECT_ID = B.SUBJECT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_SUBJECTS_PKG;

/
