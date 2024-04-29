--------------------------------------------------------
--  DDL for Package Body OKL_PROP_TAX_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROP_TAX_ADJ_PUB" AS
/* $Header: OKLPEPRB.pls 120.3 2005/10/30 04:01:34 appldev noship $ */

PROCEDURE create_adjustment_invoice (
   	       p_api_version                  IN NUMBER,
    	   p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    	   x_return_status                OUT NOCOPY VARCHAR2,
    	   x_msg_count                    OUT NOCOPY NUMBER,
    	   x_msg_data                     OUT NOCOPY VARCHAR2,
           p_contract_number	          IN  VARCHAR2,
           p_asset_number                 IN  VARCHAR2)
IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

BEGIN

        OKL_PROP_TAX_ADJ_PVT.create_adjustment_invoice(
  	       p_api_version     => p_api_version,
    	   p_init_msg_list   => p_init_msg_list,
    	   x_return_status   => x_return_status,
    	   x_msg_count       => x_msg_count,
    	   x_msg_data        => x_msg_data,
           p_contract_number => p_contract_number,
           p_asset_number    => p_asset_number);

END create_adjustment_invoice;

PROCEDURE create_adjust_invoice_conc
  (errbuf                         OUT NOCOPY VARCHAR2
  ,retcode                        OUT NOCOPY NUMBER
  ,p_contract_number	          IN  VARCHAR2
  ,p_asset_number                 IN  VARCHAR2)
IS

  l_api_vesrions   NUMBER := 1;
  lx_msg_count     NUMBER;
  lx_msg_data       VARCHAR2(450);
  i                 NUMBER:=0;
  l_msg_index_out   NUMBER:=0;
  lx_return_status  VARCHAR2(1);

BEGIN

    create_adjustment_invoice(
                            p_api_version      => l_api_vesrions,
                            p_init_msg_list    => OKC_API.G_FALSE,
                        	x_return_status    => lx_return_status,
                        	x_msg_count        => lx_msg_count,
                        	x_msg_data         => errbuf,
                            p_contract_number  => p_contract_number,
                            p_asset_number     => p_asset_number);

    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Property Tax Reconciliation');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Program Run Date:'||SYSDATE);
    FND_FILE.PUT_LINE (FND_FILE.LOG, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.LOG, 'Detailed Error Messages For Each Record:');

    BEGIN
      IF lx_msg_count > 0 THEN
         FOR i IN 1..lx_msg_count LOOP
            fnd_msg_pub.get (p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => lx_msg_data,
                             p_msg_index_out => l_msg_index_out);
            FND_FILE.PUT_LINE (FND_FILE.LOG,TO_CHAR(i) || ': ' || lx_msg_data);
         END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
      	   FND_FILE.PUT_LINE (FND_FILE.LOG,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    END;

END create_adjust_invoice_conc;

END OKL_PROP_TAX_ADJ_PUB;

/
