--------------------------------------------------------
--  DDL for Package CSI_MASS_EDIT_ENTRIES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_MASS_EDIT_ENTRIES_B_PKG" AUTHID CURRENT_USER as
/* $Header: csitmeds.pls 120.1.12010000.2 2008/11/06 20:29:36 mashah ship $ */
-- Start of Comments
-- Package name     : CSI_MASS_EDIT_ENTRIES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_ENTRY_ID   IN OUT NOCOPY NUMBER,
          px_TXN_LINE_ID IN OUT NOCOPY NUMBER,
          px_TXN_LINE_DETAIL_ID IN OUT NOCOPY NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SCHEDULE_DATE    DATE,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_NAME            VARCHAR2,
          p_BATCH_TYPE      VARCHAR2,
          p_DESCRIPTION     VARCHAR2,
          p_SYSTEM_CASCADE  VARCHAR2
       );

PROCEDURE Update_Row(
          p_ENTRY_ID    NUMBER,
          p_TXN_LINE_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SCHEDULE_DATE    DATE,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_NAME            VARCHAR2,
          p_BATCH_TYPE      VARCHAR2,
          p_DESCRIPTION     VARCHAR2,
          p_SYSTEM_CASCADE  VARCHAR2
        );

PROCEDURE Lock_Row(
          p_ENTRY_ID    NUMBER,
          p_TXN_LINE_ID    NUMBER,
          p_STATUS_CODE    VARCHAR2,
          p_SCHEDULE_DATE    DATE,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_NAME             VARCHAR2
        );

PROCEDURE Delete_Row(
    p_ENTRY_ID  NUMBER);

PROCEDURE add_language;

PROCEDURE translate_row (
          p_entry_id     IN     NUMBER  ,
          p_name         IN     VARCHAR2,
	      p_owner        IN     VARCHAR2
                        );

End CSI_MASS_EDIT_ENTRIES_B_PKG;


/
