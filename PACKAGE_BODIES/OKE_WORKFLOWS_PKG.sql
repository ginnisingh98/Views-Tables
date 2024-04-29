--------------------------------------------------------
--  DDL for Package Body OKE_WORKFLOWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_WORKFLOWS_PKG" as
/* $Header: OKEOWXXB.pls 115.0 2003/10/22 22:23:27 ybchen noship $ */
procedure INSERT_ROW (
  X_ROWID 			in out NOCOPY VARCHAR2
, X_SOURCE_CODE 	        in 	VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_CREATION_DATE 		in 	DATE
, X_CREATED_BY 			in 	NUMBER
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_WF_ITEM_TYPE		in 	VARCHAR2
, X_WF_PROCESS  		in 	VARCHAR2
) is
  cursor C is select ROWID from OKE_WORKFLOWS
    where SOURCE_CODE = X_SOURCE_CODE
    and   USAGE_CODE  = X_USAGE_CODE
    ;
begin
  insert into OKE_WORKFLOWS (
  SOURCE_CODE
, USAGE_CODE
, CREATION_DATE
, CREATED_BY
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, WF_ITEM_TYPE
, WF_PROCESS
  ) values (
  X_SOURCE_CODE
, X_USAGE_CODE
, X_CREATION_DATE
, X_CREATED_BY
, X_LAST_UPDATE_DATE
, X_LAST_UPDATED_BY
, X_LAST_UPDATE_LOGIN
, X_WF_ITEM_TYPE
, X_WF_PROCESS
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
  X_SOURCE_CODE 	        in 	VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_WF_ITEM_TYPE		in 	VARCHAR2
, X_WF_PROCESS  		in 	VARCHAR2
) is
  cursor c is select
       SOURCE_CODE
     , USAGE_CODE
     , WF_ITEM_TYPE
     , WF_PROCESS
    from OKE_WORKFLOWS
    where SOURCE_CODE = X_SOURCE_CODE
    and   USAGE_CODE  = X_USAGE_CODE
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

  if (    (recinfo.USAGE_CODE = X_USAGE_CODE AND recinfo.SOURCE_CODE =
 X_SOURCE_CODE)
       AND ((recinfo.WF_ITEM_TYPE = X_WF_ITEM_TYPE)
           OR ((recinfo.WF_ITEM_TYPE is null) AND (X_WF_ITEM_TYPE is null)))
      AND ((recinfo.WF_PROCESS = X_WF_PROCESS)
           OR ((recinfo.WF_PROCESS is null) AND (X_WF_PROCESS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SOURCE_CODE 	        in 	VARCHAR2
, X_USAGE_CODE 	                in 	VARCHAR2
, X_LAST_UPDATE_DATE 		in 	DATE
, X_LAST_UPDATED_BY 		in 	NUMBER
, X_LAST_UPDATE_LOGIN 		in 	NUMBER
, X_WF_ITEM_TYPE		in 	VARCHAR2
, X_WF_PROCESS  		in 	VARCHAR2
) is
begin
  update OKE_WORKFLOWS set
  LAST_UPDATE_DATE      	= X_LAST_UPDATE_DATE
, LAST_UPDATED_BY 		= X_LAST_UPDATED_BY
, LAST_UPDATE_LOGIN   		= X_LAST_UPDATE_LOGIN
, WF_ITEM_TYPE			= X_WF_ITEM_TYPE
, WF_PROCESS  			= X_WF_PROCESS
  where SOURCE_CODE 	        = X_SOURCE_CODE
  and   USAGE_CODE 	        = X_USAGE_CODE
  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

end OKE_WORKFLOWS_PKG;

/
