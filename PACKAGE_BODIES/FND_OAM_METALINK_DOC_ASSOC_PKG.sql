--------------------------------------------------------
--  DDL for Package Body FND_OAM_METALINK_DOC_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_METALINK_DOC_ASSOC_PKG" as
/* $Header: AFOAMMDAB.pls 120.0 2005/08/05 01:05:30 appldev noship $ */
procedure LOAD_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_CATEGORY_KEY in VARCHAR2,
    X_CATEGORY_TYPE in VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_ANCHOR in VARCHAR2) is
  begin

    begin
      fnd_oam_metalink_doc_assoc_pkg.UPDATE_ROW(
        X_DOC_ID => X_DOC_ID,
        X_CATEGORY_KEY => X_CATEGORY_KEY,
        X_CATEGORY_TYPE  => X_CATEGORY_TYPE,
        X_CREATED_BY => X_CREATED_BY,
        X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN,
        X_ANCHOR => X_ANCHOR);

     exception
       when NO_DATA_FOUND then

       fnd_oam_metalink_doc_assoc_pkg.INSERT_ROW(
         X_DOC_ID => X_DOC_ID,
         X_CATEGORY_KEY => X_CATEGORY_KEY,
         X_CATEGORY_TYPE  => X_CATEGORY_TYPE,
         X_CREATED_BY => X_CREATED_BY,
         X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
         X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN,
         X_ANCHOR => X_ANCHOR);

    end;

    commit;

end LOAD_ROW;




procedure UPDATE_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_CATEGORY_KEY     in   VARCHAR2,
    X_CATEGORY_TYPE  in  VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_ANCHOR in VARCHAR2 ) is

      db_id varchar2(40);
  begin

    select doc_id into db_id from FND_OAM_METALINK_DOC_ASSOC
       where doc_id = X_DOC_ID
          and category_key = X_CATEGORY_KEY
          and category_type = X_CATEGORY_TYPE ;

    update FND_OAM_METALINK_DOC_ASSOC SET
        doc_id = X_DOC_ID,
        category_key  = X_CATEGORY_KEY,
        category_TYPE  = X_CATEGORY_TYPE,
        created_by = X_CREATED_BY,
        creation_date = sysdate,
        last_update_date = sysdate,
        last_updated_by = X_LAST_UPDATED_BY,
        last_update_login = X_LAST_UPDATE_LOGIN,
        anchor = X_ANCHOR
      where doc_id = X_DOC_ID
            and category_key = X_CATEGORY_KEY
            and category_type = X_CATEGORY_TYPE ;

end UPDATE_ROW;

procedure INSERT_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_CATEGORY_KEY     in   VARCHAR2,
    X_CATEGORY_TYPE  in  VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_ANCHOR in VARCHAR2 ) is

  begin
    insert into FND_OAM_METALINK_DOC_ASSOC (
      doc_id,
      category_key,
      category_type,
      created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login,
      anchor
    ) values (
      X_DOC_ID,
      X_CATEGORY_KEY,
      X_CATEGORY_TYPE,
      X_CREATED_BY,
      sysdate,
      sysdate,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_ANCHOR);

end INSERT_ROW;

end FND_OAM_METALINK_DOC_ASSOC_PKG;

/
