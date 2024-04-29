--------------------------------------------------------
--  DDL for Package Body OKL_BPD_ADVANCED_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_ADVANCED_BILLING_PUB" AS
/* $Header: OKLPABLB.pls 120.4 2005/10/30 04:01:16 appldev noship $ */

  ------------------------------------------------------------------
  -- Procedure advanced_billing to bill outstanding stream elements
  ------------------------------------------------------------------

PROCEDURE advanced_billing
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2
	,p_from_bill_date	IN  DATE
	,p_to_bill_date		IN  DATE
    ,p_source           IN  VARCHAR2
    ,x_ar_inv_tbl       OUT NOCOPY ar_inv_tbl_type
 )
IS

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_name		CONSTANT VARCHAR2(30)  := 'OKL_BPD_ADVANCED_BILLING_PUB';
	l_return_status	   	     VARCHAR2(1)   := Okl_Api.G_RET_STS_SUCCESS;
	l_data			         VARCHAR2(100);
	l_count			         NUMBER;
	l_contract_number	     okc_k_headers_b.contract_number%TYPE;
	l_from_bill_date	     DATE;
	l_to_bill_date		     DATE;

  BEGIN

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;

	SAVEPOINT sp_bill_streams;

	l_contract_number	:= p_contract_number;
	l_from_bill_date	:= p_from_bill_date;
	l_to_bill_date		:= p_to_bill_date;

	------------------------------------------------------------
	-- Call process API to do advance billing
	------------------------------------------------------------
	OKL_BPD_ADVANCED_BILLING_PVT.advanced_billing (
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status		=> l_return_status,
			x_msg_count		    => x_msg_count,
			x_msg_data		    => x_msg_data,
			p_contract_number	=> l_contract_number,
			p_from_bill_date	=> l_from_bill_date,
			p_to_bill_date		=> l_to_bill_date,
            p_source            => p_source,
            x_ar_inv_tbl        => x_ar_inv_tbl);

            x_return_status		:= l_return_status;
  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Fnd_Api.G_EXC_ERROR THEN

		ROLLBACK TO sp_bill_streams;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

	WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

		ROLLBACK TO sp_bill_streams;
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

	WHEN OTHERS THEN

		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);


END advanced_billing;

PROCEDURE advanced_billing_conc (
                errbuf  OUT NOCOPY VARCHAR2,
                retcode OUT NOCOPY NUMBER,
                p_from_bill_date  IN VARCHAR2,
                p_to_bill_date  IN VARCHAR2,
                p_contract_number  IN VARCHAR2
        )
IS
  l_api_version     NUMBER := 1;
  lx_msg_count      NUMBER;
  l_from_bill_date  DATE;
  l_to_bill_date    DATE;
  l_msg_index_out   NUMBER :=0;
  lx_msg_data       VARCHAR2(450);
  lx_return_status  VARCHAR2(1);
  l_request_id      NUMBER;
  x_ar_inv_tbl      OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type;
BEGIN

    IF p_from_bill_date IS NOT NULL THEN
        l_from_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_bill_date);
    END IF;

    IF p_to_bill_date IS NOT NULL THEN
        l_to_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_bill_date);
    END IF;

    OKL_BPD_ADVANCED_BILLING_PUB.advanced_billing (
                p_api_version     => l_api_version,
                p_init_msg_list   => Okl_Api.G_FALSE,
                x_return_status   => lx_return_status,
                x_msg_count       => lx_msg_count,
                x_msg_data        => errbuf,
                p_contract_number => p_contract_number,
                p_from_bill_date  => l_from_bill_date,
	            p_to_bill_date	  => l_to_bill_date,
                p_source          => 'ADVANCE_RECEIPTS',
                x_ar_inv_tbl      => x_ar_inv_tbl
                );

    IF lx_msg_count > 0 THEN
       FOR i IN 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => lx_msg_data,
                             p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);
      END LOOP;
    END IF;

   EXCEPTION
      WHEN OTHERS THEN
          FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Some Error');
   END advanced_billing_conc;


END OKL_BPD_ADVANCED_BILLING_PUB;

/
