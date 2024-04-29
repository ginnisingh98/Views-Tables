--------------------------------------------------------
--  DDL for Package CN_LEDGER_JE_BATCHES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_LEDGER_JE_BATCHES_API" AUTHID CURRENT_USER as
/* $Header: cnsbjbs.pls 115.0 99/07/16 07:15:50 porting ship $ */

/*
Date	  Name	     	Description
---------------------------------------------------------------------------
28-DEC-94 A. Lower	Created package


  Name	  : CN_LEDGER_JE_BATCHES_API
  Purpose : Provide functionality for creating journal batches and accessing
	    their properties.

  Notes   :

*/

  --
  -- Procedure Name
  --    New_JE_Batch
  -- Purpose
  --    An API function which returns the batch ID of a newly created batch.
  --

  FUNCTION New_JE_Batch (X_reason	VARCHAR2,
			 X_who		VARCHAR2) return NUMBER;

  --
  -- Procedure Name
  --    New_JE_Batch
  -- Purpose
  --    An API function which returns the batch ID of a newly created batch.
  --

  FUNCTION New_JE_Batch (X_reason	VARCHAR2,
			 X_who		VARCHAR2,
			 X_name         VARCHAR2,
			 X_date		DATE) return NUMBER;
END CN_LEDGER_JE_BATCHES_API;

 

/
