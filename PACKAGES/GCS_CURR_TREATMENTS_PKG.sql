--------------------------------------------------------
--  DDL for Package GCS_CURR_TREATMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CURR_TREATMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_curr_trts.pls 120.1 2005/10/30 05:17:17 appldev noship $ */

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row into the gcs_curr_treatments_b and gcs_curr_treatments_tl table.
  -- Arguments
  --	 row_id
  --	 CURR_TREATMENT_ID
  --	 ENDING_RATE_TYPE
  --	 AVERAGE_RATE_TYPE
  --	 EQUITY_MODE_CODE
  --	 INC_STMT_MODE_CODE
  --	 ENABLED_FLAG
  --	 DEFAULT_FLAG
  -- 	 FINANCIAL_ELEM_ID
  --	 PRODUCT_ID
  --	 NATURAL_ACCOUNT_ID
  --	 CHANNEL_ID
  --	 LINE_ITEM_ID
  --	 PROJECT_ID
  --	 CUSTOMER_ID
  --	 CTA_USER_DIM1_ID
  --	 CTA_USER_DIM2_ID
  --	 CTA_USER_DIM3_ID
  --	 CTA_USER_DIM4_ID
  --	 CTA_USER_DIM5_ID
  --	 CTA_USER_DIM6_ID
  --	 CTA_USER_DIM7_ID
  --	 CTA_USER_DIM8_ID
  --	 CTA_USER_DIM9_ID
  --	 CTA_USER_DIM10_ID
  --	 TASK_ID
  --	 CREATION_DATE
  --	 CREATED_BY
  --	 LAST_UPDATE_DATE
  --	 LAST_UPDATED_BY
  --	 LAST_UPDATE_LOGIN
  --	 OBJECT_VERSION_NUMBER
  --	 CURR_TREATMENT_NAME
  --	 DESCRIPTION

  -- Example
  --   GCS_CURR_TREATMENTS_PKG.Insert_Row(...);
  -- Notes
  --


 PROCEDURE Insert_Row
 (
	 row_id	IN OUT NOCOPY	         VARCHAR2,
	 CURR_TREATMENT_ID               NUMBER,
	 ENDING_RATE_TYPE                VARCHAR2,
	 AVERAGE_RATE_TYPE               VARCHAR2,
	 EQUITY_MODE_CODE                VARCHAR2,
	 INC_STMT_MODE_CODE              VARCHAR2,
	 ENABLED_FLAG                    VARCHAR2,
	 DEFAULT_FLAG                    VARCHAR2,
	 FINANCIAL_ELEM_ID               NUMBER,
	 PRODUCT_ID                      NUMBER,
	 NATURAL_ACCOUNT_ID              NUMBER,
	 CHANNEL_ID                      NUMBER,
	 LINE_ITEM_ID                    NUMBER,
	 PROJECT_ID                      NUMBER,
	 CUSTOMER_ID                     NUMBER,
	 CTA_USER_DIM1_ID                NUMBER,
	 CTA_USER_DIM2_ID                NUMBER,
	 CTA_USER_DIM3_ID                NUMBER,
	 CTA_USER_DIM4_ID                NUMBER,
	 CTA_USER_DIM5_ID                NUMBER,
	 CTA_USER_DIM6_ID                NUMBER,
	 CTA_USER_DIM7_ID                NUMBER,
	 CTA_USER_DIM8_ID                NUMBER,
	 CTA_USER_DIM9_ID                NUMBER,
	 CTA_USER_DIM10_ID               NUMBER,
	 TASK_ID                         NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CURR_TREATMENT_NAME             VARCHAR2,
	 DESCRIPTION                     VARCHAR2
);



