--------------------------------------------------------
--  DDL for Package OKL_VENDOR_REFUND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_REFUND_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRFDS.pls 115.3 2003/04/25 04:15:26 smereddy noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VENDOR_REFUND_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKL';

   ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ---------------------------------------------------------------------------

  /*
    This is a concurrent process that is used to identify
    delinquent contracts and based on vendor program rules calculate
    the Cure and Repurchase Amounts.
    Note: Calculation of Cure and Repurchase is allowed only
          for those contract that have Vendor Programs that
          allow cures and repurchases.
  */
  PROCEDURE GENERATE_VENDOR_REFUND(
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    p_contract_number   IN VARCHAR2
  );

END OKL_VENDOR_REFUND_PUB;

 

/
