--------------------------------------------------------
--  DDL for Package Body AMS_MET_TPL_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MET_TPL_HEADERS_PKG" as
/* $Header: amslmthb.pls 115.1 2000/01/09 17:55:04 pkm ship     $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_METRIC_TPL_HEADER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_METRIC_TPL_HEADER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ARC_ACT_METRIC_USED_BY in VARCHAR2,
  X_ACT_METRIC_USED_BY_TYPE in VARCHAR2,
  X_ACT_METRIC_USED_BY_SUBTYPE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_MET_TPL_HEADERS
    where METRIC_TPL_HEADER_ID = X_METRIC_TPL_HEADER_ID;
begin
  insert into AMS_MET_TPL_HEADERS (
    METRIC_TPL_HEADER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    METRIC_TPL_HEADER_NAME,
    DESCRIPTION,
    ARC_ACT_METRIC_USED_BY,
    ACT_METRIC_USED_BY_TYPE,
    ACT_METRIC_USED_BY_SUBTYPE
  ) values(
    X_METRIC_TPL_HEADER_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_METRIC_TPL_HEADER_NAME,
    X_DESCRIPTION,
    X_ARC_ACT_METRIC_USED_BY,
    X_ACT_METRIC_USED_BY_TYPE,
    X_ACT_METRIC_USED_BY_SUBTYPE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_METRIC_TPL_HEADER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_METRIC_TPL_HEADER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ARC_ACT_METRIC_USED_BY in VARCHAR2,
  X_ACT_METRIC_USED_BY_TYPE in VARCHAR2,
  X_ACT_METRIC_USED_BY_SUBTYPE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_MET_TPL_HEADERS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    METRIC_TPL_HEADER_NAME = X_METRIC_TPL_HEADER_NAME,
    DESCRIPTION = X_DESCRIPTION,
    ARC_ACT_METRIC_USED_BY = X_ARC_ACT_METRIC_USED_BY,
    ACT_METRIC_USED_BY_TYPE = X_ACT_METRIC_USED_BY_TYPE,
    ACT_METRIC_USED_BY_SUBTYPE = X_ACT_METRIC_USED_BY_SUBTYPE,
    METRIC_TPL_HEADER_ID = X_METRIC_TPL_HEADER_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where METRIC_TPL_HEADER_ID = X_METRIC_TPL_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_METRIC_TPL_HEADER_ID in NUMBER
) is
begin
  delete from AMS_MET_TPL_HEADERS
  where METRIC_TPL_HEADER_ID = X_METRIC_TPL_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_METRIC_TPL_HEADER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_METRIC_TPL_HEADER_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ARC_ACT_METRIC_USED_BY in VARCHAR2,
  X_ACT_METRIC_USED_BY_TYPE in VARCHAR2,
  X_ACT_METRIC_USED_BY_SUBTYPE in VARCHAR2,
  X_Owner              VARCHAR2
  )is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_met_tpl_hdr_id   number;

cursor  c_obj_verno is
  select object_version_number
  from    AMS_MET_TPL_HEADERS
  where  METRIC_TPL_HEADER_ID =  X_METRIC_TPL_HEADER_ID;

cursor c_chk_mth_exists is
  select 'x'
  from    AMS_MET_TPL_HEADERS
  where  METRIC_TPL_HEADER_ID =  X_METRIC_TPL_HEADER_ID;

cursor c_get_mthid is
   select AMS_MET_TPL_HEADERS_ALL_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_mth_exists;
 fetch c_chk_mth_exists into l_dummy_char;
 if c_chk_mth_exists%notfound
 then
    close c_chk_mth_exists;
    if X_METRIC_TPL_HEADER_ID is null
    then
      open c_get_mthid;
      fetch c_get_mthid into l_met_tpl_hdr_id;
      close c_get_mthid;
    else
       l_met_tpl_hdr_id := X_METRIC_TPL_HEADER_ID;
    end if;
    l_obj_verno := 1;
    AMS_MET_TPL_HEADERS_PKG.INSERT_ROW(
	  X_ROWID   =>   l_row_id,
	  X_METRIC_TPL_HEADER_ID  =>  l_met_tpl_hdr_id,
	  X_OBJECT_VERSION_NUMBER  => l_obj_verno,
	  X_METRIC_TPL_HEADER_NAME  => X_METRIC_TPL_HEADER_NAME,
	  X_DESCRIPTION  => X_DESCRIPTION,
	  X_ARC_ACT_METRIC_USED_BY  => X_ARC_ACT_METRIC_USED_BY,
	  X_ACT_METRIC_USED_BY_TYPE  => X_ACT_METRIC_USED_BY_TYPE,
	  X_ACT_METRIC_USED_BY_SUBTYPE  => X_ACT_METRIC_USED_BY_SUBTYPE,
	  X_CREATION_DATE		=>  SYSDATE,
	  X_CREATED_BY	=>  l_user_id,
	  X_LAST_UPDATE_DATE	=>  SYSDATE,
	  X_LAST_UPDATED_BY =>  l_user_id,
	  X_LAST_UPDATE_LOGIN =>  0
	  );
else
   close c_chk_mth_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
    AMS_MET_TPL_HEADERS_PKG.UPDATE_ROW(
	  X_METRIC_TPL_HEADER_ID  =>  X_METRIC_TPL_HEADER_ID,
	  X_OBJECT_VERSION_NUMBER  => l_obj_verno + 1,
	  X_METRIC_TPL_HEADER_NAME  => X_METRIC_TPL_HEADER_NAME,
	  X_DESCRIPTION  => X_DESCRIPTION,
	  X_ARC_ACT_METRIC_USED_BY  => X_ARC_ACT_METRIC_USED_BY,
	  X_ACT_METRIC_USED_BY_TYPE  => X_ACT_METRIC_USED_BY_TYPE,
	  X_ACT_METRIC_USED_BY_SUBTYPE  => X_ACT_METRIC_USED_BY_SUBTYPE,
	  X_LAST_UPDATE_DATE	=>  SYSDATE,
	  X_LAST_UPDATED_BY =>  l_user_id,
	  X_LAST_UPDATE_LOGIN =>  0
	  );

end if;

END LOAD_ROW;

end AMS_MET_TPL_HEADERS_PKG;

/
