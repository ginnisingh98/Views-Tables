--------------------------------------------------------
--  DDL for Package Body CS_KB_SESSION_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SESSION_ATTR_PKG" AS
/* $Header: cskbssab.pls 115.5 2002/12/02 22:41:15 mkettle noship $ */

  /* HIGH LEVEL TABLE HANDLERS */

  function add_km_session_attr
  (
    X_SESSION_ATTR_ID     OUT NOCOPY NUMBER,
    P_SESSION_ID           in NUMBER,
    P_ATTRIBUTE_TYPE       in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1               in VARCHAR2,
    P_VALUE2               in VARCHAR2
  ) return number
  is
    l_rowid varchar2(30);
    l_current_date date;
    l_current_user number;
    l_current_login number;
  begin
    l_current_date := sysdate;
    l_current_user := fnd_global.user_id;
    l_current_login := fnd_global.login_id;
    insert_row
    (
      x_rowid              => l_rowid,
      x_session_attr_id    => x_session_attr_id,
      p_session_id         => p_session_id,
      p_attribute_type     => p_attribute_type,
      p_attribute_name     => p_attribute_name,
      p_value1             => p_value1,
      p_value2             => p_value2,
      p_creation_date      => l_current_date,
      p_created_by         => l_current_user,
      p_last_update_date   => l_current_date,
      p_last_updated_by    => l_current_user,
      p_last_update_login  => l_current_login
    );
    return OKAY_STATUS;
  exception
    when others then
      return ERROR_STATUS;
  end ;

  function update_km_session_attr
  (
    P_SESSION_ATTR_ID      in NUMBER,
    P_SESSION_ID           in NUMBER,
    P_ATTRIBUTE_TYPE       in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1               in VARCHAR2,
    P_VALUE2               in VARCHAR2
  ) return number
  is
    l_current_date date;
    l_current_user number;
    l_current_login number;
  begin
    l_current_date := sysdate;
    l_current_user := fnd_global.user_id;
    l_current_login := fnd_global.login_id;
    update_row
    (
      p_session_attr_id    => p_session_attr_id,
      p_session_id         => p_session_id,
      p_attribute_type     => p_attribute_type,
      p_attribute_name     => p_attribute_name,
      p_value1             => p_value1,
      p_value2             => p_value2,
      p_last_update_date   => l_current_date,
      p_last_updated_by    => l_current_user,
      p_last_update_login  => l_current_login
    );
    return OKAY_STATUS;
  exception
    when others then
      return ERROR_STATUS;
  end ;

  function remove_km_session_attr
  (
    P_SESSION_ATTR_ID      in NUMBER
  ) return number
  is
    l_current_date date;
    l_current_user number;
    l_current_login number;
  begin
    l_current_date := sysdate;
    l_current_user := fnd_global.user_id;
    l_current_login := fnd_global.login_id;
    delete_row
    (
      p_session_attr_id    => p_session_attr_id
    );
    return OKAY_STATUS;
  exception
    when others then
      return ERROR_STATUS;
  end ;

  function remove_all_km_session_attrs
  (
    P_SESSION_ID           in NUMBER
  ) return number
  is
    cursor getSessionAttrIds( c_session_id number ) is
      select session_attr_id
      from cs_kb_session_attrs
      where session_id = c_session_id;
  begin
    for rec in getSessionAttrIds( p_session_id ) loop
      delete_row
      (
        p_session_attr_id => rec.session_attr_id
      );
    end loop;
    return OKAY_STATUS;
  exception
    when others then
      return ERROR_STATUS;
  end ;


  /* LOW LEVEL TABLE HANDLERS */

  procedure INSERT_ROW
  (
    X_ROWID                OUT NOCOPY VARCHAR2,
    X_SESSION_ATTR_ID      OUT NOCOPY NUMBER,
    P_SESSION_ID            in NUMBER,
    P_ATTRIBUTE_TYPE        in VARCHAR2,
    P_ATTRIBUTE_NAME        in VARCHAR2,
    P_VALUE1                in VARCHAR2,
    P_VALUE2                in VARCHAR2,
    P_CREATION_DATE         in DATE,
    P_CREATED_BY            in NUMBER,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  )
  is
    cursor getNewSessionAttrIdCsr is
      select cs_kb_session_attrs_s.nextval
      from dual;

    cursor verifyRowCursor is
      select ROWID
      from CS_KB_SESSION_ATTRS
      where SESSION_ATTR_ID = X_SESSION_ATTR_ID;
  begin

    /* Get a new data id */
    OPEN getNewSessionAttrIdCsr;
    FETCH getNewSessionAttrIdCsr INTO X_SESSION_ATTR_ID;
    CLOSE getNewSessionAttrIdCsr;

    insert into cs_kb_session_attrs
    (
      session_attr_id,
      session_id,
      attribute_type,
      attribute_name,
      value1,
      value2,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    )
    values
    (
      x_session_attr_id,
      p_session_id,
      p_attribute_type,
      p_attribute_name,
      p_value1,
      p_value2,
      p_creation_date,
      p_created_by,
      p_last_update_date,
      p_last_updated_by,
      p_last_update_login
    );

    OPEN verifyRowCursor;
    FETCH verifyRowCursor INTO x_rowid;
    IF ( verifyRowCursor%NOTFOUND)
    THEN
      CLOSE verifyRowCursor;
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE verifyRowCursor;
    END IF;

  end INSERT_ROW;

  procedure UPDATE_ROW
  (
    P_SESSION_ATTR_ID       in NUMBER,
    P_SESSION_ID            in NUMBER,
    P_ATTRIBUTE_TYPE        in VARCHAR2,
    P_ATTRIBUTE_NAME        in VARCHAR2,
    P_VALUE1                in VARCHAR2,
    P_VALUE2                in VARCHAR2,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  )
  is
  begin
    update cs_kb_session_attrs
    set
      session_id          = p_session_id,
      attribute_type      = p_attribute_type,
      attribute_name      = p_attribute_name,
      value1              = p_value1,
      value2              = p_value2,
      last_update_date    = p_last_update_date,
      last_updated_by     = p_last_updated_by,
      last_update_login   = p_last_update_login
    where session_attr_id = P_SESSION_ATTR_ID;

    if(SQL%NOTFOUND)
    then
      raise NO_DATA_FOUND;
    end if;
  end UPDATE_ROW;

  procedure DELETE_ROW
  (
    P_SESSION_ATTR_ID       in NUMBER
  )
  is
  begin
    delete from cs_kb_session_attrs
    where session_attr_id = P_SESSION_ATTR_ID;
    if(sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;


  procedure LOAD_ROW
  (
    P_SESSION_ATTR_ID       in NUMBER,
    P_SESSION_ID            in NUMBER,
    P_ATTRIBUTE_TYPE        in VARCHAR2,
    P_ATTRIBUTE_NAME        in VARCHAR2,
    P_VALUE1                in VARCHAR2,
    P_VALUE2                in VARCHAR2,
    P_OWNER                 in VARCHAR2
  )
  is
    l_user_id number;
    l_rowid varchar2(100);
    l_session_attr_id number := p_session_attr_id;
  begin
    if ( p_owner = 'SEED' ) then
      l_user_id := 1;
    else
      l_user_id := 0;
    end if;

    update_row
    (
      p_session_attr_id     => p_session_attr_id,
      p_session_id          => p_session_id,
      p_attribute_type      => p_attribute_type,
      p_attribute_name      => p_attribute_name,
      p_value1              => p_value1,
      p_value2              => p_value2,
      p_last_update_date    => sysdate,
      p_last_updated_by     => l_user_id,
      p_last_update_login   => 0
    );

  exception
    when no_data_found
    then
      insert_row
      (
        x_rowid               => l_rowid,
        x_session_attr_id     => l_session_attr_id,
        p_session_id          => p_session_id,
        p_attribute_type      => p_attribute_type,
        p_attribute_name      => p_attribute_name,
        p_value1              => p_value1,
        p_value2              => p_value2,
        p_creation_date       => sysdate,
        p_created_by          => l_user_id,
        p_last_update_date    => sysdate,
        p_last_updated_by     => l_user_id,
        p_last_update_login   => 0
      );

  end LOAD_ROW;


END CS_KB_SESSION_ATTR_PKG;

/
