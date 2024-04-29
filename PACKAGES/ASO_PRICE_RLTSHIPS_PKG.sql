--------------------------------------------------------
--  DDL for Package ASO_PRICE_RLTSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PRICE_RLTSHIPS_PKG" AUTHID CURRENT_USER as
/* $Header: asotprls.pls 120.1 2005/06/29 12:40:12 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_PRICE_RELATIONSHIPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_ADJ_RELATIONSHIP_ID  IN OUT NOCOPY /* file.sql.39 change */  NUMBER,
          p_CREATION_DATE                  DATE,
          p_CREATED_BY                   NUMBER,
          p_LAST_UPDATE_DATE         DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN      NUMBER,
          p_PROGRAM_APPLICATION_ID NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID     NUMBER,
          p_QUOTE_LINE_ID  NUMBER,
          p_PRICE_ADJUSTMENT_ID  NUMBER,
          p_RLTD_PRICE_ADJ_ID  NUMBER,
		p_quote_shipment_id                         NUMBER := NULL,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Update_Row(
          p_ADJ_RELATIONSHIP_ID   NUMBER,
          p_CREATION_DATE                  DATE,
          p_CREATED_BY                   NUMBER,
          p_LAST_UPDATE_DATE         DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN      NUMBER,
          p_PROGRAM_APPLICATION_ID NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID     NUMBER,
          p_QUOTE_LINE_ID  NUMBER,
          p_PRICE_ADJUSTMENT_ID  NUMBER,
          p_RLTD_PRICE_ADJ_ID  NUMBER,
		p_quote_shipment_id  NUMBER,
          p_OBJECT_VERSION_NUMBER  NUMBER
		);

PROCEDURE Lock_Row(
          --p_OBJECT_VERSION_NUMBER  NUMBER,
          p_ADJ_RELATIONSHIP_ID   NUMBER,
          p_CREATION_DATE                  DATE,
          p_CREATED_BY                   NUMBER,
          p_LAST_UPDATE_DATE         DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN      NUMBER,
          p_PROGRAM_APPLICATION_ID NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_REQUEST_ID     NUMBER,
          p_QUOTE_LINE_ID  NUMBER,
          p_PRICE_ADJUSTMENT_ID  NUMBER,
          p_RLTD_PRICE_ADJ_ID  NUMBER,
		p_quote_shipment_id                         NUMBER := NULL);

PROCEDURE Delete_Row(
    p_ADJ_RELATIONSHIP_ID  NUMBER);

End ASO_PRICE_RLTSHIPS_PKG;

 

/
