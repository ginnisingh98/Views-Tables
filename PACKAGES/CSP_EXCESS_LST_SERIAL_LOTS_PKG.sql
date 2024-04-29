--------------------------------------------------------
--  DDL for Package CSP_EXCESS_LST_SERIAL_LOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_EXCESS_LST_SERIAL_LOTS_PKG" AUTHID CURRENT_USER as
/* $Header: csptesls.pls 115.6 2003/02/27 23:41:02 ajosephg ship $ */
-- Start of Comments
-- Package name     : CSP_EXCESS_LST_SERIAL_LOTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_EXCESS_LIST_SERIAL_LOT_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_LINE_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2,
          p_REVISION VARCHAR2,
          p_LOCATOR_ID NUMBER);

PROCEDURE Update_Row(
          p_EXCESS_LIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_LINE_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2,
          p_REVISION VARCHAR2,
          p_LOCATOR_ID NUMBER);


PROCEDURE Lock_Row(
          p_EXCESS_LIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_LINE_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2,
          p_REVISION VARCHAR2,
          p_LOCATOR_ID NUMBER);

PROCEDURE Delete_Row(
    p_EXCESS_LIST_SERIAL_LOT_ID  NUMBER);
End CSP_EXCESS_LST_SERIAL_LOTS_PKG;

 

/
