--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_TRANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_TRANS_PUB" AS
/* $Header: OKLPPIIB.pls 115.9 2004/04/13 10:56:36 rnaik noship $ */

PROCEDURE transfer(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2)

IS

BEGIN

SAVEPOINT transfer;





	okl_pay_invoices_trans_pvt.transfer(
    p_api_version		=> p_api_version
	,p_init_msg_list	=> p_init_msg_list
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		    => x_msg_data);

IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO transfer;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := x_msg_count ;
      x_msg_data := x_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO transfer;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := x_msg_count ;
      x_msg_data := x_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO transfer;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := x_msg_count ;
      x_msg_data := x_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_INVOICES_TRANS_PUB','AUTO_DISBURSEMENT');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END transfer;

  PROCEDURE transfer
  ( errbuf                         OUT NOCOPY VARCHAR2
  , retcode                        OUT NOCOPY NUMBER
  )  is

  l_api_vesrions   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_count1          NUMBER :=0;
  l_count2          NUMBER:=0;
  l_count           NUMBER:=0;
  lx_msg_data       VARCHAR2(450);
  i                 NUMBER;
  l_msg_index_out   NUMBER;
  lx_return_status  VARCHAR(1);

    BEGIN

    select count(*) into l_count1 from ap_invoices_interface;

           transfer        ( p_api_version        => l_api_vesrions,
                            p_init_msg_list    => OKC_API.G_FALSE,
                        	x_return_status    => lx_return_status,
                        	x_msg_count        => lx_msg_count,
                        	x_msg_data         => errbuf);

     select count(*) into l_count2 from ap_invoices_interface;
     l_count  := l_count2 -  l_count1;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Payables Invoices Transfer to AP');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||sysdate);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Invoices Prepared in ap_invoices_interface :'||l_count);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');


      END;

END;

/
