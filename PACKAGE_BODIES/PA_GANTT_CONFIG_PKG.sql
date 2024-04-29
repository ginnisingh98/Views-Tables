--------------------------------------------------------
--  DDL for Package Body PA_GANTT_CONFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GANTT_CONFIG_PKG" as
/* $Header: PAGCGCTB.pls 120.1 2005/08/19 16:32:54 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  X_GANTT_CONFIG_ID           in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_GANTT_CONFIG_USAGE        in VARCHAR2,
  X_FILTER_CODE               in VARCHAR2,
  X_TIME_SCALE_CODE           in VARCHAR2,
  X_EXPAND_COLLAPSE_FLAG      in VARCHAR2,
  X_NUMBER_OF_DISPLAYED_ROWS  in NUMBER,
  X_SHOW_ADDITIONAL_COL_FLAG  in VARCHAR2,
  X_FOCUS_ENABLED_FLAG        in VARCHAR2,
  X_SHOW_HEADER_UI_FLAG       in VARCHAR2,
  X_RECORD_VERSION_NUMBER     in NUMBER,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_CREATION_DATE             in DATE,
  X_CREATED_BY                in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
)
is

cursor C(c_gantt_config_id PA_GANTT_CONFIG_B.gantt_config_id%TYPE) is
select ROWID
  from PA_GANTT_CONFIG_B
 where GANTT_CONFIG_ID = c_gantt_config_id;

l_gantt_config_id     PA_GANTT_CONFIG_B.gantt_config_id%TYPE;

begin

  select nvl(X_GANTT_CONFIG_ID,PA_GANTT_CONFIG_B_S.nextval)
  into   l_gantt_config_id
  from   dual;

  insert into PA_GANTT_CONFIG_B (
    GANTT_CONFIG_ID,
    GANTT_VIEW_ID,
    GANTT_CONFIG_USAGE,
    FILTER_CODE,
    TIME_SCALE_CODE,
    EXPAND_COLLAPSE_FLAG,
    NUMBER_OF_DISPLAYED_ROWS,
    SHOW_ADDITIONAL_COL_FLAG,
    FOCUS_ENABLED_FLAG,
    SHOW_HEADER_UI_FLAG,
    RECORD_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    l_gantt_config_id,
    X_GANTT_VIEW_ID,
    X_GANTT_CONFIG_USAGE,
    X_FILTER_CODE,
    X_TIME_SCALE_CODE,
    X_EXPAND_COLLAPSE_FLAG,
    X_NUMBER_OF_DISPLAYED_ROWS,
    X_SHOW_ADDITIONAL_COL_FLAG,
    X_FOCUS_ENABLED_FLAG,
    X_SHOW_HEADER_UI_FLAG,
    1,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PA_GANTT_CONFIG_TL (
    GANTT_CONFIG_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    l_gantt_config_id,
    X_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PA_GANTT_CONFIG_TL T
    where T.GANTT_CONFIG_ID = l_gantt_config_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c(l_gantt_config_id);
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_GANTT_CONFIG_ID           in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_GANTT_CONFIG_USAGE        in VARCHAR2,
  X_FILTER_CODE               in VARCHAR2,
  X_TIME_SCALE_CODE           in VARCHAR2,
  X_EXPAND_COLLAPSE_FLAG      in VARCHAR2,
  X_NUMBER_OF_DISPLAYED_ROWS  in NUMBER,
  X_SHOW_ADDITIONAL_COL_FLAG  in VARCHAR2,
  X_FOCUS_ENABLED_FLAG        in VARCHAR2,
  X_SHOW_HEADER_UI_FLAG       in VARCHAR2,
  X_RECORD_VERSION_NUMBER     in NUMBER,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2
) is
  cursor c is select
      GANTT_VIEW_ID,
      GANTT_CONFIG_USAGE,
      FILTER_CODE,
      TIME_SCALE_CODE,
      EXPAND_COLLAPSE_FLAG,
      NUMBER_OF_DISPLAYED_ROWS,
      SHOW_ADDITIONAL_COL_FLAG,
      FOCUS_ENABLED_FLAG,
      SHOW_HEADER_UI_FLAG,
      RECORD_VERSION_NUMBER,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
    from PA_GANTT_CONFIG_B
    where GANTT_CONFIG_ID = X_GANTT_CONFIG_ID
    for update of GANTT_CONFIG_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PA_GANTT_CONFIG_TL
    where GANTT_CONFIG_ID = X_GANTT_CONFIG_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GANTT_CONFIG_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.GANTT_VIEW_ID = X_GANTT_VIEW_ID)
      AND (recinfo.GANTT_CONFIG_USAGE = X_GANTT_CONFIG_USAGE)
      AND (recinfo.FILTER_CODE = X_FILTER_CODE)
      AND (recinfo.TIME_SCALE_CODE = X_TIME_SCALE_CODE)
      AND (recinfo.EXPAND_COLLAPSE_FLAG = X_EXPAND_COLLAPSE_FLAG)
      AND (recinfo.NUMBER_OF_DISPLAYED_ROWS = X_NUMBER_OF_DISPLAYED_ROWS)
      AND (recinfo.SHOW_ADDITIONAL_COL_FLAG = X_SHOW_ADDITIONAL_COL_FLAG)
      AND (recinfo.FOCUS_ENABLED_FLAG = X_FOCUS_ENABLED_FLAG)
      AND (recinfo.SHOW_HEADER_UI_FLAG = X_SHOW_HEADER_UI_FLAG)
      AND ((recinfo.RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER)
           OR ((recinfo.RECORD_VERSION_NUMBER is null) AND (X_RECORD_VERSION_NUMBER is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_GANTT_CONFIG_ID           in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_GANTT_CONFIG_USAGE        in VARCHAR2,
  X_FILTER_CODE               in VARCHAR2,
  X_TIME_SCALE_CODE           in VARCHAR2,
  X_EXPAND_COLLAPSE_FLAG      in VARCHAR2,
  X_NUMBER_OF_DISPLAYED_ROWS  in NUMBER,
  X_SHOW_ADDITIONAL_COL_FLAG  in VARCHAR2,
  X_FOCUS_ENABLED_FLAG        in VARCHAR2,
  X_SHOW_HEADER_UI_FLAG       in VARCHAR2,
  X_RECORD_VERSION_NUMBER     in NUMBER,
  X_ATTRIBUTE_CATEGORY        in VARCHAR2,
  X_ATTRIBUTE1                in VARCHAR2,
  X_ATTRIBUTE2                in VARCHAR2,
  X_ATTRIBUTE3                in VARCHAR2,
  X_ATTRIBUTE4                in VARCHAR2,
  X_ATTRIBUTE5                in VARCHAR2,
  X_ATTRIBUTE6                in VARCHAR2,
  X_ATTRIBUTE7                in VARCHAR2,
  X_ATTRIBUTE8                in VARCHAR2,
  X_ATTRIBUTE9                in VARCHAR2,
  X_ATTRIBUTE10               in VARCHAR2,
  X_ATTRIBUTE11               in VARCHAR2,
  X_ATTRIBUTE12               in VARCHAR2,
  X_ATTRIBUTE13               in VARCHAR2,
  X_ATTRIBUTE14               in VARCHAR2,
  X_ATTRIBUTE15               in VARCHAR2,
  X_NAME                      in VARCHAR2,
  X_DESCRIPTION               in VARCHAR2,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
) is
begin
  update PA_GANTT_CONFIG_B set
    GANTT_VIEW_ID             = X_GANTT_VIEW_ID,
    GANTT_CONFIG_USAGE        = X_GANTT_CONFIG_USAGE,
    FILTER_CODE               = X_FILTER_CODE,
    TIME_SCALE_CODE           = X_TIME_SCALE_CODE,
    EXPAND_COLLAPSE_FLAG      = X_EXPAND_COLLAPSE_FLAG,
    NUMBER_OF_DISPLAYED_ROWS  = X_NUMBER_OF_DISPLAYED_ROWS,
    SHOW_ADDITIONAL_COL_FLAG  = X_SHOW_ADDITIONAL_COL_FLAG,
    FOCUS_ENABLED_FLAG        = X_FOCUS_ENABLED_FLAG,
    SHOW_HEADER_UI_FLAG       = X_SHOW_HEADER_UI_FLAG,
    RECORD_VERSION_NUMBER     = nvl(X_RECORD_VERSION_NUMBER,0)+1,
    ATTRIBUTE_CATEGORY        = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1                = X_ATTRIBUTE1,
    ATTRIBUTE2                = X_ATTRIBUTE2,
    ATTRIBUTE3                = X_ATTRIBUTE3,
    ATTRIBUTE4                = X_ATTRIBUTE4,
    ATTRIBUTE5                = X_ATTRIBUTE5,
    ATTRIBUTE6                = X_ATTRIBUTE6,
    ATTRIBUTE7                = X_ATTRIBUTE7,
    ATTRIBUTE8                = X_ATTRIBUTE8,
    ATTRIBUTE9                = X_ATTRIBUTE9,
    ATTRIBUTE10               = X_ATTRIBUTE10,
    ATTRIBUTE11               = X_ATTRIBUTE11,
    ATTRIBUTE12               = X_ATTRIBUTE12,
    ATTRIBUTE13               = X_ATTRIBUTE13,
    ATTRIBUTE14               = X_ATTRIBUTE14,
    ATTRIBUTE15               = X_ATTRIBUTE15,
    LAST_UPDATE_DATE          = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY           = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN         = X_LAST_UPDATE_LOGIN
  where GANTT_CONFIG_ID       = X_GANTT_CONFIG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PA_GANTT_CONFIG_TL set
    NAME                 = X_NAME,
    DESCRIPTION          = X_DESCRIPTION,
    LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG          = userenv('LANG')
  where GANTT_CONFIG_ID  = X_GANTT_CONFIG_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GANTT_CONFIG_ID           in NUMBER
)
is
begin
  delete from PA_GANTT_CONFIG_TL
  where GANTT_CONFIG_ID = X_GANTT_CONFIG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PA_GANTT_CONFIG_B
  where GANTT_CONFIG_ID = X_GANTT_CONFIG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from PA_GANTT_CONFIG_TL T
  where not exists
    (select NULL
    from PA_GANTT_CONFIG_B B
    where B.GANTT_CONFIG_ID = T.GANTT_CONFIG_ID
    );

  update PA_GANTT_CONFIG_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from PA_GANTT_CONFIG_TL B
    where B.GANTT_CONFIG_ID = T.GANTT_CONFIG_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GANTT_CONFIG_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GANTT_CONFIG_ID,
      SUBT.LANGUAGE
    from PA_GANTT_CONFIG_TL SUBB, PA_GANTT_CONFIG_TL SUBT
    where SUBB.GANTT_CONFIG_ID = SUBT.GANTT_CONFIG_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PA_GANTT_CONFIG_TL (
    GANTT_CONFIG_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GANTT_CONFIG_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_GANTT_CONFIG_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_GANTT_CONFIG_TL T
    where T.GANTT_CONFIG_ID = B.GANTT_CONFIG_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
         X_GANTT_CONFIG_ID    in        NUMBER
        ,X_OWNER              in        VARCHAR2
        ,X_NAME               in        VARCHAR2
        ,X_DESCRIPTION        in        VARCHAR2
)
IS
       l_user_id      NUMBER;
BEGIN
       if (X_OWNER = 'SEED') then
          l_user_id   := 1;
       else
          l_user_id   := 0;
       end if;

        update PA_GANTT_CONFIG_TL
          set
           LAST_UPDATE_DATE      = SYSDATE,
           LAST_UPDATED_BY       = l_user_id,
           LAST_UPDATE_LOGIN     = 0,
           name                  = X_NAME,
           description           = X_DESCRIPTION,
           source_lang           = userenv('LANG')
       	where  GANTT_CONFIG_ID = X_GANTT_CONFIG_ID
             and USERENV('LANG') IN ( LANGUAGE , SOURCE_LANG );

       if (sql%notfound) then
         raise no_data_found;
       end if;
END TRANSLATE_ROW;

procedure LOAD_ROW(
      X_GANTT_CONFIG_ID	         in NUMBER
     ,X_GANTT_VIEW_ID             in NUMBER
     ,X_GANTT_CONFIG_USAGE        in VARCHAR2
     ,X_FILTER_CODE		         in VARCHAR2
     ,X_TIME_SCALE_CODE           in VARCHAR2
     ,X_EXPAND_COLLAPSE_FLAG      in VARCHAR2
     ,X_NUMBER_OF_DISPLAYED_ROWS  in NUMBER
     ,X_SHOW_ADDITIONAL_COL_FLAG  in VARCHAR2
     ,X_FOCUS_ENABLED_FLAG        in VARCHAR2
     ,X_SHOW_HEADER_UI_FLAG       in VARCHAR2
     ,X_RECORD_VERSION_NUMBER     in NUMBER
     ,X_ATTRIBUTE_CATEGORY        in VARCHAR2
     ,X_ATTRIBUTE1                in VARCHAR2
     ,X_ATTRIBUTE2                in VARCHAR2
     ,X_ATTRIBUTE3                in VARCHAR2
     ,X_ATTRIBUTE4                in VARCHAR2
     ,X_ATTRIBUTE5                in VARCHAR2
     ,X_ATTRIBUTE6                in VARCHAR2
     ,X_ATTRIBUTE7                in VARCHAR2
     ,X_ATTRIBUTE8                in VARCHAR2
     ,X_ATTRIBUTE9                in VARCHAR2
     ,X_ATTRIBUTE10               in VARCHAR2
     ,X_ATTRIBUTE11               in VARCHAR2
     ,X_ATTRIBUTE12               in VARCHAR2
     ,X_ATTRIBUTE13               in VARCHAR2
     ,X_ATTRIBUTE14               in VARCHAR2
     ,X_ATTRIBUTE15               in VARCHAR2
     ,X_OWNER                     in VARCHAR2
     ,X_NAME                      in VARCHAR2
     ,X_DESCRIPTION               in VARCHAR2
)
IS
     l_user_id NUMBER;
     l_rowid   ROWID;
BEGIN
     if (X_OWNER = 'SEED')then
          l_user_id := 1;
     else
          l_user_id :=0;
     end if;

     PA_GANTT_CONFIG_PKG.UPDATE_ROW (
          X_GANTT_CONFIG_ID             => X_GANTT_CONFIG_ID
         ,X_GANTT_VIEW_ID               => X_GANTT_VIEW_ID
         ,X_GANTT_CONFIG_USAGE          => X_GANTT_CONFIG_USAGE
         ,X_FILTER_CODE                 => X_FILTER_CODE
         ,X_TIME_SCALE_CODE             => X_TIME_SCALE_CODE
         ,X_EXPAND_COLLAPSE_FLAG        => X_EXPAND_COLLAPSE_FLAG
         ,X_NUMBER_OF_DISPLAYED_ROWS    => X_NUMBER_OF_DISPLAYED_ROWS
         ,X_SHOW_ADDITIONAL_COL_FLAG    => X_SHOW_ADDITIONAL_COL_FLAG
         ,X_FOCUS_ENABLED_FLAG          => X_FOCUS_ENABLED_FLAG
         ,X_SHOW_HEADER_UI_FLAG         => X_SHOW_HEADER_UI_FLAG
         ,X_RECORD_VERSION_NUMBER       => X_RECORD_VERSION_NUMBER
         ,X_ATTRIBUTE_CATEGORY          => X_ATTRIBUTE_CATEGORY
         ,X_ATTRIBUTE1                  => X_ATTRIBUTE1
         ,X_ATTRIBUTE2                  => X_ATTRIBUTE2
         ,X_ATTRIBUTE3                  => X_ATTRIBUTE3
         ,X_ATTRIBUTE4                  => X_ATTRIBUTE4
         ,X_ATTRIBUTE5                  => X_ATTRIBUTE5
         ,X_ATTRIBUTE6                  => X_ATTRIBUTE6
         ,X_ATTRIBUTE7                  => X_ATTRIBUTE7
         ,X_ATTRIBUTE8                  => X_ATTRIBUTE8
         ,X_ATTRIBUTE9                  => X_ATTRIBUTE9
         ,X_ATTRIBUTE10                 => X_ATTRIBUTE10
         ,X_ATTRIBUTE11                 => X_ATTRIBUTE11
         ,X_ATTRIBUTE12                 => X_ATTRIBUTE12
         ,X_ATTRIBUTE13                 => X_ATTRIBUTE13
         ,X_ATTRIBUTE14                 => X_ATTRIBUTE14
         ,X_ATTRIBUTE15                 => X_ATTRIBUTE15
         ,X_NAME                        => X_NAME
         ,X_DESCRIPTION                 => X_DESCRIPTION
         ,X_LAST_UPDATE_DATE            => sysdate
         ,X_LAST_UPDATED_BY             => l_user_id
         ,X_LAST_UPDATE_LOGIN           => 0
     );
EXCEPTION
     WHEN no_data_found then
          PA_GANTT_CONFIG_PKG.INSERT_ROW(
                X_ROWID                      => l_rowid
               ,X_GANTT_CONFIG_ID            => X_GANTT_CONFIG_ID
               ,X_GANTT_VIEW_ID              => X_GANTT_VIEW_ID
               ,X_GANTT_CONFIG_USAGE         => X_GANTT_CONFIG_USAGE
               ,X_FILTER_CODE                => X_FILTER_CODE
               ,X_TIME_SCALE_CODE            => X_TIME_SCALE_CODE
               ,X_EXPAND_COLLAPSE_FLAG       => X_EXPAND_COLLAPSE_FLAG
               ,X_NUMBER_OF_DISPLAYED_ROWS   => X_NUMBER_OF_DISPLAYED_ROWS
               ,X_SHOW_ADDITIONAL_COL_FLAG   => X_SHOW_ADDITIONAL_COL_FLAG
               ,X_FOCUS_ENABLED_FLAG         => X_FOCUS_ENABLED_FLAG
               ,X_SHOW_HEADER_UI_FLAG        => X_SHOW_HEADER_UI_FLAG
               ,X_RECORD_VERSION_NUMBER      => X_RECORD_VERSION_NUMBER
               ,X_ATTRIBUTE_CATEGORY         => X_ATTRIBUTE_CATEGORY
               ,X_ATTRIBUTE1                 => X_ATTRIBUTE1
               ,X_ATTRIBUTE2                 => X_ATTRIBUTE2
               ,X_ATTRIBUTE3                 => X_ATTRIBUTE3
               ,X_ATTRIBUTE4                 => X_ATTRIBUTE4
               ,X_ATTRIBUTE5                 => X_ATTRIBUTE5
               ,X_ATTRIBUTE6                 => X_ATTRIBUTE6
               ,X_ATTRIBUTE7                 => X_ATTRIBUTE7
               ,X_ATTRIBUTE8                 => X_ATTRIBUTE8
               ,X_ATTRIBUTE9                 => X_ATTRIBUTE9
               ,X_ATTRIBUTE10                => X_ATTRIBUTE10
               ,X_ATTRIBUTE11                => X_ATTRIBUTE11
               ,X_ATTRIBUTE12                => X_ATTRIBUTE12
               ,X_ATTRIBUTE13                => X_ATTRIBUTE13
               ,X_ATTRIBUTE14                => X_ATTRIBUTE14
               ,X_ATTRIBUTE15                => X_ATTRIBUTE15
               ,X_NAME                       => X_NAME
               ,X_DESCRIPTION                => X_DESCRIPTION
               ,X_CREATION_DATE              => sysdate
               ,X_CREATED_BY                 => l_user_id
               ,X_LAST_UPDATE_DATE           => sysdate
               ,X_LAST_UPDATED_BY            => l_user_id
               ,X_LAST_UPDATE_LOGIN          => 0
          );
END LOAD_ROW;

end PA_GANTT_CONFIG_PKG;

/
