--------------------------------------------------------
--  DDL for Package Body OKL_OPEN_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPEN_INTERFACE_PUB" AS
/* $Header: OKLPOPIB.pls 115.10 2004/04/13 10:54:35 rnaik noship $ */

---------------------------------------------------------------------------
-- PROCEDURE insert_pending_int
---------------------------------------------------------------------------
PROCEDURE insert_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_contract_id              IN NUMBER,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
l_contract_id NUMBER;
lp_oinv_rec oinv_rec_type;
lx_oinv_rec oinv_rec_type;

BEGIN

SAVEPOINT insert_pending_int;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
l_contract_id := p_contract_id;



-- Private API Call start
okl_opi_pvt.insert_pending_int(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_contract_id => l_contract_id,
     x_oinv_rec => lx_oinv_rec,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);
-- Private API Call end


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_oinv_rec := lx_oinv_rec;



--Assign value to OUT variables
x_oinv_rec  := lx_oinv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_pending_int;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_pending_int;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO insert_pending_int;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','insert_pending_int');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_pending_int;

/*
---------------------------------------------------------------------------
-- PROCEDURE report_all_credit_bureau
---------------------------------------------------------------------------
PROCEDURE report_all_credit_bureau(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER) AS
lx_errbuf            VARCHAR2(2000);
lx_retcode           NUMBER;
BEGIN
okl_opi_pvt.report_all_credit_bureau(
    errbuf => lx_errbuf,
    retcode => lx_retcode);


errbuf := lx_errbuf;
retcode := lx_retcode;
END report_all_credit_bureau;
*/
---------------------------------------------------------------------------
-- PROCEDURE process_pending_int
---------------------------------------------------------------------------
PROCEDURE process_pending_int(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_oinv_rec                 IN oinv_rec_type,
     p_iohv_rec                 IN iohv_rec_type,
     x_oinv_rec                 OUT NOCOPY oinv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);

lp_oinv_rec oinv_rec_type;
lx_oinv_rec oinv_rec_type;
lp_iohv_rec iohv_rec_type;

BEGIN

SAVEPOINT process_pending_int;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_oinv_rec := p_oinv_rec;
lp_iohv_rec := p_iohv_rec;



-- Private API Call start
okl_opi_pvt.process_pending_int(
     p_api_version => l_api_version,
     p_init_msg_list => l_init_msg_list,
     p_oinv_rec => lp_oinv_rec,
     p_iohv_rec => lp_iohv_rec,
     x_oinv_rec => lx_oinv_rec,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => l_msg_data);
-- Private API Call end


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_oinv_rec := lx_oinv_rec;



--Assign value to OUT variables
x_oinv_rec  := lx_oinv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO process_pending_int;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO process_pending_int;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO process_pending_int;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INTERFACE_PUB','insert_pending_int');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END process_pending_int;

END okl_open_interface_pub;

/
