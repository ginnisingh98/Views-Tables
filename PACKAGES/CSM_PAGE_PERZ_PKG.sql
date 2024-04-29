--------------------------------------------------------
--  DDL for Package CSM_PAGE_PERZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PAGE_PERZ_PKG" AUTHID CURRENT_USER AS
/* $Header: csmlpps.pls 120.0 2005/11/30 00:48:45 utekumal noship $ */

PROCEDURE LOAD_ROW(
                   X_PAGE_PERZ_ID             VARCHAR2,
                   X_FILE_NAME                VARCHAR2,
                   X_PAGE_NAME                VARCHAR2,
                   X_UIX_PAGE_SERVER_VERSION  VARCHAR2,
                   X_UIX_PAGE_CLIENT_VERSION  VARCHAR2,
                   X_MESSAGE_NAME             VARCHAR2,
                   X_OWNER                    VARCHAR2
                  );

END;

 

/
