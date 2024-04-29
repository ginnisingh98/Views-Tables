--------------------------------------------------------
--  DDL for Package Body CS_SR_SAVED_BSC_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_SAVED_BSC_CRITERIA_PKG" as
/* $Header: csxtssbb.pls 115.1 2003/09/18 04:46:12 aktripat noship $*/

procedure INSERT_ROW (  X_ROWID in out nocopy VARCHAR2,
		    X_SEARCH_ID in NUMBER,
		    X_FIELD_NAME in VARCHAR2,
		    X_FIELD_TYPE in VARCHAR2,
		    X_OBJECT_VERSION_NUMBER in NUMBER,
		    X_FIELD_VALUE in VARCHAR2,
		    X_CREATION_DATE in DATE,
		    X_CREATED_BY in NUMBER,
		    X_LAST_UPDATE_DATE in DATE,
		    X_LAST_UPDATED_BY in NUMBER,
		    X_LAST_UPDATE_LOGIN in NUMBER,
		    X_COMMIT_FLAG in VARCHAR2) is

 cursor C is select ROWID from CS_SR_SAVED_BSC_CRITERIA
  where SEARCH_ID = X_SEARCH_ID    and FIELD_NAME = X_FIELD_NAME ;

begin

 insert into CS_SR_SAVED_BSC_CRITERIA (
                              SEARCH_ID,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN,
                              FIELD_NAME,
                              FIELD_TYPE,
                              FIELD_VALUE,
                              OBJECT_VERSION_NUMBER     )
    		   Values     (X_SEARCH_ID,
                              X_LAST_UPDATE_DATE,
                              X_LAST_UPDATED_BY,
                              X_CREATION_DATE,
                              X_CREATED_BY,
                              X_LAST_UPDATE_LOGIN,
                              X_FIELD_NAME,
                              X_FIELD_TYPE,
                              X_FIELD_VALUE,
                              X_OBJECT_VERSION_NUMBER);

          open c;
          fetch c into X_ROWID;

          if (c%notfound) then
                        close c;
                         raise no_data_found;
          end if;

           close c;

           IF X_COMMIT_FLAG = 'Y' THEN
                      commit;
           END IF;

end INSERT_ROW;

procedure LOCK_ROW ( X_SEARCH_ID in NUMBER,
                                         X_FIELD_NAME in VARCHAR2,
                                         X_FIELD_TYPE in VARCHAR2,
                                         X_OBJECT_VERSION_NUMBER in NUMBER,
                                         X_SECURITY_GROUP_ID in NUMBER,
                                         X_FIELD_VALUE in VARCHAR2) is

    cursor c1 is select  FIELD_TYPE,  OBJECT_VERSION_NUMBER,
	    SECURITY_GROUP_ID,  FIELD_VALUE,  FIELD_NAME
            from CS_SR_SAVED_BSC_CRITERIA
            where SEARCH_ID = X_SEARCH_ID
            and FIELD_NAME = X_FIELD_NAME for update of SEARCH_ID nowait;

begin

	null;

end LOCK_ROW;


procedure UPDATE_ROW (   X_SEARCH_ID in NUMBER,
		      X_FIELD_NAME in VARCHAR2,
		      X_FIELD_TYPE in VARCHAR2,
		      X_OBJECT_VERSION_NUMBER in NUMBER,
		      X_SECURITY_GROUP_ID in NUMBER,
		      X_FIELD_VALUE in VARCHAR2,
		      X_LAST_UPDATE_DATE in DATE,
		      X_LAST_UPDATED_BY in NUMBER,
		      X_LAST_UPDATE_LOGIN in NUMBER) is

begin
          null;
end UPDATE_ROW;

procedure DELETE_ROW (  X_SEARCH_ID in NUMBER) is

begin

delete from CS_SR_SAVED_BSC_CRITERIA  where SEARCH_ID = X_SEARCH_ID;
   if (sql%notfound) then
          raise no_data_found;
   end if;
end DELETE_ROW;
end CS_SR_SAVED_BSC_CRITERIA_PKG;

/
