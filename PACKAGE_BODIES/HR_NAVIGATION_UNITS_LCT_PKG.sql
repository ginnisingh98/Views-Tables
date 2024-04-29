--------------------------------------------------------
--  DDL for Package Body HR_NAVIGATION_UNITS_LCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAVIGATION_UNITS_LCT_PKG" as
/* $Header: penut01t.pkb 115.3 1999/11/05 01:37:54 pkm ship    $ */

  procedure INSERT_ROW (
  X_NAV_UNIT_ID in out NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_WORKFLOW_ID in NUMBER,
  X_APPLICATION_ABBREV in VARCHAR2,
  X_MAX_NUMBER_OF_NAV_BUTTONS in NUMBER,
  X_DEFAULT_LABEL in VARCHAR2
) is
  cursor CSR_SEQUENCE is
    select HR_NAVIGATION_UNITS_S.nextval
    from   dual;
begin
  if X_NAV_UNIT_ID is null then
    open CSR_SEQUENCE;
    fetch CSR_SEQUENCE into X_NAV_UNIT_ID;
    close CSR_SEQUENCE;
  end if;
  insert into HR_NAVIGATION_UNITS (
    NAV_UNIT_ID,
    FORM_NAME,
    BLOCK_NAME,
    DEFAULT_WORKFLOW_ID,
    APPLICATION_ABBREV,
    MAX_NUMBER_OF_NAV_BUTTONS,
    DEFAULT_LABEL
  ) values (
    X_NAV_UNIT_ID,
    X_FORM_NAME,
    X_BLOCK_NAME,
    X_DEFAULT_WORKFLOW_ID,
    X_APPLICATION_ABBREV,
    X_MAX_NUMBER_OF_NAV_BUTTONS,
    X_DEFAULT_LABEL
  );
end INSERT_ROW;
--
procedure LOCK_ROW (
  X_NAV_UNIT_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_WORKFLOW_ID in NUMBER,
  X_APPLICATION_ABBREV in VARCHAR2,
  X_MAX_NUMBER_OF_NAV_BUTTONS in NUMBER
) is
  cursor CSR_NAVIGATION_UNIT (
    X_NAV_UNIT_ID in NUMBER
  ) is
    select FORM_NAME,
           BLOCK_NAME,
           DEFAULT_WORKFLOW_ID,
           APPLICATION_ABBREV,
           MAX_NUMBER_OF_NAV_BUTTONS
    from   HR_NAVIGATION_UNITS
    where  NAV_UNIT_ID = X_NAV_UNIT_ID
    for update of NAV_UNIT_ID nowait;
  RECINFO CSR_NAVIGATION_UNIT%rowtype;
