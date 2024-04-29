--------------------------------------------------------
--  DDL for Package Body CLN_NOTIFICATION_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_NOTIFICATION_CODES_PKG" as
/* $Header: ECXNCTHB.pls 120.1 2005/08/26 07:01:03 nparihar noship $*/
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_NOTIFICATION_ID in NUMBER,
  X_COLLABORATION_POINT in VARCHAR2,
  X_NOTIFICATION_CODE in VARCHAR2,
  X_NOTIFICATION_MESSAGE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from CLN_NOTIFICATION_CODES_B
    where NOTIFICATION_ID = X_NOTIFICATION_ID
    ;
begin
  insert into CLN_NOTIFICATION_CODES_B (
    NOTIFICATION_ID,
    COLLABORATION_POINT,
    NOTIFICATION_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_NOTIFICATION_ID,
    X_COLLABORATION_POINT,
  X_NOTIFICATION_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into CLN_NOTIFICATION_CODES_TL (
    NOTIFICATION_ID,
    NOTIFICATION_MESSAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_NOTIFICATION_ID,
    X_NOTIFICATION_MESSAGE,
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
    from CLN_NOTIFICATION_CODES_TL T
    where T.NOTIFICATION_ID = X_NOTIFICATION_ID
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
  X_NOTIFICATION_ID in NUMBER,
  X_COLLABORATION_POINT in VARCHAR2,
  X_NOTIFICATION_CODE in VARCHAR2,
  X_NOTIFICATION_MESSAGE in VARCHAR2
) is
  cursor c is select
      COLLABORATION_POINT,
      NOTIFICATION_CODE
    from CLN_NOTIFICATION_CODES_B
    where NOTIFICATION_ID = X_NOTIFICATION_ID
    for update of NOTIFICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NOTIFICATION_MESSAGE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CLN_NOTIFICATION_CODES_TL
    where NOTIFICATION_ID = X_NOTIFICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of NOTIFICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.COLLABORATION_POINT = X_COLLABORATION_POINT)
           OR ((recinfo.COLLABORATION_POINT is null) AND (X_COLLABORATION_POINT is null)))
      AND ((recinfo.NOTIFICATION_CODE = X_NOTIFICATION_CODE)
           OR ((recinfo.NOTIFICATION_CODE is null) AND (X_NOTIFICATION_CODE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NOTIFICATION_MESSAGE = X_NOTIFICATION_MESSAGE)
               OR ((tlinfo.NOTIFICATION_MESSAGE is null) AND (X_NOTIFICATION_MESSAGE is null)))
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
  X_NOTIFICATION_ID in NUMBER,
  X_COLLABORATION_POINT in VARCHAR2,
  X_NOTIFICATION_CODE in VARCHAR2,
  X_NOTIFICATION_MESSAGE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update CLN_NOTIFICATION_CODES_B set
    COLLABORATION_POINT = X_COLLABORATION_POINT,
    NOTIFICATION_CODE = X_NOTIFICATION_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where NOTIFICATION_ID = X_NOTIFICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CLN_NOTIFICATION_CODES_TL set
    NOTIFICATION_MESSAGE = X_NOTIFICATION_MESSAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where NOTIFICATION_ID = X_NOTIFICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_NOTIFICATION_ID in NUMBER
) is
begin
  delete from CLN_NOTIFICATION_CODES_TL
  where NOTIFICATION_ID = X_NOTIFICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CLN_NOTIFICATION_CODES_B
  where NOTIFICATION_ID = X_NOTIFICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CLN_NOTIFICATION_CODES_TL T
  where not exists
    (select NULL
    from CLN_NOTIFICATION_CODES_B B
    where B.NOTIFICATION_ID = T.NOTIFICATION_ID
    );

  update CLN_NOTIFICATION_CODES_TL T set (
      NOTIFICATION_MESSAGE
    ) = (select
      B.NOTIFICATION_MESSAGE
    from CLN_NOTIFICATION_CODES_TL B
    where B.NOTIFICATION_ID = T.NOTIFICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NOTIFICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.NOTIFICATION_ID,
      SUBT.LANGUAGE
    from CLN_NOTIFICATION_CODES_TL SUBB, CLN_NOTIFICATION_CODES_TL SUBT
    where SUBB.NOTIFICATION_ID = SUBT.NOTIFICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NOTIFICATION_MESSAGE <> SUBT.NOTIFICATION_MESSAGE
      or (SUBB.NOTIFICATION_MESSAGE is null and SUBT.NOTIFICATION_MESSAGE is not null)
      or (SUBB.NOTIFICATION_MESSAGE is not null and SUBT.NOTIFICATION_MESSAGE is null)
  ));

  insert into CLN_NOTIFICATION_CODES_TL (
    NOTIFICATION_ID,
    NOTIFICATION_MESSAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NOTIFICATION_ID,
   B.NOTIFICATION_MESSAGE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CLN_NOTIFICATION_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CLN_NOTIFICATION_CODES_TL T
    where T.NOTIFICATION_ID = B.NOTIFICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

 /*----------------------------------------------------------*/
 /* Translate_row Procedure                                     */
/*----------------------------------------------------------*/
PROCEDURE translate_row
  (
   X_NOTIFICATION_ID            IN NUMBER   ,
   X_OWNER                      IN VARCHAR2 ,
   X_NOTIFICATION_MESSAGE       IN VARCHAR2
   ) IS
BEGIN
   UPDATE CLN_NOTIFICATION_CODES_TL SET
     NOTIFICATION_MESSAGE       = X_NOTIFICATION_MESSAGE,
     LAST_UPDATE_DATE           = sysdate,
     LAST_UPDATED_BY            = Decode(x_owner, 'SEED', 1, 0),
     LAST_UPDATE_LOGIN          = 0,
     SOURCE_LANG                = userenv('LANG')
     WHERE NOTIFICATION_ID      = fnd_number.canonical_to_number(X_NOTIFICATION_ID)
     AND userenv('LANG') IN (language, source_lang);
END translate_row;

 /*----------------------------------------------------------*/
 /* Load_Row Procedure                                     */
 /*----------------------------------------------------------*/
PROCEDURE load_row
  (
   X_NOTIFICATION_ID            IN NUMBER  ,
   X_OWNER                      IN VARCHAR2,
   X_COLLABORATION_POINT        IN VARCHAR2,
   X_NOTIFICATION_CODE          IN VARCHAR2,
   X_NOTIFICATION_MESSAGE       IN VARCHAR2
  ) IS
  BEGIN
   DECLARE
      l_notification_id          NUMBER;
      l_user_id                  NUMBER := 0;
      l_row_id                   VARCHAR2(64);
      l_sysdate                  DATE;
      l_notification_code VARCHAR2(100);
   BEGIN
      IF (x_owner = 'SEED') THEN
         l_user_id := 1;
      END IF;
      --

      SELECT Sysdate INTO l_sysdate FROM dual;
      -- l_notification_id  := fnd_number.canonical_to_number(X_NOTIFICATION_ID);

      BEGIN

         SELECT NOTIFICATION_ID INTO l_notification_id FROM CLN_NOTIFICATION_CODES_B
         WHERE NOTIFICATION_CODE = X_NOTIFICATION_CODE
         AND COLLABORATION_POINT = X_COLLABORATION_POINT;

      EXCEPTION
         WHEN NO_DATA_FOUND then

         SELECT CLN_NOTIFICATION_CODES_S.NEXTVAL INTO l_notification_id FROM DUAL;

         insert into CLN_NOTIFICATION_CODES_B (
             NOTIFICATION_ID,
             COLLABORATION_POINT,
             NOTIFICATION_CODE,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN
           )
         values (
             l_notification_id,
             X_COLLABORATION_POINT,
             X_NOTIFICATION_CODE,
             l_sysdate,
             l_user_id,
             l_sysdate,
             l_user_id,
             0
         );

         insert into CLN_NOTIFICATION_CODES_TL (
             NOTIFICATION_ID,
             NOTIFICATION_MESSAGE,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_LOGIN,
             LANGUAGE,
             SOURCE_LANG
             ) select
             l_notification_id,
             X_NOTIFICATION_MESSAGE,
             l_sysdate,
             l_user_id,
             l_sysdate,
             l_user_id,
             0,
             L.LANGUAGE_CODE,
             userenv('LANG')
             from FND_LANGUAGES L
             where L.INSTALLED_FLAG in ('I', 'B')
             and not exists
             (select NULL
             from CLN_NOTIFICATION_CODES_TL T
             where T.NOTIFICATION_ID = l_notification_id
             and T.LANGUAGE = L.LANGUAGE_CODE);

         RETURN;

      END;

      update CLN_NOTIFICATION_CODES_TL set
      NOTIFICATION_MESSAGE = X_NOTIFICATION_MESSAGE,
      LAST_UPDATE_DATE = l_sysdate,
      LAST_UPDATED_BY = l_user_id,
      LAST_UPDATE_LOGIN = 0,
      SOURCE_LANG = userenv('LANG')
      where NOTIFICATION_ID = l_notification_id
      and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

END;
commit;
END load_row;


end CLN_NOTIFICATION_CODES_PKG;

/
