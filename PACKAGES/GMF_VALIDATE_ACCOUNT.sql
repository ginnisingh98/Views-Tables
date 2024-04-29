--------------------------------------------------------
--  DDL for Package GMF_VALIDATE_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_VALIDATE_ACCOUNT" AUTHID CURRENT_USER AS
/* $Header: gmfactvs.pls 115.2 2003/08/05 20:09:42 vchukkap noship $ */

  --
  -- plsql table to store Acct Unit and Acct Number combination
  --
  TYPE acct_combination_TabType IS TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;

  --
  -- plsql table to store error message returned from call to validate_segs FND call
  --
  TYPE error_messages_TabType IS TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;

  --
  -- In case cross-validation procedure is called from form or concurrent program
  -- this plsql record will be populated with all invalid combinations and error
  -- messages
  --
  TYPE error_messages_RecType IS RECORD
  (
	acct_combination	acct_combination_TabType,
	error_messages		error_messages_TabType
  );
  errors	error_messages_RecType;

  --
  -- Main cross-validation procedure which performs Cross-Validation.
  -- Will be called from SubLedger program and from next procedure which
  -- in turn is called from form
  --
  PROCEDURE validate_segments
  (
	p_co_code		IN		gl_plcy_mst.co_code%TYPE,
	p_acctg_unit_id		IN		gl_accu_mst.acctg_unit_id%TYPE,
	p_acct_id		IN		gl_acct_mst.acct_id%TYPE,
	p_acctg_unit_no		IN		gl_accu_mst.acctg_unit_no%TYPE,
	p_acct_no		IN		gl_acct_mst.acct_no%TYPE,
	p_create_combination	IN		VARCHAR2 DEFAULT 'N',
	x_ccid			OUT NOCOPY	NUMBER,
	x_concat_seg		OUT NOCOPY	VARCHAR2,
	x_status		OUT NOCOPY	VARCHAR2,
	x_errmsg		OUT NOCOPY	VARCHAR2
  );


  --
  -- This procedure is called from account mapping form. Generates combinations
  -- using all Account Units defined for the company and calls above procedure
  -- to perform cross-validation.
  --
  -- Bug 3080232. Added additional parameter p_acct_no.
  PROCEDURE cross_validate
  (
	p_co_code		IN		gl_plcy_mst.co_code%TYPE,
	p_acct_id		IN		gl_acct_mst.acct_id%TYPE,
	p_called_from		IN		VARCHAR2,
	x_status		OUT NOCOPY	VARCHAR2,
	p_acct_no		IN		gl_acct_mst.acct_no%TYPE DEFAULT NULL
  );

  --
  -- Procedure to validate the accu and acct combination.
  -- If combination or accu/acct ids exits then returns respective ids. Otherwise,
  -- if p_create_acct = 'Y', then creates code combination in GL and
  -- creates the accu and acct in OPM and returns accu_id and acct_id.
  --
  PROCEDURE get_accu_acct_ids
  (
	p_co_code		IN		gl_plcy_mst.co_code%TYPE,
	p_acctg_unit_no		IN		gl_accu_mst.acctg_unit_no%TYPE,
	p_acct_no		IN		gl_acct_mst.acct_no%TYPE,
	p_create_acct		IN		VARCHAR2 DEFAULT 'N',
	x_acctg_unit_id		OUT NOCOPY	gl_accu_mst.acctg_unit_id%TYPE,
	x_acct_id		OUT NOCOPY	gl_acct_mst.acct_id%TYPE,
	x_ccid			OUT NOCOPY	NUMBER,
	x_status		OUT NOCOPY	VARCHAR2,
	x_errmsg		OUT NOCOPY	VARCHAR2
  );

  -- Function to return account no
  FUNCTION get_acct_no (
	p_co_code		IN	gl_acct_mst.co_code%TYPE,
	p_acct_id		IN	gl_acct_mst.acct_id%TYPE
  ) 	RETURN VARCHAR2;


  -- Function to return account unit no
  FUNCTION get_acctg_unit_no (
	p_co_code		IN	gl_accu_mst.co_code%TYPE,
	p_acctg_unit_id		IN	gl_accu_mst.acctg_unit_id%TYPE
  ) 	RETURN VARCHAR2;

  --
  -- Fuction to return error messages record type to forms.
  --
  FUNCTION get_error_messages RETURN error_messages_RecType;

END gmf_validate_account;

 

/