begin
  open CSR_NAVIGATION_UNIT(X_NAV_UNIT_ID);
  fetch CSR_NAVIGATION_UNIT into RECINFO;
  if (CSR_NAVIGATION_UNIT%notfound) then
    close CSR_NAVIGATION_UNIT;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close CSR_NAVIGATION_UNIT;
  if (   (  (RECINFO.FORM_NAME = X_FORM_NAME)
         or (RECINFO.FORM_NAME is null and X_FORM_NAME is null))
     and (  (RECINFO.BLOCK_NAME = X_BLOCK_NAME)
         or (RECINFO.BLOCK_NAME is null and X_BLOCK_NAME is null))
     and (  (RECINFO.DEFAULT_WORKFLOW_ID = X_DEFAULT_WORKFLOW_ID)
         or (RECINFO.DEFAULT_WORKFLOW_ID is null and X_DEFAULT_WORKFLOW_ID is null))
     and (  (RECINFO.APPLICATION_ABBREV = X_APPLICATION_ABBREV)
         or (RECINFO.APPLICATION_ABBREV is null and X_APPLICATION_ABBREV is null))
     and (  (RECINFO.MAX_NUMBER_OF_NAV_BUTTONS = X_MAX_NUMBER_OF_NAV_BUTTONS)
         or (RECINFO.MAX_NUMBER_OF_NAV_BUTTONS is null and X_MAX_NUMBER_OF_NAV_BUTTONS is null))
     ) then
    null;
  else
    fnd_message.set_name('FND','FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
end LOCK_ROW;
--
procedure UPDATE_ROW (
  X_NAV_UNIT_ID in NUMBER,
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_WORKFLOW_ID in NUMBER,
  X_APPLICATION_ABBREV in VARCHAR2,
  X_MAX_NUMBER_OF_NAV_BUTTONS in NUMBER,
  X_DEFAULT_LABEL in VARCHAR2
) is
begin
  update HR_NAVIGATION_UNITS set
    FORM_NAME = X_FORM_NAME,
    BLOCK_NAME = X_BLOCK_NAME,
    DEFAULT_WORKFLOW_ID = X_DEFAULT_WORKFLOW_ID,
    APPLICATION_ABBREV = X_APPLICATION_ABBREV,
    MAX_NUMBER_OF_NAV_BUTTONS = X_MAX_NUMBER_OF_NAV_BUTTONS,
    DEFAULT_LABEL = X_DEFAULT_LABEL
  where NAV_UNIT_ID = X_NAV_UNIT_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
--
procedure DELETE_ROW (
  X_NAV_UNIT_ID in NUMBER
) is
begin
  delete from HR_NAVIGATION_UNITS
  where NAV_UNIT_ID = X_NAV_UNIT_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
--
procedure LOAD_ROW (
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_WORKFLOW_NAME in VARCHAR2,
  X_APPLICATION_ABBREV in VARCHAR2,
  X_MAX_NUMBER_OF_NAV_BUTTONS in NUMBER,
  X_DEFAULT_LABEL in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  cursor CSR_NAVIGATION_UNIT (
    X_FORM_NAME in VARCHAR2,
    X_BLOCK_NAME in VARCHAR2
  ) is
    select NAV_UNIT_ID
    from   HR_NAVIGATION_UNITS
    where FORM_NAME = X_FORM_NAME
    and   (  (BLOCK_NAME = X_BLOCK_NAME)
          or (BLOCK_NAME is null and X_BLOCK_NAME is null));
  cursor CSR_WORKFLOW (
    X_WORKFLOW_NAME in VARCHAR2
  ) is
    select WORKFLOW_ID
    from   HR_WORKFLOWS
    where  WORKFLOW_NAME = X_WORKFLOW_NAME;
  X_NAV_UNIT_ID NUMBER;
  X_DEFAULT_WORKFLOW_ID NUMBER;
begin
  open CSR_NAVIGATION_UNIT(X_FORM_NAME,X_BLOCK_NAME);
  fetch CSR_NAVIGATION_UNIT into X_NAV_UNIT_ID;
  close CSR_NAVIGATION_UNIT;
  open CSR_WORKFLOW(X_DEFAULT_WORKFLOW_NAME);
  fetch CSR_WORKFLOW into X_DEFAULT_WORKFLOW_ID;
  close CSR_WORKFLOW;
  begin
    UPDATE_ROW (
      X_NAV_UNIT_ID,
      X_FORM_NAME,
      X_BLOCK_NAME,
      X_DEFAULT_WORKFLOW_ID,
      X_APPLICATION_ABBREV,
      X_MAX_NUMBER_OF_NAV_BUTTONS,
      X_DEFAULT_LABEL
    );
  exception
    when no_data_found then
      INSERT_ROW (
        X_NAV_UNIT_ID,
        X_FORM_NAME,
        X_BLOCK_NAME,
        X_DEFAULT_WORKFLOW_ID,
        X_APPLICATION_ABBREV,
        X_MAX_NUMBER_OF_NAV_BUTTONS,
        X_DEFAULT_LABEL
      );
  end;
end LOAD_ROW;
--
procedure TRANSLATE_ROW (
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_LABEL in VARCHAR2,
  X_OWNER in VARCHAR2
) is
begin
  update HR_NAVIGATION_UNITS set
    DEFAULT_LABEL = X_DEFAULT_LABEL
  where FORM_NAME = X_FORM_NAME
  and   (  (BLOCK_NAME = X_BLOCK_NAME)
        or (BLOCK_NAME is null and X_BLOCK_NAME is null))
  and   userenv('LANG') = (select LANGUAGE_CODE
                           from   FND_LANGUAGES
                           where  INSTALLED_FLAG = 'B');
end TRANSLATE_ROW;
--
end HR_NAVIGATION_UNITS_LCT_PKG;

/
