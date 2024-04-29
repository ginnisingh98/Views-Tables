--------------------------------------------------------
--  DDL for Package Body AML_BUSINESS_EVENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_BUSINESS_EVENT_TYPES_PKG" AS
/* $Header: amltbetb.pls 115.4 2003/11/13 23:47:02 solin ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_BUSINESS_EVENT_TYPE_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AML_BUSINESS_EVENT_TYPES_B
    where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID
    ;
begin
  insert into AML_BUSINESS_EVENT_TYPES_B (
    BUSINESS_EVENT_TYPE_ID,
    ACTION_ID,
    ACTION_ITEM_ID,
    ENABLED_FLAG,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_BUSINESS_EVENT_TYPE_ID,
    X_ACTION_ID,
    X_ACTION_ITEM_ID,
    X_ENABLED_FLAG,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AML_BUSINESS_EVENT_TYPES_TL (
    BUSINESS_EVENT_TYPE_ID,
    MEANING,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_BUSINESS_EVENT_TYPE_ID,
    X_MEANING,
    X_DESCRIPTION,
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
    from AML_BUSINESS_EVENT_TYPES_TL T
    where T.BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID
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
  X_BUSINESS_EVENT_TYPE_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ACTION_ID,
      ACTION_ITEM_ID,
      ENABLED_FLAG,
      OBJECT_VERSION_NUMBER
    from AML_BUSINESS_EVENT_TYPES_B
    where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID
    for update of BUSINESS_EVENT_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      MEANING,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AML_BUSINESS_EVENT_TYPES_TL
    where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of BUSINESS_EVENT_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ACTION_ID = X_ACTION_ID)
      AND (recinfo.ACTION_ITEM_ID = X_ACTION_ITEM_ID)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.MEANING = X_MEANING)
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
  X_BUSINESS_EVENT_TYPE_ID in NUMBER,
  X_ACTION_ID in NUMBER,
  X_ACTION_ITEM_ID in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MEANING in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AML_BUSINESS_EVENT_TYPES_B set
    ACTION_ID = X_ACTION_ID,
    ACTION_ITEM_ID = X_ACTION_ITEM_ID,
    ENABLED_FLAG = X_ENABLED_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AML_BUSINESS_EVENT_TYPES_TL set
    MEANING = X_MEANING,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_BUSINESS_EVENT_TYPE_ID in NUMBER
) is
begin
  delete from AML_BUSINESS_EVENT_TYPES_TL
  where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AML_BUSINESS_EVENT_TYPES_B
  where BUSINESS_EVENT_TYPE_ID = X_BUSINESS_EVENT_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AML_BUSINESS_EVENT_TYPES_TL T
  where not exists
    (select NULL
    from AML_BUSINESS_EVENT_TYPES_B B
    where B.BUSINESS_EVENT_TYPE_ID = T.BUSINESS_EVENT_TYPE_ID
    );

  update AML_BUSINESS_EVENT_TYPES_TL T set (
      MEANING,
      DESCRIPTION
    ) = (select
      B.MEANING,
      B.DESCRIPTION
    from AML_BUSINESS_EVENT_TYPES_TL B
    where B.BUSINESS_EVENT_TYPE_ID = T.BUSINESS_EVENT_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.BUSINESS_EVENT_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.BUSINESS_EVENT_TYPE_ID,
      SUBT.LANGUAGE
    from AML_BUSINESS_EVENT_TYPES_TL SUBB, AML_BUSINESS_EVENT_TYPES_TL SUBT
    where SUBB.BUSINESS_EVENT_TYPE_ID = SUBT.BUSINESS_EVENT_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AML_BUSINESS_EVENT_TYPES_TL (
    BUSINESS_EVENT_TYPE_ID,
    MEANING,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.BUSINESS_EVENT_TYPE_ID,
    B.MEANING,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AML_BUSINESS_EVENT_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AML_BUSINESS_EVENT_TYPES_TL T
    where T.BUSINESS_EVENT_TYPE_ID = B.BUSINESS_EVENT_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
  px_BUSINESS_EVENT_TYPE_ID IN OUT NOCOPY NUMBER,
  p_ACTION_ID               IN NUMBER,
  p_ACTION_ITEM_ID          IN NUMBER,
  p_ENABLED_FLAG            IN VARCHAR2,
  p_MEANING                 IN VARCHAR2,
  p_DESCRIPTION             IN VARCHAR2,
  p_OWNER                   IN VARCHAR2)
IS
    l_user_id               NUMBER := 0;
    l_row_id                VARCHAR2(100);

    CURSOR c_get_last_updated (c_BUSINESS_EVENT_TYPE_ID NUMBER) IS
        SELECT last_updated_by, OBJECT_VERSION_NUMBER
        FROM AML_BUSINESS_EVENT_TYPES_B
        WHERE BUSINESS_EVENT_TYPE_ID = c_BUSINESS_EVENT_TYPE_ID;
    l_last_updated_by       NUMBER;
    l_object_version_number NUMBER;

BEGIN
    OPEN c_get_last_updated (px_BUSINESS_EVENT_TYPE_ID);
    FETCH c_get_last_updated INTO l_last_updated_by, l_object_version_number;
    CLOSE c_get_last_updated;

    IF nvl(l_last_updated_by, 1) = 1
    THEN
        if (p_OWNER = 'SEED') then
            l_user_id := 1;
        end if;

        Update_Row(x_BUSINESS_EVENT_TYPE_ID => px_BUSINESS_EVENT_TYPE_ID,
                   x_ACTION_ID              => p_ACTION_ID,
                   x_ACTION_ITEM_ID         => p_ACTION_ITEM_ID,
                   x_ENABLED_FLAG           => p_ENABLED_FLAG,
                   x_OBJECT_VERSION_NUMBER  => l_object_version_number,
                   x_MEANING                => p_MEANING,
                   x_DESCRIPTION            => p_DESCRIPTION,
                   x_LAST_UPDATE_DATE       => sysdate,
                   x_LAST_UPDATED_BY        => l_user_id,
                   x_LAST_UPDATE_LOGIN      => 0
                   );
    END IF;

    EXCEPTION
        when no_data_found then

            Insert_Row(x_ROWID                   => l_row_id,
                       x_BUSINESS_EVENT_TYPE_ID  => px_BUSINESS_EVENT_TYPE_ID,
                       x_ACTION_ID               => p_ACTION_ID,
                       x_ACTION_ITEM_ID          => p_ACTION_ITEM_ID,
                       x_ENABLED_FLAG            => p_ENABLED_FLAG,
                       x_OBJECT_VERSION_NUMBER   => 1,
                       x_MEANING                 => p_MEANING,
                       x_DESCRIPTION             => p_DESCRIPTION,
                       x_CREATION_DATE           => sysdate,
                       x_CREATED_BY              => 0,
                       x_LAST_UPDATE_DATE        => sysdate,
                       x_LAST_UPDATED_BY         => l_user_id,
                       x_LAST_UPDATE_LOGIN       => 0
                       );
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  p_BUSINESS_EVENT_TYPE_ID  IN NUMBER,
  p_MEANING                 IN VARCHAR2,
  p_DESCRIPTION             IN VARCHAR2,
  p_OWNER                   IN VARCHAR2
) IS
BEGIN
    -- only UPDATE rows that have not been altered by user
    UPDATE AML_BUSINESS_EVENT_TYPES_TL
    SET
        MEANING = NVL(p_MEANING, MEANING),
        DESCRIPTION = NVL(p_DESCRIPTION, DESCRIPTION),
        SOURCE_LANG = userenv('LANG'),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = decode(p_owner, 'SEED', 1, 0),
        LAST_UPDATE_LOGIN = 0
    WHERE BUSINESS_EVENT_TYPE_ID = p_BUSINESS_EVENT_TYPE_ID
    AND   userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;
end AML_BUSINESS_EVENT_TYPES_PKG;

/
