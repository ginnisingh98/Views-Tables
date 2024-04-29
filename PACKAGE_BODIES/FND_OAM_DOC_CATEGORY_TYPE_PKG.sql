--------------------------------------------------------
--  DDL for Package Body FND_OAM_DOC_CATEGORY_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DOC_CATEGORY_TYPE_PKG" AS
  /* $Header: AFOAMDCTB.pls 120.2 2005/10/19 10:40:56 ilawler noship $ */
  procedure LOAD_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_OWNER               in  VARCHAR2) is
  begin
     fnd_oam_doc_category_type_pkg.LOAD_ROW (
       X_CATEGORY_TYPE => X_CATEGORY_TYPE,
       X_CATEGORY_TYPE_NAME => X_CATEGORY_TYPE_NAME,
       X_CATALOG_DOC_ID => X_CATALOG_DOC_ID,
       X_CATALOG_ATTCH_ID => X_CATALOG_ATTCH_ID,
       X_OWNER => X_OWNER,
       x_custom_mode => '',
       x_last_update_date => '');
  end LOAD_ROW;

  procedure LOAD_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_OWNER               in  VARCHAR2,
    x_custom_mode         in  varchar2,
    x_last_update_date    in  varchar2) is

      v_category_type fnd_oam_doc_category_type.category_type%TYPE;
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db

      cursor c1 is
        select last_updated_by, last_update_date
        from fnd_oam_doc_category_type
        where category_type = X_CATEGORY_TYPE
        order by last_update_date asc;
    begin
      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(x_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      begin

        select category_type, LAST_UPDATED_BY, LAST_UPDATE_DATE
         into v_category_type, db_luby, db_ludate
         from   fnd_oam_doc_category_type
         where  category_type = X_CATEGORY_TYPE;

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        fnd_oam_doc_category_type_pkg.UPDATE_ROW (
          X_CATEGORY_TYPE => v_category_type,
          X_CATEGORY_TYPE_NAME => X_CATEGORY_TYPE_NAME,
          X_CATALOG_DOC_ID => X_CATALOG_DOC_ID,
          X_CATALOG_ATTCH_ID => X_CATALOG_ATTCH_ID,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
        end if;
      exception
        when NO_DATA_FOUND then

        fnd_oam_doc_category_type_pkg.INSERT_ROW (
          X_ROWID => row_id,
          X_CATEGORY_TYPE => X_CATEGORY_TYPE,
          X_CATEGORY_TYPE_NAME => X_CATEGORY_TYPE_NAME,
          X_CATALOG_DOC_ID => X_CATALOG_DOC_ID,
          X_CATALOG_ATTCH_ID => X_CATALOG_ATTCH_ID,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;
  end LOAD_ROW;

  procedure INSERT_ROW (
    X_ROWID               IN OUT NOCOPY VARCHAR2,
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_CREATED_BY          in  NUMBER,
    X_CREATION_DATE       in  DATE,
    X_LAST_UPDATED_BY     in  NUMBER,
    X_LAST_UPDATE_DATE    in  DATE,
    X_LAST_UPDATE_LOGIN   in  NUMBER)
  is
    cursor C is select ROWID from FND_OAM_DOC_CATEGORY_TYPE
      where CATEGORY_TYPE = X_CATEGORY_TYPE;
  begin
    insert into FND_OAM_DOC_CATEGORY_TYPE (
      CATEGORY_TYPE,
      CATEGORY_TYPE_NAME,
      CATALOG_DOC_ID,
      CATALOG_ATTCH_ID,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    ) values (
      X_CATEGORY_TYPE,
      X_CATEGORY_TYPE_NAME,
      X_CATALOG_DOC_ID,
      X_CATALOG_ATTCH_ID,
      X_CREATED_BY,
      X_CREATION_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATE_LOGIN);

    open c;
    fetch c into X_ROWID;
    if (c%notfound) then
      close c;
      raise no_data_found;
    end if;
    close c;
  END INSERT_ROW;

  procedure UPDATE_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_LAST_UPDATE_DATE    in  DATE,
    X_LAST_UPDATED_BY     in  NUMBER,
    X_LAST_UPDATE_LOGIN   in  NUMBER) is
  begin
    update FND_OAM_DOC_CATEGORY_TYPE set
      CATEGORY_TYPE_NAME = X_CATEGORY_TYPE_NAME,
      CATALOG_DOC_ID = X_CATALOG_DOC_ID,
      CATALOG_ATTCH_ID = X_CATALOG_ATTCH_ID,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where CATEGORY_TYPE = X_CATEGORY_TYPE;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end UPDATE_ROW;

  procedure DELETE_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2) is
  begin
    delete from FND_OAM_DOC_CATEGORY_TYPE
    where CATEGORY_TYPE = X_CATEGORY_TYPE;

    if (sql%notfound) then
      raise no_data_found;
    end if;
  end DELETE_ROW;

END fnd_oam_doc_category_type_pkg;

/
