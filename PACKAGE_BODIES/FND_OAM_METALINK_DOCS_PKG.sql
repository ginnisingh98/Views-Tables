--------------------------------------------------------
--  DDL for Package Body FND_OAM_METALINK_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_METALINK_DOCS_PKG" as
/* $Header: AFOAMMDB.pls 120.0 2005/08/05 01:05:37 appldev noship $ */
procedure LOAD_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_TITLE     in   VARCHAR2,
    X_DOC_LAST_UPDATE_DATE  in  DATE,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_UPDATE_SUMMARY in CLOB) is
  begin

   begin


     fnd_oam_metalink_docs_pkg.UPDATE_ROW(
       X_DOC_ID => X_DOC_ID,
       X_TITLE  => X_TITLE,
       X_DOC_LAST_UPDATE_DATE => X_DOC_LAST_UPDATE_DATE,
       X_CREATED_BY => X_CREATED_BY,
       X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN,
       X_UPDATE_SUMMARY => X_UPDATE_SUMMARY);

     exception
       when NO_DATA_FOUND then

       fnd_oam_metalink_docs_pkg.INSERT_ROW(
         X_DOC_ID => X_DOC_ID,
         X_TITLE  => X_TITLE,
         X_DOC_LAST_UPDATE_DATE => X_DOC_LAST_UPDATE_DATE,
         X_CREATED_BY => X_CREATED_BY,
         X_LAST_UPDATED_BY => X_LAST_UPDATED_BY,
         X_LAST_UPDATE_LOGIN => X_LAST_UPDATE_LOGIN,
         X_UPDATE_SUMMARY => X_UPDATE_SUMMARY);

    end;
    commit;

end LOAD_ROW;


procedure UPDATE_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_TITLE     in   VARCHAR2,
    X_DOC_LAST_UPDATE_DATE  in  DATE,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_UPDATE_SUMMARY in CLOB) is

    db_id varchar2(40);
  begin

    select doc_id into db_id from FND_OAM_METALINK_DOCS
       where doc_id = X_DOC_ID;

    update FND_OAM_METALINK_DOCS SET
        doc_id = X_DOC_ID,
        title  = X_TITLE,
        doc_last_update_date = X_DOC_LAST_UPDATE_DATE,
        created_by = X_CREATED_BY,
        creation_date = sysdate,
        last_update_date = sysdate,
        last_updated_by = X_LAST_UPDATED_BY,
        last_update_login = X_LAST_UPDATE_LOGIN,
        update_summary = X_UPDATE_SUMMARY,
        doc_last_update_detected_date = sysdate
        where doc_id = X_DOC_ID and doc_last_update_date < X_DOC_LAST_UPDATE_DATE;

end UPDATE_ROW;

procedure INSERT_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_TITLE     in   VARCHAR2,
    X_DOC_LAST_UPDATE_DATE  in  DATE,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_UPDATE_SUMMARY in CLOB) is

  begin
    insert into FND_OAM_METALINK_DOCS (
      doc_id,
      title,
      doc_last_update_date,
      created_by,
      creation_date,
      last_update_date,
      last_updated_by,
      last_update_login,
      update_summary,
      doc_last_update_detected_date
    ) values (
      X_DOC_ID,
      X_TITLE,
      X_DOC_LAST_UPDATE_DATE,
      X_CREATED_BY,
      sysdate,
      sysdate,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      X_UPDATE_SUMMARY,
      sysdate);

end INSERT_ROW;


end FND_OAM_METALINK_DOCS_PKG;

/
