--------------------------------------------------------
--  DDL for Package IBY_ACCT_VAL_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ACCT_VAL_EXT_PUB" AUTHID CURRENT_USER AS
/* $Header: ibybnkvles.pls 120.0.12010000.2 2009/12/28 12:38:01 vkarlapu noship $ */


  --
  -- This API is called while creating the bank account or updating the
  -- external bank account
  --
  Procedure Validate_ext_bank_acct(p_ext_bank_acct_rec  IN
                                   IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
                                   x_return_status     OUT NOCOPY VARCHAR2,
                                   x_error_msg         OUT NOCOPY VARCHAR2);


END IBY_ACCT_VAL_EXT_PUB;



/
