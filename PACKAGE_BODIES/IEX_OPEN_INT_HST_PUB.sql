--------------------------------------------------------
--  DDL for Package Body IEX_OPEN_INT_HST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_OPEN_INT_HST_PUB" AS
/* $Header: IEXPIOHB.pls 120.4 2005/11/17 20:38:33 jsanju ship $ */

PG_DEBUG NUMBER(2);

PROCEDURE insert_open_int_hst(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iohv_rec              IN  iohv_rec_type
    ,x_iohv_rec              OUT  NOCOPY iohv_rec_type) AS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_iohv_rec  iohv_rec_type;
lx_iohv_rec  iohv_rec_type;

BEGIN

SAVEPOINT open_int_hst_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_iohv_rec :=  p_iohv_rec;
lx_iohv_rec :=  x_iohv_rec;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'B', 'C')) THEN
	iex_open_int_hst_cuhk.insert_open_int_hst_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_rec => lp_iohv_rec
	                                           ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY record type variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Customer pre-processing user hook call end



--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'B', 'V')) THEN
	iex_open_int_hst_vuhk.insert_open_int_hst_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_rec => lp_iohv_rec
	                                             ,x_iohv_rec => lx_iohv_rec );
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ioh_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_iohv_rec
                         ,lx_iohv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_rec := lx_iohv_rec;
/*
--Vertical post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'A', 'V')) THEN
	iex_open_int_hst_vuhk.insert_open_int_hst_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_iohv_rec => lp_iohv_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post processing user hook call end


--Customer post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'A', 'C')) THEN
	iex_open_int_hst_cuhk.insert_open_int_hst_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_iohv_rec => lp_iohv_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post processing user hook call end

*/
--Assign value to OUT NOCOPY variables
x_iohv_rec  := lx_iohv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','insert_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_open_int_hst;

PROCEDURE insert_open_int_hst(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl              IN  iohv_tbl_type
    ,x_iohv_tbl              OUT  NOCOPY iohv_tbl_type) AS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_iohv_tbl  iohv_tbl_type;
lx_iohv_tbl  iohv_tbl_type;

BEGIN

SAVEPOINT open_int_hst_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_iohv_tbl :=  p_iohv_tbl;
lx_iohv_tbl :=  x_iohv_tbl;
/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'B', 'C')) THEN
	iex_open_int_hst_cuhk.insert_open_int_hst_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_tbl => lp_iohv_tbl
	                                           ,x_iohv_tbl => lx_iohv_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'B', 'V')) THEN
	iex_open_int_hst_vuhk.insert_open_int_hst_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_tbl => lp_iohv_tbl
	                                           ,x_iohv_tbl => lx_iohv_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ioh_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_iohv_tbl
                         ,lx_iohv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_tbl := lx_iohv_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'A', 'V')) THEN
	iex_open_int_hst_vuhk.insert_open_int_hst_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_open_int_hst', 'A', 'C')) THEN
	iex_open_int_hst_cuhk.insert_open_int_hst_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_tbl  => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT NOCOPY variables
x_iohv_tbl  := lx_iohv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','insert_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_open_int_hst;

PROCEDURE lock_open_int_hst(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_iohv_rec              IN iohv_rec_type) AS

BEGIN
    iex_ioh_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_iohv_rec);

IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','lock_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_open_int_hst;

PROCEDURE lock_open_int_hst(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl              IN  iohv_tbl_type) AS

BEGIN
    iex_ioh_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_iohv_tbl);

IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','lock_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_open_int_hst;

PROCEDURE update_open_int_hst(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iohv_rec              IN  iohv_rec_type
    ,x_iohv_rec              OUT  NOCOPY iohv_rec_type) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_iohv_rec  iohv_rec_type;
lx_iohv_rec  iohv_rec_type;

BEGIN

SAVEPOINT open_int_hst_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_iohv_rec :=  p_iohv_rec;
lx_iohv_rec :=  x_iohv_rec;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'B', 'C')) THEN
	iex_open_int_hst_cuhk.update_open_int_hst_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_rec => lp_iohv_rec
	                                           ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'B', 'V')) THEN
	iex_open_int_hst_vuhk.update_open_int_hst_pre (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_rec => lp_iohv_rec
	                                           ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
    iex_ioh_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_iohv_rec
                             ,lx_iohv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_rec := lx_iohv_rec;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'A', 'V')) THEN
	iex_open_int_hst_vuhk.update_open_int_hst_post (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_rec => lp_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'A', 'C')) THEN
	iex_open_int_hst_cuhk.update_open_int_hst_post (
	                                           p_init_msg_list=>l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iohv_rec => lp_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT NOCOPY variables
x_iohv_rec  := lx_iohv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','update_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_open_int_hst;

PROCEDURE update_open_int_hst(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl              IN  iohv_tbl_type
    ,x_iohv_tbl              OUT  NOCOPY iohv_tbl_type) AS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_iohv_tbl  iohv_tbl_type;
lx_iohv_tbl  iohv_tbl_type;

BEGIN

SAVEPOINT open_int_hst_update;


lp_iohv_tbl :=  p_iohv_tbl;
lx_iohv_tbl :=  x_iohv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'B', 'C')) THEN
	iex_open_int_hst_cuhk.update_open_int_hst_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_tbl => lp_iohv_tbl
	                                             ,x_iohv_tbl => lx_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'B', 'V')) THEN
	iex_open_int_hst_vuhk.update_open_int_hst_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_tbl => lp_iohv_tbl
	                                             ,x_iohv_tbl => lx_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/
    iex_ioh_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_iohv_tbl
                             ,lx_iohv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_tbl := lx_iohv_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'A', 'V')) THEN
	iex_open_int_hst_vuhk.update_open_int_hst_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_open_int_hst', 'A', 'C')) THEN
	iex_open_int_hst_cuhk.update_open_int_hst_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/