--
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Updates a row in the gcs_curr_treatments_b table.
  -- Arguments
  	-- row_id
  	-- CURR_TREATMENT_ID
  	-- ENDING_RATE_TYPE
  	-- AVERAGE_RATE_TYPE
  	-- EQUITY_MODE_CODE
  	-- INC_STMT_MODE_CODE
  	-- ENABLED_FLAG
  	-- DEFAULT_FLAG
  	-- LAST_UPDATE_DATE
  	-- LAST_UPDATED_BY
  	-- CREATION_DATE
  	-- CREATED_BY
  	-- LAST_UPDATE_LOGIN
  	-- FINANCIAL_ELEM_ID
  	-- PRODUCT_ID
  	-- NATURAL_ACCOUNT_ID
  	-- CHANNEL_ID
  	-- LINE_ITEM_ID
  	-- PROJECT_ID
  	-- CUSTOMER_ID
  	-- CTA_USER_DIM1_ID
  	-- CTA_USER_DIM2_ID
  	-- CTA_USER_DIM3_ID
  	-- CTA_USER_DIM4_ID
  	-- CTA_USER_DIM5_ID
  	-- CTA_USER_DIM6_ID
  	-- CTA_USER_DIM7_ID
  	-- CTA_USER_DIM8_ID
  	-- CTA_USER_DIM9_ID
  	-- CTA_USER_DIM10_ID
  	-- TASK_ID
  	-- OBJECT_VERSION_NUMBER
  	-- CURR_TREATMENT_NAME
  	-- DESCRIPTION

  -- Example
  --   GCS_CURR_TREATMENTS_PKG.Update_Row(...);
  -- Notes
  --


  PROCEDURE Update_Row
  (
	 row_id	IN OUT NOCOPY	         VARCHAR2,
	 CURR_TREATMENT_ID               NUMBER,
	 ENDING_RATE_TYPE                VARCHAR2,
	 AVERAGE_RATE_TYPE               VARCHAR2,
	 EQUITY_MODE_CODE                VARCHAR2,
	 INC_STMT_MODE_CODE              VARCHAR2,
	 ENABLED_FLAG                    VARCHAR2,
	 DEFAULT_FLAG                    VARCHAR2,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 FINANCIAL_ELEM_ID               NUMBER,
	 PRODUCT_ID                      NUMBER,
	 NATURAL_ACCOUNT_ID              NUMBER,
	 CHANNEL_ID                      NUMBER,
	 LINE_ITEM_ID                    NUMBER,
	 PROJECT_ID                      NUMBER,
	 CUSTOMER_ID                     NUMBER,
	 CTA_USER_DIM1_ID                NUMBER,
	 CTA_USER_DIM2_ID                NUMBER,
	 CTA_USER_DIM3_ID                NUMBER,
	 CTA_USER_DIM4_ID                NUMBER,
	 CTA_USER_DIM5_ID                NUMBER,
	 CTA_USER_DIM6_ID                NUMBER,
	 CTA_USER_DIM7_ID                NUMBER,
	 CTA_USER_DIM8_ID                NUMBER,
	 CTA_USER_DIM9_ID                NUMBER,
	 CTA_USER_DIM10_ID               NUMBER,
	 TASK_ID                         NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CURR_TREATMENT_NAME             VARCHAR2,
	 DESCRIPTION                     VARCHAR2
);




   -- Procedure
   --   Load_Row
   -- Purpose
   --   Loads a row in the gcs_curr_treatments_b table.
   -- Arguments
	 --row_id
	 --CURR_TREATMENT_ID
	 --ENDING_RATE_TYPE
	 --AVERAGE_RATE_TYPE
	 --EQUITY_MODE_CODE
	 --INC_STMT_MODE_CODE
	 --ENABLED_FLAG
	 --DEFAULT_FLAG
	 --LAST_UPDATE_DATE
	 --LAST_UPDATED_BY
	 --CREATION_DATE
	 --CREATED_BY
	 --LAST_UPDATE_LOGIN
	 --FINANCIAL_ELEM_ID
	 --PRODUCT_ID
	 --NATURAL_ACCOUNT_ID
	 --CHANNEL_ID
	 --LINE_ITEM_ID
	 --PROJECT_ID
	 --CUSTOMER_ID
	 --CTA_USER_DIM1_ID
	 --CTA_USER_DIM2_ID
	 --CTA_USER_DIM3_ID
	 --CTA_USER_DIM4_ID
	 --CTA_USER_DIM5_ID
	 --CTA_USER_DIM6_ID
	 --CTA_USER_DIM7_ID
	 --CTA_USER_DIM8_ID
	 --CTA_USER_DIM9_ID
	 --CTA_USER_DIM10_ID
	 --TASK_ID
	 --OBJECT_VERSION_NUMBER
         --CURR_TREATMENT_NAME
	 --DESCRIPTION
	 --owner
	 --custom_mode

   -- Example
   --   GCS_CURR_TREATMENTS_PKG.Update_Row(...);
   -- Notes
   --

  PROCEDURE Load_Row
  (
	 row_id	IN OUT NOCOPY	         VARCHAR2,
	 CURR_TREATMENT_ID               NUMBER,
	 ENDING_RATE_TYPE                VARCHAR2,
	 AVERAGE_RATE_TYPE               VARCHAR2,
	 EQUITY_MODE_CODE                VARCHAR2,
	 INC_STMT_MODE_CODE              VARCHAR2,
	 ENABLED_FLAG                    VARCHAR2,
	 DEFAULT_FLAG                    VARCHAR2,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 FINANCIAL_ELEM_ID               NUMBER,
	 PRODUCT_ID                      NUMBER,
	 NATURAL_ACCOUNT_ID              NUMBER,
	 CHANNEL_ID                      NUMBER,
	 LINE_ITEM_ID                    NUMBER,
	 PROJECT_ID                      NUMBER,
	 CUSTOMER_ID                     NUMBER,
	 CTA_USER_DIM1_ID                NUMBER,
	 CTA_USER_DIM2_ID                NUMBER,
	 CTA_USER_DIM3_ID                NUMBER,
	 CTA_USER_DIM4_ID                NUMBER,
	 CTA_USER_DIM5_ID                NUMBER,
	 CTA_USER_DIM6_ID                NUMBER,
	 CTA_USER_DIM7_ID                NUMBER,
	 CTA_USER_DIM8_ID                NUMBER,
	 CTA_USER_DIM9_ID                NUMBER,
	 CTA_USER_DIM10_ID               NUMBER,
	 TASK_ID                         NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
         CURR_TREATMENT_NAME             VARCHAR2,
	 DESCRIPTION                     VARCHAR2,
	 owner				 VARCHAR2,
	 custom_mode                     varchar2
  );




   -- Procedure
   --   Load_Row
   -- Purpose
   --   Translates a row in the gcs_curr_treatments_tl table.
   -- Arguments
	-- CURR_TREATMENT_ID
	-- LANGUAGE
	-- SOURCE_LANG
	-- CURR_TREATMENT_NAME
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_LOGIN
	-- DESCRIPTION
        -- owner
	-- custom_mode

   -- Example
   --   GCS_CURR_TREATMENTS_PKG.Translate_Row(...);
   -- Notes
   --

 PROCEDURE Translate_Row
 (
	 CURR_TREATMENT_ID                NUMBER,
	 CURR_TREATMENT_NAME              VARCHAR2,
	 LAST_UPDATE_DATE                 DATE,
	 LAST_UPDATED_BY                  NUMBER,
	 CREATION_DATE                    DATE,
	 CREATED_BY                       NUMBER,
	 LAST_UPDATE_LOGIN                NUMBER,
	 DESCRIPTION                      VARCHAR2,
         owner				  VARCHAR2,
	 custom_mode                      varchar2

 );


 PROCEDURE ADD_LANGUAGE;

END GCS_CURR_TREATMENTS_PKG;

 

/
