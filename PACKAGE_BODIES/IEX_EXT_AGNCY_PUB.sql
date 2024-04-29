--------------------------------------------------------
--  DDL for Package Body IEX_EXT_AGNCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_EXT_AGNCY_PUB" AS
/* $Header: IEXPIEAB.pls 120.2 2005/11/17 20:38:49 jsanju ship $ */

PROCEDURE insert_ext_agncy(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ieav_rec              IN  ieav_rec_type
    ,x_ieav_rec              OUT  NOCOPY ieav_rec_type) AS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_ieav_rec  ieav_rec_type;
lx_ieav_rec  ieav_rec_type;

BEGIN

SAVEPOINT ext_agncy_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_ieav_rec :=  p_ieav_rec;
lx_ieav_rec :=  x_ieav_rec;


-- START commenting for bug 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'B', 'C')) THEN
	iex_ext_agncy_cuhk.insert_ext_agncy_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_rec => lp_ieav_rec
	                                           ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT record type variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;



IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'B', 'V')) THEN
	iex_ext_agncy_vuhk.insert_ext_agncy_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_rec => lp_ieav_rec
	                                             ,x_ieav_rec => lx_ieav_rec );
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;
*/

-- END  commenting for bug 4741980
iex_iea_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_ieav_rec
                         ,lx_ieav_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ieav_rec := lx_ieav_rec;
/*
--Vertical post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'A', 'V')) THEN
	iex_ext_agncy_vuhk.insert_ext_agncy_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_ieav_rec => lp_ieav_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post processing user hook call end


--Customer post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'A', 'C')) THEN
	iex_ext_agncy_cuhk.insert_ext_agncy_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_ieav_rec => lp_ieav_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post processing user hook call end

*/
--Assign value to OUT variables
x_ieav_rec  := lx_ieav_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','insert_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_ext_agncy;

PROCEDURE insert_ext_agncy(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ieav_tbl              IN  ieav_tbl_type
    ,x_ieav_tbl              OUT  NOCOPY ieav_tbl_type) AS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_ieav_tbl  ieav_tbl_type;
lx_ieav_tbl  ieav_tbl_type;

BEGIN

SAVEPOINT ext_agncy_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_ieav_tbl :=  p_ieav_tbl;
lx_ieav_tbl :=  x_ieav_tbl;

-- START commenting for bug 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'B', 'C')) THEN
	iex_ext_agncy_cuhk.insert_ext_agncy_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_tbl => lp_ieav_tbl
	                                           ,x_ieav_tbl => lx_ieav_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;

IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'B', 'V')) THEN
	iex_ext_agncy_vuhk.insert_ext_agncy_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_tbl => lp_ieav_tbl
	                                           ,x_ieav_tbl => lx_ieav_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;

-- END commenting for bug 4741980
*/

iex_iea_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_ieav_tbl
                         ,lx_ieav_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ieav_tbl := lx_ieav_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'A', 'V')) THEN
	iex_ext_agncy_vuhk.insert_ext_agncy_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_ext_agncy', 'A', 'C')) THEN
	iex_ext_agncy_cuhk.insert_ext_agncy_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_tbl  => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_ieav_tbl  := lx_ieav_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','insert_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_ext_agncy;

PROCEDURE lock_ext_agncy(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ieav_rec              IN ieav_rec_type) AS

BEGIN
    iex_iea_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_ieav_rec);

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
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','lock_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_ext_agncy;

PROCEDURE lock_ext_agncy(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ieav_tbl              IN  ieav_tbl_type) AS

BEGIN
    iex_iea_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_ieav_tbl);

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
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','lock_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_ext_agncy;

PROCEDURE update_ext_agncy(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ieav_rec              IN  ieav_rec_type
    ,x_ieav_rec              OUT  NOCOPY ieav_rec_type) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_ieav_rec  ieav_rec_type;
lx_ieav_rec  ieav_rec_type;

BEGIN

SAVEPOINT ext_agncy_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_ieav_rec :=  p_ieav_rec;
lx_ieav_rec :=  x_ieav_rec;

--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'B', 'C')) THEN
	iex_ext_agncy_cuhk.update_ext_agncy_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_rec => lp_ieav_rec
	                                           ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;


IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'B', 'V')) THEN
	iex_ext_agncy_vuhk.update_ext_agncy_pre (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_rec => lp_ieav_rec
	                                           ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;

--END FOR BUG 4741980
*/

    iex_iea_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_ieav_rec
                             ,lx_ieav_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ieav_rec := lx_ieav_rec;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'A', 'V')) THEN
	iex_ext_agncy_vuhk.update_ext_agncy_post (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_rec => lp_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'A', 'C')) THEN
	iex_ext_agncy_cuhk.update_ext_agncy_post (
	                                           p_init_msg_list=>l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_ieav_rec => lp_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_ieav_rec  := lx_ieav_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','update_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_ext_agncy;

PROCEDURE update_ext_agncy(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ieav_tbl              IN  ieav_tbl_type
    ,x_ieav_tbl              OUT  NOCOPY ieav_tbl_type) AS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_ieav_tbl  ieav_tbl_type;
lx_ieav_tbl  ieav_tbl_type;

BEGIN

SAVEPOINT ext_agncy_update;


lp_ieav_tbl :=  p_ieav_tbl;
lx_ieav_tbl :=  x_ieav_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;


--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'B', 'C')) THEN
	iex_ext_agncy_cuhk.update_ext_agncy_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_tbl => lp_ieav_tbl
	                                             ,x_ieav_tbl => lx_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;


IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'B', 'V')) THEN
	iex_ext_agncy_vuhk.update_ext_agncy_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_tbl => lp_ieav_tbl
	                                             ,x_ieav_tbl => lx_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;

--END FOR BUG 4741980
*/
    iex_iea_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_ieav_tbl
                             ,lx_ieav_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ieav_tbl := lx_ieav_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'A', 'V')) THEN
	iex_ext_agncy_vuhk.update_ext_agncy_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_ext_agncy', 'A', 'C')) THEN
	iex_ext_agncy_cuhk.update_ext_agncy_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_ieav_tbl  := lx_ieav_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','update_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_ext_agncy;

--Put custom code for cascade delete by developer
PROCEDURE delete_ext_agncy(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ieav_rec              IN ieav_rec_type) AS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ieav_rec  ieav_rec_type;
lx_ieav_rec  ieav_rec_type;

BEGIN

SAVEPOINT ext_agncy_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ieav_rec :=  p_ieav_rec;
lx_ieav_rec :=  p_ieav_rec;

--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'B', 'C')) THEN
	iex_ext_agncy_cuhk.delete_ext_agncy_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_rec => lp_ieav_rec
	                                             ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;


IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'B', 'V')) THEN
	iex_ext_agncy_vuhk.delete_ext_agncy_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_ieav_rec => lp_ieav_rec
	                                             ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;

--END FOR BUG 4741980
*/
--Delete the Master
iex_iea_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_ieav_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'A', 'V')) THEN
iex_ext_agncy_vuhk.delete_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_rec => lp_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;


IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'A', 'C')) THEN
iex_ext_agncy_cuhk.delete_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_rec => lp_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;

--END FOR BUG 4741980
*/
--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','delete_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_ext_agncy;

PROCEDURE delete_ext_agncy(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_ieav_tbl           IN ieav_tbl_type) AS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ieav_tbl  ieav_tbl_type;
lx_ieav_tbl  ieav_tbl_type;

BEGIN

SAVEPOINT ext_agncy_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ieav_tbl :=  p_ieav_tbl;
lx_ieav_tbl :=  p_ieav_tbl;

--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'B', 'C')) THEN
iex_ext_agncy_cuhk.delete_ext_agncy_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl
                                             ,x_ieav_tbl => lx_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'B', 'V')) THEN
iex_ext_agncy_vuhk.delete_ext_agncy_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl
                                             ,x_ieav_tbl => lx_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;
--Vertical pre-processing user hook call end

--END FOR BUG 4741980
*/

BEGIN
      --Initialize the return status
      l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (lp_ieav_tbl.COUNT > 0) THEN
       	  i := p_ieav_tbl.FIRST;
       LOOP
          delete_ext_agncy(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_ieav_tbl(i));
          EXIT WHEN (i = lp_ieav_tbl.LAST);
          i := p_ieav_tbl.NEXT(i);
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
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'A', 'V')) THEN
iex_ext_agncy_vuhk.delete_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_ext_agncy', 'A', 'C')) THEN
iex_ext_agncy_cuhk.delete_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','delete_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_ext_agncy;

PROCEDURE validate_ext_agncy(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_ieav_rec         IN  ieav_rec_type) AS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ieav_rec  ieav_rec_type;
lx_ieav_rec  ieav_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT ext_agncy_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ieav_rec :=  p_ieav_rec;
lx_ieav_rec :=  p_ieav_rec;

--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'B', 'C')) THEN
iex_ext_agncy_cuhk.validate_ext_agncy_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_rec => lp_ieav_rec
                                             ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'B', 'V')) THEN
iex_ext_agncy_vuhk.validate_ext_agncy_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_rec => lp_ieav_rec
                                             ,x_ieav_rec => lx_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_rec := lx_ieav_rec;

END IF;
--Vertical pre-processing user hook call end

--END FOR BUG 4741980
*/

iex_iea_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_ieav_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ieav_rec := lx_ieav_rec;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'A', 'V')) THEN
iex_ext_agncy_vuhk.validate_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_rec => lp_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;



--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'A', 'C')) THEN
iex_ext_agncy_cuhk.validate_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_rec => lp_ieav_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','validate_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_ext_agncy;

PROCEDURE validate_ext_agncy(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_ieav_tbl          IN  ieav_tbl_type) AS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ieav_tbl  ieav_tbl_type;
lx_ieav_tbl  ieav_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT ext_agncy_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ieav_tbl :=  p_ieav_tbl;
lx_ieav_tbl :=  p_ieav_tbl;

--START FOR BUG 4741980
/*
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'B', 'C')) THEN
iex_ext_agncy_cuhk.validate_ext_agncy_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl
                                             ,x_ieav_tbl => lx_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'B', 'V')) THEN
iex_ext_agncy_vuhk.validate_ext_agncy_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl
                                             ,x_ieav_tbl => lx_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_ieav_tbl := lx_ieav_tbl;

END IF;
--Vertical pre-processing user hook call end

--END FOR BUG 4741980
*/
iex_iea_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_ieav_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ieav_tbl := lx_ieav_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'A', 'V')) THEN
iex_ext_agncy_vuhk.validate_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end
--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_ext_agncy', 'A', 'C')) THEN
iex_ext_agncy_cuhk.validate_ext_agncy_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_ieav_tbl => lp_ieav_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;

*/

--Customer post-processing user hook call end

--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ext_agncy_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ext_agncy_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO ext_agncy_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXT_AGNCY_PUB','validate_ext_agncy');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_ext_agncy;

END IEX_EXT_AGNCY_PUB;

/
