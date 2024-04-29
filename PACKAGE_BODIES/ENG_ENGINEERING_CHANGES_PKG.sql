--------------------------------------------------------
--  DDL for Package Body ENG_ENGINEERING_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ENGINEERING_CHANGES_PKG" as
/* $Header: engpecob.pls 115.3 2003/02/07 09:05:26 rbehal ship $ */


PROCEDURE Check_Unique(	X_Rowid VARCHAR2,
			X_Change_Notice VARCHAR2,
			X_Organization_Id NUMBER ) IS
  dummy NUMBER;
BEGIN
  select 1 into dummy from dual where not exists
    (select 1 from ENG_ENGINEERING_CHANGES
      where CHANGE_NOTICE = X_Change_Notice
        and ORGANIZATION_ID = X_Organization_Id
    	and ((X_Rowid IS NULL) OR (ROWID <> X_Rowid))
    );
  exception
    when NO_DATA_FOUND then
      fnd_message.set_name('INV', 'INV_ALREADY_EXISTS');
      fnd_message.set_token('ENTITY1', X_Change_Notice);
      app_exception.raise_exception;
END Check_Unique;


PROCEDURE Delete_Row( X_Rowid VARCHAR2,
		      X_Change_Notice VARCHAR2,
		      X_Organization_Id NUMBER )IS
BEGIN
  delete from ENG_ENGINEERING_CHANGES
  where rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    raise NO_DATA_FOUND;
  elsif (SQL%FOUND) then
    Delete_ECO_Revisions( X_Change_Notice, X_Organization_Id);
  end if;
END Delete_Row;


PROCEDURE Delete_ECO_Revisions( X_Change_Notice VARCHAR2,
				X_Organization_Id NUMBER ) IS
BEGIN
  delete from ENG_CHANGE_ORDER_REVISIONS
  where CHANGE_NOTICE = X_Change_Notice
    and ORGANIZATION_ID = X_Organization_Id;
END Delete_ECO_Revisions;




END ENG_ENGINEERING_CHANGES_PKG ;

/
