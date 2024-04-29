--------------------------------------------------------
--  DDL for Package Body DPP_TRANSACTION_STATUS_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_TRANSACTION_STATUS_MAP_PKG" as
/* $Header: dppttsmb.pls 120.0.12010000.1 2008/10/30 09:27:34 anbbalas noship $ */

procedure LOAD_ROW (
  p_owner    		IN VARCHAR2,
  P_FROM_STATUS		IN VARCHAR2,
  P_TO_STATUS   	IN VARCHAR2,
  P_ENABLED_FLAG	IN VARCHAR2
  )
 is
    l_user_id                        NUMBER := 0;
    l_login_id                       NUMBER := 0;
    l_rowid                          VARCHAR2(256);

    CURSOR c(C_FROM_STATUS VARCHAR2,C_TO_STATUS VARCHAR2 ) IS
    SELECT rowid FROM DPP_TRANSACTION_STATUS_MAP
    WHERE FROM_STATUS = C_FROM_STATUS
    AND TO_STATUS = C_TO_STATUS;

  begin

    l_user_id := fnd_load_util.owner_id(p_owner);

   update DPP_TRANSACTION_STATUS_MAP
   set ENABLED_FLAG = P_ENABLED_FLAG,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY = l_user_id,
       LAST_UPDATE_LOGIN = l_login_id
    where from_status = P_FROM_STATUS
    and to_status= P_TO_STATUS;

     IF SQL%NOTFOUND then

    	Insert into DPP_TRANSACTION_STATUS_MAP
    		(FROM_STATUS,
    		TO_STATUS,
    		ENABLED_FLAG,
    		CREATION_DATE,
    		CREATED_BY,
    		LAST_UPDATE_DATE,
    		LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN)
    	VALUES (P_FROM_STATUS,
    		P_TO_STATUS,
    		P_ENABLED_FLAG,
    		SYSDATE,
    		l_user_id,
    		SYSDATE,
    		l_user_id,
    		l_login_id);

      OPEN c(P_FROM_STATUS,P_TO_STATUS);
         FETCH c INTO l_rowid;
         IF (c%NOTFOUND) THEN
           CLOSE c;
           RAISE NO_DATA_FOUND;
         END IF;
         CLOSE c;

    END IF;

end LOAD_ROW;

end DPP_TRANSACTION_STATUS_MAP_PKG;

/
