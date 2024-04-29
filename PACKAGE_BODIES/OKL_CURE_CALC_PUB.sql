--------------------------------------------------------
--  DDL for Package Body OKL_CURE_CALC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_CALC_PUB" AS
/* $Header: OKLPCURB.pls 115.4 2003/01/06 19:14:20 jsanju noship $ */

  ----------------------------------------------------------------------
  -- PROCEDURE generate_cure_amount
  ----------------------------------------------------------------------
  PROCEDURE generate_cure_amount
  (
    errbuf               OUT NOCOPY VARCHAR2,
    retcode              OUT NOCOPY NUMBER,
    p_contract_number    IN VARCHAR2
  )
  IS

  BEGIN

    SAVEPOINT generate_cure_amount;
    OKL_CURE_CALC_PVT.generate_cure_amount
      (
        p_contract_number    => p_contract_number,
        errbuf               => errbuf,
        retcode              => retcode
      );
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO generate_cure_amount;
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS) => '||SQLERRM);
  END generate_cure_amount;

END OKL_CURE_CALC_PUB;

/
