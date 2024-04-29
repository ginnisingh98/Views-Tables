--------------------------------------------------------
--  DDL for Package Body IEC_G_REP_REPORTS_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_REP_REPORTS_VALS_PKG" as
/* $Header: IECREPVB.pls 115.0 2004/03/24 05:12:27 anayak noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VALUE_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID
		from 	IEC_G_REP_REPORTS_VALS
    where
					VALUE_ID = X_VALUE_ID
			and PARAM_NAME = X_PARAM_NAME
			and PARAM_VALUE = X_PARAM_VALUE
			and REPORT_ID = X_REPORT_ID;

begin

insert into iec_g_rep_reports_vals
			            (  VALUE_ID,
			               PARAM_NAME,
			               PARAM_VALUE,
			               REPORT_ID,
			               CREATED_BY,
			               CREATION_DATE,
			               LAST_UPDATED_BY,
			               LAST_UPDATE_DATE,
			               LAST_UPDATE_LOGIN,
			               OBJECT_VERSION_NUMBER)
	          values(  X_VALUE_ID,
	                   X_PARAM_NAME,
	                   X_PARAM_VALUE,
	                   X_REPORT_ID,
										 X_CREATED_BY,
										 X_CREATION_DATE,
										 X_LAST_UPDATED_BY,
										 X_LAST_UPDATE_DATE,
										 X_LAST_UPDATE_LOGIN,
										 X_OBJECT_VERSION_NUMBER);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_VALUE_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      PARAM_NAME,
      PARAM_VALUE,
      REPORT_ID,
      OBJECT_VERSION_NUMBER
    from iec_g_rep_reports_vals
    where VALUE_ID = X_VALUE_ID
    for update of PARAM_NAME, PARAM_VALUE, REPORT_ID, OBJECT_VERSION_NUMBER  nowait;
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
  if (    (recinfo.PARAM_NAME = X_PARAM_NAME)
      AND (recinfo.PARAM_VALUE = X_PARAM_VALUE)
      AND (recinfo.REPORT_ID = X_REPORT_ID)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_VALUE_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin

  update iec_g_rep_reports_vals
  set LAST_UPDATED_BY     	= X_LAST_UPDATED_BY,
      LAST_UPDATE_DATE    	= X_LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN   	= X_LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
      PARAM_NAME          	= X_PARAM_NAME,
      PARAM_VALUE         	= X_PARAM_VALUE,
      REPORT_ID           	= X_REPORT_ID
  where
			VALUE_ID = X_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_VALUE_ID in NUMBER
) is
begin
  delete from iec_g_rep_reports_vals
  where VALUE_ID = X_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_VALUE_ID in NUMBER,
  X_PARAM_NAME in VARCHAR2,
  X_PARAM_VALUE in VARCHAR2,
  X_REPORT_ID in NUMBER,
  X_OWNER in VARCHAR2
) is
  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW (X_VALUE_ID, X_PARAM_NAME, X_PARAM_VALUE, X_REPORT_ID, USER_ID, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_VALUE_ID, X_PARAM_NAME, X_PARAM_VALUE, X_REPORT_ID, 0, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

end IEC_G_REP_REPORTS_VALS_PKG;

/
