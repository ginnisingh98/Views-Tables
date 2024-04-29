--------------------------------------------------------
--  DDL for Package ASO_PARTY_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PARTY_RELATIONSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: asotpars.pls 120.1 2005/06/29 12:39:48 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PARTY_RELATIONSHIPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PARTY_RELATIONSHIP_ID   IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
          p_RELATIONSHIP_TYPE_CODE    VARCHAR,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Update_Row(
          p_PARTY_RELATIONSHIP_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
	     p_RELATIONSHIP_TYPE_CODE    VARCHAR,
          p_OBJECT_VERSION_NUMBER  NUMBER
	  );

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_PARTY_RELATIONSHIP_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_QUOTE_HEADER_ID    NUMBER,
          p_QUOTE_LINE_ID    NUMBER,
          p_OBJECT_TYPE_CODE    VARCHAR2,
          p_OBJECT_ID    NUMBER,
	  p_RELATIONSHIP_TYPE_CODE    VARCHAR);

PROCEDURE Delete_Row(
    p_PARTY_RELATIONSHIP_ID  NUMBER);
End ASO_PARTY_RELATIONSHIPS_PKG;

 

/
