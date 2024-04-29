--------------------------------------------------------
--  DDL for Package Body FND_OAM_DOC_CATEGORY_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DOC_CATEGORY_ASSOC_PKG" as
/* $Header: AFOAMDCAB.pls 120.0 2005/08/05 01:05:16 appldev noship $ */
procedure LOAD_ROW(
    X_CATEGORY_KEY in VARCHAR2,
    X_CATEGORY_TYPE in VARCHAR2,
    X_PARENT_CATEGORY_KEY in VARCHAR2,
    X_PARENT_CATEGORY_TYPE in VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER) is
  begin

    begin
      fnd_oam_doc_category_assoc_pkg.UPDATE_ROW(
        X_CATEGORY_KEY => X_CATEGORY_KEY,
        X_CATEGORY_TYPE  => X_CATEGORY_TYPE,
        X_PARENT_CATEGORY_KEY => X_PARENT_CATEGORY_KEY,
        X_PARENT_CATEGORY_TYPE => X_PARENT_CATEGORY_TYPE,
        X_CREATED_BY => X_CREATED_BY,
        X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN);

     exception
       when NO_DATA_FOUND then

       fnd_oam_doc_category_assoc_pkg.INSERT_ROW(
         X_CATEGORY_KEY => X_CATEGORY_KEY,
	 X_CATEGORY_TYPE  => X_CATEGORY_TYPE,
	 X_PARENT_CATEGORY_KEY => X_PARENT_CATEGORY_KEY,
	 X_PARENT_CATEGORY_TYPE => X_PARENT_CATEGORY_TYPE,
	 X_CREATED_BY => X_CREATED_BY,
	 X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
	 X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN);

    end;


    commit;

end LOAD_ROW;



procedure UPDATE_ROW(
    X_CATEGORY_KEY    in   VARCHAR2,
    X_CATEGORY_TYPE     in   VARCHAR2,
    X_PARENT_CATEGORY_KEY    in   VARCHAR2,
    X_PARENT_CATEGORY_TYPE     in   VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER) is

    db_key varchar2(40);
  begin

    select category_key into db_key from FND_OAM_DOC_CATEGORY_ASSOC
       where category_key = X_CATEGORY_KEY
          and category_type = X_CATEGORY_TYPE
          and parent_category_key = X_PARENT_CATEGORY_KEY
          and parent_category_type = X_PARENT_CATEGORY_TYPE;


    update FND_OAM_DOC_CATEGORY_ASSOC SET
        category_key = X_CATEGORY_KEY,
        category_type  = X_CATEGORY_TYPE ,
        parent_category_key = X_PARENT_CATEGORY_KEY,
	parent_category_type  = X_PARENT_CATEGORY_TYPE ,
        created_by = X_CREATED_BY,
        creation_date = sysdate,
        last_update_date = sysdate,
        last_updated_by = X_LAST_UPDATED_BY,
        last_update_login = X_LAST_UPDATE_LOGIN
      where category_key = X_CATEGORY_KEY
            and category_type = X_CATEGORY_TYPE
            and parent_category_key = X_PARENT_CATEGORY_KEY
            and parent_category_type = X_PARENT_CATEGORY_TYPE;

end UPDATE_ROW;

procedure INSERT_ROW(
    X_CATEGORY_KEY    in   VARCHAR2,
    X_CATEGORY_TYPE     in   VARCHAR2,
    X_PARENT_CATEGORY_KEY    in   VARCHAR2,
    X_PARENT_CATEGORY_TYPE     in   VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER) is

  begin
    insert into FND_OAM_DOC_CATEGORY_ASSOC(
      category_key,
      category_type,
      parent_category_key,
      parent_category_type,
      created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login
    ) values (
      X_CATEGORY_KEY,
      X_CATEGORY_TYPE,
      X_PARENT_CATEGORY_KEY,
      X_PARENT_CATEGORY_TYPE,
      X_CREATED_BY,
      sysdate,
      sysdate,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN);

end INSERT_ROW;


end FND_OAM_DOC_CATEGORY_ASSOC_PKG;

/
