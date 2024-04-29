--------------------------------------------------------
--  DDL for Package CSP_USG_TRANSACTION_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_USG_TRANSACTION_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: csptutts.pls 115.0 2003/05/29 18:00:16 sunarasi noship $ */
-- Start of Comments
-- Package name     : CSP_USG_TRANSACTION_TYPES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_USG_TRANSACTION_TYPE_ID   IN OUT NOCOPY NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
	 ,p_FORECAST_RULE_ID NUMBER
	 ,p_TRANSACTION_TYPE_ID NUMBER);

PROCEDURE Update_Row(
          p_USG_TRANSACTION_TYPE_ID   IN NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
	 ,p_FORECAST_RULE_ID NUMBER
	 ,p_TRANSACTION_TYPE_ID NUMBER);

PROCEDURE Lock_Row(
          p_USG_TRANSACTION_TYPE_ID   IN NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_CREATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
	 ,p_FORECAST_RULE_ID NUMBER
	 ,p_TRANSACTION_TYPE_ID NUMBER);

PROCEDURE Delete_Row(
    p_USG_TRANSACTION_TYPE_ID  NUMBER);
End CSP_USG_TRANSACTION_TYPES_PKG;

 

/
