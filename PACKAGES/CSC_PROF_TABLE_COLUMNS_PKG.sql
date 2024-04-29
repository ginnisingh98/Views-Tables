--------------------------------------------------------
--  DDL for Package CSC_PROF_TABLE_COLUMNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_TABLE_COLUMNS_PKG" AUTHID CURRENT_USER as
/* $Header: csctptcs.pls 120.1 2005/08/23 23:26:11 vshastry noship $ */
-- Start of Comments
-- Package name     : CSC_PROF_TABLE_COLUMNS_PKG
-- Purpose          :
-- History          : 24-Feb-2003, Introduced new procedure delete_existing_row to
--                    delete before loading the rows
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_TABLE_COLUMN_ID   IN OUT NOCOPY NUMBER,
          p_BLOCK_ID    NUMBER,
          p_TABLE_NAME    VARCHAR2,
          p_COLUMN_NAME    VARCHAR2,
          p_LABEL    VARCHAR2,
          p_TABLE_ALIAS VARCHAR2,
          p_COLUMN_SEQUENCE NUMBER,
		    p_DRILLDOWN_COLUMN_FLAG VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG   VARCHAR2,
          x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER);

PROCEDURE Update_Row(
          p_TABLE_COLUMN_ID    NUMBER,
          p_BLOCK_ID    NUMBER,
          p_TABLE_NAME    VARCHAR2,
          p_COLUMN_NAME    VARCHAR2,
          p_LABEL    VARCHAR2,
          p_TABLE_ALIAS VARCHAR2,
          p_COLUMN_SEQUENCE NUMBER,
		    p_DRILLDOWN_COLUMN_FLAG VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG   VARCHAR2,
          px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER);

procedure LOCK_ROW (
  P_TABLE_COLUMN_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
);

procedure DELETE_ROW (
  P_TABLE_COLUMN_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER NUMBER
);

Procedure Add_Language;

Procedure TRANSLATE_ROW (
   p_LABEL              in varchar2,
   p_TABLE_COLUMN_ID    in number,
   p_OWNER              in varchar2 );

Procedure DELETE_EXISTING_ROW(
   	p_BLOCK_ID		IN NUMBER,
   	p_TABLE_NAME   IN VARCHAR2,
   	p_COLUMN_NAME  IN VARCHAR2);

Procedure LOAD_ROW (
   p_TABLE_COLUMN_ID        in number,
   p_BLOCK_ID               in number,
   p_TABLE_NAME             in varchar2,
   p_COLUMN_NAME            in varchar2,
   p_LABEL                  in varchar2,
   p_ALIAS_NAME             in varchar2,
   p_COLUMN_SEQUENCE        in number,
   p_DRILLDOWN_COLUMN_FLAG  in varchar2,
   p_SEEDED_FLAG            in varchar2,
   p_last_update_date       IN DATE,
   p_last_updated_by        IN NUMBER,
   p_last_update_login      IN NUMBER);



End CSC_PROF_TABLE_COLUMNS_PKG;

 

/
