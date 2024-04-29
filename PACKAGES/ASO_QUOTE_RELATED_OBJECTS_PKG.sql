--------------------------------------------------------
--  DDL for Package ASO_QUOTE_RELATED_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_RELATED_OBJECTS_PKG" AUTHID CURRENT_USER as
/* $Header: asotobjs.pls 120.1 2005/06/29 12:39:27 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_RELATED_OBJECTS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_RELATED_OBJECT_ID   IN OUT NOCOPY /* file.sql.39 change */   NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_OBJECT_TYPE_CODE    VARCHAR2,
          p_QUOTE_OBJECT_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_RECIPROCAL_FLAG    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER

		);
       --   p_QUOTE_OBJECT_CODE    NUMBER);

PROCEDURE Update_Row(
          p_RELATED_OBJECT_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_OBJECT_TYPE_CODE    VARCHAR2,
          p_QUOTE_OBJECT_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_RECIPROCAL_FLAG    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);
     --     p_QUOTE_OBJECT_CODE    NUMBER);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_RELATED_OBJECT_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_OBJECT_TYPE_CODE    VARCHAR2,
          p_QUOTE_OBJECT_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR2,
          p_RECIPROCAL_FLAG    VARCHAR2);
     --     p_QUOTE_OBJECT_CODE    NUMBER);

PROCEDURE Delete_Row(
    p_RELATED_OBJECT_ID  NUMBER);
End ASO_QUOTE_RELATED_OBJECTS_PKG;

 

/
