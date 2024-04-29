--------------------------------------------------------
--  DDL for Package AP_WEB_CC_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CC_NOTIFICATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: apwcnots.pls 115.2 2004/05/24 13:19:10 ammishra noship $ */

  PROCEDURE GET_NEW_CARD_NOTIFICATION(document_id IN VARCHAR2,
                                    display_type IN VARCHAR2,
                                    document IN OUT NOCOPY CLOB,
                                    document_type IN OUT NOCOPY VARCHAR2);
  PROCEDURE GET_VAL_ERROR_NOTIFICATION(document_id IN VARCHAR2,
                                    display_type IN VARCHAR2,
                                    document IN OUT NOCOPY CLOB,
                                    document_type IN OUT NOCOPY VARCHAR2);
  FUNCTION GET_INACTIVE_COUNT(l_request_id NUMBER) return NUMBER;
END AP_WEB_CC_NOTIFICATIONS_PKG;

 

/
