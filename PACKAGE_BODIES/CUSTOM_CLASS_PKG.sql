--------------------------------------------------------
--  DDL for Package Body CUSTOM_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUSTOM_CLASS_PKG" AS
/* $Header: MWACTCLB.pls 115.3 2004/04/08 22:37:25 vchitili ship $ */
procedure INSERT_ROW (
  X_ROWID 				in out VARCHAR2,
  X_CLASSFILEID                         in number,
  X_CLASSOLDFILE                        in VARCHAR2,
  X_CLASSNEWFILE                        in VARCHAR2,
  X_ENABLED                             in VARCHAR2,
  X_CREATION_DATE 			in DATE,
  X_CREATED_BY 				in NUMBER,
  X_LAST_UPDATE_DATE 			in DATE,
  X_LAST_UPDATED_BY 			in NUMBER,
  X_LAST_UPDATE_LOGIN 			in NUMBER,
  X_ATTRIBUTE_CATEGORY 			in VARCHAR2,
  X_ATTRIBUTE1 				in VARCHAR2,
  X_ATTRIBUTE2 				in VARCHAR2,
  X_ATTRIBUTE3 				in VARCHAR2,
  X_ATTRIBUTE4 				in VARCHAR2,
  X_ATTRIBUTE5 				in VARCHAR2,
  X_ATTRIBUTE6 				in VARCHAR2,
  X_ATTRIBUTE7 				in VARCHAR2,
  X_ATTRIBUTE8 				in VARCHAR2,
  X_ATTRIBUTE9 				in VARCHAR2,
  X_ATTRIBUTE10 			in VARCHAR2,
  X_ATTRIBUTE11 			in VARCHAR2,
  X_ATTRIBUTE12 			in VARCHAR2,
  X_ATTRIBUTE13 			in VARCHAR2,
  X_ATTRIBUTE14 			in VARCHAR2,
  X_ATTRIBUTE15 			in VARCHAR2
) is
  cursor get_row is
    select ROWID from MWA_CLASS_CUSTOM_FILES
    where CLASSFILEID = X_CLASSFILEID;
begin
  insert into MWA_CLASS_CUSTOM_FILES (
    CLASSFILEID,
    CLASSOLDFILE,
    CLASSNEWFILE,
    ENABLED,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15)
values (
    X_CLASSFILEID,
    X_CLASSOLDFILE,
    X_CLASSNEWFILE,
    X_ENABLED,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15
  );
  open get_row;
  fetch get_row into X_ROWID;
  if (get_row%notfound) then
    close get_row;
    raise no_data_found;
  end if;
  close get_row;

end insert_row;

/*****************************************************************/

procedure LOCK_ROW (
  X_ROWID                               in out VARCHAR2,
  X_CLASSFILEID                         in number,
  X_CLASSOLDFILE                        in VARCHAR2,
  X_CLASSNEWFILE                        in VARCHAR2,
  X_ENABLED                             in VARCHAR2,
  X_CREATION_DATE                       in DATE,
  X_CREATED_BY                          in NUMBER,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_ATTRIBUTE_CATEGORY                  in VARCHAR2,
  X_ATTRIBUTE1                          in VARCHAR2,
  X_ATTRIBUTE2                          in VARCHAR2,
  X_ATTRIBUTE3                          in VARCHAR2,
  X_ATTRIBUTE4                          in VARCHAR2,
  X_ATTRIBUTE5                          in VARCHAR2,
  X_ATTRIBUTE6                          in VARCHAR2,
  X_ATTRIBUTE7                          in VARCHAR2,
  X_ATTRIBUTE8                          in VARCHAR2,
  X_ATTRIBUTE9                          in VARCHAR2,
  X_ATTRIBUTE10                         in VARCHAR2,
  X_ATTRIBUTE11                         in VARCHAR2,
  X_ATTRIBUTE12                         in VARCHAR2,
  X_ATTRIBUTE13                         in VARCHAR2,
  X_ATTRIBUTE14                         in VARCHAR2,
  X_ATTRIBUTE15                         in VARCHAR2)
is
  cursor get_lock is select
        CLASSFILEID,
        CLASSOLDFILE,
        CLASSNEWFILE,
        ENABLED,
  	CREATION_DATE,
  	CREATED_BY,
  	LAST_UPDATE_DATE,
  	LAST_UPDATED_BY,
  	LAST_UPDATE_LOGIN,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15
 from MWA_CLASS_CUSTOM_FILES
 where ROWID = X_ROWID
 for update of CLASSFILEID nowait;
 recinfo get_lock%rowtype;

begin
  open get_lock;
  fetch get_lock into recinfo;
  if (get_lock%notfound) then
    close get_lock;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close get_lock;

