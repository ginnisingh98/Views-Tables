--------------------------------------------------------
--  DDL for Package Body OKL_AM_CONTRACT_PRTFL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_CONTRACT_PRTFL_PUB" AS
/* $Header: OKLPPTFB.pls 115.5 2004/04/13 10:59:26 rnaik noship $ */

PROCEDURE create_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_contract_id                   IN  NUMBER) AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER ;
    l_msg_data                      VARCHAR2(2000);
    lp_contract_id                  NUMBER;

BEGIN
SAVEPOINT trx_create_cntrct_prtfl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;

lp_contract_id                 := p_contract_id;



-- call the insert of pvt

OKL_AM_CONTRACT_PRTFL_PVT.create_cntrct_prtfl(
                                                p_api_version                => l_api_version,
                                                p_init_msg_list              => l_init_msg_list,
                                                x_return_status              => l_return_status,
                                                x_msg_count                  => l_msg_count,
                                                x_msg_data                   => l_msg_data,
                                                p_contract_id                => lp_contract_id);


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
      ROLLBACK TO trx_create_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CONTRACT_PRTFL_PUB','create_cntrct_prtfl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_cntrct_prtfl;


PROCEDURE batch_upd_cntrct_prtfl(	    ERRBUF                  OUT 	NOCOPY   VARCHAR2,
                                        RETCODE                 OUT     NOCOPY   VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        p_contract_id           IN      NUMBER   DEFAULT NULL
                                      )   AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;

    lp_contract_id                  NUMBER;
    lx_errbuf                       VARCHAR2(2000);
    lx_retcode                      VARCHAR2(2000);
BEGIN
SAVEPOINT trx_batch_upd_cntrct_prtfl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;


lp_contract_id                 := p_contract_id;

lx_errbuf                      := ERRBUF;
lx_retcode                     := RETCODE;

-- call the insert of pvt
	OKL_AM_CONTRACT_PRTFL_PVT.batch_upd_cntrct_prtfl(
                                        ERRBUF                   => lx_errbuf,
                                        RETCODE                  => lx_retcode,
                                        p_api_version            => l_api_version,
           			                    p_init_msg_list          => l_init_msg_list,
                                        p_contract_id            => lp_contract_id);

    IF ( lx_retcode <> 0 )  THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
--Assign value to OUT variables
ERRBUF := lx_errbuf ;
RETCODE := lx_retcode;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_batch_upd_cntrct_prtfl;


    WHEN OTHERS THEN
      ROLLBACK TO trx_batch_upd_cntrct_prtfl;

END batch_upd_cntrct_prtfl;



PROCEDURE update_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_contract_id                   IN  NUMBER DEFAULT NULL,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER)
 AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER ;
    l_msg_data                      VARCHAR2(2000);
    lp_contract_id                  NUMBER;

    lx_total_count                  NUMBER;
    lx_processed_count              NUMBER;
    lx_error_count                  NUMBER;

BEGIN
SAVEPOINT trx_update_cntrct_prtfl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;

lp_contract_id                 := p_contract_id;

lx_total_count                 := x_total_count;
lx_processed_count             := x_processed_count;
lx_error_count                 := x_error_count;

-- call the insert of pvt
	OKL_AM_CONTRACT_PRTFL_PVT.update_cntrct_prtfl(
                                                   p_api_version     => l_api_version
	                                              ,p_init_msg_list   => l_init_msg_list
                                                  ,x_return_status   => l_return_status
                                                  ,x_msg_count       => l_msg_count
	                                              ,x_msg_data        => l_msg_data
	                                              ,p_contract_id     => lp_contract_id,
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
      ROLLBACK TO trx_update_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CONTRACT_PRTFL_PUB','update_cntrct_prtfl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_cntrct_prtfl;


PROCEDURE batch_exe_cntrct_prtfl(	    ERRBUF                  OUT 	NOCOPY   VARCHAR2,
                                        RETCODE                 OUT     NOCOPY   VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE
                                      )   AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;
    lx_errbuf                       VARCHAR2(2000);
    lx_retcode                      VARCHAR2(2000);
BEGIN
SAVEPOINT trx_batch_exe_cntrct_prtfl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;


lx_errbuf                      := ERRBUF;
lx_retcode                     := RETCODE;

-- call the insert of pvt
	OKL_AM_CONTRACT_PRTFL_PVT.batch_exe_cntrct_prtfl(
                                        ERRBUF                   => lx_errbuf,
                                        RETCODE                  => lx_retcode,
                                        p_api_version            => l_api_version,
           			                    p_init_msg_list          => l_init_msg_list);

    IF ( lx_retcode <> 0 )  THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;
--Assign value to OUT variables
ERRBUF := lx_errbuf ;
RETCODE := lx_retcode;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_batch_exe_cntrct_prtfl;


    WHEN OTHERS THEN
      ROLLBACK TO trx_batch_exe_cntrct_prtfl;

END batch_exe_cntrct_prtfl;



PROCEDURE execute_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER)
 AS

    l_api_version                   NUMBER ;
    l_init_msg_list                 VARCHAR2(1) ;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER ;
    l_msg_data                      VARCHAR2(2000);

    lx_total_count                  NUMBER;
    lx_processed_count              NUMBER;
    lx_error_count                  NUMBER;

BEGIN
SAVEPOINT trx_execute_cntrct_prtfl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;


lx_total_count                 := x_total_count;
lx_processed_count             := x_processed_count;
lx_error_count                 := x_error_count;

-- call the insert of pvt
	OKL_AM_CONTRACT_PRTFL_PVT.execute_cntrct_prtfl(
                                                   p_api_version     => l_api_version
	                                              ,p_init_msg_list   => l_init_msg_list
                                                  ,x_return_status   => l_return_status
                                                  ,x_msg_count       => l_msg_count
	                                              ,x_msg_data        => l_msg_data
	                                              ,x_total_count     => lx_total_count,
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
      ROLLBACK TO trx_execute_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_execute_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_execute_cntrct_prtfl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_CONTRACT_PRTFL_PUB','execute_cntrct_prtfl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END execute_cntrct_prtfl;


END OKL_AM_CONTRACT_PRTFL_PUB;

/
