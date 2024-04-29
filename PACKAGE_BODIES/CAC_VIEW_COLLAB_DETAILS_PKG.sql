--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_COLLAB_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_COLLAB_DETAILS_PKG" AS
/* $Header: jtfcvcdb.pls 115.2 2004/06/29 20:29:59 cijang noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COLLAB_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_MEETING_MODE in VARCHAR2,
  X_MEETING_ID in NUMBER,
  X_MEETING_URL in VARCHAR2,
  X_JOIN_URL in VARCHAR2,
  X_PLAYBACK_URL in VARCHAR2,
  X_DOWNLOAD_URL in VARCHAR2,
  X_CHAT_URL in VARCHAR2,
  X_IS_STANDALONE_LOCATION in VARCHAR2,
  X_LOCATION in VARCHAR2,
  X_DIAL_IN in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is

  cursor C is select ROWID from CAC_VIEW_COLLAB_DETAILS
    where COLLAB_ID = X_COLLAB_ID
    ;
begin

  insert into CAC_VIEW_COLLAB_DETAILS (
    COLLAB_ID,
    TASK_ID,
    MEETING_MODE,
    MEETING_ID,
    MEETING_URL,
    JOIN_URL,
    PLAYBACK_URL,
    DOWNLOAD_URL,
    CHAT_URL,
    IS_STANDALONE_LOCATION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_COLLAB_ID,
    X_TASK_ID,
    X_MEETING_MODE,
    X_MEETING_ID,
    X_MEETING_URL,
    X_JOIN_URL,
    X_PLAYBACK_URL,
    X_DOWNLOAD_URL,
    X_CHAT_URL,
    X_IS_STANDALONE_LOCATION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CAC_VIEW_COLLAB_DETAILS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    COLLAB_ID,
    LOCATION,
    DIAL_IN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_COLLAB_ID,
    X_LOCATION,
    X_DIAL_IN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CAC_VIEW_COLLAB_DETAILS_TL T
    where T.COLLAB_ID = X_COLLAB_ID
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
  X_COLLAB_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_MEETING_MODE in VARCHAR2,
  X_MEETING_ID in NUMBER,
  X_MEETING_URL in VARCHAR2,
  X_JOIN_URL in VARCHAR2,
  X_PLAYBACK_URL in VARCHAR2,
  X_DOWNLOAD_URL in VARCHAR2,
  X_CHAT_URL in VARCHAR2,
  X_IS_STANDALONE_LOCATION in VARCHAR2,
  X_LOCATION in VARCHAR2,
  X_DIAL_IN in VARCHAR2
) is
  cursor c is select
      TASK_ID,
      MEETING_MODE,
      MEETING_ID,
      MEETING_URL,
      JOIN_URL,
      PLAYBACK_URL,
      DOWNLOAD_URL,
      CHAT_URL,
      IS_STANDALONE_LOCATION
    from CAC_VIEW_COLLAB_DETAILS
    where COLLAB_ID = X_COLLAB_ID
    for update of COLLAB_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LOCATION,
      DIAL_IN,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CAC_VIEW_COLLAB_DETAILS_TL
    where COLLAB_ID = X_COLLAB_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of COLLAB_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.TASK_ID = X_TASK_ID)
      AND ((recinfo.MEETING_MODE = X_MEETING_MODE)
           OR ((recinfo.MEETING_MODE is null) AND (X_MEETING_MODE is null)))
      AND ((recinfo.MEETING_ID = X_MEETING_ID)
           OR ((recinfo.MEETING_ID is null) AND (X_MEETING_ID is null)))
      AND ((recinfo.MEETING_URL = X_MEETING_URL)
           OR ((recinfo.MEETING_URL is null) AND (X_MEETING_URL is null)))
      AND ((recinfo.JOIN_URL = X_JOIN_URL)
           OR ((recinfo.JOIN_URL is null) AND (X_JOIN_URL is null)))
      AND ((recinfo.PLAYBACK_URL = X_PLAYBACK_URL)
           OR ((recinfo.PLAYBACK_URL is null) AND (X_PLAYBACK_URL is null)))
      AND ((recinfo.DOWNLOAD_URL = X_DOWNLOAD_URL)
           OR ((recinfo.DOWNLOAD_URL is null) AND (X_DOWNLOAD_URL is null)))
      AND ((recinfo.CHAT_URL = X_CHAT_URL)
           OR ((recinfo.CHAT_URL is null) AND (X_CHAT_URL is null)))
      AND ((recinfo.IS_STANDALONE_LOCATION = X_IS_STANDALONE_LOCATION)
           OR ((recinfo.IS_STANDALONE_LOCATION is null) AND (X_IS_STANDALONE_LOCATION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.LOCATION = X_LOCATION)
               OR ((tlinfo.LOCATION is null) AND (X_LOCATION is null)))
          AND ((tlinfo.DIAL_IN = X_DIAL_IN)
               OR ((tlinfo.DIAL_IN is null) AND (X_DIAL_IN is null)))
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
  X_COLLAB_ID in NUMBER,
  X_TASK_ID in NUMBER,
  X_MEETING_MODE in VARCHAR2,
  X_MEETING_ID in NUMBER,
  X_MEETING_URL in VARCHAR2,
  X_JOIN_URL in VARCHAR2,
  X_PLAYBACK_URL in VARCHAR2,
  X_DOWNLOAD_URL in VARCHAR2,
  X_CHAT_URL in VARCHAR2,
  X_IS_STANDALONE_LOCATION in VARCHAR2,
  X_LOCATION in VARCHAR2,
  X_DIAL_IN in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CAC_VIEW_COLLAB_DETAILS set
    TASK_ID = X_TASK_ID,
    MEETING_MODE = X_MEETING_MODE,
    MEETING_ID = X_MEETING_ID,
    MEETING_URL = X_MEETING_URL,
    JOIN_URL = X_JOIN_URL,
    PLAYBACK_URL = X_PLAYBACK_URL,
    DOWNLOAD_URL = X_DOWNLOAD_URL,
    CHAT_URL = X_CHAT_URL,
    IS_STANDALONE_LOCATION = X_IS_STANDALONE_LOCATION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COLLAB_ID = X_COLLAB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CAC_VIEW_COLLAB_DETAILS_TL set
    LOCATION = X_LOCATION,
    DIAL_IN = X_DIAL_IN,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where COLLAB_ID = X_COLLAB_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COLLAB_ID in NUMBER
) is
begin
  delete from CAC_VIEW_COLLAB_DETAILS_TL
  where COLLAB_ID = X_COLLAB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CAC_VIEW_COLLAB_DETAILS
  where COLLAB_ID = X_COLLAB_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CAC_VIEW_COLLAB_DETAILS_TL T
  where not exists
    (select NULL
    from CAC_VIEW_COLLAB_DETAILS B
    where B.COLLAB_ID = T.COLLAB_ID
    );

  update CAC_VIEW_COLLAB_DETAILS_TL T set (
      LOCATION,
      DIAL_IN
    ) = (select
      B.LOCATION,
      B.DIAL_IN
    from CAC_VIEW_COLLAB_DETAILS_TL B
    where B.COLLAB_ID = T.COLLAB_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.COLLAB_ID,
      T.LANGUAGE
  ) in (select
      SUBT.COLLAB_ID,
      SUBT.LANGUAGE
    from CAC_VIEW_COLLAB_DETAILS_TL SUBB, CAC_VIEW_COLLAB_DETAILS_TL SUBT
    where SUBB.COLLAB_ID = SUBT.COLLAB_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOCATION <> SUBT.LOCATION
      or (SUBB.LOCATION is null and SUBT.LOCATION is not null)
      or (SUBB.LOCATION is not null and SUBT.LOCATION is null)
      or SUBB.DIAL_IN <> SUBT.DIAL_IN
      or (SUBB.DIAL_IN is null and SUBT.DIAL_IN is not null)
      or (SUBB.DIAL_IN is not null and SUBT.DIAL_IN is null)
  ));

  insert into CAC_VIEW_COLLAB_DETAILS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    COLLAB_ID,
    LOCATION,
    DIAL_IN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.COLLAB_ID,
    B.LOCATION,
    B.DIAL_IN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CAC_VIEW_COLLAB_DETAILS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CAC_VIEW_COLLAB_DETAILS_TL T
    where T.COLLAB_ID = B.COLLAB_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;



END CAC_VIEW_COLLAB_DETAILS_PKG;

/
