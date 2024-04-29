--------------------------------------------------------
--  DDL for Package GME_ERES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_ERES_PKG" AUTHID CURRENT_USER AS
/* $Header: GMEVERSS.pls 120.1 2005/09/23 12:15 srpuri noship $ */


   PROCEDURE INSERT_EVENT(P_EVENT_NAME VARCHAR2,
                          P_EVENT_KEY VARCHAR2,
                          P_USER_KEY_LABEL VARCHAR2,
                          P_USER_KEY_VALUE VARCHAR2,
                          P_POST_OP_API VARCHAR2,
                          P_PARENT_EVENT VARCHAR2,
                          P_PARENT_EVENT_KEY VARCHAR2,
                          P_PARENT_ERECORD_ID NUMBER,
                          X_STATUS  OUT  NOCOPY VARCHAR2);


  FUNCTION GET_ITEM_NUMBER(P_ORGANIZATION_ID NUMBER,
                            P_INVENTORY_ITEM_ID NUMBER) RETURN VARCHAR2;

  FUNCTION GET_OPRN_NO(P_OPRN_ID NUMBER)  RETURN VARCHAR2;

  FUNCTION GET_EVENT_XML (P_EVENT_NAME VARCHAR2,P_EVENT_KEY VARCHAR2) RETURN CLOB;
END;

 

/
