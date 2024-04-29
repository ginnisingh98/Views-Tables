--------------------------------------------------------
--  DDL for Package Body PA_GANTT_BAR_STYLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GANTT_BAR_STYLES_PKG" as
/* $Header: PAGCBSTB.pls 120.1 2005/08/19 16:32:37 mwasowic noship $ */

procedure INSERT_ROW (
  X_ROWID                     in out NOCOPY ROWID, --File.Sql.39 bug 4440895
  X_GANTT_BAR_STYLE_ID        in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_DISPLAY_SEQUENCE          in NUMBER,
  X_START_FROM                in VARCHAR2,
  X_END_TO                    in VARCHAR2,
  X_ROW_INDEX                 in NUMBER,
  X_GANTT_BAR_START_SHAPE     in VARCHAR2,
  X_GANTT_BAR_START_COLOR     in NUMBER,
  X_GANTT_BAR_MIDDLE_SHAPE    in VARCHAR2,
  X_GANTT_BAR_MIDDLE_PATTERN  in VARCHAR2,
  X_GANTT_BAR_MIDDLE_COLOR    in NUMBER,
  X_GANTT_BAR_END_SHAPE       in VARCHAR2,
  X_GANTT_BAR_END_COLOR       in NUMBER,
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
  X_CREATION_DATE             in DATE,
  X_CREATED_BY                in NUMBER,
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
  )
  is

cursor C(c_bar_style_id pa_gantt_bar_styles_b.gantt_bar_style_id%TYPE) is
select ROWID
from   PA_GANTT_BAR_STYLES_B
where  GANTT_BAR_STYLE_ID = c_bar_style_id;

