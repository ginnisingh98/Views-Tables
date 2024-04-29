--------------------------------------------------------
--  DDL for Package Body HR_FSC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FSC_PKG" as
/* $Header: hrfsclct.pkb 115.1 2002/12/10 11:26:01 hjonnala noship $ */
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
  X_FORM_TAB_STACKED_CANVAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_FORM_CANVAS_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from HR_FORM_TAB_STACKED_CANVASES
    where FORM_TAB_STACKED_CANVAS_ID = X_FORM_TAB_STACKED_CANVAS_ID
    ;
begin
  insert into HR_FORM_TAB_STACKED_CANVASES (
    FORM_TAB_STACKED_CANVAS_ID,
    OBJECT_VERSION_NUMBER,
    FORM_TAB_PAGE_ID,
    FORM_CANVAS_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE
  ) values(
    X_FORM_TAB_STACKED_CANVAS_ID,
    X_OBJECT_VERSION_NUMBER,
    X_FORM_TAB_PAGE_ID,
    X_FORM_CANVAS_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_FORM_TAB_STACKED_CANVAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_FORM_CANVAS_ID in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      FORM_TAB_PAGE_ID,
      FORM_CANVAS_ID
    from HR_FORM_TAB_STACKED_CANVASES
    where FORM_TAB_STACKED_CANVAS_ID = X_FORM_TAB_STACKED_CANVAS_ID
    for update of FORM_TAB_STACKED_CANVAS_ID nowait;
begin
  for tlinfo in c1 loop
      if (   (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
          AND (tlinfo.FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID)
          AND (tlinfo.FORM_CANVAS_ID = X_FORM_CANVAS_ID)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_FORM_TAB_STACKED_CANVAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FORM_TAB_PAGE_ID in NUMBER,
  X_FORM_CANVAS_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update HR_FORM_TAB_STACKED_CANVASES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    FORM_TAB_PAGE_ID = X_FORM_TAB_PAGE_ID,
    FORM_CANVAS_ID = X_FORM_CANVAS_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FORM_TAB_STACKED_CANVAS_ID = X_FORM_TAB_STACKED_CANVAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FORM_TAB_STACKED_CANVAS_ID in NUMBER
) is
begin
  delete from HR_FORM_TAB_STACKED_CANVASES
  where FORM_TAB_STACKED_CANVAS_ID = X_FORM_TAB_STACKED_CANVAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_FORM_NAME in VARCHAR2,
  X_TAB_PAGE_NAME in VARCHAR2,
  X_CANVAS_NAME in VARCHAR2,
  X_CANVAS_NAME1 in VARCHAR2,
  X_WINDOW_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in VARCHAR2) is
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
  X_FORM_TAB_STACKED_CANVAS_ID NUMBER;
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
 where hfc.canvas_name = x_canvas_name1
 and hfc.form_window_id = x_form_window_id;

 select ftp.form_tab_page_id
 into x_form_tab_page_id
 from hr_form_tab_pages_b ftp
 where ftp.form_canvas_id = x_form_canvas_id
 and ftp.tab_page_name = x_tab_page_name;

 select hfc.form_canvas_id
 into x_form_canvas_id
 from hr_form_canvases_b hfc
 where hfc.canvas_name = x_canvas_name
 and hfc.form_window_id = x_form_window_id;

 begin
   select ftsc.form_tab_stacked_canvas_id
   into x_form_tab_stacked_canvas_id
   from hr_form_tab_stacked_canvases ftsc
   where ftsc.form_canvas_id = x_form_canvas_id
   and ftsc.form_tab_page_id = x_form_tab_page_id;
 exception
   when no_data_found then
     select hr_form_tab_stacked_canvases_s.nextval
     into x_form_tab_stacked_canvas_id
     from dual;
 end;

 begin
   UPDATE_ROW (
     X_FORM_TAB_STACKED_CANVAS_ID,
     to_number(X_OBJECT_VERSION_NUMBER),
     X_FORM_TAB_PAGE_ID,
     X_FORM_CANVAS_ID,
     X_LAST_UPDATE_DATE,
     X_LAST_UPDATED_BY,
     X_LAST_UPDATE_LOGIN
   );
 exception
   when no_data_found then
     INSERT_ROW (
       X_ROWID,
       X_FORM_TAB_STACKED_CANVAS_ID,
       to_number(X_OBJECT_VERSION_NUMBER),
       X_FORM_TAB_PAGE_ID,
       X_FORM_CANVAS_ID,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN);
      end;

end LOAD_ROW;

end HR_FSC_PKG;

/
