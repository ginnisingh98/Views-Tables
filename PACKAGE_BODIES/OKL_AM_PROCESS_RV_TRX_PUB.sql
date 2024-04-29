--------------------------------------------------------
--  DDL for Package Body OKL_AM_PROCESS_RV_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PROCESS_RV_TRX_PUB" AS
/* $Header: OKLPRVPB.pls 115.3 2004/04/13 11:03:58 rnaik noship $ */


PROCEDURE process_transactions_wrap(    ERRBUF                  OUT 	NOCOPY VARCHAR2,
                                        RETCODE                 OUT     NOCOPY VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        p_khr_id                IN      NUMBER   DEFAULT NULL,
                                        p_kle_id                IN      VARCHAR2 DEFAULT NULL) AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;

    lp_khr_id                       NUMBER;
    lp_kle_id                       NUMBER;
    lx_errbuf                       VARCHAR2(2000);
    lx_retcode                      VARCHAR2(2000);
BEGIN
SAVEPOINT trx_process_transactions_wrap;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;


lp_khr_id                      := p_khr_id;
lp_kle_id                      := p_kle_id;
lx_errbuf                      := ERRBUF;
lx_retcode                     := RETCODE;

-- call the insert of pvt
	OKL_AM_PROCESS_RV_TRX_PVT.process_transactions_wrap(
                                        ERRBUF                   => lx_errbuf,
                                        RETCODE                  => lx_retcode,
                                        p_api_version            => l_api_version,
           			                    p_init_msg_list          => l_init_msg_list,
                                        p_khr_id                 => lp_khr_id,
                                        p_kle_id                 => lp_kle_id);

    IF ( lx_retcode <> 0 )  THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
--Assign value to OUT variables
ERRBUF := lx_errbuf ;
RETCODE := lx_retcode;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_process_transactions_wrap;


    WHEN OTHERS THEN
      ROLLBACK TO trx_process_transactions_wrap;

END process_transactions_wrap;



PROCEDURE process_transactions(   p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_khr_id    	         IN   NUMBER DEFAULT NULL,
                             p_kle_id                IN   NUMBER DEFAULT NULL,
                             x_total_count           OUT  NOCOPY NUMBER,
                             x_processed_count       OUT  NOCOPY NUMBER,
                             x_error_count           OUT  NOCOPY NUMBER) AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER ;
    l_msg_data                      VARCHAR2(2000);
    lp_khr_id                       NUMBER;
    lp_kle_id                       NUMBER;
    lx_total_count                  NUMBER;
    lx_processed_count              NUMBER;
    lx_error_count                  NUMBER;

BEGIN
SAVEPOINT trx_process_transactions;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;

lp_khr_id                      := p_khr_id;
lp_kle_id                      := p_kle_id;
lx_total_count                 := x_total_count;
lx_processed_count             := x_processed_count;
lx_error_count                 := x_error_count;

-- call the insert of pvt
	OKL_AM_PROCESS_RV_TRX_PVT.process_transactions(
                                                  p_api_version     => l_api_version,
                                                  p_init_msg_list   => l_init_msg_list
	                                             ,x_msg_data        => l_msg_data
	                                             ,x_msg_count       => l_msg_count
	                                             ,x_return_status   => l_return_status
	                                              ,p_khr_id         => lp_khr_id,
                                                  p_kle_id          => lp_kle_id,
                                                  x_total_count     => lx_total_count,
                                                  x_processed_count => lx_processed_count,
                                                  x_error_count     => lx_error_count) ;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_total_count := lx_total_count;
x_processed_count := lx_processed_count;
x_error_count := lx_error_count;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_process_transactions;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_process_transactions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_process_transactions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_PROCESS_ASSET_TRX_PUB','process_transactions');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END process_transactions;
END OKL_AM_PROCESS_RV_TRX_PUB;

/
