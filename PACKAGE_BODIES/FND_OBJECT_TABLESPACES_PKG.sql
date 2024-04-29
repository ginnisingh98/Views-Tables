--------------------------------------------------------
--  DDL for Package Body FND_OBJECT_TABLESPACES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OBJECT_TABLESPACES_PKG" as
/* $Header: fndtobjb.pls 115.10 2004/04/22 22:14:20 sakhtar noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'FND_OBJECT_TABLESPACES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'fndtobjb.pls';

function OWNER_ID(
  p_name in varchar2)
return number is
l_user_id number;
begin
  if (p_name in ('SEED','CUSTOM')) then
    -- Old loader seed data
    return 1;
  elsif (p_name = 'ORACLE') then
    -- New loader seed data
    return 2;
  else
   begin
    -- User customized data
    select user_id
     into l_user_id
     from fnd_user
    where p_name = user_name;
     return l_user_id;
    exception
     when no_data_found then
        return -1;
   end;
  end if;
end OWNER_ID;

function UPLOAD_TEST(
  p_file_id     in number,
  p_file_lud    in date,
  p_db_id       in number,
  p_db_lud      in date,
  p_custom_mode in varchar2)
return boolean is
  l_db_id number;
  l_file_id number;
  l_original_seed_data_window date;
  retcode boolean;
begin
  -- CUSTOM_MODE=FORCE trumps all.
  if (p_custom_mode = 'FORCE') then
    retcode := TRUE;
    return retcode;
  end if;

  -- Handle cases where data was previously up/downloaded with
  -- 'SEED'/1 owner instead of 'ORACLE'/2, but DOES have a version
  -- date.  These rows can be distinguished by the lud timestamp;
  -- Rows without versions were uploaded with sysdate, rows with
  -- versions were uploaded with a date (with time truncated) from
  -- the file.

  -- Check file row for SEED/version
  l_file_id := p_file_id;
  if ((l_file_id in (0,1)) and (p_file_lud = trunc(p_file_lud)) and
      (p_file_lud < sysdate - .1)) then
    l_file_id := 2;
  end if;

  -- Check db row for SEED/version.
  -- NOTE: if db ludate < seed_data_window, then consider this to be
  -- original seed data, never touched by FNDLOAD, even if it doesn't
  -- have a timestamp.
  l_db_id := p_db_id;
  l_original_seed_data_window := to_date('01/01/1990','MM/DD/YYYY');
  if ((l_db_id in (0,1)) and (p_db_lud = trunc(p_db_lud)) and
      (p_db_lud > l_original_seed_data_window)) then
    l_db_id := 2;
  end if;

  if (l_file_id in (0,1)) then
    -- File owner is old FNDLOAD.
    if (l_db_id in (0,1)) then
      -- DB owner is also old FNDLOAD.
      -- Over-write, but only if file ludate >= db ludate.
      if (p_file_lud >= p_db_lud) then
        retcode := TRUE;
      else
        retcode := FALSE;
      end if;
    else
      retcode := FALSE;
    end if;
  elsif (l_file_id = 2) then
    -- File owner is new FNDLOAD.  Over-write if:
    -- 1. Db owner is old FNDLOAD, or
    -- 2. Db owner is new FNDLOAD, and file date >= db date
    if ((l_db_id in (0,1)) or
	((l_db_id = 2) and (p_file_lud >= p_db_lud))) then
      retcode :=  TRUE;
    else
      retcode := FALSE;
    end if;
  else
    -- File owner is USER.  Over-write if:
    -- 1. Db owner is old or new FNDLOAD, or
    -- 2. File date >= db date
    if ((l_db_id in (0,1,2)) or
	(p_file_lud >= p_db_lud)) then
      retcode := TRUE;
    else
      retcode := FALSE;
    end if;
  end if;

  return retcode;
end UPLOAD_TEST;


PROCEDURE INSERT_ROW (
  X_ROWID IN OUT  NOCOPY VARCHAR2 ,
  P_APPLICATION_ID IN NUMBER,
  P_OBJECT_NAME IN VARCHAR2,
  P_OBJECT_TYPE IN VARCHAR2,
  P_TABLESPACE_TYPE IN VARCHAR2,
  P_CUSTOM_TABLESPACE_TYPE IN VARCHAR2 DEFAULT NULL,
  P_OBJECT_SOURCE   IN  VARCHAR2 DEFAULT NULL,
  P_ORACLE_USERNAME  IN VARCHAR2 DEFAULT NULL,
  P_CUSTOM_FLAG IN VARCHAR2 DEFAULT NULL,
  P_CREATION_DATE IN DATE DEFAULT NULL,
  P_CREATED_BY IN NUMBER DEFAULT NULL,
  P_LAST_UPDATE_DATE IN DATE DEFAULT NULL,
  P_LAST_UPDATED_BY IN NUMBER DEFAULT NULL,
  P_LAST_UPDATE_LOGIN IN NUMBER DEFAULT NULL
) is
  cursor C is
    select ROWID from fnd_object_tablespaces
    where application_id = p_application_id
    and  object_name = p_object_name;
  CURSOR c1 IS
    select fou.oracle_username
    from fnd_oracle_userid fou,
         fnd_product_installations fpi
    where fou.oracle_id = fpi.oracle_id
    and fpi.application_id = p_application_id;
  l_schema       FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;
BEGIN
   if p_oracle_username IS NULL then
     OPEN c1;
     FETCH c1 INTO l_schema;
     CLOSE c1;
   end if;

   insert into FND_OBJECT_TABLESPACES (
     APPLICATION_ID,
     OBJECT_NAME,
     OBJECT_TYPE,
     TABLESPACE_TYPE,
     CUSTOM_TABLESPACE_TYPE,
     OBJECT_SOURCE ,
     ORACLE_USERNAME,
     CUSTOM_FLAG ,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
  ) values (
     P_APPLICATION_ID,
     P_OBJECT_NAME,
     P_OBJECT_TYPE,
     P_TABLESPACE_TYPE,
     P_CUSTOM_TABLESPACE_TYPE,
     P_OBJECT_SOURCE ,
     NVL(P_ORACLE_USERNAME, l_schema),
     P_CUSTOM_FLAG ,
     NVL(P_CREATION_DATE, sysdate),
     NVL(P_CREATED_BY, -1),
     NVL(P_LAST_UPDATE_DATE, sysdate),
     NVL(P_LAST_UPDATED_BY, -1),
     NVL(P_LAST_UPDATE_LOGIN, -1)
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;


PROCEDURE UPDATE_ROW (
  P_APPLICATION_ID in NUMBER,
  P_OBJECT_NAME in VARCHAR2,
  P_OBJECT_TYPE in VARCHAR2,
  P_TABLESPACE_TYPE in VARCHAR2 DEFAULT NULL,
  P_CUSTOM_TABLESPACE_TYPE in VARCHAR2 DEFAULT NULL,
  P_OBJECT_SOURCE   in  VARCHAR2 DEFAULT NULL,
  P_ORACLE_USERNAME  in VARCHAR2 DEFAULT NULL,
  P_CUSTOM_FLAG in VARCHAR2 DEFAULT NULL,
  P_LAST_UPDATE_DATE in DATE DEFAULT NULL,
  P_LAST_UPDATED_BY in NUMBER DEFAULT NULL,
  P_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL
  ) is
BEGIN
 update FND_OBJECT_TABLESPACES set
    OBJECT_TYPE = decode(P_OBJECT_TYPE, NULL, OBJECT_TYPE, p_OBJECT_TYPE),
    TABLESPACE_TYPE = decode(P_TABLESPACE_TYPE, NULL, TABLESPACE_TYPE, p_TABLESPACE_TYPE),
    CUSTOM_TABLESPACE_TYPE = decode(P_CUSTOM_TABLESPACE_TYPE, NULL,  CUSTOM_TABLESPACE_TYPE, p_CUSTOM_TABLESPACE_TYPE),
    OBJECT_SOURCE = decode(P_OBJECT_SOURCE, NULL,  OBJECT_SOURCE, p_OBJECT_SOURCE),
    ORACLE_USERNAME = decode(P_ORACLE_USERNAME, NULL, ORACLE_USERNAME, p_ORACLE_USERNAME),
    CUSTOM_FLAG =  decode(P_CUSTOM_FLAG, NULL, CUSTOM_FLAG, p_CUSTOM_FLAG),
    LAST_UPDATE_DATE = decode(P_LAST_UPDATE_DATE, NULL, sysdate, p_LAST_UPDATE_DATE),
    LAST_UPDATED_BY = decode(P_LAST_UPDATED_BY, NULL, -1, p_LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = decode(P_LAST_UPDATE_LOGIN, NULL, -1, p_LAST_UPDATE_LOGIN)
  where APPLICATION_ID = P_APPLICATION_ID
  and OBJECT_NAME = P_OBJECT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;

/* Overloaded version below */
PROCEDURE LOAD_ROW (
   P_APPLICATION_ID in number,
   P_OBJECT_NAME in VARCHAR2,
   P_OBJECT_TYPE in VARCHAR2,
   P_TABLESPACE_TYPE in VARCHAR2,
   P_CUSTOM_TABLESPACE_TYPE in VARCHAR2,
   P_OBJECT_SOURCE   in  VARCHAR2,
   P_ORACLE_USERNAME  in VARCHAR2,
   P_CUSTOM_FLAG in VARCHAR2,
   P_CUSTOM_MODE  in VARCHAR2
) is
BEGIN
  FND_OBJECT_TABLESPACES_PKG.LOAD_ROW (
   P_APPLICATION_ID => P_APPLICATION_ID ,
   P_OBJECT_NAME => P_OBJECT_NAME,
   P_OBJECT_TYPE =>  P_OBJECT_TYPE,
   P_TABLESPACE_TYPE => P_TABLESPACE_TYPE,
   P_CUSTOM_TABLESPACE_TYPE => P_CUSTOM_TABLESPACE_TYPE,
   P_OBJECT_SOURCE  =>  P_OBJECT_SOURCE,
   P_ORACLE_USERNAME =>  P_ORACLE_USERNAME,
   P_CUSTOM_FLAG =>  P_CUSTOM_FLAG,
   P_LAST_UPDATED_BY => null,
   P_CUSTOM_MODE => P_CUSTOM_MODE,
   P_LAST_UPDATE_DATE => null
  );
