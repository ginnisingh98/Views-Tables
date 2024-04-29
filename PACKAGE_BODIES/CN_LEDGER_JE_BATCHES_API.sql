--------------------------------------------------------
--  DDL for Package Body CN_LEDGER_JE_BATCHES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_LEDGER_JE_BATCHES_API" as
/* $Header: cnsbjbb.pls 115.0 99/07/16 07:15:47 porting ship $ */

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
			 X_who		VARCHAR2) return NUMBER IS
      Batch_Return NUMBER;
    BEGIN

      INSERT INTO cn_ledger_je_batches
	(batch_id, reason, who, status, total)
	VALUES (cn_ledger_je_batches_s.nextval, X_reason, X_who,
		'UNPOSTED', 0);

      SELECT cn_ledger_je_batches_s.currval INTO Batch_Return FROM dual;

      RETURN Batch_Return;

    END New_JE_Batch;

  --
  -- Procedure Name
  --    New_JE_Batch
  -- Purpose
  --    An API function which returns the batch ID of a newly created batch.
  --

  FUNCTION New_JE_Batch (X_reason	VARCHAR2,
			 X_who		VARCHAR2,
			 X_name         VARCHAR2,
			 X_date		DATE) return NUMBER IS
      Batch_Return NUMBER;
    BEGIN

      INSERT INTO cn_ledger_je_batches
	(batch_id, reason, who, status, total,
			batch_name, batch_date)
	VALUES (cn_ledger_je_batches_s.nextval, X_reason, X_who,
		'UNPOSTED', 0, X_name, X_date);

      SELECT cn_ledger_je_batches_s.currval INTO Batch_Return FROM dual;

      RETURN Batch_Return;

    END New_JE_Batch;

END CN_LEDGER_JE_BATCHES_API;

/
