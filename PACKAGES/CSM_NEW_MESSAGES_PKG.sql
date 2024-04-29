--------------------------------------------------------
--  DDL for Package CSM_NEW_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_NEW_MESSAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: csmlnmgs.pls 120.1 2006/05/09 05:51:45 utekumal noship $ */

PROCEDURE TRANSLATE_ROW(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_MESSAGE_TYPE     VARCHAR2,
                  X_MESSAGE_LENGTH   NUMBER,
                  X_UPDATABLE        VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  );

PROCEDURE LOAD_ROW(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_MESSAGE_TYPE     VARCHAR2,
                  X_MESSAGE_LENGTH   NUMBER,
                  X_UPDATABLE        VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  );


PROCEDURE LOAD_ROW_PERZ(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_LEVEL_ID         NUMBER,
                  X_LEVEL_VALUE      NUMBER,
                  X_LANGUAGE         VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  );

PROCEDURE ADD_LANGUAGE;

END;

 

/