l_gantt_bar_style_id   PA_GANTT_BAR_STYLES_B.GANTT_BAR_STYLE_ID%TYPE;
begin

  select nvl(X_GANTT_BAR_STYLE_ID,PA_GANTT_BAR_STYLES_B_S.nextval)
  into   l_gantt_bar_style_id
  from   dual;

  insert into PA_GANTT_BAR_STYLES_B (
    GANTT_BAR_STYLE_ID,
    GANTT_VIEW_ID,
    DISPLAY_SEQUENCE,
    START_FROM,
    END_TO,
    ROW_INDEX,
    GANTT_BAR_START_SHAPE,
    GANTT_BAR_START_COLOR,
    GANTT_BAR_MIDDLE_SHAPE,
    GANTT_BAR_MIDDLE_PATTERN,
    GANTT_BAR_MIDDLE_COLOR,
    GANTT_BAR_END_SHAPE,
    GANTT_BAR_END_COLOR,
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
  ) values
  (
    l_gantt_bar_style_id,
    X_GANTT_VIEW_ID,
    X_DISPLAY_SEQUENCE,
    X_START_FROM,
    X_END_TO,
    X_ROW_INDEX,
    X_GANTT_BAR_START_SHAPE,
    X_GANTT_BAR_START_COLOR,
    X_GANTT_BAR_MIDDLE_SHAPE,
    X_GANTT_BAR_MIDDLE_PATTERN,
    X_GANTT_BAR_MIDDLE_COLOR,
    X_GANTT_BAR_END_SHAPE,
    X_GANTT_BAR_END_COLOR,
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

  insert into PA_GANTT_BAR_STYLES_TL (
    GANTT_BAR_STYLE_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    l_gantt_bar_style_id,
    X_NAME,
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
    from PA_GANTT_BAR_STYLES_TL T
    where T.GANTT_BAR_STYLE_ID = l_gantt_bar_style_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c(l_gantt_bar_style_id);
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_GANTT_BAR_STYLE_ID        in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_DISPLAY_SEQUENCE          in NUMBER,
  X_START_FROM                in VARCHAR2,
  X_END_TO                    in VARCHAR2,
  X_ROW_INDEX                 in NUMBER,
  X_GANTT_BAR_START_SHAPE     in VARCHAR2,
  X_GANTT_BAR_START_COLOR     in NUMBER,
  X_GANTT_BAR_MIDDLE_SHAPE    in VARCHAR2,
  X_GANTT_BAR_MIDDLE_PATTERN  in VARCHAR2,
  X_GANTT_BAR_MIDDLE_COLOR    in NUMBER,
  X_GANTT_BAR_END_SHAPE       in VARCHAR2,
  X_GANTT_BAR_END_COLOR       in NUMBER,
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
  X_NAME                      in VARCHAR2
)
is
  cursor c is select
      GANTT_VIEW_ID,
      DISPLAY_SEQUENCE,
      START_FROM,
      END_TO,
      ROW_INDEX,
      GANTT_BAR_START_SHAPE,
      GANTT_BAR_START_COLOR,
      GANTT_BAR_MIDDLE_SHAPE,
      GANTT_BAR_MIDDLE_PATTERN,
      GANTT_BAR_MIDDLE_COLOR,
      GANTT_BAR_END_SHAPE,
      GANTT_BAR_END_COLOR,
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
    from PA_GANTT_BAR_STYLES_B
    where GANTT_BAR_STYLE_ID = X_GANTT_BAR_STYLE_ID
    for update of GANTT_BAR_STYLE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from  PA_GANTT_BAR_STYLES_TL
    where GANTT_BAR_STYLE_ID = X_GANTT_BAR_STYLE_ID
    and   userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GANTT_BAR_STYLE_ID nowait;
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
      AND (recinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
      AND (recinfo.START_FROM = X_START_FROM)
      AND (recinfo.END_TO = X_END_TO)
      AND (recinfo.ROW_INDEX = X_ROW_INDEX)
      AND ((recinfo.GANTT_BAR_START_SHAPE = X_GANTT_BAR_START_SHAPE)
           OR ((recinfo.GANTT_BAR_START_SHAPE is null) AND (X_GANTT_BAR_START_SHAPE is null)))
      AND ((recinfo.GANTT_BAR_START_COLOR = X_GANTT_BAR_START_COLOR)
           OR ((recinfo.GANTT_BAR_START_COLOR is null) AND (X_GANTT_BAR_START_COLOR is null)))
      AND ((recinfo.GANTT_BAR_MIDDLE_SHAPE = X_GANTT_BAR_MIDDLE_SHAPE)
           OR ((recinfo.GANTT_BAR_MIDDLE_SHAPE is null) AND (X_GANTT_BAR_MIDDLE_SHAPE is null)))
      AND ((recinfo.GANTT_BAR_MIDDLE_PATTERN = X_GANTT_BAR_MIDDLE_PATTERN)
           OR ((recinfo.GANTT_BAR_MIDDLE_PATTERN is null) AND (X_GANTT_BAR_MIDDLE_PATTERN is null)))
      AND ((recinfo.GANTT_BAR_MIDDLE_COLOR = X_GANTT_BAR_MIDDLE_COLOR)
           OR ((recinfo.GANTT_BAR_MIDDLE_COLOR is null) AND (X_GANTT_BAR_MIDDLE_COLOR is null)))
      AND ((recinfo.GANTT_BAR_END_SHAPE = X_GANTT_BAR_END_SHAPE)
           OR ((recinfo.GANTT_BAR_END_SHAPE is null) AND (X_GANTT_BAR_END_SHAPE is null)))
      AND ((recinfo.GANTT_BAR_END_COLOR = X_GANTT_BAR_END_COLOR)
           OR ((recinfo.GANTT_BAR_END_COLOR is null) AND (X_GANTT_BAR_END_COLOR is null)))
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
      if ((tlinfo.NAME = X_NAME)) then
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
  X_GANTT_BAR_STYLE_ID        in NUMBER,
  X_GANTT_VIEW_ID             in NUMBER,
  X_DISPLAY_SEQUENCE          in NUMBER,
  X_START_FROM                in VARCHAR2,
  X_END_TO                    in VARCHAR2,
  X_ROW_INDEX                 in NUMBER,
  X_GANTT_BAR_START_SHAPE     in VARCHAR2,
  X_GANTT_BAR_START_COLOR     in NUMBER,
  X_GANTT_BAR_MIDDLE_SHAPE    in VARCHAR2,
  X_GANTT_BAR_MIDDLE_PATTERN  in VARCHAR2,
  X_GANTT_BAR_MIDDLE_COLOR    in NUMBER,
  X_GANTT_BAR_END_SHAPE       in VARCHAR2,
  X_GANTT_BAR_END_COLOR       in NUMBER,
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
  X_LAST_UPDATE_DATE          in DATE,
  X_LAST_UPDATED_BY           in NUMBER,
  X_LAST_UPDATE_LOGIN         in NUMBER
)
is
begin
  update PA_GANTT_BAR_STYLES_B set
    GANTT_VIEW_ID             = X_GANTT_VIEW_ID,
    DISPLAY_SEQUENCE          = X_DISPLAY_SEQUENCE,
    START_FROM                = X_START_FROM,
    END_TO                    = X_END_TO,
    ROW_INDEX                 = X_ROW_INDEX,
    GANTT_BAR_START_SHAPE     = X_GANTT_BAR_START_SHAPE,
    GANTT_BAR_START_COLOR     = X_GANTT_BAR_START_COLOR,
    GANTT_BAR_MIDDLE_SHAPE    = X_GANTT_BAR_MIDDLE_SHAPE,
    GANTT_BAR_MIDDLE_PATTERN  = X_GANTT_BAR_MIDDLE_PATTERN,
    GANTT_BAR_MIDDLE_COLOR    = X_GANTT_BAR_MIDDLE_COLOR,
    GANTT_BAR_END_SHAPE       = X_GANTT_BAR_END_SHAPE,
    GANTT_BAR_END_COLOR       = X_GANTT_BAR_END_COLOR,
    RECORD_VERSION_NUMBER     = nvl(X_RECORD_VERSION_NUMBER,0) + 1,
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
  where GANTT_BAR_STYLE_ID    = X_GANTT_BAR_STYLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PA_GANTT_BAR_STYLES_TL set
    NAME                      = X_NAME,
    LAST_UPDATE_DATE          = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY           = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN         = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG               = userenv('LANG')
  where GANTT_BAR_STYLE_ID    = X_GANTT_BAR_STYLE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GANTT_BAR_STYLE_ID        in NUMBER
) is
begin
  delete from PA_GANTT_BAR_STYLES_TL
  where GANTT_BAR_STYLE_ID = X_GANTT_BAR_STYLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PA_GANTT_BAR_STYLES_B
  where GANTT_BAR_STYLE_ID = X_GANTT_BAR_STYLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PA_GANTT_BAR_STYLES_TL T
  where not exists
    (select NULL
    from PA_GANTT_BAR_STYLES_B B
    where B.GANTT_BAR_STYLE_ID = T.GANTT_BAR_STYLE_ID
    );

  update PA_GANTT_BAR_STYLES_TL T set (
      NAME
    ) = (select
      B.NAME
    from PA_GANTT_BAR_STYLES_TL B
    where B.GANTT_BAR_STYLE_ID = T.GANTT_BAR_STYLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GANTT_BAR_STYLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GANTT_BAR_STYLE_ID,
      SUBT.LANGUAGE
    from PA_GANTT_BAR_STYLES_TL SUBB, PA_GANTT_BAR_STYLES_TL SUBT
    where SUBB.GANTT_BAR_STYLE_ID = SUBT.GANTT_BAR_STYLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into PA_GANTT_BAR_STYLES_TL (
    GANTT_BAR_STYLE_ID,
    NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GANTT_BAR_STYLE_ID,
    B.NAME,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PA_GANTT_BAR_STYLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PA_GANTT_BAR_STYLES_TL T
    where T.GANTT_BAR_STYLE_ID = B.GANTT_BAR_STYLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
         X_GANTT_BAR_STYLE_ID       in    NUMBER
        ,X_OWNER                    in    VARCHAR2
        ,X_NAME                     in    VARCHAR2
)
IS
       l_user_id NUMBER;
BEGIN
       if (X_OWNER = 'SEED') then
          l_user_id   := 1;
       else
          l_user_id   := 0;
       end if;

        update PA_GANTT_BAR_STYLES_TL
          set
           LAST_UPDATE_DATE        = SYSDATE,
           LAST_UPDATED_BY         = l_user_id,
           LAST_UPDATE_LOGIN       = 0,
           name                    = X_NAME,
           source_lang             = userenv('LANG')
       	where  GANTT_BAR_STYLE_ID= X_GANTT_BAR_STYLE_ID
             and USERENV('LANG') IN ( LANGUAGE , SOURCE_LANG );

       if (sql%notfound) then
         raise no_data_found;
       end if;
END TRANSLATE_ROW;

procedure LOAD_ROW(
      X_GANTT_BAR_STYLE_ID         in     NUMBER
     ,X_GANTT_VIEW_ID              in     NUMBER
     ,X_DISPLAY_SEQUENCE           in     NUMBER
     ,X_START_FROM                 in     VARCHAR2
     ,X_END_TO                     in     VARCHAR2
     ,X_ROW_INDEX                  in     NUMBER
     ,X_GANTT_BAR_START_SHAPE      in     VARCHAR2
     ,X_GANTT_BAR_START_COLOR      in     NUMBER
     ,X_GANTT_BAR_MIDDLE_SHAPE     in     VARCHAR2
     ,X_GANTT_BAR_MIDDLE_PATTERN   in     VARCHAR2
     ,X_GANTT_BAR_MIDDLE_COLOR     in     NUMBER
     ,X_GANTT_BAR_END_SHAPE        in     VARCHAR2
     ,X_GANTT_BAR_END_COLOR        in     NUMBER
     ,X_RECORD_VERSION_NUMBER      in     NUMBER
     ,X_ATTRIBUTE_CATEGORY         in     VARCHAR2
     ,X_ATTRIBUTE1                 in     VARCHAR2
     ,X_ATTRIBUTE2                 in     VARCHAR2
     ,X_ATTRIBUTE3                 in     VARCHAR2
     ,X_ATTRIBUTE4                 in     VARCHAR2
     ,X_ATTRIBUTE5                 in     VARCHAR2
     ,X_ATTRIBUTE6                 in     VARCHAR2
     ,X_ATTRIBUTE7                 in     VARCHAR2
     ,X_ATTRIBUTE8                 in     VARCHAR2
     ,X_ATTRIBUTE9                 in     VARCHAR2
     ,X_ATTRIBUTE10                in     VARCHAR2
     ,X_ATTRIBUTE11                in     VARCHAR2
     ,X_ATTRIBUTE12                in     VARCHAR2
     ,X_ATTRIBUTE13                in     VARCHAR2
     ,X_ATTRIBUTE14                in     VARCHAR2
     ,X_ATTRIBUTE15                in     VARCHAR2
     ,X_OWNER                      in     VARCHAR2
     ,X_NAME                       in     VARCHAR2
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

     PA_GANTT_BAR_STYLES_PKG.UPDATE_ROW (
             X_GANTT_BAR_STYLE_ID        => X_GANTT_BAR_STYLE_ID
            ,X_GANTT_VIEW_ID             => X_GANTT_VIEW_ID
            ,X_DISPLAY_SEQUENCE          => X_DISPLAY_SEQUENCE
            ,X_START_FROM                => X_START_FROM
            ,X_END_TO                    => X_END_TO
            ,X_ROW_INDEX                 => X_ROW_INDEX
            ,X_GANTT_BAR_START_SHAPE     => X_GANTT_BAR_START_SHAPE
            ,X_GANTT_BAR_START_COLOR     => X_GANTT_BAR_START_COLOR
            ,X_GANTT_BAR_MIDDLE_SHAPE    => X_GANTT_BAR_MIDDLE_SHAPE
            ,X_GANTT_BAR_MIDDLE_PATTERN  => X_GANTT_BAR_MIDDLE_PATTERN
            ,X_GANTT_BAR_MIDDLE_COLOR    => X_GANTT_BAR_MIDDLE_COLOR
            ,X_GANTT_BAR_END_SHAPE       => X_GANTT_BAR_END_SHAPE
            ,X_GANTT_BAR_END_COLOR       => X_GANTT_BAR_END_COLOR
            ,X_RECORD_VERSION_NUMBER     => X_RECORD_VERSION_NUMBER
            ,X_ATTRIBUTE_CATEGORY        => X_ATTRIBUTE_CATEGORY
            ,X_ATTRIBUTE1                => X_ATTRIBUTE1
            ,X_ATTRIBUTE2                => X_ATTRIBUTE2
            ,X_ATTRIBUTE3                => X_ATTRIBUTE3
            ,X_ATTRIBUTE4                => X_ATTRIBUTE4
            ,X_ATTRIBUTE5                => X_ATTRIBUTE5
            ,X_ATTRIBUTE6                => X_ATTRIBUTE6
            ,X_ATTRIBUTE7                => X_ATTRIBUTE7
            ,X_ATTRIBUTE8                => X_ATTRIBUTE8
            ,X_ATTRIBUTE9                => X_ATTRIBUTE9
            ,X_ATTRIBUTE10               => X_ATTRIBUTE10
            ,X_ATTRIBUTE11               => X_ATTRIBUTE11
            ,X_ATTRIBUTE12               => X_ATTRIBUTE12
            ,X_ATTRIBUTE13               => X_ATTRIBUTE13
            ,X_ATTRIBUTE14               => X_ATTRIBUTE14
            ,X_ATTRIBUTE15               => X_ATTRIBUTE15
            ,X_NAME                      => X_NAME
            ,X_LAST_UPDATE_DATE          => sysdate
            ,X_LAST_UPDATED_BY           => l_user_id
            ,X_LAST_UPDATE_LOGIN         => 0
     );
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          PA_GANTT_BAR_STYLES_PKG.INSERT_ROW (
                  X_ROWID                     => l_rowid
                 ,X_GANTT_BAR_STYLE_ID        => X_GANTT_BAR_STYLE_ID
                 ,X_GANTT_VIEW_ID             => X_GANTT_VIEW_ID
                 ,X_DISPLAY_SEQUENCE          => X_DISPLAY_SEQUENCE
                 ,X_START_FROM                => X_START_FROM
                 ,X_END_TO                    => X_END_TO
                 ,X_ROW_INDEX                 => X_ROW_INDEX
                 ,X_GANTT_BAR_START_SHAPE     => X_GANTT_BAR_START_SHAPE
                 ,X_GANTT_BAR_START_COLOR     => X_GANTT_BAR_START_COLOR
                 ,X_GANTT_BAR_MIDDLE_SHAPE    => X_GANTT_BAR_MIDDLE_SHAPE
                 ,X_GANTT_BAR_MIDDLE_PATTERN  => X_GANTT_BAR_MIDDLE_PATTERN
                 ,X_GANTT_BAR_MIDDLE_COLOR    => X_GANTT_BAR_MIDDLE_COLOR
                 ,X_GANTT_BAR_END_SHAPE       => X_GANTT_BAR_END_SHAPE
                 ,X_GANTT_BAR_END_COLOR       => X_GANTT_BAR_END_COLOR
                 ,X_RECORD_VERSION_NUMBER     => X_RECORD_VERSION_NUMBER
                 ,X_ATTRIBUTE_CATEGORY        => X_ATTRIBUTE_CATEGORY
                 ,X_ATTRIBUTE1                => X_ATTRIBUTE1
                 ,X_ATTRIBUTE2                => X_ATTRIBUTE2
                 ,X_ATTRIBUTE3                => X_ATTRIBUTE3
                 ,X_ATTRIBUTE4                => X_ATTRIBUTE4
                 ,X_ATTRIBUTE5                => X_ATTRIBUTE5
                 ,X_ATTRIBUTE6                => X_ATTRIBUTE6
                 ,X_ATTRIBUTE7                => X_ATTRIBUTE7
                 ,X_ATTRIBUTE8                => X_ATTRIBUTE8
                 ,X_ATTRIBUTE9                => X_ATTRIBUTE9
                 ,X_ATTRIBUTE10               => X_ATTRIBUTE10
                 ,X_ATTRIBUTE11               => X_ATTRIBUTE11
                 ,X_ATTRIBUTE12               => X_ATTRIBUTE12
                 ,X_ATTRIBUTE13               => X_ATTRIBUTE13
                 ,X_ATTRIBUTE14               => X_ATTRIBUTE14
                 ,X_ATTRIBUTE15               => X_ATTRIBUTE15
                 ,X_NAME                      => X_NAME
                 ,X_CREATION_DATE             => sysdate
                 ,X_CREATED_BY                => l_user_id
                 ,X_LAST_UPDATE_DATE          => sysdate
                 ,X_LAST_UPDATED_BY           => l_user_id
                 ,X_LAST_UPDATE_LOGIN         => 0
          );
END LOAD_ROW;

end PA_GANTT_BAR_STYLES_PKG;

/
