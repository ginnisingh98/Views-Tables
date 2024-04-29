--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_CONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_CONS_PUB" AS
/* $Header: OKLPPICB.pls 120.5 2007/05/07 23:03:54 ssiruvol ship $ */
PROCEDURE consolidation(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		    OUT NOCOPY VARCHAR2
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_contract_number     IN VARCHAR2
 	,p_vendor           IN VARCHAR2
	,p_vendor_site      IN VARCHAR2
    ,p_vpa_number              IN VARCHAR2
    ,p_stream_type_purpose IN VARCHAR2
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_from_date        IN  DATE
    ,p_to_date          IN  DATE)

IS

BEGIN

SAVEPOINT consolidation;





	okl_pay_invoices_cons_pvt.consolidation(
    p_api_version		=> p_api_version
	,p_init_msg_list	=> p_init_msg_list
	,x_return_status	=> x_return_status
	,x_msg_count		=> x_msg_count
	,x_msg_data		    => x_msg_data
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_contract_number  => p_contract_number
 	,p_vendor        => p_vendor
	,p_vendor_site   => p_vendor_site
    ,p_vpa_number           => p_vpa_number
    ,p_stream_type_purpose => p_stream_type_purpose
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_from_date        => p_from_date
    ,p_to_date          => p_to_date);

IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO consolidation;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := x_msg_count ;
      x_msg_data := x_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO consolidation;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := x_msg_count ;
      x_msg_data := x_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO consolidation;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := x_msg_count ;
      x_msg_data := x_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAY_INVOICES_CONS_PUB','AUTO_DISBURSEMENT');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END consolidation;

  PROCEDURE consolidation_inv
  ( errbuf      OUT NOCOPY VARCHAR2
  , retcode     OUT NOCOPY NUMBER
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
    ,p_contract_number     IN VARCHAR2
 	,p_vendor           IN VARCHAR2
	,p_vendor_site      IN VARCHAR2
    ,p_vpa_number              IN VARCHAR2
    ,p_stream_type_purpose IN VARCHAR2
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
  ,p_from_date  IN  VARCHAR2
  ,p_to_date    IN  VARCHAR2) IS

  l_api_vesrions   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_count1          NUMBER :=0;
  l_count2          NUMBER:=0;
  l_count           NUMBER:=0;
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

    SELECT count(*) INTO l_count1 FROM OKL_EXT_PAY_INVS_B;

           consolidation( p_api_version        => l_api_vesrions,
                            p_init_msg_list    => OKC_API.G_FALSE,
                        	x_return_status    => lx_return_status,
                        	x_msg_count        => lx_msg_count,
                        	x_msg_data         => errbuf,
--start:|  24-APR-2007  cklee Disbursement changes for R12B                          |
                            p_contract_number  => p_contract_number,
                        	p_vendor        => p_vendor,
                        	p_vendor_site   => p_vendor_site,
                            p_vpa_number           => p_vpa_number,
                            p_stream_type_purpose => p_stream_type_purpose,
--end:|  24-APR-2007  cklee Disbursement changes for R12B                          |
                            p_from_date        => l_from_date,
                            p_to_date          => l_to_date);

     SELECT count(*) INTO l_count2 FROM OKL_EXT_PAY_INVS_B;
     l_count  := l_count2 -  l_count1;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'OKL Prepare Payables Invoices');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date:'||SYSDATE);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Number of Invoices Prepared in OKL_EXT_PAY_INVS_B :'||l_count);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Summary Success/Detailed Error Messages');

    IF lx_msg_count >= 1 THEN

        FOR i IN 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,to_char(i) || ': ' || lx_msg_data);
      END LOOP;

      END IF;

      END;


  END;

/
