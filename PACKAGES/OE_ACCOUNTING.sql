--------------------------------------------------------
--  DDL for Package OE_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ACCOUNTING" AUTHID CURRENT_USER AS
/* $Header: OEXACCTS.pls 115.1 99/08/23 10:48:57 porting sh $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_ACCOUNTING';

  -----------------------------------------------------------------
  --
  -- Function Name: Get_Uninvoiced_Commitment_Bal
  -- Parameter:     p_customer_trx_id.
  -- Return   :     Number.
  --
  -- The purpose of this function is to calculate the uninvoiced
  -- commitment balance for a given commitment_id, in Order Entry.
  -- This function is called by Account Receivables.
  -- This function is provided by OE for interoperability purpose
  -- between old OE and new OE.
  --
  -- total uninvoiced commitment balance =
  --     total of order lines associated with a particular commitment
  --		that are not interfaced to AR yet.
  --
  ------------------------------------------------------------------
  FUNCTION Get_Uninvoiced_Commitment_Bal
	(p_customer_trx_id IN NUMBER
	)
  RETURN NUMBER;
--  pragma restrict_references( get_uninvoiced_commitment_bal, WNDS,WNPS);


END OE_ACCOUNTING;

 

/
