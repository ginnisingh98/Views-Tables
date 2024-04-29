--------------------------------------------------------
--  DDL for Package Body PA_ADW_DIMENSION_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ADW_DIMENSION_STATUS_PKG" as
/* $Header: PAADWDSB.pls 120.0 2005/05/29 13:48:11 appldev noship $ */
procedure INSERT_ROW (
 X_DIMENSION_CODE                 IN VARCHAR2,
 X_DIMENSION_NAME                  IN VARCHAR2,
 X_STATUS_CODE                     IN VARCHAR2,
 X_UPDATE_ALLOWED                  IN VARCHAR2,
 X_LAST_UPDATE_DATE                IN DATE,
 X_LAST_UPDATED_BY                 IN NUMBER,
 X_CREATION_DATE                   IN DATE,
 X_CREATED_BY                      IN NUMBER,
 X_LAST_UPDATE_LOGIN               IN  NUMBER
) is
begin
  insert into PA_ADW_DIMENSION_STATUS(
 DIMENSION_CODE                 ,
 DIMENSION_NAME                  ,
 STATUS_CODE                     ,
 UPDATE_ALLOWED                  ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 CREATION_DATE                   ,
 CREATED_BY                      ,
 LAST_UPDATE_LOGIN
 ) values (
 X_DIMENSION_CODE                 ,
 X_DIMENSION_NAME                  ,
 X_STATUS_CODE                     ,
 X_UPDATE_ALLOWED                  ,
 X_LAST_UPDATE_DATE                ,
 X_LAST_UPDATED_BY                 ,
 X_CREATION_DATE                   ,
 X_CREATED_BY                      ,
 X_LAST_UPDATE_LOGIN
 );

  exception
    when others then
      raise;

end INSERT_ROW;

procedure TRANSLATE_ROW (
  X_DIMENSION_CODE              IN VARCHAR2,
  X_DIMENSION_NAME              IN VARCHAR2,
  X_OWNER                       IN VARCHAR2) is
begin

  update PA_ADW_DIMENSION_STATUS set
    DIMENSION_NAME      = X_DIMENSION_NAME,
    LAST_UPDATE_DATE  = sysdate,
    LAST_UPDATED_BY   = decode(X_OWNER, 'SEED', 1, 0),
    LAST_UPDATE_LOGIN = 0
  where DIMENSION_CODE      = X_DIMENSION_CODE
  and userenv('LANG') =
         (select LANGUAGE_CODE from FND_LANGUAGES where INSTALLED_FLAG = 'B');

--  Commented for Bug 3857072
--  if (sql%notfound) then
--    raise no_data_found;
--  end if;

  exception
    when others then
      raise;

end TRANSLATE_ROW;


procedure UPDATE_ROW (
X_DIMENSION_CODE                  IN VARCHAR2,
 X_DIMENSION_NAME                  IN VARCHAR2,
 X_STATUS_CODE                     IN VARCHAR2,
 X_UPDATE_ALLOWED                  IN VARCHAR2,
 X_LAST_UPDATE_DATE                IN DATE,
 X_LAST_UPDATED_BY                 IN NUMBER,
 X_LAST_UPDATE_LOGIN               IN  NUMBER
) is
begin
  update PA_ADW_DIMENSION_STATUS set
	DIMENSION_NAME = X_DIMENSION_NAME,
	STATUS_CODE = X_STATUS_CODE,
	UPDATE_ALLOWED = X_UPDATE_ALLOWED,
    	LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE,
   	LAST_UPDATED_BY     = X_LAST_UPDATED_BY,
    	LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN
  where DIMENSION_CODE      = X_DIMENSION_CODE ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  exception
    when others then
      raise;

end UPDATE_ROW;

end PA_ADW_DIMENSION_STATUS_PKG;

/
