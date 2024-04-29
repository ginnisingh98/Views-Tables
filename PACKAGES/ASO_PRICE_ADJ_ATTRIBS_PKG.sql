--------------------------------------------------------
--  DDL for Package ASO_PRICE_ADJ_ATTRIBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PRICE_ADJ_ATTRIBS_PKG" AUTHID CURRENT_USER as
/* $Header: asotpaas.pls 120.1 2005/06/29 12:39:34 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PRICE_ADJ_ATTRIBS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PRICE_ADJ_ATTRIB_ID   IN OUT NOCOPY /* file.sql.39 change */   NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID    NUMBER,
          p_PRICE_ADJUSTMENT_ID    NUMBER,
          p_PRICING_CONTEXT    VARCHAR2,
          p_PRICING_ATTRIBUTE    VARCHAR2,
          p_PRICING_ATTR_VALUE_FROM    VARCHAR2,
          p_PRICING_ATTR_VALUE_TO    VARCHAR2,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_FLEX_TITLE    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Update_Row(
          p_PRICE_ADJ_ATTRIB_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID    NUMBER,
          p_PRICE_ADJUSTMENT_ID    NUMBER,
          p_PRICING_CONTEXT    VARCHAR2,
          p_PRICING_ATTRIBUTE    VARCHAR2,
          p_PRICING_ATTR_VALUE_FROM    VARCHAR2,
          p_PRICING_ATTR_VALUE_TO    VARCHAR2,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_FLEX_TITLE    VARCHAR2,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_PRICE_ADJ_ATTRIB_ID    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID    NUMBER,
          p_PRICE_ADJUSTMENT_ID    NUMBER,
          p_PRICING_CONTEXT    VARCHAR2,
          p_PRICING_ATTRIBUTE    VARCHAR2,
          p_PRICING_ATTR_VALUE_FROM    VARCHAR2,
          p_PRICING_ATTR_VALUE_TO    VARCHAR2,
          p_COMPARISON_OPERATOR    VARCHAR2,
          p_FLEX_TITLE    VARCHAR2);

PROCEDURE Delete_Row(
    p_PRICE_ADJ_ATTRIB_ID  NUMBER);
End ASO_PRICE_ADJ_ATTRIBS_PKG;

 

/