END LOAD_ROW;

  /* Overloaded version above */
PROCEDURE LOAD_ROW (
 P_APPLICATION_ID in NUMBER,
 P_OBJECT_NAME in VARCHAR2,
 P_OBJECT_TYPE in VARCHAR2,
 P_TABLESPACE_TYPE in VARCHAR2,
 P_CUSTOM_TABLESPACE_TYPE in VARCHAR2,
 P_OBJECT_SOURCE   in  VARCHAR2,
 P_ORACLE_USERNAME  in VARCHAR2,
 P_CUSTOM_FLAG in VARCHAR2,
 P_LAST_UPDATED_BY in VARCHAR2,
 P_CUSTOM_MODE in VARCHAR2,
 P_LAST_UPDATE_DATE in VARCHAR2
 ) is
  row_id  VARCHAR2(4000);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
BEGIN
  -- Translate owner to file_last_updated_by
  f_luby := owner_id(P_LAST_UPDATED_BY);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(P_last_update_date, 'YYYY/MM/DD'), sysdate);

  select last_updated_by, last_update_date
  into  db_luby, db_ludate
  from FND_OBJECT_TABLESPACES
  where application_id = p_application_id
  and   object_name = p_object_name;

  if (upload_test(f_luby, f_ludate, db_luby,db_ludate,
                                p_custom_mode)) then
    FND_OBJECT_TABLESPACES_PKG.UPDATE_ROW (
        P_APPLICATION_ID            => P_application_id,
        P_OBJECT_NAME               => P_OBJECT_NAME,
        P_OBJECT_TYPE               => P_OBJECT_TYPE,
        P_TABLESPACE_TYPE           => P_TABLESPACE_TYPE,
        P_CUSTOM_TABLESPACE_TYPE    => P_CUSTOM_TABLESPACE_TYPE,
        P_OBJECT_SOURCE             => P_OBJECT_SOURCE ,
        P_ORACLE_USERNAME           => P_ORACLE_USERNAME ,
        P_CUSTOM_FLAG               => P_CUSTOM_FLAG,
        P_LAST_UPDATE_DATE          => f_ludate,
        P_LAST_UPDATED_BY           => f_luby,
        P_LAST_UPDATE_LOGIN         => -1 );
  end if;
