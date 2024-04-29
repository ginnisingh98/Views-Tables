--------------------------------------------------------
--  DDL for Package Body FND_LOOKUP_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOOKUP_ASSIGNMENTS_PKG" as
/* $Header: AFLVFLAB.pls 115.0 2004/08/04 21:03:35 stopiwal noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LOOKUP_ASSIGNMENT_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_LOOKUP_ASSIGNMENTS
    where LOOKUP_ASSIGNMENT_ID = X_LOOKUP_ASSIGNMENT_ID
    ;
begin
  insert into FND_LOOKUP_ASSIGNMENTS (
    LOOKUP_ASSIGNMENT_ID,
    INSTANCE_PK1_VALUE,
    OBJ_NAME,
    INSTANCE_PK4_VALUE,
    INSTANCE_PK5_VALUE,
    DISPLAY_SEQUENCE,
    LOOKUP_CODE,
    LOOKUP_TYPE,
    INSTANCE_PK2_VALUE,
    INSTANCE_PK3_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOOKUP_ASSIGNMENT_ID,
    X_INSTANCE_PK1_VALUE,
    X_OBJ_NAME,
    X_INSTANCE_PK4_VALUE,
    X_INSTANCE_PK5_VALUE,
    X_DISPLAY_SEQUENCE,
    X_LOOKUP_CODE,
    X_LOOKUP_TYPE,
    X_INSTANCE_PK2_VALUE,
    X_INSTANCE_PK3_VALUE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_LOOKUP_ASSIGNMENT_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2
) is
  cursor c is select
      INSTANCE_PK1_VALUE,
      OBJ_NAME,
      INSTANCE_PK4_VALUE,
      INSTANCE_PK5_VALUE,
      DISPLAY_SEQUENCE,
      LOOKUP_CODE,
      LOOKUP_TYPE,
      INSTANCE_PK2_VALUE,
      INSTANCE_PK3_VALUE
    from FND_LOOKUP_ASSIGNMENTS
    where LOOKUP_ASSIGNMENT_ID = X_LOOKUP_ASSIGNMENT_ID
    for update of LOOKUP_ASSIGNMENT_ID nowait;
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
  if (    (recinfo.INSTANCE_PK1_VALUE = X_INSTANCE_PK1_VALUE)
      AND (recinfo.OBJ_NAME = X_OBJ_NAME)
      AND ((recinfo.INSTANCE_PK4_VALUE = X_INSTANCE_PK4_VALUE)
           OR ((recinfo.INSTANCE_PK4_VALUE is null) AND (X_INSTANCE_PK4_VALUE is null)))
      AND ((recinfo.INSTANCE_PK5_VALUE = X_INSTANCE_PK5_VALUE)
           OR ((recinfo.INSTANCE_PK5_VALUE is null) AND (X_INSTANCE_PK5_VALUE is null)))
      AND ((recinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
           OR ((recinfo.DISPLAY_SEQUENCE is null) AND (X_DISPLAY_SEQUENCE is null)))
      AND (recinfo.LOOKUP_CODE = X_LOOKUP_CODE)
      AND (recinfo.LOOKUP_TYPE = X_LOOKUP_TYPE)
      AND ((recinfo.INSTANCE_PK2_VALUE = X_INSTANCE_PK2_VALUE)
           OR ((recinfo.INSTANCE_PK2_VALUE is null) AND (X_INSTANCE_PK2_VALUE is null)))
      AND ((recinfo.INSTANCE_PK3_VALUE = X_INSTANCE_PK3_VALUE)
           OR ((recinfo.INSTANCE_PK3_VALUE is null) AND (X_INSTANCE_PK3_VALUE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LOOKUP_ASSIGNMENT_ID in NUMBER,
  X_INSTANCE_PK1_VALUE in VARCHAR2,
  X_OBJ_NAME in VARCHAR2,
  X_INSTANCE_PK4_VALUE in VARCHAR2,
  X_INSTANCE_PK5_VALUE in VARCHAR2,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_LOOKUP_CODE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_INSTANCE_PK2_VALUE in VARCHAR2,
  X_INSTANCE_PK3_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_LOOKUP_ASSIGNMENTS set
    INSTANCE_PK1_VALUE = X_INSTANCE_PK1_VALUE,
    OBJ_NAME = X_OBJ_NAME,
    INSTANCE_PK4_VALUE = X_INSTANCE_PK4_VALUE,
    INSTANCE_PK5_VALUE = X_INSTANCE_PK5_VALUE,
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    LOOKUP_CODE = X_LOOKUP_CODE,
    LOOKUP_TYPE = X_LOOKUP_TYPE,
    INSTANCE_PK2_VALUE = X_INSTANCE_PK2_VALUE,
    INSTANCE_PK3_VALUE = X_INSTANCE_PK3_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOOKUP_ASSIGNMENT_ID = X_LOOKUP_ASSIGNMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOOKUP_ASSIGNMENT_ID in NUMBER
) is
begin
  delete from FND_LOOKUP_ASSIGNMENTS
  where LOOKUP_ASSIGNMENT_ID = X_LOOKUP_ASSIGNMENT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure Load_Row (
  x_lookup_type           in varchar2,
  x_lookup_code           in varchar2,
  x_obj_name              in varchar2,
  x_display_sequence      in varchar2,
  X_INSTANCE_PK1_VALUE    in varchar2,
  X_INSTANCE_PK2_VALUE    in varchar2,
  X_INSTANCE_PK3_VALUE    in varchar2,
  X_INSTANCE_PK4_VALUE    in varchar2,
  X_INSTANCE_PK5_VALUE    in varchar2,
  x_last_update_date      in varchar2,
  x_owner                 in varchar2,
  x_custom_mode           in varchar2)
is
  row_id varchar2(64);
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  db_luid   number;  -- entity key in db

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

    -- check the db last update fields for each record in the cursor
    begin
    select Lookup_assignment_id, LAST_UPDATED_BY, LAST_UPDATE_DATE
    into db_luid, db_luby, db_ludate
    from fnd_lookup_assignments
    where LOOKUP_TYPE        = X_LOOKUP_TYPE
    and OBJ_NAME             = x_obj_name
    and INSTANCE_PK1_VALUE = X_INSTANCE_PK1_VALUE
    and LOOKUP_CODE          = X_LOOKUP_CODE;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
      Fnd_lookup_assignments_Pkg.Update_Row (
        X_LOOKUP_ASSIGNMENT_ID  => db_luid,
        X_LOOKUP_TYPE           => x_lookup_type,
        X_LOOKUP_CODE           => x_lookup_code,
        X_OBJ_NAME              => x_obj_name,
        X_INSTANCE_PK1_VALUE    => x_instance_pk1_value,
        X_INSTANCE_PK2_VALUE    => x_instance_pk2_value,
        X_INSTANCE_PK3_VALUE    => x_instance_pk3_value,
        X_INSTANCE_PK4_VALUE    => x_instance_pk4_value,
        X_INSTANCE_PK5_VALUE    => x_instance_pk5_value,
        X_DISPLAY_SEQUENCE      => TO_NUMBER(x_display_sequence),
        X_LAST_UPDATE_DATE      => f_ludate,
        X_LAST_UPDATED_BY       => f_luby,
        X_LAST_UPDATE_LOGIN     => 0);
    end if;

    exception
      when no_data_found then
        select FND_LOOKUP_ASSIGNMENTS_S.NEXTVAL
        into db_luid
        from dual;

        Fnd_lookup_assignments_Pkg.Insert_Row(
          X_ROWID                => row_id,
          X_LOOKUP_ASSIGNMENT_ID  => db_luid,
          X_LOOKUP_TYPE           => x_lookup_type,
          X_LOOKUP_CODE           => x_lookup_code,
          X_OBJ_NAME              => x_obj_name,
          X_INSTANCE_PK1_VALUE    => x_instance_pk1_value,
          X_INSTANCE_PK2_VALUE    => x_instance_pk2_value,
          X_INSTANCE_PK3_VALUE    => x_instance_pk3_value,
          X_INSTANCE_PK4_VALUE    => x_instance_pk4_value,
          X_INSTANCE_PK5_VALUE    => x_instance_pk5_value,
          X_DISPLAY_SEQUENCE      => TO_NUMBER(x_display_sequence),
          X_CREATION_DATE         => f_ludate,
          X_CREATED_BY            => f_luby,
          X_LAST_UPDATE_DATE      => f_ludate,
          X_LAST_UPDATED_BY       => f_luby,
          X_LAST_UPDATE_LOGIN     => 0);

    end;

end Load_Row;

end FND_LOOKUP_ASSIGNMENTS_PKG;

/
