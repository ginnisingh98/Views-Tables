--------------------------------------------------------
--  DDL for Package Body AMW_VIOLATION_USERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_VIOLATION_USERS_PKG" AS
/* $Header: amwtvlub.pls 120.1.12000000.2 2007/04/02 16:54:25 dliao ship $ */

-- ===============================================================
-- Package name
--          AMW_VIOLATION_USERS_PKG
-- Purpose
--
-- History
-- 		  	11/11/2003    tsho     Creates
--          01/06/2005    tsho     for new column WAIVED_FLAG
-- ===============================================================



-- ===============================================================
-- Procedure name
--          INSERT_ROW
-- Purpose
-- 		  	create new violated user into AMW_VIOLATION_USERS
-- History
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_USER_VIOLATION_ID in NUMBER,
  X_VIOLATION_ID in NUMBER,
  X_VIOLATED_BY_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_WAIVED_FLAG in VARCHAR2 := NULL,
  X_CORRECTED_FLAG in VARCHAR2 := NULL
) is
  cursor C is select ROWID from AMW_VIOLATION_USERS
    where USER_VIOLATION_ID = X_USER_VIOLATION_ID
    ;
begin
  insert into AMW_VIOLATION_USERS (
  USER_VIOLATION_ID,
  VIOLATION_ID,
  VIOLATED_BY_ID,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATE_LOGIN,
  SECURITY_GROUP_ID,
  WAIVED_FLAG,
  CORRECTED_FLAG
  ) values (
  X_USER_VIOLATION_ID,
  X_VIOLATION_ID,
  X_VIOLATED_BY_ID,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_DATE,
  X_CREATED_BY,
  X_CREATION_DATE,
  X_LAST_UPDATE_LOGIN,
  X_SECURITY_GROUP_ID,
  X_WAIVED_FLAG,
  X_CORRECTED_FLAG
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;



-- ===============================================================
-- Procedure name
--          LOCK_ROW
-- Purpose
--
-- History
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================
procedure LOCK_ROW (
  X_USER_VIOLATION_ID in NUMBER,
  X_VIOLATION_ID in NUMBER,
  X_VIOLATED_BY_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_WAIVED_FLAG in VARCHAR2 := NULL,
  X_CORRECTED_FLAG in VARCHAR2 := NULL
) is
  cursor c is select
    VIOLATION_ID,
    VIOLATED_BY_ID,
    SECURITY_GROUP_ID,
    WAIVED_FLAG,
    CORRECTED_FLAG
    from AMW_VIOLATION_USERS
    where USER_VIOLATION_ID = X_USER_VIOLATION_ID
    for update of USER_VIOLATION_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (
          ((recinfo.VIOLATION_ID = X_VIOLATION_ID)
           OR ((recinfo.VIOLATION_ID is null) AND (X_VIOLATION_ID is null)))
      AND ((recinfo.VIOLATED_BY_ID = X_VIOLATED_BY_ID)
           OR ((recinfo.VIOLATED_BY_ID is null) AND (X_VIOLATED_BY_ID is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.WAIVED_FLAG = X_WAIVED_FLAG)
           OR ((recinfo.WAIVED_FLAG is null) AND (X_WAIVED_FLAG is null)))
      AND ((recinfo.CORRECTED_FLAG = X_CORRECTED_FLAG)
           OR ((recinfo.CORRECTED_FLAG is null) AND (X_CORRECTED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;



-- ===============================================================
-- Procedure name
--          UPDATE_ROW
-- Purpose
-- 		  	update AMW_VIOLATION_USERS
-- History
--          05/23/2005    tsho     AMW.E add corrected_flag
-- ===============================================================
procedure UPDATE_ROW (
  X_USER_VIOLATION_ID in NUMBER,
  X_VIOLATION_ID in NUMBER,
  X_VIOLATED_BY_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_WAIVED_FLAG in VARCHAR2 := NULL,
  X_CORRECTED_FLAG in VARCHAR2 := NULL
) is
begin

IF ( X_WAIVED_FLAG IS NULL OR X_WAIVED_FLAG = '') THEN
  update AMW_VIOLATION_USERS set
    VIOLATION_ID = X_VIOLATION_ID,
    VIOLATED_BY_ID = X_VIOLATED_BY_ID,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
  --  WAIVED_FLAG = X_WAIVED_FLAG,
    CORRECTED_FLAG = X_CORRECTED_FLAG
  where USER_VIOLATION_ID = X_USER_VIOLATION_ID;
 ELSE
  update AMW_VIOLATION_USERS set
    VIOLATION_ID = X_VIOLATION_ID,
    VIOLATED_BY_ID = X_VIOLATED_BY_ID,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    WAIVED_FLAG = X_WAIVED_FLAG,
    CORRECTED_FLAG = X_CORRECTED_FLAG
  where USER_VIOLATION_ID = X_USER_VIOLATION_ID;
 END IF;


  if (sql%notfound) then
    raise no_data_found;
  end if;


end UPDATE_ROW;


-- ===============================================================
-- Procedure name
--          DELETE_ROW
-- Purpose
--
-- ===============================================================
procedure DELETE_ROW (
  X_USER_VIOLATION_ID in NUMBER
) is
begin
  delete from AMW_VIOLATION_USERS
  where USER_VIOLATION_ID = X_USER_VIOLATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;




-- ----------------------------------------------------------------------
end AMW_VIOLATION_USERS_PKG;

/
