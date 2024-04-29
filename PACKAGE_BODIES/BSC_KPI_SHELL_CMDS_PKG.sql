--------------------------------------------------------
--  DDL for Package Body BSC_KPI_SHELL_CMDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_SHELL_CMDS_PKG" as
/* $Header: BSCKSHLB.pls 115.6 2003/02/12 14:26:03 adrao ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2
) is
  cursor C is select ROWID from BSC_KPI_SHELL_CMDS_TL
    where INDICATOR = X_INDICATOR
    and SHELL_CMD_ID = X_SHELL_CMD_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_KPI_SHELL_CMDS_TL (
    INDICATOR,
    SHELL_CMD_ID,
    NAME,
    COMMAND,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_INDICATOR,
    X_SHELL_CMD_ID,
    X_NAME,
    X_COMMAND,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_KPI_SHELL_CMDS_TL T
    where T.INDICATOR = X_INDICATOR
    and T.SHELL_CMD_ID = X_SHELL_CMD_ID
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
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2
) is
  cursor c1 is select
      COMMAND,
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_KPI_SHELL_CMDS_TL
    where INDICATOR = X_INDICATOR
    and SHELL_CMD_ID = X_SHELL_CMD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INDICATOR nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER,
  X_COMMAND in VARCHAR2,
  X_NAME in VARCHAR2
) is
begin
  update BSC_KPI_SHELL_CMDS_TL set
    COMMAND = X_COMMAND,
    NAME = X_NAME,
    SOURCE_LANG = userenv('LANG')
  where INDICATOR = X_INDICATOR
  and SHELL_CMD_ID = X_SHELL_CMD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INDICATOR in NUMBER,
  X_SHELL_CMD_ID in NUMBER
) is
begin
  delete from BSC_KPI_SHELL_CMDS_TL
  where INDICATOR = X_INDICATOR
  and SHELL_CMD_ID = X_SHELL_CMD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update BSC_KPI_SHELL_CMDS_TL T set (
      NAME
    ) = (select
      B.NAME
    from BSC_KPI_SHELL_CMDS_TL B
    where B.INDICATOR = T.INDICATOR
    and B.SHELL_CMD_ID = T.SHELL_CMD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INDICATOR,
      T.SHELL_CMD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INDICATOR,
      SUBT.SHELL_CMD_ID,
      SUBT.LANGUAGE
    from BSC_KPI_SHELL_CMDS_TL SUBB, BSC_KPI_SHELL_CMDS_TL SUBT
    where SUBB.INDICATOR = SUBT.INDICATOR
    and SUBB.SHELL_CMD_ID = SUBT.SHELL_CMD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BSC_KPI_SHELL_CMDS_TL (
    INDICATOR,
    SHELL_CMD_ID,
    NAME,
    COMMAND,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.INDICATOR,
    B.SHELL_CMD_ID,
    B.NAME,
    B.COMMAND,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_KPI_SHELL_CMDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_KPI_SHELL_CMDS_TL T
    where T.INDICATOR = B.INDICATOR
    and T.SHELL_CMD_ID = B.SHELL_CMD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end BSC_KPI_SHELL_CMDS_PKG;

/
