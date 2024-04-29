--------------------------------------------------------
--  DDL for Package OKL_VENDOR_REFUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VENDOR_REFUND_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRFDS.pls 115.5 2003/04/25 04:15:08 smereddy noship $ */

  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VENDOR_REFUND_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKL';

  l_MsgLevel NUMBER := NVL(to_number(FND_PROFILE.VALUE('FND_AS_MSG_LEVEL_THRESHOLD')),
                      FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

   TYPE error_rec_type IS RECORD (
			contract_number     okc_k_headers_b.contract_number%type,
			cure_type           okl_cure_amounts.cure_type%type,
   			cure_amount          okl_cure_amounts.cure_amount%type
	);

    TYPE error_tbl_type IS TABLE OF error_rec_type
           INDEX BY BINARY_INTEGER;

   TYPE error_message_type IS TABLE OF VARCHAR2(2000)
   INDEX BY BINARY_INTEGER;

  l_error_tbl    error_tbl_type;
  l_success_tbl  error_tbl_type;
  l_success_idx  NUMBER;
  l_error_idx    NUMBER;

  /*
    This is a concurrent process that is used to identify non delinquent contracts
    for refund based on vendor program rules. It calculates vendor's elgibility for
    refund using vendor program rules.
  */

  PROCEDURE GENERATE_VENDOR_REFUND(
    errbuf              OUT NOCOPY VARCHAR2,
    retcode             OUT NOCOPY NUMBER,
    p_contract_number     IN VARCHAR2
  );

 PROCEDURE write_log(mesg_level IN NUMBER, mesg IN VARCHAR2);


END OKL_VENDOR_REFUND_PVT;

 

/