EXCEPTION
  when NO_DATA_FOUND then
    FND_OBJECT_TABLESPACES_PKG.INSERT_ROW(
      X_ROWID => row_id,
      P_APPLICATION_ID         => P_APPLICATION_ID,
      P_OBJECT_NAME            => P_OBJECT_NAME,
      P_OBJECT_TYPE            => P_OBJECT_TYPE,
      P_TABLESPACE_TYPE        => P_TABLESPACE_TYPE,
      P_CUSTOM_TABLESPACE_TYPE => P_CUSTOM_TABLESPACE_TYPE,
      P_OBJECT_SOURCE          => P_OBJECT_SOURCE ,
      P_ORACLE_USERNAME        => P_ORACLE_USERNAME ,
      P_CUSTOM_FLAG            => P_CUSTOM_FLAG,
      P_CREATION_DATE          => f_ludate,
      P_CREATED_BY             => f_luby,
      P_LAST_UPDATE_DATE       => f_ludate,
      P_LAST_UPDATED_BY        => f_luby,
      P_LAST_UPDATE_LOGIN      => -1 );
END LOAD_ROW;

PROCEDURE DELETE_ROW (
  P_APPLICATION_ID in NUMBER,
  P_OBJECT_NAME in VARCHAR2,
  P_OBJECT_TYPE in VARCHAR2
 ) is
BEGIN
  delete from FND_OBJECT_TABLESPACES
  where APPLICATION_ID = P_APPLICATION_ID
  and OBJECT_NAME  = P_OBJECT_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END DELETE_ROW;

END FND_OBJECT_TABLESPACES_PKG;

/
