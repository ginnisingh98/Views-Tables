--------------------------------------------------------
--  DDL for Package Body HR_FORM_TAB_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_TAB_PAGES_PKG" as
/* $Header: hrftplct.pkb 115.1 2002/12/10 11:50:05 hjonnala noship $ */
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
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_VISIBLE_OVERRIDE in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_CANVAS_ID in NUMBER,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_USER_TAB_PAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_FORM_TAB_PAGES_B
    where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID
    ;
begin
  insert into HR_FORM_TAB_PAGES_B (
    VISIBLE_OVERRIDE,
    FORM_TAB_PAGE_ID,
    OBJECT_VERSION_NUMBER,
    FORM_CANVAS_ID,
    TAB_PAGE_NAME,
    DISPLAY_ORDER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_VISIBLE_OVERRIDE,
    X_FORM_TAB_PAGE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_FORM_CANVAS_ID,
    X_TAB_PAGE_NAME,
    X_DISPLAY_ORDER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into HR_FORM_TAB_PAGES_TL (
    USER_TAB_PAGE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    FORM_TAB_PAGE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_USER_TAB_PAGE_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_FORM_TAB_PAGE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_FORM_TAB_PAGES_TL T
    where T.FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID
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
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_VISIBLE_OVERRIDE in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_CANVAS_ID in NUMBER,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_USER_TAB_PAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      VISIBLE_OVERRIDE,
      OBJECT_VERSION_NUMBER,
      FORM_CANVAS_ID,
      TAB_PAGE_NAME,
      DISPLAY_ORDER
    from HR_FORM_TAB_PAGES_B
    where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID
    for update of FORM_TAB_PAGE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_TAB_PAGE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_FORM_TAB_PAGES_TL
    where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FORM_TAB_PAGE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.VISIBLE_OVERRIDE = X_VISIBLE_OVERRIDE)
           OR ((recinfo.VISIBLE_OVERRIDE is null) AND (X_VISIBLE_OVERRIDE is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.FORM_CANVAS_ID = X_FORM_CANVAS_ID)
      AND (recinfo.TAB_PAGE_NAME = X_TAB_PAGE_NAME)
      AND (recinfo.DISPLAY_ORDER = X_DISPLAY_ORDER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.USER_TAB_PAGE_NAME = X_USER_TAB_PAGE_NAME)
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
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_VISIBLE_OVERRIDE in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_CANVAS_ID in NUMBER,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_DISPLAY_ORDER in NUMBER,
  X_USER_TAB_PAGE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_FORM_TAB_PAGES_B set
    VISIBLE_OVERRIDE = X_VISIBLE_OVERRIDE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    FORM_CANVAS_ID = X_FORM_CANVAS_ID,
    TAB_PAGE_NAME = X_TAB_PAGE_NAME,
    DISPLAY_ORDER = X_DISPLAY_ORDER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HR_FORM_TAB_PAGES_TL set
    USER_TAB_PAGE_NAME = X_USER_TAB_PAGE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FORM_TAB_PAGE_ID in NUMBER
) is
begin
  delete from HR_FORM_TAB_PAGES_TL
  where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HR_FORM_TAB_PAGES_B
  where FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HR_FORM_TAB_PAGES_TL T
  where not exists
    (select NULL
    from HR_FORM_TAB_PAGES_B B
    where B.FORM_TAB_PAGE_ID = T.FORM_TAB_PAGE_ID
    );

  update HR_FORM_TAB_PAGES_TL T set (
      USER_TAB_PAGE_NAME,
      DESCRIPTION
    ) = (select
      B.USER_TAB_PAGE_NAME,
      B.DESCRIPTION
    from HR_FORM_TAB_PAGES_TL B
    where B.FORM_TAB_PAGE_ID = T.FORM_TAB_PAGE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FORM_TAB_PAGE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FORM_TAB_PAGE_ID,
      SUBT.LANGUAGE
    from HR_FORM_TAB_PAGES_TL SUBB, HR_FORM_TAB_PAGES_TL SUBT
    where SUBB.FORM_TAB_PAGE_ID = SUBT.FORM_TAB_PAGE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.USER_TAB_PAGE_NAME <> SUBT.USER_TAB_PAGE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into HR_FORM_TAB_PAGES_TL (
    USER_TAB_PAGE_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    FORM_TAB_PAGE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.USER_TAB_PAGE_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.FORM_TAB_PAGE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_FORM_TAB_PAGES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_FORM_TAB_PAGES_TL T
    where T.FORM_TAB_PAGE_ID = B.FORM_TAB_PAGE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_USER_TAB_PAGE_NAME in VARCHAR2,
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
  X_FORM_TAB_PAGE_ID NUMBER;
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

 select hfc.form_canvas_id,hfw.form_window_id,ftp.form_tab_page_id
 into x_form_canvas_id,x_form_window_id,x_form_tab_page_id
 from hr_form_canvases_b hfc
      ,hr_form_windows_b hfw
      ,hr_form_tab_pages_b ftp
 where hfc.canvas_name = x_canvas_name
 and hfw.application_id = x_application_id
 and hfw.form_id = x_form_id
 and hfc.form_window_id = hfw.form_window_id
 and hfc.form_canvas_id = ftp.form_canvas_id
 and ftp.tab_page_name = x_tab_page_name
 and hfw.window_name = x_window_name;

 update HR_FORM_TAB_PAGES_TL set
  DESCRIPTION = X_DESCRIPTION,
  USER_TAB_PAGE_NAME = X_USER_TAB_PAGE_NAME,
  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
  SOURCE_LANG = userenv('LANG')
 where userenv('LANG') in (LANGUAGE,SOURCE_LANG)
 and form_tab_page_id = x_form_tab_page_id;

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2,
  X_DISPLAY_ORDER in VARCHAR2,
  X_VISIBLE_OVERRIDE in VARCHAR2,
  X_USER_TAB_PAGE_NAME in VARCHAR2,
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
  X_FORM_TAB_PAGE_ID NUMBER;
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

 select hfc.form_canvas_id
 into x_form_canvas_id
 from hr_form_canvases_b hfc
 where hfc.canvas_name = x_canvas_name
 and hfc.form_window_id = x_form_window_id;

 begin
   select ftp.form_tab_page_id
   into x_form_tab_page_id
   from hr_form_tab_pages_b ftp
   where ftp.form_canvas_id = x_form_canvas_id
   and ftp.tab_page_name = x_tab_page_name;
 exception
   when no_data_found then
     select hr_form_tab_pages_b_s.nextval
     into x_form_tab_page_id
     from dual;
 end;

 begin
   UPDATE_ROW ( X_FORM_TAB_PAGE_ID,
     to_number(X_VISIBLE_OVERRIDE),
     to_number(X_OBJECT_VERSION_NUMBER),
     X_FORM_CANVAS_ID,
     X_TAB_PAGE_NAME,
     to_number(X_DISPLAY_ORDER),
     X_USER_TAB_PAGE_NAME,
     X_DESCRIPTION,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN);

 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_FORM_TAB_PAGE_ID,
       to_number(X_VISIBLE_OVERRIDE),
       to_number(X_OBJECT_VERSION_NUMBER),
       X_FORM_CANVAS_ID,
       X_TAB_PAGE_NAME,
       to_number(X_DISPLAY_ORDER),
       X_USER_TAB_PAGE_NAME,
       X_DESCRIPTION,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);
 end;

end LOAD_ROW;
end HR_FORM_TAB_PAGES_PKG;

/
