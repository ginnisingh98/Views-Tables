--------------------------------------------------------
--  DDL for Package CSC_PROF_BLOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_BLOCKS_PKG" AUTHID CURRENT_USER as
/* $Header: csctpvas.pls 120.1 2005/08/26 02:48:07 adhanara noship $ */
-- Start of Comments
-- Package name     : CSC_PROF_BLOCKS_PKG
-- Purpose          :
-- History          :
--	03 Nov 00	axsubram	Added Load_row and Translate_row for NLS (#1487860)
-- 15 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_BLOCK_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    	 NUMBER,
          p_CREATION_DATE    	 DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER,
          p_BLOCK_NAME         VARCHAR2,
          p_DESCRIPTION        VARCHAR2,
          p_START_DATE_ACTIVE  DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG        VARCHAR2,
          p_BLOCK_NAME_CODE    VARCHAR2,
          p_OBJECT_CODE 	      VARCHAR2,
          p_SQL_STMNT_FOR_DRILLDOWN    VARCHAR2,
          p_SQL_STMNT          VARCHAR2,
	  p_BATCH_SQL_STMNT    VARCHAR2,
          p_SELECT_CLAUSE      VARCHAR2,
          p_CURRENCY_CODE      VARCHAR2,
          p_FROM_CLAUSE        VARCHAR2,
          p_WHERE_CLAUSE       VARCHAR2,
          p_OTHER_CLAUSE       VARCHAR2,
          p_BLOCK_LEVEL        VARCHAR2,
          x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
          p_APPLICATION_ID NUMBER);

PROCEDURE Update_Row(
          p_BLOCK_ID           NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER,
          p_BLOCK_NAME         VARCHAR2,
          p_DESCRIPTION        VARCHAR2,
          p_START_DATE_ACTIVE  DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG        VARCHAR2,
          p_BLOCK_NAME_CODE    VARCHAR2,
          p_OBJECT_CODE        VARCHAR2,
          p_SQL_STMNT_FOR_DRILLDOWN    VARCHAR2,
          p_SQL_STMNT          VARCHAR2,
	  p_BATCH_SQL_STMNT    VARCHAR2,
          p_SELECT_CLAUSE      VARCHAR2,
          p_CURRENCY_CODE      VARCHAR2,
          p_FROM_CLAUSE        VARCHAR2,
          p_WHERE_CLAUSE       VARCHAR2,
          p_OTHER_CLAUSE       VARCHAR2,
          p_BLOCK_LEVEL        VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID NUMBER);

PROCEDURE Lock_Row(
          p_BLOCK_ID                 NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_BLOCK_ID              NUMBER,
    p_OBJECT_VERSION_NUMBER NUMBER);

PROCEDURE Add_Language;

PROCEDURE	 Translate_Row(
		p_block_id	NUMBER,
		p_block_name	VARCHAR2,
		p_description	VARCHAR2,
		p_owner		VARCHAR2);

PROCEDURE Load_Row(
          p_BLOCK_ID           NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE   DATE,
          p_LAST_UPDATE_LOGIN  NUMBER,
          p_BLOCK_NAME         VARCHAR2,
          p_DESCRIPTION        VARCHAR2,
          p_START_DATE_ACTIVE  DATE,
          p_END_DATE_ACTIVE    DATE,
          p_SEEDED_FLAG        VARCHAR2,
          p_BLOCK_NAME_CODE    VARCHAR2,
          p_OBJECT_CODE        VARCHAR2,
          p_SQL_STMNT_FOR_DRILLDOWN    VARCHAR2,
          p_SQL_STMNT          VARCHAR2,
          p_BATCH_SQL_STMNT    VARCHAR2,
          p_SELECT_CLAUSE      VARCHAR2,
          p_CURRENCY_CODE      VARCHAR2,
          p_FROM_CLAUSE        VARCHAR2,
          p_WHERE_CLAUSE       VARCHAR2,
          p_OTHER_CLAUSE       VARCHAR2,
          p_BLOCK_LEVEL        VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID NUMBER,
		p_owner		      VARCHAR2);

End CSC_PROF_BLOCKS_PKG;

 

/
