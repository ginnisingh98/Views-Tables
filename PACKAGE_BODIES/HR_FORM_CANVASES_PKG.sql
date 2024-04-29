--------------------------------------------------------
--  DDL for Package Body HR_FORM_CANVASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_CANVASES_PKG" as
/* $Header: hrfcnlct.pkb 120.1 2006/10/16 12:19:08 snukala noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FORM_CANVAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_CANVAS_TYPE in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_USER_CANVAS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_FORM_CANVASES_B
    where FORM_CANVAS_ID = X_FORM_CANVAS_ID
    ;
begin
-- Added cursor check for Bug 5600334 to avoid unwanted inserts.
 open c;
 fetch c into X_ROWID;
 if (c%notfound) then
     close c;
   insert into HR_FORM_CANVASES_B (
    OBJECT_VERSION_NUMBER,
    FORM_WINDOW_ID,
    CANVAS_TYPE,
    FORM_CANVAS_ID,
    CANVAS_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_FORM_WINDOW_ID,
    X_CANVAS_TYPE,
    X_FORM_CANVAS_ID,
    X_CANVAS_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 end if;
 close c;

  insert into HR_FORM_CANVASES_TL (
    FORM_CANVAS_ID,
    USER_CANVAS_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FORM_CANVAS_ID,
    X_USER_CANVAS_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_FORM_CANVASES_TL T
    where T.FORM_CANVAS_ID = X_FORM_CANVAS_ID
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
  X_FORM_CANVAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_CANVAS_TYPE in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_USER_CANVAS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      FORM_WINDOW_ID,
      CANVAS_TYPE,
      CANVAS_NAME
    from HR_FORM_CANVASES_B
    where FORM_CANVAS_ID = X_FORM_CANVAS_ID
    for update of FORM_CANVAS_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_CANVAS_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_FORM_CANVASES_TL
    where FORM_CANVAS_ID = X_FORM_CANVAS_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FORM_CANVAS_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.FORM_WINDOW_ID = X_FORM_WINDOW_ID)
      AND (recinfo.CANVAS_TYPE = X_CANVAS_TYPE)
      AND (recinfo.CANVAS_NAME = X_CANVAS_NAME)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_CANVAS_NAME = X_USER_CANVAS_NAME)
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
  X_FORM_CANVAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_WINDOW_ID in NUMBER,
  X_CANVAS_TYPE in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_USER_CANVAS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_FORM_CANVASES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    FORM_WINDOW_ID = X_FORM_WINDOW_ID,
    CANVAS_TYPE = X_CANVAS_TYPE,
    CANVAS_NAME = X_CANVAS_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FORM_CANVAS_ID = X_FORM_CANVAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HR_FORM_CANVASES_TL set
    USER_CANVAS_NAME = X_USER_CANVAS_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FORM_CANVAS_ID = X_FORM_CANVAS_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FORM_CANVAS_ID in NUMBER
) is
begin
  delete from HR_FORM_CANVASES_TL
  where FORM_CANVAS_ID = X_FORM_CANVAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HR_FORM_CANVASES_B
  where FORM_CANVAS_ID = X_FORM_CANVAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HR_FORM_CANVASES_TL T
  where not exists
    (select NULL
    from HR_FORM_CANVASES_B B
    where B.FORM_CANVAS_ID = T.FORM_CANVAS_ID
    );

  update HR_FORM_CANVASES_TL T set (
      USER_CANVAS_NAME,
      DESCRIPTION
    ) = (select
      B.USER_CANVAS_NAME,
      B.DESCRIPTION
    from HR_FORM_CANVASES_TL B
    where B.FORM_CANVAS_ID = T.FORM_CANVAS_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FORM_CANVAS_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FORM_CANVAS_ID,
      SUBT.LANGUAGE
    from HR_FORM_CANVASES_TL SUBB, HR_FORM_CANVASES_TL SUBT
    where SUBB.FORM_CANVAS_ID = SUBT.FORM_CANVAS_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_CANVAS_NAME <> SUBT.USER_CANVAS_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into HR_FORM_CANVASES_TL (
    FORM_CANVAS_ID,
    USER_CANVAS_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FORM_CANVAS_ID,
    B.USER_CANVAS_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_FORM_CANVASES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_FORM_CANVASES_TL T
    where T.FORM_CANVAS_ID = B.FORM_CANVAS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_CANVAS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_CANVAS_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
begin

  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select hfc.form_canvas_id,hfw.form_window_id
 into x_form_canvas_id,x_form_window_id
 from hr_form_canvases_b hfc
      ,hr_form_windows_b hfw
 where hfc.canvas_name = x_canvas_name
 and hfw.application_id = x_application_id
 and hfw.form_id = x_form_id
 and hfw.window_name = x_window_name;

 update HR_FORM_CANVASES_TL set
  DESCRIPTION = X_DESCRIPTION,
  USER_CANVAS_NAME = X_USER_CANVAS_NAME,
  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
  SOURCE_LANG = userenv('LANG')
 where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
 and form_canvas_id = x_form_canvas_id;

end TRANSLATE_ROW;
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_CANVAS_TYPE in VARCHAR2,
  X_USER_CANVAS_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2) is
  X_ROWID ROWID;
  X_CREATION_DATE DATE;
  X_CREATED_BY NUMBER;
  X_LAST_UPDATE_DATE DATE;
  X_LAST_UPDATED_BY NUMBER;
  X_LAST_UPDATE_LOGIN NUMBER;
  X_FORM_ID NUMBER;
  X_APPLICATION_ID NUMBER;
  X_FORM_CANVAS_ID NUMBER;
  X_FORM_WINDOW_ID NUMBER;
begin

  OWNER_TO_WHO (
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

 select application_id
 into x_application_id
 from fnd_application
 where application_short_name = x_application_short_name;

 select form_id
 into x_form_id
 from fnd_form
 where form_name = x_form_name
 and application_id = x_application_id;

 select hfw.form_window_id
 into x_form_window_id
 from hr_form_windows_b hfw
 where hfw.application_id = x_application_id
 and hfw.form_id = x_form_id
 and hfw.window_name = x_window_name;

 begin
   select hfc.form_canvas_id
   into x_form_canvas_id
   from hr_form_canvases_b hfc
   where hfc.canvas_name = x_canvas_name
   and hfc.form_window_id = x_form_window_id;
 exception
   when no_data_found then
     select hr_form_canvases_b_s.nextval
     into x_form_canvas_id
     from dual;
 end;

 begin
   UPDATE_ROW (
     X_FORM_CANVAS_ID,
     to_number(X_OBJECT_VERSION_NUMBER),
     X_FORM_WINDOW_ID,
     X_CANVAS_TYPE,
     X_CANVAS_NAME,
     X_USER_CANVAS_NAME,
     X_DESCRIPTION,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
   );
 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_FORM_CANVAS_ID,
       to_number(X_OBJECT_VERSION_NUMBER),
       X_FORM_WINDOW_ID,
       X_CANVAS_TYPE,
       X_CANVAS_NAME,
       X_USER_CANVAS_NAME,
       X_DESCRIPTION,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);

 end;
end LOAD_ROW;
end HR_FORM_CANVASES_PKG;

/
