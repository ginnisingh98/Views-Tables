--------------------------------------------------------
--  DDL for Package Body OKL_CASH_APPL_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_APPL_RULES_PUB" AS
/* $Header: OKLPCAPB.pls 120.5 2007/08/02 15:49:47 nikshah ship $ */

PROCEDURE okl_cash_applic  (   p_api_version	      IN  NUMBER
  				               ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
				               ,x_return_status       OUT NOCOPY VARCHAR2
				               ,x_msg_count	          OUT NOCOPY NUMBER
				               ,x_msg_data	          OUT NOCOPY VARCHAR2
                               ,p_cons_bill_id        IN  OKL_CNSLD_AR_HDRS_V.ID%TYPE DEFAULT NULL
				               ,p_cons_bill_num       IN  OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE DEFAULT NULL
				               ,p_currency_code       IN  OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT NULL
                               ,p_currency_conv_type  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL
                               ,p_currency_conv_date  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE DEFAULT NULL
				               ,p_currency_conv_rate  IN  OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE DEFAULT NULL
				               ,p_irm_id	          IN  OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE DEFAULT NULL
				               ,p_check_number        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
				               ,p_rcpt_amount	      IN  OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT NULL
                               ,p_contract_id         IN  OKC_K_HEADERS_B.ID%TYPE DEFAULT NULL
				               ,p_contract_num        IN  OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE DEFAULT NULL
                               ,p_customer_id         IN  OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE DEFAULT NULL
				               ,p_customer_num        IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                               ,p_gl_date             IN  OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE DEFAULT NULL
                               ,p_receipt_date        IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                               ,p_bank_account_id     IN  OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE
                               ,p_comments            IN  AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE DEFAULT NULL
                               ,p_create_receipt_flag IN  VARCHAR2
							   ) IS

l_api_version 			NUMBER ;
l_init_msg_list 		VARCHAR2(1) ;
l_return_status 		VARCHAR2(1);
l_msg_count 			NUMBER ;
l_msg_data 				VARCHAR2(2000);

lp_cons_bill_id    		OKL_CNSLD_AR_HDRS_V.ID%TYPE;
lp_cons_bill_num   		OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE;
lp_currency_code   		OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE;
lp_currency_conv_type	OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE;
lp_currency_conv_date   OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE;
lp_currency_conv_rate   OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE;
lp_irm_id	      	    OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE;
lp_check_number    		OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
lp_rcpt_amount	  		OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE;
lp_contract_id     		OKC_K_HEADERS_B.ID%TYPE;
lp_contract_num    		OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
lp_customer_id     		OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE;
lp_customer_num    		AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE;
lp_gl_date              OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
lp_receipt_date         OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE;
lp_bank_account_id      OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE;
lp_comments             AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE;

lx_cons_bill_id    		OKL_CNSLD_AR_HDRS_V.ID%TYPE;
lx_cons_bill_num   		OKL_CNSLD_AR_HDRS_V.CONSOLIDATED_INVOICE_NUMBER%TYPE;
lx_currency_code   		OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE;
lx_currency_conv_type	OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_TYPE%TYPE;
lx_currency_conv_date   OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE_DATE%TYPE;
lx_currency_conv_rate   OKL_TRX_CSH_RECEIPT_V.EXCHANGE_RATE%TYPE;
lx_irm_id    	      	OKL_TRX_CSH_RECEIPT_V.IRM_ID%TYPE;
lx_check_number    		OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE;
lx_rcpt_amount	  		OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE;
lx_contract_id     		OKC_K_HEADERS_B.ID%TYPE;
lx_contract_num    		OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
lx_customer_id     		OKL_TRX_CSH_RECEIPT_V.ILE_id%TYPE;
lx_customer_num    		AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE;
lx_gl_date              OKL_TRX_CSH_RECEIPT_V.GL_DATE%TYPE;
lx_receipt_date         OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE;
lx_bank_account_id      OKL_TRX_CSH_RECEIPT_V.IBA_ID%TYPE;
lx_comments             AR_CASH_RECEIPTS_ALL.COMMENTS%TYPE;

BEGIN

SAVEPOINT cash_appl_rules;


l_api_version 			  := p_api_version ;
l_init_msg_list 		  := p_init_msg_list ;
l_return_status 		  := x_return_status ;
l_msg_count 			  := x_msg_count ;
l_msg_data 				  := x_msg_data ;

lp_cons_bill_id   		  := p_cons_bill_id;
lp_cons_bill_num  		  := p_cons_bill_num;
lp_currency_code   		  := p_currency_code;

lp_currency_conv_type     := p_currency_conv_type;
lp_currency_conv_date     := p_currency_conv_date;
lp_currency_conv_rate     := p_currency_conv_rate;

