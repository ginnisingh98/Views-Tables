--------------------------------------------------------
--  DDL for Package Body IBY_EXTENSIBILITY_CALLOUTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EXTENSIBILITY_CALLOUTS_PUB" AS
/* $Header: ibyextcb.pls 120.0.12010000.2 2009/09/02 17:29:46 bkjain ship $ */


  FUNCTION isCentralBankReportingRequired(p_payment_id IN NUMBER,
                                          x_return_status OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_cbr_flag VARCHAR2(1);

  BEGIN

    -- initialize api return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_cbr_flag := 'X';

    RETURN l_cbr_flag;

  END isCentralBankReportingRequired;


  FUNCTION isCentralBankReportingRequired(p_payment_id IN NUMBER,
                                          p_trx_cbr_index	      IN BINARY_INTEGER,
                                          x_return_status OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2
  IS
    l_cbr_flag VARCHAR2(1);

  BEGIN

    l_cbr_flag := isCentralBankReportingRequired(p_payment_id,
                                                    x_return_status);
    RETURN l_cbr_flag;

  END isCentralBankReportingRequired;


END IBY_EXTENSIBILITY_CALLOUTS_PUB;



/
