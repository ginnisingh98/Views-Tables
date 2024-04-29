--------------------------------------------------------
--  DDL for Package GCS_INTERCO_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_INTERCO_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsintercorules.pls 120.1 2005/10/30 05:18:52 appldev noship $ */

   -- Procedure
   --   Insert_Row
   -- Purpose
   --   Inserts a row into the gcs_interco_rules_b table.
   -- Arguments
	 --row_id
	 --RULE_ID
	 --ENABLED_FLAG
	 --THRESHOLD_AMOUNT
	 --THRESHOLD_CURRENCY
	 --OBJECT_VERSION_NUMBER
	 --CREATION_DATE
	 --CREATED_BY
	 --LAST_UPDATE_DATE
	 --LAST_UPDATED_BY
	 --LAST_UPDATE_LOGIN
	 --SUS_FINANCIAL_ELEM_ID
	 --SUS_PRODUCT_ID
	 --SUS_NATURAL_ACCOUNT_ID
	 --SUS_CHANNEL_ID
	 --SUS_LINE_ITEM_ID
	 --SUS_PROJECT_ID
	 --SUS_CUSTOMER_ID
	 --SUS_TASK_ID
	 --SUS_USER_DIM1_ID
	 --SUS_USER_DIM2_ID
	 --SUS_USER_DIM3_ID
	 --SUS_USER_DIM4_ID
	 --SUS_USER_DIM5_ID
	 --SUS_USER_DIM6_ID
	 --SUS_USER_DIM7_ID
	 --SUS_USER_DIM8_ID
	 --SUS_USER_DIM9_ID
	 --SUS_USER_DIM10_ID
	 --RULE_NAME
	 --DESCRIPTION

   -- Example
   --   GCS_INTERCO_RULES_PKG.Insert_Row(...);
   -- Notes
   --

 PROCEDURE Insert_Row
 (
	 row_id	IN OUT NOCOPY            VARCHAR2,
	 RULE_ID                         NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 THRESHOLD_AMOUNT                NUMBER,
	 THRESHOLD_CURRENCY              VARCHAR2,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 SUS_FINANCIAL_ELEM_ID           NUMBER,
	 SUS_PRODUCT_ID                  NUMBER,
	 SUS_NATURAL_ACCOUNT_ID          NUMBER,
	 SUS_CHANNEL_ID                  NUMBER,
	 SUS_LINE_ITEM_ID                NUMBER,
	 SUS_PROJECT_ID                  NUMBER,
	 SUS_CUSTOMER_ID                 NUMBER,
	 SUS_TASK_ID                     NUMBER,
	 SUS_USER_DIM1_ID                NUMBER,
	 SUS_USER_DIM2_ID                NUMBER,
	 SUS_USER_DIM3_ID                NUMBER,
	 SUS_USER_DIM4_ID                NUMBER,
	 SUS_USER_DIM5_ID                NUMBER,
	 SUS_USER_DIM6_ID                NUMBER,
	 SUS_USER_DIM7_ID                NUMBER,
	 SUS_USER_DIM8_ID                NUMBER,
	 SUS_USER_DIM9_ID                NUMBER,
	 SUS_USER_DIM10_ID               NUMBER,
	 RULE_NAME                       varchar2,
	 DESCRIPTION                     varchar2
);


   -- Procedure
   --   Update_Row
   -- Purpose
   --   Updates a row into the gcs_interco_rules_b table.
   -- Arguments
	-- row_id
	-- RULE_ID
	-- ENABLED_FLAG
	-- THRESHOLD_AMOUNT
	-- THRESHOLD_CURRENCY
	-- CREATION_DATE
	-- CREATED_BY
	-- OBJECT_VERSION_NUMBER
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- LAST_UPDATE_LOGIN
	-- SUS_FINANCIAL_ELEM_ID
	-- SUS_PRODUCT_ID
	-- SUS_NATURAL_ACCOUNT_ID
	-- SUS_CHANNEL_ID
	-- SUS_LINE_ITEM_ID
	-- SUS_PROJECT_ID
	-- SUS_CUSTOMER_ID
	-- SUS_TASK_ID
	-- SUS_USER_DIM1_ID
	-- SUS_USER_DIM2_ID
	-- SUS_USER_DIM3_ID
	-- SUS_USER_DIM4_ID
	-- SUS_USER_DIM5_ID
	-- SUS_USER_DIM6_ID
	-- SUS_USER_DIM7_ID
	-- SUS_USER_DIM8_ID
	-- SUS_USER_DIM9_ID
	-- SUS_USER_DIM10_ID
	-- RULE_NAME
	-- DESCRIPTION

   -- Example
   --   GCS_INTERCO_RULES_PKG.Update_Row(...);
   -- Notes
   --


 PROCEDURE Update_Row
 (
	 row_id	IN OUT NOCOPY            VARCHAR2,
	 RULE_ID                         NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 THRESHOLD_AMOUNT                NUMBER,
	 THRESHOLD_CURRENCY              VARCHAR2,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 SUS_FINANCIAL_ELEM_ID           NUMBER,
	 SUS_PRODUCT_ID                  NUMBER,
	 SUS_NATURAL_ACCOUNT_ID          NUMBER,
	 SUS_CHANNEL_ID                  NUMBER,
	 SUS_LINE_ITEM_ID                NUMBER,
	 SUS_PROJECT_ID                  NUMBER,
	 SUS_CUSTOMER_ID                 NUMBER,
	 SUS_TASK_ID                     NUMBER,
	 SUS_USER_DIM1_ID                NUMBER,
	 SUS_USER_DIM2_ID                NUMBER,
	 SUS_USER_DIM3_ID                NUMBER,
	 SUS_USER_DIM4_ID                NUMBER,
	 SUS_USER_DIM5_ID                NUMBER,
	 SUS_USER_DIM6_ID                NUMBER,
	 SUS_USER_DIM7_ID                NUMBER,
	 SUS_USER_DIM8_ID                NUMBER,
	 SUS_USER_DIM9_ID                NUMBER,
	 SUS_USER_DIM10_ID               NUMBER,
	 RULE_NAME                       varchar2,
	 DESCRIPTION                     varchar2
);



   -- Procedure
   --   Load_Row
   -- Purpose
   --   loads a row into the gcs_interco_rules_b table.
   -- Arguments
	-- row_id
	-- RULE_ID
	-- ENABLED_FLAG
	-- THRESHOLD_AMOUNT
	-- THRESHOLD_CURRENCY
	-- CREATION_DATE
	-- CREATED_BY
	-- OBJECT_VERSION_NUMBER
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- LAST_UPDATE_LOGIN
	-- SUS_FINANCIAL_ELEM_ID
	-- SUS_PRODUCT_ID
	-- SUS_NATURAL_ACCOUNT_ID
	-- SUS_CHANNEL_ID
	-- SUS_LINE_ITEM_ID
	-- SUS_PROJECT_ID
	-- SUS_CUSTOMER_ID
	-- SUS_TASK_ID
	-- SUS_USER_DIM1_ID
	-- SUS_USER_DIM2_ID
	-- SUS_USER_DIM3_ID
	-- SUS_USER_DIM4_ID
	-- SUS_USER_DIM5_ID
	-- SUS_USER_DIM6_ID
	-- SUS_USER_DIM7_ID
	-- SUS_USER_DIM8_ID
	-- SUS_USER_DIM9_ID
	-- SUS_USER_DIM10_ID
	-- RULE_NAME
	-- DESCRIPTION
	-- owner
	-- custom_mode

   -- Example
   --   GCS_INTERCO_RULES_PKG.Load_Row(...);
   -- Notes
   --
