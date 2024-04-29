--------------------------------------------------------
--  DDL for Package ASO_LINE_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_LINE_RELATIONSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: asotlins.pls 120.1 2005/06/29 12:39:19 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_LINE_RELATIONSHIPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_LINE_RELATIONSHIP_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_LINE_ID    NUMBER,
          p_RELATED_QUOTE_LINE_ID    NUMBER,
          p_RECIPROCAL_FLAG    VARCHAR2,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER);

PROCEDURE Update_Row(
          p_LINE_RELATIONSHIP_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_LINE_ID    NUMBER,
          p_RELATED_QUOTE_LINE_ID    NUMBER,
          p_RECIPROCAL_FLAG    VARCHAR2,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_LINE_RELATIONSHIP_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_LINE_ID    NUMBER,
          p_RELATED_QUOTE_LINE_ID    NUMBER,
          p_RECIPROCAL_FLAG    VARCHAR2,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2);

PROCEDURE Delete_Row(
    p_LINE_RELATIONSHIP_ID  NUMBER);
End ASO_LINE_RELATIONSHIPS_PKG;

 

/
