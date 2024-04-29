--------------------------------------------------------
--  DDL for Package ASO_QUOTE_LINE_ATTRIBS_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_LINE_ATTRIBS_EXT_PKG" AUTHID CURRENT_USER as
/* $Header: asotlats.pls 120.1 2005/06/29 12:39:06 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_QUOTE_LINE_ATTRIBS_EXT_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_LINE_ATTRIBUTE_ID IN OUT NOCOPY /* file.sql.39 change */    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_APPLICATION_ID NUMBER,
          p_STATUS     VARCHAR2,
          p_QUOTE_LINE_ID    NUMBER,
          p_ATTRIBUTE_TYPE_CODE    VARCHAR2,
		p_QUOTE_HEADER_ID NUMBER,
		p_QUOTE_SHIPMENT_ID NUMBER,
          p_NAME    VARCHAR2,
          p_VALUE    VARCHAR2,
           p_VALUE_TYPE VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Update_Row(
          p_LINE_ATTRIBUTE_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_APPLICATION_ID NUMBER,
          p_STATUS     VARCHAR2,
          p_QUOTE_LINE_ID    NUMBER,
          p_ATTRIBUTE_TYPE_CODE    VARCHAR2,
		p_QUOTE_HEADER_ID NUMBER,
		p_QUOTE_SHIPMENT_ID NUMBER,
          p_NAME    VARCHAR2,
          p_VALUE    VARCHAR2,
          p_VALUE_TYPE VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_LINE_ATTRIBUTE_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
           p_APPLICATION_ID NUMBER,
           p_STATUS     VARCHAR2,
          p_QUOTE_LINE_ID    NUMBER,
          p_ATTRIBUTE_TYPE_CODE    VARCHAR2,
		p_QUOTE_HEADER_ID NUMBER,
		p_QUOTE_SHIPMENT_ID NUMBER,
          p_NAME    VARCHAR2,
          p_VALUE    VARCHAR2,
           p_VALUE_TYPE VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE);

PROCEDURE Delete_Row(
    p_LINE_ATTRIB_ID  NUMBER);

PROCEDURE Delete_Row(
    p_QUOTE_LINE_ID  NUMBER);

End ASO_QUOTE_LINE_ATTRIBS_EXT_PKG;

 

/
