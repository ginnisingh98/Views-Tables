--------------------------------------------------------
--  DDL for Package Body OKC_NUMBER_SCHEMES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_NUMBER_SCHEMES_PVT" as
/* $Header: OKCSNOSB.pls 120.0 2005/05/26 09:28:30 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_NUM_SCHEME_ID in NUMBER,
  X_NUMBER_ARTICLE_YN in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SCHEME_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OKC_NUMBER_SCHEMES_B
    where NUM_SCHEME_ID = X_NUM_SCHEME_ID
    ;

  l_return_status      VARCHAR2(30);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_out_string         VARCHAR2(2000);

begin
  insert into OKC_NUMBER_SCHEMES_B (
    NUM_SCHEME_ID,
    NUMBER_ARTICLE_YN,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_NUM_SCHEME_ID,
    X_NUMBER_ARTICLE_YN,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OKC_NUMBER_SCHEMES_TL (
    DESCRIPTION,
    NUM_SCHEME_ID,
    SCHEME_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_NUM_SCHEME_ID,
    X_SCHEME_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from OKC_NUMBER_SCHEMES_TL T
    where T.NUM_SCHEME_ID = X_NUM_SCHEME_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

/*
-- this update is now called from the UI
-- update the preview column
OKC_NUMBER_SCHEME_GRP.generate_preview(
    p_api_version     => 1,
    p_init_msg_list   => FND_API.G_TRUE,
    x_return_status   => l_return_status,
    x_msg_count       => l_msg_count,
    x_msg_data        => l_msg_data,
    x_out_string      => l_out_string,
    p_update_db       => FND_API.G_TRUE,
    p_num_scheme_id   => X_NUM_SCHEME_ID
      ) ;
*/

end INSERT_ROW;

procedure LOCK_ROW (
  X_NUM_SCHEME_ID in NUMBER,
  X_NUMBER_ARTICLE_YN in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SCHEME_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      NUMBER_ARTICLE_YN,
      OBJECT_VERSION_NUMBER
    from OKC_NUMBER_SCHEMES_B
    where NUM_SCHEME_ID = X_NUM_SCHEME_ID
    for update of NUM_SCHEME_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SCHEME_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OKC_NUMBER_SCHEMES_TL
    where NUM_SCHEME_ID = X_NUM_SCHEME_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of NUM_SCHEME_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.NUMBER_ARTICLE_YN = X_NUMBER_ARTICLE_YN)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.SCHEME_NAME = X_SCHEME_NAME)
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
  X_NUM_SCHEME_ID in NUMBER,
  X_NUMBER_ARTICLE_YN in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SCHEME_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  l_return_status      VARCHAR2(30);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_out_string         VARCHAR2(2000);
begin
  update OKC_NUMBER_SCHEMES_B set
    NUMBER_ARTICLE_YN = X_NUMBER_ARTICLE_YN,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where NUM_SCHEME_ID = X_NUM_SCHEME_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OKC_NUMBER_SCHEMES_TL set
    SCHEME_NAME = X_SCHEME_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where NUM_SCHEME_ID = X_NUM_SCHEME_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

/*
-- this update is now called from the UI
-- update the preview column
OKC_NUMBER_SCHEME_GRP.generate_preview(
    p_api_version     => 1,
    p_init_msg_list   => FND_API.G_TRUE,
    x_return_status   => l_return_status,
    x_msg_count       => l_msg_count,
    x_msg_data        => l_msg_data,
    x_out_string      => l_out_string,
    p_update_db       => FND_API.G_TRUE,
    p_num_scheme_id   => X_NUM_SCHEME_ID
      ) ;
*/





end UPDATE_ROW;

procedure DELETE_ROW (
  X_NUM_SCHEME_ID in NUMBER
) is
begin
  delete from OKC_NUMBER_SCHEMES_TL
  where NUM_SCHEME_ID = X_NUM_SCHEME_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  -- remove child records from okc_number_scheme_dtls
  delete from okc_number_scheme_dtls
  where NUM_SCHEME_ID = X_NUM_SCHEME_ID;

  delete from OKC_NUMBER_SCHEMES_B
  where NUM_SCHEME_ID = X_NUM_SCHEME_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OKC_NUMBER_SCHEMES_TL T
  where not exists
    (select NULL
    from OKC_NUMBER_SCHEMES_B B
    where B.NUM_SCHEME_ID = T.NUM_SCHEME_ID
    );

  update OKC_NUMBER_SCHEMES_TL T set (
      SCHEME_NAME,
      DESCRIPTION
    ) = (select
      B.SCHEME_NAME,
      B.DESCRIPTION
    from OKC_NUMBER_SCHEMES_TL B
    where B.NUM_SCHEME_ID = T.NUM_SCHEME_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NUM_SCHEME_ID,
      T.LANGUAGE
  ) in (select
      SUBT.NUM_SCHEME_ID,
      SUBT.LANGUAGE
    from OKC_NUMBER_SCHEMES_TL SUBB, OKC_NUMBER_SCHEMES_TL SUBT
    where SUBB.NUM_SCHEME_ID = SUBT.NUM_SCHEME_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SCHEME_NAME <> SUBT.SCHEME_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OKC_NUMBER_SCHEMES_TL (
    DESCRIPTION,
    NUM_SCHEME_ID,
    SCHEME_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DESCRIPTION,
    B.NUM_SCHEME_ID,
    B.SCHEME_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKC_NUMBER_SCHEMES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKC_NUMBER_SCHEMES_TL T
    where T.NUM_SCHEME_ID = B.NUM_SCHEME_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end OKC_NUMBER_SCHEMES_PVT;

/
