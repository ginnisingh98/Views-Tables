--------------------------------------------------------
--  DDL for Package Body JTF_AM_SCREEN_SETUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AM_SCREEN_SETUPS_PKG" as
/* $Header: jtfamtsb.pls 115.3 2002/12/03 21:02:17 sroychou ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCREEN_SETUP_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_DOC_DETAILS in VARCHAR2,
  X_PREFERENCE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_AM_SCREEN_SETUPS_B
    where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID
    ;
begin
  insert into JTF_AM_SCREEN_SETUPS_B (
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    SECURITY_GROUP_ID,
    ATTRIBUTE11,
    MODE_ASSIST,
    MODE_UNASSIST,
    CONTRACTS,
    INSTALLED_BASE,
    TERRITORY,
    AVAILABILITY,
    DOCUMENT_TYPE,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    SCREEN_SETUP_ID,
    WINDOW_WIDTH,
    WINDOW_HEIGHT,
    WINDOW_X_POSITION,
    WINDOW_Y_POSITION,
    DOC_DTLS_USER_VALUES,
    SHOW_SELECTED_TIME,
    OBJECT_VERSION_NUMBER,
    USER_ID,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    DOC_DETAILS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_SECURITY_GROUP_ID,
    X_ATTRIBUTE11,
    X_MODE_ASSIST,
    X_MODE_UNASSIST,
    X_CONTRACTS,
    X_INSTALLED_BASE,
    X_TERRITORY,
    X_AVAILABILITY,
    X_DOCUMENT_TYPE,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_SCREEN_SETUP_ID,
    X_WINDOW_WIDTH,
    X_WINDOW_HEIGHT,
    X_WINDOW_X_POSITION,
    X_WINDOW_Y_POSITION,
    X_DOC_DTLS_USER_VALUES,
    X_SHOW_SELECTED_TIME,
    X_OBJECT_VERSION_NUMBER,
    X_USER_ID,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_DOC_DETAILS,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_AM_SCREEN_SETUPS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    SCREEN_SETUP_ID,
    PREFERENCE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_SECURITY_GROUP_ID,
    X_SCREEN_SETUP_ID,
    X_PREFERENCE_NAME,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_AM_SCREEN_SETUPS_TL T
    where T.SCREEN_SETUP_ID = X_SCREEN_SETUP_ID
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
  X_SCREEN_SETUP_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_DOC_DETAILS in VARCHAR2,
  X_PREFERENCE_NAME in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE15,
      ATTRIBUTE_CATEGORY,
      SECURITY_GROUP_ID,
      ATTRIBUTE11,
      MODE_ASSIST,
      MODE_UNASSIST,
      CONTRACTS,
      INSTALLED_BASE,
      TERRITORY,
      AVAILABILITY,
      DOCUMENT_TYPE,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      WINDOW_WIDTH,
      WINDOW_HEIGHT,
      WINDOW_X_POSITION,
      WINDOW_Y_POSITION,
      DOC_DTLS_USER_VALUES,
      SHOW_SELECTED_TIME,
      OBJECT_VERSION_NUMBER,
      USER_ID,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      DOC_DETAILS
    from JTF_AM_SCREEN_SETUPS_B
    where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID
    for update of SCREEN_SETUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PREFERENCE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_AM_SCREEN_SETUPS_TL
    where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SCREEN_SETUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.MODE_ASSIST = X_MODE_ASSIST)
           OR ((recinfo.MODE_ASSIST is null) AND (X_MODE_ASSIST is null)))
      AND ((recinfo.MODE_UNASSIST = X_MODE_UNASSIST)
           OR ((recinfo.MODE_UNASSIST is null) AND (X_MODE_UNASSIST is null)))
      AND ((recinfo.CONTRACTS = X_CONTRACTS)
           OR ((recinfo.CONTRACTS is null) AND (X_CONTRACTS is null)))
      AND ((recinfo.INSTALLED_BASE = X_INSTALLED_BASE)
           OR ((recinfo.INSTALLED_BASE is null) AND (X_INSTALLED_BASE is null)))
      AND ((recinfo.TERRITORY = X_TERRITORY)
           OR ((recinfo.TERRITORY is null) AND (X_TERRITORY is null)))
      AND ((recinfo.AVAILABILITY = X_AVAILABILITY)
           OR ((recinfo.AVAILABILITY is null) AND (X_AVAILABILITY is null)))
      AND ((recinfo.DOCUMENT_TYPE = X_DOCUMENT_TYPE)
           OR ((recinfo.DOCUMENT_TYPE is null) AND (X_DOCUMENT_TYPE is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.WINDOW_WIDTH = X_WINDOW_WIDTH)
           OR ((recinfo.WINDOW_WIDTH is null) AND (X_WINDOW_WIDTH is null)))
      AND ((recinfo.WINDOW_HEIGHT = X_WINDOW_HEIGHT)
           OR ((recinfo.WINDOW_HEIGHT is null) AND (X_WINDOW_HEIGHT is null)))
      AND ((recinfo.WINDOW_X_POSITION = X_WINDOW_X_POSITION)
           OR ((recinfo.WINDOW_X_POSITION is null) AND (X_WINDOW_X_POSITION is null)))
      AND ((recinfo.WINDOW_Y_POSITION = X_WINDOW_Y_POSITION)
           OR ((recinfo.WINDOW_Y_POSITION is null) AND (X_WINDOW_Y_POSITION is null)))
      AND ((recinfo.DOC_DTLS_USER_VALUES = X_DOC_DTLS_USER_VALUES)
           OR ((recinfo.DOC_DTLS_USER_VALUES is null) AND (X_DOC_DTLS_USER_VALUES is null)))
      AND ((recinfo.SHOW_SELECTED_TIME = X_SHOW_SELECTED_TIME)
           OR ((recinfo.SHOW_SELECTED_TIME is null) AND (X_SHOW_SELECTED_TIME is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.USER_ID = X_USER_ID)
           OR ((recinfo.USER_ID is null) AND (X_USER_ID is null)))
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
      AND ((recinfo.DOC_DETAILS = X_DOC_DETAILS)
           OR ((recinfo.DOC_DETAILS is null) AND (X_DOC_DETAILS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.PREFERENCE_NAME = X_PREFERENCE_NAME)
               OR ((tlinfo.PREFERENCE_NAME is null) AND (X_PREFERENCE_NAME is null)))
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
  X_SCREEN_SETUP_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_ATTRIBUTE11 in VARCHAR2,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_DOC_DETAILS in VARCHAR2,
  X_PREFERENCE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_AM_SCREEN_SETUPS_B set
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    MODE_ASSIST = X_MODE_ASSIST,
    MODE_UNASSIST = X_MODE_UNASSIST,
    CONTRACTS = X_CONTRACTS,
    INSTALLED_BASE = X_INSTALLED_BASE,
    TERRITORY = X_TERRITORY,
    AVAILABILITY = X_AVAILABILITY,
    DOCUMENT_TYPE = X_DOCUMENT_TYPE,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    WINDOW_WIDTH = X_WINDOW_WIDTH,
    WINDOW_HEIGHT = X_WINDOW_HEIGHT,
    WINDOW_X_POSITION = X_WINDOW_X_POSITION,
    WINDOW_Y_POSITION = X_WINDOW_Y_POSITION,
    DOC_DTLS_USER_VALUES = X_DOC_DTLS_USER_VALUES,
    SHOW_SELECTED_TIME = X_SHOW_SELECTED_TIME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    USER_ID = X_USER_ID,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    DOC_DETAILS = X_DOC_DETAILS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_AM_SCREEN_SETUPS_TL set
    PREFERENCE_NAME = X_PREFERENCE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SCREEN_SETUP_ID in NUMBER
) is
begin
  delete from JTF_AM_SCREEN_SETUPS_TL
  where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_AM_SCREEN_SETUPS_B
  where SCREEN_SETUP_ID = X_SCREEN_SETUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_AM_SCREEN_SETUPS_TL T
  where not exists
    (select NULL
    from JTF_AM_SCREEN_SETUPS_B B
    where B.SCREEN_SETUP_ID = T.SCREEN_SETUP_ID
    );

  update JTF_AM_SCREEN_SETUPS_TL T set (
      PREFERENCE_NAME
    ) = (select
      B.PREFERENCE_NAME
    from JTF_AM_SCREEN_SETUPS_TL B
    where B.SCREEN_SETUP_ID = T.SCREEN_SETUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SCREEN_SETUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SCREEN_SETUP_ID,
      SUBT.LANGUAGE
    from JTF_AM_SCREEN_SETUPS_TL SUBB, JTF_AM_SCREEN_SETUPS_TL SUBT
    where SUBB.SCREEN_SETUP_ID = SUBT.SCREEN_SETUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PREFERENCE_NAME <> SUBT.PREFERENCE_NAME
      or (SUBB.PREFERENCE_NAME is null and SUBT.PREFERENCE_NAME is not null)
      or (SUBB.PREFERENCE_NAME is not null and SUBT.PREFERENCE_NAME is null)
  ));

  insert into JTF_AM_SCREEN_SETUPS_TL (
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    SCREEN_SETUP_ID,
    PREFERENCE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.SCREEN_SETUP_ID,
    B.PREFERENCE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_AM_SCREEN_SETUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_AM_SCREEN_SETUPS_TL T
    where T.SCREEN_SETUP_ID = B.SCREEN_SETUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_OWNER           in VARCHAR2,
  X_SCREEN_SETUP_ID in NUMBER,
  X_MODE_ASSIST in VARCHAR2,
  X_MODE_UNASSIST in VARCHAR2,
  X_CONTRACTS in VARCHAR2,
  X_INSTALLED_BASE in VARCHAR2,
  X_TERRITORY in VARCHAR2,
  X_AVAILABILITY in VARCHAR2,
  X_DOCUMENT_TYPE in VARCHAR2,
  X_WINDOW_WIDTH in NUMBER,
  X_WINDOW_HEIGHT in NUMBER,
  X_WINDOW_X_POSITION in NUMBER,
  X_WINDOW_Y_POSITION in NUMBER,
  X_DOC_DTLS_USER_VALUES in VARCHAR2,
  X_SHOW_SELECTED_TIME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_USER_ID in NUMBER,
  X_DOC_DETAILS in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_PREFERENCE_NAME in VARCHAR2
) is
l_row_id rowid;
l_user_id number;
l_last_updated_by number := -1;
l_object_version_number number := 1;

CURSOR c_last_updated IS
  SELECT last_updated_by,
         object_version_number
    from JTF_AM_SCREEN_SETUPS_VL
   WHERE screen_setup_id = x_screen_setup_id;

begin
if (X_OWNER = 'SEED') then
	l_user_id := 1;
else
	l_user_id := 0;
end if;

OPEN c_last_updated;
FETCH c_last_updated into l_last_updated_by, l_object_version_number ;
      IF c_last_updated%NOTFOUND THEN
         l_object_version_number := 1;
	 jtf_am_screen_setups_pkg.insert_row(
                X_ROWID               => l_row_id ,
                X_SCREEN_SETUP_ID       => X_SCREEN_SETUP_ID,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
                X_ATTRIBUTE3            => X_ATTRIBUTE3 ,
                X_ATTRIBUTE4            => X_ATTRIBUTE4 ,
                X_ATTRIBUTE5            => X_ATTRIBUTE5 ,
                X_ATTRIBUTE6            => X_ATTRIBUTE6 ,
                X_ATTRIBUTE7            => X_ATTRIBUTE7 ,
                X_ATTRIBUTE8            => X_ATTRIBUTE8 ,
                X_ATTRIBUTE9            => X_ATTRIBUTE9 ,
                X_ATTRIBUTE10           => X_ATTRIBUTE10 ,
                X_ATTRIBUTE11           => X_ATTRIBUTE11 ,
                X_ATTRIBUTE12           => X_ATTRIBUTE12 ,
                X_ATTRIBUTE13           => X_ATTRIBUTE13 ,
                X_ATTRIBUTE14           => X_ATTRIBUTE14 ,
                X_ATTRIBUTE15           => X_ATTRIBUTE15 ,
                X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY ,
                X_SECURITY_GROUP_ID     => X_SECURITY_GROUP_ID,
                X_MODE_ASSIST           => X_MODE_ASSIST,
                X_MODE_UNASSIST         => X_MODE_UNASSIST,
                X_CONTRACTS             => X_CONTRACTS,
                X_INSTALLED_BASE        => X_INSTALLED_BASE,
                X_TERRITORY             => X_TERRITORY,
                X_AVAILABILITY          => X_AVAILABILITY ,
                X_DOCUMENT_TYPE         => X_DOCUMENT_TYPE,
                X_WINDOW_WIDTH          => X_WINDOW_WIDTH,
                X_WINDOW_HEIGHT         => X_WINDOW_HEIGHT,
                X_WINDOW_X_POSITION     => X_WINDOW_X_POSITION,
                X_WINDOW_Y_POSITION     => X_WINDOW_Y_POSITION,
                X_DOC_DTLS_USER_VALUES  => X_DOC_DTLS_USER_VALUES ,
                X_SHOW_SELECTED_TIME    => X_SHOW_SELECTED_TIME,
                X_DOC_DETAILS           => X_DOC_DETAILS,
                X_OBJECT_VERSION_NUMBER => l_object_version_number ,
                X_USER_ID               => X_USER_ID,
                X_PREFERENCE_NAME       => X_PREFERENCE_NAME ,
                X_CREATION_DATE		=> sysdate      ,
                X_CREATED_BY	        => l_user_id ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0 );
      ELSIF c_last_updated%FOUND THEN
         IF l_last_updated_by IN (1,0) THEN
            l_object_version_number :=   l_object_version_number + 1;
	    jtf_am_screen_setups_pkg.update_row(
                X_SCREEN_SETUP_ID       => X_SCREEN_SETUP_ID,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
                X_ATTRIBUTE3            => X_ATTRIBUTE3 ,
                X_ATTRIBUTE4            => X_ATTRIBUTE4 ,
                X_ATTRIBUTE5            => X_ATTRIBUTE5 ,
                X_ATTRIBUTE6            => X_ATTRIBUTE6 ,
                X_ATTRIBUTE7            => X_ATTRIBUTE7 ,
                X_ATTRIBUTE8            => X_ATTRIBUTE8 ,
                X_ATTRIBUTE9            => X_ATTRIBUTE9 ,
                X_ATTRIBUTE10           => X_ATTRIBUTE10 ,
                X_ATTRIBUTE11           => X_ATTRIBUTE11 ,
                X_ATTRIBUTE12           => X_ATTRIBUTE12 ,
                X_ATTRIBUTE13           => X_ATTRIBUTE13 ,
                X_ATTRIBUTE14           => X_ATTRIBUTE14 ,
                X_ATTRIBUTE15           => X_ATTRIBUTE15 ,
                X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY ,
                X_SECURITY_GROUP_ID     => X_SECURITY_GROUP_ID,
                X_MODE_ASSIST           => X_MODE_ASSIST,
                X_MODE_UNASSIST         => X_MODE_UNASSIST,
                X_CONTRACTS             => X_CONTRACTS,
                X_INSTALLED_BASE        => X_INSTALLED_BASE,
                X_TERRITORY             => X_TERRITORY,
                X_AVAILABILITY          => X_AVAILABILITY ,
                X_DOCUMENT_TYPE         => X_DOCUMENT_TYPE,
                X_WINDOW_WIDTH          => X_WINDOW_WIDTH,
                X_WINDOW_HEIGHT         => X_WINDOW_HEIGHT,
                X_WINDOW_X_POSITION     => X_WINDOW_X_POSITION,
                X_WINDOW_Y_POSITION     => X_WINDOW_Y_POSITION,
                X_DOC_DTLS_USER_VALUES  => X_DOC_DTLS_USER_VALUES ,
                X_SHOW_SELECTED_TIME    => X_SHOW_SELECTED_TIME,
                X_DOC_DETAILS           => X_DOC_DETAILS,
                X_OBJECT_VERSION_NUMBER => l_object_version_number,
                X_USER_ID               => X_USER_ID,
                X_PREFERENCE_NAME       => X_PREFERENCE_NAME ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0 );
           END IF;
      END IF;
CLOSE c_last_updated;
End LOAD_ROW;

Procedure TRANSLATE_ROW
(X_screen_setup_id  in number,
 X_preference_name  in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number)
is
begin
Update jtf_am_screen_setups_tl set
     preference_name        = nvl(x_preference_name,preference_name),
     last_update_date       = nvl(x_last_update_date,sysdate),
     last_updated_by        = x_last_updated_by,
     last_update_login      = 0,
     source_lang            = userenv('LANG')
where screen_setup_id       = x_screen_setup_id
  and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

end JTF_AM_SCREEN_SETUPS_PKG;

/
