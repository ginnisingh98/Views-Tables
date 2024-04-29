--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_DISB_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_DISB_PUB" AS
/* $Header: OKLPPIDB.pls 120.2 2005/06/03 23:18:48 pjgomes noship $ */

PROCEDURE auto_disbursement(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
	,p_from_date	    IN  DATE
	,p_to_date		    IN  DATE
  ,p_contract_number IN VARCHAR2)

IS
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
--l_from_date	            DATE;
--l_to_date	            DATE;

BEGIN

SAVEPOINT auto_disbursement;




--dbms_output.put_line('call to pvt ');
	okl_pay_invoices_disb_pvt.auto_disbursement(
    p_api_version		=> p_api_version
	,p_init_msg_list	=> p_init_msg_list
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		    => x_msg_data
	,p_from_date	    => p_from_date
	,p_to_date		    => p_to_date
  ,p_contract_number => p_contract_number);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO auto_disbursement;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO auto_disbursement;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO auto_disbursement;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_INVOICES_DISB_PUB','AUTO_DISBURSEMENT');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END AUTO_DISBURSEMENT;

PROCEDURE auto_disbursement
    (errbuf	 OUT NOCOPY  VARCHAR2
    ,retcode OUT NOCOPY  NUMBER
    ,p_from_date IN  VARCHAR2
    ,p_to_date	 IN  VARCHAR2
    ,p_contract_number IN VARCHAR2) is

    l_api_vesrions   NUMBER := 1;
    lx_msg_count     NUMBER;
    l_count         NUMBER :=0;
    l_count1          NUMBER :=0;
    l_count2          NUMBER :=0;
    lx_msg_data       VARCHAR2(450);
    i                 NUMBER;
    l_msg_index_out   NUMBER;
    lx_return_status  VARCHAR(1);
    l_from_date         DATE;
    l_to_date           DATE;

   BEGIN

    IF p_from_date IS NOT NULL THEN
    l_from_date :=  FND_DATE.CANONICAL_TO_DATE(p_from_date);
    END IF;

    IF p_to_date IS NOT NULL THEN
    l_to_date :=  FND_DATE.CANONICAL_TO_DATE(p_to_date);
    END IF;

    SELECT count(*) INTO l_count1 FROM OKL_TRX_AP_INVOICES_B;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Pay Invoices Creation By Auto-Disbursement from Consolidated Invoices');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'From Consolidated Invoice Date:'||l_from_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'To Consolidated Invoice Date:'||l_to_date);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number:'||p_contract_number);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Success or Error Detailed Messages If Any For Each Consolidated Invoice');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
--dbms_output.put_line('From Consolidated Invoice Date:'||l_from_date);
--dbms_output.put_line('To Consolidated Invoice Date:'||l_to_date);
           auto_disbursement( p_api_version    => l_api_vesrions,
                            p_init_msg_list    => OKC_API.G_FALSE,
                        	x_return_status    => lx_return_status,
                        	x_msg_count        => lx_msg_count,
                        	x_msg_data         => errbuf,
                            p_from_date        => l_from_date,
                            p_to_date          => l_to_date,
                            p_contract_number  => p_contract_number
                            );

    SELECT count(*) INTO l_count2 FROM OKL_TRX_AP_INVOICES_B;

    l_count  := l_count2 -  l_count1;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Invoice Lines Created in OKL_TRX_AP_INVOICES_B :'||TO_CHAR(l_count));
    --FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Invoice Lines in OKL_TRX_AP_INVOICES_B :'||TO_CHAR(l_count2));


        IF lx_msg_count >= 1 THEN
        FOR i in 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
      END LOOP;
      END IF;
      EXCEPTION
      WHEN OTHERS THEN

     FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
     --dbms_output.put_line('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);

   END;

END;

/
