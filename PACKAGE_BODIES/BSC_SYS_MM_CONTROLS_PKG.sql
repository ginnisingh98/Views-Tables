--------------------------------------------------------
--  DDL for Package Body BSC_SYS_MM_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_MM_CONTROLS_PKG" as
/* $Header: BSCSMMB.pls 115.6 2003/02/12 14:29:26 adeulgao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_BUTTON_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor C is select ROWID from BSC_SYS_MM_CONTROLS_TL
    where BUTTON_ID = X_BUTTON_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_SYS_MM_CONTROLS_TL (
    BUTTON_ID,
    NAME,
    HELP,
    COMMAND,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_BUTTON_ID,
    X_NAME,
    X_HELP,
    X_COMMAND,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_SYS_MM_CONTROLS_TL T
    where T.BUTTON_ID = X_BUTTON_ID
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
  X_BUTTON_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
  cursor c1 is select
      COMMAND,
      NAME,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_SYS_MM_CONTROLS_TL
    where BUTTON_ID = X_BUTTON_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BUTTON_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
          AND (tlinfo.HELP = X_HELP)
          AND ((tlinfo.COMMAND = X_COMMAND)
               OR ((tlinfo.COMMAND is null) AND (X_COMMAND is null)))
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
  X_BUTTON_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2,
  X_HELP in VARCHAR2
) is
begin
  update BSC_SYS_MM_CONTROLS_TL set
    COMMAND = X_COMMAND,
    NAME = X_NAME,
    HELP = X_HELP,
    SOURCE_LANG = userenv('LANG')
  where BUTTON_ID = X_BUTTON_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BUTTON_ID in NUMBER
) is
begin
  delete from BSC_SYS_MM_CONTROLS_TL
  where BUTTON_ID = X_BUTTON_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update BSC_SYS_MM_CONTROLS_TL T set (
      NAME,
      HELP
    ) = (select
      B.NAME,
      B.HELP
    from BSC_SYS_MM_CONTROLS_TL B
    where B.BUTTON_ID = T.BUTTON_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BUTTON_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BUTTON_ID,
      SUBT.LANGUAGE
    from BSC_SYS_MM_CONTROLS_TL SUBB, BSC_SYS_MM_CONTROLS_TL SUBT
    where SUBB.BUTTON_ID = SUBT.BUTTON_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.HELP <> SUBT.HELP
  ));

  insert into BSC_SYS_MM_CONTROLS_TL (
    BUTTON_ID,
    NAME,
    HELP,
    COMMAND,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.BUTTON_ID,
    B.NAME,
    B.HELP,
    B.COMMAND,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_SYS_MM_CONTROLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_SYS_MM_CONTROLS_TL T
    where T.BUTTON_ID = B.BUTTON_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_SYS_MM_CONTROLS_PKG;

/
