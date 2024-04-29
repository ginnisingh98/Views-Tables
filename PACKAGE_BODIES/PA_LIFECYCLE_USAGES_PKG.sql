--------------------------------------------------------
--  DDL for Package Body PA_LIFECYCLE_USAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_LIFECYCLE_USAGES_PKG" AS
/* $Header: PALCUPKB.pls 115.1 2002/10/22 21:25:22 mrajput noship $ */

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE INSERT_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER :=1,
  X_LIFECYCLE_ID in NUMBER,
  X_USAGE_TYPE in VARCHAR2
) IS
BEGIN
  insert into PA_LIFECYCLE_USAGES (
    LAST_UPDATE_LOGIN,
    RECORD_VERSION_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    LIFECYCLE_USAGE_ID,
    LIFECYCLE_ID,
    USAGE_TYPE,
    CREATION_DATE
  ) values
 (
    FND_GLOBAL.LOGIN_ID,
    1,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    FND_GLOBAL.USER_ID,
    X_LIFECYCLE_USAGE_ID,
    X_LIFECYCLE_ID,
    X_USAGE_TYPE,
    SYSDATE
 );

END INSERT_ROW;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/
-- Not used as of now. Locking should be done in calling API's

PROCEDURE LOCK_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_USAGE_TYPE in VARCHAR2
) IS
  cursor c1 is select
      RECORD_VERSION_NUMBER,
      LIFECYCLE_ID,
      USAGE_TYPE,
      LIFECYCLE_USAGE_ID
    from PA_LIFECYCLE_USAGES
    where LIFECYCLE_USAGE_ID = X_LIFECYCLE_USAGE_ID
    for update of LIFECYCLE_USAGE_ID nowait;
BEGIN
  for tlinfo in c1 loop
      if (    (tlinfo.LIFECYCLE_USAGE_ID = X_LIFECYCLE_USAGE_ID)
          AND ((tlinfo.RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER)
               OR ((tlinfo.RECORD_VERSION_NUMBER is null) AND (X_RECORD_VERSION_NUMBER is null)))
          AND (tlinfo.LIFECYCLE_ID = X_LIFECYCLE_ID)
          AND (tlinfo.USAGE_TYPE = X_USAGE_TYPE)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
END LOCK_ROW;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE UPDATE_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER,
  X_RECORD_VERSION_NUMBER in NUMBER,
  X_LIFECYCLE_ID in NUMBER,
  X_USAGE_TYPE in VARCHAR2
) IS
BEGIN
  update PA_LIFECYCLE_USAGES set
    RECORD_VERSION_NUMBER = nvl(X_RECORD_VERSION_NUMBER,0)+1,
    LIFECYCLE_ID = X_LIFECYCLE_ID,
    USAGE_TYPE = X_USAGE_TYPE,
    LIFECYCLE_USAGE_ID = X_LIFECYCLE_USAGE_ID,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
  where LIFECYCLE_USAGE_ID = X_LIFECYCLE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END UPDATE_ROW;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE DELETE_ROW (
  X_LIFECYCLE_USAGE_ID in NUMBER
) IS
BEGIN
  delete from PA_LIFECYCLE_USAGES
  where LIFECYCLE_USAGE_ID = X_LIFECYCLE_USAGE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END DELETE_ROW;

END PA_LIFECYCLE_USAGES_PKG;

/