--Assign value to OUT NOCOPY variables
x_iohv_tbl  := lx_iohv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','update_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_open_int_hst;

--Put custom code for cascade delete by developer
PROCEDURE delete_open_int_hst(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iohv_rec              IN iohv_rec_type) AS

i	                    NUMBER;
l_return_status 	    VARCHAR2(1);
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iohv_rec  iohv_rec_type;
lx_iohv_rec  iohv_rec_type;

BEGIN

SAVEPOINT open_int_hst_delete_rec;

i:=0;
l_return_status := OKC_API.G_RET_STS_SUCCESS;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iohv_rec :=  p_iohv_rec;
lx_iohv_rec :=  p_iohv_rec;
/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'B', 'C')) THEN
	iex_open_int_hst_cuhk.delete_open_int_hst_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_rec => lp_iohv_rec
	                                             ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'B', 'V')) THEN
	iex_open_int_hst_vuhk.delete_open_int_hst_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iohv_rec => lp_iohv_rec
	                                             ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
--Delete the Master
iex_ioh_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_iohv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'A', 'V')) THEN
iex_open_int_hst_vuhk.delete_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_rec => lp_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'A', 'C')) THEN
iex_open_int_hst_cuhk.delete_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_rec => lp_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT NOCOPY variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','delete_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_open_int_hst;

PROCEDURE delete_open_int_hst(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_iohv_tbl           IN iohv_tbl_type) AS

i NUMBER := 0;
l_return_status VARCHAR2(1);
l_api_version NUMBER;
l_init_msg_list VARCHAR2(1);
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iohv_tbl  iohv_tbl_type;
lx_iohv_tbl  iohv_tbl_type;

BEGIN

SAVEPOINT open_int_hst_delete_tbl;


l_return_status := OKC_API.G_RET_STS_SUCCESS;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iohv_tbl :=  p_iohv_tbl;
lx_iohv_tbl :=  p_iohv_tbl;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'B', 'C')) THEN
iex_open_int_hst_cuhk.delete_open_int_hst_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl
                                             ,x_iohv_tbl => lx_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'B', 'V')) THEN
iex_open_int_hst_vuhk.delete_open_int_hst_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl
                                             ,x_iohv_tbl => lx_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/

BEGIN
      --Initialize the return status
      l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (lp_iohv_tbl.COUNT > 0) THEN
       	  i := p_iohv_tbl.FIRST;
       LOOP
          delete_open_int_hst(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_iohv_tbl(i));
          EXIT WHEN (i = lp_iohv_tbl.LAST);
          i := p_iohv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'A', 'V')) THEN
iex_open_int_hst_vuhk.delete_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_open_int_hst', 'A', 'C')) THEN
iex_open_int_hst_cuhk.delete_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT NOCOPY variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','delete_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_open_int_hst;

PROCEDURE validate_open_int_hst(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_iohv_rec         IN  iohv_rec_type) AS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iohv_rec  iohv_rec_type;
lx_iohv_rec  iohv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT open_int_hst_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iohv_rec :=  p_iohv_rec;
lx_iohv_rec :=  p_iohv_rec;
/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'B', 'C')) THEN
iex_open_int_hst_cuhk.validate_open_int_hst_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_rec => lp_iohv_rec
                                             ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'B', 'V')) THEN
iex_open_int_hst_vuhk.validate_open_int_hst_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_rec => lp_iohv_rec
                                             ,x_iohv_rec => lx_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_rec := lx_iohv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ioh_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_iohv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_rec := lx_iohv_rec;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'A', 'V')) THEN
iex_open_int_hst_vuhk.validate_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_rec => lp_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;



--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'A', 'C')) THEN
iex_open_int_hst_cuhk.validate_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_rec => lp_iohv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT NOCOPY variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','validate_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_open_int_hst;

PROCEDURE validate_open_int_hst(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 ,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_iohv_tbl          IN  iohv_tbl_type) AS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iohv_tbl  iohv_tbl_type;
lx_iohv_tbl  iohv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT open_int_hst_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iohv_tbl :=  p_iohv_tbl;
lx_iohv_tbl :=  p_iohv_tbl;
/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'B', 'C')) THEN
iex_open_int_hst_cuhk.validate_open_int_hst_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl
                                             ,x_iohv_tbl => lx_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'B', 'V')) THEN
iex_open_int_hst_vuhk.validate_open_int_hst_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl
                                             ,x_iohv_tbl => lx_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT NOCOPY variable in the IN record type
	lp_iohv_tbl := lx_iohv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ioh_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_iohv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT NOCOPY variable in the IN record type
lp_iohv_tbl := lx_iohv_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'A', 'V')) THEN
iex_open_int_hst_vuhk.validate_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end
--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_open_int_hst', 'A', 'C')) THEN
iex_open_int_hst_cuhk.validate_open_int_hst_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iohv_tbl => lp_iohv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;


*/
--Customer post-processing user hook call end

--Assign value to OUT NOCOPY variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO open_int_hst_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO open_int_hst_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO open_int_hst_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_OPEN_INT_HST_PUB','validate_open_int_hst');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_open_int_hst;
BEGIN
PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
END IEX_OPEN_INT_HST_PUB;

/
