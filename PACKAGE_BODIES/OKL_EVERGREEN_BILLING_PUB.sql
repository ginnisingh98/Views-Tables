--------------------------------------------------------
--  DDL for Package Body OKL_EVERGREEN_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_EVERGREEN_BILLING_PUB" AS
/* $Header: OKLPEGBB.pls 115.6 2004/04/13 10:44:10 rnaik noship $ */

  ------------------------------------------------------------------
  -- Procedure BIL_STREAMS to bill outstanding stream elements
  ------------------------------------------------------------------

  PROCEDURE bill_evg_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL) IS

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_name		CONSTANT VARCHAR2(30)  := 'BILL_STREAMS';
	l_return_status		VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_data			VARCHAR2(100);
	l_count			NUMBER;
	l_contract_number	okc_k_headers_b.contract_number%TYPE;
	l_from_bill_date	DATE;
	l_to_bill_date		DATE;

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
	------------------------------------------------------------


	------------------------------------------------------------
	------------------------------------------------------------


	------------------------------------------------------------
	-- Call process API to bill streams
	------------------------------------------------------------

	Okl_Evergreen_Billing_Pvt.BILL_EVERGREEN_STREAMS(
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status		=> l_return_status,
			x_msg_count		=> x_msg_count,
			x_msg_data		=> x_msg_data,
			p_contract_number	=> l_contract_number,
			p_from_bill_date	=> l_from_bill_date,
			p_to_bill_date		=> l_to_bill_date);


	IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
		RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

	------------------------------------------------------------
	------------------------------------------------------------


	------------------------------------------------------------
	------------------------------------------------------------



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


  END bill_evg_streams;



PROCEDURE bill_evg_streams_conc (
                errbuf  OUT NOCOPY VARCHAR2,
                retcode OUT NOCOPY NUMBER,
                p_from_bill_date  IN VARCHAR2,
                p_to_bill_date  IN VARCHAR2,
                p_contract_number  IN VARCHAR2
                )
IS

  l_api_version   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_from_bill_date   DATE;
  l_to_bill_date     DATE;
  l_count1          NUMBER :=0;
  l_count2          NUMBER :=0;
  l_count           NUMBER :=0;
  I                 NUMBER :=0;
  l_msg_index_out   NUMBER :=0;
  lx_msg_data    VARCHAR2(450);
  lx_return_status  VARCHAR2(1);

BEGIN

    IF p_from_bill_date IS NOT NULL THEN
    l_from_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_bill_date);
    END IF;

    IF p_to_bill_date IS NOT NULL THEN
    l_to_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_bill_date);
    END IF;


    FND_FILE.PUT_LINE (FND_FILE.LOG, 'From Bill Date  = ' ||p_from_bill_date);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'To Bill Date    = ' ||p_to_bill_date);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number = ' ||p_contract_number);


         Okl_Evergreen_Billing_Pub.BILL_EVG_STREAMS(
                p_api_version   => l_api_version,
                p_init_msg_list => Okl_Api.G_FALSE,
                x_return_status => lx_return_status,
                x_msg_count     => lx_msg_count,
                x_msg_data      => errbuf,
                p_contract_number => p_contract_number,
                p_from_bill_date	=> l_from_bill_date,
	            p_to_bill_date		=> l_to_bill_date);


    BEGIN
       IF lx_msg_count > 0 THEN
         FOR i IN 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);
         END LOOP;
       END IF;
    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

    END;
   EXCEPTION
      WHEN OTHERS THEN
          NULL ;
   END bill_evg_streams_conc;


END Okl_Evergreen_Billing_Pub;

/