if
-- check if the mandatory columns match  values in the form
     ((recinfo.CLASSFILEID = X_CLASSFILEID)
AND  (recinfo.CLASSOLDFILE = X_CLASSOLDFILE)
AND  (recinfo.CLASSNEWFILE = X_CLASSNEWFILE)
AND  (recinfo.ENABLED = X_ENABLED)
AND  (recinfo.CREATION_DATE = X_CREATION_DATE)
AND  (recinfo.CREATED_BY = X_CREATED_BY)
AND  (recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE)
AND  (recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY)
AND  (recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN)
AND ((recinfo.attribute_category = X_attribute_category)
OR ((recinfo.attribute_category is null) AND (X_attribute_category is null)))
AND ((recinfo.attribute1 = X_attribute1)
OR ((recinfo.attribute1 is null)  AND (X_attribute1 is null)))
AND ((recinfo.attribute2 = X_attribute2)
OR ((recinfo.attribute2 is null)  AND (X_attribute2 is null)))
AND ((recinfo.attribute3 = X_attribute3)
OR ((recinfo.attribute3 is null)  AND (X_attribute3 is null)))
AND ((recinfo.attribute4 = X_attribute4)
OR ((recinfo.attribute4 is null)  AND (X_attribute4 is null)))
AND ((recinfo.attribute5 = X_attribute5)
OR ((recinfo.attribute5 is null)  AND (X_attribute5 is null)))
AND ((recinfo.attribute6 = X_attribute6)
OR ((recinfo.attribute6 is null)  AND (X_attribute6 is null)))
AND ((recinfo.attribute7 = X_attribute7)
OR ((recinfo.attribute7 is null)  AND (X_attribute7 is null)))
AND ((recinfo.attribute8 = X_attribute8)
OR ((recinfo.attribute8 is null)  AND (X_attribute8 is null)))
AND ((recinfo.attribute9 = X_attribute9)
OR ((recinfo.attribute9 is null)  AND (X_attribute9 is null)))
AND ((recinfo.attribute10 = X_attribute10)
OR ((recinfo.attribute10 is null) AND (X_attribute10 is null)))
AND ((recinfo.attribute11 = X_attribute11)
OR ((recinfo.attribute11 is null) AND (X_attribute11 is null)))
AND ((recinfo.attribute12 = X_attribute12)
OR ((recinfo.attribute12 is null) AND (X_attribute12 is null)))
AND ((recinfo.attribute13 = X_attribute13)
OR ((recinfo.attribute13 is null) AND (X_attribute13 is null)))
AND ((recinfo.attribute14 = X_attribute14)
OR ((recinfo.attribute14 is null) AND (X_attribute14 is null)))
AND ((recinfo.attribute15 = X_attribute15)
OR ((recinfo.attribute15 is null) AND (X_attribute15 is null)))
 )
then
return;
else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
end if;

end LOCK_ROW;

/*******************************************************************************/

procedure UPDATE_ROW (
  X_ROWID                               in out VARCHAR2,
  X_CLASSFILEID                         in NUMBER,
  X_CLASSOLDFILE                        in Varchar2,
  X_CLASSNEWFILE                        in Varchar2,
  X_ENABLED                             in VARCHAR2,
  X_LAST_UPDATE_DATE                    in DATE,
  X_LAST_UPDATED_BY                     in NUMBER,
  X_LAST_UPDATE_LOGIN                   in NUMBER,
  X_ATTRIBUTE_CATEGORY                  in VARCHAR2,
  X_ATTRIBUTE1                          in VARCHAR2,
  X_ATTRIBUTE2                          in VARCHAR2,
  X_ATTRIBUTE3                          in VARCHAR2,
  X_ATTRIBUTE4                          in VARCHAR2,
  X_ATTRIBUTE5                          in VARCHAR2,
  X_ATTRIBUTE6                          in VARCHAR2,
  X_ATTRIBUTE7                          in VARCHAR2,
  X_ATTRIBUTE8                          in VARCHAR2,
  X_ATTRIBUTE9                          in VARCHAR2,
  X_ATTRIBUTE10                         in VARCHAR2,
  X_ATTRIBUTE11                         in VARCHAR2,
  X_ATTRIBUTE12                         in VARCHAR2,
  X_ATTRIBUTE13                         in VARCHAR2,
  X_ATTRIBUTE14                         in VARCHAR2,
  X_ATTRIBUTE15                         in VARCHAR2)
is
begin
update MWA_CLASS_CUSTOM_FILES set
    CLASSOLDFILE = X_CLASSOLDFILE,
    CLASSNEWFILE = X_CLASSNEWFILE,
    ENABLED      = X_ENABLED,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15
where CLASSFILEID = X_CLASSFILEID       ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

/********************************************************************************/

procedure DELETE_ROW (X_CLASSFILEID in NUMBER)
is
begin
  delete from MWA_CLASS_CUSTOM_FILES
  where CLASSFILEID = X_CLASSFILEID;

  if (sql%notfound) then
      raise no_data_found;
  end if;

end DELETE_ROW;

/*******************************************************************************/

end CUSTOM_CLASS_PKG;

/
