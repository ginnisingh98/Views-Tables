--------------------------------------------------------
--  DDL for Package Body XDP_DQ_CONFIGURATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_DQ_CONFIGURATION_PKG" AS
/* $Header: XDPDQCNB.pls 120.1 2005/06/15 22:47:12 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_INTERNAL_Q_NAME in VARCHAR2,
  X_Q_ALIAS in VARCHAR2,
  X_QUEUE_TABLE_NAME in VARCHAR2,
  X_PAYLOAD_TYPE in VARCHAR2,
  X_NUM_OF_DQER in NUMBER,
  X_DQ_PROC_NAME in VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_IS_AQ_FLAG in VARCHAR2,
  X_STATE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_EXCEPTION_QUEUE_NAME in VARCHAR2,
  X_MAX_RETRIES in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XDP_DQ_CONFIGURATION
    where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME
    ;
begin
  insert into XDP_DQ_CONFIGURATION (
    INTERNAL_Q_NAME,
    Q_ALIAS,
    QUEUE_TABLE_NAME,
    PAYLOAD_TYPE,
    NUM_OF_DQER,
    DQ_PROC_NAME,
    MODULE_NAME,
    IS_AQ_FLAG,
    STATE,
    DISPLAY_SEQUENCE,
    EXCEPTION_QUEUE_NAME,
    MAX_RETRIES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_INTERNAL_Q_NAME,
    X_Q_ALIAS,
    X_QUEUE_TABLE_NAME,
    X_PAYLOAD_TYPE,
    X_NUM_OF_DQER,
    X_DQ_PROC_NAME,
    X_MODULE_NAME,
    X_IS_AQ_FLAG,
    X_STATE,
    X_DISPLAY_SEQUENCE,
    X_EXCEPTION_QUEUE_NAME,
    X_MAX_RETRIES,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XDP_DQ_CONFIGURATION_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    INTERNAL_Q_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_INTERNAL_Q_NAME,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XDP_DQ_CONFIGURATION_TL T
    where T.INTERNAL_Q_NAME = X_INTERNAL_Q_NAME
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
  X_INTERNAL_Q_NAME in VARCHAR2,
  X_Q_ALIAS in VARCHAR2,
  X_QUEUE_TABLE_NAME in VARCHAR2,
  X_PAYLOAD_TYPE in VARCHAR2,
  X_NUM_OF_DQER in NUMBER,
  X_DQ_PROC_NAME in VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_IS_AQ_FLAG in VARCHAR2,
  X_STATE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_EXCEPTION_QUEUE_NAME in VARCHAR2,
  X_MAX_RETRIES in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      Q_ALIAS,
      QUEUE_TABLE_NAME,
      PAYLOAD_TYPE,
      NUM_OF_DQER,
      DQ_PROC_NAME,
      MODULE_NAME,
      IS_AQ_FLAG,
      STATE,
      DISPLAY_SEQUENCE,
      EXCEPTION_QUEUE_NAME,
      MAX_RETRIES
    from XDP_DQ_CONFIGURATION
    where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME
    for update of INTERNAL_Q_NAME nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XDP_DQ_CONFIGURATION_TL
    where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INTERNAL_Q_NAME nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.Q_ALIAS = X_Q_ALIAS)
      AND (recinfo.QUEUE_TABLE_NAME = X_QUEUE_TABLE_NAME)
      AND (recinfo.PAYLOAD_TYPE = X_PAYLOAD_TYPE)
      AND (recinfo.NUM_OF_DQER = X_NUM_OF_DQER)
      AND (recinfo.DQ_PROC_NAME = X_DQ_PROC_NAME)
      AND (recinfo.MODULE_NAME = X_MODULE_NAME)
      AND (recinfo.IS_AQ_FLAG = X_IS_AQ_FLAG)
      AND (recinfo.STATE = X_STATE)
      AND ((recinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
           OR ((recinfo.DISPLAY_SEQUENCE is null) AND (X_DISPLAY_SEQUENCE is null)))
      AND ((recinfo.EXCEPTION_QUEUE_NAME = X_EXCEPTION_QUEUE_NAME)
           OR ((recinfo.EXCEPTION_QUEUE_NAME is null) AND (X_EXCEPTION_QUEUE_NAME is null)))
      AND ((recinfo.MAX_RETRIES = X_MAX_RETRIES)
           OR ((recinfo.MAX_RETRIES is null) AND (X_MAX_RETRIES is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_INTERNAL_Q_NAME in VARCHAR2,
  X_Q_ALIAS in VARCHAR2,
  X_QUEUE_TABLE_NAME in VARCHAR2,
  X_PAYLOAD_TYPE in VARCHAR2,
  X_NUM_OF_DQER in NUMBER,
  X_DQ_PROC_NAME in VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_IS_AQ_FLAG in VARCHAR2,
  X_STATE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_EXCEPTION_QUEUE_NAME in VARCHAR2,
  X_MAX_RETRIES in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XDP_DQ_CONFIGURATION set
    Q_ALIAS = X_Q_ALIAS,
    QUEUE_TABLE_NAME = X_QUEUE_TABLE_NAME,
    PAYLOAD_TYPE = X_PAYLOAD_TYPE,
    NUM_OF_DQER = X_NUM_OF_DQER,
    DQ_PROC_NAME = X_DQ_PROC_NAME,
    MODULE_NAME = X_MODULE_NAME,
    IS_AQ_FLAG = X_IS_AQ_FLAG,
    STATE = X_STATE,
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    EXCEPTION_QUEUE_NAME = X_EXCEPTION_QUEUE_NAME,
    MAX_RETRIES = X_MAX_RETRIES,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XDP_DQ_CONFIGURATION_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INTERNAL_Q_NAME in VARCHAR2
) is
begin
  delete from XDP_DQ_CONFIGURATION_TL
  where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XDP_DQ_CONFIGURATION
  where INTERNAL_Q_NAME = X_INTERNAL_Q_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XDP_DQ_CONFIGURATION_TL T
  where not exists
    (select NULL
    from XDP_DQ_CONFIGURATION B
    where B.INTERNAL_Q_NAME = T.INTERNAL_Q_NAME
    );

  update XDP_DQ_CONFIGURATION_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XDP_DQ_CONFIGURATION_TL B
    where B.INTERNAL_Q_NAME = T.INTERNAL_Q_NAME
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INTERNAL_Q_NAME,
      T.LANGUAGE
  ) in (select
      SUBT.INTERNAL_Q_NAME,
      SUBT.LANGUAGE
    from XDP_DQ_CONFIGURATION_TL SUBB, XDP_DQ_CONFIGURATION_TL SUBT
    where SUBB.INTERNAL_Q_NAME = SUBT.INTERNAL_Q_NAME
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XDP_DQ_CONFIGURATION_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    INTERNAL_Q_NAME,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.INTERNAL_Q_NAME,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XDP_DQ_CONFIGURATION_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XDP_DQ_CONFIGURATION_TL T
    where T.INTERNAL_Q_NAME = B.INTERNAL_Q_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_INTERNAL_Q_NAME in VARCHAR2,
  X_Q_ALIAS in VARCHAR2,
  X_QUEUE_TABLE_NAME in VARCHAR2,
  X_PAYLOAD_TYPE in VARCHAR2,
  X_NUM_OF_DQER in NUMBER,
  X_DQ_PROC_NAME in VARCHAR2,
  X_MODULE_NAME in VARCHAR2,
  X_IS_AQ_FLAG in VARCHAR2,
  X_STATE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_EXCEPTION_QUEUE_NAME in VARCHAR2,
  X_MAX_RETRIES in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id            number := 0;
     row_id             varchar2(64);

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     XDP_DQ_CONFIGURATION_PKG.UPDATE_ROW (
  	X_INTERNAL_Q_NAME => X_INTERNAL_Q_NAME,
  	X_Q_ALIAS => X_Q_ALIAS,
  	X_QUEUE_TABLE_NAME => X_QUEUE_TABLE_NAME,
  	X_PAYLOAD_TYPE => X_PAYLOAD_TYPE,
  	X_NUM_OF_DQER => X_NUM_OF_DQER,
  	X_DQ_PROC_NAME => X_DQ_PROC_NAME,
  	X_MODULE_NAME => X_MODULE_NAME,
  	X_IS_AQ_FLAG => X_IS_AQ_FLAG,
  	X_STATE => X_STATE,
  	X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
  	X_EXCEPTION_QUEUE_NAME => X_EXCEPTION_QUEUE_NAME,
  	X_MAX_RETRIES => X_MAX_RETRIES,
  	X_DISPLAY_NAME => X_DISPLAY_NAME,
  	X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => user_id,
        X_LAST_UPDATE_LOGIN => 0);

    exception
       when NO_DATA_FOUND then
          XDP_DQ_CONFIGURATION_PKG.INSERT_ROW (
             	X_ROWID => row_id,
  	  	X_INTERNAL_Q_NAME => X_INTERNAL_Q_NAME,
  		X_Q_ALIAS => X_Q_ALIAS,
  		X_QUEUE_TABLE_NAME => X_QUEUE_TABLE_NAME,
  		X_PAYLOAD_TYPE => X_PAYLOAD_TYPE,
  		X_NUM_OF_DQER => X_NUM_OF_DQER,
  		X_DQ_PROC_NAME => X_DQ_PROC_NAME,
  		X_MODULE_NAME => X_MODULE_NAME,
  		X_IS_AQ_FLAG => X_IS_AQ_FLAG,
  		X_STATE => X_STATE,
  		X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
  		X_EXCEPTION_QUEUE_NAME => X_EXCEPTION_QUEUE_NAME,
  		X_MAX_RETRIES => X_MAX_RETRIES,
             	X_DISPLAY_NAME => X_DISPLAY_NAME,
             	X_DESCRIPTION => X_DESCRIPTION,
             	X_CREATION_DATE => sysdate,
             	X_CREATED_BY => user_id,
             	X_LAST_UPDATE_DATE => sysdate,
             	X_LAST_UPDATED_BY => user_id,
             	X_LAST_UPDATE_LOGIN => 0);
   end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_INTERNAL_Q_NAME in VARCHAR2,
   X_DISPLAY_NAME in VARCHAR2,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2) IS

begin

    -- only update rows that have not been altered by user

    update XDP_DQ_CONFIGURATION_TL
    set display_name = X_DISPLAY_NAME,
        description = X_DESCRIPTION,
        source_lang = userenv('LANG'),
        last_update_date = sysdate,
        last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
        last_update_login = 0
    where internal_q_name = X_INTERNAL_Q_NAME
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;


end XDP_DQ_CONFIGURATION_PKG;

/
