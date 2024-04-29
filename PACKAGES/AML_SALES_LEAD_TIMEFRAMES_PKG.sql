--------------------------------------------------------
--  DDL for Package AML_SALES_LEAD_TIMEFRAMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_SALES_LEAD_TIMEFRAMES_PKG" AUTHID CURRENT_USER as
/* $Header: amlttfrs.pls 115.5 2003/01/03 23:45:12 ckapoor noship $ */
-- Start of Comments
-- Package name     : AML_SALES_LEAD_TIMEFRAMES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_TIMEFRAME_ID   IN OUT NOCOPY NUMBER
         ,p_DECISION_TIMEFRAME_CODE  IN  VARCHAR2
         ,p_TIMEFRAME_DAYS IN   NUMBER
         ,p_CREATION_DATE in DATE
	 ,p_CREATED_BY in NUMBER
	 ,p_LAST_UPDATE_DATE in DATE
	 ,p_LAST_UPDATED_BY in NUMBER
  	 ,p_LAST_UPDATE_LOGIN in NUMBER
  	 ,p_ENABLED_FLAG in VARCHAR2

         );

PROCEDURE Update_Row(
          p_TIMEFRAME_ID    NUMBER
         ,p_DECISION_TIMEFRAME_CODE   in VARCHAR2
         ,p_TIMEFRAME_DAYS   in NUMBER
         ,p_CREATION_DATE in DATE
	 ,p_CREATED_BY in NUMBER
         ,p_LAST_UPDATE_DATE in DATE
	 ,p_LAST_UPDATED_BY in NUMBER
  	 ,p_LAST_UPDATE_LOGIN in NUMBER
  	 ,p_ENABLED_FLAG  in VARCHAR2
         );

PROCEDURE Lock_Row(
          p_TIMEFRAME_ID   in NUMBER
         ,p_DECISION_TIMEFRAME_CODE  in  VARCHAR2
         ,p_TIMEFRAME_DAYS  in  NUMBER
         ,p_CREATION_DATE in DATE
	 ,p_CREATED_BY in NUMBER
	 ,p_LAST_UPDATE_DATE in DATE
	 ,p_LAST_UPDATED_BY in NUMBER
  	 ,p_LAST_UPDATE_LOGIN in NUMBER
  	 , p_ENABLED_FLAG in VARCHAR2
);

PROCEDURE Delete_Row(
    p_TIMEFRAME_ID in NUMBER);

    PROCEDURE Load_Row(
            X_TIMEFRAME_ID in OUT NOCOPY NUMBER,
            X_DECISION_TIMEFRAME_CODE in VARCHAR2,
            X_TIMEFRAME_DAYS in NUMBER,
        	X_OWNER in VARCHAR2,
        	X_ENABLED_FLAG in VARCHAR2);

End AML_SALES_LEAD_TIMEFRAMES_PKG;

 

/
