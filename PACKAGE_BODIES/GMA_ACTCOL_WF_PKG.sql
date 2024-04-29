--------------------------------------------------------
--  DDL for Package Body GMA_ACTCOL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_ACTCOL_WF_PKG" as
/* $Header: GMAACTB.pls 115.4 2002/10/31 16:19:15 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from GMA_ACTCOL_WF_B
    where ACTIVITY_ID = X_ACTIVITY_ID
    and TABLE_NAME = X_TABLE_NAME
    and COLUMN_NAME = X_COLUMN_NAME
    ;
begin
  insert into GMA_ACTCOL_WF_B (
    ACTIVITY_ID,
    COLUMN_HIERARCHY,
    TABLE_NAME,
    COLUMN_NAME,
    LOV_TABLE,
    LOV_COLUMN,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTIVITY_ID,
    X_COLUMN_HIERARCHY,
    X_TABLE_NAME,
    X_COLUMN_NAME,
    X_LOV_TABLE,
    X_LOV_COLUMN,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into GMA_ACTCOL_WF_TL (
    ACTIVITY_ID,
    COLUMN_HIERARCHY,
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_PROMPT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ACTIVITY_ID,
    X_COLUMN_HIERARCHY,
    X_TABLE_NAME,
    X_COLUMN_NAME,
    X_COLUMN_PROMPT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from GMA_ACTCOL_WF_TL T
    where T.ACTIVITY_ID = X_ACTIVITY_ID
    and T.TABLE_NAME = X_TABLE_NAME
    and T.COLUMN_NAME = X_COLUMN_NAME
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
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2
) is
  cursor c is select
      COLUMN_HIERARCHY,
      LOV_TABLE,
      LOV_COLUMN
    from GMA_ACTCOL_WF_B
    where ACTIVITY_ID = X_ACTIVITY_ID
    and TABLE_NAME = X_TABLE_NAME
    and COLUMN_NAME = X_COLUMN_NAME
    for update of ACTIVITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      COLUMN_PROMPT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from GMA_ACTCOL_WF_TL
    where ACTIVITY_ID = X_ACTIVITY_ID
    and TABLE_NAME = X_TABLE_NAME
    and COLUMN_NAME = X_COLUMN_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ACTIVITY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.COLUMN_HIERARCHY = X_COLUMN_HIERARCHY)
           OR ((recinfo.COLUMN_HIERARCHY is null) AND (X_COLUMN_HIERARCHY is null)))
      AND (recinfo.LOV_TABLE = X_LOV_TABLE)
      AND (recinfo.LOV_COLUMN = X_LOV_COLUMN)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.COLUMN_PROMPT = X_COLUMN_PROMPT)
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
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update GMA_ACTCOL_WF_B set
    COLUMN_HIERARCHY = X_COLUMN_HIERARCHY,
    LOV_TABLE = X_LOV_TABLE,
    LOV_COLUMN = X_LOV_COLUMN,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTIVITY_ID = X_ACTIVITY_ID
  and TABLE_NAME = X_TABLE_NAME
  and COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update GMA_ACTCOL_WF_TL set
    COLUMN_PROMPT = X_COLUMN_PROMPT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ACTIVITY_ID = X_ACTIVITY_ID
  and TABLE_NAME = X_TABLE_NAME
  and COLUMN_NAME = X_COLUMN_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2
) is
begin
  delete from GMA_ACTCOL_WF_TL
  where ACTIVITY_ID = X_ACTIVITY_ID
  and TABLE_NAME = X_TABLE_NAME
  and COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from GMA_ACTCOL_WF_B
  where ACTIVITY_ID = X_ACTIVITY_ID
  and TABLE_NAME = X_TABLE_NAME
  and COLUMN_NAME = X_COLUMN_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from GMA_ACTCOL_WF_TL T
  where not exists
    (select NULL
    from GMA_ACTCOL_WF_B B
    where B.ACTIVITY_ID = T.ACTIVITY_ID
    and B.TABLE_NAME = T.TABLE_NAME
    and B.COLUMN_NAME = T.COLUMN_NAME
    );

  update GMA_ACTCOL_WF_TL T set (
      COLUMN_PROMPT
    ) = (select
      B.COLUMN_PROMPT
    from GMA_ACTCOL_WF_TL B
    where B.ACTIVITY_ID = T.ACTIVITY_ID
    and B.TABLE_NAME = T.TABLE_NAME
    and B.COLUMN_NAME = T.COLUMN_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTIVITY_ID,
      T.TABLE_NAME,
      T.COLUMN_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.ACTIVITY_ID,
      SUBT.TABLE_NAME,
      SUBT.COLUMN_NAME,
      SUBT.LANGUAGE
    from GMA_ACTCOL_WF_TL SUBB, GMA_ACTCOL_WF_TL SUBT
    where SUBB.ACTIVITY_ID = SUBT.ACTIVITY_ID
    and SUBB.TABLE_NAME = SUBT.TABLE_NAME
    and SUBB.COLUMN_NAME = SUBT.COLUMN_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.COLUMN_PROMPT <> SUBT.COLUMN_PROMPT
  ));

  insert into GMA_ACTCOL_WF_TL (
    ACTIVITY_ID,
    COLUMN_HIERARCHY,
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_PROMPT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTIVITY_ID,
    B.COLUMN_HIERARCHY,
    B.TABLE_NAME,
    B.COLUMN_NAME,
    B.COLUMN_PROMPT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GMA_ACTCOL_WF_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GMA_ACTCOL_WF_TL T
    where T.ACTIVITY_ID = B.ACTIVITY_ID
    and T.TABLE_NAME = B.TABLE_NAME
    and T.COLUMN_NAME = B.COLUMN_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_OWNER         in VARCHAR2
) IS
BEGIN
  update GMA_ACTCOL_WF_TL set
    COLUMN_PROMPT = X_COLUMN_PROMPT,
    SOURCE_LANG   = userenv('LANG'),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = decode(X_OWNER,'SEED',1,0),
    LAST_UPDATE_LOGIN = 0
  where ACTIVITY_ID = X_ACTIVITY_ID
  and TABLE_NAME = X_TABLE_NAME
  and COLUMN_NAME = X_COLUMN_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ACTIVITY_ID in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_HIERARCHY in NUMBER,
  X_LOV_TABLE in VARCHAR2,
  X_LOV_COLUMN in VARCHAR2,
  X_COLUMN_PROMPT in VARCHAR2,
  X_OWNER         in VARCHAR2
) IS
 l_activity_id number(10);
 l_user_id number:=0;
 l_row_id VARCHAR2(64);
 BEGIN
    IF (X_OWNER ='SEED') THEN
        l_user_id :=1;
    END IF;

    SELECT activity_id into l_activity_id
    FROM   GMA_ACTCOL_WF_B
    WHERE  ACTIVITY_ID = X_ACTIVITY_ID
       and TABLE_NAME = X_TABLE_NAME
       and COLUMN_NAME = X_COLUMN_NAME;

   GMA_ACTCOL_WF_PKG.UPDATE_ROW (X_ACTIVITY_ID =>X_ACTIVITY_ID,
                                 X_TABLE_NAME => X_TABLE_NAME,
                                 X_COLUMN_NAME=> X_COLUMN_NAME,
                                 X_COLUMN_HIERARCHY =>X_COLUMN_HIERARCHY,
                                 X_LOV_TABLE => X_LOV_TABLE,
                                 X_LOV_COLUMN =>X_LOV_COLUMN,
                                 X_COLUMN_PROMPT =>X_COLUMN_PROMPT,
                                 X_LAST_UPDATE_DATE => sysdate,
                                 X_LAST_UPDATED_BY => l_user_id,
                                 X_LAST_UPDATE_LOGIN =>0);
 EXCEPTION
    WHEN NO_DATA_FOUND THEN

   GMA_ACTCOL_WF_PKG.INSERT_ROW (X_ROWID =>l_row_id,
                                 X_ACTIVITY_ID =>X_ACTIVITY_ID,
                                 X_TABLE_NAME => X_TABLE_NAME,
                                 X_COLUMN_NAME=> X_COLUMN_NAME,
                                 X_COLUMN_HIERARCHY =>X_COLUMN_HIERARCHY,
                                 X_LOV_TABLE => X_LOV_TABLE,
                                 X_LOV_COLUMN =>X_LOV_COLUMN,
                                 X_COLUMN_PROMPT =>X_COLUMN_PROMPT,
  				 X_CREATION_DATE => sysdate,
				 X_CREATED_BY => L_USER_ID,
                                 X_LAST_UPDATE_DATE => sysdate,
                                 X_LAST_UPDATED_BY => l_user_id,
                                 X_LAST_UPDATE_LOGIN =>0);
END LOAD_ROW;

end GMA_ACTCOL_WF_PKG;

/
