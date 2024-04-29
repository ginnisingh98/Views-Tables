--------------------------------------------------------
--  DDL for Package Body BEN_STARTUP_LERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_STARTUP_LERS_PKG" as
/* $Header: beslr01t.pkb 120.0 2005/05/28 11:52:44 appldev noship $ */
procedure OWNER_TO_WHO (
  P_OWNER in VARCHAR2,
  P_CREATION_DATE out nocopy DATE,
  P_CREATED_BY out nocopy NUMBER,
  P_LAST_UPDATE_DATE out nocopy DATE,
  P_LAST_UPDATED_BY out nocopy NUMBER,
  P_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if P_OWNER = 'SEED' then
    P_CREATED_BY := 1;
    P_LAST_UPDATED_BY := 1;
  else
    P_CREATED_BY := 0;
    P_LAST_UPDATED_BY := 0;
  end if;
  P_CREATION_DATE := sysdate;
  P_LAST_UPDATE_DATE := sysdate;
  P_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

procedure INSERT_ROW (
  P_ROWID in out nocopy VARCHAR2,
  P_TYP_CD in VARCHAR2,
  P_NAME in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BEN_STARTUP_LERS
    where TYP_CD = P_TYP_CD
    ;
begin
  insert into BEN_STARTUP_LERS (
    TYP_CD,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_TYP_CD,
    P_NAME,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
  );

  insert into BEN_STARTUP_LERS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    TYP_CD,
    NAME,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_TYP_CD,
    P_NAME,
    P_LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BEN_STARTUP_LERS_TL T
    where T.TYP_CD = P_TYP_CD
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_TYP_CD in VARCHAR2,
  P_NAME in VARCHAR2
) is
  cursor c is select TYP_CD,NAME
    from BEN_STARTUP_LERS
    where TYP_CD = P_TYP_CD
    for update of TYP_CD nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BEN_STARTUP_LERS_TL
    where TYP_CD = P_TYP_CD
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of TYP_CD nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ((recinfo.TYP_CD = P_TYP_CD)
    AND (recinfo.NAME = P_NAME)) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = P_NAME)
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
  P_TYP_CD in VARCHAR2,
  P_NAME in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BEN_STARTUP_LERS set
    NAME = decode(userenv('LANG'),'US',P_NAME,NAME),
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
  where TYP_CD = P_TYP_CD;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update BEN_STARTUP_LERS_TL set
    NAME = P_NAME,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TYP_CD = P_TYP_CD
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_TYP_CD in VARCHAR2
) is
begin
  delete from BEN_STARTUP_LERS_TL
  where TYP_CD = P_TYP_CD;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from BEN_STARTUP_LERS
  where TYP_CD = P_TYP_CD;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure UPLOAD_ROW(P_TYP_CD in VARCHAR2,
                        P_NAME in VARCHAR2,
                        P_OWNER in VARCHAR2) is

  --
  L_ROWID ROWID;
  L_CREATION_DATE DATE;
  L_CREATED_BY NUMBER;
  L_LAST_UPDATE_DATE DATE;
  L_LAST_UPDATED_BY NUMBER;
  L_LAST_UPDATE_LOGIN NUMBER;
begin
  OWNER_TO_WHO(P_OWNER,
    L_CREATION_DATE,
    L_CREATED_BY,
    L_LAST_UPDATE_DATE,
    L_LAST_UPDATED_BY,
    L_LAST_UPDATE_LOGIN
  );
  UPDATE_ROW(P_TYP_CD,
             P_NAME,
             L_LAST_UPDATE_DATE,
             L_LAST_UPDATED_BY,
             L_LAST_UPDATE_LOGIN);
  exception
    when no_data_found then
    INSERT_ROW(L_ROWID,
               P_TYP_CD,
               P_NAME,
               L_CREATION_DATE,
               L_CREATED_BY,
               L_LAST_UPDATE_DATE,
               L_LAST_UPDATED_BY,
               L_LAST_UPDATE_LOGIN);
end;

procedure TRANSLATE_ROW(P_TYP_CD in VARCHAR2,
                        P_NAME in VARCHAR2,
                        P_OWNER in VARCHAR2) is
  --
  L_CREATION_DATE DATE;
  L_CREATED_BY NUMBER;
  L_LAST_UPDATE_DATE DATE;
  L_LAST_UPDATED_BY NUMBER;
  L_LAST_UPDATE_LOGIN NUMBER;
begin
  OWNER_TO_WHO (
    P_OWNER,
    L_CREATION_DATE,
    L_CREATED_BY,
    L_LAST_UPDATE_DATE,
    L_LAST_UPDATED_BY,
    L_LAST_UPDATE_LOGIN
  );
--
  update BEN_STARTUP_LERS_TL T  set
  NAME = P_NAME,
  LAST_UPDATE_DATE = L_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = L_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = L_LAST_UPDATE_LOGIN,
  SOURCE_LANG = userenv('LANG')
  where TYP_CD = P_TYP_CD
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

end;

procedure ADD_LANGUAGE
is
begin
  delete from BEN_STARTUP_LERS_TL T
  where not exists
    (select NULL
    from BEN_STARTUP_LERS B
    where B.TYP_CD = T.TYP_CD
    );

  update BEN_STARTUP_LERS_TL T set (
      NAME
    ) = (select
      B.NAME
    from BEN_STARTUP_LERS_TL B
    where B.TYP_CD = T.TYP_CD
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TYP_CD,
      T.LANGUAGE
  ) in (select
      SUBT.TYP_CD,
      SUBT.LANGUAGE
    from BEN_STARTUP_LERS_TL SUBB, BEN_STARTUP_LERS_TL SUBT
    where SUBB.TYP_CD = SUBT.TYP_CD
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BEN_STARTUP_LERS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    TYP_CD,
    NAME,
    LAST_UPDATE_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.TYP_CD,
    B.NAME,
    B.LAST_UPDATE_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BEN_STARTUP_LERS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BEN_STARTUP_LERS_TL T
    where T.TYP_CD = B.TYP_CD
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BEN_STARTUP_LERS_PKG;

/
