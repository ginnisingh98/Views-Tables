--------------------------------------------------------
--  DDL for Package Body OKE_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_NOTIFICATIONS_PKG" as
/* $Header: OKEONXXB.pls 115.0 2003/10/22 22:26:13 ybchen noship $ */
procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2
, X_ID                          in      NUMBER
, X_SOURCE_CODE 	        in      VARCHAR2
, X_USAGE_CODE 	                in      VARCHAR2
, X_CREATION_DATE 		in 	DATE
, X_CREATED_BY 			in 	NUMBER
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_TARGET_DATE         	in 	VARCHAR2
, X_BEFORE_AFTER                in      VARCHAR2
, X_DURATION_DAYS		in 	NUMBER
, X_RECIPIENT    		in 	VARCHAR2
, X_ROLE_ID		        in 	NUMBER
) is
  cursor C is select ROWID from OKE_NOTIFICATIONS
    where ID = X_ID
    ;
begin
  insert into OKE_NOTIFICATIONS (
  ID
, SOURCE_CODE
, USAGE_CODE
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, TARGET_DATE
, BEFORE_AFTER
, DURATION_DAYS
, RECIPIENT
, ROLE_ID
  ) values (
  X_ID
, X_SOURCE_CODE
, X_USAGE_CODE
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, X_TARGET_DATE
, X_BEFORE_AFTER
, X_DURATION_DAYS
, X_RECIPIENT
, X_ROLE_ID
);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ID    			in      NUMBER
, X_SOURCE_CODE 	        in      VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_TARGET_DATE         	in 	VARCHAR2
, X_BEFORE_AFTER                in      VARCHAR2
, X_DURATION_DAYS		in 	NUMBER
, X_RECIPIENT    		in 	VARCHAR2
, X_ROLE_ID		        in 	NUMBER
) is
  cursor c is
    select
       ID
     , TARGET_DATE
     , BEFORE_AFTER
     , DURATION_DAYS
     , RECIPIENT
     , ROLE_ID
    from OKE_NOTIFICATIONS
    where ID = X_ID
    for update nowait;

  recinfo c%rowtype;

begin

  open c;
    fetch c into recinfo;
    if (c%notfound) then
      close c;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    end if;
  close c;

  if (    (recinfo.ID = X_ID)
      AND ((recinfo.TARGET_DATE = X_TARGET_DATE)
           OR ((recinfo.TARGET_DATE is null) AND (X_TARGET_DATE is null)))
      AND ((recinfo.BEFORE_AFTER = X_BEFORE_AFTER)
           OR ((recinfo.BEFORE_AFTER is null) AND (X_BEFORE_AFTER is null)))
      AND ((recinfo.DURATION_DAYS = X_DURATION_DAYS)
           OR ((recinfo.DURATION_DAYS is null) AND (X_DURATION_DAYS is null)))
      AND ((recinfo.RECIPIENT = X_RECIPIENT)
           OR ((recinfo.RECIPIENT is null) AND (X_RECIPIENT is null)))
      AND ((recinfo.ROLE_ID = X_ROLE_ID)
           OR ((recinfo.ROLE_ID is null) AND (X_ROLE_ID
 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ID 	        		in      NUMBER
, X_SOURCE_CODE 	        in      VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_TARGET_DATE         	in 	VARCHAR2
, X_BEFORE_AFTER                in      VARCHAR2
, X_DURATION_DAYS		in 	NUMBER
, X_RECIPIENT    		in 	VARCHAR2
, X_ROLE_ID		        in 	NUMBER
)
is
begin
  update OKE_NOTIFICATIONS
  set
  LAST_UPDATE_DATE      	= X_LAST_UPDATE_DATE
, LAST_UPDATED_BY 		= X_LAST_UPDATED_BY
, LAST_UPDATE_LOGIN   		= X_LAST_UPDATE_LOGIN
, TARGET_DATE     		= X_TARGET_DATE
, BEFORE_AFTER         		= X_BEFORE_AFTER
, DURATION_DAYS    		= X_DURATION_DAYS
, RECIPIENT      		= X_RECIPIENT
, ROLE_ID		        = X_ROLE_ID
  where ID                      = X_ID
;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ID  			in 	NUMBER
) is
begin
  delete OKE_NOTIFICATIONS
  where ID 	= X_ID
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end OKE_NOTIFICATIONS_PKG;

/
