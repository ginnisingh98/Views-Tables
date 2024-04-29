--------------------------------------------------------
--  DDL for Package GCS_ELIM_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ELIM_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: gcselimruless.pls 120.1 2005/10/30 05:17:57 appldev noship $ */

  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Inserts a row the
  --   gcs_elim_rules_b  and gcs_elim_rules_b table.
  -- Arguments
  --	 row_id
  --	 RULE_ID
  --	 SEEDED_RULE_FLAG
  --	 TRANSACTION_TYPE_CODE
  --	 RULE_TYPE_CODE
  --	 FROM_TREATMENT_ID
  --	 TO_TREATMENT_ID
  --	 ENABLED_FLAG
  --	 OBJECT_VERSION_NUMBER
  --	 LAST_UPDATE_DATE
  --	 LAST_UPDATED_BY
  --	 CREATION_DATE
  --	 CREATED_BY
  --	 LAST_UPDATE_LOGIN
  --     RULE_NAME
  --	 DESCRIPTION


  -- Example
  --   GCS_ELIM_RULES_PKG.Insert_Row(...);
  -- Notes
  --


PROCEDURE Insert_Row
(
	 row_id	IN OUT NOCOPY VARCHAR2,
	 RULE_ID NUMBER,
	 SEEDED_RULE_FLAG VARCHAR2,
	 TRANSACTION_TYPE_CODE VARCHAR2,
	 RULE_TYPE_CODE VARCHAR2,
	 FROM_TREATMENT_ID NUMBER,
	 TO_TREATMENT_ID NUMBER,
	 ENABLED_FLAG VARCHAR2,
	 OBJECT_VERSION_NUMBER NUMBER,
	 LAST_UPDATE_DATE DATE,
	 LAST_UPDATED_BY NUMBER,
	 CREATION_DATE DATE,
	 CREATED_BY NUMBER,
	 LAST_UPDATE_LOGIN NUMBER,
	 RULE_NAME VARCHAR2,
	 DESCRIPTION VARCHAR2
);

   --****************************************

  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates  a row in the
  --   gcs_elim_rules_b table.
  -- Arguments
	-- row_id
	-- RULE_ID
	-- SEEDED_RULE_FLAG
	-- TRANSACTION_TYPE_CODE
	-- RULE_TYPE_CODE
	-- FROM_TREATMENT_ID
	-- TO_TREATMENT_ID
	-- ENABLED_FLAG
	-- OBJECT_VERSION_NUMBER
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_LOGIN
	-- RULE_NAME
	-- DESCRIPTION


  -- Example
  --   GCS_ELIM_RULES_PKG.Update_Row(...);
  -- Notes
  --

PROCEDURE Update_Row
(
	 row_id	IN OUT NOCOPY           VARCHAR2,
	 RULE_ID 			NUMBER,
	 SEEDED_RULE_FLAG	        VARCHAR2,
	 TRANSACTION_TYPE_CODE 		VARCHAR2,
	 RULE_TYPE_CODE			 VARCHAR2,
	 FROM_TREATMENT_ID 		NUMBER,
	 TO_TREATMENT_ID 		NUMBER,
	 ENABLED_FLAG 			VARCHAR2,
	 OBJECT_VERSION_NUMBER 		NUMBER,
	 LAST_UPDATE_DATE 		DATE,
	 LAST_UPDATED_BY 		NUMBER,
	 CREATION_DATE 			DATE,
	 CREATED_BY 			NUMBER,
	 LAST_UPDATE_LOGIN 		NUMBER,
	 RULE_NAME			VARCHAR2,
	 DESCRIPTION			VARCHAR2
);
 --****************************************

  -- Procedure
  --   Load_Row
  -- Purpose
  --   loads a row in the
  --   gcs_elim_rules_b table.
  -- Arguments
	-- row_id
	-- RULE_ID
	-- SEEDED_RULE_FLAG
	-- TRANSACTION_TYPE_CODE
	-- RULE_TYPE_CODE
	-- FROM_TREATMENT_ID
	-- TO_TREATMENT_ID
	-- ENABLED_FLAG
	-- OBJECT_VERSION_NUMBER
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_LOGIN
	-- owner
	-- custom_mode
	-- RULE_NAME
	-- DESCRIPTION


  -- Example
  --   GCS_ELIM_RULES_PKG.Load_Row(...);
  -- Notes
  --

PROCEDURE Load_Row
(
	 row_id	          IN OUT NOCOPY VARCHAR2,
	 RULE_ID                         NUMBER,
	 SEEDED_RULE_FLAG                VARCHAR2,
	 TRANSACTION_TYPE_CODE           VARCHAR2,
	 RULE_TYPE_CODE                  VARCHAR2,
	 FROM_TREATMENT_ID               NUMBER,
	 TO_TREATMENT_ID                 NUMBER,
	 ENABLED_FLAG                    VARCHAR2,
	 OBJECT_VERSION_NUMBER           NUMBER,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 owner                           varchar2,
	 custom_mode                     varchar2,
	 RULE_NAME                       VARCHAR2,
	 DESCRIPTION                     VARCHAR2
 );


  -- Procedure
  --   Translate_Row
  -- Purpose
  --   Updates translated infromation for a row in the
  --   gcs_elim_rules_tl table.
  -- Arguments
	-- RULE_ID
	-- LANGUAGE
	-- SOURCE_LANG
	-- RULE_NAME
	-- DESCRIPTION
	-- LAST_UPDATE_DATE
	-- LAST_UPDATED_BY
	-- CREATION_DATE
	-- CREATED_BY
	-- LAST_UPDATE_LOGIN
	-- owner
	-- custom_mode
	-- RULE_NAME
	-- DESCRIPTION

  -- Example
  --   GCS_ELIM_RULES_PKG.Translate_Row(...);
  -- Notes
  --


 PROCEDURE Translate_Row
 (
	 RULE_ID                         NUMBER,
	 RULE_NAME                       VARCHAR2,
	 DESCRIPTION                     VARCHAR2,
	 LAST_UPDATE_DATE                DATE,
	 LAST_UPDATED_BY                 NUMBER,
	 CREATION_DATE                   DATE,
	 CREATED_BY                      NUMBER,
	 LAST_UPDATE_LOGIN               NUMBER,
	 owner                           VARCHAR2,
	 custom_mode                     VARCHAR2
 );

procedure ADD_LANGUAGE ;



END GCS_ELIM_RULES_PKG;

 

/
