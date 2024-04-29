--------------------------------------------------------
--  DDL for Package CUSTOM_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUSTOM_CLASS_PKG" AUTHID CURRENT_USER as
/* $Header: MWACTCLS.pls 115.1 2002/03/15 16:57:34 pkm ship      $ */
procedure INSERT_ROW (
  X_ROWID 			        in out VARCHAR2,
  X_CLASSFILEID                         in number,
  X_CLASSOLDFILE 			in VARCHAR2,
  X_CLASSNEWFILE 			in VARCHAR2,
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
  X_ATTRIBUTE15 			in VARCHAR2);

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
  X_ATTRIBUTE15                         in VARCHAR2);

procedure UPDATE_ROW (
  X_ROWID                               in out VARCHAR2,
  X_CLASSFILEID                         in number,
  X_CLASSOLDFILE                        in VARCHAR2,
  X_CLASSNEWFILE                        in VARCHAR2,
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
  X_ATTRIBUTE15                         in VARCHAR2);

procedure DELETE_ROW (X_CLASSFILEID     in NUMBER);

end CUSTOM_CLASS_PKG ;

 

/
