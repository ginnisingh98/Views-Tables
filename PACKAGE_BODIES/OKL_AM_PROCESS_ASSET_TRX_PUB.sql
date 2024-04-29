--------------------------------------------------------
--  DDL for Package Body OKL_AM_PROCESS_ASSET_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PROCESS_ASSET_TRX_PUB" AS
/* $Header: OKLPAMAB.pls 115.10 2004/04/13 10:30:21 rnaik noship $ */


PROCEDURE process_transactions_wrap(    ERRBUF                  OUT 	NOCOPY VARCHAR2,
                                        RETCODE                 OUT     NOCOPY VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        p_contract_id           IN      NUMBER   DEFAULT NULL,
                                        p_asset_id              IN      NUMBER   DEFAULT NULL,
                                        p_kle_id                IN      VARCHAR2 DEFAULT NULL,
                                        p_salvage_writedown_yn  IN      VARCHAR2 DEFAULT 'N') AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;

    lp_contract_id                  NUMBER;
    lp_asset_id                     NUMBER;
    lp_kle_id                       NUMBER;
    lp_salvage_writedown_yn         VARCHAR2(1);
    lx_errbuf                       VARCHAR2(2000);
    lx_retcode                      VARCHAR2(2000);
BEGIN
SAVEPOINT trx_process_transactions_wrap;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;


lp_contract_id                 := p_contract_id;
lp_asset_id                    := p_asset_id ;
lp_kle_id                      := p_kle_id;
lp_salvage_writedown_yn        := p_salvage_writedown_yn;
lx_errbuf                      := ERRBUF;
lx_retcode                     := RETCODE;

-- call the insert of pvt
	OKL_AM_PROCESS_ASSET_TRX_PVT.process_transactions_wrap(
                                        ERRBUF                   => lx_errbuf,
                                        RETCODE                  => lx_retcode,
                                        p_api_version            => l_api_version,
           			                    p_init_msg_list          => l_init_msg_list,
                                        p_contract_id            => lp_contract_id,
                                        p_asset_id               => lp_asset_id,
                                        p_kle_id                 => lp_kle_id,
                                        p_salvage_writedown_yn   => lp_salvage_writedown_yn);

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
                             p_contract_id    	     IN   NUMBER DEFAULT NULL,
                             p_asset_id              IN   NUMBER DEFAULT NULL,
                             p_kle_id                IN   NUMBER DEFAULT NULL,
                             p_salvage_writedown_yn  IN   VARCHAR2 DEFAULT 'N',
                             x_total_count           OUT     NOCOPY NUMBER,
                             x_processed_count       OUT     NOCOPY NUMBER,
                             x_error_count           OUT     NOCOPY NUMBER) AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER ;
    l_msg_data                      VARCHAR2(2000);
    lp_contract_id                  NUMBER;
    lp_asset_id                     NUMBER;
    lp_kle_id                       NUMBER;
    lp_salvage_writedown_yn         VARCHAR2(1);
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

lp_contract_id                 := p_contract_id;
lp_asset_id                    := p_asset_id ;
lp_kle_id                      := p_kle_id;
lp_salvage_writedown_yn        := p_salvage_writedown_yn;
lx_total_count                 := x_total_count;
lx_processed_count             := x_processed_count;
lx_error_count                 := x_error_count;

-- call the insert of pvt
	OKL_AM_PROCESS_ASSET_TRX_PVT.process_transactions(    p_api_version     => l_api_version
	                                              ,p_init_msg_list          => l_init_msg_list
	                                              ,x_msg_data               => l_msg_data
	                                              ,x_msg_count              => l_msg_count
	                                              ,x_return_status          => l_return_status
	                                              ,p_contract_id            => lp_contract_id,
                                                   p_asset_id               => lp_asset_id,
                                                   p_kle_id                 => lp_kle_id,
                                                   p_salvage_writedown_yn   => lp_salvage_writedown_yn,
                                                   x_total_count            => lx_total_count,
                                                   x_processed_count        => lx_processed_count,
                                                   x_error_count            => lx_error_count) ;
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
END OKL_AM_PROCESS_ASSET_TRX_PUB;

/
