--------------------------------------------------------
--  DDL for Package Body DPP_XLA_EVENT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_XLA_EVENT_MAP_PKG" as
/* $Header: dpptxemb.pls 120.0.12010000.1 2008/10/30 09:29:03 anbbalas noship $ */

procedure LOAD_ROW (
  p_owner                	IN VARCHAR2,
  P_PP_TRANSACTION_TYPE 	IN VARCHAR2,
  P_ENTITY_CODE 		IN VARCHAR2,
  P_EVENT_CLASS_CODE 		IN VARCHAR2,
  P_EVENT_TYPE_CODE 		IN VARCHAR2
  )
 is
    l_user_id                        NUMBER := 0;
    l_login_id                       NUMBER := 0;
    l_rowid                          VARCHAR2(256);

    CURSOR c(C_PP_TRANSACTION_TYPE VARCHAR2) IS SELECT rowid FROM DPP_XLA_EVENT_MAP
      WHERE PP_TRANSACTION_TYPE = C_PP_TRANSACTION_TYPE;

  begin

    l_user_id := fnd_load_util.owner_id(p_owner);

    update DPP_XLA_EVENT_MAP
    set ENTITY_CODE = P_ENTITY_CODE,
    	EVENT_CLASS_CODE = P_EVENT_CLASS_CODE,
    	EVENT_TYPE_CODE =  P_EVENT_TYPE_CODE,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = l_user_id,
    	LAST_UPDATE_LOGIN = l_login_id
    where PP_TRANSACTION_TYPE = P_PP_TRANSACTION_TYPE;

     IF SQL%NOTFOUND then

    	Insert into DPP_XLA_EVENT_MAP
    		(PP_TRANSACTION_TYPE,
    		ENTITY_CODE,
    		EVENT_CLASS_CODE,
    		EVENT_TYPE_CODE,
    		CREATION_DATE,
    		CREATED_BY,
    		LAST_UPDATE_DATE,
    		LAST_UPDATED_BY,
    		LAST_UPDATE_LOGIN)
    	VALUES (P_PP_TRANSACTION_TYPE,
    		P_ENTITY_CODE,
    		P_EVENT_CLASS_CODE,
    		P_EVENT_TYPE_CODE,
    		SYSDATE,
    		l_user_id,
    		SYSDATE,
    		l_user_id,
    		l_login_id);

      OPEN c(P_PP_TRANSACTION_TYPE);
         FETCH c INTO l_rowid;
         IF (c%NOTFOUND) THEN
           CLOSE c;
           RAISE NO_DATA_FOUND;
         END IF;
         CLOSE c;

    END IF;

end LOAD_ROW;

end DPP_XLA_EVENT_MAP_PKG;

/
