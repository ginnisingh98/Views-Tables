--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_SALES_TAX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_SALES_TAX_PUB" BODY	OKL_PROCESS_SALES_TAX_PUB AS
/* $Header: OKLPPSTB.pls 120.2 2007/07/12 22:19:47 rravikir ship $ */

  -- Start of comments
  -- Procedure Name	  : calculate_sales_tax
  -- Description	  : This procedure calls pvt procedure to calculate sales tax
  -- Business Rules   :
  -- Parameters		  : p_source_trx_id - source transaction ID
  --                    p_source_trx_name - source trx name
  --                    p_source_table - source transaction table
  -- Version		  : 1.0
  -- History          :
  -- End of comments
PROCEDURE  calculate_sales_tax(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_source_trx_id				 	IN  NUMBER,
    p_source_trx_name               IN  VARCHAR2,
    p_source_table                  IN  VARCHAR2,
    p_tax_call_type                 IN  VARCHAR2 DEFAULT NULL,
    p_serialized_asset              IN  VARCHAR2 DEFAULT NULL,
    p_request_id                    IN  NUMBER   DEFAULT NULL,
    p_alc_final_call                IN  VARCHAR2 DEFAULT NULL) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

    lp_source_trx_id 				NUMBER;
    lp_source_trx_name				VARCHAR2(150);
    lp_source_table					VARCHAR2(30);

BEGIN
SAVEPOINT trx_calc_sales_tax;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_source_trx_id :=  p_source_trx_id;
lp_source_trx_name :=  p_source_trx_name;
lp_source_table := p_source_table;

-- call the insert of pvt

	OKL_PROCESS_SALES_TAX_PVT.calculate_sales_tax( p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_source_trx_id	=> lp_source_trx_id
    											  ,p_source_trx_name  => lp_source_trx_name
    											  ,p_source_table => lp_source_table
                                                  ,p_tax_call_type => p_tax_call_type
                                                  ,p_serialized_asset => p_serialized_asset
                                                  ,p_request_id       => p_request_id
                                                  ,p_alc_final_call   => p_alc_final_call);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_calc_sales_tax;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_calc_sales_tax;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_calc_sales_tax;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_SALES_TAX_PUB','calculate_sales_tax');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END calculate_sales_tax;


END OKL_PROCESS_SALES_TAX_PUB;

/