lp_irm_id	      	      := p_irm_id;
lp_check_number    		  := p_check_number;
lp_rcpt_amount	  		  := p_rcpt_amount;
lp_contract_id            := p_contract_id;
lp_contract_num   		  := p_contract_num;
lp_customer_id    		  := p_customer_id;
lp_customer_num			  := p_customer_num;
lp_gl_date                := p_gl_date;
lp_comments               := p_comments;
lp_receipt_date           := p_receipt_date;
lp_bank_account_id        := p_bank_account_id;



Okl_Cash_Appl_Rules.handle_manual_pay     ( l_api_version
				             	  		   ,l_init_msg_list
				             	  		   ,l_return_status
				             	  		   ,l_msg_count
				             	  		   ,l_msg_data
                             	  		   ,lp_cons_bill_id
				             	  		   ,lp_cons_bill_num
				             	  		   ,lp_currency_code
                                           ,lp_currency_conv_type
                                           ,lp_currency_conv_date
  		                                   ,lp_currency_conv_rate
				             	  		   ,lp_irm_id
				             	  		   ,lp_check_number
				             	  		   ,lp_rcpt_amount
										   ,lp_contract_id
				             	  		   ,lp_contract_num
                             	  		   ,lp_customer_id
				             	  		   ,lp_customer_num
                                           ,lp_gl_date
                                           ,lp_receipt_date
                                           ,lp_bank_account_id
                                           ,lp_comments
                                           ,p_create_receipt_flag
							  	  		   );


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO cash_appl_rules;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO cash_appl_rules;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO cash_appl_rules;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CASH_APPL_RULES_PUB','unexpected error');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


 END Okl_Cash_Applic;

 PROCEDURE create_manual_receipt ( p_api_version	      IN  NUMBER
		                   ,p_init_msg_list       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
		                   ,x_return_status       OUT NOCOPY VARCHAR2
                                   ,x_msg_count	          OUT NOCOPY NUMBER
                                   ,x_msg_data	          OUT NOCOPY VARCHAR2
                                   ,p_cons_bill_id        IN  OKL_CNSLD_AR_HDRS_V.ID%TYPE DEFAULT NULL
                                   ,p_ar_inv_id           IN  RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE DEFAULT NULL
                                   ,p_contract_id         IN  OKC_K_HEADERS_ALL_B.ID%TYPE DEFAULT NULL
                                   ,p_rcpt_rec            IN  OKL_CASH_APPL_RULES.rcpt_rec_type
				   ,x_cash_receipt_id     OUT NOCOPY NUMBER
			      ) IS

l_api_version 			NUMBER ;
l_init_msg_list 		VARCHAR2(1) ;
l_return_status 		VARCHAR2(1);
l_msg_count 			NUMBER ;
l_msg_data 				VARCHAR2(2000);

l_cons_bill_id    		OKL_CNSLD_AR_HDRS_V.ID%TYPE;
l_ar_inv_id    		RA_CUSTOMER_TRX_ALL.CUSTOMER_TRX_ID%TYPE;
l_contract_id          OKC_K_HEADERS_B.ID%TYPE;

l_rcpt_rec             Okl_Cash_Appl_Rules.rcpt_rec_type;

BEGIN

SAVEPOINT create_manual_receipt;


l_api_version 			  := p_api_version ;
l_init_msg_list 		  := p_init_msg_list ;
l_return_status 		  := x_return_status ;
l_msg_count 			  := x_msg_count ;
l_msg_data 				  := x_msg_data ;

l_cons_bill_id   		  := p_cons_bill_id;
l_ar_inv_id              := p_ar_inv_id;
l_contract_id            := p_contract_id;
l_rcpt_rec               := p_rcpt_rec;


Okl_Cash_Appl_Rules.create_manual_receipt ( p_api_version => l_api_version
	          	  		   ,p_init_msg_list => l_init_msg_list
	          	  		   ,x_return_status => l_return_status
	            	  		   ,x_msg_count => l_msg_count
	             	  		   ,x_msg_data => l_msg_data
                       	  		   ,p_cons_bill_id => l_cons_bill_id
	             	  		   ,p_ar_inv_id => l_cons_bill_id
	             	  		   ,p_contract_id => l_contract_id
	             	  		   ,p_rcpt_rec => l_rcpt_rec
	             	  		   ,x_cash_receipt_id => x_cash_receipt_id
		  	  		   );


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_manual_receipt;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_manual_receipt;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_manual_receipt;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CASH_APPL_RULES_PUB','unexpected error');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


 END create_manual_receipt;


END okl_cash_appl_rules_pub;

/
