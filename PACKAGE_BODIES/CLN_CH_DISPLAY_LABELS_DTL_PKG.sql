--------------------------------------------------------
--  DDL for Package Body CLN_CH_DISPLAY_LABELS_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_CH_DISPLAY_LABELS_DTL_PKG" as
/* $Header: ECXDISLB.pls 120.0 2005/08/25 04:44:50 nparihar noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

--
--  Package
--    CLN_CH_DISPLAY_LABELS_DTL_PKG
--
--  Purpose
--
--  History
--


PROCEDURE TRANSLATE_ROW
  (
   X_GUID                IN RAW,
   X_OWNER               IN VARCHAR2,
   X_DISPLAY_LABEL       IN VARCHAR2
   ) IS
BEGIN
   UPDATE CLN_CH_DISPLAY_LABELS_DTL_TL SET
     GUID          = X_GUID,
  DISPLAY_LABEL= X_DISPLAY_LABEL,
     LAST_UPDATE_DATE           = sysdate,
     LAST_UPDATED_BY            = Decode(X_OWNER, 'SEED', 1, 0),
     LAST_UPDATE_LOGIN          = 0,
     SOURCE_LANG                = userenv('LANG')
     WHERE GUID   = X_GUID AND userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;




PROCEDURE LOAD_ROW
  (
   X_GUID            IN RAW ,
   X_OWNER                      IN VARCHAR2,
   X_PARENT_GUID         IN RAW,
   X_CLN_COLUMNS         IN VARCHAR2,
   X_DISPLAY_LABEL       IN VARCHAR2,
   X_SEARCH_ENABLED      IN VARCHAR2,
   X_DISPLAY_ENABLED_EVENTS_SCR IN VARCHAR2,
   X_DISPLAY_ENABLED_RESULTS_TBL IN VARCHAR2
  ) IS
    cursor c is select * from CLN_CH_DISPLAY_LABELS_HDR where GUID=X_PARENT_GUID;
    cursor c1 is select * from CLN_CH_DISPLAY_LABELS_DTL_B where (PARENT_GUID=X_PARENT_GUID)
AND (GUID=X_GUID);
    l_fkpresent c%rowtype;
    l_pkpresent c1%rowtype;
    l_user_id                  NUMBER := 0;
    l_sysdate                  DATE;
    l_guid           raw(100);
   BEGIN
     IF (x_owner = 'SEED') THEN
         l_user_id := 1;
     END IF;
     select sysdate into l_sysdate from dual;
     OPEN c;
     OPEN c1;
     fetch c into l_fkpresent;
     fetch c1 into l_pkpresent;
     IF (c1%found) THEN
  UPDATE CLN_CH_DISPLAY_LABELS_DTL_B SET
             CLN_COLUMNS=X_CLN_COLUMNS,
             SEARCH_ENABLED=X_SEARCH_ENABLED,
             DISPLAY_ENABLED_EVENTS_SCREEN=X_DISPLAY_ENABLED_EVENTS_SCR,
             DISPLAY_ENABLED_RESULTS_TABLE=X_DISPLAY_ENABLED_RESULTS_TBL,
             LAST_UPDATE_DATE=l_sysdate,
             LAST_UPDATED_BY=l_user_id,
             LAST_UPDATE_LOGIN=0
                         WHERE  GUID= X_GUID and PARENT_GUID= X_PARENT_GUID;
   UPDATE CLN_CH_DISPLAY_LABELS_DTL_TL SET
            DISPLAY_LABEL=X_DISPLAY_LABEL,
             LAST_UPDATE_DATE=l_sysdate,
             LAST_UPDATED_BY=l_user_id,
             LAST_UPDATE_LOGIN=0,
           SOURCE_LANG=userenv('LANG')
       WHERE GUID = X_GUID and userenv('LANG') in (LANGUAGE,SOURCE_LANG) ;

      ELSIF (c1%notfound and c%found) then
       Insert into  CLN_CH_DISPLAY_LABELS_DTL_B(
             GUID,
             PARENT_GUID,
             CLN_COLUMNS,
             SEARCH_ENABLED,
             DISPLAY_ENABLED_EVENTS_SCREEN,
             DISPLAY_ENABLED_RESULTS_TABLE,
                         CREATION_DATE,
                         CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN)
            values(
            X_GUID,
            X_PARENT_GUID,
            X_CLN_COLUMNS,
     X_SEARCH_ENABLED,
            X_DISPLAY_ENABLED_EVENTS_SCR,
            X_DISPLAY_ENABLED_RESULTS_TBL,
            l_sysdate,
            l_user_id,
            l_sysdate,
            l_user_id,
            0);
  INSERT into CLN_CH_DISPLAY_LABELS_DTL_TL(
       GUID,
       DISPLAY_LABEL,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
       LANGUAGE,
        SOURCE_LANG
       )select
             X_GUID,
             X_DISPLAY_LABEL,
            l_sysdate,
             l_user_id,
             l_sysdate,
             l_user_id,
          0,
             L.LANGUAGE_CODE,
             userenv('LANG')
             from FND_LANGUAGES L
             where L.INSTALLED_FLAG in ('I','B') and not exists
                         (select NULL
                         from CLN_CH_DISPLAY_LABELS_DTL_TL T
                         where T.GUID = X_GUID
                         and T.LANGUAGE = L.LANGUAGE_CODE);
      END IF;
close c;
close c1;
commit;
END LOAD_ROW;



procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GUID in RAW,
  X_PARENT_GUID in RAW,
  X_CLN_COLUMNS in VARCHAR2,
  X_SEARCH_ENABLED in VARCHAR2,
  X_DISPLAY_ENABLED_EVENTS_SCREE in VARCHAR2,
  X_DISPLAY_ENABLED_RESULTS_TABL in VARCHAR2,
  X_DISPLAY_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CLN_CH_DISPLAY_LABELS_DTL_B
    where GUID = X_GUID
    ;
begin
  insert into CLN_CH_DISPLAY_LABELS_DTL_B (
    GUID,
    PARENT_GUID,
    CLN_COLUMNS,
    SEARCH_ENABLED,
    DISPLAY_ENABLED_EVENTS_SCREEN,
    DISPLAY_ENABLED_RESULTS_TABLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_GUID,
    X_PARENT_GUID,
    X_CLN_COLUMNS,
    X_SEARCH_ENABLED,
    X_DISPLAY_ENABLED_EVENTS_SCREE,
    X_DISPLAY_ENABLED_RESULTS_TABL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CLN_CH_DISPLAY_LABELS_DTL_TL (
    GUID,
    DISPLAY_LABEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_GUID,
    X_DISPLAY_LABEL,
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
    from CLN_CH_DISPLAY_LABELS_DTL_TL T
    where T.GUID = X_GUID
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
  X_GUID in RAW,
  X_PARENT_GUID in RAW,
  X_CLN_COLUMNS in VARCHAR2,
  X_SEARCH_ENABLED in VARCHAR2,
  X_DISPLAY_ENABLED_EVENTS_SCREE in VARCHAR2,
  X_DISPLAY_ENABLED_RESULTS_TABL in VARCHAR2,
  X_DISPLAY_LABEL in VARCHAR2
) is
  cursor c is select
      PARENT_GUID,
      CLN_COLUMNS,
      SEARCH_ENABLED,
      DISPLAY_ENABLED_EVENTS_SCREEN,
      DISPLAY_ENABLED_RESULTS_TABLE
    from CLN_CH_DISPLAY_LABELS_DTL_B
    where GUID = X_GUID
    for update of GUID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CLN_CH_DISPLAY_LABELS_DTL_TL
    where GUID = X_GUID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GUID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PARENT_GUID = X_PARENT_GUID)
      AND ((recinfo.CLN_COLUMNS = X_CLN_COLUMNS)
           OR ((recinfo.CLN_COLUMNS is null) AND (X_CLN_COLUMNS is null)))
      AND ((recinfo.SEARCH_ENABLED = X_SEARCH_ENABLED)
           OR ((recinfo.SEARCH_ENABLED is null) AND (X_SEARCH_ENABLED is null)))
      AND ((recinfo.DISPLAY_ENABLED_EVENTS_SCREEN = X_DISPLAY_ENABLED_EVENTS_SCREE)
           OR ((recinfo.DISPLAY_ENABLED_EVENTS_SCREEN is null) AND (X_DISPLAY_ENABLED_EVENTS_SCREE is null)))
      AND ((recinfo.DISPLAY_ENABLED_RESULTS_TABLE = X_DISPLAY_ENABLED_RESULTS_TABL)
           OR ((recinfo.DISPLAY_ENABLED_RESULTS_TABLE is null) AND (X_DISPLAY_ENABLED_RESULTS_TABL is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DISPLAY_LABEL = X_DISPLAY_LABEL)
               OR ((tlinfo.DISPLAY_LABEL is null) AND (X_DISPLAY_LABEL is null)))
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
  X_GUID in RAW,
  X_PARENT_GUID in RAW,
  X_CLN_COLUMNS in VARCHAR2,
  X_SEARCH_ENABLED in VARCHAR2,
  X_DISPLAY_ENABLED_EVENTS_SCREE in VARCHAR2,
  X_DISPLAY_ENABLED_RESULTS_TABL in VARCHAR2,
  X_DISPLAY_LABEL in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CLN_CH_DISPLAY_LABELS_DTL_B set
    PARENT_GUID = X_PARENT_GUID,
    CLN_COLUMNS = X_CLN_COLUMNS,
    SEARCH_ENABLED = X_SEARCH_ENABLED,
    DISPLAY_ENABLED_EVENTS_SCREEN = X_DISPLAY_ENABLED_EVENTS_SCREE,
    DISPLAY_ENABLED_RESULTS_TABLE = X_DISPLAY_ENABLED_RESULTS_TABL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GUID = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CLN_CH_DISPLAY_LABELS_DTL_TL set
    DISPLAY_LABEL = X_DISPLAY_LABEL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GUID = X_GUID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GUID in RAW
) is
begin
  delete from CLN_CH_DISPLAY_LABELS_DTL_TL
  where GUID = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CLN_CH_DISPLAY_LABELS_DTL_B
  where GUID = X_GUID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CLN_CH_DISPLAY_LABELS_DTL_TL T
  where not exists
    (select NULL
    from CLN_CH_DISPLAY_LABELS_DTL_B B
    where B.GUID = T.GUID
    );

  update CLN_CH_DISPLAY_LABELS_DTL_TL T set (
      DISPLAY_LABEL
    ) = (select
      B.DISPLAY_LABEL
    from CLN_CH_DISPLAY_LABELS_DTL_TL B
    where B.GUID = T.GUID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GUID,
      T.LANGUAGE
  ) in (select
      SUBT.GUID,
      SUBT.LANGUAGE
    from CLN_CH_DISPLAY_LABELS_DTL_TL SUBB, CLN_CH_DISPLAY_LABELS_DTL_TL SUBT
    where SUBB.GUID = SUBT.GUID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_LABEL <> SUBT.DISPLAY_LABEL
      or (SUBB.DISPLAY_LABEL is null and SUBT.DISPLAY_LABEL is not null)
      or (SUBB.DISPLAY_LABEL is not null and SUBT.DISPLAY_LABEL is null)
  ));

  insert into CLN_CH_DISPLAY_LABELS_DTL_TL (
    GUID,
    DISPLAY_LABEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.GUID,
    B.DISPLAY_LABEL,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CLN_CH_DISPLAY_LABELS_DTL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CLN_CH_DISPLAY_LABELS_DTL_TL T
    where T.GUID = B.GUID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end CLN_CH_DISPLAY_LABELS_DTL_PKG;

/
