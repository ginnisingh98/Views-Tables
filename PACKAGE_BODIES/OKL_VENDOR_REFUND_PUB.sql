--------------------------------------------------------
--  DDL for Package Body OKL_VENDOR_REFUND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDOR_REFUND_PUB" AS
/* $Header: OKLPRFDB.pls 115.6 2003/04/25 14:09:58 jsanju noship $ */

  ----------------------------------------------------------------------
  -- PROCEDURE GENERATE_VENDOR_REFUND
  ----------------------------------------------------------------------
  PROCEDURE GENERATE_VENDOR_REFUND
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY NUMBER,
    p_contract_number    IN VARCHAR2
  )
  IS

  BEGIN

    SAVEPOINT GENERATE_VENDOR_REFUND;
    OKL_VENDOR_REFUND_PVT.GENERATE_VENDOR_REFUND
      (
        errbuf               => errbuf,
        retcode              => retcode,
        p_contract_number    => p_contract_number
      );
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO GENERATE_VENDOR_REFUND;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
  END GENERATE_VENDOR_REFUND;

END OKL_VENDOR_REFUND_PUB;

/
