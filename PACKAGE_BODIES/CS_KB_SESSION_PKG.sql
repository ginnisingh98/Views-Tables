--------------------------------------------------------
--  DDL for Package Body CS_KB_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SESSION_PKG" AS
/* $Header: cskbsesb.pls 120.0 2005/06/01 10:14:37 appldev noship $ */

  procedure INSERT_ROW
  (
    X_ROWID                OUT NOCOPY VARCHAR2,
    X_SESSION_ID           OUT NOCOPY NUMBER,
    P_SOURCE_OBJECT_CODE    in VARCHAR2,
    P_SOURCE_OBJECT_ID      in NUMBER,
    P_CREATION_DATE         in DATE,
    P_CREATED_BY            in NUMBER,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  )
  is
    cursor getNewSessionIdCsr is
      select cs_kb_sessions_s.nextval
      from dual;

    cursor verifyRowCursor is
      select ROWID
      from CS_KB_SESSIONS
      where SESSION_ID = X_SESSION_ID;
  begin

    /* Get a new data id */
    OPEN getNewSessionIdCsr;
    FETCH getNewSessionIdCsr INTO X_SESSION_ID;
    CLOSE getNewSessionIdCsr;

    insert into cs_kb_sessions
    (
      session_id,
      source_object_id,
      source_object_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    )
    values
    (
      x_session_id,
      p_source_object_id,
      p_source_object_code,
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
    P_SESSION_ID            in NUMBER,
    P_SOURCE_OBJECT_CODE    in VARCHAR2,
    P_SOURCE_OBJECT_ID      in NUMBER,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  )
  is
  begin
    update cs_kb_sessions
    set
      source_object_id    = p_source_object_id,
      source_object_code  = p_source_object_code,
      last_update_date    = p_last_update_date,
      last_updated_by     = p_last_updated_by,
      last_update_login   = p_last_update_login
    where session_id = P_SESSION_ID;

    if(SQL%NOTFOUND)
    then
      raise NO_DATA_FOUND;
    end if;
  end UPDATE_ROW;

  procedure DELETE_ROW
  (
    P_SESSION_ID               in NUMBER
  )
  is
  begin
    delete from cs_kb_sessions
    where session_id = P_SESSION_ID;
    if(sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;


  procedure LOAD_ROW
  (
    P_SESSION_ID            in NUMBER,
    P_SOURCE_OBJECT_CODE    in VARCHAR2,
    P_SOURCE_OBJECT_ID      in NUMBER,
    P_OWNER                 in VARCHAR2
  )
  is
    l_user_id number;
    l_rowid varchar2(100);
    l_session_id number := p_session_id;
  begin
    if ( p_owner = 'SEED' ) then
      l_user_id := 1;
    else
      l_user_id := 0;
    end if;

    update_row
    (
      p_session_id          => p_session_id,
      p_source_object_code  => p_source_object_code,
      p_source_object_id    => p_source_object_id,
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
        x_session_id          => l_session_id,
        p_source_object_code  => p_source_object_code,
        p_source_object_id    => p_source_object_id,
        p_creation_date       => sysdate,
        p_created_by          => l_user_id,
        p_last_update_date    => sysdate,
        p_last_updated_by     => l_user_id,
        p_last_update_login   => 0
      );

  end LOAD_ROW;


END CS_KB_SESSION_PKG;

/