PROCEDURE Load_Row
(
	 row_id	IN OUT NOCOPY            VARCHAR2,
	 RULE_ID                         NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 THRESHOLD_AMOUNT                NUMBER,
	 THRESHOLD_CURRENCY              VARCHAR2,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 SUS_FINANCIAL_ELEM_ID           NUMBER,
	 SUS_PRODUCT_ID                  NUMBER,
	 SUS_NATURAL_ACCOUNT_ID          NUMBER,
	 SUS_CHANNEL_ID                  NUMBER,
	 SUS_LINE_ITEM_ID                NUMBER,
	 SUS_PROJECT_ID                  NUMBER,
	 SUS_CUSTOMER_ID                 NUMBER,
	 SUS_TASK_ID                     NUMBER,
	 SUS_USER_DIM1_ID                NUMBER,
	 SUS_USER_DIM2_ID                NUMBER,
	 SUS_USER_DIM3_ID                NUMBER,
	 SUS_USER_DIM4_ID                NUMBER,
	 SUS_USER_DIM5_ID                NUMBER,
	 SUS_USER_DIM6_ID                NUMBER,
	 SUS_USER_DIM7_ID                NUMBER,
	 SUS_USER_DIM8_ID                NUMBER,
	 SUS_USER_DIM9_ID                NUMBER,
	 SUS_USER_DIM10_ID               NUMBER,
	 RULE_NAME                       varchar2,
	 DESCRIPTION                     varchar2,
	 owner varchar2,
	 custom_mode varchar2
);


   -- Procedure
   --   Translate_Row
   -- Purpose
   --   Translates a row into the gcs_interco_rules_tl table.
   -- Arguments
	-- RULE_ID
	-- LANGUAGE
	-- SOURCE_LANG
	-- RULE_NAME
	-- OBJECT_VERSION_NUMBER
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- LAST_UPDATE_LOGIN
	-- DESCRIPTION
	-- owner
	-- custom_mode

   -- Example
   --   GCS_INTERCO_RULES_PKG.Translate_Row(...);
   -- Notes
   --

 PROCEDURE Translate_Row
 (
	 RULE_ID                         NUMBER,
	 RULE_NAME                       VARCHAR2,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 DESCRIPTION                     VARCHAR2,
	 owner varchar2,
	 custom_mode varchar2

 );

 procedure ADD_LANGUAGE ;


END GCS_INTERCO_RULES_PKG;

 

/
