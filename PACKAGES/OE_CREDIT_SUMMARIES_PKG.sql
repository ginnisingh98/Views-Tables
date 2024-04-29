--------------------------------------------------------
--  DDL for Package OE_CREDIT_SUMMARIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREDIT_SUMMARIES_PKG" AUTHID CURRENT_USER AS
-- $Header: OEXCRSMS.pls 120.0 2005/06/01 22:46:17 appldev noship $
--------------------
-- TYPE DECLARATIONS
--------------------

------------
-- CONSTANTS
------------

-------------------
-- PUBLIC VARIABLES
-------------------

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------

--=====================================================================
--NAME:         Insert_Row
--TYPE:         PRIVATE
--COMMENTS:     Insert a row into the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--=====================================================================

PROCEDURE Insert_Row
  ( p_cust_account_id            IN  NUMBER
  , p_org_id                     IN  NUMBER
  , p_site_use_id                IN  NUMBER
  , p_currency_code              IN  VARCHAR2
  , p_balance_type               IN  NUMBER
  , p_balance                    IN  NUMBER
  , p_creation_date              IN  DATE
  , p_created_by                 IN  NUMBER
  , p_last_update_date           IN  DATE
  , p_last_updated_by            IN  NUMBER
  , p_last_update_login          IN  NUMBER
  , p_program_application_id     IN  NUMBER
  , p_program_id                 IN  NUMBER
  , p_program_update_date        IN  DATE
  , p_request_id                 IN  NUMBER
  , p_exposure_source_code       IN  VARCHAR2
  );

--=====================================================================
--NAME:         Update_Row
--TYPE:         PRIVATE
--COMMENTS:     Update a row in the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--=====================================================================

PROCEDURE Update_Row
  ( p_row_id                     IN  VARCHAR2
  , p_balance                    IN  NUMBER
  , p_last_update_date           IN  DATE
  , p_last_updated_by            IN  NUMBER
  , p_last_update_login          IN  NUMBER
  , p_program_application_id     IN  NUMBER
  , p_program_id                 IN  NUMBER
  , p_program_update_date        IN  DATE
  , p_request_id                 IN  NUMBER
  );

--=====================================================================
--NAME:         Delete_Row
--TYPE:         PRIVATE
--COMMENTS:     Delete a row in the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--=====================================================================

PROCEDURE Delete_Row
  ( p_row_id                     IN  VARCHAR2
  );

END OE_CREDIT_SUMMARIES_PKG;

 

/
