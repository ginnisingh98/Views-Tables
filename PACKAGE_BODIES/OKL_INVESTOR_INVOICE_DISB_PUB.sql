--------------------------------------------------------
--  DDL for Package Body OKL_INVESTOR_INVOICE_DISB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVESTOR_INVOICE_DISB_PUB" AS
/* $Header: OKLPIDBB.pls 120.5 2007/06/28 22:36:52 ssiruvol ship $ */

PROCEDURE OKL_INVESTOR_DISBURSEMENT_IN
        (p_api_version		IN  NUMBER
	    ,p_init_msg_list	IN  VARCHAR2
	    ,x_return_status	OUT NOCOPY VARCHAR2
	    ,x_msg_count		OUT NOCOPY NUMBER
	    ,x_msg_data		    OUT NOCOPY VARCHAR2
	    ,p_investor_agreement  IN  VARCHAR2
	    ,px_to_date		    IN  DATE)
IS
    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);


BEGIN

    SAVEPOINT OKL_INVESTOR_DISBURSEMENT;

    okl_investor_invoice_disb_pvt.OKL_INVESTOR_DISBURSEMENT(
        p_api_version		=> p_api_version
       ,p_init_msg_list	=> p_init_msg_list
	   ,x_return_status	=> x_return_status
	   ,x_msg_count		=> x_msg_count
       ,x_msg_data		   => x_msg_data
       ,p_investor_agreement => p_investor_agreement
	   ,p_to_date		    => px_to_date);

    IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	   RAISE Fnd_Api.G_EXC_ERROR;
    ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	   RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO OKL_INVESTOR_DISBURSEMENT;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO OKL_INVESTOR_DISBURSEMENT;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO OKL_INVESTOR_DISBURSEMENT;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_INVESTOR_INVOICE_DISB_PUB',
                              'OKL_INVESTOR_DISBURSEMENT');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END OKL_INVESTOR_DISBURSEMENT_IN;


PROCEDURE OKL_INVESTOR_DISBURSEMENT
        (errbuf	 OUT NOCOPY  VARCHAR2
	    ,retcode OUT NOCOPY  NUMBER
	    ,p_investor_agreement  IN  VARCHAR2
	    ,p_to_date		    IN  VARCHAR2)
IS

    -- Local Variables
    l_api_version      NUMBER := 1;
    lx_msg_count       NUMBER;
    lx_msg_data        VARCHAR2(450);
    l_msg_index_out    NUMBER;
    lx_return_status   VARCHAR(1);


    -- Input parameters to the conc program
    l_from_date         DATE;
    l_to_date           DATE;


    -- Log Meesage reporting
    l_request_id      NUMBER;

    CURSOR req_id_csr IS
	  SELECT
          DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
	  FROM dual;

    CURSOR tap_cnt_succ_csr( p_req_id NUMBER ) IS
          SELECT count(*)
          FROM okl_trx_ap_invoices_v a,
               okl_txl_ap_inv_lns_v b
          WHERE a.id = b.tap_id AND
                a.trx_status_code = 'ENTERED' AND
                a.request_id = p_req_id ;

    CURSOR tap_cnt_err_csr( p_req_id NUMBER ) IS
          SELECT count(*)
          FROM okl_trx_ap_invoices_v a,
               okl_txl_ap_inv_lns_v b
          WHERE a.id = b.tap_id AND
                a.trx_status_code = 'ERROR' AND
                a.request_id = p_req_id ;

    l_succ_cnt    NUMBER;
    l_err_cnt     NUMBER;

BEGIN

    l_succ_cnt    := 0;
    l_err_cnt     := 0;

    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    -- Format Input parameters
--    IF p_from_date IS NOT NULL THEN
--        l_from_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_date);
--    END IF;

    IF p_to_date IS NOT NULL THEN
        --commented out by pgomes on 03/25/2003
        --removed the comments stmathew 04/07/2004
        --convert to fnd_canonical date
        l_to_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_date);
    END IF;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Create Investor Invoice Disbursements');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date: '||sysdate||' Request Id: '||l_request_id);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Investor Agreement: '||p_investor_agreement);
--    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'From Invoice Date: '||l_from_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'To Invoice Date: '||l_to_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

        OKL_INVESTOR_DISBURSEMENT_IN
                (p_api_version        => l_api_version
	            ,p_init_msg_list      => OKC_API.G_FALSE
	            ,x_return_status      => lx_return_status
	            ,x_msg_count          => lx_msg_count
	            ,x_msg_data           => errbuf
	            ,p_investor_agreement => p_investor_agreement
	            ,px_to_date            => l_to_date);


     -- Success Count
     OPEN   tap_cnt_succ_csr( l_request_id );
     FETCH  tap_cnt_succ_csr INTO l_succ_cnt;
     CLOSE  tap_cnt_succ_csr;

     -- Error Count
     OPEN   tap_cnt_err_csr( l_request_id );
     FETCH  tap_cnt_err_csr INTO l_err_cnt;
     CLOSE  tap_cnt_err_csr;


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Successful records in OKL_TRX_AP_INVOICES_B :'||l_succ_cnt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Errored records in OKL_TRX_AP_INVOICES_B :'||l_err_cnt);


    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success or Error Detailed Messages (If Any):');

    IF lx_msg_count >= 1 THEN
        FOR i in 1..lx_msg_count LOOP
            fnd_msg_pub.get (
                       p_msg_index     => i,
                       p_encoded       => 'F',
                       p_data          => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
        END LOOP;
    END IF;
EXCEPTION
   WHEN OTHERS THEN
     FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

END OKL_INVESTOR_DISBURSEMENT;

END OKL_INVESTOR_INVOICE_DISB_PUB;

/
