--------------------------------------------------------
--  DDL for Package Body GMA_MR_TEXT_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_MR_TEXT_TBL_PKG" AS
/* $Header: GMAMRTXB.pls 115.6 2003/02/24 19:22:38 kmoizudd ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from MR_TEXT_TBL_TL
    where TEXT_CODE = X_TEXT_CODE
    and LANG_CODE = X_LANG_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and LINE_NO = X_LINE_NO
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into MR_TEXT_TBL_TL (
    TEXT_CODE,
    LANG_CODE,
    PARAGRAPH_CODE,
    SUB_PARACODE,
    LINE_NO,
    TEXT,
    LAST_UPDATED_BY,
    CREATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEXT_CODE,
    X_LANG_CODE,
    X_PARAGRAPH_CODE,
    X_SUB_PARACODE,
    X_LINE_NO,
    X_TEXT,
    X_LAST_UPDATED_BY,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from MR_TEXT_TBL_TL T
    where T.TEXT_CODE = X_TEXT_CODE
    and T.LANG_CODE = X_LANG_CODE
    and T.PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and T.SUB_PARACODE = X_SUB_PARACODE
    and T.LINE_NO = X_LINE_NO
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2
) is
  cursor c1 is select
      TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from MR_TEXT_TBL_TL
    where TEXT_CODE = X_TEXT_CODE
    and LANG_CODE = X_LANG_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and LINE_NO = X_LINE_NO
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TEXT_CODE nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.TEXT = X_TEXT)
               OR ((tlinfo.TEXT is null) AND (X_TEXT is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROW_ID in VARCHAR2,
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
L_LINE_NO number;
begin

-- added this select to retrieve the old line number with ROWID
  select LINE_NO INTO L_LINE_NO
    from MR_TEXT_TBL_TL
    where ROWID=X_ROW_ID;

  update MR_TEXT_TBL_TL set
    TEXT = X_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LINE_NO = X_LINE_NO,
    SOURCE_LANG = userenv('LANG')
  where TEXT_CODE = X_TEXT_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and LINE_NO = L_LINE_NO
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

--  where ROWID = X_ROW_ID;
-- bug #1712111 (JKB)
-- bug #2747352 (kmoizudd) Modified the Where clause without ROW_ID


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_ROW_ID in VARCHAR2
) is
begin
  delete from MR_TEXT_TBL_TL
  where TEXT_CODE = X_TEXT_CODE
  and LANG_CODE = X_LANG_CODE
  and PARAGRAPH_CODE = X_PARAGRAPH_CODE
  and SUB_PARACODE = X_SUB_PARACODE
  and LINE_NO = X_LINE_NO;

--  where ROWID = X_ROW_ID;
-- Bug #1775354 (JKB)
-- bug #2747352 (kmoizudd) Modified the Where clause without ROW_ID

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update MR_TEXT_TBL_TL T set (
      TEXT
    ) = (select
      B.TEXT
    from MR_TEXT_TBL_TL B
    where B.TEXT_CODE = T.TEXT_CODE
    and B.LANG_CODE = T.LANG_CODE
    and B.PARAGRAPH_CODE = T.PARAGRAPH_CODE
    and B.SUB_PARACODE = T.SUB_PARACODE
    and B.LINE_NO = T.LINE_NO
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEXT_CODE,
      T.LANG_CODE,
      T.PARAGRAPH_CODE,
      T.SUB_PARACODE,
      T.LINE_NO,
      T.LANGUAGE
  ) in (select
      SUBT.TEXT_CODE,
      SUBT.LANG_CODE,
      SUBT.PARAGRAPH_CODE,
      SUBT.SUB_PARACODE,
      SUBT.LINE_NO,
      SUBT.LANGUAGE
    from MR_TEXT_TBL_TL SUBB, MR_TEXT_TBL_TL SUBT
    where SUBB.TEXT_CODE = SUBT.TEXT_CODE
    and SUBB.LANG_CODE = SUBT.LANG_CODE
    and SUBB.PARAGRAPH_CODE = SUBT.PARAGRAPH_CODE
    and SUBB.SUB_PARACODE = SUBT.SUB_PARACODE
    and SUBB.LINE_NO = SUBT.LINE_NO
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEXT <> SUBT.TEXT
      or (SUBB.TEXT is null and SUBT.TEXT is not null)
      or (SUBB.TEXT is not null and SUBT.TEXT is null)
  ));

  insert into MR_TEXT_TBL_TL (
    TEXT_CODE,
    LANG_CODE,
    PARAGRAPH_CODE,
    SUB_PARACODE,
    LINE_NO,
    TEXT,
    LAST_UPDATED_BY,
    CREATED_BY,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEXT_CODE,
    B.LANG_CODE,
    B.PARAGRAPH_CODE,
    B.SUB_PARACODE,
    B.LINE_NO,
    B.TEXT,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from MR_TEXT_TBL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from MR_TEXT_TBL_TL T
    where T.TEXT_CODE = B.TEXT_CODE
    and T.LANG_CODE = B.LANG_CODE
    and T.PARAGRAPH_CODE = B.PARAGRAPH_CODE
    and T.SUB_PARACODE = B.SUB_PARACODE
    and T.LINE_NO = B.LINE_NO
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
 X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_OWNER         in VARCHAR2
) IS
BEGIN
  update MR_TEXT_TBL_TL set
    TEXT = X_TEXT,
    SOURCE_LANG   = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = decode(X_OWNER,'SEED',1,0),
    LAST_UPDATE_LOGIN = 0
  where TEXT_CODE = X_TEXT_CODE
    and LANG_CODE = X_LANG_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and LINE_NO = X_LINE_NO
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

procedure LOAD_ROW (
 X_TEXT_CODE in NUMBER,
  X_LANG_CODE in VARCHAR2,
  X_PARAGRAPH_CODE in VARCHAR2,
  X_SUB_PARACODE in NUMBER,
  X_LINE_NO in NUMBER,
  X_TEXT in VARCHAR2,
  X_OWNER         in VARCHAR2
) IS
 l_text_code number(10);
 l_user_id number:=0;
 l_row_id VARCHAR2(64);
 BEGIN
    IF (X_OWNER ='SEED') THEN
        l_user_id :=1;
    END IF;

    SELECT text_code, rowid into l_text_code, l_row_id
    FROM   MR_TEXT_TBL_TL
    WHERE  TEXT_CODE = X_TEXT_CODE
    and LANG_CODE = X_LANG_CODE
    and PARAGRAPH_CODE = X_PARAGRAPH_CODE
    and SUB_PARACODE = X_SUB_PARACODE
    and LINE_NO = X_LINE_NO;

   GMA_MR_TEXT_TBL_PKG.UPDATE_ROW ( X_ROW_ID => l_row_id,
                                    X_TEXT_CODE => X_TEXT_CODE,
                                    X_LANG_CODE => X_LANG_CODE,
                                    X_PARAGRAPH_CODE => X_PARAGRAPH_CODE,
                                    X_SUB_PARACODE => X_SUB_PARACODE,
                                    X_LINE_NO => X_LINE_NO,
                                    X_TEXT => X_TEXT,
                                    X_LAST_UPDATE_DATE => sysdate,
                                    X_LAST_UPDATED_BY => l_user_id,
                                    X_LAST_UPDATE_LOGIN => 0
                                   );
-- Bug #1712111 (JKB)




 EXCEPTION
    WHEN NO_DATA_FOUND THEN


  GMA_MR_TEXT_TBL_PKG.INSERT_ROW (  X_ROWID => l_row_id,
                                    X_TEXT_CODE => X_TEXT_CODE,
                                    X_LANG_CODE => X_LANG_CODE,
                                    X_PARAGRAPH_CODE => X_PARAGRAPH_CODE,
                                    X_SUB_PARACODE => X_SUB_PARACODE,
                                    X_LINE_NO => X_LINE_NO,
                                    X_TEXT => X_TEXT,
                                    X_CREATION_DATE => sysdate,
				    X_CREATED_BY => l_user_id,
                                    X_LAST_UPDATE_DATE => sysdate,
                                    X_LAST_UPDATED_BY => l_user_id,
                                    X_LAST_UPDATE_LOGIN => 0
                                   );

END LOAD_ROW;

end GMA_MR_TEXT_TBL_PKG;

/
