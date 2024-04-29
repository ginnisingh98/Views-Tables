--------------------------------------------------------
--  DDL for Package CSP_PACKLIST_SERIAL_LOTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PACKLIST_SERIAL_LOTS_PKG" AUTHID CURRENT_USER AS
/* $Header: cspttsps.pls 115.4 2002/11/26 07:18:28 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PACKLIST_SERIAL_LOTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PACKLIST_SERIAL_LOT_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PACKLIST_LINE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2);

PROCEDURE Update_Row(
          p_PACKLIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE   DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PACKLIST_LINE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2);

PROCEDURE Lock_Row(
          p_PACKLIST_SERIAL_LOT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PACKLIST_LINE_ID    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_INVENTORY_ITEM_ID    NUMBER,
          p_QUANTITY    NUMBER,
          p_LOT_NUMBER    VARCHAR2,
          p_SERIAL_NUMBER    VARCHAR2);

PROCEDURE Delete_Row(
    p_PACKLIST_SERIAL_LOT_ID  NUMBER);
End CSP_PACKLIST_SERIAL_LOTS_PKG;

 

/
