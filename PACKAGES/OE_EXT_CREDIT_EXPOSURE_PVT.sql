--------------------------------------------------------
--  DDL for Package OE_EXT_CREDIT_EXPOSURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_EXT_CREDIT_EXPOSURE_PVT" AUTHID CURRENT_USER AS
-- $Header: OEXVECES.pls 120.1.12000000.1 2007/01/16 22:09:29 appldev ship $
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
--NAME:         Import_Credit_Exposure
--TYPE:         PRIVATE
--COMMENTS:     This procedure validates the rows in the interface table
--              and load them into the OE_CREDIT_SUMMARIES table.
--Parameters:
--IN
--OUT
--Version:  	Current Version   	1.0
--              Previous Version  	1.0
--=====================================================================

PROCEDURE Import_Credit_Exposure
  ( p_api_version                IN  NUMBER
  , p_org_id                     IN  NUMBER
  , p_exposure_source_code       IN  VARCHAR2
  , p_batch_id                   IN  NUMBER
  , p_validate_only              IN  VARCHAR2
  , x_num_rows_to_process        OUT NOCOPY NUMBER
  , x_num_rows_validated         OUT NOCOPY NUMBER
  , x_num_rows_failed            OUT NOCOPY NUMBER
  , x_num_rows_imported          OUT NOCOPY NUMBER
  );

--=====================================================================
--NAME:         Purge
--TYPE:         PRIVATE
--DESCRIPTION:  This procedure delete external exposure from the summary
--              table.
--Parameters:
--IN
--OUT
--=====================================================================
PROCEDURE Purge
  ( p_org_id                  IN  NUMBER
  , p_exposure_source_code    IN  VARCHAR2
  );

END OE_EXT_CREDIT_EXPOSURE_PVT;

 

/
