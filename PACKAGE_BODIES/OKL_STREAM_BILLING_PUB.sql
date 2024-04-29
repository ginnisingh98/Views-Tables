--------------------------------------------------------
--  DDL for Package Body OKL_STREAM_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAM_BILLING_PUB" AS
/* $Header: OKLPBSTB.pls 120.9 2008/02/07 13:16:15 zrehman noship $ */

  ------------------------------------------------------------------
  -- Procedure BIL_STREAMS to bill outstanding stream elements
  ------------------------------------------------------------------

  PROCEDURE bill_streams
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT Okc_Api.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
	,p_ia_contract_type     IN  VARCHAR2	DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_from_bill_date	IN  DATE	DEFAULT NULL
	,p_to_bill_date		IN  DATE	DEFAULT NULL
    ,p_cust_acct_id     IN NUMBER    DEFAULT NULL
    ,p_inv_cust_acct_id      IN NUMBER    DEFAULT NULL  --modified by zrehman for Bug#6788005 on 01-Feb-2008
    ,p_assigned_process  IN VARCHAR2 DEFAULT NULL)
 IS

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

	Okl_Stream_Billing_Pvt.bill_streams (
			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
			x_return_status		=> x_return_status,
			x_msg_count		    => x_msg_count,
			x_msg_data		    => x_msg_data,
            p_commit            => FND_API.G_TRUE,
			p_contract_number	=> l_contract_number,
			p_from_bill_date	=> l_from_bill_date,
			p_to_bill_date		=> l_to_bill_date,
            p_cust_acct_id      => p_cust_acct_id,
            p_assigned_process  => p_assigned_process);


	IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        NULL;
		--RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        NULL;
		--RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
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

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

		ROLLBACK TO sp_bill_streams;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

	WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

		ROLLBACK TO sp_bill_streams;
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

	WHEN OTHERS THEN

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);


  END bill_streams;



     PROCEDURE bill_streams_conc (
                errbuf  OUT NOCOPY VARCHAR2,
                retcode OUT NOCOPY NUMBER,
		p_ia_contract_type IN VARCHAR2, --modified by zrehman for Bug#6788005 on 01-Feb-2008
                p_from_bill_date  IN VARCHAR2,
                p_to_bill_date  IN VARCHAR2,
                p_contract_number  IN VARCHAR2,
                p_cust_acct_id     IN NUMBER,
		p_inv_cust_acct_id IN NUMBER, --modified by zrehman for Bug#6788005 on 01-Feb-2008
                p_assigned_process IN VARCHAR2
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

  l_request_id      NUMBER;

   CURSOR req_id_csr IS
	  SELECT
          DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
	  FROM dual;

   CURSOR txd_cnt_succ_csr( p_req_id NUMBER ) IS
          SELECT count(*)
          FROM okl_trx_ar_invoices_v a,
               okl_txl_ar_inv_lns_v b,
               okl_txd_ar_ln_dtls_v c
          WHERE a.id = b.tai_id AND
                b.id = c.til_id_details AND
                a.trx_status_code = 'PROCESSED' AND
                a.request_id = p_req_id ;

   CURSOR txd_cnt_err_csr( p_req_id NUMBER ) IS
          SELECT count(*)
          FROM okl_trx_ar_invoices_v a,
               okl_txl_ar_inv_lns_v b,
               okl_txd_ar_ln_dtls_v c
          WHERE a.id = b.tai_id AND
                b.id = c.til_id_details AND
                a.trx_status_code = 'ERROR' AND
                a.request_id = p_req_id ;

	------------------------------------------------------------
	-- Operating Unit
	------------------------------------------------------------
    CURSOR op_unit_csr IS
           SELECT NAME
           FROM hr_operating_units
	   WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID;--MOAC- Concurrent request


   l_succ_cnt    NUMBER;
   l_err_cnt     NUMBER;
   l_op_unit_name  hr_operating_units.name%TYPE;

BEGIN

   l_succ_cnt    := 0;
   l_err_cnt     := 0;

    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    IF p_from_bill_date IS NOT NULL THEN
        l_from_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_bill_date);
    END IF;

    IF p_to_bill_date IS NOT NULL THEN
        l_to_bill_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_bill_date);
    END IF;

    FND_FILE.PUT_LINE (FND_FILE.LOG, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Process Billable Streams Program');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'From Bill Date  = ' ||p_from_bill_date);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'To Bill Date    = ' ||p_to_bill_date);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Contract Number = ' ||p_contract_number);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Customer Account Id = ' ||p_cust_acct_id);
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Assigned Process = ' ||p_assigned_process);

         okl_stream_billing_pub.bill_streams (
                p_api_version      => l_api_version,
                p_init_msg_list    => Okl_Api.G_FALSE,
                x_return_status    => lx_return_status,
                x_msg_count        => lx_msg_count,
                x_msg_data         => errbuf,
		p_ia_contract_type => p_ia_contract_type, --modified by zrehman for Bug#6788005 on 01-Feb-2008
                p_contract_number  => p_contract_number,
                p_from_bill_date   => l_from_bill_date,
                p_to_bill_date     => l_to_bill_date,
                p_cust_acct_id     => p_cust_acct_id,
		p_inv_cust_acct_id      => p_inv_cust_acct_id, --modified by zrehman for Bug#6788005 on 01-Feb-2008
                p_assigned_process => p_assigned_process);

  if lx_return_status= 'W' then
    retcode := 1;
  end if;

   EXCEPTION
      WHEN OTHERS THEN
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

   END bill_streams_conc;


END Okl_Stream_Billing_Pub;

/
