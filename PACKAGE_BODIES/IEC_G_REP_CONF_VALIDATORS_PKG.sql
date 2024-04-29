--------------------------------------------------------
--  DDL for Package Body IEC_G_REP_CONF_VALIDATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_REP_CONF_VALIDATORS_PKG" as
/* $Header: IECREPDB.pls 115.0 2004/03/24 05:10:57 anayak noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor C is select ROWID
		from 	iec_g_rep_conf_vldtrs
    where
					VALIDATOR_ID = X_VALIDATOR_ID
			and VALIDATOR_CLASS = X_VALIDATOR_CLASS
			and FORMAT = X_FORMAT;

begin

    insert into iec_g_rep_conf_vldtrs
           ( VALIDATOR_ID,
             VALIDATOR_CLASS,
             FORMAT,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             OBJECT_VERSION_NUMBER)
    values( X_VALIDATOR_ID,
            X_VALIDATOR_CLASS,
            X_FORMAT,
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
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      VALIDATOR_CLASS,
      FORMAT,
      OBJECT_VERSION_NUMBER
    from iec_g_rep_conf_vldtrs
    where VALIDATOR_ID = X_VALIDATOR_ID
    for update of VALIDATOR_CLASS, FORMAT, OBJECT_VERSION_NUMBER  nowait;
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
  if (    (recinfo.VALIDATOR_CLASS = X_VALIDATOR_CLASS)
      AND (recinfo.FORMAT = X_FORMAT)
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
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
begin

	update iec_g_rep_conf_vldtrs
	set LAST_UPDATED_BY     	= X_LAST_UPDATED_BY,
	    LAST_UPDATE_DATE    	= X_LAST_UPDATE_DATE,
	    LAST_UPDATE_LOGIN   	= X_LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
	    VALIDATOR_CLASS      	= X_VALIDATOR_CLASS,
	    FORMAT             		= X_FORMAT
	where VALIDATOR_ID = X_VALIDATOR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_VALIDATOR_ID in NUMBER
) is
begin
  delete from iec_g_rep_conf_vldtrs
  where VALIDATOR_ID = X_VALIDATOR_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure LOAD_ROW (
  X_VALIDATOR_ID in NUMBER,
  X_VALIDATOR_CLASS in VARCHAR2,
  X_FORMAT in VARCHAR2,
  X_OWNER in VARCHAR2
) is
  USER_ID NUMBER := 0;
  ROW_ID  VARCHAR2(500);
begin

  if (X_OWNER = 'SEED') then
    USER_ID := 1;
  end if;

  UPDATE_ROW (X_VALIDATOR_ID, X_VALIDATOR_CLASS, X_FORMAT, USER_ID, SYSDATE, USER_ID, 0);

exception
  when no_data_found then
    INSERT_ROW (ROW_ID, X_VALIDATOR_ID, X_VALIDATOR_CLASS, X_FORMAT, USER_ID, SYSDATE, USER_ID, SYSDATE, USER_ID, 0);

end LOAD_ROW;

end IEC_G_REP_CONF_VALIDATORS_PKG;

/
